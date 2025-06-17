@isTest
public class MRPGeneratorTest {
    
    @TestSetup
    static void setupTestData() {
        
        List<Material__c> testMaterials = new List<Material__c>();
    
        testMaterials.add(new Material__c(
            Name = 'Test Material 1',
            Stock_Quantity__c = 50,
            Blocked_Stock_Quantity__c = 100
        ));
        
        testMaterials.add(new Material__c(
            Name = 'Test Material 2',
            Stock_Quantity__c = 100,
            Blocked_Stock_Quantity__c = 80
        ));
        
        testMaterials.add(new Material__c(
            Name = 'Test Material 3',
            Stock_Quantity__c = 25,
            Blocked_Stock_Quantity__c = 75
        ));
        
        testMaterials.add(new Material__c(
            Name = 'Test Material 4',
            Stock_Quantity__c = null,
            Blocked_Stock_Quantity__c = 50
        ));
        
        testMaterials.add(new Material__c(
            Name = 'Test Material 5',
            Stock_Quantity__c = 30,
            Blocked_Stock_Quantity__c = null
        ));
        
        insert testMaterials;
    }
    
    @isTest
    static void testGenerateMRPWithNoExistingMRP() {
        Test.startTest();
        MRPGenerator.generateMRP();
        Test.stopTest();
        
        List<Material_Requirements_Planning__c> createdMRPs = [
            SELECT Id, Material__c, Quantity_to_Buy__c, Status__c
            FROM Material_Requirements_Planning__c
            WHERE Status__c = 'Open'
        ];
        
        System.assertEquals(2, createdMRPs.size(), 'Should create 2 MRP records');
        
        Map<Id, Material__c> materialMap = new Map<Id, Material__c>([
            SELECT Id, Name, Stock_Quantity__c, Blocked_Stock_Quantity__c
            FROM Material__c
        ]);
        
        for (Material_Requirements_Planning__c mrp : createdMRPs) {
            Material__c material = materialMap.get(mrp.Material__c);
            Decimal expectedQuantity = material.Blocked_Stock_Quantity__c - material.Stock_Quantity__c;
            System.assertEquals(expectedQuantity, mrp.Quantity_to_Buy__c, 
                'Quantity to buy should be calculated correctly for ' + material.Name);
            System.assertEquals('Open', mrp.Status__c, 'Status should be Open');
        }
    }
    
    @isTest
    static void testGenerateMRPWithExistingMRPUpdate() {
        
        List<Material__c> materials = [SELECT Id FROM Material__c LIMIT 2];
        
        Material_Requirements_Planning__c existingMRP = new Material_Requirements_Planning__c(
            Material__c = materials[0].Id,
            Quantity_to_Buy__c = 30, 
            Status__c = 'Open'
        );
        insert existingMRP;
        
        Material__c materialToUpdate = [
            SELECT Id, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            WHERE Id = :materials[0].Id
        ];
        materialToUpdate.Stock_Quantity__c = 40; 
        materialToUpdate.Blocked_Stock_Quantity__c = 120;
        update materialToUpdate;
        
        Test.startTest();
        MRPGenerator.generateMRP();
        Test.stopTest();
        
        
        Material_Requirements_Planning__c updatedMRP = [
            SELECT Id, Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            WHERE Id = :existingMRP.Id
        ];
        
        System.assertEquals(80, updatedMRP.Quantity_to_Buy__c, 
            'Existing MRP should be updated with new quantity');
    }    
    
    @isTest
    static void testGenerateMRPWithNoMaterials() {
        
        delete [SELECT Id FROM Material__c];
        
        Test.startTest();
        MRPGenerator.generateMRP();
        Test.stopTest();
        
        
        List<Material_Requirements_Planning__c> createdMRPs = [
            SELECT Id FROM Material_Requirements_Planning__c
        ];
        
        System.assertEquals(0, createdMRPs.size(), 
            'No MRP records should be created when no materials exist');
    }
    
    @isTest
    static void testGenerateMRPWithMixedScenarios() {
        
        List<Material__c> materials = [
            SELECT Id, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            WHERE Stock_Quantity__c != null AND Blocked_Stock_Quantity__c != null
            LIMIT 3
        ];
        
        Material_Requirements_Planning__c existingMRP = new Material_Requirements_Planning__c(
            Material__c = materials[0].Id,
            Quantity_to_Buy__c = 999, 
            Status__c = 'Open'
        );
        insert existingMRP;
        
        materials[1].Stock_Quantity__c = 200;
        materials[1].Blocked_Stock_Quantity__c = 100;
        update materials[1];
        
        Test.startTest();
        MRPGenerator.generateMRP();
        Test.stopTest();
        
        
        List<Material_Requirements_Planning__c> allMRPs = [
            SELECT Id, Material__c, Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            ORDER BY Material__c
        ];
        
        System.assertEquals(2, allMRPs.size(), 
            'Should have 2 MRP records after mixed scenario processing');
    }
}
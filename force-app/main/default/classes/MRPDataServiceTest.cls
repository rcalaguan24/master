@isTest
public class MRPDataServiceTest{
    
    @TestSetup
    static void setupTestData() {
        
        List<Material__c> testMaterials = new List<Material__c>();
        
        for (Integer i = 1; i <= 5; i++) {
            testMaterials.add(new Material__c(
                Name = 'Test Material ' + i,
                Stock_Quantity__c = 50 * i,
                Blocked_Stock_Quantity__c = 100 * i
            ));
        }
        
        insert testMaterials;
        
        List<Material_Requirements_Planning__c> testMRPs = new List<Material_Requirements_Planning__c>();
        
        testMRPs.add(new Material_Requirements_Planning__c(
            Material__c = testMaterials[0].Id,
            Quantity_to_Buy__c = 50,
            Status__c = 'Open'
        ));
        
        testMRPs.add(new Material_Requirements_Planning__c(
            Material__c = testMaterials[1].Id,
            Quantity_to_Buy__c = 100,
            Status__c = 'Open'
        ));
        
        testMRPs.add(new Material_Requirements_Planning__c(
            Material__c = testMaterials[2].Id,
            Quantity_to_Buy__c = 75,
            Status__c = 'PO Created'
        ));
        
        testMRPs.add(new Material_Requirements_Planning__c(
            Material__c = testMaterials[3].Id,
            Quantity_to_Buy__c = 125,
            Status__c = 'PO Created'
        ));
        
        insert testMRPs;
    }
    
    @isTest
    static void testGetAllMRP() {
        Test.startTest();
        List<Material_Requirements_Planning__c> openMRPs = MRPDataService.getAllOpenMRP();
        Test.stopTest();
        
        System.assertEquals(2, openMRPs.size(), 'Should return only Open MRP records');
        
        for (Material_Requirements_Planning__c mrp : openMRPs) {
            System.assertEquals('Open', mrp.Status__c, 'All returned MRP records should have Open status');
            System.assertNotEquals(null, mrp.Id, 'MRP record should have valid Id');
            System.assertNotEquals(null, mrp.Material__c, 'MRP record should have Material reference');
            System.assert(mrp.Quantity_to_Buy__c > 0, 'MRP record should have positive quantity');
        }
        
        Set<Decimal> expectedQuantities = new Set<Decimal>{50.00, 100.00};
        Set<Decimal> actualQuantities = new Set<Decimal>();
        for (Material_Requirements_Planning__c mrp : openMRPs) {
            actualQuantities.add(mrp.Quantity_to_Buy__c);
        }
        
        System.assertEquals(expectedQuantities, actualQuantities, 'Returned quantities should match expected values');
    }
    
    @isTest
    static void testGetAllMRPNoRecords() {
        
        delete [SELECT Id FROM Material_Requirements_Planning__c];
        
        Test.startTest();
        List<Material_Requirements_Planning__c> openMRPs = MRPDataService.getAllOpenMRP();
        Test.stopTest();
        
        
        System.assertEquals(0, openMRPs.size(), 'Should return empty list when no Open MRP records exist');
        System.assertNotEquals(null, openMRPs, 'Should return empty list, not null');
    }
    
    @isTest
    static void testUpsertMRPMixedInsertAndUpdate() {
        
        Material_Requirements_Planning__c existingMRP = [
            SELECT Id, Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            WHERE Status__c = 'Open'
            LIMIT 1
        ];
        
        
        Material__c newMaterial = [
            SELECT Id
            FROM Material__c
            WHERE Id NOT IN (SELECT Material__c FROM Material_Requirements_Planning__c)
            LIMIT 1
        ];
        
        List<Material_Requirements_Planning__c> mixedMRPs = new List<Material_Requirements_Planning__c>();
        
        
        existingMRP.Quantity_to_Buy__c = 777;
        mixedMRPs.add(existingMRP);
        
        
        mixedMRPs.add(new Material_Requirements_Planning__c(
            Material__c = newMaterial.Id,
            Quantity_to_Buy__c = 555,
            Status__c = 'Open'
        ));
        
        Test.startTest();
        MRPDataService.upsertMRP(mixedMRPs);
        Test.stopTest();
        
        
        List<Material_Requirements_Planning__c> allMRPs = [
            SELECT Id, Material__c, Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            WHERE Id = :existingMRP.Id OR Material__c = :newMaterial.Id
        ];
        
        System.assertEquals(2, allMRPs.size(), 'Should have both updated and inserted MRP records');
        
        
        Material_Requirements_Planning__c updatedMRP = [
            SELECT Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            WHERE Id = :existingMRP.Id
        ];
        System.assertEquals(777, updatedMRP.Quantity_to_Buy__c, 'Existing MRP should be updated');
        
        
        Material_Requirements_Planning__c insertedMRP = [
            SELECT Id, Quantity_to_Buy__c
            FROM Material_Requirements_Planning__c
            WHERE Material__c = :newMaterial.Id
        ];
        System.assertNotEquals(null, insertedMRP.Id, 'New MRP should have valid Id');
        System.assertEquals(555, insertedMRP.Quantity_to_Buy__c, 'New MRP should have correct quantity');
    }    
}
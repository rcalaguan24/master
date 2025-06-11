@IsTest
public class MaterialDataServiceTest {
    
    @TestSetup
    static void setupTestData() {
        List<Material__c> testMaterials = new List<Material__c>();
        
        for (Integer i = 1; i <= 5; i++) {
            testMaterials.add(new Material__c(
                Name = 'Test Material ' + i,
                Stock_Quantity__c = 100 + i,
                Blocked_Stock_Quantity__c = 10 + i
            ));
        }
        
        insert testMaterials;
    }
    
    @IsTest
    static void testGetMaterialsById_ValidIds() {
        List<Material__c> allMaterials = [SELECT Id FROM Material__c LIMIT 3];
        Set<Id> materialIds = new Map<Id, Material__c>(allMaterials).keySet();
        
        Test.startTest();
        Map<Id, Material__c> result = MaterialDataService.getMaterialsById(materialIds);
        Test.stopTest();
        
        System.assertEquals(3, result.size(), 'Should return 3 materials');
        
        for (Id materialId : materialIds) {
            System.assert(result.containsKey(materialId), 'Result should contain all requested material IDs');
            Material__c material = result.get(materialId);
            System.assertNotEquals(null, material.Name, 'Material Name should not be null');
            System.assertNotEquals(null, material.Stock_Quantity__c, 'Stock Quantity should not be null');
            System.assertNotEquals(null, material.Blocked_Stock_Quantity__c, 'Blocked Stock Quantity should not be null');
        }
    }
    
    @IsTest
    static void testGetMaterialsById_EmptySet() {
        Set<Id> emptyIds = new Set<Id>();
        
        Test.startTest();
        Map<Id, Material__c> result = MaterialDataService.getMaterialsById(emptyIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for empty input');
    }
    
    @IsTest
    static void testGetMaterialsById_NonExistentIds() {
        Set<Id> fakeIds = new Set<Id>();
        String fakeId = '001000000000000AAA'; 
        fakeIds.add(fakeId);
        
        Test.startTest();
        Map<Id, Material__c> result = MaterialDataService.getMaterialsById(fakeIds);
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty map for non-existent IDs');
    }
    
    @IsTest
    static void testUpdateMaterials_ValidList() {
        List<Material__c> materialsToUpdate = [
            SELECT Id, Name, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            LIMIT 3
        ];
        
        for (Material__c material : materialsToUpdate) {
            material.Stock_Quantity__c = 200;
            material.Blocked_Stock_Quantity__c = 20;
        }
        
        Test.startTest();
        MaterialDataService.updateMaterials(materialsToUpdate);
        Test.stopTest();
        
        List<Material__c> updatedMaterials = [
            SELECT Id, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            WHERE Id IN :materialsToUpdate
        ];
        
        for (Material__c material : updatedMaterials) {
            System.assertEquals(200, material.Stock_Quantity__c, 'Stock quantity should be updated to 200');
            System.assertEquals(20, material.Blocked_Stock_Quantity__c, 'Blocked stock quantity should be updated to 20');
        }
    }
    
    @IsTest
    static void testUpdateMaterials_EmptyList() {
        List<Material__c> emptyList = new List<Material__c>();
        
        Test.startTest();
        MaterialDataService.updateMaterials(emptyList);
        Test.stopTest();

        System.assert(true, 'Method should handle empty list without throwing exception');
    }
    
    @IsTest
    static void testUpdateMaterials_BulkOperation() {
        List<Material__c> allMaterials = [
            SELECT Id, Name, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c
        ];
        
        for (Material__c material : allMaterials) {
            material.Stock_Quantity__c = 500;
        }
        
        Test.startTest();
        MaterialDataService.updateMaterials(allMaterials);
        Test.stopTest();
        List<Material__c> updatedMaterials = [
            SELECT Id, Stock_Quantity__c 
            FROM Material__c
        ];
        
        System.assertEquals(5, updatedMaterials.size(), 'All 5 materials should be retrieved');
        
        for (Material__c material : updatedMaterials) {
            System.assertEquals(500, material.Stock_Quantity__c, 'All materials should have stock quantity of 500');
        }
    }
    
    @IsTest
    static void testGetAllMaterials_Success() {
        Test.startTest();
        List<Material__c> result = MaterialDataService.getAllMaterials();
        Test.stopTest();
        
        System.assertEquals(5, result.size(), 'Should return all 5 test materials');
        
        for (Material__c material : result) {
            System.assertNotEquals(null, material.Id, 'Material ID should not be null');
            System.assertNotEquals(null, material.Name, 'Material Name should not be null');
            System.assertNotEquals(null, material.Stock_Quantity__c, 'Stock Quantity should not be null');
            System.assertNotEquals(null, material.Blocked_Stock_Quantity__c, 'Blocked Stock Quantity should not be null');
            
            System.assert(material.Name.startsWith('Test Material'), 'Should be a test material');
        }
    }
    
    @IsTest
    static void testGetAllMaterials_NoData() {
        delete [SELECT Id FROM Material__c];
        
        Test.startTest();
        List<Material__c> result = MaterialDataService.getAllMaterials();
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list when no materials exist');
    }
    
    @IsTest
    static void testSystemModeExecution() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            List<Material__c> allMaterials = MaterialDataService.getAllMaterials();
            
            if (!allMaterials.isEmpty()) {
                Set<Id> materialIds = new Set<Id>{allMaterials[0].Id};
                Map<Id, Material__c> materialMap = MaterialDataService.getMaterialsById(materialIds);
                System.assertEquals(1, materialMap.size(), 'Should retrieve material in system mode');
            }
            
            Test.stopTest();
        }
    }
}
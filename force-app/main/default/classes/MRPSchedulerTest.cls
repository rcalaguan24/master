@isTest
public with sharing class MRPSchedulerTest {
    @TestSetup
    static void setupTestData() {
        
        List<Material__c> testMaterials = new List<Material__c>();
        
        testMaterials.add(new Material__c(
            Name = 'Scheduler Test Material 1',
            Stock_Quantity__c = 30,
            Blocked_Stock_Quantity__c = 80
        ));
        
        testMaterials.add(new Material__c(
            Name = 'Scheduler Test Material 2',
            Stock_Quantity__c = 60,
            Blocked_Stock_Quantity__c = 100
        ));
        
        insert testMaterials;
    }

    @isTest
    static void testSchedulerExecuteSuccess() {
        
        MRPScheduler scheduler = new MRPScheduler();
        
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();
        
        
        List<Material_Requirements_Planning__c> createdMRPs = [
            SELECT Id, Material__c, Quantity_to_Buy__c, Status__c
            FROM Material_Requirements_Planning__c
            WHERE Status__c = 'Open'
        ];
        
        System.assertEquals(2, createdMRPs.size(), 'Scheduler should have created MRP records');
        
        
        for (Material_Requirements_Planning__c mrp : createdMRPs) {
            System.assertEquals('Open', mrp.Status__c, 'MRP status should be Open');
            System.assert(mrp.Quantity_to_Buy__c > 0, 'Quantity to buy should be positive');
        }
    }
}
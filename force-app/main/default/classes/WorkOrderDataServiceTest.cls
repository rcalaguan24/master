@isTest
public class WorkOrderDataServiceTest {
    
    @TestSetup
    static void setupData() {
        Product__c testProduct = new Product__c(
            Name = 'Test Product'
        );
        insert testProduct;
        
        List<Work_Order__c> workOrders = new List<Work_Order__c>();
        for(Integer i = 0; i < 5; i++) {
            workOrders.add(new Work_Order__c(
                Producttttt__c = testProduct.Id,
                Quantity__c = 10,
                Status__c = 'Not Started'
            ));
        }
        insert workOrders;
    }
    
    @isTest
    static void testUpdateWorkOrderStatus() {
        List<Work_Order__c> workOrders = [SELECT Id, Status__c FROM Work_Order__c];

        for(Work_Order__c wo : workOrders) {
            wo.Status__c = 'In Progress';
        }
        
        Test.startTest();
        WorkOrderDataService.updateWorkOrderStatus(workOrders);
        Test.stopTest();
        
        List<Work_Order__c> updatedWorkOrders = [SELECT Id, Status__c FROM Work_Order__c];
        for(Work_Order__c wo : updatedWorkOrders) {
            System.assertEquals('In Progress', wo.Status__c, 'Status should be updated to In Progress');
        }
    }
}
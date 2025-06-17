@isTest
public class WorkOrderOperationTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        Product__c testProduct = new Product__c(
            Name = 'Test Product'
        );
        insert testProduct;
        
        Material__c testMaterial = new Material__c(
            Name = 'Test Material'
        );
        insert testMaterial;
        
        
        Product_Material__c productMaterial = new Product_Material__c(
            Product__c = testProduct.Id,
            Material__c = testMaterial.Id,
            Quantity__c = 5
        );
        insert productMaterial;

        Work_Order__c workOrder = new Work_Order__c(
            Status__c = 'In Progress',
            Producttttt__c = testProduct.Id,
            Quantity__c = 10
        );
        insert workOrder;
    }
    
    @isTest
    static void testBeforeInsert() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        Test.startTest();
        
        
        List<Work_Order_Operation__c> operations = new List<Work_Order_Operation__c>();
        for(Integer i = 0; i < 3; i++) {
            operations.add(new Work_Order_Operation__c(
                Name = 'Test Operation ' + i,
                Work_Order__c = workOrder.Id
            ));
        }
        
        insert operations;
        
        Test.stopTest();
        
        
        List<Work_Order_Operation__c> insertedOperations = [
            SELECT Id, Status__c, Actual_Start_Time__c, Actual_End_Time__c 
            FROM Work_Order_Operation__c
        ];
        
        for(Work_Order_Operation__c operation : insertedOperations) {
            System.assertEquals('Not Started', operation.Status__c);
            System.assertEquals(null, operation.Actual_Start_Time__c);
            System.assertEquals(null, operation.Actual_End_Time__c);
        }
    }
    
    @isTest
    static void testBeforeUpdateStartOperation() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        
        Work_Order_Operation__c operation = new Work_Order_Operation__c(
            Name = 'Test Operation',
            Work_Order__c = workOrder.Id
        );
        insert operation;
        
        Test.startTest();
        
        
        operation.Status__c = 'In Progress';
        update operation;
        
        Test.stopTest();
        
        
        Work_Order_Operation__c updatedOperation = [
            SELECT Id, Status__c, Actual_Start_Time__c 
            FROM Work_Order_Operation__c 
            WHERE Id = :operation.Id
        ];
        
        System.assertEquals('In Progress', updatedOperation.Status__c);
        System.assertNotEquals(null, updatedOperation.Actual_Start_Time__c);
    }
    
    @isTest
    static void testBeforeUpdateCompleteOperation() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        
        Work_Order_Operation__c operation = new Work_Order_Operation__c(
            Name = 'Test Operation',
            Work_Order__c = workOrder.Id,
            Status__c = 'In Progress'
        );
        insert operation;
        
        Test.startTest();
        
        
        operation.Status__c = 'Completed';
        update operation;
        
        Test.stopTest();
        
        
        Work_Order_Operation__c updatedOperation = [
            SELECT Id, Status__c, Actual_End_Time__c 
            FROM Work_Order_Operation__c 
            WHERE Id = :operation.Id
        ];
        
        System.assertEquals('Completed', updatedOperation.Status__c);
        System.assertNotEquals(null, updatedOperation.Actual_End_Time__c);
    }
    
    @isTest
    static void testAfterUpdateCompleteAllOperations() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        
        List<Work_Order_Operation__c> operations = new List<Work_Order_Operation__c>();
        for(Integer i = 0; i < 3; i++) {
            operations.add(new Work_Order_Operation__c(
                Name = 'Test Operation ' + i,
                Work_Order__c = workOrder.Id,
                Status__c = 'In Progress'
            ));
        }
        insert operations;
        
        Test.startTest();
        
        
        for(Work_Order_Operation__c operation : operations) {
            operation.Status__c = 'Completed';
        }
        update operations;
        
        Test.stopTest();
        
        
        Work_Order__c updatedWorkOrder = [
            SELECT Id, Status__c 
            FROM Work_Order__c 
            WHERE Id = :workOrder.Id
        ];
        
        System.assertEquals('Completed', updatedWorkOrder.Status__c);
    }
    
    @isTest
    static void testDataServiceGetRelatedOperations() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        
        List<Work_Order_Operation__c> operations = new List<Work_Order_Operation__c>();
        for(Integer i = 0; i < 2; i++) {
            operations.add(new Work_Order_Operation__c(
                Name = 'Test Operation ' + i,
                Work_Order__c = workOrder.Id,
                Status__c = 'Not Started'
            ));
        }
        insert operations;
        
        Test.startTest();
        
        
        Set<Id> workOrderIds = new Set<Id>{workOrder.Id};
        Map<Id, List<Work_Order_Operation__c>> result = 
            WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        
        Test.stopTest();
        
        
        System.assert(result.containsKey(workOrder.Id));
        System.assertEquals(2, result.get(workOrder.Id).size());
    }

     @IsTest
    static void testTriggerHandlerEmptyMethods() {
        WorkOrderOperationTriggerHandler handler = new WorkOrderOperationTriggerHandler();
        
        Test.startTest();
        handler.afterInsert(new List<SObject>());
        handler.beforeDelete(new List<SObject>());
        handler.afterDelete(new List<SObject>());
        handler.afterUndelete(new List<SObject>());
        Test.stopTest();
    }
}
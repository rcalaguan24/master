@isTest
public class WorkOrderOperationServiceTest {
    
    @TestSetup
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

        List<Work_Order__c> workOrders = new List<Work_Order__c>();
        for(Integer i = 0; i < 3; i++) {
            workOrders.add(new Work_Order__c(
                Status__c = '',
                Producttttt__c = testProduct.Id,
                Quantity__c = 10 + i
            ));
        }
        insert workOrders;
        
        
        List<Work_Order_Operation__c> operations = new List<Work_Order_Operation__c>();
        for(Work_Order__c wo : workOrders) {
            operations.add(new Work_Order_Operation__c(
                Name = 'Operation 1 for ' + wo.Name,
                Work_Order__c = wo.Id,
                Status__c = 'Not Started'
            ));
            operations.add(new Work_Order_Operation__c(
                Name = 'Operation 2 for ' + wo.Name,
                Work_Order__c = wo.Id,
                Status__c = 'Not Started'
            ));
        }
        insert operations;
    }
    
    @isTest
    static void testHandleBeforeInsert() {
        
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        
        List<Work_Order_Operation__c> newOperations = new List<Work_Order_Operation__c>();
        newOperations.add(new Work_Order_Operation__c(
            Work_Order__c = workOrder.Id,
            Status__c = 'In Progress', 
            Actual_Start_Time__c = System.now(), 
            Actual_End_Time__c = System.now() 
        ));
        newOperations.add(new Work_Order_Operation__c(
            Work_Order__c = workOrder.Id
        ));
        
        Test.startTest();
        WorkOrderOperationService.handleBeforeInsert(newOperations);
        Test.stopTest();
        
        
        for(Work_Order_Operation__c operation : newOperations) {
            System.assertEquals('Not Started', operation.Status__c, 'Status should be set to Not Started');
            System.assertEquals(null, operation.Actual_Start_Time__c, 'Actual Start Time should be null');
            System.assertEquals(null, operation.Actual_End_Time__c, 'Actual End Time should be null');
        }
    }
    
    
    
    @isTest
    static void testHandleBeforeUpdateStatusChange() {
        
        List<Work_Order_Operation__c> operations = [SELECT Id, Status__c, Actual_Start_Time__c, Actual_End_Time__c FROM Work_Order_Operation__c LIMIT 2];
        
        Map<Id, Work_Order_Operation__c> oldMap = new Map<Id, Work_Order_Operation__c>();
        Map<Id, Work_Order_Operation__c> newMap = new Map<Id, Work_Order_Operation__c>();
        
        
        for(Work_Order_Operation__c op : operations) {
            oldMap.put(op.Id, op.clone(true, true, true, true));
        }
        
        
        Work_Order_Operation__c op1 = operations[0].clone(true, true, true, true);
        op1.Status__c = 'In Progress';
        newMap.put(op1.Id, op1);
        
        Work_Order_Operation__c op2 = operations[1].clone(true, true, true, true);
        op2.Status__c = 'Completed';
        newMap.put(op2.Id, op2);
        
        Test.startTest();
        WorkOrderOperationService.handleBeforeUpdate(oldMap, newMap);
        Test.stopTest();
        
        
        System.assertNotEquals(null, newMap.get(op1.Id).Actual_Start_Time__c, 'Actual Start Time should be set for In Progress status');
        
        
        System.assertNotEquals(null, newMap.get(op2.Id).Actual_End_Time__c, 'Actual End Time should be set for Completed status');
    }
    
    
    @isTest
    static void testHandleAfterUpdateWorkOrderCompletion() {
        
        Work_Order__c workOrder = [SELECT Id, Status__c FROM Work_Order__c LIMIT 1];
        List<Work_Order_Operation__c> operations = [SELECT Id, Status__c, Work_Order__c FROM Work_Order_Operation__c WHERE Work_Order__c = :workOrder.Id];
        
        Map<Id, Work_Order_Operation__c> oldMap = new Map<Id, Work_Order_Operation__c>();
        Map<Id, Work_Order_Operation__c> newMap = new Map<Id, Work_Order_Operation__c>();
        
        
        for(Work_Order_Operation__c op : operations) {
            oldMap.put(op.Id, op.clone(true, true, true, true));
        }
        
        
        for(Work_Order_Operation__c op : operations) {
            Work_Order_Operation__c newOp = op.clone(true, true, true, true);
            newOp.Status__c = 'Completed';
            newMap.put(op.Id, newOp);
        }
        
        Test.startTest();
        WorkOrderOperationService.handleAfterUpdate(oldMap, newMap);
        Test.stopTest();
        
        
        Work_Order__c updatedWorkOrder = [SELECT Id, Status__c FROM Work_Order__c WHERE Id = :workOrder.Id];
        System.assertEquals('Not Started', updatedWorkOrder.Status__c, 'Status should be Not Started');
    }
    
    
    @isTest
    static void testGetRelatedWorkOrderOperations() {
        
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c LIMIT 2];
        Set<Id> workOrderIds = new Set<Id>();
        for(Work_Order__c wo : workOrders) {
            workOrderIds.add(wo.Id);
        }
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        Test.stopTest();
        
        
        System.assertEquals(workOrders.size(), result.size(), 'Should return operations for all work orders');
        for(Id workOrderId : workOrderIds) {
            System.assert(result.containsKey(workOrderId), 'Should contain operations for work order: ' + workOrderId);
            System.assertEquals(2, result.get(workOrderId).size(), 'Should return 2 operations per work order');
        }
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperationsEmptySet() {
        Set<Id> emptySet = new Set<Id>();
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(emptySet);
        Test.stopTest();
        
        
        System.assert(result.isEmpty(), 'Should return empty map for empty input');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperationsNullSet() {
        Set<Id> nullSet = null;
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(nullSet);
        Test.stopTest();
        
        
        System.assert(result.isEmpty(), 'Should return empty map for null input');
    }
    
    
}
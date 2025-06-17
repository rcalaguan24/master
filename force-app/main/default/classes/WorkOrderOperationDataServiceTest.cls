@isTest
public class WorkOrderOperationDataServiceTest {
    
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
        List<Work_Order__c> workOrders = new List<Work_Order__c>();
        for(Integer i = 1; i <= 3; i++) {
            workOrders.add(new Work_Order__c(
                Status__c = 'In Progress',
                Producttttt__c = testProduct.Id,
                Quantity__c = 10 + i
            ));
        }
        insert workOrders;
        
        
        List<Work_Order_Operation__c> operations = new List<Work_Order_Operation__c>();
        
        
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 1-1',
            Work_Order__c = workOrders[0].Id,
            Status__c = 'Completed'
        ));
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 1-2',
            Work_Order__c = workOrders[0].Id,
            Status__c = 'In Progress'
        ));
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 1-3',
            Work_Order__c = workOrders[0].Id,
            Status__c = 'Not Started'
        ));
        
        
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 2-1',
            Work_Order__c = workOrders[1].Id,
            Status__c = 'Completed'
        ));
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 2-2',
            Work_Order__c = workOrders[1].Id,
            Status__c = 'Completed'
        ));
        
        
        operations.add(new Work_Order_Operation__c(
            Name = 'Operation 3-1',
            Work_Order__c = workOrders[2].Id,
            Status__c = 'Cancelled'
        ));
        
        insert operations;
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithValidWorkOrderIds() {
        
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c ORDER BY Name];
        Set<Id> workOrderIds = new Set<Id>{workOrders[0].Id, workOrders[1].Id};
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        Test.stopTest();
        
        
        System.assertEquals(2, result.size(), 'Should return operations for 2 work orders');
        System.assert(result.containsKey(workOrders[0].Id), 'Should contain first work order');
        System.assert(result.containsKey(workOrders[1].Id), 'Should contain second work order');
        
        
        List<Work_Order_Operation__c> workOrder1Operations = result.get(workOrders[0].Id);
        System.assertEquals(3, workOrder1Operations.size(), 'Work Order 1 should have 3 operations');
        
        
        for(Work_Order_Operation__c operation : workOrder1Operations) {
            System.assertEquals(workOrders[0].Id, operation.Work_Order__c, 'Operation should belong to correct work order');
            System.assertNotEquals(null, operation.Status__c, 'Operation status should not be null');
        }
        
        
        List<Work_Order_Operation__c> workOrder2Operations = result.get(workOrders[1].Id);
        System.assertEquals(2, workOrder2Operations.size(), 'Work Order 2 should have 2 operations');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithSingleWorkOrderId() {
        
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c ORDER BY Name];
        Set<Id> workOrderIds = new Set<Id>{workOrders[2].Id}; 
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        Test.stopTest();
        
        
        System.assertEquals(1, result.size(), 'Should return operations for 1 work order');
        System.assert(result.containsKey(workOrders[2].Id), 'Should contain the requested work order');
        
        List<Work_Order_Operation__c> operations = result.get(workOrders[2].Id);
        System.assertEquals(1, operations.size(), 'Should have 1 operation');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithEmptySet() {
        Set<Id> emptyWorkOrderIds = new Set<Id>();
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(emptyWorkOrderIds);
        Test.stopTest();
        
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result should be empty map');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithNullSet() {
        Set<Id> nullWorkOrderIds = null;
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(nullWorkOrderIds);
        Test.stopTest();
        
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result should be empty map');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithNonExistentWorkOrderIds() {
        
        Set<Id> nonExistentIds = new Set<Id>();
        
        
        String fakeId1 = 'a00000000000001'; 
        String fakeId2 = 'a00000000000002';
        
        
        List<Work_Order__c> tempWorkOrders = new List<Work_Order__c>();
        tempWorkOrders.add(new Work_Order__c(Status__c = 'Not Started'));
        tempWorkOrders.add(new Work_Order__c(Status__c = 'Not Started'));
        insert tempWorkOrders;
        
        for(Work_Order__c wo : tempWorkOrders) {
            nonExistentIds.add(wo.Id);
        }
        
        delete tempWorkOrders;
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(nonExistentIds);
        Test.stopTest();
        
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result should be empty for non-existent work order IDs');
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_WithAllWorkOrderIds() {
        
        List<Work_Order__c> allWorkOrders = [SELECT Id FROM Work_Order__c];
        Set<Id> allWorkOrderIds = new Set<Id>();
        for(Work_Order__c wo : allWorkOrders) {
            allWorkOrderIds.add(wo.Id);
        }
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(allWorkOrderIds);
        Test.stopTest();
        
        
        System.assertEquals(3, result.size(), 'Should return operations for all 3 work orders');
        
        
        Integer totalOperations = 0;
        for(List<Work_Order_Operation__c> operations : result.values()) {
            totalOperations += operations.size();
        }
        System.assertEquals(6, totalOperations, 'Should return all 6 operations total');
        
        
        for(Id workOrderId : allWorkOrderIds) {
            System.assert(result.containsKey(workOrderId), 'Should contain all work order IDs');
            System.assert(!result.get(workOrderId).isEmpty(), 'Each work order should have at least one operation');
        }
    }
    
    @isTest
    static void testGetRelatedWorkOrderOperations_VerifyFieldsReturned() {
        
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c LIMIT 1];
        Set<Id> workOrderIds = new Set<Id>{workOrders[0].Id};
        
        Test.startTest();
        Map<Id, List<Work_Order_Operation__c>> result = WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        Test.stopTest();
        
        
        List<Work_Order_Operation__c> operations = result.get(workOrders[0].Id);
        System.assert(!operations.isEmpty(), 'Should have operations');
        
        Work_Order_Operation__c firstOperation = operations[0];
        System.assertNotEquals(null, firstOperation.Id, 'Id field should be populated');
        System.assertNotEquals(null, firstOperation.Work_Order__c, 'Work_Order__c field should be populated');
        System.assertNotEquals(null, firstOperation.Status__c, 'Status__c field should be populated');
    }
}
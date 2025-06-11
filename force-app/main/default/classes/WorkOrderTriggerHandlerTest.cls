@isTest
public class WorkOrderTriggerHandlerTest {
    
    @TestSetup
    static void setupData() {
        
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
    }
    
    @isTest
    static void testBeforeInsert() {
        Product__c testProduct = [SELECT Id FROM Product__c LIMIT 1];
        
        Test.startTest();
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 10
        );
        insert workOrder;
        Test.stopTest();
        
        
        Work_Order__c insertedWorkOrder = [SELECT Id, Status__c FROM Work_Order__c WHERE Id = :workOrder.Id];
        System.assertEquals('Not Started', insertedWorkOrder.Status__c, 'Status should be set to Not Started');
    }
    
    @isTest
    static void testAfterInsert() {
        Product__c testProduct = [SELECT Id FROM Product__c LIMIT 1];
        
        Test.startTest();
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 10
        );
        insert workOrder;
        Test.stopTest();
        
        
        List<Work_Order_Material__c> createdMaterials = [
            SELECT Id, Work_Order__c, Material__c, Required_Quantity__c, Name 
            FROM Work_Order_Material__c 
            WHERE Work_Order__c = :workOrder.Id
        ];
        
        System.assertEquals(1, createdMaterials.size(), 'One Work Order Material should be created');
        System.assertEquals(50, createdMaterials[0].Required_Quantity__c, 'Required quantity should be 5 * 10 = 50');
    } 

    @IsTest
    static void testTriggerHandlerEmptyMethods() {
        WorkOrderTriggerHandler handler = new WorkOrderTriggerHandler();
        
        Test.startTest();
        handler.beforeInsert(new List<SObject>());
        handler.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.beforeDelete(new List<SObject>());
        handler.afterDelete(new List<SObject>());
        handler.afterUndelete(new List<SObject>());
        Test.stopTest();
    }
}
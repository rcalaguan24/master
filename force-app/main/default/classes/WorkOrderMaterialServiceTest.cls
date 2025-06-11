@isTest
public class WorkOrderMaterialServiceTest {
    @TestSetup
    static void setupTestData() {
        
        List<Material__c> materials = new List<Material__c>();
        materials.add(new Material__c(
            Name = 'Test Material 1',
            Blocked_Stock_Quantity__c = 10.00
        ));
        materials.add(new Material__c(
            Name = 'Test Material 2',
            Blocked_Stock_Quantity__c = 5.00
        ));
        insert materials;

        Product__c testProduct = new Product__c(
            Name = 'Test Product 1'
        );
        insert testProduct;

        Product_Material__c productMaterial = new Product_Material__c(
            Product__c = testProduct.Id,
            Material__c = materials[0].Id,
            Quantity__c = 3
        );
        insert productMaterial;

        Work_Order__c testWorkOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 1
        );
        insert testWorkOrder;
    }
    
    @isTest
    static void testHandleAfterInsert() {
        
        List<Material__c> materials = [SELECT Id, Blocked_Stock_Quantity__c FROM Material__c];
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c];
        
        List<Work_Order_Material__c> workOrderMaterials = new List<Work_Order_Material__c>();
        workOrderMaterials.add(new Work_Order_Material__c(
            Material__c = materials[0].Id,
            Required_Quantity__c = 3.00,
            Work_Order__c = workOrders[0].Id
        ));
        workOrderMaterials.add(new Work_Order_Material__c(
            Material__c = materials[1].Id,
            Required_Quantity__c = 2.00,
            Work_Order__c = workOrders[0].Id
        ));
        
        Test.startTest();
        insert workOrderMaterials;
        Test.stopTest();
        
        List<Material__c> updatedMaterials = [SELECT Id, Blocked_Stock_Quantity__c FROM Material__c ORDER BY Name];
        System.assertEquals(16.00, updatedMaterials[0].Blocked_Stock_Quantity__c, 'Material 1 blocked quantity should be updated');
        System.assertEquals(7.00, updatedMaterials[1].Blocked_Stock_Quantity__c, 'Material 2 blocked quantity should be updated');
    }
}
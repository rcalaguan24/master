@isTest
public with sharing class WorkOrderMaterialDataServiceTest {
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
    static void testWorkOrderMaterialDataServiceInsert() {
        
        List<Material__c> materials = [SELECT Id FROM Material__c LIMIT 1];
        List<Work_Order__c> workOrders = [SELECT Id FROM Work_Order__c];
        
        
        List<Work_Order_Material__c> workOrderMaterials = new List<Work_Order_Material__c>();
        workOrderMaterials.add(new Work_Order_Material__c(
            Material__c = materials[0].Id,
            Required_Quantity__c = 3.00,
            Work_Order__c = workOrders[0].Id
        ));
        
        Test.startTest();
        WorkOrderMaterialDataService.insertWorkOrderMaterials(workOrderMaterials);
        Test.stopTest();
        
        
        List<Work_Order_Material__c> insertedRecords = [SELECT Id, Material__c, Required_Quantity__c FROM Work_Order_Material__c];
        System.assertEquals(2, insertedRecords.size(), 'Two Work Order Material should be inserted');
        System.assertEquals(materials[0].Id, insertedRecords[0].Material__c, 'Material should match');
        System.assertEquals(3.00, insertedRecords[0].Required_Quantity__c, 'Required quantity should match');
    }
}
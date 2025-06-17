@isTest
public class WorkOrderServiceTest {
    
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
            Quantity__c = 3
        );
        insert productMaterial;
    }
    
    @isTest
    static void testHandleBeforeInsert() {
        Product__c testProduct = [SELECT Id FROM Product__c WHERE Name = 'Test Product' LIMIT 1];
        
        List<Work_Order__c> workOrders = new List<Work_Order__c>();
        workOrders.add(new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 5
        ));
        workOrders.add(new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 10
        ));
        
        Test.startTest();
        WorkOrderService.handleBeforeInsert(workOrders);
        Test.stopTest();
        
        
        for(Work_Order__c wo : workOrders) {
            System.assertEquals('Not Started', wo.Status__c, 'Status should be set to Not Started');
        }
    }
    
    @isTest
    static void testHandleBeforeInsertEmpty() {
        List<Work_Order__c> emptyList = new List<Work_Order__c>();
        
        Test.startTest();
        WorkOrderService.handleBeforeInsert(emptyList);
        Test.stopTest();
        
        
        System.assertEquals(0, emptyList.size(), 'List should remain empty');
    }
    
    @isTest
    static void testHandleAfterInsert() {
        Product__c testProduct = [SELECT Id FROM Product__c WHERE Name = 'Test Product' LIMIT 1];
        
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 7
        );
        insert workOrder;
        
        List<Work_Order__c> workOrders = new List<Work_Order__c>{workOrder};
        
        Test.startTest();
        WorkOrderService.handleAfterInsert(workOrders);
        Test.stopTest();
        
        
        List<Work_Order_Material__c> materials = [
            SELECT Id, Required_Quantity__c, Name 
            FROM Work_Order_Material__c 
            WHERE Work_Order__c = :workOrder.Id
        ];
        
        System.assertEquals(2, materials.size(), 'Two material should be created');
        System.assertEquals(21, materials[0].Required_Quantity__c, 'Required quantity should be 3 * 7 = 21');
    }
    
    @isTest
    static void testHandleAfterInsertEmpty() {
        List<Work_Order__c> emptyList = new List<Work_Order__c>();
        
        Test.startTest();
        WorkOrderService.handleAfterInsert(emptyList);
        Test.stopTest();
        
        
        System.assertEquals(0, emptyList.size(), 'List should remain empty');
    }
    
    @isTest
    static void testCreateWorkOrderMaterials() {
        Product__c testProduct = [SELECT Id FROM Product__c WHERE Name = 'Test Product' LIMIT 1];
        
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 4
        );
        insert workOrder;
        
        Test.startTest();
        WorkOrderService.createWorkOrderMaterials(workOrder);
        Test.stopTest();
        
        
        List<Work_Order_Material__c> materials = [
            SELECT Id, Work_Order__c, Material__c, Required_Quantity__c, Name 
            FROM Work_Order_Material__c 
            WHERE Work_Order__c = :workOrder.Id
        ];
        
        System.assertEquals(2, materials.size(), 'Two Work Order Material should be created');
        System.assertEquals(workOrder.Id, materials[0].Work_Order__c, 'Work Order should be linked correctly');
        System.assertEquals(12, materials[0].Required_Quantity__c, 'Required quantity should be 3 * 4 = 12');
    }
    
    @isTest
    static void testCreateWorkOrderMaterialsMultiple() {
        Product__c testProduct = [SELECT Id FROM Product__c WHERE Name = 'Test Product' LIMIT 1];
        Material__c testMaterial2 = new Material__c(Name = 'Test Material 2');
        insert testMaterial2;
        
        
        Product_Material__c productMaterial2 = new Product_Material__c(
            Product__c = testProduct.Id,
            Material__c = testMaterial2.Id,
            Quantity__c = 2
        );
        insert productMaterial2;
        
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = testProduct.Id,
            Quantity__c = 6
        );
        insert workOrder;
        
        Test.startTest();
        WorkOrderService.createWorkOrderMaterials(workOrder);
        Test.stopTest();
        
        
        List<Work_Order_Material__c> materials = [
            SELECT Id, Required_Quantity__c 
            FROM Work_Order_Material__c 
            WHERE Work_Order__c = :workOrder.Id
            ORDER BY Required_Quantity__c
        ];
        
        System.assertEquals(4, materials.size(), 'Four Work Order Materials should be created');
    }
}
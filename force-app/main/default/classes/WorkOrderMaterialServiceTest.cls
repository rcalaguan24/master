@isTest
public class WorkOrderMaterialServiceTest {

    @TestSetup
    static void setupTestData() {
        List<Material__c> materials = TestDataFactory.createMaterials(2, 'Test Material ', 10, 5);
        TestDataFactory.insertMaterials(materials);

        Product__c product = TestDataFactory.createAndInsertProduct('Test Product 1');

        TestDataFactory.createAndInsertProductMaterial(product.Id, materials[0].Id, 3);

        TestDataFactory.createAndInsertWorkOrder(product.Id, 1);
    }

   	@isTest
   	static void testHandleAfterInsert() {
      List<Material__c> initialMaterials = [SELECT Id, Blocked_Stock_Quantity__c FROM Material__c ORDER BY Name];
      Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
    
      Decimal expected1 = initialMaterials[0].Blocked_Stock_Quantity__c + 3;
      Decimal expected2 = initialMaterials[1].Blocked_Stock_Quantity__c + 2;
    
      List<Work_Order_Material__c> womList = new List<Work_Order_Material__c>{
          new Work_Order_Material__c(
              Material__c = initialMaterials[0].Id,
              Required_Quantity__c = 3.00,
              Work_Order__c = workOrder.Id
          ),
          new Work_Order_Material__c(
              Material__c = initialMaterials[1].Id,
              Required_Quantity__c = 2.00,
              Work_Order__c = workOrder.Id
          )
      };
    
      Test.startTest();
      insert womList;
      Test.stopTest();
    
      List<Material__c> updatedMaterials = [SELECT Id, Blocked_Stock_Quantity__c FROM Material__c ORDER BY Name];
    
      System.assertEquals(expected1, updatedMaterials[0].Blocked_Stock_Quantity__c, 'Material 1 blocked quantity should be updated');
      System.assertEquals(expected2, updatedMaterials[1].Blocked_Stock_Quantity__c, 'Material 2 blocked quantity should be updated');
   	}

    @isTest
    static void testHandleBeforeUpdate_ExceedsStockQuantity() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c ORDER BY Name];
        Work_Order__c workOrder = [SELECT Id FROM Work_Order__c LIMIT 1];

        Work_Order_Material__c wom = new Work_Order_Material__c(
            Material__c = materials[0].Id,
            Required_Quantity__c = 1.00,
            Work_Order__c = workOrder.Id
        );
        insert wom;

        wom.Required_Quantity__c = materials[0].Stock_Quantity__c + 100;

        Test.startTest();
        try {
            update wom;
            System.assert(false, 'Expected error due to exceeding stock quantity.');
        } catch (DmlException ex) {
            System.assert(
                ex.getMessage().contains('Test Material'),
                'Error message should contain material name'
            );
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testTriggerHandlerEmptyMethods() {
        WorkOrderMaterialTriggerHandler handler = new WorkOrderMaterialTriggerHandler();
        Test.startTest();
            handler.beforeDelete(new List<SObject>());
            handler.afterDelete(new List<SObject>());
            handler.afterUndelete(new List<SObject>());
        	handler.afterUpdate(new Map<Id,SObject>(), new Map<Id,SObject>());
        Test.stopTest();
    }
}
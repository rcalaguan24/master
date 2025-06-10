@isTest
public class MaterialTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        List<Material__c> materials = new List<Material__c>();
        for (Integer i = 0; i < 2; i++) {
            materials.add(new Material__c(Name = 'Test Material ' + i, Stock_Quantity__c = 10));
        }
        insert materials;
    }

    @isTest
    static void testBeforeUpdate_ValidationFailsForNegativeStock() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        
        Test.startTest();
        for (Material__c mat : materials) {
            mat.Stock_Quantity__c = -5; // Invalid
        }
        try {
            update materials;
            System.assert(false, 'Expected DMLException for negative stock.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Stock Quantity cannot be negative'), 'Expected stock quantity validation error.');
        }
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdate_CreatesStockAdjustment() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        for (Material__c mat : materials) {
            mat.Stock_Quantity__c = mat.Stock_Quantity__c + 5;
        }

        Test.startTest();
        update materials;
        Test.stopTest();

        List<Stock_Adjustment__c> adjustments = [SELECT Id, Material__c, Adjustment_Quantity__c, IsCreatedFromMaterial__c FROM Stock_Adjustment__c];
        System.assertEquals(materials.size(), adjustments.size(), 'Expected one adjustment per material updated');
        
        for (Stock_Adjustment__c adj : adjustments) {
            System.assert(adj.IsCreatedFromMaterial__c, 'Adjustment should be marked as created from material');
        }
    }

    @isTest
    static void testAfterUpdate_DoesNotCreateAdjustmentWhenFlagIsTrue() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        for (Material__c mat : materials) {
            mat.Stock_Quantity__c += 2;
        }

        Test.startTest();
        MaterialService.isUpdateFromAdjustment = true; 
        update materials;
        Test.stopTest();

        List<Stock_Adjustment__c> adjustments = [SELECT Id FROM Stock_Adjustment__c];
        System.assertEquals(0, adjustments.size(), 'No adjustments should be created when isUpdateFromAdjustment is true');
    }
    
    @isTest
	static void testBeforeUpdate_NoChange_TriggersContinue() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c LIMIT 1];
        Material__c mat = materials[0];
        Decimal originalQty = mat.Stock_Quantity__c;
        
        // No change in stock quantity
        mat.Stock_Quantity__c = originalQty;
    
        Test.startTest();
        update mat; // Should trigger the 'continue;' line
        Test.stopTest();
    
        // Assert that no error occurred and record was updated
        Material__c updated = [SELECT Id, Stock_Quantity__c FROM Material__c WHERE Id = :mat.Id];
        System.assertEquals(originalQty, updated.Stock_Quantity__c);
	}

    // ----------------------
    // NEW TESTS TO COVER EMPTY OVERRIDES
    // ----------------------

    @IsTest
    static void testTriggerHandlerEmptyMethods() {
        MaterialTriggerHandler handler = new MaterialTriggerHandler();
        
        Test.startTest();
        handler.beforeInsert(new List<SObject>());
        handler.afterInsert(new List<SObject>());
        handler.beforeDelete(new List<SObject>());
        handler.afterDelete(new List<SObject>());
        handler.afterUndelete(new List<SObject>());
        Test.stopTest();
    }
}
@IsTest
public class MaterialTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {
        List<Material__c> mats = TestDataFactory.createMaterials(2, 'Test Material ', 10, 0);
        TestDataFactory.insertMaterials(mats);
    }

    @IsTest
    static void testBeforeUpdate_ValidationFailsForNegativeStock() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        for (Material__c m : materials) {
            m.Stock_Quantity__c = -50;
        }

        Test.startTest();
            try {
                update materials;
                System.assert(false, 'Expected DmlException for negative stock.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Stock Quantity cannot be negative'),
                    'Expected stock quantity validation error.');
            }
        Test.stopTest();
    }

    @IsTest
    static void testAfterUpdate_CreatesStockAdjustment() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        for (Material__c m : materials) {
            m.Stock_Quantity__c += 5;
        }

        Test.startTest();
            update materials;
        Test.stopTest();

        List<Stock_Adjustment__c> adjustments = [
            SELECT Id, Material__c, Adjustment_Quantity__c, IsCreatedFromMaterial__c
            FROM Stock_Adjustment__c
        ];
        System.assertEquals(materials.size(), adjustments.size(),
            'Expected one adjustment per material updated');
        for (Stock_Adjustment__c adj : adjustments) {
            System.assert(adj.IsCreatedFromMaterial__c,
                'Adjustment should be marked as created from material');
        }
    }

    @IsTest
    static void testAfterUpdate_DoesNotCreateAdjustmentWhenFlagTrue() {
        List<Material__c> materials = [SELECT Id, Stock_Quantity__c FROM Material__c];
        for (Material__c m : materials) {
            m.Stock_Quantity__c += 2;
        }

        Test.startTest();
            MaterialService.isUpdateFromAdjustment = true;
            update materials;
        Test.stopTest();

        Integer countAdj = [SELECT count() FROM Stock_Adjustment__c];
        System.assertEquals(0, countAdj,
            'No adjustments should be created when isUpdateFromAdjustment is true');
    }

    @IsTest
    static void testBeforeUpdate_NoChange_TriggersContinue() {
        Material__c m = [SELECT Id, Stock_Quantity__c FROM Material__c LIMIT 1];
        Decimal orig = m.Stock_Quantity__c;
        m.Stock_Quantity__c = orig;

        Test.startTest();
            update m;
        Test.stopTest();

        Material__c updated = [SELECT Stock_Quantity__c FROM Material__c WHERE Id = :m.Id];
        System.assertEquals(orig, updated.Stock_Quantity__c,
            'Record should update with no validation error when quantity unchanged');
    }
    
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
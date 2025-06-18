@IsTest
private class StockAdjustmentServiceTest {
    @TestSetup
    static void setupTestData() {
        List<Material__c> mats = TestDataFactory.createMaterials(1, 'SA Material ', 10, 0);
        TestDataFactory.insertMaterials(mats);
    }

    @IsTest
    static void testValidateStockAdjustments_NoError() {
        Material__c mat = [SELECT Id FROM Material__c LIMIT 1];
        Stock_Adjustment__c adj = TestDataFactory.newStockAdjustment(mat.Id, -5, false);

        Test.startTest();
            StockAdjustmentService.handleBeforeInsert(new List<Stock_Adjustment__c>{adj});
        Test.stopTest();
    }

    @IsTest
    static void testValidateStockAdjustments_WithError() {
        Material__c mat = [SELECT Id FROM Material__c LIMIT 1];
        Stock_Adjustment__c adj = TestDataFactory.newStockAdjustment(mat.Id, -500, false);

        Test.startTest();
            try {
                insert adj;
                System.assert(false, 'Expected insert to fail due to negative stock error.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Stock Quantity cannot be negative'),
                    'Expected stock quantity validation error.');
            }
        Test.stopTest();
    }

    @IsTest
    static void testHandleAfterInsert() {
        Material__c mat = [SELECT Id FROM Material__c LIMIT 1];
        List<Stock_Adjustment__c> adjustments = new List<Stock_Adjustment__c>{
            TestDataFactory.newStockAdjustment(mat.Id, 5, false),
            TestDataFactory.newStockAdjustment(mat.Id, 3, true)
        };
        TestDataFactory.insertStockAdjustments(adjustments);

        Test.startTest();
            StockAdjustmentService.handleAfterInsert(adjustments);
        Test.stopTest();

        List<Stock_Adjustment__c> updated = [SELECT Adjustment_Date__c, User__c FROM Stock_Adjustment__c WHERE Id IN :adjustments];
        for (Stock_Adjustment__c adj : updated) {
            System.assertNotEquals(null, adj.Adjustment_Date__c, 'Adjustment_Date__c should be set');
            System.assertEquals(UserInfo.getUserId(), adj.User__c, 'User__c should be current user');
        }
    }

    @IsTest
    static void testTriggerHandlerBeforeInsert() {
        Material__c mat = [SELECT Id FROM Material__c LIMIT 1];
        Stock_Adjustment__c adj = TestDataFactory.newStockAdjustment(mat.Id, 1, false);
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();

        Test.startTest();
            handler.beforeInsert(new List<SObject>{adj});
        Test.stopTest();
    }

    @IsTest
    static void testTriggerHandlerAfterInsert() {
        Material__c mat = [SELECT Id FROM Material__c LIMIT 1];
        Stock_Adjustment__c adj = TestDataFactory.newStockAdjustment(mat.Id, 1, false);
        TestDataFactory.insertStockAdjustments(new List<Stock_Adjustment__c>{adj});
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();

        Test.startTest();
            handler.afterInsert(new List<SObject>{adj});
        Test.stopTest();
    }

    @IsTest
    static void testUpdateMaterialQuantity() {
        Material__c mat = [SELECT Id, Stock_Quantity__c FROM Material__c LIMIT 1];
        List<Stock_Adjustment__c> adjustments = new List<Stock_Adjustment__c>{
            TestDataFactory.newStockAdjustment(mat.Id, 4, false),
            TestDataFactory.newStockAdjustment(mat.Id, -2, false)
        };

        Test.startTest();
            TestDataFactory.insertStockAdjustments(adjustments);
        Test.stopTest();

        Material__c result = [SELECT Stock_Quantity__c FROM Material__c WHERE Id = :mat.Id];
        System.assertEquals(mat.Stock_Quantity__c + 4 - 2, result.Stock_Quantity__c,
            'Stock should be correctly adjusted');
    }

    @IsTest
    static void testTriggerHandlerEmptyMethods() {
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();
        Test.startTest();
            handler.beforeUpdate(new Map<Id,SObject>(), new Map<Id,SObject>());
            handler.beforeDelete(new List<SObject>());
            handler.afterUpdate(new Map<Id,SObject>(), new Map<Id,SObject>());
            handler.afterDelete(new List<SObject>());
            handler.afterUndelete(new List<SObject>());
        Test.stopTest();
    }
    
    @IsTest
	static void testFlagResetAfterUpdateQuantity() {
    
    Material__c mat = [SELECT Id, Stock_Quantity__c FROM Material__c LIMIT 1];
    Decimal originalQuantity = mat.Stock_Quantity__c;
    
    List<Stock_Adjustment__c> adjustments = new List<Stock_Adjustment__c>{
        TestDataFactory.newStockAdjustment(mat.Id, 2, false),
        TestDataFactory.newStockAdjustment(mat.Id, 3, false)
    };

    MaterialService.isUpdateFromAdjustment = false;
    
    Test.startTest();
        StockAdjustmentDataService.insertStockAdjustments(adjustments);
        List<Stock_Adjustment__c> insertedAdjustments = [
            SELECT Id, Adjustment_Quantity__c 
            FROM Stock_Adjustment__c 
            WHERE Material__c = :mat.Id
        ];
        System.assertEquals(2, insertedAdjustments.size(), 'Should have 2 adjustments');
    Test.stopTest();

    Material__c updatedMat = [SELECT Stock_Quantity__c FROM Material__c WHERE Id = :mat.Id];
    System.assertEquals(
        originalQuantity + 5, // 2 + 3 = 5
        updatedMat.Stock_Quantity__c,
        'Stock should increase by sum of adjustment quantities'
    );
    
    System.assertEquals(false, MaterialService.isUpdateFromAdjustment,
        'isUpdateFromAdjustment flag should be reset after update');
}
}
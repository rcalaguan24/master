@IsTest
private class StockAdjustmentServiceTest {
    // Helper method to create a Material record
    private static Material__c createMaterial(Decimal stockQty) {
        Material__c mat = new Material__c(Name = 'Test Material', Stock_Quantity__c = stockQty);
        insert mat;
        return mat;
    }
    
    @IsTest
    static void testValidateStockAdjustments_NoError() {
        Material__c mat = createMaterial(10);
        Stock_Adjustment__c adj = new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = -5);
        
        Test.startTest();
        StockAdjustmentService.validateStockAdjustments(new List<Stock_Adjustment__c>{ adj });
        Test.stopTest();
    }
    
    @IsTest
    static void testValidateStockAdjustments_WithError() {
        Material__c mat = createMaterial(2);

        Stock_Adjustment__c adj = new Stock_Adjustment__c(
            Material__c = mat.Id,
            Adjustment_Quantity__c = -5
        );

        try {
            Test.startTest();
            insert adj;
            Test.stopTest();
            
            System.assert(false, 'Expected insert to fail due to negative stock error.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Adjustment would result in negative stock'), 
                'Error message should mention negative stock');
        }
    }
    
    @IsTest
    static void testHandleAfterInsert() {
        Material__c mat = createMaterial(10);
        List<Stock_Adjustment__c> newAdjustments = new List<Stock_Adjustment__c>{
            new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = 5, IsCreatedFromMaterial__c = false),
            new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = 3, IsCreatedFromMaterial__c = true)
        };
        insert newAdjustments;
        
        Test.startTest();
        StockAdjustmentService.handleAfterInsert(newAdjustments);
        Test.stopTest();
        
        List<Stock_Adjustment__c> updatedAdjustments = [SELECT Adjustment_Date__c, User__c FROM Stock_Adjustment__c WHERE Id IN :newAdjustments];
        for (Stock_Adjustment__c adj : updatedAdjustments) {
            System.assertNotEquals(null, adj.Adjustment_Date__c, 'Adjustment_Date__c should be set');
            System.assertEquals(UserInfo.getUserId(), adj.User__c, 'User__c should be current user');
        }
    }
    
    @IsTest
    static void testUpdateDoesNotChangeStock() {
        // Start material with 0 stock
        Material__c mat = createMaterial(0);

        Stock_Adjustment__c adj = new Stock_Adjustment__c(
            Material__c = mat.Id,
            Adjustment_Quantity__c = 5,
            IsCreatedFromMaterial__c = false
        );
        insert adj;  // Stock: 0 + 5 = 5

        adj.Adjustment_Quantity__c = 8;

        Test.startTest();
        update adj;  // No stock update expected here
        Test.stopTest();

        Material__c updatedMat = [SELECT Stock_Quantity__c FROM Material__c WHERE Id = :mat.Id];
        System.assertEquals(5, updatedMat.Stock_Quantity__c, 'Stock quantity should NOT change on update since no afterUpdate logic');
    }
    
    @IsTest
    static void testTriggerHandlerBeforeInsert() {
        Material__c mat = createMaterial(10);
        Stock_Adjustment__c adj = new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = 1);
        
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();
        
        Test.startTest();
        handler.beforeInsert(new List<SObject>{ adj });
        Test.stopTest();
    }
    
    @IsTest
    static void testTriggerHandlerAfterInsert() {
        Material__c mat = createMaterial(10);
        Stock_Adjustment__c adj = new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = 1, IsCreatedFromMaterial__c = false);
        insert adj;
        
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();
        
        Test.startTest();
        handler.afterInsert(new List<SObject>{ adj });
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateMaterialQuantity() {
        Material__c mat = createMaterial(5);
    
        List<Stock_Adjustment__c> adjustments = new List<Stock_Adjustment__c>{
            new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = 4, IsCreatedFromMaterial__c = false),
            new Stock_Adjustment__c(Material__c = mat.Id, Adjustment_Quantity__c = -2, IsCreatedFromMaterial__c = false)
        };
    
        Test.startTest();
        insert adjustments;  // Will call handleAfterInsert -> updateMaterialQuantity
        Test.stopTest();
    
        Material__c updatedMat = [SELECT Stock_Quantity__c FROM Material__c WHERE Id = :mat.Id];
        System.assertEquals(7, updatedMat.Stock_Quantity__c, 'Stock should be correctly adjusted (5 + 4 - 2 = 7)');
    }

    @IsTest
    static void testTriggerHandlerEmptyMethods() {
        StockAdjustmentTriggerHandler handler = new StockAdjustmentTriggerHandler();
        
        Test.startTest();
        handler.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.beforeDelete(new List<SObject>());
        handler.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.afterDelete(new List<SObject>());
        handler.afterUndelete(new List<SObject>());
        Test.stopTest();
    }
}
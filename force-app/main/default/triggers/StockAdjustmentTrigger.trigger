trigger StockAdjustmentTrigger on Stock_Adjustment__c (before insert, after insert) {
    new StockAdjustmentTriggerHandler().run();
}
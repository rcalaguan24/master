public class StockAdjustmentDataService {
    public static List<Stock_Adjustment__c> insertStockAdjustments(List<Stock_Adjustment__c> adjustments) {
        insert adjustments;
        return adjustments;
    }

    
    public static void updateStockAdjustments(List<Stock_Adjustment__c> adjustments) {
        if (!adjustments.isEmpty()) {
            update adjustments;
        }
    }
}
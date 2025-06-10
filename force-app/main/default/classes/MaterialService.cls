public class MaterialService {
    private static Boolean isProcessing = false;
    public static Boolean isUpdateFromAdjustment = false;
    
    public static Set<Id> materialOriginatedAdjustments = new Set<Id>();
    
    public static void validateBeforeUpdate(Map<Id, Material__c> oldMap, Map<Id, Material__c> newMap) {
        for (Id id : newMap.keySet()) {
            Material__c oldMat = oldMap.get(id);
            Material__c newMat = newMap.get(id);
        
        if (oldMat.Stock_Quantity__c == newMat.Stock_Quantity__c) {
            continue;
        }

        if (newMat.Stock_Quantity__c != null && newMat.Stock_Quantity__c < 0) {
            newMat.addError('Stock Quantity cannot be negative.');
        }
    }
}
    
    public static void handleAfterUpdate(Map<Id, Material__c> oldMap, Map<Id, Material__c> newMap) {
    
        if (isProcessing || isUpdateFromAdjustment) {
            return;
        }
        
        isProcessing = true;
        
        try {
            List<Stock_Adjustment__c> adjustmentsToInsert = new List<Stock_Adjustment__c>();
            
            for (Id id : newMap.keySet()) {
                Material__c oldMat = oldMap.get(id);
                Material__c newMat = newMap.get(id);
                if (oldMat.Stock_Quantity__c != newMat.Stock_Quantity__c) {
                    Stock_Adjustment__c adj = new Stock_Adjustment__c(
                        Material__c = newMat.Id,
                        Adjustment_Quantity__c = newMat.Stock_Quantity__c - oldMat.Stock_Quantity__c,
                        Adjustment_Date__c = System.now(),
                        IsCreatedFromMaterial__c = true,
                        User__c = UserInfo.getUserId()
                    );
                    adjustmentsToInsert.add(adj);
                }
            }
            if (!adjustmentsToInsert.isEmpty()) {
                List<Stock_Adjustment__c> insertedAdjustments = StockAdjustmentDataService.insertStockAdjustments(adjustmentsToInsert);
                for (Stock_Adjustment__c adj : insertedAdjustments) {
                    materialOriginatedAdjustments.add(adj.Id);
                }
            }
       } finally {
           isProcessing = false;
       }
    }
}
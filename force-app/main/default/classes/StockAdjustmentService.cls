public class StockAdjustmentService {
    private static Boolean isProcessing = false;
    
    public static void validateStockAdjustments(List<Stock_Adjustment__c> adjustments) {
        Set<Id> materialIds = new Set<Id>();
        
        for (Stock_Adjustment__c adj : adjustments) {
            if (adj.Material__c != null && adj.Adjustment_Quantity__c != null) {
                materialIds.add(adj.Material__c);
            }
        }
        
        if (materialIds.isEmpty()) {
            return;
        }
        
        Map<Id, Material__c> materialsMap = MaterialDataService.getMaterialsById(materialIds);
        
        for (Stock_Adjustment__c adj : adjustments) {
            if (adj.Material__c != null && adj.Adjustment_Quantity__c != null) {
                Material__c material = materialsMap.get(adj.Material__c);
                
                if (material != null) {
                    Decimal currentStock = material.Stock_Quantity__c != null ? material.Stock_Quantity__c : 0;
                    Decimal newStock = currentStock + adj.Adjustment_Quantity__c;
                    
                    if (newStock < 0) {
                        adj.addError('Adjustment would result in negative stock. Current: ' + 
                                   currentStock + ', Adjustment: ' + adj.Adjustment_Quantity__c);
                    }
                }
            }
        }
    }
    
    public static void handleAfterInsert(List<Stock_Adjustment__c> newList) {
        
        if (isProcessing) {
           return;
        }
        
        try {
            isProcessing = true;
            List<Stock_Adjustment__c> adjustmentsToUpdate = new List<Stock_Adjustment__c>();
            List<Stock_Adjustment__c> adjustmentsForMaterialUpdate = new List<Stock_Adjustment__c>();
            
            for (Stock_Adjustment__c adj : newList) {
                Stock_Adjustment__c updateAdj = new Stock_Adjustment__c(Id = adj.Id);
                updateAdj.Adjustment_Date__c = System.now();
                updateAdj.User__c = UserInfo.getUserId();
                adjustmentsToUpdate.add(updateAdj);
                

                if (adj.IsCreatedFromMaterial__c != true) {
                    adjustmentsForMaterialUpdate.add(adj);
                }
            }
            
            if (!adjustmentsToUpdate.isEmpty()) {
                StockAdjustmentDataService.updateStockAdjustments(adjustmentsToUpdate);
            }
            
            if (!adjustmentsForMaterialUpdate.isEmpty()) {
                updateMaterialQuantity(adjustmentsForMaterialUpdate);
            }
        } finally {
            isProcessing = false;
        }
    }
    
     
    private static void updateMaterialQuantity(List<Stock_Adjustment__c> adjustments) {
        Map<Id, Decimal> materialAdjustments = new Map<Id, Decimal>();
        
        for (Stock_Adjustment__c adj : adjustments) {
            if (adj.Material__c != null && adj.Adjustment_Quantity__c != null) {
                Decimal currentStockQnty = materialAdjustments.get(adj.Material__c);
                Decimal totalQuantity = (currentStockQnty != null ? currentStockQnty : 0) + adj.Adjustment_Quantity__c;
                materialAdjustments.put(adj.Material__c, totalQuantity);
            }
        }
        
        system.debug('materialAdjustments after ' + materialAdjustments);
        
        if (!materialAdjustments.isEmpty()) {
            Map<Id, Material__c> materials = MaterialDataService.getMaterialsById(materialAdjustments.keySet());
            
            MaterialService.isUpdateFromAdjustment = true;
            
            for (Material__c material : materials.values()) {
                material.Stock_Quantity__c = (material.Stock_Quantity__c != null ? material.Stock_Quantity__c : 0) + materialAdjustments.get(material.Id);
            }
            
            MaterialDataService.updateMaterials(materials.values());
            MaterialService.isUpdateFromAdjustment = false;
        }
    }
}
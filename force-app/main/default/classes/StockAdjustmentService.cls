public with sharing class StockAdjustmentService {
    
    public static void handleBeforeInsert(List<Stock_Adjustment__c> stockAdjustments) {
        
        if(stockAdjustments != null && !stockAdjustments.isEmpty()){
            Set<Id> materialIds = new Set<Id>();
            
            for (Stock_Adjustment__c adj : stockAdjustments) {
                if (adj.Material__c != null && adj.Adjustment_Quantity__c != null) {
                    materialIds.add(adj.Material__c);
                }
            }
            
            if (materialIds.isEmpty()) {
                return;
            }
            
            Map<Id, Material__c> materialsMap = MaterialDataService.getMaterialsById(materialIds);
            
            for (Stock_Adjustment__c adj : stockAdjustments) {
                Material__c material = materialsMap.get(adj.Material__c);
                if (material != null) {
                    Decimal currentStock = material.Stock_Quantity__c != null ? material.Stock_Quantity__c : 0;
                    Decimal newStock = currentStock + adj.Adjustment_Quantity__c;
                    
                    if (newStock < 0) {
                        adj.addError(MessageUtility.ERROR_NEGATIVE_STOCK_QUANTITY);
                        
                    }
                }
            }
        }
    }
    
    public static void handleAfterInsert(List<Stock_Adjustment__c> newStockAdjustmentRecords) {
        
        if(newStockAdjustmentRecords != null && !newStockAdjustmentRecords.isEmpty()){
            List<Stock_Adjustment__c> adjustmentsToUpdate = new List<Stock_Adjustment__c>();
            List<Stock_Adjustment__c> adjustmentsForMaterialUpdate = new List<Stock_Adjustment__c>();
            
            for (Stock_Adjustment__c adj : newStockAdjustmentRecords) {
                Stock_Adjustment__c updateAdj = new Stock_Adjustment__c();
                updateAdj.Id = adj.Id;
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
        }
    }
    
    
    private static void updateMaterialQuantity(List<Stock_Adjustment__c> stockAdjustments) {
        if(stockAdjustments != null && !stockAdjustments.isEmpty()){
            Map<Id, Decimal> materialAdjustments = new Map<Id, Decimal>();
            
            for (Stock_Adjustment__c adj : stockAdjustments) {
                if (adj.Material__c != null && adj.Adjustment_Quantity__c != null) {
                    Decimal currentStockQnty = materialAdjustments.get(adj.Material__c);
                    Decimal totalQuantity = (currentStockQnty != null ? currentStockQnty : 0) + adj.Adjustment_Quantity__c;
                    materialAdjustments.put(adj.Material__c, totalQuantity);
                }
            }
            
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
}
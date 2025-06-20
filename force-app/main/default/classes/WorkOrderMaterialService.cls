public with sharing class WorkOrderMaterialService {
    public static void handleafterInsert(List<Work_Order_Material__c> newWorkOrderMaterials) {
        if(!newWorkOrderMaterials.isEmpty()){
            Set<Id> materialIds = new Set<Id>();
            for(Work_Order_Material__c newWorkOrderMaterial : newWorkOrderMaterials){
                if(newWorkOrderMaterial.Material__c != null){
                    materialIds.add(newWorkOrderMaterial.Material__c);
                }
            }

            if(!materialIds.isEmpty()){
                Map<Id, Material__c> materials = MaterialDataService.getMaterialsById(materialIds);
                List<Material__c> materialList = new List<Material__c>();

                for(Work_Order_Material__c newWorkOrderMaterial : newWorkOrderMaterials){
                    Decimal blockedQuantity = materials.get(newWorkOrderMaterial.Material__c).Blocked_Stock_Quantity__c ?? 0.00;
                    materialList.add(
                        new Material__c(
                            Id = newWorkOrderMaterial.Material__c,
                            Blocked_Stock_Quantity__c = blockedQuantity + newWorkOrderMaterial.Required_Quantity__c
                        )
                    );
                }
                MaterialDataService.updateMaterials(materialList);
            }
        }
    }
    
    public static void handleBeforeUpdate(Map<Id, Work_Order_Material__c> oldWorkOrderMaterialsMap, Map<Id, Work_Order_Material__c> newWorkOrderMaterialsMap) {
        if (oldWorkOrderMaterialsMap != null || newWorkOrderMaterialsMap != null || !newWorkOrderMaterialsMap.isEmpty()){
            List<Work_Order_Material__c> womToValidate = new List<Work_Order_Material__c>();
            for (Id womId : newWorkOrderMaterialsMap.keySet()) {
                Work_Order_Material__c newWorkOrderMaterials = newWorkOrderMaterialsMap.get(womId);
                Work_Order_Material__c oldWorkOrderMaterials = oldWorkOrderMaterialsMap.get(womId);
                if (newWorkOrderMaterials.Material__c != oldWorkOrderMaterials.Material__c || newWorkOrderMaterials.Required_Quantity__c != oldWorkOrderMaterials.Required_Quantity__c) {
                    womToValidate.add(newWorkOrderMaterials);
                }
            }
            if (!womToValidate.isEmpty()) validateRequiredQuantity(womToValidate);
        }
    }
    
    public static void validateRequiredQuantity(List<Work_Order_Material__c> WorkOrderMaterials) {
        if(!WorkOrderMaterials.isEmpty()){
            Set<Id> materialIds = new Set<Id>();
            for (Work_Order_Material__c WorkOrderMaterial : WorkOrderMaterials) {
                if (WorkOrderMaterial.Material__c != null) {
                    materialIds.add(WorkOrderMaterial.Material__c);
                }
            }
            
            if (!materialIds.isEmpty()) {
            	Map<Id, Material__c> materialMap = MaterialDataService.getMaterialsById(materialIds);
        
                for (Work_Order_Material__c WorkOrderMaterial : WorkOrderMaterials) {
                    Material__c materialRecord = materialMap.get(WorkOrderMaterial.Material__c);
                    
                    if (materialRecord.Stock_Quantity__c == null || WorkOrderMaterial.Required_Quantity__c > materialRecord.Stock_Quantity__c) {
                    	WorkOrderMaterial.addError('"' + materialRecord.Name + MessageUtility.PRODUCT_MATERIAL_WARNING_SUFFIX);
                    }
        		}
           }
    	}
	}
}
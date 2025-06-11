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
}
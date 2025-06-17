public with sharing class MRPGenerator {
    public static void generateMRP(){
        List<Material_Requirements_Planning__c> existingMRP = MRPDataService.getAllOpenMRP();
        List<Material__c> allMaterials = MaterialDataService.getAllMaterials();
        List<Material_Requirements_Planning__c> newMRPs = new List<Material_Requirements_Planning__c>();
        List<Material_Requirements_Planning__c> updateMRPs = new List<Material_Requirements_Planning__c>();
        Map<Id, Decimal> materialToQuanitityToBuyMap = new Map<Id, Decimal>();
        Map<Id, Id> materialToMRPMap = new Map<Id, Id>();
        Set<Id> existingMRPMaterials = new Set<Id>();

        if (!existingMRP.isEmpty()){
            for (Material_Requirements_Planning__c mrp: existingMRP){
                if (mrp.Material__c != null) {
                    materialToQuanitityToBuyMap.put(mrp.Material__c, mrp.Quantity_to_Buy__c ?? 0);
                    materialToMRPMap.put(mrp.Material__c, mrp.Id);
                    existingMRPMaterials.add(mrp.Material__c);
                }
            }
        }

        if (!allMaterials.isEmpty()){
            for (Material__c material : allMaterials) {

                if (material.Blocked_Stock_Quantity__c == null || material.Stock_Quantity__c == null) {
                    continue; 
                }
                
                Decimal quantityToBuy = material.Blocked_Stock_Quantity__c - material.Stock_Quantity__c;
                
                if (!existingMRPMaterials.contains(material.Id) && material.Blocked_Stock_Quantity__c > material.Stock_Quantity__c) {
                    newMRPs.add(
                        new Material_Requirements_Planning__c(
                            Material__c = material.Id,
                            Quantity_to_Buy__c = quantityToBuy,
                            Status__c = 'Open'
                        )
                    );
                } else if (existingMRPMaterials.contains(material.Id) && material.Blocked_Stock_Quantity__c > material.Stock_Quantity__c) {
                    Decimal existingQuantity = materialToQuanitityToBuyMap.get(material.Id) ?? 0;
                    
                    if (existingQuantity != quantityToBuy) {
                        updateMRPs.add(
                            new Material_Requirements_Planning__c(
                                Id = materialToMRPMap.get(material.Id),
                                Quantity_to_Buy__c = quantityToBuy
                            )
                        );
                    }
                }
            }

            if(!newMRPs.isEmpty()){
                MRPDataService.upsertMRP(newMRPs);
                System.debug('Created ' + newMRPs.size() + ' new MRPs');
            }

            if(!updateMRPs.isEmpty()){
                MRPDataService.upsertMRP(updateMRPs);
                System.debug('Updated ' + updateMRPs.size() + ' MRPs');
            }
            
            if(newMRPs.isEmpty() && updateMRPs.isEmpty()){
                System.debug('No MRP records to create or update');
            }
        }
    }
}
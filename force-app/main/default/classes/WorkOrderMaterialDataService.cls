public with sharing class WorkOrderMaterialDataService {
    public static void insertWorkOrderMaterials(List<Work_Order_Material__c> workOrderMaterials) {
        if (!workOrderMaterials.isEmpty()) {
            insert workOrderMaterials;
        }
    }
}
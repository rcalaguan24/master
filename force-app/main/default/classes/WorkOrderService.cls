public with sharing class WorkOrderService {
    
    public static void handleBeforeInsert(List<Work_Order__c> newWorkOrders) {
        if(!newWorkOrders.isEmpty()) {
            for(Work_Order__c newWorkOrder : newWorkOrders){
                newWorkOrder.Status__c = 'Not Started';
            }
        }
    }

    public static void handleAfterInsert(List<Work_Order__c> newWorkOrders) {
        System.debug('After Insert');
        System.debug('newWorkOrders: ' + newWorkOrders);
        if(!newWorkOrders.isEmpty()) {
            for(Work_Order__c newWorkOrder : newWorkOrders){
                createWorkOrderMaterials(newWorkOrder);
            }
        }
    }

    public static void createWorkOrderMaterials(Work_Order__c workOrder) {
        List<Product_Material__c> productMaterials  = [SELECT Id, Name, Product__c, Material__c, Quantity__c FROM Product_Material__c WHERE Product__c = :workOrder.Producttttt__c];
        List<Work_Order_Material__c> workOrderMaterials = new List<Work_Order_Material__c>();
        for(Product_Material__c productMaterial : productMaterials) {
            workOrderMaterials.add(
                new Work_Order_Material__c(
                    Work_Order__c = workOrder.Id,
                    Material__c = productMaterial.Material__c,
                    Required_Quantity__c = productMaterial.Quantity__c * workOrder.Quantity__c,
                    Name = productMaterial.Name + ' ' + workOrder.Name
                )
            );
        }

        if(!workOrderMaterials.isEmpty()) {
            System.debug('Work Order materials to insert: ' + workOrderMaterials);
            insert workOrderMaterials;
            System.debug('Work Order materials inserted successfully');
        }
    }
}
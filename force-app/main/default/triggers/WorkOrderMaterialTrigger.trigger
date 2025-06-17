trigger WorkOrderMaterialTrigger on Work_Order_Material__c (before insert, after insert, before update) {
    new WorkOrderMaterialTriggerhandler().run();
}
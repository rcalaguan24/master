trigger WorkOrderMaterialTrigger on Work_Order_Material__c (before insert, after insert) {
    new WorkOrderMaterialTriggerhandler().run();
}
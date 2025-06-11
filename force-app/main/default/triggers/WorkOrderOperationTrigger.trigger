trigger WorkOrderOperationTrigger on Work_Order_Operation__c (before insert, before update, after update) {
    new WorkOrderOperationTriggerHandler().run();
}
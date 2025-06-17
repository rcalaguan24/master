trigger WorkOrderTrigger on Work_Order__c (before insert, after insert) {
    new WorkOrderTriggerhandler().run();
}
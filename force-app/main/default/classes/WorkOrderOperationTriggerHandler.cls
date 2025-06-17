public class WorkOrderOperationTriggerHandler extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {
        WorkOrderOperationService.handleBeforeInsert((List<Work_Order_Operation__c>)newList);
    }

    public override void afterInsert(List<SObject> newList) {}

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        WorkOrderOperationService.handleBeforeUpdate((Map<Id, Work_Order_Operation__c>) oldMap, (Map<Id, Work_Order_Operation__c>) newMap);
    }

    public override void beforeDelete(List<SObject> oldList) {}

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        WorkOrderOperationService.handleAfterUpdate((Map<Id, Work_Order_Operation__c>) oldMap, (Map<Id, Work_Order_Operation__c>) newMap);
    }

    public override void afterDelete(List<SObject> oldList) {}

    public override void afterUndelete(List<SObject> newList) {}
}
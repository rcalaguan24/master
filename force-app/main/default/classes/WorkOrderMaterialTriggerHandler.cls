public with sharing class WorkOrderMaterialTriggerHandler extends TriggerHandler{
    public override void beforeInsert(List<SObject> newList) {
    }
    public override void afterInsert(List<SObject> newList) {
        WorkOrderMaterialService.handleAfterInsert((List<Work_Order_Material__c>) newList);
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }
    public override void beforeDelete(List<SObject> oldList) {
    }
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }
    public override void afterDelete(List<SObject> oldList) {
    }
    public override void afterUndelete(List<SObject> newList) {
    }
}
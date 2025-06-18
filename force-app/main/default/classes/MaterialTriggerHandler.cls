public class MaterialTriggerHandler extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {}
    public override void afterInsert(List<SObject> newList) {}
    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        MaterialService.handleBeforeUpdate((Map<Id, Material__c>) oldMap, (Map<Id, Material__c>) newMap);
    }
    public override void beforeDelete(List<SObject> oldList) {
    }
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        MaterialService.handleAfterUpdate((Map<Id, Material__c>) oldMap, (Map<Id, Material__c>) newMap);
    }
    public override void afterDelete(List<SObject> oldList) {
    }
    public override void afterUndelete(List<SObject> newList) {
    }
}
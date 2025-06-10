public abstract class TriggerHandler {
    public abstract void beforeInsert(List<SObject> newList);
    public abstract void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap);
    public abstract void beforeDelete(List<SObject> oldList);
    public abstract void afterInsert(List<SObject> newList);
    public abstract void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap);
    public abstract void afterDelete(List<SObject> oldList);
    public abstract void afterUndelete(List<SObject> newList);
    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                beforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                beforeUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                beforeDelete(Trigger.old);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                afterInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                afterUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                afterDelete(Trigger.old);
            } else if (Trigger.isUndelete) {
                afterUndelete(Trigger.new);
            }
        }
    }
}
trigger MaterialTrigger on Material__c (before update, after update) {
    new MaterialTriggerHandler().run();
}
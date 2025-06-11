public with sharing class WorkOrderOperationDataService {
    public static Map<Id, List<Work_Order_Operation__c>> getRelatedWorkOrderOperations(Set<Id> workOrderIds) {
        Map<Id, List<Work_Order_Operation__c>> workOrderToOperationsMap = new Map<Id, List<Work_Order_Operation__c>>();
        
        if(workOrderIds != null && !workOrderIds.isEmpty()) {
            List<Work_Order_Operation__c> operations = [
                SELECT Id, Work_Order__c, Status__c 
                FROM Work_Order_Operation__c 
                WHERE Work_Order__c IN :workOrderIds
            ];
            
            for(Work_Order_Operation__c operation : operations) {
                if(!workOrderToOperationsMap.containsKey(operation.Work_Order__c)) {
                    workOrderToOperationsMap.put(operation.Work_Order__c, new List<Work_Order_Operation__c>());
                }
                workOrderToOperationsMap.get(operation.Work_Order__c).add(operation);
            }
        }
        
        return workOrderToOperationsMap;
    }    
}
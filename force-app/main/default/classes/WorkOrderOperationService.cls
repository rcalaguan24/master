public with sharing class WorkOrderOperationService {

    public static void handleBeforeInsert(List<Work_Order_Operation__c> newWorkOrderOperations) {
        if(!newWorkOrderOperations.isEmpty()) {
            for(Work_Order_Operation__c newWorkOrderOperation : newWorkOrderOperations){
                newWorkOrderOperation.Status__c = 'Not Started';
                newWorkOrderOperation.Actual_Start_Time__c = null;
                newWorkOrderOperation.Actual_End_Time__c = null;
            }
        }
    }

    public static void handleBeforeUpdate(Map<Id, Work_Order_Operation__c> oldWorkOrderOperations, Map<Id, Work_Order_Operation__c> newWorkOrderOperations){

        if(!newWorkOrderOperations.isEmpty() && newWorkOrderOperations != null){
            for(Id id : newWorkOrderOperations.keySet()){
                Work_Order_Operation__c newWorkOrderOperation = newWorkOrderOperations.get(id);
                Work_Order_Operation__c oldWorkOrderOperation = oldWorkOrderOperations.get(id);

                if(oldWorkOrderOperation.Status__c == 'Cancelled' || oldWorkOrderOperation.Status__c == 'Completed'){
                    newWorkOrderOperation.addError('This Work Order Operation is already completed');
                }

                if(newWorkOrderOperation.Status__c == 'In Progress' && oldWorkOrderOperation.Status__c =='Not Started'){
                    newWorkOrderOperation.Actual_Start_Time__c = System.now();
                }else if(newWorkOrderOperation.Status__c == 'Completed'){
                    newWorkOrderOperation.Actual_End_Time__c = System.now();
                }
            }
        }
    }

    public static void handleAfterUpdate(Map<Id, Work_Order_Operation__c> oldWorkOrderOperations, Map<Id, Work_Order_Operation__c> newWorkOrderOperations){

        if(newWorkOrderOperations != null && !newWorkOrderOperations.isEmpty()){
            Set<Id> workOrderIds = new Set<Id>();
            
            for(Id id : newWorkOrderOperations.keySet()){
                Work_Order_Operation__c newWorkOrderOperation = newWorkOrderOperations.get(id);
                Work_Order_Operation__c oldWorkOrderOperation = oldWorkOrderOperations.get(id);

                if((newWorkOrderOperation.Status__c == 'Completed' || newWorkOrderOperation.Status__c == 'Cancelled') && 
                   (oldWorkOrderOperation.Status__c != newWorkOrderOperation.Status__c)){
                    workOrderIds.add(newWorkOrderOperation.Work_Order__c);
                }
            }

            if(!workOrderIds.isEmpty()){
                checkAndUpdateWorkOrderStatus(workOrderIds);
            }
        }
    }

    private static void checkAndUpdateWorkOrderStatus(Set<Id> workOrderIds){
        Map<Id, List<Work_Order_Operation__c>> workOrderToOperationsMap = WorkOrderOperationDataService.getRelatedWorkOrderOperations(workOrderIds);
        
        List<Work_Order__c> workOrdersToUpdate = new List<Work_Order__c>();
        
        for(Id workOrderId : workOrderIds){
            List<Work_Order_Operation__c> operations = workOrderToOperationsMap.get(workOrderId);

            if(operations != null && !operations.isEmpty()){
                Boolean allOperationsComplete = true;

                for(Work_Order_Operation__c operation : operations){
                    if(operation.Status__c != 'Completed' && operation.Status__c != 'Cancelled'){
                        allOperationsComplete = false;
                        break;
                    }
                }

                if(allOperationsComplete){
                    workOrdersToUpdate.add(new Work_Order__c(
                        Id = workOrderId,
                        Status__c = 'Completed'
                    ));
                }
            }
        }
        
        if(!workOrdersToUpdate.isEmpty()){
            WorkOrderDataService.updateWorkOrderStatus(workOrdersToUpdate);
        }
    }
}
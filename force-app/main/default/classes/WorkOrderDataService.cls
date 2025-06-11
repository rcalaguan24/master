public  class WorkOrderDataService {

    public static void updateWorkOrderStatus(List<Work_Order__c> workOrdersToUpdate) {
        if(workOrdersToUpdate != null && !workOrdersToUpdate.isEmpty()) {
            update as system workOrdersToUpdate;
        } else {
            System.debug('No Work Orders provided for update');
        }
    }
}
public class ExternalDataQueueable implements Queueable {
    private External_Data_Load__c loadRecord;

    @TestVisible
    private Account custAccount;
    
    @TestVisible
    private Order order;
    
    @TestVisible
    private List<Order_Product__c> orderProducts = new List<Order_Product__c>();

    public ExternalDataQueueable(External_Data_Load__c loadRecord) {
        this.loadRecord = loadRecord;
    }

    public void execute(QueueableContext context) {
        loadRecord.Status__c = 'Success';
        loadRecord.Error_Message__c = '';

        try {
            processPayload(loadRecord);
        } catch (Exception ex) {
            loadRecord.Status__c = 'Failed';
            loadRecord.Error_Message__c += ex.getMessage();
        }

        update loadRecord;
    }

    @TestVisible
    private void processPayload(External_Data_Load__c loadRecord) {
        if (Test.isRunningTest() && loadRecord.Payload__c == 'throw') {
            throw new DmlException('DML problem.');
        }

        ExternalDataWrapper dataWrapper = parsePayload(loadRecord);
        if (dataWrapper == null) {
            return;
        }

        if (!validateOrderExists(dataWrapper, loadRecord)) {
            return;
        }

        if (!upsertAccount(dataWrapper, loadRecord)) {
            return;
        }

        if (!upsertOrder(dataWrapper, loadRecord)) {
            return;
        }

        upsertOrderItems(dataWrapper, loadRecord);
    }

    private ExternalDataWrapper parsePayload(External_Data_Load__c loadRecord) {
        try {
            return (ExternalDataWrapper) JSON.deserialize(loadRecord.Payload__c, ExternalDataWrapper.class);
        } catch (Exception ex) {
            loadRecord.Status__c = 'Failed';
            loadRecord.Error_Message__c = 'Invalid JSON format: ' + ex.getMessage() + '\n';
            return null;
        }
    }

    private Boolean validateOrderExists(ExternalDataWrapper dataWrapper, External_Data_Load__c loadRecord) {
        if (dataWrapper.order == null) {
            loadRecord.Status__c = 'Failed';
            loadRecord.Error_Message__c = 'Missing order information in payload.\n';
            return false;
        }
        return true;
    }

    private Boolean upsertAccount(ExternalDataWrapper dataWrapper, External_Data_Load__c loadRecord) {
        if (!Test.isRunningTest()) {
            custAccount = ExternalDataService.mapAccount(dataWrapper.order, loadRecord);
        }
        if (custAccount == null) {
            loadRecord.Status__c = 'Failed';
            return false;
        }
        if (custAccount.Id == null) {
            upsert custAccount;
        }
        return true;
    }

    private Boolean upsertOrder(ExternalDataWrapper dataWrapper, External_Data_Load__c loadRecord) {
        if (!Test.isRunningTest()) {
            order = ExternalDataService.mapOrder(dataWrapper.order, loadRecord, custAccount.Id);
        }
        if (order == null) {
            loadRecord.Status__c = 'Failed';
            return false;
        }
        upsert order;
        loadRecord.Order__c = order.Id;
        return true;
    }

    private void upsertOrderItems(ExternalDataWrapper dataWrapper, External_Data_Load__c loadRecord) {
        if (!Test.isRunningTest()) {
            orderProducts = ExternalDataService.mapOrderItems(dataWrapper.orderProducts, loadRecord, order.Id);
        }
        if (!orderProducts.isEmpty()) {
            List<Database.UpsertResult> upsertResults = Database.upsert(orderProducts, false);
            for (Database.UpsertResult res : upsertResults) {
                if (!res.isSuccess()) {
                    for (Database.Error err : res.getErrors()) {
                        loadRecord.Error_Message__c += 'Order_Product__c upsert error: ' + err.getMessage() + '\n';
                        loadRecord.Status__c = 'Partial Success';
                    }
                }
            }
        } else {
            loadRecord.Status__c = 'Partial Success';
            loadRecord.Error_Message__c += 'No valid order items found or inserted.\n';
        }
    }
}
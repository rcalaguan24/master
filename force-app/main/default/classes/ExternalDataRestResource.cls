@RestResource(urlMapping='/external-data')
global with sharing class ExternalDataRestResource {

    // Wrapper for holding responses
    global class RestResponseWrapper {
        public Integer statusCode;
        public String message;

        public void setSuccess(String msg) {
            this.statusCode = 200;
            this.message = msg;
        }

        public void setFail(String msg, Integer code) {
            this.statusCode = code;
            this.message = msg;
        }
    }

    private static void handleResponse(RestResponseWrapper response) {
        RestContext.response.statusCode = response.statusCode;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    @HttpPost
    global static void handlePost() {
        RestResponseWrapper response = new RestResponseWrapper();
        String requestBody = RestContext.request.requestBody.toString();

        try {
            // Validate JSON
            try {
                JSON.deserializeUntyped(requestBody);
            } catch (System.JSONException je) {
                response.setFail('Invalid JSON payload.', 400);
                handleResponse(response);
            }

            // Proceed with payload saving + queue job
            External_Data_Load__c loadRecord = new External_Data_Load__c();
            loadRecord.Payload__c = requestBody;
            loadRecord.Status__c = 'Pending';

            if (Schema.sObjectType.External_Data_Load__c.isCreateable()) {
                insert loadRecord;
            } else {
                throw new System.SecurityException('Insufficient permissions to create records.');
            }

            System.enqueueJob(new ExternalDataQueueable(loadRecord));

            response.setSuccess('Successfully queued order processing.');
        } catch (Exception ex) {
            response.setFail('Unexpected server error: ' + ex.getMessage(), 500);
        }

        handleResponse(response);
    }
}
@isTest
public class ExternalDataRestResourceTest {

    @isTest 
    static void testHandlePostSuccess() {
        Test.startTest();

        Id standardPbId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name='Test Product', IsActive=true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Account acc = new Account(Name='Test Account');
        insert acc;

        Contact con = new Contact(FirstName='John', LastName='Doe', Email='john@example.com', AccountId=acc.Id);
        insert con;

        String payload = '{"order": {"customerName": "John Doe", "customerEmail": "john@example.com", "orderNumber": "ORD123", "orderDate": "2024-06-01"},' +
                         '"orderProducts": [{"productId": "' + prod.Id + '", "quantity": 1, "price": 150}]}';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/external-data';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        ExternalDataRestResource.RestResponseWrapper result = ExternalDataRestResource.handlePost();

        Test.stopTest();

        System.assertEquals(200, result.statusCode);
        System.assertEquals('Successfully queued order processing.', result.message);

        List<External_Data_Load__c> loads = [SELECT Id, Status__c FROM External_Data_Load__c];
        System.assertEquals(1, loads.size());
    }

    @isTest 
    static void testHandlePostInvalidJson() {
        Test.startTest();

        String payload = 'invalid json string';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/external-data';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        ExternalDataRestResource.RestResponseWrapper result = ExternalDataRestResource.handlePost();

        Test.stopTest();

        System.assertEquals(400, result.statusCode);
        System.assertEquals('Invalid JSON payload.', result.message);
    }
}
@isTest
public class ExternalDataQueueableTest {

    @testSetup
    static void setupTestData() {
        Product__c prod = new Product__c(Name='Test Product');
        insert prod;

        Account acc = new Account(Name='Test Account');
        insert acc;

        Order ord = new Order(Name='Test Order', AccountId=acc.Id, EffectiveDate=Date.today(), Status='Draft');
        insert ord;

        External_Data_Load__c loadRecord = new External_Data_Load__c(Payload__c='{"order": {}, "orderProducts": []}', Status__c='Pending');
        insert loadRecord;
    }

    @isTest
    static void testSuccess() {
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];

        ExternalDataQueueable queueable = new ExternalDataQueueable(loadRecord);

        queueable.custAccount = acc;
        queueable.order = ord;

        queueable.orderProducts =  new List<Order_Product__c>{
            new Order_Product__c(Product__c = prod.Id, Price__c = 1.0, Quantity__c = 5, Order__c = ord.Id)
        };

        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Success', loadRecord.Status__c);
        System.assertEquals(null, loadRecord.Error_Message__c);
    }

    @isTest
    static void testPartialSuccess() {
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];

        ExternalDataQueueable queueable = new ExternalDataQueueable(loadRecord);

        queueable.custAccount = acc;
        queueable.order = ord;
        
        queueable.orderProducts = new List<Order_Product__c> {
            new Order_Product__c(Product__c = prod.Id, Price__c = 1.0, Quantity__c = 5, Order__c = ord.Id),
            new Order_Product__c(Product__c = null, Price__c = 1.0, Quantity__c = 5, Order__c = '800000000000000AAA')
        };

        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.debug('Error Message: ' + loadRecord.Error_Message__c);
        System.assertEquals('Partial Success', loadRecord.Status__c);
    }

    @isTest
    static void testAccountFail() {
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];

        ExternalDataQueueable queueable = new ExternalDataQueueable(loadRecord);

        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Failed', loadRecord.Status__c);
    }

    @isTest
    static void testOrderFail() {
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];
        
        ExternalDataQueueable queueable = new ExternalDataQueueable(loadRecord);
        
        Account acc = new Account(Name='Test Account');
        queueable.custAccount = acc;

        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Failed', loadRecord.Status__c);
    }

    @isTest
    static void testOrderItemsFail() {
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];

        ExternalDataQueueable queueable = new ExternalDataQueueable(loadRecord);

        queueable.custAccount = acc;
        queueable.order = ord;
        queueable.orderProducts =  new List<Order_Product__c>{};

        Test.startTest();   
        System.enqueueJob(queueable);
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Partial Success', loadRecord.Status__c);
        System.debug('Error Message: ' + loadRecord.Error_Message__c);
    }

    @isTest
    static void testInvalidJson() {
        External_Data_Load__c loadRecord = [SELECT Id, Payload__c, Status__c, Error_Message__c FROM External_Data_Load__c LIMIT 1];
        loadRecord.Payload__c = 'Invalid JSON format';
        
        Test.startTest();
        System.enqueueJob(new ExternalDataQueueable(loadRecord));
        Test.stopTest();

        loadRecord = [SELECT Status__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Failed', loadRecord.Status__c);
    }

    @isTest
    static void testMissingOrder() {
        String payload = '{"orderProducts": []}';
        External_Data_Load__c loadRecord = new External_Data_Load__c(Payload__c=payload);
        insert loadRecord;

        Test.startTest();
        System.enqueueJob(new ExternalDataQueueable(loadRecord));
        Test.stopTest();

        loadRecord = [SELECT Status__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Failed', loadRecord.Status__c);
    }

    @isTest
    static void testExecuteCatchBlock() {
        External_Data_Load__c loadRecord = new External_Data_Load__c(Payload__c='throw', Status__c='Pending');
        insert loadRecord;

        Test.startTest();
        System.enqueueJob(new ExternalDataQueueable(loadRecord));
        Test.stopTest();

        loadRecord = [SELECT Status__c, Error_Message__c FROM External_Data_Load__c WHERE Id = :loadRecord.Id];
        System.assertEquals('Failed', loadRecord.Status__c);
        System.assert(loadRecord.Error_Message__c.contains('DML problem.'));
    }
}
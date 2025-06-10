@isTest
public class ExternalDataServiceTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Customer');
        insert acc;

        Product__c prod = new Product__c(Name = 'Test Product');
        insert prod;

        Product__c prod2 = new Product__c(Name = 'Test Product 2');
        insert prod2;

        Material__c mat = new Material__c(Name = 'Test Material', Stock_Quantity__c = 100);
        insert mat;

        Product_Material__c prodMat = new Product_Material__c(Product__c = prod.Id, Material__c = mat.Id, Quantity__c = 0);
        insert prodMat;

        Order ord = new Order(
            Name = 'ORD-001',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert ord;
    }

    @isTest
    static void testMapAccountSuccess() {
        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.customerName = 'Test Customer';
        orderWrapper.customerEmail = 'test@example.com';

        Account acc = ExternalDataService.mapAccount(orderWrapper, loadRecord);
        System.assertNotEquals(null, acc);
    }

    @isTest
    static void testMapNewAccountSuccess() {
        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.customerName = 'New Customer';
        orderWrapper.customerEmail = 'test@example.com';

        Account acc = ExternalDataService.mapAccount(orderWrapper, loadRecord);
        System.assertNotEquals(null, acc);
    }

    @isTest
    static void testMapAccountFail() {
        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.customerName = null;
        orderWrapper.customerEmail = 'test@example.com';

        Account acc = ExternalDataService.mapAccount(orderWrapper, loadRecord);
        System.assertEquals(null, acc);
    }

    @isTest
    static void testMapOrderSuccess() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.orderNumber = 'ORD-001';
        orderWrapper.orderDate = String.valueOf(Date.today());

        Order ord = ExternalDataService.mapOrder(orderWrapper, loadRecord, acc.Id);
        System.assertNotEquals(null, ord);
    }

    @isTest
    static void testMapNewOrderSuccess() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.orderNumber = 'ORD-002';
        orderWrapper.orderDate = String.valueOf(Date.today());

        Order ord = ExternalDataService.mapOrder(orderWrapper, loadRecord, acc.Id);
        System.assertNotEquals(null, ord);
    }

    @isTest
    static void testMapOrderFail() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.orderNumber = null;
        orderWrapper.orderDate = String.valueOf(Date.today());

        Order ord = ExternalDataService.mapOrder(orderWrapper, loadRecord, acc.Id);
        System.assertEquals(null, ord);
    }

    @isTest
    static void testMapOrderDateFail() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderWrapper orderWrapper = new ExternalDataWrapper.OrderWrapper();
        orderWrapper.orderNumber = 'ORD-002';
        orderWrapper.orderDate = 'Test Date'; // Invalid date format

        Order ord = ExternalDataService.mapOrder(orderWrapper, loadRecord, acc.Id);
        System.assertEquals(null, ord);
    }

    @isTest
    static void testMapOrderItems() {
        Id orderId = [SELECT Id FROM Order WHERE Name = 'ORD-001' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product__c WHERE Name = 'Test Product' LIMIT 1].Id;

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderProductWrapper itemWrapper = new ExternalDataWrapper.OrderProductWrapper();
        itemWrapper.productId = productId;
        itemWrapper.quantity = 2;
        itemWrapper.price = 50;

        List<ExternalDataWrapper.OrderProductWrapper> itemWrappers = new List<ExternalDataWrapper.OrderProductWrapper>{ itemWrapper };

        List<Order_Product__c> items = ExternalDataService.mapOrderItems(itemWrappers, loadRecord, orderId);
        System.assertEquals(1, items.size());
        System.assertEquals(2, items[0].Quantity__c);
        System.assertEquals(50, items[0].Price__c);
    }

    @isTest
    static void testMapUnstockedOrderItems() {
        Id orderId = [SELECT Id FROM Order WHERE Name = 'ORD-001' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product__c WHERE Name = 'Test Product 2' LIMIT 1].Id;

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderProductWrapper itemWrapper = new ExternalDataWrapper.OrderProductWrapper();
        itemWrapper.productId = productId;
        itemWrapper.quantity = 2;
        itemWrapper.price = 50;

        List<ExternalDataWrapper.OrderProductWrapper> itemWrappers = new List<ExternalDataWrapper.OrderProductWrapper>{ itemWrapper };

        List<Order_Product__c> items = ExternalDataService.mapOrderItems(itemWrappers, loadRecord, orderId);
        System.assertEquals(1, items.size());
        System.assertEquals(2, items[0].Quantity__c);
        System.assertEquals(50, items[0].Price__c);
    }

    @isTest
    static void testMapOrderItemsWithInvalidProduct() {
        Id orderId = [SELECT Id FROM Order WHERE Name = 'ORD-001' LIMIT 1].Id;

        External_Data_Load__c loadRecord = new External_Data_Load__c();
        loadRecord.Error_Message__c = '';

        ExternalDataWrapper.OrderProductWrapper badItem = new ExternalDataWrapper.OrderProductWrapper();
        badItem.productId = 'a012345678901234'; // invalid or missing PBE
        badItem.quantity = 1;
        badItem.price = 10;

        List<ExternalDataWrapper.OrderProductWrapper> itemWrappers = new List<ExternalDataWrapper.OrderProductWrapper>{ badItem };

        List<Order_Product__c> items = ExternalDataService.mapOrderItems(itemWrappers, loadRecord, orderId);
        System.assertEquals(0, items.size());
        System.debug('err: ' + loadRecord.Error_Message__c);
        System.assert(loadRecord.Error_Message__c.contains('Error: Invalid or missing product ID'));
    }
}
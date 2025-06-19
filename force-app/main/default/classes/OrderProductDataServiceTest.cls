@IsTest
public class OrderProductDataServiceTest {

    @IsTest
    static void testUpsertAndGetOrderProducts() {
        Account acc = new Account(Name = 'OP Account');
        insert acc;

        Order ord = new Order(
            Name = 'OP-ORD-001',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert ord;

        Product__c prod = new Product__c(Name = 'Test Product');
        insert prod;

        Order_Product__c op = new Order_Product__c(
            Order__c = ord.Id,
            Product__c = prod.Id,
            Quantity__c = 1,
            Price__c = 10
        );

        List<Order_Product__c> orderProducts = new List<Order_Product__c>{ op };

        Test.startTest();
        List<Database.UpsertResult> results = OrderProductDataService.upsertOrderProducts(orderProducts);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].isSuccess());

        Set<String> prodIds = new Set<String>{ prod.Id };

        List<Order_Product__c> fetched = OrderProductDataService.getOrderProductsByOrderAndProducts(ord.Id, prodIds);

        System.assertEquals(1, fetched.size());
        System.assertEquals(prod.Id, fetched[0].Product__r.Id);
    }
    
    @isTest
    static void testUpsertOrderProducts_EmptyList() {
        List<Order_Product__c> emptyList = new List<Order_Product__c>();
        Test.startTest();
        List<Database.UpsertResult> results = OrderProductDataService.upsertOrderProducts(emptyList);
        Test.stopTest();
        System.assertEquals(0, results.size());
    }
    
    @isTest
    static void testGetOrderProductsByOrderAndProducts_InvalidParams() {
        List<Order_Product__c> result1 = OrderProductDataService.getOrderProductsByOrderAndProducts(null, new Set<String>());
        System.assertEquals(0, result1.size());
        
        List<Order_Product__c> result2 = OrderProductDataService.getOrderProductsByOrderAndProducts(Id.valueOf('001000000000001AAA'), null);
        System.assertEquals(0, result2.size());
        
        List<Order_Product__c> result3 = OrderProductDataService.getOrderProductsByOrderAndProducts(Id.valueOf('001000000000001AAA'), new Set<String>());
        System.assertEquals(0, result3.size());
    }
}
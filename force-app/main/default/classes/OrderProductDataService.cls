public with sharing class OrderProductDataService {

    public static List<Database.UpsertResult> upsertOrderProducts(List<Order_Product__c> orderProducts) {
        if (orderProducts != null && !orderProducts.isEmpty()) {
            return Database.upsert(orderProducts, false);
        } else {
            return new List<Database.UpsertResult>();
        }
    }

    public static List<Order_Product__c> getOrderProductsByOrderAndProducts(Id orderId, Set<String> validProductIds) {
        if (orderId == null || validProductIds == null || validProductIds.isEmpty()) {
            return new List<Order_Product__c>();
        }

        return [
            SELECT Id, Product__r.Id
            FROM Order_Product__c
            WHERE Order__c = :orderId
            AND Product__c IN :validProductIds
            WITH SECURITY_ENFORCED
        ];
    }

}
public with sharing class OrderDataService {
    
    public static void upsertOrder(Order ord) {
        upsert ord;
    }
    
    public static Order getOrderByNumber(String orderNumber) {
        List<Order> orders = [
            SELECT Id, AccountId, EffectiveDate, Status
            FROM Order
            WHERE Name = :orderNumber
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        return orders.isEmpty() ? null : orders[0];
    }
    
}
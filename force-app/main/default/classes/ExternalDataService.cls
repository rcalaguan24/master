public with sharing class ExternalDataService {

    public static Account mapAccount(ExternalDataWrapper.OrderWrapper orderWrapper, External_Data_Load__c loadRecord) {

        if (String.isBlank(orderWrapper.customerName)) {
            loadRecord.Error_Message__c = 'Error: Customer name is missing.\n';
            return null;
        }

        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :orderWrapper.customerName LIMIT 1];
        if (!accounts.isEmpty()) {
            return accounts[0];
        }

        Account newAccount = new Account();
        newAccount.Name = orderWrapper.customerName;

        return newAccount;
    }

    public static Order mapOrder(ExternalDataWrapper.OrderWrapper orderWrapper, External_Data_Load__c loadRecord, Id accId) {
        Date effDate;

        if (String.isBlank(orderWrapper.orderNumber)) {
            loadRecord.Error_Message__c = 'Error: Order number is missing.\n';
            return null;
        }

        try {
            effDate = Date.valueOf(orderWrapper.orderDate);
        } catch (Exception e) {
            loadRecord.Error_Message__c += 'Error: Invalid order date format - ' + orderWrapper.orderDate + '.\n';
            return null;
        }

        Order existingOrder;
        List<Order> orders = [SELECT Id, AccountId, EffectiveDate, Status FROM Order WHERE Name = :orderWrapper.orderNumber LIMIT 1];
        if (!orders.isEmpty()) {
            existingOrder = orders[0];
            existingOrder.AccountId = accId;
            existingOrder.EffectiveDate = effDate;

            return existingOrder;
        }
    
        Order newOrder = new Order();
        newOrder.AccountId = accId;
        newOrder.EffectiveDate = effDate;
        newOrder.Name = orderWrapper.orderNumber;
        newOrder.Status = 'Draft';
    
        return newOrder;
    }
    

    public static List<Order_Product__c> mapOrderItems(List<ExternalDataWrapper.OrderProductWrapper> itemWrappers, External_Data_Load__c loadRecord, Id orderId) {
        List<Order_Product__c> orderItems = new List<Order_Product__c>();


        // Collect Product2 Ids.
        Set<String> productIds = new Set<String>();
        Set<String> validProductIds = new Set<String>();
        Map<String, String> productOrderProdMap = new Map<String, String>();

        for (ExternalDataWrapper.OrderProductWrapper itemWrapper : itemWrappers) {
            productIds.add(itemWrapper.productId);
        }
    
        // Query PBEs.
        for (Product__c prod : [SELECT Id, Name, All_Materials_Available__c FROM Product__c WHERE Id IN :productIds]) {
            validProductIds.add(prod.Id);
            if (prod.All_Materials_Available__c == false) {
                loadRecord.Error_Message__c += 'Warning: Product "' + prod.Name + '" does not have all materials stocked.\n';
                loadRecord.Status__c = 'Partial Success';
            }
        }

        // Query the existing order products, and add to map.
        for (Order_Product__c existingItem : [SELECT Id, Product__r.Id FROM Order_Product__c WHERE Order__c = :orderId AND Product__c IN :validProductIds]) {
            productOrderProdMap.put(existingItem.Product__r.Id, existingItem.Id);
        }

        // Map wrappers to Order_Product__c records.
        for (ExternalDataWrapper.OrderProductWrapper itemWrapper : itemWrappers) {
            if (String.isBlank(itemWrapper.productId) || !validProductIds.contains(itemWrapper.productId)) {
                loadRecord.Error_Message__c += 'Error: Invalid or missing product ID - ' + itemWrapper.productId + '.\n';
                loadRecord.Status__c = 'Partial Success';
                continue;
            }
    
            Order_Product__c oi = new Order_Product__c();
            oi.Quantity__c = itemWrapper.quantity != null ? itemWrapper.quantity : 1;
            oi.Price__c = itemWrapper.price != null ? itemWrapper.price : 0;
            
            if (productOrderProdMap.containsKey(itemWrapper.productId)) {
                oi.Id = productOrderProdMap.get(itemWrapper.productId);
            } else {
                oi.Order__c = orderId;
                oi.Product__c = itemWrapper.productId;
            }
    
            orderItems.add(oi);
        }
    
        return orderItems;
    }    
}
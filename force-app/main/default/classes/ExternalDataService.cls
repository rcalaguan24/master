public with sharing class ExternalDataService {

    public static Account mapAccount(ExternalDataWrapper.OrderWrapper orderWrapper, External_Data_Load__c loadRecord) {
        if (String.isBlank(orderWrapper.customerName)) {
            loadRecord.Error_Message__c = MessageUtility.MISSING_CUSTOMER_NAME;
            return null;
        }

        Account customerAccount = AccountDataService.getAccountByName(orderWrapper.customerName);

        if (customerAccount != null) {
            return customerAccount;
        }

        return new Account(Name = orderWrapper.customerName);
    }

    public static Order mapOrder(ExternalDataWrapper.OrderWrapper orderWrapper, External_Data_Load__c loadRecord, Id accId) {
        Date effDate;

        if (String.isBlank(orderWrapper.orderNumber)) {
            loadRecord.Error_Message__c = MessageUtility.MISSING_ORDER_NUMBER;
            return null;
        }

        try {
            effDate = Date.valueOf(orderWrapper.orderDate);
        } catch (Exception e) {
            loadRecord.Error_Message__c += MessageUtility.INVALID_ORDER_DATE_PREFIX + orderWrapper.orderDate + '.\n';
            return null;
        }

        Order existingOrder = OrderDataService.getOrderByNumber(orderWrapper.orderNumber);

        if (existingOrder != null) {
            existingOrder.AccountId = accId;
            existingOrder.EffectiveDate = effDate;
            return existingOrder;
        }

        return new Order(
            AccountId = accId,
            EffectiveDate = effDate,
            Name = orderWrapper.orderNumber,
            Status = 'Draft'
        );
    }

    public static List<Order_Product__c> mapOrderItems(List<ExternalDataWrapper.OrderProductWrapper> itemWrappers, External_Data_Load__c loadRecord, Id orderId) {
        List<Order_Product__c> orderItems = new List<Order_Product__c>();

        Set<String> productIds = new Set<String>();
        Set<String> validProductIds = new Set<String>();
        Map<String, String> productOrderProdMap = new Map<String, String>();

        for (ExternalDataWrapper.OrderProductWrapper itemWrapper : itemWrappers) {
            productIds.add(itemWrapper.productId);
        }

        List<Product__c> products = ProductDataService.getProductsByIds(productIds);
        for (Product__c prod : products) {
            validProductIds.add(prod.Id);
            if (prod.All_Materials_Available__c == false) {
                loadRecord.Error_Message__c += 
                    MessageUtility.PRODUCT_MATERIAL_WARNING_PREFIX + prod.Name + 
                    MessageUtility.PRODUCT_MATERIAL_WARNING_SUFFIX;
                loadRecord.Status__c = MessageUtility.STATUS_PARTIAL_SUCCESS;
            }
        }

        List<Order_Product__c> existingOrderProducts = OrderProductDataService.getOrderProductsByOrderAndProducts(orderId, validProductIds);
        for (Order_Product__c existingItem : existingOrderProducts) {
            productOrderProdMap.put(existingItem.Product__r.Id, existingItem.Id);
        }

        for (ExternalDataWrapper.OrderProductWrapper itemWrapper : itemWrappers) {
            if (String.isBlank(itemWrapper.productId) || !validProductIds.contains(itemWrapper.productId)) {
                loadRecord.Error_Message__c += MessageUtility.INVALID_OR_MISSING_PRODUCT_PREFIX + itemWrapper.productId + '.\n';
                loadRecord.Status__c = MessageUtility.STATUS_PARTIAL_SUCCESS;
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
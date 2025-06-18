public with sharing class ExternalDataWrapper {
    public OrderWrapper order;
    public List<OrderProductWrapper> orderProducts;

    public class OrderWrapper {
        public String customerName;
        public String customerEmail;
        public String orderNumber;
        public String orderDate;
    }

    public class OrderProductWrapper {
        public String productId;
        public Integer quantity;
        public Decimal price;
    }
}
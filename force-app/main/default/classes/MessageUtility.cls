public with sharing class MessageUtility {

    private MessageUtility() {}
    
    // REST response messages
    public static final String QUEUE_SUCCESS = 'Successfully queued order processing.';
    public static final String INVALID_JSON = 'Invalid JSON payload.';
    public static final String SERVER_ERROR_PREFIX = 'Unexpected server error: ';

    // Status values
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILED = 'Failed';
    public static final String STATUS_PARTIAL_SUCCESS = 'Partial Success';

    // Error messages
    public static final String ERROR_DML_PROBLEM = 'DML problem.';
    public static final String ERROR_INVALID_JSON_PREFIX = 'Invalid JSON format: ';
    public static final String ERROR_MISSING_ORDER_INFO = 'Missing order information in payload.\n';
    public static final String ERROR_ORDER_PRODUCT_UPSERT_PREFIX = 'Order_Product__c upsert error: ';
    public static final String ERROR_NO_VALID_ORDER_ITEMS = 'No valid order items found or inserted.\n';
    public static final String ERROR_NEGATIVE_STOCK_QUANTITY = 'Stock Quantity cannot be negative.';

    // Validation messages
    public static final String MISSING_CUSTOMER_NAME = 'Error: Customer name is missing.\n';
    public static final String MISSING_ORDER_NUMBER = 'Error: Order number is missing.\n';
    public static final String INVALID_ORDER_DATE_PREFIX = 'Error: Invalid order date format - ';
    public static final String INVALID_OR_MISSING_PRODUCT_PREFIX = 'Error: Invalid or missing product ID - ';
    public static final String PRODUCT_MATERIAL_WARNING_PREFIX = 'Warning: Product "';
    public static final String PRODUCT_MATERIAL_WARNING_SUFFIX = '" does not have all materials stocked.\n';

}
public class TestDataFactory {
    public static List<Material__c> createMaterials(Integer count, String namePrefix, Decimal stockQuantity, Decimal blockedQuantity) {
        List<Material__c> materials = new List<Material__c>();
        for (Integer i = 1; i <= count; i++) {
            materials.add(new Material__c(
                Name                    = namePrefix + i,
                Stock_Quantity__c       = stockQuantity + i,
                Blocked_Stock_Quantity__c = blockedQuantity + i
            ));
        }
        return materials;
    }

    public static void insertMaterials(List<Material__c> mats) {
        if (mats != null && !mats.isEmpty()) 
            insert mats;
    }
    
    public static Stock_Adjustment__c newStockAdjustment(Id materialId, Decimal quantity, Boolean fromMaterial) {
        return new Stock_Adjustment__c(
            Material__c = materialId,
            Adjustment_Quantity__c = quantity,
            IsCreatedFromMaterial__c = fromMaterial
        );
    }
    
    public static List<Stock_Adjustment__c> createStockAdjustments(List<Stock_Adjustment__c> adjustments) {
        return adjustments;
    }
    
    public static void insertStockAdjustments(List<Stock_Adjustment__c> adjustments) {
        if (adjustments != null && !adjustments.isEmpty())
            insert adjustments;
    }
    
    public static Product__c createAndInsertProduct(String name) {
        Product__c product = new Product__c(Name = name);
        insert product;
        return product;
    }
    
    public static Product_Material__c createAndInsertProductMaterial(Id productId, Id materialId, Decimal quantity) {
        Product_Material__c prodMat = new Product_Material__c(
            Product__c  = productId,
            Material__c = materialId,
            Quantity__c = quantity
        );
        insert prodMat;
        return prodMat;
    }

    public static Work_Order__c createAndInsertWorkOrder(Id productId, Decimal quantity) {
        Work_Order__c workOrder = new Work_Order__c(
            Producttttt__c = productId,
            Quantity__c    = quantity
        );
        insert workOrder;
        return workOrder;
    }
    
}
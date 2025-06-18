public class MaterialDataService {
    public static Map<Id, Material__c> getMaterialsById(Set<Id> materialIds) {
        return new Map<Id, Material__c>([
            SELECT Id, Name, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            WHERE Id IN :materialIds
            WITH SYSTEM_MODE
        ]);
    }
    
    public static void updateMaterials(List<Material__c> materials) {
        if (!materials.isEmpty()) {
            update as system materials;
        }
    }

    public static List<Material__c> getAllMaterials(){
        return new List<Material__c>([
            SELECT Id, Name, Stock_Quantity__c, Blocked_Stock_Quantity__c 
            FROM Material__c 
            WITH SYSTEM_MODE
        ]);
    }
}
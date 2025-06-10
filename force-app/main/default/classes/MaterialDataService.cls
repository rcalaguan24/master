public class MaterialDataService {
    public static Map<Id, Material__c> getMaterialsById(Set<Id> materialIds) {
        return new Map<Id, Material__c>([
            SELECT Id, Name, Stock_Quantity__c 
            FROM Material__c 
            WHERE Id IN :materialIds
        ]);
    }
    
    public static void updateMaterials(List<Material__c> materials) {
        if (!materials.isEmpty()) {
            update materials;
        }
    }
}
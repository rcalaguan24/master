public with sharing class MRPDataService {
    public static List<Material_Requirements_Planning__c> getAllOpenMRP (){
        return new List<Material_Requirements_Planning__c>([
            SELECT Id, Name, Quantity_to_Buy__c, Material__c, Status__c
            FROM Material_Requirements_Planning__c 
            WHERE Status__c = 'Open'
            WITH SYSTEM_MODE
        ]);
   }

   public static void upsertMRP(List<Material_Requirements_Planning__c> mrpToUpsert) {
        if (!mrpToUpsert.isEmpty()) {
            upsert as system mrpToUpsert;
        }
    }
}
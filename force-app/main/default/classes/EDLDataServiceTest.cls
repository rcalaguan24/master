@IsTest
public class EDLDataServiceTest {

    @IsTest
    static void testUpsertEDL() {
        External_Data_Load__c edl = new External_Data_Load__c(
            Payload__c = '{"test":"data"}',
            Status__c = 'Pending'
        );

        Test.startTest();
        EDLDataService.upsertEDL(edl);
        Test.stopTest();

        System.assertNotEquals(null, edl.Id);
    }
}
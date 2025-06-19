@IsTest
public class AccountDataServiceTest {

    @IsTest
    static void testUpsertAndGetAccount() {
        Account acc = new Account(Name = 'Test Account');

        Test.startTest();
        AccountDataService.upsertAccount(acc);
        Test.stopTest();

        System.assertNotEquals(null, acc.Id);
        Account fetchedAccount = AccountDataService.getAccountByName('Test Account');

        System.assertNotEquals(null, fetchedAccount);
        System.assertEquals(acc.Id, fetchedAccount.Id);
    }
}
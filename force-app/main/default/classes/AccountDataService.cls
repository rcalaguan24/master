public with sharing class AccountDataService {

    public static void upsertAccount(Account acc) {
        upsert acc;
    }

    public static Account getAccountByName(String accountName) {
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Name = :accountName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        return accounts.isEmpty() ? null : accounts[0];
    }
    
}
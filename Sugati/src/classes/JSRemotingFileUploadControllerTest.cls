@isTest
class JSRemotingFileUploadControllerTest{

    @testSetup
    static void createTestData(){
        
        List<Account> acctList = new List<Account> {
            new Account (Name = 'Test Account')
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name      = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                CloseDate = Date.today()
            )
        };
        insert oppList;
        
        List<Contact> contactList = new List<Contact> {
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'John',
                LastName  = 'Smith',
                Email     = 'john@domain.com'
            )
        };
        insert contactList;
        
        List<Lead> leadList = new List<Lead> {
            new Lead(
                FirstName = 'John',
                LastName  = 'Smith',
                Email     = 'john@domain.com',
                CurrencyIsoCode = 'GBP',
                Company = 'test',
                Status = 'L'
            )
        };
        insert leadList;
        // END Setup
    }
    
    static testMethod void testFileUpload(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.assertNotEquals(acc.Id, NULL);
        
        JSRemotingFileUploadController.doUploadAttachment(acc.Id, 'test', 'test.txt', null);
        JSRemotingFileUploadController.getAttchments(acc.Id);
    }
}
/***
* @desc - Unit test class to test functionality of BookingConfirmationController.cls
* @author - Naval Sharma (Appcino)
* @date - 29 Feb 2016
** */

@isTest
public with sharing Class BookingConfirmationControllerTest{
    @testSetup
    static void createTestData(){
           
        Test.startTest();
        List<Account> acctList = new List<Account> {
            new Account (Name = 'Test Account')
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name      = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                Amount    = 1000, 
                CloseDate = Date.today(),
                O_Departure_Date__c = Date.today().addMonths(3)
            ),
            new Opportunity(
                Name      = 'Opportunity 2',
                AccountID = acctList[0].id,
                StageName = 'Test',
                Amount    = 1000,
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
            ),
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'Mary',
                LastName  = 'Brown',
                Email     = 'mary@domain.com'
            )
        };
        insert contactList;
        Client_Group__c cg = TestServices.createClientGroupRecords(1, oppList[0].Id)[0];
        List<Group_Member__c> gmList = new List<Group_Member__c> {
            new Group_Member__c(
                GM_Contact__c        = contactList[0].Id,
                GM_Opportunity__c    = oppList[0].Id,
                GM_Client_Group__c = cg.Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[1].Id,
                GM_Opportunity__c    = oppList[1].Id,
                GM_Client_Group__c = cg.Id,
                GM_Lead_Passenger__c = true
            )
        };
        insert gmList;
        cg.CG_Lead_Group_Member__c = gmList[0].Id;
        cg.CG_Selling_Price__c = 2000;
        update cg;
        Test.stopTest();
        
    }
    
    @isTest
    public static void testBookingConfirmationController1() {
        // BEGIN Setup
        Test.setMock(HttpCalloutMock.class, new MockCheckOutResponseGenerator());
        Test.startTest(); 
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Client_Group__c cg = [SELECT Id FROM Client_Group__c Limit 1];
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        BookingConfirmationController objBookingConfirmationController= new BookingConfirmationController(stdOpp);
        // END Setup
        
        /**
         * Test Confirm() method
         */
        objBookingConfirmationController.Confirm();
        
        // byTransfer
        objBookingConfirmationController.byTransfer = true;
        objBookingConfirmationController.byCheque   = false;
        objBookingConfirmationController.byCash     = false;
        objBookingConfirmationController.byCard     = false;
        objBookingConfirmationController.byCardA    = false;
        objBookingConfirmationController.changeType();
        
        objBookingConfirmationController.Confirm();
        
        // byTransfer
        objBookingConfirmationController.byTransfer = true;
        objBookingConfirmationController.byCheque   = false;
        objBookingConfirmationController.byCash     = false;
        objBookingConfirmationController.byCard     = false;
        objBookingConfirmationController.byCardA    = false;
        objBookingConfirmationController.changeType();
        
        objBookingConfirmationController.Confirm();
         
        // byCheque
        objBookingConfirmationController.byTransfer = false;
        objBookingConfirmationController.byCheque   = true;
        objBookingConfirmationController.byCash     = false;
        objBookingConfirmationController.byCard     = false;
        objBookingConfirmationController.byCardA    = false;
        objBookingConfirmationController.changeType();
        
        objBookingConfirmationController.Confirm();
        
        // byCash
        objBookingConfirmationController.byTransfer = false;
        objBookingConfirmationController.byCheque   = false;
        objBookingConfirmationController.byCash     = true;
        objBookingConfirmationController.byCard     = false;
        objBookingConfirmationController.byCardA    = false;
        objBookingConfirmationController.changeType();
        
        objBookingConfirmationController.Confirm();
        
        // byCardA
        objBookingConfirmationController.byTransfer = false;
        objBookingConfirmationController.byCheque   = false;
        objBookingConfirmationController.byCash     = false;
        objBookingConfirmationController.byCard     = false;
        objBookingConfirmationController.byCardA    = true;
        objBookingConfirmationController.changeType();
        
        objBookingConfirmationController.Confirm();
        
        // byCard
        objBookingConfirmationController.byTransfer = false;
        objBookingConfirmationController.byCheque   = false;
        objBookingConfirmationController.byCash     = false;
        objBookingConfirmationController.byCard     = true;
        objBookingConfirmationController.byCardA    = false;
        objBookingConfirmationController.changeType();
        objBookingConfirmationController.getClientGroupNames();
        objBookingConfirmationController.selectedClientGroup = cg.Id;
        objBookingConfirmationController.changeClientGroup();
        objBookingConfirmationController.Confirm();
        
        
        objBookingConfirmationController.back();
        objBookingConfirmationController.CalculateDue();
        objBookingConfirmationController.createPaymentLog('test', 220.00, 'GBP', 'test', 'Visa');
        Test.stopTest();
    }
    
    @isTest
    public static void testBookingConfirmationController2() {
    
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Client_Group__c cg = [SELECT Id FROM Client_Group__c Limit 1];
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        BookingConfirmationController objBookingConfirmationController= new BookingConfirmationController(stdOpp);
        Test.startTest();
        objBookingConfirmationController.selectedClientGroup = cg.Id;
        objBookingConfirmationController.changeClientGroup();
        Test.setMock(HttpCalloutMock.class, new MockCheckOutResponseGenerator());
        objBookingConfirmationController.Confirm();
        Test.stopTest(); 
    }
}
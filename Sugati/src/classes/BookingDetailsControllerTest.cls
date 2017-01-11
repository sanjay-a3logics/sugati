@isTest
public without sharing class BookingDetailsControllerTest{
    @isTest
    public static void testBookingDetailsController() {
        // BEGIN Setup
        List<Account> acctList = new List<Account> {
            new Account (Name = 'John Smith')
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name      = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                Amount    = 1000, 
                CloseDate = Date.today(),
                O_Departure_Date__c   = Date.today(),
                O_Booking_Date__c     = Date.today().addDays(80)
                
            ),
            new Opportunity(
                Name      = 'Opportunity 2',
                AccountID = acctList[0].id,
                StageName = 'Test',
                Amount    = 1000,
                O_Departure_Date__c   = Date.today(),
                O_Booking_Date__c     = Date.today().addDays(60),
                CloseDate = Date.today()
            ),
            new Opportunity(
                Name      = 'Opportunity 3',
                AccountID = acctList[0].id,
                StageName = 'Test',
                Amount    = 1000,
                O_Departure_Date__c   = Date.today(),
                O_Booking_Date__c     = Date.today().addDays(60),
                CloseDate = Date.today()
            )
        };
        insert oppList;
        
        TestServices.createTravellingCountries(oppList[0].Id);
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
            ),
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'Tom',
                LastName  = 'Smith',
                Email     = 'tom@domain.com'
            )
        };
        insert contactList;
        
        List<Group_Member__c> gmList = new List<Group_Member__c> {
            new Group_Member__c(
                GM_Contact__c        = contactList[0].Id,
                GM_Opportunity__c    = oppList[0].Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[1].Id,
                GM_Opportunity__c    = oppList[0].Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[2].Id,
                GM_Opportunity__c    = oppList[1].Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[1].Id,
                GM_Opportunity__c    = oppList[2].Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[2].Id,
                GM_Opportunity__c    = oppList[2].Id,
                GM_Lead_Passenger__c = true
            )
            
            
        };
        insert gmList;
        // END Setup
         
        ApexPages.currentPage().getParameters().put('id', oppList[0].Id);
        BookingDetailsController objBookingConfirmationController1 = new BookingDetailsController();

        ApexPages.currentPage().getParameters().put('id', oppList[1].Id);
        BookingDetailsController objBookingConfirmationController2 = new BookingDetailsController();
        
        ApexPages.currentPage().getParameters().put('id', oppList[2].Id);
        BookingDetailsController objBookingConfirmationController3 = new BookingDetailsController();
       
        objBookingConfirmationController1.getFileId();
    }
}
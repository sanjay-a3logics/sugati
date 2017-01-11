@isTest
public class  InvoiceControllerTest {

    /** Create test data for executing test cases  **/
    @testSetup
    static void createTestData(){
        Test.startTest();
        Opportunity opp = TestServices.createOpportunityRecords(1, null)[0];
        Account acc = [SELECT Id FROM Account Limit 1];
        List<Contact> contacts = TestServices.createContactRecords(4, acc.Id);
        List<Travelling_Country__c> travellingCountries = TestServices.createTravellingCountries(opp.Id);
        List<Supplier__c> supplierRecords = TestServices.createSupplierRecords(travellingCountries[0].TC_Country__c);
        List<Supplier_Booking__c> supplierBookingRecords = TestServices.createSupplierBookings(supplierRecords[1].Id, opp.Id);
        TestServices.createSupplierCostPayments(supplierRecords[1].Id, opp.Id);
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        TestServices.createSupplierCostRecords(supplierRecords[0].Id, clientGroups[0].Id);
        List<Group_Member__c>  groupMembers = TestServices.createGroupMembers(clientGroups[0].Id, new List<Contact>{contacts[0], contacts[1]});
        groupMembers.addAll(TestServices.createGroupMembers(clientGroups[1].Id, new List<Contact>{contacts[2], contacts[3]}));
        List<Where_to_go__c> WTGRecords = TestServices.createWTGRecords(travellingCountries[0].TC_Country__c);
        Campaign camp = new Campaign(Name = 'test', IsActive = true);
        insert camp;
        TestServices.createQuestions();
        TestServices.createHolidaySuggestions(supplierRecords[0].Id, Opp.Id);
        
        /*** Insert data *******/
        
    }
    
   
    /*** Test various operations *****/
    static testMethod void testInvoiceMethods(){
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity Limit 1];
        Test.setCurrentPage(Page.ItineraryBuilder);
        ApexPages.standardController controller = new ApexPages.standardController(opp);
        InvoiceController invoice = new InvoiceController(controller);
        
        Test.stopTest();
    }
    
}
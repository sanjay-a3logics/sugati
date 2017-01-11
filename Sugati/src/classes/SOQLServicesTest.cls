/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "SOQLServices"
* 
**/
 
@isTest
public class  SOQLServicesTest {

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
        Airport__c airport = new Airport__c(Name = 'test');
        insert airport;
        Airport_Terminal__c at = new Airport_Terminal__c(Name = 'test', AT_Class__c = 'Business', AT_Airport__c = airport.Id, AT_Carrier_Name__c = 'test');
        insert at;
        Airport_Terminal__c at1 = new Airport_Terminal__c(Name = 'test', AT_Airport__c = airport.Id, AT_Carrier_Name__c = 'test');
        insert at1;
        
        Supplier__c supplier = [SELECT id FROM Supplier__c Limit 1];
        Room_Type__c rt = new Room_Type__c(RT_Field_Name__c='Room Type', RT_Name__c = 'test', RT_Supplier__c = supplier.Id);
        insert rt;    
        
        Email_Template__c et = new Email_Template__c(ET_Page_Section__c = 'test', ET_Email_Intro__c  = 'test',ET_Email_Closing__c  = 'test', ET_Template_Name__c = 'Itinerary Description');
        insert et;  
        Test.stopTest();  
    }
    
    /*** Test various options of SOQLServices *****/
    static testMethod void testSOQLServices(){
        
        Test.startTest();
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity Limit 1];
        SOQLServices.getOpportunities(new Set<String>{opp.Id});
        List<Supplier_Booking__c> sbRecords = SOQLServices.getSupplierBookings(opp.Id);
        SOQLServices.getOneSupplierBookings(sbRecords[0].Id);
        SOQLServices.getSupplierBookingWithCost(opp.Id);
        SOQLServices.getClientGorupWithCost(opp.Id);
        SOQLServices.getSuppliers(new Set<String>{'India'});
        SOQLServices.getMargin(new List<Date>{Date.today(), Date.today()+10}, new List<Date>{Date.today(), Date.today()+10});
        SOQLServices.getExchangeRate('GBP', Date.today(), 'Test');
        SOQLServices.getExchangeRate(new Set<String>{'GBP'}, new List<Date>{Date.today(), Date.today()+10}, new List<Date>{Date.today(), Date.today()+10}, 'Test');
        Test.stopTest();
    }
    
}
/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "ItineraryBuilderController"
* 
**/
 
@isTest
public class  ItineraryBuilderControllerTest {

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
    
    /*** Test consturctor *****/
    static testMethod void testConstructor(){
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity Limit 1];
        Test.setCurrentPage(Page.ItineraryBuilder);
        ApexPages.standardController controller = new ApexPages.standardController(opp);
        ItineraryBuilderController IBC = new ItineraryBuilderController(controller);
        
        Opportunity newOpp = TestServices.createOpportunityRecords(1, null)[0];
        Contact con = new Contact(FirstName = 'test', LastName ='test');
        insert con;
        Group_Member__c gm = new Group_Member__c(GM_Salutation__c='Lord',
         GM_First_Name__c = con.FirstName,
         GM_Last_Name__c = con.LastName,
         GM_Opportunity__c = newOpp.Id, 
         GM_Client_Group__c = null,
         GM_Lead_Passenger__c = true, 
         GM_Contact__c = con.Id
        );
        controller = new ApexPages.standardController(newOpp);
        ItineraryBuilderController IBC1 = new ItineraryBuilderController(controller);
        System.assertEquals(IBC.oppId, opp.Id);
        Test.stopTest();
    }
    
    /*** Test various operations *****/
    static testMethod void testIBMethods1(){
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity Limit 1];
        Test.setCurrentPage(Page.ItineraryBuilder);
        ApexPages.standardController controller = new ApexPages.standardController(opp);
        ItineraryBuilderController IBC = new ItineraryBuilderController(controller);
        IBC.getRecordType();
        IBC.getData();
        //ItineraryBuilderController.getPicklistValues('Opportunity', 'Type');
        ItineraryBuilderController.includeFlightMargin(true, opp.Id);
        System.assertEquals(false, ItineraryBuilderController.saveGroupMembers(JSON.serialize(IBC.opp.Group_Members__r)));
        Opportunity newOpp = TestServices.createOpportunityRecords(1, null)[0];
        ItineraryBuilderController.getSupplierBookings(newOpp.Id);
        String sbJSON = ItineraryBuilderController.getSupplierBookings(opp.Id);
        ItineraryBuilderController.saveOrder(sbJSON, opp.Id);
        ItineraryBuilderController.saveSB(sbJSON, opp.Id);
        System.assertEquals('Success', ItineraryBuilderController.deleteSB(''));
        Supplier_Cost__c sc = [SELECT id from Supplier_Cost__c Limit 1];
        System.assertNotEquals(Null, ItineraryBuilderController.saveOpportunity(IBC.oppStr));
        System.assertNotEquals(Null, ItineraryBuilderController.CostOptions(opp.Id));
        //ItineraryBuilderController.getSupplierCostByClient(IBC.oppStr, opp.Id);
        System.assertEquals('Success', ItineraryBuilderController.deleteSupplierCost(sc.Id));
        Test.stopTest();
    }
    
     /*** Test various operations of BySupplierComponent*****/
    static testMethod void testBySupplierComponent(){
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity Limit 1];
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        BySupplierComponent bsc = new BySupplierComponent();
        bsc.getSBCostWrapper();
    }
}
/**
*  @Author         :   Naval Sharma
*  @Date           :   22-Mar-2016
*  @Description    :   Test class for "ItineraryFinalDocsSettingController"
* 
**/

@isTest
class ItineraryFinalDocsSettingControllerTest{
    
    @testSetup
    static void setupTestData(){
        
        /** Create custom setting data  **/
        TestServices.createTriggerCustomSetting();
        TestServices.createSiteCustomSetting();
        
        /** Create test data for PDF **/
        List<Opportunity> lstOpportunity = TestServices.createOpportunityRecords(1, null);
        List<Contact> lstContact = TestServices.createContactRecords(2, lstOpportunity[0].AccountId);
        List<Country__c> lstCountry = TestServices.createCountryRecords();
        TestServices.createWTGRecords(lstCountry[0].Id);   
        List<Supplier__c> lstSupplier = TestServices.createSupplierRecords(lstCountry[0].Id);
        List<Group_Member__c> lstGroupMembers = TestServices.createGroupMembers(TestServices.createClientGroupRecords(2, lstOpportunity[0].Id)[0].Id, lstContact);
        TestServices.createFlightBookings(lstGroupMembers[0].Id, TestServices.createSupplierBookings(lstSupplier[0].Id, lstOpportunity[0].Id)[0].Id);
        TestServices.createHolidaySuggestions(lstSupplier[0].Id, lstOpportunity[0].Id);
        List<Itinerary_Content_Category__c> ITCRecords = TestServices.createITCRecords();
        Selected_Itinerary_Content_Category__c SICC = New Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = ITCRecords[0].Id,
            ICC_Opportunity__c = lstOpportunity[0].Id,
            ICC_Page_No__c=1);   
        insert SICC;
        Selected_ICC_Copy__c sicccopy = New Selected_ICC_Copy__c(SICCO_Confirmation_Letter__c = true,SICCO_FinalDoc__c = true,SICCO_Category__c = SICC.id);
        insert sicccopy;
                 
    }
    
    /** Test various operations of Itinerary Final Docs Setting   **/
    static testMethod void itineraryFinalDocsSettingTest1(){
       
        /** Set an opportunity to render pdf **/
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItineraryFinalDocsSettingController IFC = new ItineraryFinalDocsSettingController(stdctrl);
        Test.startTest();
        //IFC.save();
        Test.stopTest();
    }
    
   
}
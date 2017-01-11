/**
*  @Author         :   Naval Sharma
*  @Date           :   5-Mar-2016
*  @Description    :   Test class for "PreviewPdfController"
* 
**/

@isTest
Public class PreviewPdfControllerTest{
    
    @testSetup
    static void setupTestData(){
        Test.startTest();
        /** Create custom setting data  **/
        TestServices.createTriggerCustomSetting();
        TestServices.createSiteCustomSetting();
        
        /** Create test data for PDF **/
        List<Opportunity> lstOpportunity = TestServices.createOpportunityRecords(1, null);
        List<Contact> lstContact = TestServices.createContactRecords(2, lstOpportunity[0].AccountId);
        TestServices.createTravellingCountries(lstOpportunity [0].Id);
        List<Country__c> lstCountry = [SELECT id FROM Country__c];
        List<Where_to_go__c> lstWTG =  TestServices.createWTGRecords(lstCountry[0].Id);   
        List<Supplier__c> lstSupplier = TestServices.createSupplierRecords(lstCountry[0].Id);
        List<Group_Member__c> lstGroupMembers = TestServices.createGroupMembers(TestServices.createClientGroupRecords(2, lstOpportunity[0].Id)[0].Id, lstContact);
        TestServices.createFlightBookings(lstGroupMembers[0].Id, TestServices.createSupplierBookings(lstSupplier[0].Id, lstOpportunity[0].Id)[0].Id);
        TestServices.createHolidaySuggestions(lstSupplier[0].Id, lstOpportunity[0].Id);
        List<Itinerary_Content_Category__c> ITCRecords = TestServices.createITCRecords();
        Selected_Itinerary_Content_Category__c SICC = New Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = ITCRecords[0].Id,
            ICC_Opportunity__c = lstOpportunity[0].Id,
            ICC_Page_No__c=1);   
        insert SICC; 
        List<Holiday_Suggestions__c> HSRec = new List<Holiday_Suggestions__c>([Select id,HS_Holiday_Type__c from Holiday_Suggestions__c Where HS_Supplier__c =: lstSupplier[0].Id AND HS_Opportunity__c = :lstOpportunity[0].Id]);
        String hsId = HSRec[0].Id;
        String oppId = lstOpportunity[0].Id;
        String supplierId = lstSupplier[0].Id;
        
        TestServices.createSICCRecords(oppId, ITCRecords);  
        List<Itinerary_Text__c> lstItineraryText = new List<Itinerary_Text__c>();
        lstItineraryText.add(new Itinerary_Text__c(
            IT_Country__c = lstCountry[0].Id,
            IT_Holiday_Type__c = HSRec[0].HS_Holiday_Type__c,
            IT_Message__c = 'test',
            IT_Status__c = 'Submitted'
            
        ));   
        lstItineraryText.add(new Itinerary_Text__c(
            IT_Holiday_Type__c = HSRec[0].HS_Holiday_Type__c,
            IT_Message__c = 'test',
            IT_Status__c = 'Submitted',
            IT_Where_to_go__c = lstWTG[0].Id
            
        ));
        lstItineraryText.add(new Itinerary_Text__c(
            IT_Holiday_Type__c = HSRec[0].HS_Holiday_Type__c,
            IT_Message__c = 'test',
            IT_Status__c = 'Submitted',
            IT_Supplier__c = supplierId
            
        ));
        insert lstItineraryText;
        
        System.assertNotEquals(lstItineraryText[0].Id, null);
        //Create Target Markup
        TestServices.createTargetMarkups();
        Test.stopTest();
    }

    static testMethod void testPreviewPdfController(){
    
        Opportunity TestOpp = [SELECT Id,StageName from Opportunity Limit 1]; 
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c limit 1];
        TestOpp.O_Holiday_Type__c = ht.id;
        
        upsert TestOpp;
        system.assert(TestOpp.id != null);
         
        /** Create Supplier Booking for Car Hire', 'Int Flight'  **/
        List<Supplier__c> lstSupplier = [SELECT Id FROM Supplier__c WHERE S_Type__c = 'Hotel' Limit 1];
        String supplierId = lstSupplier[0].Id;
        String oppId = testOpp.Id;
        List<Holiday_Suggestions__c> HSRec = TestServices.createHolidaySuggestions(supplierId,  oppId);
        String hsId = HSRec[0].Id;
        
        Where_To_Go__c wtg = [SELECT Id FROM Where_To_Go__c LIMIT 1];
        List<Supplier_Booking__c> SBRec = new List<Supplier_Booking__c>();
        Map<String, String> recordTypeMap = new Map<String, String>();
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c' AND Name in ('Car Hire', 'Int Flight')]){
            recordTypeMap.put(rt.Name, rt.Id);     
        }
        SBRec.add(new Supplier_Booking__c(
            SB_Day__c = 2, SB_From_Time__c = '11:30',
            SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() +1 , 
            SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
            SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
            RecordTypeId = recordTypeMap.get('Car Hire'), SB_Notes__c = 'test',
            SB_Where_to_go__c = wtg.Id,
            SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
        );
        SBRec.add(new Supplier_Booking__c(
            SB_Day__c = 2, SB_From_Time__c = '11:30',
            SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today()+1 , 
            SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
            SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
            SB_Where_to_go__c = wtg.Id,
            RecordTypeId = recordTypeMap.get('Int Flight'), SB_Notes__c = 'test',
            SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
        );
        insert SBRec;   
        system.assert(SBRec.size()>0);
        
        ApexPages.standardController std =  new ApexPages.standardController(TestOpp);
        
        PreviewPdfController ppc = new PreviewPdfController(std);
        
        // execute all methods of PreviewPdfController
        ppc.getWhereYouWillStay();
        ppc.getWhereStay();
        ppc.getflight();
        ppc.getItineraryGlanceFlight();
        ppc.getItineraryFlightMessage();
        ppc.getItineraryFlightMessage1();
        
        system.assert(ppc.attachedFiles == null) ;
         
        TestOpp.StageName = 'Booking Optional';
        upsert TestOpp;
        ppc.getItineraryFlightBookedMessage();
        ppc.getItineraryFlightBookedMessage1();
        List<Supplier_Booking__c> sbcLst =  ppc.getItineraryGlanceAccommodation();
        
        system.assert(sbcLst != null);
        system.assert(ppc.lstSelectedItinerary == null);
        system.assert(ppc.lstStr == null);
        system.assert(ppc.attachedMap == null);
        system.assert(ppc.attachedUserPhoto == null);
        system.assert(ppc.lstDetailedItinerary == null);
        system.assert(ppc.lstTC == null);
        system.assert(ppc.lstTCMap == null);
        system.assert(ppc.lstTravelCountry == null);
        system.assert(ppc.lstCountry == null);
        
        
        ppc.getLogo();
        ppc.getOTUKLogo();
        ppc.getColor();
        ppc.getYourGuides();
        ppc.getAcc();
        ppc.getDetailedItinerary1();
        ppc.getGroupMembers();
         
         
    }
}
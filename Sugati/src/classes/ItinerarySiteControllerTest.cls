/**
*  @Author         :   Naval Sharma
*  @Date           :   25-Feb-2016
*  @Description    :   Test class for "ItinerarySiteController"
* 
**/

@isTest
class ItinerarySiteControllerTest{
    
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
    
    /** Test various operations of itinerary pdf  **/
    static testMethod void itineraryPDFTest1(){
        
        /** Set an opportunity to render pdf **/
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItinerarySiteController TestExt =  new ItinerarySiteController(stdctrl);
        
        Test.startTest();
        TestExt.getFileId();
        TestExt.getSelectedItineraryContent();
        TestExt.getTailorDescription(); 
        TestExt.getTravellingCountry();
        TestExt.getTailorDescription1();
        TestExt.getCountryQuote();
        TestExt.getBcurrency(); 
        TestExt.getAmount();
        TestExt.getItineraryContentWhatItCost();
        TestExt.getItineraryContentPleaseDontForget();
        TestExt.getUserExpertise();
        TestExt.getUserPhoto();
        TestExt.getWhereYouWillStay();
        TestExt.getWhereStay();
        TestExt.getGroupMembers();
        TestExt.getflight(); 
        TestExt.getItineraryGlanceFlight();
        TestExt.getAcc(); 
        TestExt.getItineraryGlanceAccommodation();
        TestExt.getCostDescription();
        TestExt.getWCount(); 
        TestExt.getLogo();
        TestExt.getOTUKLogo();
        TestExt.getColorr(); 
        TestExt.getDetailedItinerary1();
        TestExt.getWhereYouWillStay();
        TestExt.getItineraryFlightBookedMessage();
        TestExt.getItineraryFlightBookedMessage1();
        TestExt.getItineraryFlightMessage();
        TestExt.getItineraryFlightMessage1();
        TestExt.getTicketsVouchers_Flights();
        TestExt.getTicketsVouchers_Accomm();
        TestExt.getTicketsVouchers_Transfer();
        TestExt.getTicketsVouchers_LocalArrange();
        TestExt.getCount_TVFlights();
        TestExt.getCount_TVAccomm();
        TestExt.getCount_TVTransfer();
        TestExt.getCount_TVLocalArrange();
        TestExt.getTodayDate();
        TestExt.getConfirmLetter_CountTravelCountry();
        TestExt.getConfirmLetter_TravelCountry();
        TestExt.getConfirmLetterPleaseDontForget();
        TestExt.getEmergencyDetail();
        TestExt.getUserSign();
        TestExt.getInvoiceAddress();
        //TestExt.savePDF();
        TestExt.getUserDet();
        System.assertNotEquals(TestExt.Opp.Id, null);
        Test.stopTest();
    }
    
    /** Test various operations of itinerary pdf  **/
    static testMethod void itineraryPDFTest2(){
        
        /** Set an opportunity to render pdf **/
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItinerarySiteController TestExt =  new ItinerarySiteController(stdctrl);
        
        Test.startTest();
        
        Test.stopTest();
    }
    
 
    
    static testMethod void testSupplierBookings(){
        Test.startTest();
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItinerarySiteController TestExt =  new ItinerarySiteController(stdctrl);
       
        List<Supplier__c> lstSupplier = [SELECT Id FROM Supplier__c limit 1];
        String supplierId = lstSupplier[0].Id;
        String oppId = testOpp.Id;
        List<Holiday_Suggestions__c> HSRec = new List<Holiday_Suggestions__c>([Select id from Holiday_Suggestions__c Where HS_Supplier__c =: supplierId AND HS_Opportunity__c = :oppId]);
        String hsId = HSRec[0].Id;

        
        List<Supplier_Booking__c> SBRec = new List<Supplier_Booking__c>();
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c' AND Name in ('Accommodation', 'Car Hire', 'Transfer', 'Rail', 'Bulk Cost', 'Private Road Transfer', 'Ferry', 'Meet & Greet', 'Private Jet', 'Sea Plane')]){
             SBRec.add(new Supplier_Booking__c(SB_Day__c = 2, SB_From_Time__c = '11:30',
                SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() , 
                SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
                SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
                RecordTypeId = rt.Id,
                SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
              );
        }
        insert SBRec;    
        System.assertNotEquals(SBRec[0].Id, null);
        TestExt.getSupplierBookings();
        TestExt.getItineraryGlanceFlight();
        Test.stopTest();
    }
    
    
    /**** New Test Method *****/
    static testMethod void testCountryQuotes(){
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, O_Departure_Date__c, CloseDate, O_Return_Date__c from Opportunity Limit 1];   
        Country__c con = [SELECT id FROM Country__c LIMIT 1];
        Margin__c margin = new Margin__c(
            M_Travel_From__c = TestOpp.O_Departure_Date__c.addDays(-10), 
            M_Book_From__c = TestOpp.CloseDate.addDays(-10), 
            M_Travel_To__c = TestOpp.O_Return_Date__c.addDays(-10), 
            M_Book_To__c = TestOpp.CloseDate.addDays(10),
            M_Margin__c = 20,
            M_Country__c = con.Id
        );
        insert margin;
        TestOpp.O_Suggested_Margin__c = margin.Id;
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItinerarySiteController TestExt =  new ItinerarySiteController(stdctrl);
       
        List<Supplier__c> lstSupplier = [SELECT Id FROM Supplier__c WHERE S_Type__c = 'Hotel' Limit 1];
        String supplierId = lstSupplier[0].Id;
        String oppId = testOpp.Id;
        List<Holiday_Suggestions__c> HSRec = TestServices.createHolidaySuggestions(supplierId,  oppId);
        String hsId = HSRec[0].Id;
        
        Where_To_Go__c wtg = [SELECT Id FROM Where_To_Go__c LIMIT 1];
        List<Supplier_Booking__c> SBRec = new List<Supplier_Booking__c>();
        Map<String, String> recordTypeMap = new Map<String, String>();
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c' AND Name in ('Car Hire', 'Transfer', 'Int Flight')]){
            recordTypeMap.put(rt.Name, rt.Id);     
        }
        SBRec.add(new Supplier_Booking__c(
            SB_Day__c = 2, SB_From_Time__c = '11:30',
            SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() , 
            SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
            SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
            RecordTypeId = recordTypeMap.get('Car Hire'), SB_Notes__c = 'test',
            SB_Where_to_go__c = wtg.Id,
            SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
        );
        SBRec.add(new Supplier_Booking__c(
            SB_Day__c = 2, SB_From_Time__c = '11:30',
            SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() , 
            SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
            SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
            SB_Where_to_go__c = wtg.Id,
            RecordTypeId = recordTypeMap.get('Int Flight'), SB_Notes__c = 'test',
            SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
        );
        insert SBRec; 
        String clientGroupId = [SELECT id FROM Client_Group__c limit 1].Id;
        List<Supplier_Cost__c> SCRec = new List<Supplier_Cost__c>
        {
          new Supplier_Cost__c(SC_Client_Group__c = clientGroupId, 
            SC_Supplier_Booking__c = SBRec[0].Id, 
            SC_Supplier_Currency__c = 'GBP',
            SC_Total_Client_Group_Cost__c = 100,
            SC_Description__c = 'test',
            SC_Total_Net_CostSC__c = 100,
            SC_Margin__c = 2,
            SC_Option__c = 'Option 2') ,
            
          new Supplier_Cost__c(SC_Client_Group__c = clientGroupId, 
            SC_Supplier_Booking__c = SBRec[1].Id, 
            SC_Supplier_Currency__c = 'GBP',
            SC_Description__c = 'test',
            SC_Total_Client_Group_Cost__c = 100,
            SC_Total_Net_CostSC__c = 100,
            SC_Margin__c = 2,
            SC_Option__c = 'Option 2')
        };   
        insert SCRec;
        System.assertNotEquals(SCRec[0].Id, null);
        TestExt.getCountryQuote();
        TestExt.getExtraQuote();
        TestExt.getFinalDocsPleaseDontForget();
        TestExt.getSBookings();
        TestExt.getSBQuote();
        TestExt.getColor();
        TestExt.getCountryQuote();
        ItinerarySiteController.DetailItinerary di = new ItinerarySiteController.DetailItinerary();
        TestExt.comment = 'test';
        TestExt.saveComment();
        TestExt.getItineraryGlanceFlight();
        System.assertEquals('You don\'t have the permission to comment on this trip proposal. If you are travelling on this trip, please get in touch with the Sales Consultant so that you can collborate online.', TestExt.saveMsg);
        TestExt.emailAdd = 'test@test.com';
        TestExt.saveComment();
        System.assertEquals('Thanks for your comment.', TestExt.saveMsg);
        TestExt.C_Forget_TravelCountry = new Set<String>();
        TestExt.C_TravelCountry = new Set<String>();
        TestExt.Final_Forget_TravelCountry  = new Set<String>();
        TestExt.Final_TravelCountry = new Set<String>();
        System.assertEquals(TestExt.attachedFiles, Null);
        System.assertEquals(TestExt.lstStr, Null);
        System.assertEquals(TestExt.attachedMap, Null);
        System.assertEquals(TestExt.attachedLogo, Null);
        System.assertEquals(TestExt.attachedUserPhoto, Null);
        System.assertEquals(TestExt.lstGroupMember, Null);
        System.assertEquals(TestExt.lstDetailedItinerary, Null);
        System.assertEquals(TestExt.lstTC, Null);
        System.assertEquals(TestExt.lstTCMap, Null);
        System.assertEquals(TestExt.UserfullPhoto, Null);
        System.assertEquals(TestExt.UserSmallPhoto, Null);
        System.assertEquals(TestExt.CoverImg, Null);
        System.assertEquals(TestExt.MapImg, Null);
        System.assertEquals(TestExt.pageLogo, Null);
        System.assertEquals(TestExt.accommodationsNames, Null);
        System.assertEquals(TestExt.travelcountry, Null);
        System.assertEquals(TestExt.lstCountry, Null);
        ItinerarySiteController.SupplierBookingsWrapper sbw = new ItinerarySiteController.SupplierBookingsWrapper();
        Test.stopTest();
    }
}
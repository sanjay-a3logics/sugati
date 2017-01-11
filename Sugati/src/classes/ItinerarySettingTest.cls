/**
 *  @Author         :   Naval Sharma
 *  @Date           :   23-Feb-2016
 *  @Description    :   Test class for "ItinerarySetting"
 * 
 **/
 
@isTest
class ItinerarySettingTest{

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
            IT_Holiday_Type__c = HSRec[0].HS_Holiday_Type__c,
            IT_Message__c = 'test',
            IT_Status__c = 'Submitted',
            IT_Supplier__c = supplierId
        ));
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
        
        insert lstItineraryText;
        
        System.assertNotEquals(lstItineraryText[0].Id, null);
        //Create Target Markup
        TestServices.createTargetMarkups();
       
        Where_To_Go__c wtg = [SELECT Id FROM Where_To_Go__c LIMIT 1];
        List<Supplier_Booking__c> SBRec = new List<Supplier_Booking__c>();
        Map<String, String> recordTypeMap = new Map<String, String>();
        
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c' AND Name in ('Accommodation', 'Car Hire', 'Int Flight')]){
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
        SBRec.add(new Supplier_Booking__c(
            SB_Day__c = 2, SB_From_Time__c = '11:30',
            SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() , 
            SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
            SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
            SB_Where_to_go__c = wtg.Id,
            RecordTypeId = recordTypeMap.get('Accommodation'), SB_Notes__c = 'test',
            SB_Itinerary_Description__c = 'test',
            SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )
        );
        insert SBRec; 
        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment.add(new Attachment(body = Blob.valueOf('test1'), Name = 'coverImage', parentId = SBRec[0].Id));
        lstAttachment.add(new Attachment(body = Blob.valueOf('test2'), Name = 'coverImage', parentId = SBRec[1].Id));
        lstAttachment.add(new Attachment(body = Blob.valueOf('test3'), Name = 'coverImage', parentId = SBRec[2].Id));
        lstAttachment.add(new Attachment(body = Blob.valueOf('test4'), Name = 'map', parentId = SBRec[2].Id));
        insert lstAttachment;
        
        List<SupplierBookingImage__c> lstSBImages = new List<SupplierBookingImage__c>();
        lstSBImages.add(new SupplierBookingImage__c(SBI_Attachement_Id__c = lstAttachment[0].Id, SBI_Order__c = 1, SBI_Supplier_Booking__c = SBRec[0].Id));
        lstSBImages.add(new SupplierBookingImage__c(SBI_Attachement_Id__c = lstAttachment[1].Id, SBI_Order__c = 1, SBI_Supplier_Booking__c = SBRec[1].Id));
        lstSBImages.add(new SupplierBookingImage__c(SBI_Attachement_Id__c = lstAttachment[2].Id, SBI_Order__c = 1, SBI_Supplier_Booking__c = SBRec[2].Id));
        lstSBImages.add(new SupplierBookingImage__c(SBI_Attachement_Id__c = lstAttachment[3].Id, SBI_Order__c = 2, SBI_Supplier_Booking__c = SBRec[2].Id));
        insert lstSBImages;
        
        Test.stopTest();
    }
    
    /** Test various operations of ItinerarySetting  **/
    static testMethod void itinerarySettingTest1(){
        
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];  
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        update TestOpp;
        
        List<Client_Group__c> lstClientGroups = [SELECT Id FROM Client_Group__c];
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        ItinerarySetting TestExt =  new ItinerarySetting(stdctrl);
        ApexPages.currentPage().getParameters().put('id', TestOpp.Id);
        TestExt.lstSupp = TestExt.getData();
        System.assertNotEquals('', TestExt.lstSupp);
        TestExt.getDataStay();
        TestExt.saveSB();
        TestExt.getRecordType();
        Supplier_Booking__c sbStay = [SELECT id FROM Supplier_Booking__c WHERE RecordType.Name = 'Accommodation' AND SB_Opportunity__c = :TestOpp.Id Limit 1];
        List<SupplierBookingImage__c> SBImagesStay = [SELECT Id, SBI_Attachement_Id__c, SBI_Order__c,SBI_Supplier_Booking__c FROM SupplierBookingImage__c WHERE SBI_Supplier_Booking__c =: sbStay.Id];
        ItinerarySetting.saveSBI('', JSON.serialize(SBImagesStay), TestOpp.Id, true);
        
        Supplier_Booking__c sbNotStay = [SELECT id FROM Supplier_Booking__c WHERE RecordType.Name = 'Int Flight' AND SB_Opportunity__c = :TestOpp.Id Limit 1];
        List<SupplierBookingImage__c> SBImagesNotStay = [SELECT Id, SBI_Attachement_Id__c, SBI_Order__c,SBI_Supplier_Booking__c FROM SupplierBookingImage__c WHERE SBI_Supplier_Booking__c =: sbNotStay.Id];
        ItinerarySetting.saveSBI('', JSON.serialize(SBImagesNotStay), TestOpp.Id, false);
        ItinerarySetting.saveSBI(SBImagesNotStay[0].Id, JSON.serialize(SBImagesNotStay), TestOpp.Id, false);
        
        ItinerarySetting.saveSB(TestExt.lstSupp, JSON.serialize(SBImagesNotStay), TestOpp.Id);
        ItinerarySetting.saveSBS(TestExt.lstSupp,JSON.serialize(SBImagesStay), TestExt.oppStr, TestExt.DestinationImgs, JSON.serialize(lstClientGroups));  
        System.assertEquals(0, ItinerarySetting.search(TestOpp.Id).size());
        
        
    }
}
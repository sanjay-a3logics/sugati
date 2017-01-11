/***
* @Description - Unit test class to test functionality of SupplierPaymentsController.cls
* @Author - Naval Sharma (Appcino)
* @Date - 29 Feb 2016
** */

@isTest
class SupplierPaymentsControllerTest{
    
    @testSetup
    static void createTestData(){
        
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
        List<Client_Group__c> lstClientGroups = TestServices.createClientGroupRecords(2, lstOpportunity[0].Id);
        List<Group_Member__c> lstGroupMembers = TestServices.createGroupMembers(lstClientGroups[0].Id, lstContact);
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
        TestServices.createSupplierCostRecords(supplierId, lstClientGroups[0].Id);
        TestServices.createSupplierCostPayments(supplierId, oppId);
        //Create Target Markup
        TestServices.createTargetMarkups();
        Test.stopTest();
        
    }
    
    
    /** Test various operations of itinerary pdf  **/
    static testMethod void itineraryPDFTest1(){
        
        /** Set an opportunity to render pdf **/
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Supplier__c supplier = [SELECT id from Supplier__c Limit 1];
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        TestOpp.O_Agent__c = supplier.Id;
        update TestOpp;
        Supplier_Cost_Payment__c scp = [SELECT Id FROM Supplier_Cost_Payment__c LIMIT 1];
        scp.SCP_Is_Agent__c = true;
        update scp;
        Supplier_Payment__c sp = new Supplier_Payment__c(
            SP_Bank_Account__c = 'Handles Bank Account EUR - 71697839',
            SP_Note__c = 'test',
            SP_Transferred_To_Accts__c = Date.today(),
            SB_Payment_Type__c = 'Deposit',
            SP_Payment_Date__c = Date.today(),
            SP_Paid_By__c = UserInfo.getUserId(),
            SP_Due_Date__c = Date.today()+5,
            SP_Currency__c = 'GBP',
            SP_Comment__c = 'test',
            SBP_Supplier_Cost_Currency_Value__c = scp.Id,
            SP_Authorised_by__c = 'Ysobel Greenlees',
            P_Amount__c = 200
        );
        insert sp;
        
        Supplier_Booking__c sb = [SELECT Id FROM Supplier_Booking__c Limit 1];
       
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        SupplierPaymentController spc = new SupplierPaymentController(stdctrl);
        spc.preLoadComplete();
        spc.oneByOne();
        spc.edit();
        spc.selectedRow = 1;
        spc.ChangeSupplier();
        spc.savePaymetns();
    }  
    
    
    /** Test various operations of itinerary pdf  **/
    static testMethod void itineraryPDFTest2(){
        
        /** Set an opportunity to render pdf **/
        Opportunity TestOpp = [SELECT Id from Opportunity Limit 1];   
        Supplier__c supplier = [SELECT id from Supplier__c Limit 1];
        Holiday_Type__c ht = [SELECT id from Holiday_Type__c Limit 1];
        TestOpp.O_Holiday_Type__c = ht.Id;
        TestOpp.O_Agent__c = supplier.Id;
        update TestOpp;
        Supplier_Cost_Payment__c scp = [SELECT Id FROM Supplier_Cost_Payment__c LIMIT 1];
        scp.SCP_Is_Agent__c = true;
        update scp;
        
        
        Supplier_Booking__c sb = [SELECT Id FROM Supplier_Booking__c Limit 1];
        sb.SB_Own_Arrangement__c = true;
        update sb;
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(TestOpp); 
        SupplierPaymentController spc = new SupplierPaymentController(stdctrl);
        spc.preLoadComplete();
        
    }         
}
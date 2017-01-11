/**
*  @Author         :   Naval Sharma
*  @Date           :   24-Feb-2016
*  @Description    :   Test class for "CopyOpportunity"
* 
**/
 
@isTest
Private class CopyOpportunity_Test {
    @testSetup 
    static void testSetupMethod() {
        Holiday_Type__c ht= new Holiday_Type__c(Name='testHoliday');
        insert ht ;  
        system.assert(ht.Id != null); 
        
        Account TestAcc = new Account(Name = 'TestAccount');
        insert TestAcc ;  
        system.assert(TestAcc.Id != null);  
        
        Contact cont = new Contact(Salutation='testsal',LastName='testL',FirstName='testF',email='testemail@a.com',AccountId=TestAcc.Id);
        insert cont;
        system.assert(cont.Id != null);
        
        Continent__c cn = new Continent__c(name='testcon');
        insert cn ;
        system.assert(cn.Id != null);   
        
        Country__c c= new Country__c(name='testcoun',C_Continent__c=cn.Id);
        insert c ;
        system.assert(c.Id != null);   
        
        Itinerary_Content_Category__c icc= new Itinerary_Content_Category__c(ICC_Order__c = '1', name='WHAT IT COSTS');
        Insert icc;
        system.assert(icc.Id != null); 
        
        Itinerary_Content_Category__c icc1= new Itinerary_Content_Category__c(ICC_Order__c = '1', name='CONFIRMATION LETTER');
        Insert icc1;
        system.assert(icc1.Id != null);
        Itinerary_Content_Category__c icc2= new Itinerary_Content_Category__c(ICC_Order__c = '1', name='COVER');
        Insert icc2;
        system.assert(icc2.Id != null);
        
        Where_to_go__c wr = new Where_to_go__c(Name='TestWhere',W_Country__c=c.Id,W_Holiday_Type__c=ht.Id,W_Description__c='testWhDes',W_Interest__c='Diving',
                                              W_When__c='September'); 
        insert wr;
        system.assert(wr.Id != null); 
        
        Activity__c wt = new Activity__c(Name='TestWhat',WH_Country__c=c.Id,WH_Where_to_go__c=wr.Id,
                                           WH_Holiday_Type__c=ht.Id,WH_Description__c='TestwhDesc',WH_Interest__c='Diving',
                                            WH_When__c='September') ;    
        insert wt;
        system.assert(wt.Id != null);
        
        Supplier__c s = new Supplier__c(Name='TestSup',S_Where_to_go__c=wr.Id,S_Phone__c='222344',
                                     S_Description__c='TestsupDes',S_What_to_do__c=wt.Id);
        insert s;
        system.assert(s.Id != null); 
        
        Itinerary_Content__c ic = new Itinerary_Content__c(IC_ConfirmationLetter__c = true, IC_Country__c = c.id, IC_Description__c='', IC_FinalDoc__c = false,
                                    IC_Itinerary__c = true, IC_Itinerary_Content_Category__c = icc.Id, IC_New_Page__c = true, IC_Order__c = '1',IC_Page__c =  1,
                                        IC_Small_Font__c = true, IC_Supplier__c = s.Id, IC_Title__c = '', IC_User__c = UserInfo.getuserId() );
                        
        insert ic;
        system.assert(ic.Id != null); 
        
        
        Opportunity opp =  new Opportunity (AccountId = TestAcc.Id,StageName = 'Enquiry',name = 'TestOpportunity',CloseDate = Date.today(),O_Departure_Date__c = Date.today(),O_Return_Date__c = Date.today());
        insert opp;
        system.assert(opp.Id != null);
        
        
        
        Travelling_Country__c tc = new Travelling_Country__c(TC_Opportunity__c=opp.Id,TC_Country__c=c.Id);      
        insert tc;
        system.assert(tc.Id != null);   
        
        Site__c site = new Site__c(SiteURLAdmin__c='http://test.com', SiteURLCommunity__c='http://test.com');
        insert site;
        system.assert(site.Id != null);
        
        Client_Group__c cg = new Client_Group__c(CG_Opportunity__c=Opp.Id,Name='testClient',CG_Charity__c =200,
        CG_Arrival_Presents__c=300);
        insert cg;
        system.assert(cg.Id != null);
        
        Group_Member__c gm = new Group_Member__c(GM_Salutation__c='Lord',GM_First_Name__c='TestA',GM_Last_Name__c='TestAA',
                GM_Opportunity__c=Opp.Id, GM_Client_Group__c=cg.id,GM_Lead_Passenger__c =true, GM_Contact__c = cont.Id); 
        Insert gm;
        system.assert(gm.Id != null); 
        
        Holiday_Suggestions__c hs = new Holiday_Suggestions__c(HS_Opportunity__c=opp.Id,HS_Where_to_go__c=wr.Id,  HS_Order__c = 1);
        insert hs;       
        system.assert(hs.Id != null);  
        
        Holiday_Suggestions__c hs1 = new Holiday_Suggestions__c(HS_Opportunity__c=opp.Id,HS_What_to_do__c =wt.Id, HS_Order__c = 2);
        insert hs1;       
        system.assert(hs1.Id != null); 
        
        Attachment att = new Attachment(ParentId=hs.HS_Where_to_go__c,Name='TestAtt',Body=Blob.valueOf('TestBody'));
        insert att;
        system.assert(att.Id != null);
        
        Supplier_Booking__c sb = new Supplier_Booking__c(SB_Day__c=2,SB_From_Time__c='11:30',
                    SB_From_Date__c=Date.today(), SB_To_Date__c=Date.today() , SB_From_Place__c='TestLondon' ,SB_To_Time__c='16:30',
                    SB_To_Place__c='TestItaly',SB_Holiday_Suggestion__c=hs.Id,SB_Opportunity__c=opp.Id,SB_Supplier__c=s.Id );
        insert sb;
        system.assert(sb.Id != null); 
        Flight_Booking__c fb = new Flight_Booking__c(FB_Group_Member__c = gm.Id, FB_Supplier_Booking__c = sb.Id);
        insert fb;
        system.assert(fb.Id != null); 
        
        SupplierBookingImage__c ssb = new SupplierBookingImage__c(
            SBI_Supplier_Booking__c = sb.Id, 
            SBI_Attachement_Id__c = att.Id, 
            SBI_Order__c = 1);
        insert ssb;
        system.assert(ssb.Id != null); 
        
        Holiday_Question__c hq = new Holiday_Question__c(HQ_Answer__c='Hans',HQ_Opportunity__c=opp.Id,HQ_Order__c='1');
        insert hq;
        system.assert(hq.Id!=null); 
    }  
    
    /** Test various operations of CopyOpportunityController **/
    Private Static testMethod void TestCopyOpp1(){
        List<Opportunity> opp = [Select ID, O_RecordType__c from Opportunity];
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp[0]);
        ApexPages.currentPage().getParameters().put('oppid',opp[0].id);  
        CopyOpportunity TestExt =  new CopyOpportunity(stdctrl);
        TestExt.objCon.AccountId = [SELECT Id from Account limit 1].Id;
        Test.startTest();
        TestExt.getContacts();
        TestExt.lstWrapperAdd[0].isLead = true;
        TestExt.clientGorupMapping();
        TestExt.SelectedPax = '4';
        TestExt.DoCreate();
        TestExt.OpportunityType = 'same Client';
        TestExt.saveContact();
        TestExt.OpportunityType = '';
        TestExt.saveContact();
        TestExt.DoCopy();
        TestExt.getAllOpportunity();
        TestExt.saveOpp();
        List<Opportunity> lstOpp = [Select ID, O_RecordType__c from Opportunity];
        Test.stopTest();
        System.assert(lstOpp.size() >= 2);
    }
    
    /** Test various operations of CopyOpportunityController **/
    Private Static testMethod void TestCopyOpp2(){
        List<Opportunity> opp = [Select ID, O_RecordType__c from Opportunity];
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp[0]);
        ApexPages.currentPage().getParameters().put('oppid', opp[0].id);  
        CopyOpportunity TestExt =  new CopyOpportunity(stdctrl);
        TestExt.objCon.AccountId = [SELECT Id from Account limit 1].Id;
        Supplier__c supplier = [SELECT id FROM Supplier__c limit 1];
        Client_Group__c clientGroup = [SELECT id FROM Client_Group__c limit 1];
        TestServices.createSupplierBookings(supplier.Id, opp[0].id);
        TestServices.createExchangeRateRecords();
        TestServices.createSICCRecords(opp[0].Id, null);
        TestServices.createSupplierCostRecords(supplier.Id, clientGroup.Id);
        Test.startTest();
        TestExt.getContacts();
        TestExt.lstWrapperAdd[0].isLead = true;
        TestExt.clientGorupMapping();
        TestExt.SelectedPax = '4';
        TestExt.DoCreate();
        TestExt.OpportunityType = 'same Client';
        TestExt.saveContact();
        TestExt.OpportunityType = '';
        TestExt.saveContact();
        TestExt.DoCopy();
        TestExt.getAllOpportunity();
        TestExt.saveOpp();
        Test.stopTest();
    }
}
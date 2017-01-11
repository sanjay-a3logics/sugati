/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "HolidayEnquiryController"
* 
**/
 
@isTest
public class  HolidayEnquiryControllerTest {

    /** Create test data for executing test cases  **/
    @testSetup
    static void createTestData(){
        
        Opportunity opp = TestServices.createOpportunityRecords(1, null)[0];
        Account acc = [SELECT Id FROM Account Limit 1];
        List<Contact> contacts = TestServices.createContactRecords(4, acc.Id);
        List<Travelling_Country__c> travellingCountries = TestServices.createTravellingCountries(opp.Id);
        List<Supplier__c> supplierRecords = TestServices.createSupplierRecords(travellingCountries[0].TC_Country__c);
        List<Supplier_Booking__c> supplierBookingRecords = TestServices.createSupplierBookings(supplierRecords[1].Id, opp.Id);
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        TestServices.createSupplierCostRecords(supplierRecords[0].Id, clientGroups[0].Id);
        List<Group_Member__c>  groupMembers = TestServices.createGroupMembers(clientGroups[0].Id, new List<Contact>{contacts[0], contacts[1]});
        groupMembers.addAll(TestServices.createGroupMembers(clientGroups[1].Id, new List<Contact>{contacts[2], contacts[3]}));
        List<Where_to_go__c> WTGRecords = TestServices.createWTGRecords(travellingCountries[0].TC_Country__c);
        Campaign camp = new Campaign(Name = 'test', IsActive = true);
        insert camp;
        TestServices.createQuestions();
        TestServices.createHolidaySuggestions(supplierRecords[0].Id, Opp.Id);
        
        List<Task> tasks = new List<Task>{new Task(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            WhatId = acc.Id,
            OwnerId = UserInfo.getUserId(),
            Status='Completed'),
            
            new Task(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            WhatId = acc.Id,
            OwnerId = UserInfo.getUserId(),
            Status='In Progress'),
            
            new Task(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            WhatId = acc.Id,
            OwnerId = UserInfo.getUserId(),
            Status='Not Started')
            };
        
        insert tasks;
        
        List<Event> activities = new List<Event>{new Event(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            ActivityDateTime = DateTime.now(),
            DurationInMinutes = 120,
            WhatId = acc.Id),
            
            new Event(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            DurationInMinutes = 120,
            ActivityDateTime = DateTime.now(),
            WhatId = acc.Id),
            
            new Event(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            DurationInMinutes = 120,
            ActivityDateTime = DateTime.now(),
            WhatId = acc.Id)
            };
        
        insert activities;
    }
    
    /*** Test constructor  **/
    static testMethod void testHolidayEnquiry1(){
        
        Account acc = [SELECT Id FROM Account Limit 1];
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        HolidayEnquiryController hec = new HolidayEnquiryController();
        
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        HolidayEnquiryController hec1 = new HolidayEnquiryController();
        HolidayEnquiryController.Suggestions newSuggestion = new HolidayEnquiryController.Suggestions();
        newSuggestion.activity = null;
        newSuggestion.whereToGo = null;
        newSuggestion.hs = null;
        newSuggestion.imageId = null;
        hec.OppId = opp.Id;
    }
    
    /** Test various member methods ***/
    static testMethod void testHolidayEnquiry2(){
        
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        HolidayEnquiryController hec = new HolidayEnquiryController();

        hec.getHEPageErrorMessage();
        hec.getGroupMembersWrapperJson();
        hec.getGroupMembersWrapperJson();
    }
    
    /** Test various static methods ***/
    static testMethod void testHolidayEnquiry3(){
    
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Account acc = [SELECT Id, A_Salutation__c, A_First_Name__c, A_Last_Name__c, BillingPostalCode, A_Email__c, Phone FROM Account Limit 1];
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        Test.StartTest();
        HolidayEnquiryController.getHolidayCategories();
        HolidayEnquiryController.getAccountDetail(opp.Id);
        HolidayEnquiryController.getAccountDetail(acc.Id);
        HolidayEnquiryController.getAccountDetail(null);
        HolidayEnquiryController.getOpportunityDetail(acc.Id, opp.Id);
        HolidayEnquiryController.getOpportunityDetail(opp.Id, opp.Id);
        HolidayEnquiryController.getOpportunityDetail(null, null);
        HolidayEnquiryController.searchAccount(new Account(A_Salutation__c = 'Mr.', A_Last_Name__c = 'Test'));
        HolidayEnquiryController.searchAccount(new Account(A_Last_Name__c = 'Test', A_First_Name__c = 'Test'));
        HolidayEnquiryController.searchAccount(new Account(A_Last_Name__c = 'Test'));
        HolidayEnquiryController.searchAccount(new Account(A_Last_Name__c = 'Test', BillingPostalCode = 'Test'));
        HolidayEnquiryController.searchAccount(new Account(A_Last_Name__c = 'Test', A_Email__c = 'test@test.com'));
        HolidayEnquiryController.searchAccount(new Account(A_Last_Name__c = 'Test', Phone = '22334'));
        HolidayEnquiryController.searchAccount(acc);
        Test.StopTest();
    }
    
    /** Test various static methods ***/
    static testMethod void testHolidayEnquiry4(){
        
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Account acc = [SELECT Id, A_Salutation__c, A_First_Name__c, A_Last_Name__c, BillingPostalCode, A_Email__c, Phone FROM Account Limit 1];
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        Test.StartTest();
        
        HolidayEnquiryController.saveAddress(new Account(A_Last_Name__c = 'Test'), 'true');
        HolidayEnquiryController.saveAddress(new Account(A_First_Name__c = 'Test'), 'true');
        HolidayEnquiryController.saveAddress(new Account(A_First_Name__c = 'Test', A_Last_Name__c = 'Test'), 'true');
        HolidayEnquiryController.saveContactAddress(JSON.serialize( new Contact(FirstName = 'test', LastName = 'test')));

        Test.StopTest();
    }
    
    /** Test various static methods ***/
    static testMethod void testHolidayEnquiry5(){
        String accountId;
        String contactId;
        String oppId;
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        oppId = opp.Id;
        
        Account acc = [SELECT Id, A_Salutation__c, A_First_Name__c, A_Last_Name__c, BillingPostalCode, A_Email__c, Phone FROM Account Limit 1];
        accountId = acc.Id;
        
        Contact con = new Contact(FirstName = 'test1', LastName = 'LastName', AccountId = acc.Id);
        insert con;
        contactId = con.Id;
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        Test.StartTest();
        HolidayEnquiryController hec = new HolidayEnquiryController();

        HolidayEnquiryController.saveBroucheRequest(acc);
        acc.Id = null;
        HolidayEnquiryController.saveBroucheRequest(acc);
        
        HolidayEnquiryController.saveBroucheRequestContact(JSON.serialize(con), acc.Id);
        con.Id = null;
        HolidayEnquiryController.saveBroucheRequestContact(JSON.serialize(con), acc.Id);
        HolidayEnquiryController.getOpportunities(acc.Id);
        HolidayEnquiryController.getOpportunities(accountId);
        //HolidayEnquiryController.getOpenActivities(acc.Id);
        //HolidayEnquiryController.getActivityHistory(acc.Id);
        HolidayEnquiryController.getGroupMembres(acc, opp.Id);
        
        /** Create JSON for passing in remote action  ***/
        List<HolidayEnquiryController.GroupMembersWrapper> newGroupMembers = new List<HolidayEnquiryController.GroupMembersWrapper>();
        HolidayEnquiryController.GroupMembersWrapper newGroupMember = new HolidayEnquiryController.GroupMembersWrapper();
        Contact con1 = new Contact();
        newGroupMember.con = con;
        newGroupMember.con.Occupancy_Type__c = 'Adult';
        newGroupMember.included = true;
        newGroupMember.isLead = false;
        newGroupMembers.add(newGroupMember);
        String JSONString = JSON.serialize(newGroupMembers);
        
        System.assertNotEquals('', HolidayEnquiryController.addPax(2, JSONString, accountId));
        
        HolidayEnquiryController.Filters filter = new HolidayEnquiryController.Filters();
        List<Country__c> countries = new List<Country__c>([Select id,Name from Country__c]);
        List<Where_to_go__c> WTGRec = new List<Where_to_go__c>([Select id,Name from Where_to_go__c where W_Country__c = :countries[0].Id]);
        List<Holiday_Type__c> holidayTypes = new List<Holiday_Type__c>([SELECT id, Name from Holiday_Type__c Limit 1]);
        
        filter.countries.add(new HolidayEnquiryController.pickListValue(countries[0].Id, countries[0].Name));
        filter.whereToGo.add(WTGRec[0].Name);
        filter.holidayType = holidayTypes[0].Id;
        HolidayEnquiryController.Trees tree = HolidayEnquiryController.getSuggestions(filter, true);
        HolidayEnquiryController.getSuggestions(filter, false);
        String QuestionJSON = JSON.serialize(HolidayEnquiryController.loadAllQuestion(accountId, oppId));
        System.assertNotEquals(QuestionJSON, '');
        HolidayEnquiryController.saveQuestion(QuestionJSON, oppId, accountId, 3);
        
        List<Holiday_Suggestions__c> hs = [select Id,HS_What_to_do__c,HS_Message__c,HS_Where_to_go__c,HS_Supplier__c from Holiday_Suggestions__c where HS_Opportunity__c = :oppId];
        System.assertEquals(HolidayEnquiryController.saveSuggestionOrder(hs), null);
        
        List<HolidayEnquiryController.pickListValue> addSugg = new List<HolidayEnquiryController.pickListValue>();
        List<HolidayEnquiryController.pickListValue> removeSugg = new List<HolidayEnquiryController.pickListValue>();
        
        List<Activity__c> activities = new List<Activity__c>([Select id, Name from Activity__c]);
        if(activities.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(activities[0].Id, 'Activity__c');
            pv.Type = 'Activity__c';
            addSugg.add(pv);
        }
        
        if(WTGRec.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(WTGRec[0].Id, 'Where_to_go__c');
            pv.Type = 'Where_to_go__c';
            addSugg.add(pv);
        }
        List<Supplier__c> suppliers = new List<Supplier__c>([Select id, Name from Supplier__c]);
        if(suppliers.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(suppliers[0].Id, 'Supplier__c');
            pv.Type = 'Supplier__c';
            addSugg.add(pv);
        }
        String imageId = null;
        for(Attachment att : [Select id from Attachment]){
            imageId = att.Id;
        }
        System.assertNotEquals(HolidayEnquiryController.saveSuggestion(hs[0], imageId, addSugg, removeSugg, oppId), null);
        System.assertNotEquals(HolidayEnquiryController.saveSuggestion(hs[0], imageId, removeSugg, addSugg, oppId), null);
        HolidayEnquiryController.getCategoies(tree.catTree, tree.whereToGoTree, filter);
        HolidayEnquiryController.LoadSuggestions(tree.whereToGoTree, tree.catTree, oppId, filter.holidayType);
        
        HolidayEnquiryController.AirlineMemberShip am = new HolidayEnquiryController.AirlineMemberShip(con, 'test', 'test');
        upsert con;
        System.assertNotEquals(null, HolidayEnquiryController.saveAirlineMember(JSON.serialize(am), JSON.serialize(con)));
        Airline_membership__c amRec = [SELECT Id from Airline_membership__c Limit 1];
        HolidayEnquiryController.DeleteAirlineMember(amRec.Id, con.Id);
        String oppJSON = HolidayEnquiryController.getOpportunityDetail(oppId, oppId);
        acc.Id = accountId;
        opp.Id = oppId;
        String groupMemberJSON = HolidayEnquiryController.getGroupMembres(acc, oppId);
        HolidayEnquiryController.saveOpportunity(oppJSON, groupMemberJSON, filter.countries, acc);
        Test.StopTest();  
    }
    
    
    
     /** Test various static methods ***/
    static testMethod void testHolidayEnquiry6(){
        Test.StartTest();
        String accountId;
        String contactId;
        String oppId;
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        oppId = opp.Id;
        
        Account acc = [SELECT Id, A_Salutation__c, A_First_Name__c, A_Last_Name__c, BillingPostalCode, A_Email__c, Phone FROM Account Limit 1];
        accountId = acc.Id;
        
        Contact con = new Contact(FirstName = 'test1', LastName = 'LastName', AccountId = acc.Id);
        insert con;
        contactId = con.Id;
        
        Test.setCurrentPage(Page.HolidayEnquiry);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        HolidayEnquiryController hec = new HolidayEnquiryController();

        HolidayEnquiryController.saveBroucheRequest(acc);
        acc.Id = null;
        HolidayEnquiryController.saveBroucheRequest(acc);
        
        HolidayEnquiryController.saveBroucheRequestContact(JSON.serialize(con), acc.Id);
        con.Id = null;
        HolidayEnquiryController.saveBroucheRequestContact(JSON.serialize(con), acc.Id);
        HolidayEnquiryController.getOpportunities(acc.Id);
        HolidayEnquiryController.getOpportunities(accountId);
        //HolidayEnquiryController.getOpenActivities(acc.Id);
        //HolidayEnquiryController.getActivityHistory(acc.Id);
        HolidayEnquiryController.getGroupMembres(acc, opp.Id);
        
        /** Create JSON for passing in remote action  ***/
        List<HolidayEnquiryController.GroupMembersWrapper> newGroupMembers = new List<HolidayEnquiryController.GroupMembersWrapper>();
        HolidayEnquiryController.GroupMembersWrapper newGroupMember = new HolidayEnquiryController.GroupMembersWrapper();
        Contact con1 = new Contact();
        newGroupMember.con = con;
        newGroupMember.con.Occupancy_Type__c = 'Adult';
        newGroupMember.included = true;
        newGroupMember.isLead = false;
        newGroupMembers.add(newGroupMember);
        String JSONString = JSON.serialize(newGroupMembers);
        
        System.assertNotEquals('', HolidayEnquiryController.addPax(2, JSONString, accountId));
        
        HolidayEnquiryController.Filters filter = new HolidayEnquiryController.Filters();
        List<Country__c> countries = new List<Country__c>([Select id,Name from Country__c]);
        List<Where_to_go__c> WTGRec = new List<Where_to_go__c>([Select id,Name from Where_to_go__c where W_Country__c = :countries[0].Id]);
        List<Holiday_Type__c> holidayTypes = new List<Holiday_Type__c>([SELECT id, Name from Holiday_Type__c Limit 1]);
        
        filter.countries.add(new HolidayEnquiryController.pickListValue(countries[0].Id, countries[0].Name));
        filter.whereToGo.add(WTGRec[0].Name);
        filter.holidayType = holidayTypes[0].Id;
        HolidayEnquiryController.Trees tree = HolidayEnquiryController.getSuggestions(filter, true);
        HolidayEnquiryController.getSuggestions(filter, false);
        String QuestionJSON = JSON.serialize(HolidayEnquiryController.loadAllQuestion(accountId, oppId));
        System.assertNotEquals(QuestionJSON, '');
        HolidayEnquiryController.saveQuestion(QuestionJSON, oppId, accountId, 3);
        
        List<Holiday_Suggestions__c> hs = [select Id,HS_What_to_do__c,HS_Message__c,HS_Where_to_go__c,HS_Supplier__c from Holiday_Suggestions__c where HS_Opportunity__c = :oppId];
        System.assertEquals(HolidayEnquiryController.saveSuggestionOrder(hs), null);
        
        List<HolidayEnquiryController.pickListValue> addSugg = new List<HolidayEnquiryController.pickListValue>();
        List<HolidayEnquiryController.pickListValue> removeSugg = new List<HolidayEnquiryController.pickListValue>();
        
        List<Activity__c> activities = new List<Activity__c>([Select id, Name from Activity__c]);
        if(activities.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(activities[0].Id, 'Activity__c');
            pv.Type = 'Activity__c';
            addSugg.add(pv);
        }
        
        if(WTGRec.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(WTGRec[0].Id, 'Where_to_go__c');
            pv.Type = 'Where_to_go__c';
            addSugg.add(pv);
        }
        List<Supplier__c> suppliers = new List<Supplier__c>([Select id, Name from Supplier__c]);
        if(suppliers.size() > 0){
            HolidayEnquiryController.pickListValue pv = new HolidayEnquiryController.pickListValue(suppliers[0].Id, 'Supplier__c');
            pv.Type = 'Supplier__c';
            addSugg.add(pv);
        }
        String imageId = null;
        for(Attachment att : [Select id from Attachment]){
            imageId = att.Id;
        }
     
        Opportunity opp1 = [select id,(Select Id,OE_To_Email_Addresses__c,OE_Bcc_Email_Addresses__c,CurrencyISOCode,OE_Cc_Email_Addresses__c,OE_Email_Body__c,
                     OE_Email_Closing__c,OE_Email_Intro__c,OE_Email_Subject__c,OE_Email_Type__c from Opportunity_Emails__r where 
                     OE_Email_Type__c = 'HE Recap Email' limit 1),O_Budget__c ,O_Holiday_Enquiry_Recap_Description__c,
                     Amount, Budget_Note__c,O_Holiday_Enquiry_Stage__c , O_Budget_specify__c, O_Flexibility_Details__c, O_Follow_Up_Time__c, 
                     O_Country__c,O_Steps_Completed__c,name,O_No_of_Nights__c,O_Type_2__c,StageName,CloseDate ,CampaignID,O_Flexiable_Date__c,AccountId,O_Agent_SC__c,O_Agent__c,
                     O_Holiday_Type__c, O_Holiday_Type__r.Name, type,O_Booking_Currency__c, O_Departure_Date__c,O_Return_Date__c,O_Budget_Start_Range__c,Description,
                     O_Pax__c from Opportunity where id =: oppId Limit 1][0];
        opp1.Id = NULL;   
        opp1.Name = 'New Enquiry';          
        String oppJSON = JSON.serialize(opp1);
        acc.Id = accountId;
        opp.Id = oppId;
        String groupMemberJSON = HolidayEnquiryController.getGroupMembres(acc, oppId);
        HolidayEnquiryController.saveOpportunity(oppJSON, groupMemberJSON, filter.countries, acc);
        Communication_Preference__c cp = new Communication_Preference__c(CP_Email__c = 'test@test.com', CP_Type__c = 'Email', Id = NULL);
        Contact contactRec = [SELECT Id, AccountId FROM Contact WHERE AccountId != NULL LIMIT 1];
        System.assertNotEquals(NULL, HolidayEnquiryController.saveCommp(JSON.serialize(cp), JSON.serialize(contactRec)));
        cp = [SELECT Id FROM Communication_Preference__c Limit 1];
        System.assertNotEquals(NULL, HolidayEnquiryController.DeleteCommp(cp.Id, contactRec.Id));
        Test.StopTest();  
    }
}
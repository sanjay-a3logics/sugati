/**
 *  @Author         :   Naval Sharma
 *  @Date           :   23-Feb-2016
 *  @Description    :   Various operations to create test data for test classes 
 * 
 * */
public class TestServices {
    
    /** 
    * Method to create opportunity records
    **/
    public static List<Opportunity> createOpportunityRecords(Integer size, Account acc){
        
        /**  Enable all the triggers  **/
        createTriggerCustomSetting();
        
        List<Opportunity> lstOppRecords = new List<Opportunity>();
        List<Record_Type__c> recordTypes = [SELECT id From Record_Type__c where RT_SObject_Type__c = 'Opportunity'];
        if(recordTypes.size() == 0)
            recordTypes = createRecordTypes();
        
        if(acc == null){
            acc = new Account(
                Name = 'Test', 
                A_First_Name__c = 'Test', 
                A_Salutation__c = 'Mr.', 
                A_Last_Name__c = 'test',
                BillingPostalCode = 'Test',
                A_Email__c = 'test@test.com',
                Phone = '22334332234553'
            );
            upsert acc;
        }
        for(Integer i = 0; i < size ; i++){
            lstOppRecords.add(new Opportunity( 
                Name = 'Opportunity ' + i, 
                AccountID = acc.id, 
                StageName = 'Enquiry', 
                CloseDate = Date.today()+10,  
                Amount = 1000,  
                O_Departure_Date__c = Date.today().addDays(20),
                O_Booking_Date__c = Date.today().addDays(5),
                O_Return_Date__c = Date.today().addDays(25),
                
                CurrencyISOCode = 'GBP', 
                O_RecordType__c = recordTypes[0].Id));
        }
        
        upsert lstOppRecords;        
        return lstOppRecords;
    }
    
    /** 
    * Method to create Exchange Rate records
    **/
    public static List<Record_Type__c> createRecordTypes(){
        
        List<Record_Type__c> lstRecordTypes = new List<Record_Type__c>();    
        lstRecordTypes.add( new Record_Type__c(Name = 'ST', RT_SObject_Type__c = 'Opportunity', RT_Active__c = true)); 
        lstRecordTypes.add( new Record_Type__c(RT_SObject_Type__c = 'Task', Name = 'Brochure Request', RT_Active__c = true));
        upsert lstRecordTypes;
        
        return lstRecordTypes;
    }
    
    
    /** 
    * Method to create contact records
    **/
    public static List<Contact> createContactRecords(Integer size, String accId){
        
        List<Contact> lstContactRecords = new List<Contact>();
        if( size>0 )
            lstContactRecords.add(new Contact(LastName = 'test', FirstName = 'test1', Occupancy_Type__c = 'Adult', Birthdate = Date.today().addYears(-20), Email = 'test@test.com', AccountId = accId));
        if( size>1 )
            lstContactRecords.add(new Contact(LastName = 'test', FirstName = 'test2', Occupancy_Type__c = 'Infant', Birthdate = Date.today().addYears(-10), Email = 'test@test.com', AccountId = accId));
        if( size >2 )
            lstContactRecords.add(new Contact(LastName = 'test', FirstName = 'test3', Occupancy_Type__c = 'Child', Birthdate = Date.today().addYears(-1), Email = 'test@test.com', AccountId = accId));
        if( size >3 )
            lstContactRecords.add(new Contact(LastName = 'test', FirstName = 'test4', Occupancy_Type__c = 'Child', Email = 'test@test.com', AccountId = accId));
        if( size >4 ){
            for(Integer i = 4; i < size ; i++){
                lstContactRecords.add(new Contact(LastName = 'test', FirstName = 'test'+i, Occupancy_Type__c = 'Adult', Email = 'test@test.com', AccountId = accId));
            }    
        }
        upsert lstContactRecords; 
        return lstContactRecords;        
    }
    
    /** 
    * Method to create Client Group records
    **/
    public static List<Client_Group__c> createClientGroupRecords(Integer size, String oppId){
        
        List<Client_Group__c> lstCGRecords = new List<Client_Group__c>();
        Exchange_Rate__c exRate = TestServices.createExchangeRateRecords()[0];
        
        for(Integer i = 0; i < size ; i++){
            lstCGRecords.add(new Client_Group__c(Name = 'TestCG '+ i, CG_Exchange_Rate_GBP__c = exRate.Id, CG_Opportunity__c = oppId));
        }    
        
        upsert lstCGRecords; 
        return lstCGRecords;        
    }
    
     /** 
    * Method to create Group Member records
    **/
    public static  List<Group_Member__c> createGroupMembers(String clientGroupId, List<Contact> contacts){
        
        List<Group_Member__c> gmList = new List<Group_Member__c>();
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        for(Contact con : contacts){
             gmList.add(new Group_Member__c(GM_Salutation__c='Lord',
                 GM_First_Name__c = con.FirstName,
                 GM_Last_Name__c = con.LastName,
                 GM_Opportunity__c = Opp.Id, 
                 GM_Client_Group__c = clientGroupId,
                 GM_Lead_Passenger__c = true, 
                 GM_Contact__c = con.Id
             )); 
        }
        upsert gmList;
        
        return gmList;        
    }
    
    /** 
    * Method to create Exchange Rate records
    **/
    public static List<Exchange_Rate__c> createExchangeRateRecords(){
        
        List<Exchange_Rate__c> lstEXRecords = new List<Exchange_Rate__c>();
        lstEXRecords.add(new Exchange_Rate__c(
            ER_Exchange_Rate__c = 1.2, 
            ER_Base_Currency__c = 'GBP', 
            ER_Sales_Currency__c= 'GBP', 
            ER_Travel_From__c = Date.today().addYears(-1), 
            ER_Book_From__c = Date.today().addYears(-1), 
            ER_Travel_To__c = Date.today().addYears(1), 
            ER_Book_To__c = Date.today().addYears(1)
        ));
        
        upsert lstEXRecords; 
        return lstEXRecords;        
    }
    
    /** 
    * Method to create Trigger Custom setting record
    **/
    public static Trigger_Setting__c createTriggerCustomSetting(){
        List<Trigger_Setting__c> customSettings = [SELECT id FROM Trigger_Setting__c];
        if( customSettings.size() > 0) 
            return customSettings[0];
                  
        Trigger_Setting__c ts = new Trigger_Setting__c();
        ts.Group_MembersTrigger__c = true;
        ts.Opportunity_Trigger__c = true;
        ts.Supplier_Booking_Trigger__c = true;
        ts.Supplier_Cost_Trigger__c = true;   
        ts.Travelling_Country_Trigger__c = true;   
        upsert ts; 
        
        return ts;        
    }
    
    /** 
    * Method to create Site Custom setting record
    **/
    public static Site__c createSiteCustomSetting(){
        
        Site__c site = new Site__c();
        site.Run_Trigger__c = true;
        site.SiteURLAdmin__c = 'test.com/';
        site.SiteURLCommunity__c = 'test.com/';
        upsert site; 
        
        return site;        
    }
    
    /** 
    * Method to create Country records
    **/
    public static List<Country__c> createCountryRecords(){
        
        Continent__c continent = new Continent__c(Name = 'Asia', R_Client_Notes__c = 'Test', R_Our_Opinion__c = 'Test', R_Quote__c = 'Test', R_Region_Code__c = 'Test', R_Sales_Tips__c = 'Test');
        upsert continent;
        
        List<Country__c> lstCountries = new List<Country__c>();
        lstCountries.add(new Country__c( Name = 'India', C_Continent__c = continent.Id, C_Margin__c = 2));
        lstCountries.add(new Country__c( Name = 'Sri Lanka', C_Continent__c = continent.Id));
        lstCountries.add(new Country__c( Name = 'Italy', C_Continent__c = continent.Id));
        upsert lstCountries; 
        
        Attachment att = new Attachment(body = Blob.valueOf('test'), Name = 'coverImage', parentId = lstCountries[0].Id);
        upsert att;
        
        return lstCountries;       
    }
    
    /** 
    * Method to create Travelling Countries records
    **/
    public static List<Travelling_Country__c> createTravellingCountries(String oppId){
        
        Continent__c continent = new Continent__c(Name = 'Asia', R_Client_Notes__c = 'Test', R_Our_Opinion__c = 'Test', R_Quote__c = 'Test', R_Region_Code__c = 'Test', R_Sales_Tips__c = 'Test');
        upsert continent;
        
        List<Country__c> lstCountries = new List<Country__c>();
        lstCountries.add(new Country__c( Name = 'India', C_Continent__c = continent.Id, C_Margin__c = 2));
        lstCountries.add(new Country__c( Name = 'Sri Lanka', C_Continent__c = continent.Id));
        lstCountries.add(new Country__c( Name = 'Italy', C_Continent__c = continent.Id));
        upsert lstCountries; 
        
        Attachment att = new Attachment(body = Blob.valueOf('test'), Name = 'coverImage', parentId = lstCountries[0].Id);
        upsert att;
        
        List<Travelling_Country__c> travellingCountries = new List<Travelling_Country__c>();
        for(Country__c country : lstCountries){
            travellingCountries.add( new Travelling_Country__c( TC_Country__c = country.Id, TC_Opportunity__c = oppId ) );
        }
        upsert travellingCountries;
        
        return travellingCountries;       
    }
    
    
    /**
    * Method to create Where To Go Records
    **/
    public static List<Where_to_go__c> createWTGRecords(String countryId){

        List<Holiday_Type__c> holidayTypes = new List<Holiday_Type__c>([SELECT id from Holiday_Type__c Limit 1]);
        
        if(holidayTypes.size() == 0){
            holidayTypes.add(new Holiday_Type__c(Name='Generic', HT_HE__c = true));
            upsert holidayTypes;
        }
        
        List<Where_to_go__c> WTGRec = [SELECT name from Where_to_go__c Where Name = :'test'];
        if(WTGRec.size() == 0){
            WTGRec = new List<Where_to_go__c>();
            WTGRec.add(new Where_to_go__c(Name = 'test', W_Holiday_Type__c =  holidayTypes[0].Id, W_Country__c = countryId, W_Description__c = 'Test', W_Interest__c='Diving', W_When__c= System.now().format('MMMM')));
            WTGRec.add(new Where_to_go__c(Name = 'test1', W_Holiday_Type__c =  holidayTypes[0].Id, W_Country__c = countryId, W_Description__c = 'Test1', W_Interest__c='Diving', W_When__c= System.now().format('MMMM'), W_Archive__c = false));
            WTGRec.add(new Where_to_go__c(Name = 'test2', W_Country__c = countryId, W_Description__c = 'Test2', W_Interest__c='Diving', W_When__c= System.now().format('MMMM'), W_Archive__c = false));
            upsert WTGRec;
        }
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf('test');
        attachment.Name = 'cover';
        attachment.ParentId = WTGRec[0].id;
        upsert attachment;
        
        return WTGRec;
    }
    
    
    /**
    * Method to create Suppliers
    **/
    public static List<Supplier__c> createSupplierRecords(String countryId){
        
        List<Where_to_go__c> WTGRec = new List<Where_to_go__c>([Select id from Where_to_go__c where W_Country__c = :countryId]);
        
        if(WTGRec.size() == 0)
            WTGRec = createWTGRecords(countryId);
       
        List<Supplier__c> suppliersRec = new List<Supplier__c>();
        suppliersRec.add(new Supplier__c(Name='TestSup', S_Where_to_go__c = WTGRec[0].Id, S_Archive__c = false, S_Type__c = 'Accommodation', S_Emergency_Phone__c = '123432', S_Emergency_Phone_2__c = '2345456', S_Billing_Currency__c = 'GBP'));
        suppliersRec.add(new Supplier__c(Name='test', S_Where_to_go__c = WTGRec[0].Id, S_Archive__c = false, S_Type__c = 'Hotel', S_Emergency_Phone__c = '123432', S_Emergency_Phone_2__c = '2345456', S_Billing_Currency__c = 'GBP'));
        upsert suppliersRec;
         
        return suppliersRec;
    }
    
    /**
    * Method to create Holiday Suggestion Record
    **/
    public static List<Holiday_Suggestions__c> createHolidaySuggestions(String supplierId, String oppId){
        
        List<Holiday_Type__c> holidayTypes = new List<Holiday_Type__c>([SELECT id from Holiday_Type__c Limit 1]);
        if(holidayTypes.size() == 0){
            holidayTypes.add(new Holiday_Type__c(Name='Generic'));
            upsert holidayTypes;
        }

        List<Country__c> countries = new List<Country__c>([Select id, Name from Country__c]);
        if(countries.size() > 0){
            countries = createCountryRecords();  
        }   
        
        String whereToGo = null;
        List<Where_to_go__c> WTGRec = new List<Where_to_go__c>([Select id, Name from Where_to_go__c where W_Country__c = :countries[0].Id]);
        if(WTGRec.size() > 0)
            whereToGo = WTGRec[0].Id;     
        Activity__c activity = new Activity__c(Name = 'test', WH_Holiday_Type__c = holidayTypes[0].Id, WH_Description__c = 'Test', WH_Where_to_go__c = whereToGo, WH_Country__c = countries[0].Id, WH_Archive__c= false);
        upsert activity;
        
        List<Holiday_Suggestions__c> HSRec = new List<Holiday_Suggestions__c>();
        HSRec.add(new Holiday_Suggestions__c(HS_Supplier__c = supplierId, HS_Opportunity__c = oppId, HS_What_to_do__c = activity.Id, HS_Message__c='TestHSMessage',HS_Order__c=1,
                                          HS_When__c = System.now().format('MMMM'), HS_Interest__c='Diving', HS_Holiday_Type__c = holidayTypes[0].ID,
                                          HS_Base_Cost__c=100, HS_Date_Time__c = Date.today(), HS_Day__c='1', HS_Pax__c='4'));
        HSRec.add(new Holiday_Suggestions__c(HS_Supplier__c = supplierId, HS_Opportunity__c = oppId, HS_Where_to_go__c = whereToGo, HS_Message__c='TestHSMessage',HS_Order__c=1,
                                          HS_When__c = System.now().format('MMMM'), HS_Interest__c='Diving', HS_Holiday_Type__c = holidayTypes[0].ID,
                                          HS_Base_Cost__c=100, HS_Date_Time__c = Date.today(), HS_Day__c='1', HS_Pax__c='4'));
        upsert HSRec;       
         
        return HSRec;
    }
    
    /**
    * Method to create Supplier Booking Records
    **/
    public static List<Supplier_Booking__c> createSupplierBookings(String supplierId, String oppId){
        
        List<Holiday_Suggestions__c> HSRec = new List<Holiday_Suggestions__c>([Select id from Holiday_Suggestions__c Where HS_Supplier__c =: supplierId AND HS_Opportunity__c = :oppId]);
        String hsId = null;
        if(!HSRec.isEmpty())
            hsId = HSRec[0].Id;
        List<RecordType> recordTypes = [SELECT Id From RecordType WHERE DeveloperName = 'Accommodation'];
        String recordTypeId = null;
        if(recordTypes.size() > 0)
            recordTypeId = recordTypes[0].Id; 
        List<Supplier_Booking__c> SBRec = new List<Supplier_Booking__c>();
        SBRec.add(new Supplier_Booking__c(SB_Day__c = 2, SB_From_Time__c = '11:30',
                    SB_From_Date__c = Date.today(), SB_To_Date__c = Date.today() , 
                    SB_From_Place__c = 'TestLondon', SB_To_Time__c = '16:30',
                    SB_To_Place__c = 'TestItaly', SB_Holiday_Suggestion__c = hsId,
                    RecordTypeId = recordTypeId,
                    SB_Opportunity__c = oppId, SB_Supplier__c = supplierId )); 
        upsert SBRec;       
        
        Attachment att = new Attachment(body = Blob.valueOf('test'), Name = 'coverImage', parentId = supplierId);
        upsert att;
        
        SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Attachement_Id__c = att.Id, SBI_Order__c = 1, SBI_Supplier_Booking__c = SBRec[0].Id);
        return SBRec;
    }
    
    /**
    * Method to create Supplier Cost Payment
    **/
    public static List<Supplier_Cost_Payment__c> createSupplierCostPayments(String supplierId, String oppId){
        
        List<Exchange_Rate__c> lstEXRate = new List<Exchange_Rate__c>([Select id from Exchange_Rate__c Limit 1]);
        if(lstEXRate.isEmpty())
            lstEXRate = createExchangeRateRecords();
            
        List<Supplier_Cost_Payment__c> SCPRec = new List<Supplier_Cost_Payment__c>();
        SCPRec.add(new Supplier_Cost_Payment__c(SCP_Exchange_Rate__c = lstEXRate[0].id, 
            SCP_Opportunity__c = oppId, 
            SCP_Is_Agent__c = false, SCP_Supplier__c = supplierId, 
            SCP_Total__c = 0.0) 
        ); 
        upsert SCPRec;       
         
        return SCPRec;
    }
    
    /**
    * Method to create Supplier Cost record
    **/
    public static List<Supplier_Cost__c> createSupplierCostRecords(String supplierId, String clientGroupId){
        
        List<Exchange_Rate__c> lstEXRate = new List<Exchange_Rate__c>([Select id from Exchange_Rate__c Limit 1]);
        if(lstEXRate.isEmpty())
            lstEXRate = createExchangeRateRecords();
        Opportunity opp = [SELECT id from Opportunity Limit 1];
        List<Supplier_Booking__c> lstSupplierBookings = [SELECT Id from Supplier_Booking__c where SB_Supplier__c = :supplierId Limit 1];    
        if(lstSupplierBookings.size() == 0)
            lstSupplierBookings = createSupplierBookings(supplierId, opp.Id); 
        List<Supplier_Cost__c> SCRec = new List<Supplier_Cost__c>();
        SCRec.add(new Supplier_Cost__c(SC_Client_Group__c = clientGroupId, 
            SC_Supplier_Booking__c = lstSupplierBookings[0].Id, 
            SC_Supplier_Currency__c = 'GBP',
            SC_Total_Client_Group_Cost__c = 100,
            SC_Total_Net_CostSC__c = 100,
            SC_Margin__c = 2,
            SC_Option__c = 'Option 1',
            SC_Exchange_Rate_Lookup__c = lstEXRate[0].Id) 
        ); 
        upsert SCRec;       
         
        return SCRec;
    }
    
    /**
    * Create Target Markup Records
    **/
    public static List<Target_Mark_Up__c> createTargetMarkups(){
        
        List<Target_Mark_Up__c> lstTargetMarkups = new List<Target_Mark_Up__c>();
        lstTargetMarkups.add(new Target_Mark_Up__c(TMU_APC__c = 2, TMU_FFP__c = 2, TMU_TOMS_APC__c = 2, TMU_TOMS_FFP__c =2 , TMU_Target_Margin__c = 2));
        upsert lstTargetMarkups;
        
        return lstTargetMarkups;
    }
    
    /**
    * Create Itinerary Content Category Records
    **/
    public static List<Itinerary_Content_Category__c> createITCRecords(){
        
        List<Itinerary_Content_Category__c> lstITCRecords = new List<Itinerary_Content_Category__c>();
        lstITCRecords.add(new Itinerary_Content_Category__c(Name = 'TICKETS AND VOUCHERS', ICC_Order__c = '1'));
        lstITCRecords.add(new Itinerary_Content_Category__c(Name = 'CONFIRMATION LETTER', ICC_Order__c = '1'));
        lstITCRecords.add(new Itinerary_Content_Category__c(Name = 'FINAL DOCS LETTER', ICC_Order__c = '1'));
        lstITCRecords.add(new Itinerary_Content_Category__c(Name = 'Tailored for you', ICC_Order__c = '1'));
        lstITCRecords.add(new Itinerary_Content_Category__c(Name = 'What it costs', ICC_Order__c = '1'));
        upsert lstITCRecords;
        
        return lstITCRecords;
    }
    
    /**
    * Create Flight Booking Records
    **/
    public static List<Flight_Booking__c> createFlightBookings(String groupMemberId, String supplierBookingId){
        
        List<Flight_Booking__c> flightBookings = new List<Flight_Booking__c>();
        flightBookings.add(new Flight_Booking__c(FB_Group_Member__c = groupMemberId, FB_Supplier_Booking__c = supplierBookingId));
        upsert flightBookings;
        
        return flightBookings;    
    }
    
    /**
    * Create Selected Itinerary Content Category records
    **/
    public static List<Selected_Itinerary_Content_Category__c> createSICCRecords(String oppId, List<Itinerary_Content_Category__c> ICCRecords){
        /* Create a record type */
        RecordType rt =  [Select Id FROM RecordType where developerName = 'Categories' Limit 1];
        
        if(ICCRecords == null)
            ICCRecords = createITCRecords();
        List<Selected_Itinerary_Content_Category__c> SICCRecords = new List<Selected_Itinerary_Content_Category__c>();
        for(Itinerary_Content_Category__c icc : ICCRecords)
            SICCRecords.add(new Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = icc.Id, ICC_Opportunity__c = oppId, SICC_message__c = 'TestMessage', SICC_message1__c = 'TestMessage'));
        upsert SICCRecords;
        
        return SICCRecords;    
    }
    
    /**
    * Create Questions & Question Categories
    **/
    public static List<HE_Question_Categories__c> createQuestions(){
        List<HE_Question_Categories__c> questionCategories = new List<HE_Question_Categories__c>();
        questionCategories.add(new HE_Question_Categories__c(Name = 'Test', QC_Active__c = true, QC_Order__c = 1));
        upsert questionCategories;
        
        List<Question__c> lstQuestion = new List<Question__c>();
        lstQuestion.add(new Question__c(Q_Ack_Question_Title__c = 'test', Is_Active__c = true, Q_Category__c = questionCategories[0].Id, Q_Options__c = 'A,B,C,D', Q_Question_Name__c = 'test', Q_Order__c = 1, Q_Related_To__c = 'Opportunity', Q_Type__c = 'Radio'));
        lstQuestion.add(new Question__c(Q_Ack_Question_Title__c = 'test1', Is_Active__c = true, Q_Category__c = questionCategories[0].Id, Q_Options__c = 'A,B,C,D', Q_Question_Name__c = 'test1', Q_Order__c = 1, Q_Related_To__c = 'Account', Q_Type__c = 'Checkbox'));
        insert lstQuestion;
        
        Account acc = [SELECT id FROM Account LIMIT 1];
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        List<Holiday_Question__c> lstPreferences = new List<Holiday_Question__c>();
        lstPreferences.add(new Holiday_Question__c(HQ_Account__c = acc.Id, HQ_Answer__c = 'A', HQ_Order__c = '1', HQ_Question__c = lstQuestion[0].Id));
        lstPreferences.add(new Holiday_Question__c(HQ_Opportunity__c = opp.Id, HQ_Answer__c = 'A,C', HQ_Order__c = '1', HQ_Question__c = lstQuestion[1].Id));
        insert lstPreferences;
        
        return questionCategories;    
    }
    
    
}
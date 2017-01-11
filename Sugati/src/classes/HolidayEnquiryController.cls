public Without Sharing Class HolidayEnquiryController extends UserEdition{
    
    public String OppId{get;set;}
    public Opportunity opp{get;set;}
    public String AccId{get;set;}
    public String TCountries{get;set;}
    public String filter{get;set;}
    public transient  String pickLists {get; set;}
    public transient  String referrer{get;set;}
    public transient  String holidayType{get;set;}
    public transient  String countries{get;set;}
    public transient  String suppliers{get;set;}
    public transient  String campaigns{get;set;}
    public transient String accountSearchfieldSet {get;set;}
    public transient String leadSearchfieldSet {get;set;}
    public transient  String airports{get;set;}
    public transient  String carriers{get;set;}
    List<pickListValue> mapAccount = new List<pickListValue>();
    List<pickListValue> mapHolidayType = new List<pickListValue>();
    List<pickListValue> mapCountries = new List<pickListValue>();
    List<pickListValue> mapSuppliers = new List<pickListValue>();
    List<pickListValue> mapCampaigns = new List<pickListValue>();
    List<pickListValue> mapAirports = new List<pickListValue>();
    public String nameSpacePrefix{get;set;}
    public String mapSecondaryAccounts{get; set;}
    public transient String autoSuggestTime{get; set;}
    
    
    public static String OpportunityId;
    
    public HolidayEnquiryController(){
        try{
            String recordId = ApexPages.currentPage().getParameters().get('id');
            TCountries = '[]';
            ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            if(recordId != null && recordId.startsWith('001')){
                AccId = recordId;
            }    
            else if(recordId != null && recordId.startsWith('006')){
                opp = [select id,AccountId,(Select Id ,TC_Country__c, TC_Country__r.Name from Travelling_Countries__r) from Opportunity where id =: recordId];
                AccId =  opp.accountId;  
                OpportunityId =  recordId;
                TCountries = '';
                List<pickListValue> lstCountries = new List<pickListValue>();
                for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                    lstCountries.add(new pickListValue(tc.TC_Country__c,tc.TC_Country__r.Name));
                }
                TCountries = JSON.serialize(lstCountries);
            }
            for(Account acc : [Select Id,Name from Account where A_First_Name__c != null order by Name]){
                mapAccount.add(new pickListValue(acc.Id,acc.Name));
            }
            for(Holiday_Type__c ht : [Select Id,Name from Holiday_Type__c where HT_HE__c = true order by Name]){
                mapHolidayType.add(new pickListValue(ht.Id,ht.Name));
            }
            for(Country__c coun : [Select Id,name from Country__c order by Name]){
                mapCountries.add(new pickListValue(coun.Id,coun.Name));
            }
            for(Supplier__c sup : [Select Id,name,S_Type__c from Supplier__c order by Name]){
                pickListValue pv = new pickListValue(sup.Id,sup.Name);
                pv.type = sup.S_Type__c;
                mapSuppliers.add(pv);
            }
            for(Campaign sup : [Select Id,name from Campaign where IsActive = true order by Name]){
                mapCampaigns.add(new pickListValue(sup.Id,sup.Name));
            }
            for(Airport__c airport : [Select ID, name from Airport__c]){
                //mapAirports.add(new pickListValue(airport.Id,airport.Name));
            }
    
            
            campaigns = JSON.serialize(mapCampaigns);
            suppliers = JSON.serialize(mapSuppliers);
            countries = JSON.serialize(mapCountries);
            holidayType = JSON.serialize(mapHolidayType);
            referrer = JSON.serialize(mapAccount);
            pickLists = JSON.serialize(describePickLists('Account,Contact,Opportunity,'+Utility.getNameSpacePrefix()+'Communication_Preference__c'));
            carriers = JSON.serialize(Utility.describePickListsStr(Utility.getNameSpacePrefix()+'Supplier_Booking__c'));
            filter = JSON.serialize(new Filters());
            accountSearchfieldSet = JSON.serialize(Utility.readFieldSet('Account').get('Sugati'));
            leadSearchfieldSet = JSON.serialize(Utility.readFieldSet('Lead').get('Sugati'));
            airports = JSON.serialize(mapAirports);
            
            
            List<pickListValue> lstTime = new List<pickListValue>();
            String strTimes = '';
            for (integer i = 0 ; i < 24; i ++) {
                for (integer j = 0 ; j < 60; j++) {
                    
                    if( i < 10) {
                        if ( j < 10) {
                            if (strTimes == '') {
                                strTimes = '0'+i +':'+ '0'+ j;
                            }
                            else {
                                strTimes += ',' + '0'+i +':'+ '0'+ j;
                            }
                        }
                        else {
                            strTimes += ',' + '0'+i +':'+  j;
                        }
                    }
                    else {
                        if ( j < 10) {
                            strTimes += ',' + i +':'+ '0'+ j;
                        }
                        else {
                            strTimes += ',' + i +':' + j ;
                        }
                        
                    }
                }
            }
            
            for(String sb : strTimes.split(',')){
                lstTime.add(new pickListValue(sb,sb));
            }
            autoSuggestTime  = JSON.serialize(lstTime);
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString());
        }
        
    } 
    
    
    
    //Fetch all the HE Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('HolidayEnquiry'));
    }
    
    //Fetch all the HS Page Messages
    public String getHSPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('HolidaySuggestion'));
    }
    
    public String getGroupMembersWrapperJson(){
        GroupMembersWrapper newGroupMember = new GroupMembersWrapper();
        Contact con = new Contact();
        newGroupMember.con = con;
        newGroupMember.con.Occupancy_Type__c = 'Adult';
        newGroupMember.included = true;
        newGroupMember.isLead = false;
        return JSON.serialize(newGroupMember);
    }
    
    Map<String, Set<pickListValue>> describePickLists(String ObjectApi_name){
        Map<String, Set<pickListValue>> pickList = new Map<String, Set<pickListValue>>();
        for(String str : ObjectApi_name.split(',')){
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(str);//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField>  field_map = sobject_describe.fields.getMap(); 
            
            for(String fieldName : field_map.keySet()){
                if(''+field_map.get(fieldName).getDescribe().getType() == 'Picklist'){
                    if(!(fieldName == 'CurrencyISOCode' && pickList.containsKey(fieldName))){
                        if(!pickList.containsKey(fieldName)){
                            pickList.put(fieldName, new Set<pickListValue>());
                            /**
                                pickListValue pkc = new pickListValue('', '-- Select --');
                                pickList.get(fieldName).add(pkc);
                            **/   
                        }
                        List<Schema.PicklistEntry> ple = field_map.get(fieldName).getDescribe().getPicklistValues();
                        for( Schema.PicklistEntry f : ple){
                            pickListValue pkc = new pickListValue(f.getValue(),f.getLabel());
                            pickList.get(fieldName).add(pkc);
                       }   
                   }
                }    
            }
        }
        return pickList;
    }
    
    
    @remoteAction
    public static List<HE_Question_Categories__c> getHolidayCategories() {
        //Do not include Question Categories if it's not active or there is no associated question 
        List<HE_Question_Categories__c> lstQC = new List<HE_Question_Categories__c>();
        for(HE_Question_Categories__c qc: [Select ID,Name, (select id from Questions__r) from HE_Question_Categories__c where QC_Active__c = true order by QC_Order__c]){
            if(qc.Questions__r.size() > 0)
                lstQC.add(qc);
        }
        return lstQC;
    }
    
    @remoteAction
    public static Account getAccountDetail(String recordId) {
        if(recordId != null && recordId.startsWith('001')){
            return [Select ID, Name, A_Salutation__c,A_ABTA_Number__c,A_Status__c,A_Total_Enquiries__c,A_Total_Bookings__c,Total_Credit_Memo__c,A_Total_Quotes__c,Total_Revenue__c,A_First_Name__c,A_Last_Name__c, BillingStreet, BillingState, BillingCity, BillingCountry, Description, A_Referrer__c,A_Middle_Name__c,A_Email__c,Phone,BillingPostalCode from 
                    Account where Id = :recordId ][0];
        } 
           
        else if(recordId != null && recordId.startsWith('006')){
            Opportunity opp = [Select Id, AccountId from Opportunity where Id = :recordId limit 1];
            return [Select ID, Name,A_Status__c,A_ABTA_Number__c,A_Total_Enquiries__c,A_Total_Bookings__c,Total_Credit_Memo__c,A_Total_Quotes__c,Total_Revenue__c, A_Salutation__c,A_First_Name__c,A_Last_Name__c, BillingStreet, BillingState, BillingCity, BillingCountry, Description, A_Referrer__c, A_Middle_Name__c, A_Email__c, Phone, BillingPostalCode from 
                    Account where Id = :opp.AccountId Limit 1][0];     
        }
        return new Account();
    }
    
    @remoteAction
    public static String getOpportunityDetail(String recordId,String oppId) {
        if(recordId != null && recordId.startsWith('001')){
            return JSON.serialize(new Opportunity(CurrencyISOCode='GBP'));
        }    
        else if((recordId != null && recordId.startsWith('006')) || (oppId != '' && oppId != null)){
            if(oppId != '' && oppId != null){
                recordId = oppId;
            }
            return JSON.serialize([select id,(Select Id,OE_To_Email_Addresses__c,OE_Bcc_Email_Addresses__c,CurrencyISOCode,OE_Cc_Email_Addresses__c,OE_Email_Body__c,
                     OE_Email_Closing__c,OE_Email_Intro__c,OE_Email_Subject__c,OE_Email_Type__c from Opportunity_Emails__r where 
                     OE_Email_Type__c = 'HE Recap Email' limit 1),O_Budget__c ,O_Holiday_Enquiry_Recap_Description__c,
                     Amount, Budget_Note__c,O_Holiday_Enquiry_Stage__c , O_Budget_specify__c, O_Flexibility_Details__c, O_Follow_Up_Time__c, 
                     O_Country__c,O_Is_Group_Booking__c,O_Maximum_Occupancy__c,O_Minimum_Occupancy__c,O_Break_Through_No__c,O_Steps_Completed__c,name,O_No_of_Nights__c,O_Type_2__c,StageName,CloseDate ,CampaignID,O_Flexiable_Date__c,AccountId,O_Agent_SC__c,O_Agent__c,
                     O_Holiday_Type__c, O_Holiday_Type__r.Name, type,O_Booking_Currency__c, O_Departure_Date__c,O_Return_Date__c,O_Budget_Start_Range__c,Description,
                     O_Pax__c from Opportunity where id =: recordId Limit 1][0]);     
        }
        return JSON.serialize(new Opportunity(CurrencyISOCode='GBP'));
    }
    
    @remoteAction
    public static LeadAndAccounts searchAccount(Account acc) {
        LeadAndAccounts lstLeadAccounts = new LeadAndAccounts();
        List<Account> searhcedAccount = new List<Account>();
        List<Lead> searhcedlead = new List<Lead>();
        
        try{        
            String condition = '';
            String conditionLead = '';
            
            if(acc.A_Salutation__c != null && acc.A_Salutation__c != ''){
                String salution = '\'%'+acc.A_Salutation__c+'%\'';
                condition += 'A_Salutation__c like '+salution+'  ';        
                conditionLead += 'Salutation like '+salution+'  ';        
            }
            
            String Name = '';
            if(acc.A_First_Name__c != null && acc.A_First_Name__c!= ''){
                String firstName = '\'%'+acc.A_First_Name__c+'%\'';
                if(condition != ''){
                    condition += ' AND A_First_Name__c like '+firstName+'  ';        
                }
                else{
                    condition += 'A_First_Name__c like '+firstName+'  ';        
                }
                Name += acc.A_First_Name__c+' ';
            }
            
            if(acc.A_Last_Name__c != null && acc.A_Last_Name__c != ''){
                String lastName = '\'%'+acc.A_Last_Name__c +'%\'';
                if(condition != ''){
                    condition += 'AND A_Last_Name__c like '+lastName+'  ';        
                }
                else{
                    condition += 'A_Last_Name__c like '+lastName+'  ';        
                }
                Name += acc.A_Last_Name__c;
            }
            
            if(Name != null && Name != ''){
                String lastName = '\'%'+Name +'%\'';
                if(conditionLead != ''){
                    conditionLead += 'AND Name like '+lastName+'  ';        
                }
                else{
                    conditionLead += 'Name like '+lastName+'  ';        
                }
            }
            
            
            
            
            
            if(acc.BillingPostalCode != null && acc.BillingPostalCode != ''){
                String postCode = '\'%'+acc.BillingPostalCode+'%\'';
                condition += 'AND BillingPostalCode like '+ postCode +'  ';        
            }
            
            if(acc.A_Email__c != null && acc.A_Email__c != ''){
                String leadE = acc.A_Email__c ;
                condition += 'AND A_Email__c = \''+leadE +'\' '; 
                conditionLead += 'AND Email = \''+leadE +'\' '; 
            }
            
            if(acc.Phone != null && acc.Phone != ''){
                String ph = '\'%'+acc.Phone+'%\'';
                condition += 'AND Phone like '+ ph +'  '; 
                conditionLead += 'AND Phone like '+ ph +'  '; 
            }
            
            if(acc.A_ABTA_Number__c != null && acc.A_ABTA_Number__c != ''){
                String salution = '\'%'+acc.A_ABTA_Number__c +'%\'';
                if(condition == ''){
                    condition += ' (Name like '+salution+' OR A_ABTA_Number__c like '+salution+') ';        
                }
                else{
                    condition += 'AND (Name like '+salution+' OR A_ABTA_Number__c like '+salution+') ';        
                }
                if(conditionLead == ''){
                    conditionLead += ' Name like '+salution+' ';
                }
                else{
                    conditionLead += ' AND Name like '+salution+' ';
                }
            }
            
            
            Set<String> fieldNames = new Set<String>();
            for(Schema.FieldSetMember fs : Utility.readFieldSet('Account').get('Sugati')){
                String fieldName = fs.fieldPath;
                fieldNames.add(fieldName.toLowerCase());   
            }
            searhcedAccount = Utility.getAccounts(fieldNames, condition+' limit 1000').values();
            
            //Search Lead
            Set<String> leadFieldNames = new Set<String>();
            for(Schema.FieldSetMember fs : Utility.readFieldSet('Lead').get('Sugati')){
                String fieldName = fs.fieldPath;
                leadFieldNames .add(fieldName.toLowerCase());   
            }
            searhcedLead = Utility.getLeads(leadFieldNames, conditionLead+' and isConverted = false limit 1000').values();
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '******' +e.getMessage() + '******' +e.getStackTraceString());    
        }
        lstLeadAccounts.lstAccounts = searhcedAccount;
        lstLeadAccounts.lstLeads = searhcedlead;
        return lstLeadAccounts;
    }
    
    @remoteAction
    public static LeadAndAccounts searchSecAccount(Account acc) {
        LeadAndAccounts lstLeadAccounts = new LeadAndAccounts();
        List<Account> searhcedAccount = new List<Account>();
        List<Lead> searhcedlead = new List<Lead>();
        
        try{        
            String condition = '';
            String conditionLead = '';
            
            if(acc.A_Salutation__c != null && acc.A_Salutation__c != ''){
                String salution = '\'%'+acc.A_Salutation__c+'%\'';
                condition += 'A_Salutation__c like '+salution+'  ';        
            }
            
            String Name = '';
            if(acc.A_First_Name__c != null && acc.A_First_Name__c!= ''){
                String firstName = '\'%'+acc.A_First_Name__c+'%\'';
                if(condition != ''){
                    condition += ' AND A_First_Name__c like '+firstName+'  ';        
                }
                else{
                    condition += 'A_First_Name__c like '+firstName+'  ';        
                }
                Name += acc.A_First_Name__c+' ';
            }
            
            if(acc.A_Last_Name__c != null && acc.A_Last_Name__c != ''){
                String lastName = '\'%'+acc.A_Last_Name__c +'%\'';
                if(condition != ''){
                    condition += 'AND A_Last_Name__c like '+lastName+'  ';        
                }
                else{
                    condition += 'A_Last_Name__c like '+lastName+'  ';        
                }
                Name += acc.A_Last_Name__c;
            }
            
            
            if(acc.BillingPostalCode != null && acc.BillingPostalCode != ''){
                String postCode = '\'%'+acc.BillingPostalCode+'%\'';
                condition += 'AND BillingPostalCode like '+ postCode +'  ';        
            }
            
            if(acc.A_Email__c != null && acc.A_Email__c != ''){
                String leadE = acc.A_Email__c ;
                condition += 'AND A_Email__c = \''+leadE +'\' '; 
            }
            
            if(acc.Phone != null && acc.Phone != ''){
                String ph = '\'%'+acc.Phone+'%\'';
                condition += 'AND Phone like '+ ph +'  '; 
            }
            
            if(acc.A_ABTA_Number__c != null && acc.A_ABTA_Number__c != ''){
                String salution = '\'%'+acc.A_ABTA_Number__c +'%\'';
                if(condition == ''){
                    condition += ' (Name like '+salution+' OR A_ABTA_Number__c like '+salution+') ';        
                }
                else{
                    condition += 'AND (Name like '+salution+' OR A_ABTA_Number__c like '+salution+') ';        
                }
                
            }
            
            
            Set<String> fieldNames = new Set<String>();
            for(Schema.FieldSetMember fs : Utility.readFieldSet('Account').get('Sugati')){
                String fieldName = fs.fieldPath;
                fieldNames.add(fieldName.toLowerCase());   
            }
            searhcedAccount = Utility.getAccounts(fieldNames, condition+' limit 1000').values();
            
            
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '******' +e.getMessage() + '******' +e.getStackTraceString());    
        }
        lstLeadAccounts.lstAccounts = searhcedAccount;
        return lstLeadAccounts;
    }
    
    public Class LeadAndAccounts{
        public List<Account> lstAccounts{get; set;}
        public List<Lead> lstLeads{get; set;}
        public LeadAndAccounts(){
            this.lstAccounts = new List<Account>();
            this.lstLeads = new List<Lead>();
        }
    }
    @remoteAction
    public static void deleteNewClient(String selectedAcc, String oppId) {
        try{
            Delete [Select Id from Client_Group__c where CG_Lead_Group_Member__r.GM_Contact__r.AccountId = :selectedAcc];        
            Delete [Select Id from Group_Member__c where GM_Contact__r.AccountId = :selectedAcc];
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString());
        }
    }
    @remoteAction
    public static String addNewClient(Account acc, String oppID,String jsonsecGroupMembers) {
        //System.assert(false,acc);
        GroupMembersAccount gma = (GroupMembersAccount)JSON.deserialize(jsonsecGroupMembers,GroupMembersAccount.class);
        List<GroupMembersWrapper> lstGroupMember = new List<GroupMembersWrapper>();
        Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
        
        //Account acc = (Account)JSON.deserialize(selectedAcc,Account.class);
        if(acc.Id != null){
            acc = [Select ID,Name,A_Salutation__c,A_First_Name__c,A_Last_Name__c,A_Middle_Name__c,A_Email__c,Phone,BillingPostalCode,billingStreet
                          ,billingCity,billingState,billingCountry from Account where Id = :acc.Id];
            gma.acc =  acc;
        }
        else{
            if(acc.A_First_Name__c != null){
                acc.Name = acc.A_First_Name__c;  
            }  
            if(acc.A_First_Name__c != null && acc.A_Last_Name__c != null){
                acc.Name = acc.A_First_Name__c+' '+acc.A_Last_Name__c;  
            }  
            else if(acc.A_First_Name__c == null && acc.A_Last_Name__c != null){
                acc.Name = acc.A_Last_Name__c;  
            }
            insert acc;    
        }
        if(oppID != null){
            for(Group_Member__c gm : [Select id,GM_Contact__c,GM_Opportunity__c,GM_Lead_Passenger__c from Group_Member__c where GM_Opportunity__c =: oppID]){
                mapGroupMembers.put(gm.GM_Contact__c,gm);  
            }
        }
        for(Contact con : [Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,C_Middle_Name__c,
                            C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingState,MailingPostalCode,
                            Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c,
                            (select id,Name,AM_Airline__c from Airline_memberships__r), (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) from Contact where AccountId = :acc.Id]){
            GroupMembersWrapper gmw = new GroupMembersWrapper();
            gmw.included = false;
            if(mapGroupMembers.containsKey(con.Id)){
                gmw.included = true;
                gmw.isLead = mapGroupMembers.get(con.Id).GM_Lead_Passenger__c;
            }
            else{
                gmw.included = true;  
                gmw.isLead = false;  
            }
            if(acc.A_Email__c == con.email){
                gmw.isLead = true;    
            }
            gmw.con = con;
            lstGroupMember.add(gmw);
        }
        
        if(lstGroupMember.size() == 0){
            GroupMembersWrapper gmw = new GroupMembersWrapper();    
            gmw.con = new Contact(FirstName = acc.A_First_Name__c,LastName = acc.A_Last_Name__c, AccountId = acc.Id,
                                  salutation = acc.A_Salutation__c, email = acc.A_Email__c, phone = acc.phone, 
                                  mailingStreet = acc.billingStreet, mailingCity = acc.billingCity, mailingState = acc.billingState,
                                  mailingCountry = acc.billingCountry,  mailingPostalCode = acc.billingPostalCode, Occupancy_Type__c = 'Adult');
            gmw.included = true;
            gmw.isLead = true;
            lstGroupMember.add(gmw);
        }
        gma.lstGms = lstGroupMember;
        gma.acc = acc;
        return JSON.serialize(gma);
        
    }
    
    @remoteAction
    public static Account saveAddress(Account acc,String createBrochure) {
        
        if(acc.Id == null){
            if(acc.A_First_Name__c != null){
                acc.Name = acc.A_First_Name__c;  
            }  
            if(acc.A_First_Name__c != null && acc.A_Last_Name__c != null){
                acc.Name = acc.A_First_Name__c+' '+acc.A_Last_Name__c;  
            }  
            else if(acc.A_First_Name__c == null && acc.A_Last_Name__c != null){
                acc.Name = acc.A_Last_Name__c;  
            }
        }
        
        
        upsert acc;
        
        if(createBrochure == 'true'){
            RecordType  rt = [select Id, Name FROM RecordType where SObjectType = 'Task' AND Name = 'Brochure Request' Limit 1  ];
            if(acc.Id != null){
              Task task = new Task();
              task.Status = 'Not Started';
              task.Subject = 'Brochure Request';
              task.RecordTypeId  = rt.id;
              task.ActivityDate = System.Today();
              task.WhatId = acc.id;
              insert Task;  
            }
        }
        return acc;
    }
    
    @remoteAction
    public static Contact saveContactAddress(String jsoncon) {
       Contact con= (Contact)JSON.deserialize(jsoncon,Contact.class);
        
        upsert con;
        
        return [Select Id,Occupancy_Type__c,BirthDate from Contact where Id = :con.Id];
    }
    
     @remoteAction
     public static boolean saveBroucheRequest(Account acc) {
        //Record_Type__c rt = [select Id, Name FROM Record_Type__c where RT_SObject_Type__c = 'Task' AND Name = 'Brochure Request' Limit 1];
        Recordtype rt = [Select Id,Name,SobjectType from recordtype where SobjectType = 'Task' AND Name = 'Brochure Request' Limit 1];
        if(acc.Id != null){
          Task task = new Task();
          task.Status = 'Not Started';
          task.Subject = 'Brochure Request';
          task.RecordTypeId = rt.id;
          task.ActivityDate = System.Today();
          task.WhatId = acc.id;
          insert Task;  
          if(Task.id != null){        
              return true;
          }else return false;
        }
        else{
        return false;
        }
     }
    
     @remoteAction
     public static boolean saveBroucheRequestContact(String jsoncon, String accountId){
        Contact con = (Contact)JSON.deserialize(jsoncon,Contact.class);
        Recordtype rt = [Select Id,Name,SobjectType from recordtype where SobjectType = 'Task' AND Name = 'Brochure Request' Limit 1];
        if(con.Id != null){
          Task task = new Task();
          task.Status = 'Not Started';
          task.Subject = 'Brochure Request';
          task.RecordTypeId = rt.id;
          task.ActivityDate = System.Today();
          task.WhatId = AccountId;
          task.whoId = con.id;
          insert Task;  
          if(Task.id != null){        
              return true;
          }else return false;
        }
        else{
        return false;
        }
     }
    
    
     
    @remoteAction
    public static List<Opportunity > getOpportunities(String accId) {
        return [Select Id,Owner.Name,Amount, Name, O_Country__c, O_Departure_Date__c, O_Return_Date__c, StageName, CloseDate from Opportunity where AccountId = :accId Order by CloseDate DESC limit 1000];
    }
    
    @remoteAction
    public static List<Task> getOpenActivities(String accId) {
        Account a =[select id, (Select Id,Who.Name,Owner.Name,Subject,What.Name,Status,Priority,ActivityDate  from OpenActivities where (Status = 'Not Started' OR Status = 'Completed') Order By LastModifiedDate desc Limit 5 ) from Account where id =: accId];
        List<String> lstTId = new List<String>();
        for(OpenActivity oa : a.OpenActivities){
            lstTId.add(oa.Id);
        }
        List<Task> lstTask  = [Select Id,Who.Name,Owner.Name, Subject,What.Name,Status,Priority,ActivityDate,RecordType.Name  
                               from Task where (Status = 'Not Started' OR Status = 'Completed') and Id In :lstTId];
        return lstTask;
    }
    
    @remoteAction
    public static List<ActivityHistory> getActivityHistory(String accId) {
        Account a =[select id,(Select Id,Who.Name,Owner.Name,Subject,What.Name,Status,Priority,ActivityDate  from ActivityHistories Order By LastModifiedDate desc Limit 5) from Account where id =: accId];
        return a.ActivityHistories ;
    }    
    
    @remoteAction
    public static String getGroupMembres(Account acc, String oppID) {
        List<GroupMembersWrapper> lstGroupMember = new List<GroupMembersWrapper>();
        Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
        if(oppID != null){
            for(Group_Member__c gm : [Select id,GM_Contact__c,GM_Opportunity__c,GM_Lead_Passenger__c from Group_Member__c where GM_Opportunity__c =: oppID]){
                mapGroupMembers.put(gm.GM_Contact__c,gm);  
            }
        }
        for(Contact con : [Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,C_Middle_Name__c,
                            C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingState,MailingPostalCode,
                            Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c,
                            (select id,Name,AM_Airline__c from Airline_memberships__r), (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) from Contact where AccountId = :acc.Id]){
            GroupMembersWrapper gmw = new GroupMembersWrapper();
            gmw.included = false;
            if(mapGroupMembers.containsKey(con.Id)){
                gmw.included = true;
                gmw.isLead = mapGroupMembers.get(con.Id).GM_Lead_Passenger__c;
            }
            if(oppID == null || oppID == ''){
                gmw.included = true;  
                gmw.isLead = false;  
            }
            if(acc.A_Email__c == con.email && (oppID == null || oppID == '')){
                gmw.isLead = true;    
            }
            gmw.con = con;
            lstGroupMember.add(gmw);
        }
        
        if(lstGroupMember.size() == 0){
            GroupMembersWrapper gmw = new GroupMembersWrapper();    
            gmw.con = new Contact(FirstName = acc.A_First_Name__c,LastName = acc.A_Last_Name__c, AccountId = acc.Id,
                                  salutation = acc.A_Salutation__c, email = acc.A_Email__c, phone = acc.phone, 
                                  mailingStreet = acc.billingStreet, mailingCity = acc.billingCity, mailingState = acc.billingState,
                                  mailingCountry = acc.billingCountry,  mailingPostalCode = acc.billingPostalCode, Occupancy_Type__c = 'Adult');
            gmw.included = true;
            gmw.isLead = true;
            lstGroupMember.add(gmw);
        }
        return JSON.serialize(lstGroupMember);
    }
    
    @remoteAction
    public static String getGroupMembresOther(Account acc, String oppID) {
        Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
        Map<String,List<GroupMembersWrapper>> mapGMByAccount = new Map<String,List<GroupMembersWrapper>>();
        Map<String,Account> mapAccounts = new Map<String,Account>();
        List<GroupMembersAccount> lstGMSAccount = new List<GroupMembersAccount>();
        List<String> lstAccounts = new List<String>(); 
        if(oppID != null){
            for(Group_Member__c gm : [Select id,GM_Contact__c,GM_Contact__r.AccountId,GM_Opportunity__c,GM_Lead_Passenger__c from Group_Member__c where GM_Opportunity__c =: oppID]){
                mapGroupMembers.put(gm.GM_Contact__c,gm);  
                lstAccounts.add(gm.GM_Contact__r.AccountId);
            }
        }
        for(Account accN : [Select Id,Name,A_Last_Name__c from Account where Id in :lstAccounts]){
            mapAccounts.put(accN.Id,accN);
        }
        
        for(Contact con : [Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,C_Middle_Name__c,
                            C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingState,MailingPostalCode,
                            Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c,
                            (select id,Name,AM_Airline__c from Airline_memberships__r), (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) from Contact where AccountId in : lstAccounts and AccountId != :acc.Id]){
            GroupMembersWrapper gmw = new GroupMembersWrapper();
            gmw.included = false;
            if(mapGroupMembers.containsKey(con.Id)){
                gmw.included = true;
                gmw.isLead = mapGroupMembers.get(con.Id).GM_Lead_Passenger__c;
            }
            if(oppID == null || oppID == ''){
                gmw.included = true;  
                gmw.isLead = false;  
            }
            if(acc.A_Email__c == con.email && (oppID == null || oppID == '')){
                gmw.isLead = true;    
            }
            gmw.con = con;
            if(!mapGMByAccount.containsKey(con.AccountId)){
                mapGMByAccount.put(con.AccountId, new List<GroupMembersWrapper>());    
            }
            mapGMByAccount.get(con.AccountId).add(gmw);
        }
        
        for(String accStr : mapGMByAccount.keySet()){
            GroupMembersAccount gma = new GroupMembersAccount();
            gma.acc = mapAccounts.get(accStr);
            gma.lstGms= mapGMByAccount.get(accStr);
            lstGMSAccount.add(gma);
        }
        return JSON.serialize(lstGMSAccount);
    }
    
    @remoteAction
    public static String addPax(Integer add, String jsonString, String accId) {
        List<GroupMembersWrapper> lstGMW = (List<GroupMembersWrapper>)JSON.deserialize(jsonString,List<GroupMembersWrapper>.class);
        Account acc = [Select ID,A_Salutation__c,A_First_Name__c,A_Last_Name__c,A_Middle_Name__c,A_Email__c,Phone,BillingPostalCode,billingStreet
                      ,billingCity,billingState,billingCountry from Account where Id = :accId];
        for(Integer i=1; i<=add; i++){
            Contact con = new Contact(accountId = accId, mailingStreet = acc.billingStreet, mailingCity = acc.billingCity, mailingState = acc.billingState,
                                  mailingCountry = acc.billingCountry,  mailingPostalCode = acc.billingPostalCode);
            con.LastName= acc.A_Last_Name__c;
            GroupMembersWrapper gmw = new GroupMembersWrapper();
            gmw.con = con;
            gmw.con.Occupancy_Type__c = 'Adult';
            gmw.included = true;
            gmw.isLead = false;
            lstGMW.add(gmw);
        }
        return JSON.serialize(lstGMW);
    }
    
    @remoteAction
    public static String saveOpportunityNew(String jsonOpp, String jsonString, List<pickListValue> tcs, Account acc, String otherGroupMembers) {
        Savepoint sp = Database.setSavepoint();
        try{
            List<GroupMembersAccount> lstGMAccounts = (List<GroupMembersAccount>)JSON.deserialize(otherGroupMembers,List<GroupMembersAccount>.class);
            Opportunity opp = (Opportunity)JSON.deserialize(jsonOpp,Opportunity.class);
            List<GroupMembersWrapper> lstGMW = (List<GroupMembersWrapper>)JSON.deserialize(jsonString,List<GroupMembersWrapper>.class);
            Map<GroupMembersWrapper,Contact> mapGMWContact = new Map<GroupMembersWrapper,Contact>();
            
            for(GroupMembersWrapper gmw : lstGMW){
                if(acc.Id  != null){
                    gmw.con.AccountId = acc.Id;                  
                }
                if(gmw.isLead){
                    gmw.con.C_Lead_Passenger__c = true;
                }
                
                mapGMWContact.put(gmw,gmw.con);
            }
            for(GroupMembersAccount gma : lstGMAccounts){
                for(GroupMembersWrapper gmw : gma.lstGms){
                    if(acc.Id  != null){
                        gmw.con.AccountId = gma.acc.Id;                  
                    }
                    if(gmw.isLead){
                        gmw.con.C_Lead_Passenger__c = true;
                    }
                    
                    mapGMWContact.put(gmw,gmw.con);
                }
            }
            upsert mapGMWContact.values();
            
            for(GroupMembersAccount gma : lstGMAccounts){
                for(GroupMembersWrapper gmw : gma.lstGms){
                    mapGMWContact.put(gmw,gmw.con);
                }
            }
            
            
            if(opp.Id == null){
                if(opp.CloseDate == null)
                    opp.CloseDate = Date.today();
                opp.Name = 'New Enquiry';
                
                opp.O_Holiday_Enquiry_Stage__c = 0;
                opp.AccountId = acc.Id;
                opp.StageName = 'Enquiry' ;
            }
            //opp.CurrencyIsoCode = opp.O_Booking_Currency__c;
            upsert opp;
            
            //Group Members Section
            Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
            List<Group_Member__c> lstGroupMembers = new List<Group_Member__c>();
            List<Group_Member__c> delGroupMembers = new List<Group_Member__c>();
                    
            for(Group_Member__c gm : [Select Id,GM_Contact__c from Group_Member__c where GM_Opportunity__c = :opp.Id]){
                mapGroupMembers.put(gm.GM_Contact__c, gm);
            }
            for(GroupMembersWrapper gmw : mapGMWContact.KeySet()){
                
                if(gmw.included){
                    Group_Member__c groupMember;
                    if(mapGroupMembers.containsKey(mapGMWContact.get(gmw).Id)){
                        groupMember = mapGroupMembers.get(mapGMWContact.get(gmw).Id);     
                        groupMember.GM_Lead_Passenger__c = gmw.isLead ;
                        groupMember.GM_Contact__c = mapGMWContact.get(gmw).Id;
                        if(gmw.con.Occupancy_Type__c != null)
                            groupMember.GM_Occupancy_Type__c = gmw.con.Occupancy_Type__c;
                    }
                    else{
                        groupMember = new Group_Member__c();     
                        groupMember.GM_Lead_Passenger__c = gmw.isLead ;
                        groupMember.GM_Opportunity__c = opp.id;  
                        groupMember.GM_Contact__c = mapGMWContact.get(gmw).Id;  
                        if(gmw.con.Occupancy_Type__c != null)
                            groupMember.GM_Occupancy_Type__c = gmw.con.Occupancy_Type__c;    
                    }
                    lstGroupMembers.add(groupMember);
                }
                else if(mapGroupMembers.containsKey(mapGMWContact.get(gmw).Id)){
                    delGroupMembers.add(mapGroupMembers.get(mapGMWContact.get(gmw).Id));
                }
            }
            //System.assert(false,lstGroupMembers);
            upsert lstGroupMembers;
            
            delete [Select Id from Group_Member__c where Id in :delGroupMembers];
            
            //*** Client Group Section Starts ***//
             List<Group_Member__c> lstGMem = new List<Group_Member__c>();
             Map<String, Client_Group__c> mapExistingCGs = new Map<String,Client_Group__c>();
             List<Client_Group__c> lstClientGroups = new List<Client_Group__c>();
             Set<String> delCGIds = new Set<String>();
             List<Group_Member__c > lstGMems = [Select id,GM_Contact__r.AccountId,GM_Contact__c,GM_Contact__r.salutation,GM_Contact__r.Name, GM_Lead_Passenger__c  from Group_Member__c where GM_Opportunity__c =: opp.Id];
             
             for (Client_Group__c cg: [Select id,name,CG_Opportunity__c,CG_Lead_Group_Member__c  from Client_Group__c where CG_Opportunity__c  =: opp.Id]) {
                mapExistingCGs.put(cg.CG_Lead_Group_Member__c,cg);
             }
             Map<Group_Member__c,Client_Group__c> leadGMs = new Map<Group_Member__c,Client_Group__c>();
             
             for(Group_Member__c gm : lstGMems){
                 if(gm.GM_Lead_Passenger__c){
                     if (!mapExistingCGs.containskey(gm.Id)) {
                         Client_Group__c cg = new Client_Group__c();
                         cg.CG_Lead_Group_Member__c = gm.Id;
                         cg.name = '';
                         if(gm.GM_Contact__r.salutation != null){
                             cg.name =  gm.GM_Contact__r.salutation+' ';
                         }
                         cg.name += gm.GM_Contact__r.Name;
                         cg.CG_Opportunity__c = Opp.Id;
                         lstClientGroups.add(cg); 
                         leadGMs.put(gm,cg);
                     }
                     else{
                         Client_Group__c cg = mapExistingCGs.get(gm.Id);
                         cg.name = '';
                         if(gm.GM_Contact__r.salutation != null){
                             cg.name =  gm.GM_Contact__r.salutation+' ';
                         }
                         cg.name += gm.GM_Contact__r.Name;
                         lstClientGroups.add(cg);    
                         leadGMs.put(gm,cg); 
                     }     
                 }
                 else{
                     if (mapExistingCGs.containskey(gm.Id)) {
                         delCGIds.add(mapExistingCGs.get(gm.Id).Id);
                     }
                 }
             }
             if(!test.isRunningTest()){
                 upsert leadGMs.values();
             }
             
             //upsert lstClientGroups ;
             delete [Select Id from Client_Group__c where Id in :delCGIds];
             
             //Update Lead GMS Client Group
             List<Group_Member__c> lstGMs = new List<Group_Member__c>();
             Map<String,String> mapAccountClientGroup = new Map<String,String>();
             if(leadGMs.values().size() > 1){
                 for(Group_Member__c gm : leadGMs.keySet()){
                     gm.GM_Client_Group__c = leadGMs.get(gm).Id;
                     lstGMs.add(gm);
                     
                     mapAccountClientGroup.put(gm.GM_Contact__r.AccountId,gm.GM_Client_Group__c);
                     
                 }
                 for(Group_Member__c gm : lstGMems){
                     if(!gm.GM_Lead_Passenger__c){
                         if(mapAccountClientGroup.containsKey(gm.GM_Contact__r.AccountId)){
                             gm.GM_Client_Group__c = mapAccountClientGroup.get(gm.GM_Contact__r.AccountId);
                             lstGMs.add(gm);
                         }
                     }
                 }
             }
             else if(leadGMs.values().size() == 1){
                 for(Group_Member__c gm : lstGMems){
                     gm.GM_Client_Group__c = leadGMs.values()[0].Id;
                     lstGMs.add(gm);
                 }
             }
             update lstGMs;
            
            //Travelling Countries
            List<String> travellingCountries = new List<String>();
            for(pickListValue pv : tcs){
                travellingCountries.add(pv.value);    
            }
            Set<String> existingTCs = new Set<String>();
            Set<String> lstCountriesId = new Set<String>();
            Set<String> selectedCountry = new Set<String>();
            selectedCountry.addAll(travellingCountries);
            List<Travelling_country__c> deleteTCs = new List<Travelling_country__c>();
            List<Travelling_country__c> lstTcs = new List<Travelling_country__c>();
            for (Travelling_country__c tc: [select id, TC_country__c from travelling_Country__c where TC_Opportunity__c =: opp.Id ]) {
                existingTCs.add(tc.TC_country__c);
                if(!selectedCountry.contains(tc.TC_country__c)){
                    deleteTCs.add(tc);    
                }
                else{
                    lstCountriesId.add(tc.TC_country__c);
                    lstTcs.add(tc);
                }
            }
            if(deleteTCs.size() != 0)
                delete deleteTCs;
            
            if(travellingCountries.size() > 0){
                for (String country : travellingCountries) {                       
                    if(!existingTCs.contains(country)){
                       country = country.trim();
                       lstTcs.add(new Travelling_Country__c(TC_Opportunity__c =opp.id, TC_Country__c = country));
                       lstCountriesId.add(country);
                       existingTCs.add(country);
                    }   
                } 
                
                upsert lstTcs;
            } 
            List<Country__c> lstCountrys = [Select Id, Name from Country__c where Id in :lstCountriesId];
            if(opp.Name == 'New Enquiry'){
                if(lstClientGroups.size() == 1){
                    opp.Name = lstClientGroups[0].name;
                }
                else{
                    opp.Name = '';
                }
                
                if(lstCountrys.size() > 0){
                    if(opp.Name != ''){
                        opp.Name += ' - ';
                    }
                    for(Country__c country : lstCountrys){
                        opp.Name += country.Name+',';
                    }
                    opp.Name = opp.Name.removeEnd(',');
                }
                opp.Name += ': '+ datetime.newinstance(opp.O_Departure_Date__c.year(), opp.O_Departure_Date__c.month(), opp.O_Departure_Date__c.day()).format('dd.MM.yyyy')+' - '+datetime.newinstance(opp.O_Return_Date__c.year(), opp.O_Return_Date__c.month(), opp.O_Return_Date__c.day()).format('dd.MM.yyyy');
            }       
            Utility.isCopied = true; 
            String  countryStr= '';
            opp.O_Country__c = '';
            for(Country__c country : lstCountrys){
                countryStr+= country.Name+', ';
            }
            countryStr = countryStr.removeEnd(', ');
            opp.O_Country__c = countryStr;
            update opp;
            return JSON.serialize([select id,(Select Id,OE_To_Email_Addresses__c,CurrencyISOCode,OE_Bcc_Email_Addresses__c,OE_Cc_Email_Addresses__c,OE_Email_Body__c,
                     OE_Email_Closing__c,OE_Email_Intro__c,OE_Email_Subject__c,OE_Email_Type__c from Opportunity_Emails__r where 
                     OE_Email_Type__c = 'HE Recap Email' limit 1),O_Budget__c ,O_Holiday_Enquiry_Recap_Description__c,
                     Amount, Budget_Note__c,O_Holiday_Enquiry_Stage__c , O_Budget_specify__c, O_Flexibility_Details__c, O_Follow_Up_Time__c, 
                     O_Country__c,O_Is_Group_Booking__c,O_Maximum_Occupancy__c,O_Minimum_Occupancy__c,O_Break_Through_No__c,O_Steps_Completed__c,name,O_Type_2__c,StageName,CloseDate ,CampaignID,O_Flexiable_Date__c,AccountId,O_Agent_SC__c,O_Agent__c,
                     O_Holiday_Type__c,O_Holiday_Type__r.Name,O_No_of_Nights__c, type,O_Booking_Currency__c, O_Departure_Date__c,O_Return_Date__c,O_Budget_Start_Range__c,Description,
                     O_Pax__c from Opportunity where id =: opp.Id Limit 1][0]);
            
        }
        Catch(Exception e){
            Database.rollback(sp);
            System.assert(false,e.getStackTraceString()+'dddd'+e.getMessage() + '*****' + e.getLineNumber());
            return null;    
        }
        
    }
    
    
    @remoteAction
    public static String saveOpportunity(String jsonOpp, String jsonString, List<pickListValue> tcs, Account acc) {
        Savepoint sp = Database.setSavepoint();
        try{
            Opportunity opp = (Opportunity)JSON.deserialize(jsonOpp,Opportunity.class);
            List<GroupMembersWrapper> lstGMW = (List<GroupMembersWrapper>)JSON.deserialize(jsonString,List<GroupMembersWrapper>.class);
            Map<GroupMembersWrapper,Contact> mapGMWContact = new Map<GroupMembersWrapper,Contact>();
            
            for(GroupMembersWrapper gmw : lstGMW){
                if(acc.Id  != null){
                    gmw.con.AccountId = acc.Id;                  
                }
                if(gmw.isLead){
                    gmw.con.C_Lead_Passenger__c = true;
                }
                
                mapGMWContact.put(gmw,gmw.con);
            }
            upsert mapGMWContact.values();
            
            
            if(opp.Id == null){
                if(opp.CloseDate == null)
                    opp.CloseDate = Date.today();
                opp.Name = 'New Enquiry';
                
                opp.O_Holiday_Enquiry_Stage__c = 0;
                opp.AccountId = acc.Id;
                opp.StageName = 'Enquiry' ;
            }
            //opp.CurrencyIsoCode = opp.O_Booking_Currency__c;
            upsert opp;
            
            //Group Members Section
            Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
            List<Group_Member__c> lstGroupMembers = new List<Group_Member__c>();
            List<Group_Member__c> delGroupMembers = new List<Group_Member__c>();
                    
            for(Group_Member__c gm : [Select Id,GM_Contact__c from Group_Member__c where GM_Opportunity__c = :opp.Id]){
                mapGroupMembers.put(gm.GM_Contact__c, gm);
            }
            for(GroupMembersWrapper gmw : mapGMWContact.KeySet()){
                
                if(gmw.included){
                    Group_Member__c groupMember;
                    if(mapGroupMembers.containsKey(mapGMWContact.get(gmw).Id)){
                        groupMember = mapGroupMembers.get(mapGMWContact.get(gmw).Id);     
                        groupMember.GM_Lead_Passenger__c = gmw.isLead ;
                        groupMember.GM_Contact__c = mapGMWContact.get(gmw).Id;
                        if(gmw.con.Occupancy_Type__c != null)
                            groupMember.GM_Occupancy_Type__c = gmw.con.Occupancy_Type__c;
                    }
                    else{
                        groupMember = new Group_Member__c();     
                        groupMember.GM_Lead_Passenger__c = gmw.isLead ;
                        groupMember.GM_Opportunity__c = opp.id;  
                        groupMember.GM_Contact__c = mapGMWContact.get(gmw).Id;  
                        if(gmw.con.Occupancy_Type__c != null)
                            groupMember.GM_Occupancy_Type__c = gmw.con.Occupancy_Type__c;    
                    }
                    lstGroupMembers.add(groupMember);
                }
                else if(mapGroupMembers.containsKey(mapGMWContact.get(gmw).Id)){
                    delGroupMembers.add(mapGroupMembers.get(mapGMWContact.get(gmw).Id));
                }
            }
            //System.assert(false,lstGroupMembers);
            upsert lstGroupMembers;
            
            delete [Select Id from Group_Member__c where Id in :delGroupMembers];
            
            //*** Client Group Section Starts ***//
             List<Group_Member__c> lstGMem = new List<Group_Member__c>();
             Map<String, Client_Group__c> mapExistingCGs = new Map<String,Client_Group__c>();
             List<Client_Group__c> lstClientGroups = new List<Client_Group__c>();
             Set<String> delCGIds = new Set<String>();
             List<Group_Member__c > lstGMems = [Select id,GM_Contact__c,GM_Contact__r.salutation,GM_Contact__r.Name, GM_Lead_Passenger__c  from Group_Member__c where GM_Opportunity__c =: opp.Id];
             
             for (Client_Group__c cg: [Select id,name,CG_Opportunity__c,CG_Lead_Group_Member__c  from Client_Group__c where CG_Opportunity__c  =: opp.Id]) {
                mapExistingCGs.put(cg.CG_Lead_Group_Member__c,cg);
             }
             Map<Group_Member__c,Client_Group__c> leadGMs = new Map<Group_Member__c,Client_Group__c>();
             for(Group_Member__c gm : lstGMems){
                 if(gm.GM_Lead_Passenger__c){
                     if (!mapExistingCGs.containskey(gm.Id)) {
                         Client_Group__c cg = new Client_Group__c();
                         cg.CG_Lead_Group_Member__c = gm.Id;
                         cg.name = '';
                         if(gm.GM_Contact__r.salutation != null){
                             cg.name =  gm.GM_Contact__r.salutation+' ';
                         }
                         cg.name += gm.GM_Contact__r.Name;
                         cg.CG_Opportunity__c = Opp.Id;
                         lstClientGroups.add(cg); 
                         leadGMs.put(gm,cg); 
                     }
                     else{
                         Client_Group__c cg = mapExistingCGs.get(gm.Id);
                         cg.name = '';
                         if(gm.GM_Contact__r.salutation != null){
                             cg.name =  gm.GM_Contact__r.salutation+' ';
                         }
                         cg.name += gm.GM_Contact__r.Name;
                         lstClientGroups.add(cg);    
                         leadGMs.put(gm,cg); 
                     }     
                 }
                 else{
                     if (mapExistingCGs.containskey(gm.Id)) {
                         delCGIds.add(mapExistingCGs.get(gm.Id).Id);
                     }
                 }
             }
             if(!test.isRunningTest()){
                 upsert leadGMs.values();
             }
             
             //upsert lstClientGroups ;
             delete [Select Id from Client_Group__c where Id in :delCGIds];
             
             //Update Lead GMS Client Group
             List<Group_Member__c> lstGMs = new List<Group_Member__c>();
             if(leadGMs.values().size() > 1){
                 for(Group_Member__c gm : leadGMs.keySet()){
                     gm.GM_Client_Group__c = leadGMs.get(gm).Id;
                     lstGMs.add(gm);
                 }
             }
             else if(leadGMs.values().size() == 1){
                 for(Group_Member__c gm : lstGMems){
                     gm.GM_Client_Group__c = leadGMs.values()[0].Id;
                     lstGMs.add(gm);
                 }
             }
             update lstGMs;
            
            //Travelling Countries
            List<String> travellingCountries = new List<String>();
            for(pickListValue pv : tcs){
                travellingCountries.add(pv.value);    
            }
            Set<String> existingTCs = new Set<String>();
            Set<String> lstCountriesId = new Set<String>();
            Set<String> selectedCountry = new Set<String>();
            selectedCountry.addAll(travellingCountries);
            List<Travelling_country__c> deleteTCs = new List<Travelling_country__c>();
            List<Travelling_country__c> lstTcs = new List<Travelling_country__c>();
            for (Travelling_country__c tc: [select id, TC_country__c from travelling_Country__c where TC_Opportunity__c =: opp.Id ]) {
                existingTCs.add(tc.TC_country__c);
                if(!selectedCountry.contains(tc.TC_country__c)){
                    deleteTCs.add(tc);    
                }
                else{
                    lstCountriesId.add(tc.TC_country__c);
                    lstTcs.add(tc);
                }
            }
            if(deleteTCs.size() != 0)
                delete deleteTCs;
            
            if(travellingCountries.size() > 0){
                for (String country : travellingCountries) {                       
                    if(!existingTCs.contains(country)){
                       country = country.trim();
                       lstTcs.add(new Travelling_Country__c(TC_Opportunity__c =opp.id, TC_Country__c = country));
                       lstCountriesId.add(country);
                       existingTCs.add(country);
                    }   
                } 
                
                upsert lstTcs;
            } 
            if(opp.Name == 'New Enquiry'){
                if(acc.name != ''){
                    opp.Name = acc.name;
                }
                List<Country__c> lstCountrys = [Select Id, Name from Country__c where Id in :lstCountriesId];
                if(lstCountrys.size() > 0){
                    opp.Name += ' - ';
                    for(Country__c country : lstCountrys){
                        opp.Name += country.Name+',';
                    }
                    opp.Name = opp.Name.removeEnd(',');
                }
                opp.Name += ': '+ datetime.newinstance(opp.O_Departure_Date__c.year(), opp.O_Departure_Date__c.month(), opp.O_Departure_Date__c.day()).format('dd.MM.yyyy')+' - '+datetime.newinstance(opp.O_Return_Date__c.year(), opp.O_Return_Date__c.month(), opp.O_Return_Date__c.day()).format('dd.MM.yyyy');
            }       
            Utility.isCopied = true; 
            update opp;
            return JSON.serialize([select id,(Select Id,OE_To_Email_Addresses__c,CurrencyISOCode,OE_Bcc_Email_Addresses__c,OE_Cc_Email_Addresses__c,OE_Email_Body__c,
                     OE_Email_Closing__c,OE_Email_Intro__c,OE_Email_Subject__c,OE_Email_Type__c from Opportunity_Emails__r where 
                     OE_Email_Type__c = 'HE Recap Email' limit 1),O_Budget__c ,O_Holiday_Enquiry_Recap_Description__c,
                     Amount, Budget_Note__c,O_Holiday_Enquiry_Stage__c , O_Budget_specify__c, O_Flexibility_Details__c, O_Follow_Up_Time__c, 
                     O_Country__c,O_Is_Group_Booking__c,O_Maximum_Occupancy__c,O_Minimum_Occupancy__c,O_Break_Through_No__c,O_Steps_Completed__c,name,O_Type_2__c,StageName,CloseDate ,CampaignID,O_Flexiable_Date__c,AccountId,O_Agent_SC__c,O_Agent__c,
                     O_Holiday_Type__c, type,O_Booking_Currency__c, O_Departure_Date__c,O_Return_Date__c,O_Budget_Start_Range__c,Description,
                     O_Pax__c from Opportunity where id =: opp.Id Limit 1][0]);
            
        }
        Catch(Exception e){
            Database.rollback(sp);
            System.assert(false,e.getStackTraceString()+'dddd'+e.getMessage() + '*****' + e.getLineNumber());
            return null;    
        }
        
    }
    
    @remoteAction
    public static List<Questionnaire> loadAllQuestion(String accId, String oppId){
    
        List<Questionnaire> lstQuestionWrapper = new List<Questionnaire>();
        
        for(Question__c ques : [Select Id, Q_Category__c, Q_Holiday_Type__c, Q_Related_To__c, Name,Q_Question_Name__c,Q_Type__c,Q_Options__c from Question__c where 
                                Is_Active__c = true order by Q_Order__c limit 1000 ]){
            List<pickListValue> lstOp = new List<pickListValue>();
            if(ques.Q_Type__c == 'Picklist'){
                //lstOp.add(new pickListValue('','--Select--'));
            }
            if(ques.Q_Type__c == 'Picklist' || ques.Q_Type__c == 'Checkbox' || ques.Q_Type__c == 'Search' || ques.Q_Type__c == 'Radio'){
                for(String option : ques .Q_Options__c.split(',')){
                    lstOp.add(new pickListValue(option.trim(),option.trim()));    
                }
            }
            lstQuestionWrapper.add(new Questionnaire(ques,lstOp));
        }
        
        if((oppId != null && oppId !='')  || (accId != null && accId != '')){
            String condition = 'where';
            if((accId != null && accId != '')){
                condition += ' (HQ_Opportunity__c  = null AND HQ_Account__c = : accId) ';
            }
            if((oppId != null && oppId !='') && (accId != null && accId != '')){
                condition += ' OR (HQ_Opportunity__c = : oppId AND HQ_Account__c = null) ';
            }
            
            for(Holiday_Question__c hq : Database.Query('Select ID,HQ_Answer__c,HQ_Answer_Time__c,HQ_Question__c,HQ_Question__r.Q_Question_Name__c,HQ_Question__r.Q_Category__c,HQ_Question__r.Q_Order__c   from Holiday_Question__c '+condition)){
                
                for(Questionnaire qw : lstQuestionWrapper){
                    if(qw.question.Id == hq.HQ_Question__c){
                        qw.hq = hq;
                        if(qw.question.Q_Type__c == 'Checkbox'){
                            if(hq.HQ_Answer__c != null){    
                                qw.checkedAns.addAll(hq.HQ_Answer__c.split(',')); 
                            }   
                        }
                    }
                }
            }
        }
        return lstQuestionWrapper;
    }
    
    @remoteAction
    public static List<Questionnaire> saveQuestion(String quesions, String oppId, String accId, Integer currentStage){
        try{
            List<Questionnaire> lstQuestionWrapper = (List<Questionnaire>) JSON.deserialize(quesions, List<Questionnaire>.class);
            List<Holiday_Question__c> lstHQ = new List<Holiday_Question__c>();
            for(Questionnaire qw : lstQuestionWrapper){
                if((qw.hq.HQ_Answer__c  != null && qw.hq.HQ_Answer__c  != '') || qw.checkedAns.size() > 0){
                    Holiday_Question__c hq = qw.hq;
                    if(oppId != null && oppId != '' && qw.question.Q_Related_To__c == 'Opportunity'){
                        hq.HQ_Opportunity__c = oppId;
                    }
                    if(accId != null && accId != ''&& qw.question.Q_Related_To__c == 'Account'){
                        hq.HQ_Account__c = accId;    
                    }
                    if(hq.Id == null)
                        hq.HQ_Question__c = qw.question.Id;
                    if(qw.checkedAns.size() > 0 && qw.question.Q_Type__c == 'Checkbox'){
                        hq.HQ_Answer__c = '';
                        for(String str : qw.checkedAns){
                            hq.HQ_Answer__c += str+',';
                        }
                        hq.HQ_Answer__c = hq.HQ_Answer__c.removeEnd(',');
                    }
                    lstHQ.add(hq);    
                }
            } 
            upsert lstHQ;   
            for(Holiday_Question__c hq : [Select ID,HQ_Answer__c,HQ_Answer_Time__c,HQ_Question__c,HQ_Question__r.Q_Type__c ,HQ_Question__r.Q_Question_Name__c,HQ_Question__r.Q_Category__c,
                                            HQ_Question__r.Q_Order__c from Holiday_Question__c where (HQ_Opportunity__c = :oppId OR HQ_Account__c = :accId)]){
                for(Questionnaire qw : lstQuestionWrapper){
                    if(qw.question.Id == hq.HQ_Question__c){
                        qw.hq = hq;
                    }
                    if(qw.question.Q_Type__c == 'Checkbox'){
                        if(hq.HQ_Answer__c != null){    
                            //qw.checkedAns.addAll(hq.HQ_Answer__c.split(',')); 
                        }   
                    }
                }
            }
            Opportunity opp = [Select id, O_Holiday_Enquiry_Stage__c from Opportunity where id =: oppId];
            opp.O_Holiday_Enquiry_Stage__c  = currentStage+1;
            update opp;
            //system.assert(false, currentStage); 
            return lstQuestionWrapper;
        }
        Catch(Exception e){
            System.assert(false,e.getMessage()+'@@@@'+e.getStackTraceString());
            ApexPages.addMessages(e);
            return null;
        }
    }
    
   /////////////////////////Holiday Suggestion Area/////////////////////
   
   @remoteAction
    public static Trees getSuggestions(Filters filter, boolean isFirstTime, String oppId) {
        Set<Id> whSet = new Set <Id>();
        List<String> travellingCountries = new List<String>();
        Trees treeObj = new Trees();
        for(Holiday_Suggestions__c  hsc : [SELECT Id, HS_Where_to_go__r.Id FROM Holiday_Suggestions__c  WHERE HS_Opportunity__r.Id =:oppId AND HS_Where_to_go__c!=null]){
            whSet.add(hsc.HS_Where_to_go__r.Id);
        }
        for(pickListValue pv : filter.countries){
            travellingCountries.add(pv.value);    
        }
        //Tree Navigation
        Map<String,List<Where_to_go__c>> lstWRMap = new Map<String,List<Where_to_go__c>>();
        for(Where_to_go__c whtg : [Select Id, Name,CurrencyISOCode, W_Country__r.Name, W_Holiday_Type__c, W_Country__c from Where_to_go__c where W_Country__c 
                                    in : travellingCountries and (W_Holiday_Type__c= : filter.holidayType OR W_Holiday_Type__c = null) and W_Archive__c = false order by Name]){
            if(!lstWRMap.containsKey(whtg.W_Country__c)){
                lstWRMap.put(whtg.W_Country__c, new List<Where_to_go__c>());    
            }
            lstWRMap.get(whtg.W_Country__c).add(whtg);
        }
        for(String cat : lstWRMap.keySet()){
            TreeNav tn = new TreeNav();
            tn.name = lstWRMap.get(cat)[0].W_Country__r.Name;
            tn.label = lstWRMap.get(cat)[0].W_Country__r.Name;
            tn.objId = lstWRMap.get(cat)[0].W_Country__c;
            tn.expanded = !isFirstTime;
            tn.obj = 'Country__c';
            tn.checked = true;
            List<TreeNav> lstChildren = new List<TreeNav>();
            for(Where_to_go__c act : lstWRMap.get(cat)){
                TreeNav chtn = new TreeNav();
                chtn.Name = act.name;
                chtn.label = act.name;
                chtn.objId = act.Id;
                chtn.expanded = false;
                chtn.obj = 'Where_to_go__c';
                
                if(act.W_Holiday_Type__c == filter.holidayType) {
                    chtn.checked = true;
                }
                
                if(whSet.contains(act.Id)){
                    chtn.checked = true;
                }
                lstChildren.add(chtn);
            }  
            tn.children = lstChildren;
            treeObj.whereToGoTree.add(tn);   
        }
        return treeObj;
    }
    
    
    @remoteAction
    public static Trees getCategoies(List<TreeNav> whereToGo, List<TreeNav> catTree, Filters filter, String oppId) {
        Set<String> selectedCatrgory = new Set<String>();
        Trees treeObj = new Trees();
        treeObj.whereToGoTree = whereToGo;
        for(Holiday_Suggestions__c  hsc : [SELECT Id, HS_What_to_do__r.Id FROM Holiday_Suggestions__c                  
                    WHERE HS_Opportunity__r.Id =:oppId AND HS_What_to_do__c !=null]){
           selectedCatrgory .add(hsc.HS_What_to_do__r.Id);
        }
        
        
        List<String> selectedWhereToGo = new List<String>();
        for(TreeNav tn : whereToGo){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Where_to_go__c'){
                    selectedWhereToGo.add(tnCh.objId);
                }
            }
        }
        
        for(TreeNav tn : catTree){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Activity__c'){   
                    selectedCatrgory.add(tnCh.objId);
                }
            }
        }
        
        Map<String,List<Activity__c>> lstActMap = new Map<String,List<Activity__c>>();
        for(Activity__c act : [Select Id, Name,CurrencyISOCode, WH_Category__r.Name, WH_Category__c from Activity__c where 
                                WH_Where_to_go__c in :selectedWhereToGo and (WH_Holiday_Type__c = : filter.holidayType OR WH_Holiday_Type__c = null) and WH_Archive__c = false order by Name]){
            if(!lstActMap.containsKey(act.WH_Category__c)){
                lstActMap.put(act.WH_Category__c, new List<Activity__c>());    
            }
            lstActMap.get(act.WH_Category__c).add(act);
        }
        for(String cat : lstActMap.keySet()){
            TreeNav tn = new TreeNav();
            tn.name = lstActMap.get(cat)[0].WH_Category__r.Name;
            tn.label = lstActMap.get(cat)[0].WH_Category__r.Name; 
            tn.objId = lstActMap.get(cat)[0].WH_Category__c;
            tn.obj = 'Category__c';
            List<TreeNav> lstChildren = new List<TreeNav>();
            for(Activity__c act : lstActMap.get(cat)){
                TreeNav chtn = new TreeNav();
                if(selectedCatrgory.contains(act.Id)){
                    chtn.checked = true;        
                }
                chtn.Name = act.name;
                chtn.objId = act.Id;
                chtn.obj = 'Activity__c';
                lstChildren.add(chtn);
            }  
            tn.children = lstChildren;
            treeObj.catTree.add(tn);   
        }
        return treeObj;
    }
    
    @remoteAction
    public static Trees getAccommodation(List<TreeNav> whereToGo, List<TreeNav> catTree,  List<TreeNav> accTree, Filters filter, String oppId) {
        
        Trees treeObj = new Trees();
        treeObj.whereToGoTree = whereToGo;
        Set<String> selectedCatrgory = new Set<String>();
        for(Holiday_Suggestions__c  hsc : [SELECT Id, HS_Supplier__r.Id FROM Holiday_Suggestions__c                  
                    WHERE HS_Opportunity__r.Id =:oppId AND HS_Supplier__c !=null]){
           selectedCatrgory.add(hsc.HS_Supplier__r.Id);
        }
        List<String> selectedWhereToGo = new List<String>();
        for(TreeNav tn : whereToGo){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Where_to_go__c'){
                    selectedWhereToGo.add(tnCh.objId);
                }
            }
        }
        
        for(TreeNav tn : catTree){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Activity__c'){
                    selectedCatrgory.add(tnCh.objId);
                }
            }
        }
        
        for(TreeNav tn : accTree){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Accommodation'){
                    selectedCatrgory.add(tnCh.objId);
                }
            }
        }
        
        Map<String,List<Supplier__c>> lstActMap = new Map<String,List<Supplier__c>>();
        List<Holiday_Type__c> ht = [Select Id,Name from Holiday_Type__c where Id = :filter.holidayType limit 1];
        String htName = '';
        if(ht.size() > 0 ){
            htName = ht[0].Name;
        }
        for(Supplier__c  sup : [Select Id, Name, S_Type__c,CurrencyISOCode  from Supplier__c where 
                                (S_Where_to_go__c in :selectedWhereToGo or S_What_to_do__c in : selectedCatrgory) and 
                                (S_Holiday_Types__c includes (:htName) OR S_Holiday_Types__c = null) and S_Archive__c = false and S_Type__c in ('Hotel','Accommodation') order by Name]){   
            if(!lstActMap.containsKey(sup.S_Type__c)){
                lstActMap.put(sup.S_Type__c, new List<Supplier__c>());    
            }
            lstActMap.get(sup.S_Type__c).add(sup);
        }
        for(String cat : lstActMap.keySet()){
            TreeNav tn = new TreeNav();
            tn.name = lstActMap.get(cat)[0].S_Type__c;
            tn.label = lstActMap.get(cat)[0].S_Type__c; 
            tn.objId = lstActMap.get(cat)[0].S_Type__c;
            tn.obj = 'Category__c';
            List<TreeNav> lstChildren = new List<TreeNav>();
            for(Supplier__c act : lstActMap.get(cat)){
                TreeNav chtn = new TreeNav();
                if(selectedCatrgory.contains(act.Id)){
                    chtn.checked = true;        
                }
                chtn.Name = act.name;
                chtn.objId = act.Id;
                chtn.obj = 'Accommodation';
                lstChildren.add(chtn);
            }  
            tn.children = lstChildren;
            treeObj.catTree.add(tn);   
        }
        return treeObj;
    }
    
    
    @remoteAction
    public static List<Suggestions> LoadSuggestions(List<TreeNav> whereToGo, List<TreeNav> catTree, List<TreeNav> accTree, String oppId, String HolidayTypeId) {
        Trees treeObj = new Trees();
        List<Suggestions> lstSuggestions = new List<Suggestions>();
        treeObj.whereToGoTree = whereToGo;
        
        List<String> selectedWhereToGo = new List<String>();
        for(TreeNav tn : whereToGo){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Where_to_go__c'){
                    selectedWhereToGo.add(tnCh.objId);
                }
            }
        }
        List<String> selectedCatrgory = new List<String>();
        for(TreeNav tn : catTree){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj == 'Activity__c'){
                    selectedCatrgory.add(tnCh.objId);
                }
            }
        }
        
        List<String> selectedAcc = new List<String>();
        for(TreeNav tn : accTree){
            for(TreeNav tnCh : tn.children){
                if(tnCh.checked && tnCh.obj != 'Category__c'){
                    selectedAcc.add(tnCh.objId);
                }
            }
        }
        
        
        Map<String,Holiday_Suggestions__c > actIds = new Map<String,Holiday_Suggestions__c >();
        Map<String,Holiday_Suggestions__c > whIds  = new Map<String,Holiday_Suggestions__c >();
        Map<String,Holiday_Suggestions__c > suppIds = new Map<String,Holiday_Suggestions__c >();
        for(Holiday_Suggestions__c  hs : [select Id,HS_What_to_do__c,HS_Message__c,HS_Errata_Text__c,HS_Where_to_go__c,HS_Supplier__c,HS_Order__c from Holiday_Suggestions__c where  HS_Opportunity__c = :oppId order by HS_Order__c]){
            if(hs.HS_What_to_do__c != null){
                actIds.put(hs.HS_What_to_do__c,hs);
            }
            if(hs.HS_Where_to_go__c != null){
                whIds.put(hs.HS_Where_to_go__c,hs);
            }
            if(hs.HS_Supplier__c != null){
                suppIds.put(hs.HS_Supplier__c,hs);
            }
        }
        Map<String,String> mapErrataMSG = SOQLServices.getErrataMsg(oppId,selectedWhereToGo,selectedCatrgory,selectedAcc);
        
        for(Where_to_go__c whtg : [Select Id, Name, W_Country__r.Name, W_Country__c,W_Duration__c,W_Rating__c,W_When__c,CurrencyISOCode,W_Estimated_Cost__c
                                   ,(Select Id from Attachments where Name like '%Suggestion%' limit 1),
                                   (Select Id,IT_Message__c,IT_Holiday_Type__r.Name,IT_Holiday_Type__c from Itinerary_Text__r where (IT_Holiday_Type__c = :HolidayTypeId or IT_Holiday_Type__r.Name = 'Generic') limit 2)
                                     from Where_to_go__c where ID in : selectedWhereToGo and W_Archive__c = false]){
           
            Suggestions sugg = new Suggestions();
            if(whIds.containsKey(whtg.Id)){
                sugg.selected = true;
                sugg.hs = whIds.get(whtg.Id);
                if(mapErrataMSG.containsKey(whtg.Id)){
                    sugg.hs.HS_Errata_Text__c = mapErrataMSG.get(whtg.Id);
                }
            }
            else{
                Holiday_Suggestions__c hsRecord = new Holiday_Suggestions__c();
                if(whtg.Itinerary_Text__r.size() == 1){
                    hsRecord.HS_Message__c = whtg.Itinerary_Text__r[0].IT_Message__c;
                }
                else if(whtg.Itinerary_Text__r.size() > 1){
                    for(Itinerary_Text__c It : whtg.Itinerary_Text__r){
                        if(It.IT_Holiday_Type__r.Name == 'Generic'){
                            hsRecord.HS_Message__c = It.IT_Message__c;
                        }
                    }
                }
                if(mapErrataMSG.containsKey(whtg.Id)){
                    hsRecord.HS_Errata_Text__c = mapErrataMSG.get(whtg.Id);
                }
                sugg.hs = hsRecord;   
            }
            if(whtg.Attachments.size() != 0){
                sugg.imageID = whtg.Attachments[0].Id;
            }
            sugg.whereToGo = whtg;
            lstSuggestions.add(sugg);
        }
        
        
        for(Activity__c act : [Select Id, Name, WH_Category__r.Name, WH_Category__c,WH_Description__c,WH_Duration__c,CurrencyISOCode,WH_Estimated_Cost__c,
                                WH_Rating__c,WH_When__c,WH_Country__c,(Select Id from Attachments where Name like '%Suggestion%' limit 1),
                                (Select Id,IT_Message__c,IT_Holiday_Type__r.Name from Itinerary_Text__r where (IT_Holiday_Type__c = :HolidayTypeId or IT_Holiday_Type__r.Name = 'Generic') limit 1)
                                 from Activity__c where Id in : selectedCatrgory and WH_Archive__c = false]){
            Suggestions sugg = new Suggestions();
            if(actIds.containsKey(act.Id)){
                sugg.selected = true;
                sugg.hs = actIds.get(act.Id);  
                if(mapErrataMSG.containsKey(act.Id)){
                    sugg.hs.HS_Errata_Text__c = mapErrataMSG.get(act.Id);
                }  
            }
            else{
                Holiday_Suggestions__c hsRecord = new Holiday_Suggestions__c();
                if(act.Itinerary_Text__r.size() == 1){
                    hsRecord.HS_Message__c = act.Itinerary_Text__r[0].IT_Message__c;
                }
                else if(act.Itinerary_Text__r.size() > 1){
                    for(Itinerary_Text__c It : act.Itinerary_Text__r){
                        if(It.IT_Holiday_Type__r.Name != 'Generic'){
                            hsRecord.HS_Message__c = It.IT_Message__c;
                        }
                    }
                }
                if(mapErrataMSG.containsKey(act.Id)){
                    hsRecord.HS_Errata_Text__c = mapErrataMSG.get(act.Id);
                }
                sugg.hs = hsRecord;   
            }
            if(act.Attachments.size() != 0){
                sugg.imageID = act.Attachments[0].Id;
            }
            sugg.activity = act;
            lstSuggestions.add(sugg);
        }
        
        for(Supplier__c act : [Select Id, Name, S_Rating__c,CurrencyISOCode,S_Estimated_Cost__c,
                                (Select Id from Attachments where Name like '%Suggestion%' limit 1),
                                (Select Id,IT_Message__c,IT_Holiday_Type__r.Name from Quote_Text__r where (IT_Holiday_Type__c = :HolidayTypeId or IT_Holiday_Type__r.Name = 'Generic') limit 1)
                                 from Supplier__c where Id in : selectedAcc and S_Archive__c = false]){
            Suggestions sugg = new Suggestions();
            if(suppIds.containsKey(act.Id)){
                sugg.selected = true;
                sugg.hs = actIds.get(act.Id);  
                if(mapErrataMSG.containsKey(act.Id)){
                    sugg.hs.HS_Errata_Text__c = mapErrataMSG.get(act.Id);
                }   
            }
            else{
                Holiday_Suggestions__c hsRecord = new Holiday_Suggestions__c();
                if(act.Quote_Text__R.size() == 1){
                    hsRecord.HS_Message__c = act.Quote_Text__R[0].IT_Message__c;
                }
                else if(act.Quote_Text__R.size() > 1){
                    for(Itinerary_Text__c It : act.Quote_Text__R){
                        if(It.IT_Holiday_Type__r.Name != 'Generic'){
                            hsRecord.HS_Message__c = It.IT_Message__c;
                        }
                    }
                }
                if(mapErrataMSG.containsKey(act.Id)){
                    hsRecord.HS_Errata_Text__c = mapErrataMSG.get(act.Id);
                }
                sugg.hs = hsRecord;   
            }
            if(act.Attachments.size() != 0){
                sugg.imageID = act.Attachments[0].Id;
            }
            sugg.supplier = act;
            lstSuggestions.add(sugg);
        }
        
        return lstSuggestions;
    }
    
    @remoteAction
    public static List<Suggestions> saveSuggestion(Holiday_Suggestions__c  hss, String imageId, List<pickListValue> addSugg, List<pickListValue> removeSugg, String oppId){
        
        List<Suggestions> lstMySuggestions = new List<Suggestions>();
        for(pickListValue pl : addSugg){
            List<Holiday_Suggestions__c> oldHs = [Select Id from Holiday_Suggestions__c where Id = :hss.Id];
            if(oldHs.size() == 0){
                hss.Id = null;
            }
            
            if(pl.label == 'Activity__c'){
                upsert  new Holiday_Suggestions__c(HS_What_to_do__c = pl.value,HS_Suggestion_Image__c = imageId, HS_Opportunity__c = oppId, HS_Message__c = hss.HS_Message__c, HS_Errata_Text__c = hss.HS_Errata_Text__c, Id = hss.Id, HS_Order__c = hss.HS_Order__c);
            }   
            if(pl.label == 'Where_to_go__c'){
                upsert new Holiday_Suggestions__c(HS_Where_to_go__c= pl.value,HS_Suggestion_Image__c = imageId, HS_Opportunity__c = oppId, HS_Message__c = hss.HS_Message__c , HS_Errata_Text__c = hss.HS_Errata_Text__c, Id = hss.Id, HS_Order__c = hss.HS_Order__c);
            }
            if(pl.label == 'Supplier__c'){
                upsert new Holiday_Suggestions__c(HS_Supplier__c = pl.value, HS_Suggestion_Image__c = imageId,HS_Opportunity__c = oppId, HS_Message__c = hss.HS_Message__c, HS_Errata_Text__c = hss.HS_Errata_Text__c, Id = hss.Id, HS_Order__c = hss.HS_Order__c);
            }             
        }
        
        for(pickListValue pl : removeSugg){
            if(pl.label == 'Activity__c'){
                delete [select Id from Holiday_Suggestions__c where HS_What_to_do__c = :pl.value and HS_Opportunity__c = :oppId];
            }   
            if(pl.label == 'Where_to_go__c'){
                delete [select Id from Holiday_Suggestions__c where HS_Where_to_go__c = :pl.value and HS_Opportunity__c = :oppId];
            }
            if(pl.label == 'Supplier__c'){
                delete [select Id from Holiday_Suggestions__c where HS_Supplier__c = :pl.value and HS_Opportunity__c = :oppId];
            }             
        }
        Map<String,Holiday_Suggestions__c > actIds = new Map<String,Holiday_Suggestions__c >();
        Map<String,Holiday_Suggestions__c > whIds  = new Map<String,Holiday_Suggestions__c >();
        Map<String,Holiday_Suggestions__c > suppIds = new Map<String,Holiday_Suggestions__c >();
        for(Holiday_Suggestions__c  hs : [select Id,HS_Suggestion_Image__c,HS_What_to_do__c,HS_Message__c,HS_Errata_Text__c,HS_Where_to_go__c,HS_Supplier__c,HS_Order__c from Holiday_Suggestions__c where  HS_Opportunity__c = :oppId order by HS_Order__c]){
            actIds.put(hs.HS_What_to_do__c,hs);
            whIds.put(hs.HS_Where_to_go__c,hs);
            suppIds.put(hs.HS_Supplier__c,hs);
        }
        
        for(Where_to_go__c whtg : [Select Id, Name, W_Country__r.Name, W_Country__c,CurrencyISOCode,W_Description__c,W_Duration__c,W_Rating__c,W_When__c,W_Estimated_Cost__c
                                   ,(Select Id from Attachments where Name like '%Suggestion%' limit 1)  from Where_to_go__c where ID in : whIds.keySet() and W_Archive__c = false]){
            Suggestions sugg = new Suggestions();
            if(whIds.containsKey(whtg.Id)){
                sugg.selected = true;
                sugg.hs = whIds.get(whtg.Id);
            }
            sugg.whereToGo = whtg;
            if(whtg.Attachments.size() != 0){
                sugg.imageID = whtg.Attachments[0].Id;
            }
            if(sugg.hs.HS_Suggestion_Image__c != null){
                sugg.imageID = sugg.hs.HS_Suggestion_Image__c;
            }
            lstMySuggestions.add(sugg);
        }
        for(Activity__c act : [Select Id, Name, WH_Category__r.Name, WH_Category__c,WH_Description__c,WH_Duration__c,CurrencyISOCode,WH_Estimated_Cost__c,
                                WH_Rating__c,WH_When__c,WH_Country__c,(Select Id from Attachments where Name like '%Suggestion%' limit 1)
                                 from Activity__c where Id in : actIds.keySet() and WH_Archive__c = false]){
            Suggestions sugg = new Suggestions();
            if(actIds.containsKey(act.Id)){
                sugg.selected = true;
                sugg.hs = actIds.get(act.Id);    
            }
            if(act.Attachments.size() != 0){
                sugg.imageID = act.Attachments[0].Id;
            }
            if(sugg.hs.HS_Suggestion_Image__c != null){
                sugg.imageID = sugg.hs.HS_Suggestion_Image__c;
            }
            sugg.activity = act;
            lstMySuggestions.add(sugg);
        }
        
        for(Supplier__c act : [Select Id, Name, S_Rating__c,CurrencyISOCode,S_Estimated_Cost__c,
                                (Select Id from Attachments where Name like '%Suggestion%' limit 1)
                                from Supplier__c where Id in : suppIds.keySet() and S_Archive__c = false]){
            Suggestions sugg = new Suggestions();
            if(suppIds.containsKey(act.Id)){
                sugg.selected = true;
                sugg.hs = suppIds.get(act.Id);    
            }
            if(act.Attachments.size() != 0){
                sugg.imageID = act.Attachments[0].Id;
            }
            if(sugg.hs.HS_Suggestion_Image__c != null){
                sugg.imageID = sugg.hs.HS_Suggestion_Image__c;
            }
            sugg.supplier = act;
            lstMySuggestions.add(sugg);
        }
        
        return lstMySuggestions;
        
    }
    
    //Save Order of suggestions
    @remoteAction
    public static List<Suggestions> saveSuggestionOrder(List<Holiday_Suggestions__c> hss){
        update hss;
        return null;    
    }
    
    //save updated images HS
    @remoteAction
    public static void saveSuggestionImage(Holiday_Suggestions__c hss){
        update hss;
    }
    
    public Class Suggestions{
        public Boolean selected{get; set;}
        public Activity__c activity{get; set;}
        public Where_to_go__c whereToGo{get; set;}
        public Supplier__c supplier{get; set;}
        public Holiday_Suggestions__c hs{get; set;}
        public String imageID{get; set;}
        
        public Suggestions(){
            this.selected = false;     
        }
    }
    
    public Class Filters{
        public String holidayType{get; set;}
        public List<pickListValue> countries{get; set;}
        public List<String> categories{get; set;}
        public List<String> whereToGo{get; set;}
        
        public Filters(){
            this.countries = new List<pickListValue>();
            this.categories = new List<String>();
            this.whereToGo = new List<String>();
        }
    }
    
    public Class Trees{
        public List<TreeNav> catTree{get;set;}
        public List<TreeNav> whereToGoTree{get;set;}
        
        public Trees(){
            this.catTree = new List<TreeNav>();    
            this.whereToGoTree = new List<TreeNav>();
        }
    }
    
    public Class TreeNav{
        public String name{get; set;}
        public String label{get; set;}
        public String objId{get; set;}
        public String obj{get; set;}
        public Boolean selected{get; set;}
        public Boolean checked{get; set;}
        public Boolean show{get; set;}
        public string uid{get; set;}
        public string parent_uid{get; set;}
        public Boolean expanded{get; set;}
        public List<TreeNav> children{get; set;}
        
        public TreeNav(){
            this.checked = false;
            this.show = true;
            this.children = new List<TreeNav>();
        }
    }
    
    
    
    public Class pickListValue{
        public String value{get; set;}
        public String label{get; set;}
        public String type{get; set;}
        
        public pickListValue(String value, String label){
            this.value = value;
            this.label = label;
            this.type = '';
        }
    }
    
    public Class GroupMembersAccount{
        public Account acc{get;set;}
        public List<GroupMembersWrapper> lstGms{get; set;}
        public Integer additionalPaxSec{get;set;}
        public GroupMembersAccount(){
            this.acc = new Account();
            this.lstGms = new List<GroupMembersWrapper>();
            this.additionalPaxSec = 0;
        }
    }
    
    public Class GroupMembersWrapper{
        public Boolean included{get;set;}
        public Boolean isLead{get;set;}
        public Contact con{get;set;}
        public GroupMembersWrapper(){
            this.included = false ;
            this.isLead = false;
        }
    } 
    
    public Class Questionnaire{
        public Question__c question{get; set;}
        public Holiday_Question__c hq{get; set;}
        public List<pickListValue> lstOption{get; set;}
        public Set<String> checkedAns{get; set;}
        
        public Questionnaire(Question__c ques, List<pickListValue> lstOption){
            this.question = ques;
            this.hq = new Holiday_Question__c();
            this.lstOption = lstOption;
            this.checkedAns = new Set<String>();
        }
    }
    
    // save communication pre.
    @remoteAction
    public static String saveCommp(String jsonData, String conStr){
        //System.assert(false,jsonData);
        try{
            Communication_Preference__c commp = (Communication_Preference__c) JSON.deserialize(jsonData, Communication_Preference__c.Class);
            Contact con = (Contact) JSON.deserialize(conStr, Contact.Class);
            //upsert contact as we need contact id to create airline membership
            upsert con;
            if(commp.Id == null){
                commp.CP_Account__c = con.AccountId;
                commp.CP_Contact__c = con.Id;
            }
            upsert commp;
            
            return JSON.serialize([Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingState,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            ,(Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c, CP_State__c, CP_Street_1__c,
                             CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :con.Id]);
        }
        catch(Exception e){
            System.assert(false, e.getMessage()+'dsdsd'+e.getStackTraceString());
            return null;
        }
        
    }
    
    // save airline member
    @remoteAction
    public static String saveAirlineMember(String jsonData, String conStr){
        //System.assert(false,jsonData);
        try{
            AirlineMemberShip member = (AirlineMemberShip) JSON.deserialize(jsonData, AirlineMemberShip.Class);
            Contact con = (Contact) JSON.deserialize(conStr, Contact.Class);
        
            //upsert contact as we need contact id to create airline membership
            //system.assert(false, member);
            upsert con;
            Airline_membership__c amc = new Airline_membership__c();
            amc.Id = member.id;
            amc.AM_Airline__c = member.airline;
            if(amc.Id == null){
                amc.AM_Contact__c = con.Id;
            }
            amc.Name = member.membershipnumber;
            upsert amc;
            return JSON.serialize([Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingState,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            , (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :con.Id]);
        }
        catch(Exception e){
            System.assert(false, e.getMessage()+'dsdsd'+e.getStackTraceString());
            return null;
        }
        
    } 
    
    // Delete airline member
    @remoteAction
    public static String DeleteAirlineMember(String airlineMembershipRecordId, String contactId){
        try{
            
            Airline_membership__c  member = [Select id from Airline_membership__c where id =: airlineMembershipRecordId];
            delete member;
        }
        catch(Exception e){
            System.assert(false, e);
        }
        return JSON.serialize([Select id,Salutation,AccountId,firstname,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,C_Passport_Number__c,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingCountry,MailingState,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            , (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :contactId]);
    } 
    
    // Delete Communication Pre.
    @remoteAction
    public static String DeleteCommp(String commpRecordId, String contactId){
        try{
            Communication_Preference__c member = [Select id from Communication_Preference__c where id =: commpRecordId];
            delete member;
        }
        catch(Exception e){
            System.assert(false, e);
        }
        return JSON.serialize([Select id,Salutation,AccountId,firstname,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,C_Passport_Number__c,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingCountry,MailingState,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            , (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :contactId]);
    } 
    
    public String getLoadCountries() {
        List<pickListValue> countryOptions = new List<pickListValue>();
        countryOptions.add(new pickListValue('','-Select-'));    
        countryOptions.add(new pickListValue ('GB','United Kingdom'));
        countryOptions.add(new pickListValue ('US','United States'));
        countryOptions.add(new pickListValue ('AF','Afghanistan'));
        //countryOptions.add(new pickListValue ('Åland Islands','Åland Islands'));
        countryOptions.add(new pickListValue ('AL','Albania'));
        countryOptions.add(new pickListValue ('DZ','Algeria'));
        countryOptions.add(new pickListValue ('AS','American Samoa'));
        countryOptions.add(new pickListValue ('AD','Andorra'));
        countryOptions.add(new pickListValue ('AO','Angola'));
        countryOptions.add(new pickListValue ('AI','Anguilla'));
        countryOptions.add(new pickListValue ('AQ','Antarctica'));
        countryOptions.add(new pickListValue ('AG','Antigua and Barbuda'));
        countryOptions.add(new pickListValue ('AR','Argentina'));
        countryOptions.add(new pickListValue ('AM','Armenia'));
        countryOptions.add(new pickListValue ('AW','Aruba'));
        countryOptions.add(new pickListValue ('AU','Australia'));
        countryOptions.add(new pickListValue ('AT','Austria'));
        countryOptions.add(new pickListValue ('AZ','Azerbaijan'));
        countryOptions.add(new pickListValue ('BS','Bahamas'));
        countryOptions.add(new pickListValue ('BH','Bahrain'));
        countryOptions.add(new pickListValue ('BD','Bangladesh'));
        countryOptions.add(new pickListValue ('BB','Barbados'));
        countryOptions.add(new pickListValue ('BY','Belarus'));
        countryOptions.add(new pickListValue ('BE','Belgium'));
        countryOptions.add(new pickListValue ('BZ','Belize'));
        countryOptions.add(new pickListValue ('BJ','Benin'));
        countryOptions.add(new pickListValue ('BM','Bermuda'));
        countryOptions.add(new pickListValue ('BT','Bhutan'));
        countryOptions.add(new pickListValue ('BO','Bolivia'));
        countryOptions.add(new pickListValue ('BA','Bosnia and Herzegovina'));
        countryOptions.add(new pickListValue ('BW','Botswana'));
        countryOptions.add(new pickListValue ('BV','Bouvet Island'));
        countryOptions.add(new pickListValue ('BR','Brazil'));
        countryOptions.add(new pickListValue ('IO','British Indian Ocean Territory'));
        countryOptions.add(new pickListValue ('BN','Brunei Darussalam'));
        countryOptions.add(new pickListValue ('BG','Bulgaria'));
        countryOptions.add(new pickListValue ('BF','Burkina Faso'));
        countryOptions.add(new pickListValue ('BI','Burundi'));
        countryOptions.add(new pickListValue ('KH','Cambodia'));
        countryOptions.add(new pickListValue ('CM','Cameroon'));
        countryOptions.add(new pickListValue ('CA','Canada'));
        countryOptions.add(new pickListValue ('CV','Cape Verde'));
        countryOptions.add(new pickListValue ('KY','Cayman Islands'));
        countryOptions.add(new pickListValue ('CF','Central African Republic'));
        countryOptions.add(new pickListValue ('TD','Chad'));
        countryOptions.add(new pickListValue ('CL','Chile'));
        countryOptions.add(new pickListValue ('CN','China'));
        countryOptions.add(new pickListValue ('CX','Christmas Island'));
        countryOptions.add(new pickListValue ('CC','Cocos (Keeling) Islands'));
        countryOptions.add(new pickListValue ('CO','Colombia'));
        countryOptions.add(new pickListValue ('KM','Comoros'));
        countryOptions.add(new pickListValue ('CG','Congo'));
        countryOptions.add(new pickListValue ('CD, The Democratic Republic of The','Congo, The Democratic Republic of The'));
        countryOptions.add(new pickListValue ('CK','Cook Islands'));
        countryOptions.add(new pickListValue ('CR','Costa Rica'));
        countryOptions.add(new pickListValue ('CI','Cote D\'ivoire'));
        countryOptions.add(new pickListValue ('HR','Croatia'));
        countryOptions.add(new pickListValue ('CU','Cuba'));
        countryOptions.add(new pickListValue ('CY','Cyprus'));
        countryOptions.add(new pickListValue ('CZ','Czech Republic'));
        countryOptions.add(new pickListValue ('DK','Denmark'));
        countryOptions.add(new pickListValue ('DJ','Djibouti'));
        countryOptions.add(new pickListValue ('DM','Dominica'));
        countryOptions.add(new pickListValue ('DO','Dominican Republic'));
        countryOptions.add(new pickListValue ('EC','Ecuador'));
        countryOptions.add(new pickListValue ('EG','Egypt'));
        countryOptions.add(new pickListValue ('SV','El Salvador'));
        countryOptions.add(new pickListValue ('GQ','Equatorial Guinea'));
        countryOptions.add(new pickListValue ('ER','Eritrea'));
        countryOptions.add(new pickListValue ('EE','Estonia'));
        countryOptions.add(new pickListValue ('ET','Ethiopia'));
        countryOptions.add(new pickListValue ('FK','Falkland Islands (Malvinas)'));
        countryOptions.add(new pickListValue ('FO','Faroe Islands'));
        countryOptions.add(new pickListValue ('FJ','Fiji'));
        countryOptions.add(new pickListValue ('FI','Finland'));
        countryOptions.add(new pickListValue ('FR','France'));
        countryOptions.add(new pickListValue ('GF','French Guiana'));
        countryOptions.add(new pickListValue ('PF','French Polynesia'));
        countryOptions.add(new pickListValue ('TF','French Southern Territories'));
        countryOptions.add(new pickListValue ('GA','Gabon'));
        countryOptions.add(new pickListValue ('GM','Gambia'));
        countryOptions.add(new pickListValue ('GE','Georgia'));
        countryOptions.add(new pickListValue ('DE','Germany'));
        countryOptions.add(new pickListValue ('GH','Ghana'));
        countryOptions.add(new pickListValue ('GI','Gibraltar'));
        countryOptions.add(new pickListValue ('GR','Greece'));
        countryOptions.add(new pickListValue ('GL','Greenland'));
        countryOptions.add(new pickListValue ('GD','Grenada'));
        countryOptions.add(new pickListValue ('GP','Guadeloupe'));
        countryOptions.add(new pickListValue ('GU','Guam'));
        countryOptions.add(new pickListValue ('GT','Guatemala'));
        //countryOptions.add(new pickListValue ('Guernsey','Guernsey'));
        countryOptions.add(new pickListValue ('GN','Guinea'));
        countryOptions.add(new pickListValue ('GW','Guinea-bissau'));
        countryOptions.add(new pickListValue ('GY','Guyana'));
        countryOptions.add(new pickListValue ('HT','Haiti'));
        countryOptions.add(new pickListValue ('HM','Heard Island and Mcdonald Islands'));
        countryOptions.add(new pickListValue ('VA','Holy See (Vatican City State)'));
        countryOptions.add(new pickListValue ('HN','Honduras'));
        countryOptions.add(new pickListValue ('HK','Hong Kong'));
        countryOptions.add(new pickListValue ('HU','Hungary'));
        countryOptions.add(new pickListValue ('IS','Iceland'));
        countryOptions.add(new pickListValue ('IN','India'));
        countryOptions.add(new pickListValue ('ID','Indonesia'));
        countryOptions.add(new pickListValue ('IR, Islamic Republic of','Iran, Islamic Republic of'));
        countryOptions.add(new pickListValue ('IQ','Iraq'));
        countryOptions.add(new pickListValue ('IE','Ireland'));
        //countryOptions.add(new pickListValue ('Isle of Man','Isle of Man'));
        countryOptions.add(new pickListValue ('IL','Israel'));
        countryOptions.add(new pickListValue ('IT','Italy'));
        countryOptions.add(new pickListValue ('JM','Jamaica'));
        countryOptions.add(new pickListValue ('JP','Japan'));
        //countryOptions.add(new pickListValue ('Jersey','Jersey'));
        countryOptions.add(new pickListValue ('JO','Jordan'));
        countryOptions.add(new pickListValue ('KZ','Kazakhstan'));
        countryOptions.add(new pickListValue ('KE','Kenya'));
        countryOptions.add(new pickListValue ('KI','Kiribati'));
        countryOptions.add(new pickListValue ('KP, Democratic People\'s Republic of','Korea, Democratic People\'s Republic of'));
        countryOptions.add(new pickListValue ('KR','Korea, Republic of'));
        countryOptions.add(new pickListValue ('KW','Kuwait'));
        countryOptions.add(new pickListValue ('KG','Kyrgyzstan'));
        //countryOptions.add(new pickListValue ('Lao People\'s Democratic Republic','Lao People\'s Democratic Republic'));
        countryOptions.add(new pickListValue ('LV','Latvia'));
        countryOptions.add(new pickListValue ('LB','Lebanon'));
        countryOptions.add(new pickListValue ('LS','Lesotho'));
        countryOptions.add(new pickListValue ('LR','Liberia'));
        countryOptions.add(new pickListValue ('LY','Libyan Arab Jamahiriya'));
        countryOptions.add(new pickListValue ('LI','Liechtenstein'));
        countryOptions.add(new pickListValue ('LT','Lithuania'));
        countryOptions.add(new pickListValue ('LU','Luxembourg'));
        countryOptions.add(new pickListValue ('MO','Macao'));
        countryOptions.add(new pickListValue ('MK, The Former Yugoslav Republic of','Macedonia, The Former Yugoslav Republic of'));
        countryOptions.add(new pickListValue ('MG','Madagascar'));
        countryOptions.add(new pickListValue ('MW','Malawi'));
        countryOptions.add(new pickListValue ('MY','Malaysia'));
        countryOptions.add(new pickListValue ('MV','Maldives'));
        countryOptions.add(new pickListValue ('ML','Mali'));
        countryOptions.add(new pickListValue ('MT','Malta'));
        countryOptions.add(new pickListValue ('MH','Marshall Islands'));
        countryOptions.add(new pickListValue ('MQ','Martinique'));
        countryOptions.add(new pickListValue ('MR','Mauritania'));
        countryOptions.add(new pickListValue ('MU','Mauritius'));
        countryOptions.add(new pickListValue ('YT','Mayotte'));
        countryOptions.add(new pickListValue ('MX','Mexico'));
        countryOptions.add(new pickListValue ('FM','Micronesia, Federated States of'));
        countryOptions.add(new pickListValue ('MD, Republic of','Moldova, Republic of'));
        countryOptions.add(new pickListValue ('MC','Monaco'));
        countryOptions.add(new pickListValue ('MN','Mongolia'));
        countryOptions.add(new pickListValue ('ME','Montenegro'));
        countryOptions.add(new pickListValue ('MS','Montserrat'));
        countryOptions.add(new pickListValue ('MA','Morocco'));
        countryOptions.add(new pickListValue ('MZ','Mozambique'));
        countryOptions.add(new pickListValue ('MM','Myanmar'));
        countryOptions.add(new pickListValue ('NA','Namibia'));
        countryOptions.add(new pickListValue ('NR','Nauru'));
        countryOptions.add(new pickListValue ('NP','Nepal'));
        countryOptions.add(new pickListValue ('NL','Netherlands'));
        countryOptions.add(new pickListValue ('AN','Netherlands Antilles'));
        countryOptions.add(new pickListValue ('NC','New Caledonia'));
        countryOptions.add(new pickListValue ('NZ','New Zealand'));
        countryOptions.add(new pickListValue ('NI','Nicaragua'));
        countryOptions.add(new pickListValue ('NE','Niger'));
        countryOptions.add(new pickListValue ('NG','Nigeria'));
        countryOptions.add(new pickListValue ('NU','Niue'));
        countryOptions.add(new pickListValue ('NF','Norfolk Island'));
        countryOptions.add(new pickListValue ('MP','Northern Mariana Islands'));
        countryOptions.add(new pickListValue ('NO','Norway'));
        countryOptions.add(new pickListValue ('OM','Oman'));
        countryOptions.add(new pickListValue ('PK','Pakistan'));
        countryOptions.add(new pickListValue ('PW','Palau'));
        //countryOptions.add(new pickListValue ('Palestinian Territory, Occupied','Palestinian Territory, Occupied'));
        countryOptions.add(new pickListValue ('PA','Panama'));
        countryOptions.add(new pickListValue ('PG','Papua New Guinea'));
        countryOptions.add(new pickListValue ('PY','Paraguay'));
        countryOptions.add(new pickListValue ('PE','Peru'));
        countryOptions.add(new pickListValue ('PH','Philippines'));
        countryOptions.add(new pickListValue ('PN','Pitcairn'));
        countryOptions.add(new pickListValue ('PL','Poland'));
        countryOptions.add(new pickListValue ('PT','Portugal'));
        countryOptions.add(new pickListValue ('PR','Puerto Rico'));
        countryOptions.add(new pickListValue ('QA','Qatar'));
        countryOptions.add(new pickListValue ('RE','Reunion'));
        countryOptions.add(new pickListValue ('RO','Romania'));
        countryOptions.add(new pickListValue ('RU','Russian Federation'));
        countryOptions.add(new pickListValue ('RW','Rwanda'));
        countryOptions.add(new pickListValue ('SH','Saint Helena'));
        countryOptions.add(new pickListValue ('KN','Saint Kitts and Nevis'));
        countryOptions.add(new pickListValue ('LC','Saint Lucia'));
        countryOptions.add(new pickListValue ('PM','Saint Pierre and Miquelon'));
        countryOptions.add(new pickListValue ('VC','Saint Vincent and The Grenadines'));
        countryOptions.add(new pickListValue ('WS','Samoa'));
        countryOptions.add(new pickListValue ('SM','San Marino'));
        countryOptions.add(new pickListValue ('ST','Sao Tome and Principe'));
        countryOptions.add(new pickListValue ('SA','Saudi Arabia'));
        countryOptions.add(new pickListValue ('SN','Senegal'));
        countryOptions.add(new pickListValue ('RS','Serbia'));
        countryOptions.add(new pickListValue ('SC','Seychelles'));
        countryOptions.add(new pickListValue ('SL','Sierra Leone'));
        countryOptions.add(new pickListValue ('SG','Singapore'));
        countryOptions.add(new pickListValue ('SK','Slovakia'));
        countryOptions.add(new pickListValue ('SI','Slovenia'));
        countryOptions.add(new pickListValue ('SB','Solomon Islands'));
        countryOptions.add(new pickListValue ('SO','Somalia'));
        countryOptions.add(new pickListValue ('ZA','South Africa'));
        countryOptions.add(new pickListValue ('GS','South Georgia and The South Sandwich Islands'));
        countryOptions.add(new pickListValue ('ES','Spain'));
        countryOptions.add(new pickListValue ('LK','Sri Lanka'));
        countryOptions.add(new pickListValue ('SD','Sudan'));
        countryOptions.add(new pickListValue ('SR','Suriname'));
        countryOptions.add(new pickListValue ('SJ','Svalbard and Jan Mayen'));
        countryOptions.add(new pickListValue ('SZ','Swaziland'));
        countryOptions.add(new pickListValue ('SE','Sweden'));
        countryOptions.add(new pickListValue ('CH','Switzerland'));
        countryOptions.add(new pickListValue ('SY','Syrian Arab Republic'));
        countryOptions.add(new pickListValue ('TW','Taiwan, Province of China'));
        countryOptions.add(new pickListValue ('TZ','Tajikistan'));
        countryOptions.add(new pickListValue ('TZ','Tanzania, United Republic of'));
        countryOptions.add(new pickListValue ('TH','Thailand'));
        //countryOptions.add(new pickListValue ('Timor-leste','Timor-leste'));
        countryOptions.add(new pickListValue ('TG','Togo'));
        countryOptions.add(new pickListValue ('TK','Tokelau'));
        countryOptions.add(new pickListValue ('TO','Tonga'));
        countryOptions.add(new pickListValue ('TT','Trinidad and Tobago'));
        countryOptions.add(new pickListValue ('TN','Tunisia'));
        countryOptions.add(new pickListValue ('TR','Turkey'));
        countryOptions.add(new pickListValue ('TM','Turkmenistan'));
        countryOptions.add(new pickListValue ('TC','Turks and Caicos Islands'));
        countryOptions.add(new pickListValue ('TV','Tuvalu'));
        countryOptions.add(new pickListValue ('UG','Uganda'));
        countryOptions.add(new pickListValue ('UA','Ukraine'));
        countryOptions.add(new pickListValue ('AE','United Arab Emirates'));
        countryOptions.add(new pickListValue ('UM','United States Minor Outlying Islands'));
        countryOptions.add(new pickListValue ('UY','Uruguay'));
        countryOptions.add(new pickListValue ('UZ','Uzbekistan'));
        countryOptions.add(new pickListValue ('VU','Vanuatu'));
        countryOptions.add(new pickListValue ('VE','Venezuela'));
        countryOptions.add(new pickListValue ('VN','Viet Nam'));
        countryOptions.add(new pickListValue ('VG','Virgin Islands, British'));
        countryOptions.add(new pickListValue ('VI','Virgin Islands, U.S.'));
        countryOptions.add(new pickListValue ('WF','Wallis and Futuna'));
        countryOptions.add(new pickListValue ('EH','Western Sahara'));
        countryOptions.add(new pickListValue ('YE','Yemen'));
        countryOptions.add(new pickListValue ('ZM','Zambia'));
        countryOptions.add(new pickListValue ('ZW','Zimbabwe'));
        return JSON.serialize(countryOptions);
    }
    
    
    public Class AirlineMemberShip{
        public Contact con {get;set;}
        public string airline{get;set;}
        public string id{get;set;}
        public String membershipNumber{get;set;}
        
        public AirlineMemberShip(Contact con, String airline, String amnumber){
            this.con = con;
            this.id = null;
            this.airline = airline;
            this.membershipnumber = amnumber;
        }
    }
    
   
    
}
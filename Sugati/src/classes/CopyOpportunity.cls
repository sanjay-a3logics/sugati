public class CopyOpportunity {
    
    
    public string oppId  {get;set;}
    public string OpportunityType  {get;set;}
    public boolean checkedTypeFlag  {get;set;}
    public Integer step{get; set;}
    public String SelectedPax {get;set;}
    public List<holidayEnquiryWrapper> lstWrapperAdd {get;set;} 
    public Contact objCon{get; set;}
    public List<SelectOption> PaxOptions{get;set;}
    public List<SelectOption> ConOcctype{get;set;}
    public List<MapClientGorups> lstMappingCG{get; set;}
    public List<MapGroupMember> lstMappingGM{get; set;}
    public Boolean mapping{get; set;}
    public String mappingMSG{get; set;}
    
    private Opportunity oppMain;
    Integer oldClientGorupCount = 0;
    Integer oldGroupMemberCount = 0;
    PageReference pr = null;
    public Opportunity copyOpp{get;set;}
    public List<Client_Group__c> lstCGs{get;set;}
    public Integer groupMemberCount{get;set;}
    public Integer clientGroupCount{get;set;}
    
    public CopyOpportunity(Apexpages.standardController controller ) {
        oppId = controller.getId();
        checkedTypeFlag  = false;
        groupMemberCount = 0;
        clientGroupCount = 0;
        
        mapping = false;
        step = 0;
        objCon = new Contact();
        PaxOptions = new List<SelectOption>();
        lstWrapperAdd = new List<holidayEnquiryWrapper>();
        lstMappingCG = new List<MapClientGorups>();
        lstMappingGM = new List<MapGroupMember>();
        lstCGs = new List<Client_Group__c>();
            
        for(integer i = 1 ; i<= 50 ;i++){
            PaxOptions.add(new SelectOption(''+i,''+i));
        }
        
        for(Client_Group__c cg : [Select Id,Name,CG_Total_Adult_Members__c,CG_Total_Child_Members__c, CG_Total_Infant_Members__c, (Select Id from Group_Members__r) from Client_Group__c where CG_Opportunity__c = :oppId]){
            lstCGs.add(cg);
            for(Group_Member__c gm : cg.Group_Members__r){
                groupMemberCount++;
            }
            clientGroupCount++;
        } 
        copyOpp = new Opportunity();
        
    }
    
    //Fetch all the PDF Setting Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('CopyOpportunity'));
    }
    
    public PageReference selectType(){
        return null;    
    }
    public void clientGorupMapping(){
        mapping = false;
        List<Group_Member__c> lstGM  = new List<Group_Member__c>();
        for(HolidayEnquiryWrapper wc : lstWrapperAdd){
            if(wc.checked){
                String conId = wc.conWrapper.id;
                Group_Member__c gm = new Group_Member__c();
                gm.GM_Opportunity__c = copyOpp.id;
                gm.GM_Salutation__c = wc.conWrapper.Salutation ;
                gm.GM_Contact__c = wc.conWrapper.Id ;
                gm.GM_Lead_Passenger__c = wc.isLead ;
                gm.GM_First_Name__c = wc.conWrapper.firstname ;
                gm.GM_Last_Name__c = wc.conWrapper.lastname ;
                gm.GM_Email__c = wc.conWrapper.email ;
                gm.GM_Phone__c  = wc.conWrapper.phone ;
                gm.GM_Occupancy_Type__c = wc.conWrapper.Occupancy_Type__c ;
                gm.GM_Phone__c = wc.conWrapper.phone ;
                gm.GM_DOB__c = wc.conWrapper.birthdate ;
                
                lstGM.add(gm);
            }
         }
         //*** Client Group Section Starts ***//
         Map<String, Client_Group__c> mapExistingCGs = new Map<String,Client_Group__c>();
         List<Client_Group__c> lstClientGroups = new List<Client_Group__c>();
         
         for(Group_Member__c gm : lstGM){
             if(gm.GM_Lead_Passenger__c){
                  Client_Group__c cg = new Client_Group__c();
                  //cg.CG_Lead_Group_Member__c = gm.Id;
                  cg.name = gm.GM_First_Name__c +' '+ gm.GM_Last_Name__c ;
                  cg.CG_Opportunity__c = copyOpp.id;
                  lstClientGroups.add(cg);    
             }
         }
         
        lstMappingCG = new List<MapClientGorups>();
        lstMappingGM = new List<MapGroupMember>();
        
        oldClientGorupCount = 0;
        oldGroupMemberCount = 0; 
        for(Client_Group__c cg : [Select Id, (Select Id, Name,GM_Salutation__c,GM_Contact__c,GM_Contact__R.Occupancy_Type__c,GM_Contact__R.Name,GM_First_Name__c,GM_Last_Name__c,GM_Client_Group__c,GM_Lead_Passenger__c from Group_Members__r), Name from Client_Group__c where CG_Opportunity__c = :oppId]){
            lstMappingCG.add(new MapClientGorups(cg.Name, cg.Id));
            for(Group_Member__c gm : cg.Group_Members__r){
                lstMappingGM.add(new MapGroupMember(gm));
                oldGroupMemberCount++;
            }
            oldClientGorupCount++;
        } 
        Boolean isOneClient =false;
        
        for(MapClientGorups  mcg : lstMappingCG){
            Integer countCGS = 1;
            for(Client_Group__c cg : lstClientGroups){
                mcg.newClientGorups.add(new SelectOption('#'+countCGS+' '+cg.Name.replaceAll(' ',''), '#'+countCGS+' '+cg.Name));
                countCGS++;
            }
            if(mcg.newClientGorups.size() == 1){
                mcg.selectedNewCG = '#'+countCGS+' '+lstClientGroups[0].name.replace(' ','');
                isOneClient = true;
            }
            
        }
        
        Integer newCountGM = 1;
        
        for(MapGroupMember mgm : lstMappingGM){
            Integer oldCountGM = 1;
            Integer gmCounts = 1;
            Integer leadCGS = 1;
            for(Group_Member__c gm : lstGM){
                String name = '';
                gmCounts++;
                if(gm.GM_Salutation__c != null){
                    name += gm.GM_Salutation__c+' ';
                }
                if(gm.GM_First_Name__c != null){
                    name += gm.GM_First_Name__c+' ';
                }
                if(gm.GM_Last_Name__c != null){
                    name += gm.GM_Last_Name__c+' ';
                }
                if(mgm.oldGM.GM_Lead_Passenger__c && gm.GM_Lead_Passenger__c){
                    mgm.newGropMemberOption.add(new SelectOption(gm.GM_Contact__c+'#'+name.trim().replaceAll(' ',''), '#'+leadCGS+' '+name.trim()+'-['+gm.GM_Occupancy_Type__c+']'));
                    leadCGS ++;
                }
                if(!mgm.oldGM.GM_Lead_Passenger__c && !gm.GM_Lead_Passenger__c){
                    mgm.newGropMemberOption.add(new SelectOption(gm.GM_Contact__c+'#'+name.trim().replaceAll(' ',''), name.trim()+'-['+gm.GM_Occupancy_Type__c+']'));
                    oldCountGM ++;
                }
                
                if(oldCountGM == newCountGM && !gm.GM_Lead_Passenger__c){
                    mgm.selecteNewGM  = name ;
                }
            }
            if(mgm.newGropMemberOption.size() == 1){
                mgm.selecteNewGM = mgm.newGropMemberOption[0].getValue();
            }
            newCountGM ++;
        }
        
        if((lstGM.size() != oldGroupMemberCount) || (lstClientGroups.size() != oldClientGorupCount)){
            mapping = true;   
            String s = '';
            if(oldClientGorupCount > 1){
                s = 's';
            }
            String ss = '';
            if(oldGroupMemberCount > 1){
                ss = 's';
            }
            mappingMSG = 'The previous opportunity has '+oldClientGorupCount+' Client Group'+s+' and '+oldGroupMemberCount+' Group Member'+ss+ '.';
        }   
        
        if(oldClientGorupCount>oldGroupMemberCount){
            mappingMSG = 'Please configure your Itinerary completely';
        }
        
    }
    
    public void getContacts(){
        lstWrapperAdd = new List<holidayEnquiryWrapper>();
        //To get account contacts
        if(objCon.AccountId != null){
            for(Contact con : [Select id,Salutation,firstname,lastname,C_Middle_Name__c,AccountId, email,phone,Birthdate,C_Lead_Passenger__c ,
                Adult__c,C_Child__c,C_Infant__c,Occupancy_Type__c  from Contact where AccountId =: objCon.AccountId]){
                holidayEnquiryWrapper wc = new holidayEnquiryWrapper();
                wc.checked = true;
                wc.conWrapper = con ;
                lstWrapperAdd.add(wc);
            }
        }
    }
    
     List<contact> lstContacts = new List<Contact>();
     public void DoCreate(){
         try{
             lstContacts = new List<Contact>();
            if (objCon.AccountId != null && SelectedPax != null && SelectedPax != '' && SelectedPax != 'Select'){
                Integer PaxNumber = integer.valueof(SelectedPax) ;
                List<Contact> lstContact = [Select id,Salutation,firstname,lastname,email,phone,Birthdate,Occupancy_Type__c ,
                        Adult__c,C_Lead_Passenger__c ,C_Child__c,C_Infant__c,C_Middle_Name__c  from Contact where AccountId =: objCon.AccountId];
                Account acc = [Select Id, Name from Account where Id  = :objCon.AccountId];
                for(integer i=0; i<PaxNumber; i++){
                    Contact con = new Contact ();
                    holidayEnquiryWrapper wc = new holidayEnquiryWrapper();
                    wc.conWrapper = con ;
                    lstContacts.add(con);
                    //***Salutation, First Name and Last Name by default
                    Set<String> lstSalutation = new Set<String>{'Mr','Mrs','Miss','Ms','Mstr','Baron','Baroness','Capt','Dame','Dr','HRH','Lady','Lord','Prof','Rabbi','Rev','Sir','The Hon','The RT Hon','Viscount','Viscountess'};
                    List<String> accountName  = acc.name.Split(' ');
                    if(lstContact.size() == 0 && lstWrapperAdd.size() == 0){
                        if(lstSalutation.contains(accountName[0])){
                            con.salutation = accountName[0];
                            if(accountName.size() > 1){
                                con.firstName = accountName[1];
                                if(accountName.size() >= 2)
                                    con.lastname =  accountName[2];
                            }
                        }
                        else{
                            con.firstName = accountName[0];   
                            if(accountName.size() >= 1)
                                con.lastname =  accountName[1]; 
                        }
                        
                    }
                    else{
                        if(lstSalutation.contains(accountName[0])){
                            
                            if(accountName.size() > 1){
                                if(accountName.size() >= 2)
                                    con.lastname =  accountName[accountName.size()-1];
                            }
                        }
                        else{
                            con.lastname =  accountName[accountName.size()-1]; 
                        }   
                    }
                    
                    con.Occupancy_Type__c = 'Adult' ;
                    wc.checked = true ;    
                    lstWrapperAdd.add(wc);
                }
            }
            SelectedPax = 'Select';
            
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
        } 
    }
    
    List<Contact> listConMember;
    List<Contact> listConMemberSelected;
    public void saveContact(){           
        try{
            if(OpportunityType == 'same Client'){
                //Copy opportunity 
                DoCopy();  
            }
            else{
                upsert lstContacts;
                if(objCon.AccountId != null){
                    Set<String> conIds = new Set<String>(); 
                    listConMember = new List<Contact>();
                    listConMemberSelected = new List<Contact>();
                    
                    for(holidayEnquiryWrapper wc : lstWrapperAdd){
                        if(wc.conWrapper.AccountId == null)
                            wc.conWrapper.AccountId = objCon.AccountId;                  
                        if(wc.checked){
                            listConMemberSelected.add(wc.conWrapper);
                        }
                        else{
                            
                        }
                        listConMember.add(wc.conWrapper);
                    }
                    if (listConMember.size() > 0){
                        upsert listConMember;
                    }
                }
                if(OpportunityType == 'New Client without Cost' || step == 2){
                    //Copy opportunity 
                    DoCopy();  
                    step = 1;
                }
                else{
                    //Map Client Group
                    clientGorupMapping();    
                }
            }
        }
        catch(exception e){
           ApexPages.addMessages(e);  
        }    
    }
    
    public PageReference DoCopy(){
        checkedTypeFlag  =true;
        Utility.isCopied = true;
       
        try{
            for(Opportunity opp : [Select Id, AccountId, Name, Description, StageName, Amount, CloseDate, Type, NextStep, LeadSource, 
                                 IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, FiscalYear, 
                                 Fiscal, ContractId, DeliveryInstallationStatus__c, TrackingNumber__c, OrderNumber__c, CurrentGenerators__c, 
                                 MainCompetitors__c, Add_administrative_flight_information__c, Add_birthdays_and_other__c, Add_principal_dates_and_reservations__c,
                                  Adult_Old__c, Agent_Name__c, Ask_for_insurance_from_client__c, Ask_for_upgrades__c, Balance_paid_reminder__c, 
                                  Booking_Form_Received_Date__c, Booking_Form_Sent_Date__c, Budget_Note__c, O_Suggested_Margin_Value__c, Check_ATOL_issued_correctly__c, 
                                  Check_booking_form__c, Check_completed_tasks__c, Check_emergency_phone_list__c, Check_flight_booking__c, Check_supplier_confirmation__c, 
                                  Check_supplier_payments__c, Check_visa_and_inoculation_plann__c, Commission_Paid__c, Concierge_phone_call__c, Confirm_Supplier_arrangements__c,
                                   Confirmation_documents__c, Copy_of_Big_Short_Break_book__c, Costing_Type__c, Diarise_all_next_steps__c, Exchange_check__c, 
                                   First_night_tax__c, O_Flexibility_Details__c, GBP_Margin_Value__c, O_APC_Charges__c, O_APC_or_FFP_Non_Licensable_Charges__c, 
                                   O_ATOL__c, O_Agent_Commission_Amount__c, O_Agent_Commission_Due_Date__c, O_Agent_Commission_Type__c, O_Agent_Commission__c,
                                    O_Agent_Commission_percent__c, O_Agent_SC__c, O_Agent__c, O_Ancillary_Charges__c, O_Arrival_Presents__c, O_Arrival_gift__c, 
                                    O_Reference_Number__c, O_Automated_survey_opt_out__c, O_Bond_Type__c, O_Booking_Currency__c, O_Booking_Date__c, O_Booking_Month__c, 
                                    O_Booking_Number__c, O_Booking_Stat_Code__c, O_Booking_Week_Actual__c, O_Booking_Week__c, O_Booking_Year__c, O_Booking_to_Departure__c,
                                     O_Budget_End_Range__c, O_Budget_Start_Range__c, O_Budget__c, O_Charity__c, O_Charity_contribution__c, O_Child_Old__c, O_Cleaned_Data__c, 
                                     O_Company_Code__c, O_Continent__c, O_Converted_to_Booking__c, O_Converted_to_Quote__c, O_Country__c, O_Credit_Card_Charges_Amount__c, 
                                     O_Credit_Card_Charges_P__c, O_Credit_Card_Charges__c, O_Days_to_Departure__c, O_Departure_Date__c, O_Departure_Month__c, O_Departure_Year__c, 
                                     O_Display_Due_Date__c, O_Division__c, O_Due_By_Date__c, O_Due_Date__c, O_Duration_End_Days__c, O_Duration_Start_Days__c, O_EU__c, 
                                     O_Emergency_Contact_Number__c, O_Enquiry_Month__c, O_Enquiry_Week_Actual__c, O_Enquiry_Week__c, O_Enquiry_Year__c, O_Enquiry_to_Departure__c, 
                                     O_Enquiry_to_Quote__c, O_Exchange_Rate__c, O_FFP_Charges__c, O_FX_Transaction_Charges__c, O_FX_transfer_charges__c, O_Finders_Commission__c, 
                                     O_Flexiable_Date__c, O_Follow_Up_Time__c, O_HE__c, O_HolTypeCode__c, O_Holiday_Enquiry_Recap_Description__c, O_Holiday_Enquiry_Stage__c, 
                                     O_Holiday_Grouping__c, O_Holiday_Reason__c, O_Holiday_Type__c, O_Map_Type__c, O_Infant_Old__c, O_Insurance_Company__c, O_Insurance_Confirmation__c, 
                                     O_Itinerary_Cover_Name__c, O_Itinerary_Display_Price__c, O_Last_Payment__c, O_Lead_Email_Address__c, O_Lead_In__c, O_Live_Margin__c, 
                                     O_Lock__c, O_Margin_Warning__c, O_Margin__c, O_No_Notification__c, O_No_of_Nights__c, O_Original_COSTS__c, O_Original_Margin__c, 
                                     O_Original_Sales_Price__c, O_Owner_Name__c, O_Parent_Source__c, O_Pax__c, O_Pipeline_Notes__c, O_Policy_No__c, O_Pre_Booking__c, 
                                     O_Pre_Quote__c, O_Previous_Margin_Value__c, O_Previous_Total_Selling_Price__c, O_Quote_Date__c, O_Quote_Month__c, O_Quote_No__c,
                                      O_Quote_Week_Actual__c, O_Quote_Week__c, O_Quote_Year__c, O_Quote_to_Booking__c, O_Quote_to_Departure__c, O_Reason__c, O_Reminder__c, 
                                      O_Requested_Amount__c, O_Return_Date__c, O_Return_Month__c, O_Return_Year__c, O_School_holidays__c, O_Seasons__c, 
                                      O_Selling_Exchange_Rate__c, O_Selling_Price_in_GBP__c, O_Service_Team__c, O_Steps_Completed__c, O_Suggested_Margin__c, 
                                      O_Supplier_Payments__c, O_TOMS_Applicable_Margin__c, O_TOMS_Charges__c, O_TOMS_Post_Margin__c, O_TOTAL_COS_in_GBP__c, O_Taken_by__c, 
                                      O_Target_Mark_Up_Value__c, O_Target_Mark_Up__c, O_Tasks_Management__c, O_Team__c, O_Total_FFP_Charges__c, O_Total_Flight_Cost_in_GBP__c, 
                                      O_Total_Other_Charges__c, O_Total_Recommended_Selling_Price__c, O_Total_Regulatory_Cost__c, O_Ts_Cs__c, O_Type_2__c, O_Update__c, 
                                      O_Welcome__c, Obtain_required_information__c, Payment_queuing__c, Pipeline__c, Pre_holiday_phone_call_to_clients__c, 
                                      Prepare_and_send_Sharky_and_George_packs__c, Prepare_and_send_final_documents__c, Print_flight_documents__c, 
                                      Reconfirm_hotel_transfer_booking__c, Referral_hamper__c, Remind_consultants_of_pre_holiday_call__c, Request_invoice__c, 
                                      Responsible_for_supplier_payments__c, Return_questionnaire__c, Seat_check_and_online_check_in__c, Send_confirmation_documents__c, 
                                      Send_goodbye_email__c, Send_recommendations__c, Something_not_available__c, Take_balance_payment_and_issue_receipt__c, Taking_deposit__c,
                                       Thank_you_note__c, Update_departure_board__c, Update_in_house_records__c, Welcome_back_phonecall__c, Welcome_home_packs__c, O_Adult__c, 
                                       O_Children__c, O_Infant__c, O_Total_Credit_Card_Charges__c, O_Total_Payment__c, O_Total_Selling_Price__c, O_Outstanding__c, 
                                       O_Budget_specify__c, O_RecordType__c, O_Total_Payment_Without_CC__c, O_Deposit_Required1__c, O_Total_Payment1__c,
                                        O_Destination__c, O_Questionnaire_Completed__c, O_Include_Flight_Margin__c, O_Total_Flight_Cost__c, O_Destination_Map_Image_ID__c,
                                         O_Itinerary_At_Glance_Rows__c, O_Old_Markup_Value__c
            From Opportunity Where Id = :oppId Limit 1]){
                
                //Clone Opportinity Details
                oppMain= opp;
                copyOpp = opp.Clone(false,true); 
                copyOpp.Pipeline__c= true;
                copyOPP.StageName = 'Quote pending';
                copyOPP.Name = 'Test';
                if(OpportunityType != 'Same Client'){
                    copyOpp.accountId = objCon.AccountId;
                }
                copyOpp.CloseDate = system.Today();
                upsert copyOpp;
                
                Opportunity opp1 = [Select Id,O_Reference_Number__c from Opportunity where Id = :copyOpp.Id];
                opp1.Name = ''+opp1.O_Reference_Number__c;
                update opp1;
                
                
                pr = new PageReference('/apex/ItineraryBuilder?id=' + copyOpp.Id);
                
                
                
                
                // Clone Holiday suggestion Details
                
                List <Holiday_Suggestions__c> ListHS =  new List <Holiday_Suggestions__c>();
                
                for(Holiday_Suggestions__c hs:[select  Name, CurrencyIsoCode, HS_Opportunity__c, HS_Base_Cost__c, HS_Continent__c, 
                                                HS_Country__c, HS_Date_Time__c, HS_Day__c, HS_Holiday_Type__c, HS_Interest__c, 
                                                HS_Message__c, HS_Order__c, HS_Pax__c, HS_Supplier__c, HS_What_to_do__c, HS_When__c,
                                                 HS_Where_to_go__c, HS_Suggestion_Image__c from Holiday_Suggestions__c  where HS_Opportunity__c = : opp.Id ])
                {
                    
                    Holiday_Suggestions__c copyHS = new Holiday_Suggestions__c();
                    
                    copyHS = hs.clone(false,true,false,false);
                    copyHS.HS_Opportunity__c= copyOpp.Id;
                    
                    listHS.add(copyHS);
                    
                }
                
                if(listHS.size() > 0){
                    upsert listHS;
                }
                
                //Clone Travelling Country Records
                
                List <Travelling_Country__c> ListTC =  new List <Travelling_Country__c>();
                for(Travelling_Country__c tc:[select Name,TC_Country__c,TC_Cover_Image__c,TC_ImageID__c,
                TC_Opportunity__c,TC_Selected__c
                from Travelling_Country__c  
                where TC_Opportunity__c = : opp.Id ])
                {
                    
                    Travelling_Country__c copyTC = new Travelling_Country__c();
                    
                    copyTC = tc.clone(false,true,false,false);
                    copyTC.TC_Cover_Image__c = tc.TC_Cover_Image__c;
                    copyTC.TC_Opportunity__c= copyOpp.Id;
                    
                    listTC.add(copyTC);
                    
                }
                
                if(listTC.size() > 0){
                    upsert listTC;
                }
                
                
                //Clone Holiday Questions Records
                
                List <Holiday_Question__c> ListHQ =  new List <Holiday_Question__c>();
                
                for(Holiday_Question__c hq:[select Name,HQ_Answer__c,HQ_Opportunity__c,HQ_Order__c,HQ_Question__c,HQ_Account__c 
                from Holiday_Question__c  
                where HQ_Opportunity__c = : opp.Id ])
                {
                    
                    Holiday_Question__c copyHQ = new Holiday_Question__c();
                    
                    copyHQ = hq.clone(false,true,false,false);
                    copyHQ.HQ_Opportunity__c= copyOpp.Id;
                    
                    listHQ.add(copyHQ);
                    
                }
                
                if(listHQ.size() > 0){
                    upsert listHQ;
                }
                
                
                
                Map<String,Client_Group__c > mapOldClientGroup = new Map<String,Client_Group__c>();
                Map<String,Group_Member__c> mapGroupMembers = new Map<String,Group_Member__c>();
                //clone Group Member Details
                if(OpportunityType == 'Same Client'){
                    List <Group_Member__c> ListGM =  new List <Group_Member__c>();
                    
                    for(Group_Member__c gm:[select Id, Name, CurrencyIsoCode, GM_Opportunity__c, GM_Client_Group__c, GM_Client_Payment__c, 
                                            GM_Contact__c, GM_Email__c, GM_Lead_Passenger__c, GM_Occupancy_Type__c, GM_Name__c
                                            from Group_Member__c  where GM_Opportunity__c = : opp.Id ]){
                        Group_Member__c copyGM = new Group_Member__c();
                        copyGM = gm.clone(false,true,false,false);
                        copyGM.GM_Opportunity__c= copyOpp.Id;
                        listGM.add(copyGM);
                        mapGroupMembers.put(gm.Id,copyGM);
                    }
                    if(listGM.size() > 0){
                        upsert mapGroupMembers.values();
                    }
                    
                    //Clone Client Group Records
                    
                    List <Client_Group__c> ListCG =  new List <Client_Group__c>();
                    for(Client_Group__c cg:[select Id, Name, CurrencyIsoCode, CG_Opportunity__c, CG_Arrival_Presents__c, CG_Charity__c, 
                                            CG_FX_Transfer_Charges__c, CG_Lead_Group_Member__c, CG_Order__c, CG_Recommended_Selling_Price__c, 
                                            CG_Regulatory_Charges__c, CG_Selling_Price__c, CG_Total_Recommended_Selling_Price__c, 
                                            Previous_Recommended_Selling_Price__c, Recommended_Selling_Price__c, CG_Total_cost_in_selling_currency__c, 
                                            CG_Recommended_Selling_Price_Rp__c, CG_Deposit_Overwrite__c, CG_Total_Group_Members__c, CG_Total_Adult_Members__c, 
                                            CG_Total_Child_Members__c, CG_Exchange_Rate_GBP__c, CG_Deposit_Required_I__c, CG_Display_Price__c, 
                                            CG_Deposit_Required_II__c, CG_Total_Flight_Cost__c from Client_Group__c where CG_Opportunity__c = : opp.Id ]){
                        
                        Client_Group__c copyCG = new Client_Group__c();
                        copyCG = cg.clone(false,true,false,false);
                        if(mapGroupMembers.containsKey(cg.CG_Lead_Group_Member__c))
                        copycg.CG_Lead_Group_Member__c = mapGroupMembers.get(cg.CG_Lead_Group_Member__c).Id;
                        copyCG.CG_Opportunity__c= copyOpp.Id;
                        listCG.add(copyCG);
                        mapOldClientGroup.put(cg.Id,copyCG);
                    }
                    
                    if(mapOldClientGroup.size() > 0){
                        upsert mapOldClientGroup.values();
                    }
                    
                    List<Group_Member__c> insertClientGroup = new List<Group_Member__c>();
                    for(Group_Member__c gm : [select GM_Salutation__c,GM_Client_Group__c,GM_First_Name__c,GM_Last_Name__c,Name,GM_Opportunity__c,GM_Age__c,GM_Contact__c,GM_DOB__c,GM_Lead_Passenger__c,
                                             GM_Nationality__c,GM_Relationship__c,GM_Occupancy_Type__c,GM_Email__c,GM_Phone__c
                                             from Group_Member__c  where GM_Opportunity__c = : opp.Id]){
                        if(mapGroupMembers.containsKey(gm.Id)){
                            Group_Member__c gm1 =  mapGroupMembers.get(gm.Id);
                            if(mapOldClientGroup.containsKey(gm.GM_Client_Group__c)){
                                gm1.GM_Client_Group__c =  mapOldClientGroup.get(gm.GM_Client_Group__c).Id;
                            }
                            insertClientGroup.add(gm1);
                        }
                    }
                    update insertClientGroup;
                    //Clone Selected Itinerary Records
                    
                }
                else {
                    //Copied from HE page
                    // logic to add group members
                    Map<String, Group_Member__c> mapGroupMember = new Map<String,Group_Member__c>();
                    Integer counter = 0;
                    for(HolidayEnquiryWrapper wc : lstWrapperAdd){
                        if(wc.checked){
                            String conId = wc.conWrapper.id;
                            Group_Member__c gm = new Group_Member__c();
                            gm.GM_Opportunity__c = copyOpp.id;
                            gm.GM_Salutation__c = wc.conWrapper.Salutation ;
                            gm.GM_Contact__c = wc.conWrapper.Id ;
                            gm.GM_Lead_Passenger__c = wc.isLead ;
                            gm.GM_First_Name__c = wc.conWrapper.firstname ;
                            gm.GM_Last_Name__c = wc.conWrapper.lastname ;
                            gm.GM_Email__c = wc.conWrapper.email ;
                            gm.GM_Phone__c  = wc.conWrapper.phone ;
                            gm.GM_Occupancy_Type__c = wc.conWrapper.Occupancy_Type__c ;
                            gm.GM_Phone__c = wc.conWrapper.phone ;
                            gm.GM_DOB__c = wc.conWrapper.birthdate ;
                            String name = '';
                            if(gm.GM_Salutation__c != null){
                                name += gm.GM_Salutation__c+' ';
                            }
                            if(gm.GM_First_Name__c != null){
                                name += gm.GM_First_Name__c+' ';
                            }
                            if(gm.GM_Last_Name__c != null){
                                name += gm.GM_Last_Name__c+' ';
                            }
                            counter++;
                            mapGroupMember.put(wc.conWrapper.Id+'#'+name.trim().replaceAll(' ',''),gm);
                        }
                     }
                     insert mapGroupMember.values() ;
                    
                     //*** Client Group Section Starts ***//
                     Map<String, Client_Group__c> mapClientGroups = new Map<String,Client_Group__c>();
                     Map<String, Client_Group__c> mapGMCG = new Map<String,Client_Group__c>();
                     Integer countNCGS = 1;
                     for(Group_Member__c gm : mapGroupMember.values()){
                         if(gm.GM_Lead_Passenger__c){
                             Client_Group__c cg = new Client_Group__c();
                             cg.CG_Lead_Group_Member__c = gm.Id;
                             cg.name = gm.GM_First_Name__c +' '+ gm.GM_Last_Name__c ;
                             cg.CG_Opportunity__c = copyOpp.id;
                             mapClientGroups.put('#'+countNCGS+' '+cg.name.replace(' ',''),cg);  
                             mapGMCG.put(gm.Id,cg);
                             countNCGS++;
                         }
                     }
                     insert mapClientGroups.values();
                     
                     List<Group_Member__c> lstGMs = new List<Group_Member__c>();
                     for(Group_Member__c gm : mapGroupMember.values()){
                         if(mapGMCG.ContainsKey(gm.Id)){
                             gm.GM_Client_Group__c  =  mapGMCG.get(gm.Id).Id;
                             lstGMs.add(gm);
                         }    
                     }
                     update lstGMs;
                     //Map Client and Group Members
                     
                        
                     if(OpportunityType != 'New Client without Cost'){
                         Integer count = 1;
                         List<Client_Group__c> lstCGUpdate = new List<Client_Group__c>();
                         for(Client_Group__c cg:[select Name,CG_Arrival_Presents__c,CG_Lead_Group_Member__c , CG_Charity__c,CG_FX_Transfer_Charges__c,CG_Opportunity__c,
                            CG_Order__c,CG_Recommended_Selling_Price__c,CG_Recommended_Selling_Price_Rp__c,CG_Regulatory_Charges__c,
                            CG_Selling_Price__c,CG_Total_Recommended_Selling_Price__c
                            from Client_Group__c where CG_Opportunity__c = : opp.Id ]){
                             for(MapClientGorups mcg : lstMappingCG){
                                 if(mcg.oldClientGorupId  == cg.Id && mapClientGroups.containsKey(mcg.selectedNewCG)){
                                     Client_Group__c  copyCG = cg.clone(false,true,false,false);
                                     copyCG.Id = mapClientGroups.get(mcg.selectedNewCG).Id;
                                     copyCG.name = mapClientGroups.get(mcg.selectedNewCG).Name;
                                     for(MapGroupMember mgm : lstMappingGM){
                                         if(mgm.oldGM.Id == cg.CG_Lead_Group_Member__c){
                                             
                                             for(Group_Member__c gm : mapGroupMember.values()){
                                                 String name = '';
                                                 if(gm.GM_Salutation__c != null){
                                                     name += gm.GM_Salutation__c+' ';
                                                 }
                                                 if(gm.GM_First_Name__c != null){
                                                     name += gm.GM_First_Name__c+' ';
                                                 }
                                                 if(gm.GM_Last_Name__c != null){
                                                     name += gm.GM_Last_Name__c+' ';
                                                 }
                                                 String CGnamestr = '';
                                                 if(mgm.selecteNewGM.indexOf('#') != -1){
                                                     CGnamestr = mgm.selecteNewGM.split('#')[1];
                                                 }
                                                 if(name.trim().replaceAll(' ','') == CGnamestr){
                                                     copyCG.CG_Lead_Group_Member__c = gm.Id;
                                                     lstCGUpdate.add(copyCG);
                                                     mapOldClientGroup.put(cg.Id,copyCG);
                                                 }
                                             }
                                         }
                                         count++;
                                     }
                                     
                                 }
                                 
                             }
                         }
                         update lstCGUpdate;
                         
                        List<Group_Member__c> lstGMUpdate = new List<Group_Member__c>();
                        for(Group_Member__c gm : [select GM_Salutation__c,GM_Client_Group__c,GM_First_Name__c,GM_Last_Name__c,Name,GM_Opportunity__c,GM_Age__c,GM_Contact__c,GM_DOB__c,GM_Lead_Passenger__c,
                                                 GM_Nationality__c,GM_Relationship__c,GM_Occupancy_Type__c,GM_Email__c,GM_Phone__c
                                                 from Group_Member__c  where GM_Opportunity__c = : opp.Id]){
                            
                            for(MapGroupMember mcg : lstMappingGM){
                                Group_Member__c copyGM  = mapGroupMember.get(mcg.selecteNewGM);
                                if(mcg.oldGM.Id == gm.Id && mapOldClientGroup.containsKey(gm.GM_Client_Group__c)){
                                    copyGM.GM_Client_Group__c = mapOldClientGroup.get(gm.GM_Client_Group__c).Id;
                                    lstGMUpdate.add(copyGM);
                                }
                            }
                        }
                        update lstGMUpdate;
                    }
                }
                
                
                
                
                //****Deleting Selected ICC which is created by trigger  ***//
                Delete [Select Id from Selected_Itinerary_Content_Category__c where ICC_Opportunity__c = :copyOpp.Id];
                
                List <Selected_Itinerary_Content_Category__c> listSIC =  new List <Selected_Itinerary_Content_Category__c>();
                for(Selected_Itinerary_Content_Category__c sic:[select Name, CurrencyIsoCode, RecordTypeId, ICC_Opportunity__c, 
                                                                SICC_Itinerary_Content_Category__c, ICC_Image_ID__c, ICC_Page_No__c, 
                                                                SICC_message1__c, SICC_message__c from Selected_Itinerary_Content_Category__c  
                                                                where ICC_Opportunity__c = : opp.Id ]){
                    
                    Selected_Itinerary_Content_Category__c copySIC = new Selected_Itinerary_Content_Category__c();
                    
                    copySIC = sic.clone(false,true,false,false);
                    copySIC.ICC_Opportunity__c= copyOpp.Id;
                    
                    listSIC.add(copySIC);
                    
                }
                
                if(listSIC.size() > 0){
                    
                    system.debug('size of list SIC '+listSIC.size());  
                    upsert listSIC;
                }
                // Clone Supplier Booking Details
                
                
                List <Supplier_Booking__c> ListSB =  new List <Supplier_Booking__c>();
                
                Map<String, Supplier_Booking__c> mapOldSBIds = new Map<String,Supplier_Booking__c>();
                for(Supplier_Booking__c sb : [select Id, Name, RecordType.Name,CurrencyIsoCode, RecordTypeId, SB_Opportunity__c, SB_Adjustment__c, SB_Arrival_Airport_l__r.Name, 
                                            SB_Arrival_Terminal__c, SB_RecordType__c, SB_Show_Voucher__c, SB_Base_Currency__c, SB_Booking_No__c, 
                                            SB_Booking_Ref__c, SB_Booking_Status__c, SB_Carrier__c, SB_Check_In_Time__c, SB_Class__c, 
                                            SB_Commission_Due_Date__c, SB_Cost_Group__c, SB_Cost_PP__c, SB_Cost_Type__c, SB_Day__c, SB_Departure_Airport_l__r.Name,
                                             SB_Departure_Terminal__c, SB_Departure_Time__c, SB_Drop_off_Point__c, SB_Exchange_Rate_Look_Up__c, SB_Flight_No__c, 
                                             SB_Flight_Ref__c, SB_From_Date__c, SB_From_Place__c, SB_From_Station__c, SB_From_Time__c, SB_Ground_Handler__c, SB_Holiday_Suggestion__c, 
                                             SB_Holiday_Type__c, SB_Itinerary_Description__c, SB_Local_Arrangements_Content__c, SB_Lock__c, SB_Luggage_Note__c, SB_Margin__c, 
                                             SB_Length_of_Journey__c, SB_Name__c, SB_New_Page__c, SB_Night__c, SB_No_of_Rooms__c, SB_Not_Held__c, SB_Notes__c, SB_Pilot_Details__c, 
                                             SB_Option__c, SB_Order__c, SB_Own_Arrangement__c, SB_Pax_for_Costing__c, SB_Payment_Type__c, SB_Pickup_Point__c, SB_Provider_Telephone__c, 
                                             SB_Reservation_Confirmed__c, SB_Reservation_Ref__c, SB_Room_Details__c, SB_Room_Type__c, SB_Sales_Currency__c, SB_Selling_Price_Actual__c, 
                                             SB_Source__c, SB_Suggested_Margin__c, SB_Supplier_Name__c, SB_Supplier_Payment_Due_Date__c, SB_Supplier__c, SB_Ticket_No__c, SB_To_Date__c, 
                                             SB_To_Place__c, SB_To_Station__c, SB_To_Time__c, SB_Total_Vehicle__c, SB_Train__c, SB_Transfer_Car_Hire_Option__c, SB_Type__c, SB_Vehicle__c,
                                              SB_What_to_do__c, SB_Where_to_go__c, SB_Jet_Model__c, SB_Cost__c, SB_Duration__c, SB_Occupancy__c, SB_Meal_Basis__c, SB_Name_Of_Driver__c 
                                              , Sum_Margin__c, Total_Cost_Records__c, SB_Avrage_Margin__c, SB_Remove_Date_Title__c, SB_Remove_Images__c, SB_Remove_TextArea__c,
                                (Select ID,SC_Client_Group__c,SC_Client_Group__r.Name,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.CurrencyISOCode,
                                SC_Supplier_Booking__c,SC_Supplier_Booking__r.SB_Supplier__c,SC_Supplier_Booking__r.SB_Supplier__r.Name,
                                SC_Supplier_Booking__r.recordType.DeveloperName,SC_Supplier_Booking__r.recordType.Name,SC_Occupancy_Type__c,
                                SC_Occupancy_No__c,SC_Total_Net_CostSC__c,SC_Selected__c, SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c,SC_Option__c,  
                                SC_Total_Client_Group_Cost__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c,SC_Description__c
                                from Supplier_Costs__r order by SC_Supplier_Booking__r.SB_Supplier__r.Name,SC_Option__c,createdDate)   
                
                from Supplier_Booking__c  where SB_Opportunity__c = : opp.Id ])
                {
                    Supplier_Booking__c copySB = new Supplier_Booking__c();
                    copySB = sb.clone(false,true,false,false);
                    copySB.SB_Opportunity__c= copyOpp.Id;
                    listSB.add(copySB);
                    mapOldSBIds.put(sb.Id, copySB);
                }  
                
                if(listSB.size() > 0){
                    upsert listSB;
                } 
                
                if(OpportunityType != 'New Client without Cost'){
                    // Copy realted supplier cost of supplier booking
                    List <Supplier_Cost__c> ListSBC =  new List <Supplier_Cost__c>();    
                    
                    for(Supplier_Cost__c sbc : [Select Id, Name, CurrencyIsoCode, RecordTypeId, SC_Supplier_Booking__c, SC_Client_Group__c, 
                                                SC_Occupancy_No__c, SC_Cost__c, SC_Description__c, SC_Nights__c, SC_Adjustment__c, 
                                                SC_Commission_Out__c, SC_Exchange_Rate_Lookup__c, SC_Margin_Lookup__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c, 
                                                SC_Deposit_Required__c, SC_Occupancy_Type__c, SC_Outstanding_Payment_Amount__c, SC_Shared_Cost_Per_Night__c, 
                                                SC_Supplier_Cost_Payment__c, SC_Supplier_Currency__c, SC_Total_Client_Group_Cost__c, SC_Total_Net_CostSC__c, 
                                                SC_Total_Net_Cost_PP__c, SC_Type__c, SC_Option__c, SC_Selected__c, OpportunityId__c, SC_Margin_Type__c, SC_Margin_Value__c, 
                                                SC_Is_Flight_Cost__c,SC_Client_Group__r.Name,SC_Supplier_Cost_Payment__r.CurrencyISOCode, SC_Supplier_Booking__r.SB_Supplier__c,
                                                SC_Supplier_Booking__r.SB_Supplier__r.Name,SC_Supplier_Booking__r.recordType.DeveloperName,SC_Supplier_Booking__r.recordType.Name, 
                                                SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c from Supplier_Cost__c
                                                    where SC_Supplier_Booking__c in :mapOldSBIds.keySet() ]){
                        Supplier_Cost__c copySBC = new Supplier_Cost__c();
                        copySBC = sbc.clone(false,true,false,false);
                        copySBC.SC_Client_Group__c = mapOldClientGroup.get(sbc.SC_Client_Group__c).Id;
                        copySBC.SC_Supplier_Booking__c= mapOldSBIds.get(sbc.SC_Supplier_Booking__c).Id;
                        ListSBC.add(copySBC);            
                        
                    }
                    
                    if(ListSBC.size() > 0){
                        system.debug('listSBC size '+ListSBC.size());
                        upsert ListSBC;
                    }  
                    
                }
                
                if(listSB.size() > 0){
                    upsert listSB;
                    
                }
                List<String> sbIds = new List<String>();
                for(Supplier_Booking__c sbNew : listSB){
                    sbIds.add(sbNew.id);
                }
                Map<String,Integer> mapSBI = new Map<String,Integer>();
                /*for(SupplierBookingImage__c sbiNew : [Select Id,SBI_Supplier_Booking__c   from SupplierBookingImage__c where SBI_Supplier_Booking__c  in :sbIds]){
                    if(!mapSBI.containsKey(sbiNew.SBI_Supplier_Booking__c)){
                    mapSBI.put(sbiNew.SBI_Supplier_Booking__c,0);
                    }
                    mapSBI.put(sbiNew.SBI_Supplier_Booking__c,mapSBI.get(sbiNew.SBI_Supplier_Booking__c)+1);    
                }*/
                List<SupplierBookingImage__c > sbb = [Select Id,SBI_Supplier_Booking__c   from SupplierBookingImage__c where SBI_Supplier_Booking__c  in :sbIds];
                if(sbb.size() > 0)
                Delete sbb ;
                System.debug('FFFFFFFFFFFFFFFFFFFF'+[Select Id, SBI_Attachement_Id__c, SBI_Supplier_Booking__c from SupplierBookingImage__c where SBI_Supplier_Booking__c in :mapOldSBIds.keySet()]+'########'+mapOldSBIds);
                List<SupplierBookingImage__c> lstSBI = new List<SupplierBookingImage__c>();
                for(SupplierBookingImage__c SBI : [Select Id, SBI_Supplier_Booking__c, SBI_Attachement_Id__c, SBI_Image__c, SBI_Order__c,SBI_Supplier_Booking__r.RecordType.Name from SupplierBookingImage__c where SBI_Supplier_Booking__c in :mapOldSBIds.keySet()]){
                    
                    if(mapSBI.containsKey(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id )|| !mapSBI.containsKey(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c ).Id) ){
                        if(!mapSBI.containsKey(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id)){
                            mapSBI.put(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id,0);
                        }
                        if(SBI.SBI_Supplier_Booking__r.RecordType.Name != 'Accommodation'){
                            if(mapSBI.get(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id)<2){
                                SupplierBookingImage__c sbce = SBI.clone(false,true,false,false);
                                sbce.SBI_Supplier_Booking__c = mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id;
                                lstSBI.add(sbce);
                                mapSBI.put(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id,mapSBI.get(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id)+1);    
                            }
                        }
                        else{
                            SupplierBookingImage__c sbce = SBI.clone(false,true,false,false);
                            sbce.SBI_Supplier_Booking__c = mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id;
                            lstSBI.add(sbce);
                            mapSBI.put(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id,mapSBI.get(mapOldSBIds.get(SBI.SBI_Supplier_Booking__c).Id)+1);        
                        }
                    }
                }
                
                insert lstSBI;
                if(OpportunityType == 'Same Client'){
                    //## Clone Flight Booking 
                    List<Flight_Booking__c> lstFB = new List<Flight_Booking__c>();
                    for(Flight_Booking__c fb: [Select Id, FB_Group_Member__c, FB_Supplier_Booking__c from Flight_Booking__c where FB_Supplier_Booking__c in :mapOldSBIds.keySet()]){
                        Flight_Booking__c fbNew = new Flight_Booking__c(); 
                        if(mapGroupMembers.containsKey(fb.FB_Group_Member__c) && mapOldSBIds.containsKey(fb.FB_Supplier_Booking__c)){
                            fbNew = fb;
                            fbNew.Id = null;
                            fb.FB_Group_Member__c = mapGroupMembers.get(fb.FB_Group_Member__c).id;
                            fb.FB_Supplier_Booking__c  = mapOldSBIds.get(fb.FB_Supplier_Booking__c).Id;
                            lstFB.add(fb);
                        }
                    }    
                    
                    insert lstFB;  
                } 
                
                
                getAllOpportunity();
                //return pr;   
                
                if(OpportunityType == 'New Client without Cost'){
                    
                    return null;
                }
                
            }
            step = 1;
            return null;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()+'Line Number #'+ex.getStackTraceString()));  
            return null;
        }
        
        
    }
    
    public List<Opportunity> lstOfOpportunity{get; set;}
    
    public void getAllOpportunity(){
        Integer year = oppMain.O_Departure_Date__c.year();
        Integer month = oppMain.O_Departure_Date__c.month();
        String accountId = '';
        if(OpportunityType == 'Same Client'){
            accountId = oppMain.AccountId;
        }
        else{
            accountId = objCon.AccountId;
        }
        lstOfOpportunity = [Select Id,Name,Pipeline__c, CreatedDate, StageName, O_Departure_Date__c, O_Return_Date__c from Opportunity where CALENDAR_YEAR(O_Departure_Date__c)  = :year and  CALENDAR_MONTH(O_Departure_Date__c) = :month and AccountId = :accountId order by createdDate DESC];        
        
    }
    public pageReference saveOpp(){
       /*if(OpportunityType == 'Same Client'){
            update lstOfOpportunity ;
       }else{
            upsert copyOpp;
       }*/
       update lstOfOpportunity ;
        return pr ;
    }
    
    public class MapClientGorups{
        public String oldClientGorup{get; set;}
        public String oldClientGorupId{get; set;}
        public String selectedNewCG{get; set;}
        public List<SelectOption> newClientGorups{get; set;}
        
        public MapClientGorups(String oldCg, String oldcgId){
            oldClientGorup = oldCg;
            oldClientGorupId = oldcgId;
            selectedNewCG = '';
            newClientGorups = new List<SelectOption>();    
        }
    }
    
    public class MapGroupMember{
        public Group_Member__c oldGM{get; set;}
        public String selecteNewGM{get; set;}
        public List<SelectOption> newGropMemberOption{get; set;}
        
        public MapGroupMember(Group_Member__c oldGM){
            this.oldGM = oldGM;
            selecteNewGM = '';
            newGropMemberOption = new List<SelectOption>();    
        }
    }
    
    public class holidayEnquiryWrapper{
        public Boolean checked {get;set;}
        public Boolean isLead {get;set;}
        public Boolean gmId {get;set;}
        public Contact conWrapper {get;set;}
        
        
        public holidayEnquiryWrapper(){
            this.checked = false ;
            this.isLead = false;
            this.gmId = false;
        }
    } 
}
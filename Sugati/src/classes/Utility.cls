global  Class Utility{
    public Static Boolean changeCoverImage = true;
    public static boolean isCopied = false;
    public static boolean copyCost = false;
    public Utility(){}
    
    
    public Static String getNameSpacePrefix(){
        ApexClass cs =[select NamespacePrefix from ApexClass where Name ='Utility'];
        if(cs.NamespacePrefix != null){
            return  cs.NamespacePrefix+'__';
        }
        else{
            return  '';
        }
    }
    
    public static String getEmailBody(String pageName, Opportunity Opp, String templateName){
        String EmailBody='';
        Map<String, List<Holiday_Question__c>> mapCategoryQus = new Map<String, List<Holiday_Question__c>>();

        if(pageName.indexOf('Acknowledgement') != -1 || pageName.indexOf('Holiday Suggestions') != -1 || templateName.indexOf('Suggestion') != -1 || templateName.indexOf('Ack') != -1){
            for(Holiday_Question__c hq : [Select id,name,HQ_Answer__c,HQ_Order__c,HQ_Question__r.Q_Ack_Question_Title__c,HQ_Question__r.Q_Category__r.Name
                                         from Holiday_Question__c where (HQ_Opportunity__c =:Opp.Id OR HQ_Account__c =: Opp.AccountId) and HQ_Question__r.Q_Category__r.QC_Active__c = true and 
                                         (HQ_Question__r.Q_Holiday_Type__c = :Opp.O_Holiday_Type__c OR HQ_Question__r.Q_Holiday_Type__c = null) order by 
                                         HQ_Question__r.Q_Category__r.QC_Order__c, HQ_Question__r.Q_Order__c,HQ_Order__c]){            
                if(!mapCategoryQus.containsKey(hq.HQ_Question__r.Q_Category__r.Name)){
                    mapCategoryQus.put(hq.HQ_Question__r.Q_Category__r.Name, new List<Holiday_Question__c>());    
                }
                mapCategoryQus.get(hq.HQ_Question__r.Q_Category__r.Name).add(hq);
            }

        }
        if(pageName.indexOf('Acknowledgement') != -1 || pageName.indexOf('Holiday Suggestions') != -1 || templateName.indexOf('Suggestion') != -1 || templateName.indexOf('Ack') != -1){
            EmailBody = '<br/><ul style="list-style-type: square; margin-left: 40px;">';
            for(String cat : mapCategoryQus.keySet()){
                String catQuestions = '';
                for(Holiday_Question__c hq : mapCategoryQus.get(cat)){
                    if(hq.HQ_Question__r.Q_Ack_Question_Title__c != null){
                        catQuestions += '<li>'+hq.HQ_Question__r.Q_Ack_Question_Title__c+' - <Strong>'+hq.HQ_Answer__c+'</Strong></li>';
                    }
                }
                if(catQuestions != ''){
                    EmailBody += '<li>'+cat+'<ul style="list-style-type: square; margin-left: 40px;">'+catQuestions+'</ul>';
                }
            }
            if(Opp.Description != null && Opp.Description !=''){
               EmailBody  += '<li>Client Holiday Description - <Strong>'+Opp.Description+'</Strong></li>'; 
            }
            EmailBody += '</ul><br/>';
        }
        if(pageName.indexOf('Holiday Suggestions') != -1 || templateName.indexOf('Suggestion') != -1){
            List<Holiday_Suggestions__c> lstSuggestion = [select Id,HS_What_to_do__c,HS_Errata_Text__c,HS_Suggestion_Image__c,HS_What_to_do__r.Name,HS_Message__c,HS_Where_to_go__c,
                                                HS_Where_to_go__r.Name, HS_Supplier__c, HS_Supplier__r.Name from Holiday_Suggestions__c 
                                                where  HS_Opportunity__c = : Opp.Id order by HS_Order__c];
            if(lstSuggestion.size() > 0){
                EmailBody += '<div class="container" style="width:100%;display:block;">';
                for(Holiday_Suggestions__c  hs : lstSuggestion){
                    String wasName = '';
                    if(hs.HS_Where_to_go__c != null){
                        wasName = hs.HS_Where_to_go__r.Name;
                    }
                    if(hs.HS_What_to_do__c != null){
                        wasName = hs.HS_What_to_do__r.Name;
                    }
                    if(hs.HS_Supplier__c != null){
                        wasName = hs.HS_Supplier__r.Name;
                    }
                    EmailBody += '<div class="section" style="display:block;width:100%;float:left;">';
                        EmailBody += '<div class="picture" style="display:block; width:220px; margin-left:auto;margin-right:auto; float:left;"><img width="200" height="100" src="http://framework-email-developer-edition.eu5.force.com//servlet/servlet.FileDownload?file='+hs.HS_Suggestion_Image__c+'" />';
                        EmailBody += '<br/><br/></div>';
                        EmailBody += '<div class="text" style="display:block; width:auto;"><strong>'+wasName+'</strong>&nbsp;';
                        EmailBody += hs.HS_Message__c;
                        
                        if(hs.HS_Errata_Text__c != null){
                            EmailBody += '<p><Strong>Errata Text : </Strong>'+hs.HS_Errata_Text__c;
                        }
                        EmailBody += '</p></div>';
                    EmailBody += '</div><br style="clear:both;" />';
                }
                EmailBody += '</div><div style="clear:both;"/>';
            }
        }
        return EmailBody;
    }    
    
    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String[] bccRecipients,String templateApiName, String emailBody, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, String setSenderDisplayName, String setSubject, Attachment[] attachList ) {
          //  templateId   must be ID of an Email template
          //  targetObjId must be a Contact, User, Lead Id -- also used in merge fields of template recipient.xxxx
          //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
          //  fromId    if non null, use current user, otherwise, use this ID (most likely an org wide no reply id)
          //  bcc      not permitted when using templates
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
            
        Id templateId;  
        if(templateApiName != null){
            try {templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;}
            catch (Exception e) {
              //throw new UtilException('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + 
              //              ' refer to Setup | Communications Templates ' + templateApiName);
            }
        }
        
        Set<String> toEmails = new Set<String>();
        toEmails.addAll(toRecipients);
        Boolean isLeadPresentInTo = false;
        for(Contact con : [Select Id, Email from Contact where Id = :targetObjId]){
            if(toEmails.contains(con.email)){
                isLeadPresentInTo = true;
            }        
        }
        
        // Create the email attachment
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for(Attachment att : attachList){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.body);
            attachments.add(efa);
        }
        
        //toRecipients.add('navals@appcino.com');
        email.setToAddresses(toRecipients);
        email.setCcAddresses(ccRecipients);
        //email.setBccAddresses(bccRecipients);
        email.setSenderDisplayName(setSenderDisplayName);
        email.setSubject(setSubject);
        if(isLeadPresentInTo){
            email.setTargetObjectId(targetObjId);
        }
        email.setWhatId(whatId);
        email.setorgWideEmailAddressId(orgWideEmailId);
        if(attachments.size() > 0){
            email.setFileAttachments(attachments);
        }
        if(templateApiName != null){
            email.setTemplateId(templateId);
        }
        else{
            email.setHTMLBody(emailBody);
        }
        email.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users
        
        System.debug(LoggingLevel.INFO,'** entered sendTemplatedEmail, to:' + toRecipients + ' cc:' + ccRecipients +  ' templateId:' + templateId + ' tagetObjId:' + targetObjId + 
                        ' whatId:' + whatId + ' orgWideEmailId: ' + orgWideEmailId);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return;
        }
        catch (EmailException e) {
            System.assert(false, e.getMessage());
        }
    }  
    
    
   //Describe SObject for picklist type fields
   public static Map<String, Set<pickListValue>> describePickLists(String ObjectApi_name){
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
                        }
                        List<Schema.PicklistEntry> ple = field_map.get(fieldName).getDescribe().getPicklistValues();
                        
                        for( Schema.PicklistEntry f : ple){
                            //pickListValue pkc = new pickListValue(f.getValue(),f.getLabel());
                            pickListValue pkc;
                            if(fieldName.contains('__c')){
                                pkc = new pickListValue(f.getLabel(),f.getLabel());
                            }
                            else if(fieldName == 'CurrencyISOCode'){
                                pkc = new pickListValue(f.getValue(),f.getValue());
                            }
                            else{
                                pkc = new pickListValue(f.getValue(),f.getLabel());
                            }
                            pickList.get(fieldName).add(pkc);
                       }   
                   }
                }    
            }
        }
        return pickList;
    }
    
    public static Map<String, Set<Schema.PicklistEntry>> describePickListsStr(String ObjectApi_name){
        Map<String, Set<Schema.PicklistEntry>> pickList = new Map<String, Set<Schema.PicklistEntry>>();
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
                            pickList.put(fieldName, new Set<Schema.PicklistEntry>());
                        }
                        List<Schema.PicklistEntry> ple = field_map.get(fieldName).getDescribe().getPicklistValues();
                        
                        for( Schema.PicklistEntry f : ple){
                            //pickListValue pkc = new pickListValue(f.getValue(),f.getLabel());
                            /*pickListValue pkc;
                            if(fieldName.contains('__c')){
                                pkc = new pickListValue(f.getLabel(),f.getLabel());
                            }
                            else if(fieldName == 'CurrencyISOCode'){
                                pkc = new pickListValue(f.getValue(),f.getValue());
                            }
                            else{
                                pkc = new pickListValue(f.getValue(),f.getLabel());
                            }*/
                            pickList.get(fieldName).add(f);
                       }   
                   }
                }    
            }
        }
        return pickList;
    }
    
    public static Map<String,List<Schema.FieldSetMember>> readFieldSet(String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Map<String,List<Schema.FieldSetMember>> mapFieldsOfFieldSet = new Map<String,List<Schema.FieldSetMember>>();
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        for(String fSetName : DescribeSObjectResultObj.FieldSets.getMap().KeySet()){
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fSetName);
            mapFieldsOfFieldSet.put(DescribeSObjectResultObj.FieldSets.getMap().get(fSetName).getLabel(),fieldSetObj.getFields());
            
        }
        return mapFieldsOfFieldSet; 
    } 
    public static Map<String, Account> getAccounts(Set<String> requiredFields, String whereClause){
        Map<String, Account> accMap = new Map<String, Account>();
        try{
                //Map<String, Schema.SObjectTypeFields> fieldsDesMap = Account.SObjectType.getDescribe().fields.getMap();
                //List<String> fields = new List<String>(Account.SObjectType.getDescribe().fields.getMap());
                String fieldNames = '';
                boolean isFirst = true;   
                List<String> queriedFilds =  new List<String>();
                Map<String, Schema.SObjectField> fMap = Account.SObjectType.getDescribe().fields.getMap();
                list<string> selectFields = new list<string>();
                
                if (fMap != null){
                    for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                        Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                        if(String.valueOf(fd.getType()) !=  'Address' && !requiredFields.contains(fd.getName().toLowerCase()))
                            queriedFilds.add(fd.getName());    
                    }
                }
                queriedFilds.addAll(requiredFields);
                
                String soql = ''
                        + ' select ' + String.join(queriedFilds, ',')
                        + ' from Account'
                        + ' where '+whereClause;
                
                for (Account acc : Database.query(soql)) {
                    accMap.put(acc.id, acc);    
                }
           }
           catch(Exception e){
               System.assert(false, e.getLineNumber()+ '******' +e.getStackTraceString()+ '******' +e.getMessage());    
           }
           return accMap;
    }
    
    public static Map<String, Lead> getLeads(Set<String> requiredFields, String whereClause){
        Map<String, Lead> accMap = new Map<String, Lead>();
        try{
                //Map<String, Schema.SObjectTypeFields> fieldsDesMap = Account.SObjectType.getDescribe().fields.getMap();
                //List<String> fields = new List<String>(Account.SObjectType.getDescribe().fields.getMap());
                String fieldNames = '';
                boolean isFirst = true;   
                List<String> queriedFilds =  new List<String>();
                Map<String, Schema.SObjectField> fMap = Lead.SObjectType.getDescribe().fields.getMap();
                list<string> selectFields = new list<string>();
                
                if (fMap != null){
                    for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                        Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                        if(String.valueOf(fd.getType()) !=  'Address' && !requiredFields.contains(fd.getName().toLowerCase()))
                            queriedFilds.add(fd.getName());    
                    }
                }
                queriedFilds.addAll(requiredFields);
                
                String soql = ''
                        + ' select ' + String.join(queriedFilds, ',')
                        + ' from Lead'
                        + ' where '+whereClause;
                //System.assert(false, soql);
                for (Lead acc : Database.query(soql)) {
                    accMap.put(acc.id, acc);    
                }
           }
           catch(Exception e){
               System.assert(false, e.getLineNumber()+ '******' +e.getStackTraceString()+ '******' +e.getMessage());    
           }
           return accMap;
    }
    public static List<Task> getTasks(Set<String> requiredFields, String whereClause){
        try{
            String fieldNames = '';
            boolean isFirst = true;   
            List<String> queriedFilds =  new List<String>();
            Map<String, Schema.SObjectField> fMap = Task.SObjectType.getDescribe().fields.getMap();
            list<string> selectFields = new list<string>();
            
            if (fMap != null){
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if(String.valueOf(fd.getType()) !=  'Address' && !requiredFields.contains(fd.getName().toLowerCase())){
                        queriedFilds.add(fd.getName());    
                    }        
                }
            }
            queriedFilds.addAll(requiredFields);
            String soql = ''
                        + ' select ' + String.join(queriedFilds, ',')
                        + ',Preference__r.HQ_Question__c from Task'
                        + ' where '+whereClause;
            //System.assert(false,soql);
            return Database.query(soql);
        }
        catch(Exception e){
           System.assert(false, e.getLineNumber()+ '******' +e.getStackTraceString()+ '******' +e.getMessage()); 
           return null;   
        }
     }
    
     public static List<Client_Payment__c > updatePayeeFieldOfClientPayment(Set<String> groupMembers,  LIST<Client_Payment__c> lstcp){
        Set<String> setOfClientGroup = new Set<String>();
        List<Client_Payment__c > lstClientPayment = new List<Client_Payment__c>();
        String returnId = '';
        for(Group_Member__c gm : [Select Id,GM_Client_Group__c from Group_Member__c where Id in :groupMembers]){
            setOfClientGroup.add(gm.GM_Client_Group__c);
        }
        if(setOfClientGroup.size()== 1){
            for(Client_Payment__c cp : lstcp){
                for(String cgId : setOfClientGroup)
                    cp.CP_Payee__c =  cgId;
                Map<String,String> mapGMContact = new Map<String,String>();
                Map<String,String> mapGMContactEmail = new Map<String,String>();
                for(Group_Member__c gm : [Select Id, GM_Contact__c, GM_Client_Group__c,GM_Contact__r.Email from Group_Member__c  where GM_Client_Group__c  = :cp.CP_Payee__c and GM_Lead_Passenger__c = true]){
                    mapGMContact.put(gm.GM_Client_Group__c, gm.GM_Contact__c); 
                    if(gm.GM_Contact__r.Email != null)
                        mapGMContactEmail.put(gm.GM_Client_Group__c, gm.GM_Contact__r.Email);   
                }
               
                if(cp.CP_Payee__c != null && mapGMContact.containsKey(cp.CP_Payee__c)){
                    cp.CP_Contact__c = mapGMContact.get(cp.CP_Payee__c) ;
                    if(mapGMContactEmail.containsKey(cp.CP_Payee__c))
                        cp.CP_Client_Email__c = mapGMContactEmail.get(cp.CP_Payee__c) ;
                }
                lstClientPayment.add(cp);
            }
               
        }
        return lstClientPayment;    
    }
    
    //TO Check Internal User or not
    public static Boolean isInternalUser() {
        Profile p = [select id, name from profile where id =:Userinfo.getProfileID() ];
        if (p.name.contains('Original Travel Profile')) {
            return false;
            
        }
        return true;
    }
    //Save Opportunity Steps
    public static void saveSteps(string OppId, integer stepNumber) {
        try{
            List<Opportunity> opps = [select id,O_Steps_Completed__c from Opportunity where id =: OppId ];
            if (opps.size() > 0) {
                /*
                if(stepNumber == 5 && opps[0].Booking_Form_Received_Date__c == null){
                    opps[0].Booking_Form_Received_Date__c = System.today();
                }
                */
                if (opps[0].O_Steps_Completed__c != '' && opps[0].O_Steps_Completed__c != null) {
                    //4<5
                    if (integer.valueOf(opps[0].O_Steps_Completed__c ) < stepNumber) {
                        opps[0].O_Steps_Completed__c = stepNumber+'';
                        update opps;
                    }
                }
                else {
                    opps[0].O_Steps_Completed__c = stepNumber+'';
                    update opps;
                }
                
            }
        }
        Catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    
    // Finding MinDate And MaxDate From A List 
    public static List<Date> FindMinMaxDate(Set<Date> lstDates){
        Date MinDate;
        Date MaxDate;
        for(Date dt : lstDates){
            if(MinDate == null){
                MinDate = dt;
            }
            if(MaxDate == null){
                MaxDate = dt;
            }
            
            if(MinDate > dt){
                MinDate = dt;
            }
            if(MaxDate < dt){
                MaxDate = dt;
            }
        }
        List<Date> retLstDates = new List<Date>();
        retLstDates.add(MinDate);
        retLstDates.add(MaxDate);
        return retLstDates;
    }
    
    //Get Exchange Rate for Opportunities
    public static Map<String, Map<String,Exchange_Rate__c>> getExchangeRates(List<String> oppIds){
        Map<String, Map<String,Exchange_Rate__c>> exchangeRateByCurrency = new Map<String, Map<String,Exchange_Rate__c>>();
        Set<Date> setOfDepartureDates = new Set<Date>();
        Set<Date> setOfCloseDates = new Set<Date>();
        Set<String> setOfSellingCurency = new Set<String>();
        //Load Opportunities
        List<Opportunity> lstOpportunities = [Select id,(Select Id, Name, TC_Country__c, TC_Country__r.Name from Travelling_Countries__r),
                                CloseDate,CurrencyISOCode,CreatedDate,O_Departure_Date__c from Opportunity where Id in :oppIds];
        //Put data in all sets
        for(Opportunity opp : lstOpportunities){
            setOfDepartureDates.add(opp.O_Departure_Date__c);
            setOfCloseDates.add(opp.CloseDate);
            setOfSellingCurency.add(opp.CurrencyISOCode);
        }
        //Get minimum and maximum close and departure date.
        List<Date> lstMinMaxDPDate = Utility.FindMinMaxDate(setOfDepartureDates);
        List<Date> lstMinMaxCloseDate = Utility.FindMinMaxDate(setOfCloseDates);
        //Get exchange and margin                        
        List<Exchange_Rate__c> fullExchangeRate = SOQLServices.getExchangeRate(setOfSellingCurency,lstMinMaxCloseDate,lstMinMaxDPDate,'Sell');
        List<Margin__c> fullMargin = SOQLServices.getMargin(lstMinMaxCloseDate,lstMinMaxDPDate);
        
        
        //Calculate exchange rate and margin for supplier cost.
        for(Opportunity opp : lstOpportunities){
            Map<String,Exchange_Rate__c> childExr = new Map<String,Exchange_Rate__c>();
            Set<String> travellingCountryIds = new Set<String>();
            Margin__c mmg = new Margin__c();
            
            for(Exchange_Rate__c er : fullExchangeRate){
                if((er.ER_Sales_Currency__c == opp.CurrencyISOCode) 
                  && opp.closeDate >= er.ER_Book_From__c && opp.closeDate <= er.ER_Book_To__c && opp.O_Departure_Date__c >= er.ER_Travel_From__c &&
                  opp.O_Departure_Date__c <= er.ER_Travel_To__c){
                      childExr.put(er.ER_Base_Currency__c,er);    
                }
            }
            for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                travellingCountryIds.add(tc.TC_Country__c);
            }
            exchangeRateByCurrency.put(opp.Id, childExr);
        }
        return exchangeRateByCurrency;
    }
    
    //Return opp by updating stageName
    public Static Opportunity UpdateOppStage(Opportunity opp, String templateName, String EmailTempName){
        if((EmailTempName.indexOf('Itinerary Pdf') != -1 || templateName.indexOf('Itinerary Pdf') != -1) && (opp.StageName == 'Enquiry' || opp.StageName == 'Quote pending')){
            opp.StageName = 'Quoted to client';
        }
        else if((EmailTempName.indexOf('Booking Form') != -1  || templateName.indexOf('Booking Form') != -1)  && (opp.StageName == 'Enquiry' || opp.StageName == 'Quote pending' || opp.StageName == 'Quoted to client')){
            opp.StageName = 'Booking Optional';
        }
        
       
        return opp;
    }
    
    public static List<Selectoption> getBankAccounts() {
        List<Selectoption> bankAccounts = new List<Selectoption>();
        bankAccounts.add(new Selectoption ('', '-Select-'));
        bankAccounts.add(new Selectoption ('All', 'All'));
        for (Bank_Account__c ba: [select id, name from Bank_Account__c order by name]) {
           bankAccounts.add(new Selectoption (ba.id, ba.name));

        }
        return bankAccounts ;
    }
    
    public static List<Selectoption> getPaymentMethods() {
        List<Selectoption> paymentMethods = new List<Selectoption>();
        paymentMethods.add(new Selectoption ('', '-Select-'));
        paymentMethods.add(new Selectoption ('All', 'All'));
        paymentMethods.add(new Selectoption ('Cash', 'Cash'));
        paymentMethods.add(new Selectoption ('Cheque', 'Cheque'));
        paymentMethods.add(new Selectoption ('Transfer', 'Transfer'));
        return paymentMethods;
    }
    
    
    public class picklistValue{
        String label {get; set;}
        String value {get; set;}
        
        public picklistValue(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
    
    @future
    public static void fillCostForSecAccounts(Set<String> oppIds){
        List<Client_Group__c> lstCG = [Select Id,CG_Total_Infant_Members__c,CG_Total_Adult_Members__c,CG_Total_Child_Members__c
                                         from Client_Group__c where CG_Opportunity__c in :oppIds and Cost_Autofill__c = false and CG_Opportunity__r.O_Is_Group_Booking__c = true and CG_Lead_Group_Member__r.GM_Contact__r.AccountId != :Label.GroupBooking ];
        
        List<Supplier_Cost__c> lstCosts = new List<Supplier_Cost__c>();
        if(lstCG.size() > 0 && Label.GroupBooking != null){
            
            for(Supplier_Cost__c sc : [Select id,SC_Type__c,SC_Shared_Cost_Per_Night__c ,SC_Total_Net_Cost_PP__c ,SC_Client_Group__c,SC_Client_Group__r.Name,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.CurrencyISOCode,
                                SC_Supplier_Booking__c,SC_Occupancy_Type__c,SC_Occupancy_No__c,SC_Total_Net_CostSC__c,SC_Selected__c, SC_Exchange_Rate_Lookup__c,SC_Option__c,  
                                SC_Total_Client_Group_Cost__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c,SC_Description__c from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c in :oppIds and SC_Client_Group__r.CG_Lead_Group_Member__r.GM_Contact__r.AccountId = :Label.GroupBooking]){
                for(Client_Group__c cg : lstCG){
                    Supplier_Cost__c clonedSC = sc.clone(false, true, false, false);    
                    if((clonedSC.SC_Occupancy_Type__c == 'Adult' && cg.CG_Total_Adult_Members__c != 0) || 
                            (clonedSC.SC_Occupancy_Type__c == 'Child' && cg.CG_Total_Child_Members__c != 0)|| 
                            (clonedSC.SC_Occupancy_Type__c == 'Infant' && cg.CG_Total_Infant_Members__c != 0)){
                        clonedSC.SC_Client_Group__c = cg.Id;
                        if(clonedSC.SC_Occupancy_Type__c == 'Adult' && cg.CG_Total_Adult_Members__c != 0){
                            clonedSC.SC_Occupancy_No__c = cg.CG_Total_Adult_Members__c;
                        }
                        else if(clonedSC.SC_Occupancy_Type__c == 'Child' && cg.CG_Total_Child_Members__c != 0){
                            clonedSC.SC_Occupancy_No__c = cg.CG_Total_Child_Members__c;
                        }
                        else if(clonedSC.SC_Occupancy_Type__c == 'Infant' && cg.CG_Total_Infant_Members__c != 0){
                            clonedSC.SC_Occupancy_No__c = cg.CG_Total_Infant_Members__c;
                        }
                        if(sc.SC_Shared_Cost_Per_Night__c != null){
                            clonedSC.SC_Shared_Cost_Per_Night__c = clonedSC.SC_Occupancy_No__c*sc.SC_Shared_Cost_Per_Night__c;
                        }
                        if(sc.SC_Total_Net_Cost_PP__c != null){
                            if(clonedSC.SC_Shared_Cost_Per_Night__c != null && clonedSC.SC_Nights__c != null){
                                clonedSC.SC_Total_Net_Cost_PP__c = (clonedSC.SC_Shared_Cost_Per_Night__c*clonedSC.SC_Nights__c)/clonedSC.SC_Occupancy_No__c;
                            }
                        }
                        clonedSC.SC_Total_Client_Group_Cost__c = clonedSC.SC_Total_Net_Cost_PP__c*clonedSC.SC_Occupancy_No__c;
                        lstCosts.add(clonedSC);
                    }
                }
            }
            Utility.isCopied = true;
            insert lstCosts;
            for(Client_Group__c cg : lstCG ){
                cg.Cost_Autofill__c  = true;
            }
            update lstCG ;
        }    
    }
}
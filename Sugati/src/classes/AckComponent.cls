public with sharing Class AckComponent{

    
    public Opportunity opp{get; set;}
    public String emailAddresses{get; set;}
    public String emailW{get; set;}
    public String emailBody{get; set;}
    public EmailTemplate emailTemp{get; set;}
    public String getEmailW{get; set;}
    public String pageName{get; set;}
    public String oppRecords{get; set;}
    public transient String autoSuggestTime{get; set;}
    public String nameSpacePrefix{get;set;}
    
    String oppId;
    List<pickListValue> mapEmail = new List<pickListValue>();
    public AckComponent() {
        oppId = ApexPages.CurrentPage().getParameters().get('Id');
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        if(oppId != null && oppId.startsWith('006')){
            opp = [Select Id, Name, O_Departure_Date__c,AccountId from Opportunity where Id = :oppId ];  
            if(opp.O_Departure_Date__c != null){
                Integer year = opp.O_Departure_Date__c.year();
                Integer month = opp.O_Departure_Date__c.month();
                List<Opportunity> lstOpp =  [Select Id,Name,O_Holiday_Type__c,Pipeline__c, CreatedDate, StageName, O_Departure_Date__c, O_Return_Date__c 
                                            from Opportunity where Id != :opp.Id and CALENDAR_YEAR(O_Departure_Date__c)  = :year and  
                                            CALENDAR_MONTH(O_Departure_Date__c) = :month and AccountId = :opp.AccountId order by 
                                            createdDate DESC];
                oppRecords = JSON.serialize(lstOpp);
            }
            else{
                oppRecords = '[]'; 
            }
        }
        pageName = getVFPageName();
        if(pageName.indexOf('sugati__') != -1){
            pageName = pageName.subString(8,pageName.length());
        }
        
        getEmailW = JSON.serialize(new EmailWrapper(''));    
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
    
    
    
    public string getVFPageName()  {
        // THIS IS THE CLOSEST YOU CAN GET SO FAR
        String pageName = ApexPages.CurrentPage().getUrl();  
        // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
        // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
        string[] pageNameExtra = pageName.split('%3F',0);   
        // SO YOU MAY SPLIT THE STRING AT THAT POINT
          // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
        // IN THE RESULTING ARRAY
        pageName = pageNameExtra[0]; 
        // HERE IS YOUR PRODUCT  
        system.debug('pageName-->'+pageName);                       
        return pageName;                                        
    }
    
    
    //Fetch all the Page Messages
    @remoteAction
    public static Map<string, String> getErrorMessages(String pagename) {
        return ErrorMessageController.getErrorMessage(pagename);
    }
    
    @remoteAction
    public static List<Opportunity> getOppRecords(String oppId) {
        if(oppId != '' && oppId.startsWith('006')){
            Opportunity opp = [Select Id,O_Departure_Date__c,AccountId from Opportunity where Id = :oppId ];  
            Integer year = opp.O_Departure_Date__c.year();
            Integer month = opp.O_Departure_Date__c.month();
            List<Opportunity> lstOpp =  [Select Id,Name,Pipeline__c, CreatedDate, StageName, O_Departure_Date__c, O_Return_Date__c 
                                        from Opportunity where Id != :opp.Id and CALENDAR_YEAR(O_Departure_Date__c)  = :year and  
                                        CALENDAR_MONTH(O_Departure_Date__c) = :month and AccountId = :opp.AccountId order by 
                                        createdDate DESC];
            
            return lstOpp;
        }
        else{
            return null;    
        }
    }
    
    @remoteAction
    public static List<pickListValue> getContact(String oppId) {
        if(oppId != null && oppId != '' && oppId.startsWith('006')){
            Opportunity opp = [Select Id, AccountId from Opportunity where Id = :oppId];    
            List<pickListValue> mapEmail = new List<pickListValue>();
           /* for(Contact con : [Select Id, FirstName, LastName, Email from Contact Where AccountId = :opp.AccountId]){
                if(con.Email != null){
                    mapEmail.add(new pickListValue(con.Email,con.FirstName+' '+con.LastName+' ('+con.Email+')'));
                }
            }*/
            for(Group_Member__c gm : [SELECT Id,GM_Contact__r.FirstName,GM_Contact__r.LastName,GM_Contact__r.Email from Group_Member__c where GM_Opportunity__c=: oppId and GM_Contact__r.Email!=null]){
            
                mapEmail.add(new pickListValue(gm.GM_Contact__r.Email,gm.GM_Contact__r.FirstName+' ('+gm.GM_Contact__r.Email+')'));
            }
            for(User us : [Select Id,Email,Name from User where IsActive = true]){
                mapEmail.add(new pickListValue(us.Email,us.Name+' ('+us.Email+')'));
            }
            for(Supplier_Booking__c sb : [Select Id,SB_Supplier__r.Name,SB_Supplier__r.S_Email__c from Supplier_Booking__c where SB_Opportunity__c = :oppId  and SB_Supplier__r.S_Email__c != null]){
                mapEmail.add(new pickListValue(sb.SB_Supplier__r.S_Email__c,sb.SB_Supplier__r.Name+' ('+sb.SB_Supplier__r.S_Email__c+')'));
            }
            return mapEmail;
        }
        else{
            return new List<pickListValue>();
        }
    }
    @remoteAction
    public static EmailWrapper getTemplate(String oppId, String templateName, String pageName) {
        try{
            if(oppId != null && oppId.startsWith('006')){
                EmailWrapper ew;
                Group_Member__c  leadGM;
                String contactId;
                List<Group_Member__c> gmCCList = new List<Group_Member__c >();
                List<Opportunity> lstOpp = [Select ID,AccountId,Description,O_Holiday_Type__c from Opportunity where Id = :oppId];
                for(Group_Member__c gm : [Select Id,GM_Contact__c,GM_Contact__r.Account.A_First_Name__c, GM_Contact__r.Account.A_Last_Name__c,
                                                GM_Contact__r.FirstName,GM_Contact__r.LastName, GM_Contact__r.Email,GM_Lead_Passenger__c from Group_Member__c where 
                                                GM_Opportunity__c = :oppId]){
                                                
                    if(gm.GM_Lead_Passenger__c) {                           
                        if(gm.GM_Contact__r.Account.A_First_Name__c.trim() == gm.GM_Contact__r.FirstName.trim() && gm.GM_Contact__r.Account.A_Last_Name__c.trim() == gm.GM_Contact__r.LastName.trim()){
                            leadGM = gm;
                            contactId = gm.GM_Contact__c;
                        }                            
                        if(leadGM  == null && gm.GM_Contact__r.Email != null){
                            leadGM = gm;
                            contactId = gm.GM_Contact__c;
                        }    
                    }else{
                       if(gm.GM_Contact__r.Email != null){
                           gmCCList.add(gm);
                       }
                     }
                }
                List<Email_Template__c> et = [Select Id,ET_Email_Closing__c,ET_Email_Intro__c,ET_Template_Name__c,ET_Page_Section__c,To_Address_Filter__c
                                                 from Email_Template__c where ET_Page_Section__c = :templateName and ET_User__c = :UserInfo.getUserId()];
                if(et.size() == 0){
                    et = [Select Id,ET_Email_Intro__c,ET_Email_Closing__c,ET_Template_Name__c,ET_Page_Section__c,To_Address_Filter__c
                             from Email_Template__c where ET_Page_Section__c = :templateName and ET_User__c = null];
                }
                if(et.size() > 0){
                    List<EmailTemplate>  emailTemp = [Select id,HtmlValue,Subject from EmailTemplate where name = :et[0].ET_Template_Name__c];
                    if(emailTemp.size() > 0 && contactId != null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[]{'veer@appssential.com'};
                        mail.setToAddresses(toAddresses);
                        mail.setUseSignature(false);
                        mail.setSaveAsActivity(false);
                        mail.setSenderDisplayName('MMPT');
                        mail.setTargetObjectId(contactId);
                        mail.setWhatId(oppId);
                        mail.setTemplateId(emailTemp[0].Id);
                        Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                        Database.rollback(sp);
                        String mailTextBody = mail.getPlainTextBody();
                        String emailBody = mail.getHTMLBody();
                        String compileCSS = '';
                        for(CSS_Styler__c cssdata : [Select id , Email__c,Typography__c,Table__c,Button__c,name,Email_Font_Family__c,Email_Font_Size__c,
                                    Email_Font_Style__c,Email_Font_Color__c, CSS__c, CS_Button_JSON__c, Button_CSS__c, Is_Active__c,Backgroundcolor__c,
                                    Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,H3color__c,H4color__c,Header_Color__c,
                                    Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,CS_Itinerary_Page_Marker__c, 
                                    CS_Travelling_Country_Marker__c, CS_Address_Marker__c from CSS_Styler__c where Name = :pageName and Is_Active__c = true]){
                             compileCSS = 'style="';
                             if(cssdata.Email__c){
                                    if(cssdata.Email_Font_Family__c != null && cssdata.Email_Font_Family__c != '')
                                        compileCSS += 'font-family: ' + cssdata.Email_Font_Family__c + ' !important;\n';
                                    if(cssdata.Email_Font_Size__c != null && cssdata.Email_Font_Size__c != '')
                                        compileCSS += 'font-size: ' + cssdata.Email_Font_Size__c + 'px !important;\n';
                                    if(cssdata.Email_Font_Style__c != null && cssdata.Email_Font_Style__c != '')
                                        compileCSS += 'font-style: ' + cssdata.Email_Font_Style__c + ' !important;\n';
                                    if(cssdata.Email_Font_Color__c != null && cssdata.Email_Font_Color__c != '')
                                        compileCSS += 'color: ' + cssdata.Email_Font_Color__c + ' !important;\n';
                            }
                            compileCSS += '"';
                        }
                        if(compileCSS != ''){
                            emailBody = '<div '+compileCSS+'>'+emailBody+'</div>';
                        }
                        else{
                            emailBody = '<div  class="emailBody1" Style="font-family: arial,sans-serif;">'+emailBody+'</div>';
                        }
                         
                        //Get Body from Utility Class
                        String bodyStr = Utility.getEmailBody(templateName, lstOpp[0], et[0].ET_Template_Name__c);
                        if(et[0].ET_Email_Intro__c != null){
                            emailBody = emailBody.replace('~intro~','<br/>'+et[0].ET_Email_Intro__c);
                        }
                        emailBody = emailBody.replace('~body~','<br/>'+bodyStr);
                        if(et[0].ET_Email_Closing__c != null){
                            emailBody = emailBody.replace('~footer~','<br/>'+et[0].ET_Email_Closing__c);
                        }
                        ew = new EmailWrapper(JSON.serialize(emailBody));
                        ew.subject = emailTemp[0].Subject;
                        PickListValue leadEmailContact = new pickListValue(leadGM.GM_Contact__r.Email,leadGM.GM_Contact__r.FirstName+' '+leadGM.GM_Contact__r.LastName+' ('+leadGM.GM_Contact__r.Email+')');
                        if(templateName.indexOf('SupplierPayments') == -1 && et[0].ET_Page_Section__c != 'SupplierPayments'){
                            ew.selectedTo.add(leadEmailContact);
                        }
                        for(Group_Member__c gmCC : gmCCList){
                            PickListValue leadEmailContactCC = new pickListValue(gmCC.GM_Contact__r.Email,gmCC.GM_Contact__r.FirstName+' '+gmCC.GM_Contact__r.LastName+' ('+gmCC.GM_Contact__r.Email+')');
                            if(templateName.indexOf('SupplierPayments') == -1  && et[0].ET_Page_Section__c != 'SupplierPayments'){
                                ew.selectedCc.add(leadEmailContactCC);
                            }
                        }
                        ew.selectedBcc.add(new pickListValue(UserInfo.getUserEmail(),UserInfo.getName()+' ('+UserInfo.getUserEmail()+')'));
                        ew.leadpassenger = [Select id,Salutation,firstname,lastname,C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c from Contact where id =: ContactId];
                        
                        //system.assert(false, ew);
                        return ew;
                    }
                }  
            }
            else{
                System.assert(false,'Please create email template for this page.');    
            }   
        }
        catch(Exception e){
            System.assert(false,e.getMessage() + '       ' +e.getstacktraceString());
        }
        return null;
    }
    
     @remoteAction
     public static boolean saveBroucheRequestContact(String jsoncon){
       Contact con= (Contact)JSON.deserialize(jsoncon,Contact.class);
        RecordType rt = [select id,name from RecordType where sobjectType='Task' and name = 'Brochure Request' Limit 1  ];
        if(true){
          Task task = new Task();
          task.Status = 'Not Started';
          task.Subject = 'Brochure Request';
          task.RecordTypeId = rt.id;
          task.ActivityDate = System.Today();
          task.WhatId = con.Account.id;
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
    public static String sendEmail(EmailWrapper wrapper, String emailBody, String oppId, String templateName, String pageName, List<String> attachmentIds, String EmailTemplateName) {
            try{
            String conId;
            for(Group_Member__c gm : [Select Id,GM_Contact__c,GM_Contact__r.Account.A_First_Name__c, GM_Contact__r.Account.A_Last_Name__c,
                                            GM_Contact__r.FirstName,GM_Contact__r.LastName from Group_Member__c where 
                                            GM_Opportunity__c = :oppId and GM_Lead_Passenger__c = true]){
                if(gm.GM_Contact__r.Account.A_First_Name__c == gm.GM_Contact__r.FirstName && gm.GM_Contact__r.Account.A_Last_Name__c == gm.GM_Contact__r.LastName){
                    conId = gm.GM_Contact__c;
                }                            
                if(conId == null){
                    conId = gm.GM_Contact__c;
                }    
            }
            
            List<String> toAddresses = new List<String>();
            List<String> bccAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            for(pickListValue pl : wrapper.selectedTo){
                toAddresses.add(pl.value);
            }
            for(pickListValue pl : wrapper.selectedCc){
                ccAddresses.add(pl.value);
            }
            for(pickListValue pl : wrapper.selectedBcc){
                bccAddresses.add(pl.value);
            }
            String compileCSS = '';
            
            for(CSS_Styler__c cssdata : [Select id , Email__c,Typography__c,Table__c,Button__c,name,Email_Font_Family__c,Email_Font_Size__c,
                                    Email_Font_Style__c,Email_Font_Color__c, CSS__c, CS_Button_JSON__c, Button_CSS__c, Is_Active__c,Backgroundcolor__c,
                                    Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,H3color__c,H4color__c,Header_Color__c,
                                    Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,CS_Itinerary_Page_Marker__c, 
                                    CS_Travelling_Country_Marker__c, CS_Address_Marker__c from CSS_Styler__c where Name = :pageName and Is_Active__c = true]){
                 compileCSS = 'style="';
                 if(cssdata.Email__c){
                        if(cssdata.Email_Font_Family__c != null && cssdata.Email_Font_Family__c != '')
                            compileCSS += 'font-family: ' + cssdata.Email_Font_Family__c + ' !important;\n';
                        if(cssdata.Email_Font_Size__c != null && cssdata.Email_Font_Size__c != '')
                            compileCSS += 'font-size: ' + cssdata.Email_Font_Size__c + ' !important;\n';
                        if(cssdata.Email_Font_Style__c != null && cssdata.Email_Font_Style__c != '')
                            compileCSS += 'font-style: ' + cssdata.Email_Font_Style__c + ' !important;\n';
                        if(cssdata.Email_Font_Color__c != null && cssdata.Email_Font_Color__c != '')
                            compileCSS += 'color: ' + cssdata.Email_Font_Color__c + ' !important;\n';
                }
                compileCSS += '"';
            }
            if(compileCSS != ''){
                emailBody = '<div class="emailBody" '+compileCSS+'>'+emailBody+'</div>';
            }
            else{
                emailBody = '<div Style="font-family: arial,sans-serif;">'+emailBody+'</div>';
            }
            
            List<Attachment> attachedFiles = new List<Attachment>();
            if(attachmentIds.size() > 0){
                attachedFiles = [SELECT Id, Name, Body FROM Attachment WHERE Id in :attachmentIds];    
            }
            //emailBody
            Utility.sendTemplatedEmail(toAddresses,ccAddresses,bccAddresses,null,emailBody,conId,oppId,null,true,'Appssential',wrapper.subject, attachedFiles);
            List<HE_Question_Categories__c> lstQC = new List<HE_Question_Categories__c>();
            for(HE_Question_Categories__c qc: [Select ID,Name, (select id from Questions__r) from HE_Question_Categories__c where QC_Active__c = true order by QC_Order__c]){
               if(qc.Questions__r.size() > 0)
                   lstQC.add(qc);
            }
            Integer currentStage = lstQC.size();   
            if(templateName == 'Acknowledgement')
                currentStage = currentStage;
            if(templateName == 'Holiday Suggestions') 
                currentStage = currentStage+1;
            Opportunity opp = [Select id,StageName, O_Holiday_Enquiry_Stage__c from Opportunity where id =: oppId];
            opp.O_Holiday_Enquiry_Stage__c  = currentStage;
            
            if(wrapper.followUpD != '' && wrapper.followUpD != null){
                List<String> lstDate = wrapper.followUpD.split('/');
                if(wrapper.followUpTime != '' && wrapper.followUpTime != null){
                    List<String> lstTIme = wrapper.followUpTime.split(':');
                    if(lstDate.size()>=3 && lstTIme.size() > 1)
                           opp.O_Follow_Up_Time__c = datetime.newInstance(Integer.valueOf(lstDate [2]), Integer.valueOf(lstDate [1]), Integer.valueOf(lstDate [0]),Integer.valueOf(lstTIme[0]),Integer.valueOf(lstTIme[1]),0);
                }
                else{
                    opp.O_Follow_Up_Time__c = datetime.newInstance(Integer.valueOf(lstDate [2]), Integer.valueOf(lstDate [1]), Integer.valueOf(lstDate [0]),Integer.valueOf('00'),Integer.valueOf('00'),0);
                }
            }
            opp = Utility.UpdateOppStage(opp,templateName,EmailTemplateName);
            if(opp.O_Follow_Up_Time__c != null){
                Task task = new Task();
                task.Status = 'Not Started';
                task.Subject = 'Follow Up Call';
                task.ActivityDate = Date.valueOf(opp.O_Follow_Up_Time__c);
                task.WhatId = Opp.id;
                task.description =  'Follow Up Call';
                
                //task.whoId = conId;
                insert Task;  
                update opp;
            }
            else if(templateName.indexOf('Acknowledgement') != -1 || templateName.indexOf('Itinerary Pdf') != -1 || templateName.indexOf('Booking Form') != -1){
                update opp;
            }
            else if(EmailTemplateName.indexOf('Acknowledgement') != -1 || EmailTemplateName.indexOf('Itinerary Pdf') != -1 || EmailTemplateName.indexOf('Booking Form') != -1){
                update opp;
            }
            return 'Sucess';
        }
        catch(Exception e){
            return e.getMessage()+e.getStackTraceString();
        }
    }
    
    
    
    @remoteAction
    public static EmailWrapper getSelectedTemplate(String oppId, String templateName, String selectedTemplate, String objName, String selectedId, List<String> selectedOpps) {
        try{
            
            if(oppId != null){
                EmailWrapper ew;
                Group_Member__c  leadGM;
                String contactId;
                List<Group_Member__c> gmccList = new List<Group_Member__c>(); 
                List<Opportunity> lstOpp = [Select ID,AccountId,Description,O_Holiday_Type__c from Opportunity where Id = :oppId];
                for(Group_Member__c gm : [Select Id,GM_Contact__c,GM_Contact__r.Account.A_First_Name__c, GM_Contact__r.Account.A_Last_Name__c,
                                                GM_Contact__r.FirstName,GM_Contact__r.LastName, GM_Contact__r.Email,GM_Lead_Passenger__c from Group_Member__c where 
                                                GM_Opportunity__c = :oppId]){
                    
                    if(gm.GM_Lead_Passenger__c){
                        if(gm.GM_Contact__r.Account.A_First_Name__c.trim() == gm.GM_Contact__r.FirstName.trim() && gm.GM_Contact__r.Account.A_Last_Name__c.trim() == gm.GM_Contact__r.LastName.trim()){
                        leadGM = gm;
                        contactId = gm.GM_Contact__c; 
                        }                            
                        if(leadGM  == null && gm.GM_Contact__r.Email != null){
                        leadGM = gm;
                        contactId = gm.GM_Contact__c;
                        }    
                    }else{
                       if(gm.GM_Contact__r.Email != null){
                           gmccList.add(gm);
                       }
                     }
                 }
                   
                    
                List<Email_Template__c> et = [Select Id,ET_Email_Closing__c,ET_Email_Intro__c,ET_Template_Name__c,ET_Page_Section__c,To_Address_Filter__c from 
                                            Email_Template__c where Id =  :selectedTemplate];
                
                if(et.size() > 0 ){
                    List<EmailTemplate>  emailTemp = [Select id,HtmlValue,Subject from EmailTemplate where Name = : et[0].ET_Template_Name__c];
                    if(emailTemp.size() > 0 && contactId != null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[]{'veer@appssential.com'};
                        mail.setToAddresses(toAddresses);
                        mail.setUseSignature(false);
                        mail.setSaveAsActivity(false);
                        mail.setSenderDisplayName('MMPT');
                        mail.setTargetObjectId(contactId);
                        if(selectedId != null && selectedId != ''){
                            mail.setWhatId(selectedId);
                        }
                        else{
                            mail.setWhatId(oppId);
                        }
                        mail.setTemplateId(emailTemp[0].Id);
                        Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                        Database.rollback(sp);
                        //String mailTextBody = mail.getPlainTextBody(); */
                        //String whatIdIs = '';
                        //if(selectedId != null && selectedId != ''){
                       //     whatIdIs = selectedId;
                       // }
                       // else{
                        //    whatIdIs = oppId;
                       // }
                        
                        //Messaging.SingleEmailMessage  convertedMail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id,contactId,whatIdIs );
                        //String emailBody = convertedMail.getHTMLBody();//mail.getHTMLBody();
                        String emailBody = mail.getHTMLBody();
                        
                        String compileCSS = '';
            
                        for(CSS_Styler__c cssdata : [Select id , Email__c,Typography__c,Table__c,Button__c,name,Email_Font_Family__c,Email_Font_Size__c,
                                                Email_Font_Style__c,Email_Font_Color__c, CSS__c, CS_Button_JSON__c, Button_CSS__c, Is_Active__c,Backgroundcolor__c,
                                                Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,H3color__c,H4color__c,Header_Color__c,
                                                Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,CS_Itinerary_Page_Marker__c, 
                                                CS_Travelling_Country_Marker__c, CS_Address_Marker__c from CSS_Styler__c where Name = 'SendEmail' and Is_Active__c = true]){
                             compileCSS = 'style="';
                             if(cssdata.Email__c){
                                    if(cssdata.Email_Font_Family__c != null && cssdata.Email_Font_Family__c != '')
                                        compileCSS += 'font-family: ' + cssdata.Email_Font_Family__c + ' !important;\n';
                                    if(cssdata.Email_Font_Size__c != null && cssdata.Email_Font_Size__c != '')
                                        compileCSS += 'font-size: ' + cssdata.Email_Font_Size__c + ' !important;\n';
                                    if(cssdata.Email_Font_Style__c != null && cssdata.Email_Font_Style__c != '')
                                        compileCSS += 'font-style: ' + cssdata.Email_Font_Style__c + ' !important;\n';
                                    if(cssdata.Email_Font_Color__c != null && cssdata.Email_Font_Color__c != '')
                                        compileCSS += 'color: ' + cssdata.Email_Font_Color__c + ' !important;\n';
                            }
                            compileCSS += '"';
                        }
                        
                        if(compileCSS != ''){
                            emailBody = '<div class="emailBody" '+compileCSS+'>'+emailBody+'</div>';
                        }
                        else{
                            emailBody = '<div class="emailBody1" Style="font-family: arial,sans-serif;">'+emailBody+'</div>';
                        }
                        //Get Body from Utility Class
                        
                        String bodyStr = Utility.getEmailBody(templateName, lstOpp[0],et[0].ET_Template_Name__c);
                        if(et[0].ET_Email_Intro__c != null){
                            emailBody = emailBody.replace('~intro~','<br/>'+et[0].ET_Email_Intro__c);
                        }
                        emailBody = emailBody.replace('~body~','<br/>'+bodyStr);
                        if(et[0].ET_Email_Closing__c != null){
                            emailBody = emailBody.replace('~footer~','<br/>'+et[0].ET_Email_Closing__c);
                        }
                        if(emailBody.indexOf('~OtherPDF~') != -1){
                            String otherPdf = '';
                            Site__c site = Site__c.getInstance();
                            for(Opportunity opp : [Select Id, name from Opportunity where Id in :selectedOpps]){
                                otherPdf += '<a href="'+site.SiteURLAdmin__c+'/ItineraryPdfA4?id='+opp.id+'">'+opp.Name+'</a><br />';
                            }
                            emailBody = emailBody.replace('~OtherPDF~',otherPdf);
                        }
                        ew = new EmailWrapper(JSON.serialize(emailBody));
                        ew.selectedTemplateName = et[0].ET_Template_Name__c;
                        ew.subject = emailTemp[0].Subject;
                        PickListValue leadEmailContact = new pickListValue(leadGM.GM_Contact__r.Email,leadGM.GM_Contact__r.FirstName+' '+leadGM.GM_Contact__r.LastName+' ('+leadGM.GM_Contact__r.Email+')');
                        if(templateName.indexOf('SupplierPayments') == -1  && et[0].ET_Page_Section__c != 'SupplierPayments'){
                            ew.selectedTo.add(leadEmailContact);
                        }
                        
                        for(Group_Member__c gmCC : gmccList){
                            PickListValue leadEmailContactCC = new pickListValue(gmCC.GM_Contact__r.Email,gmCC.GM_Contact__r.FirstName+' '+gmCC.GM_Contact__r.LastName+' ('+gmCC.GM_Contact__r.Email+')');
                            if(templateName.indexOf('SupplierPayments') == -1  && et[0].ET_Page_Section__c != 'SupplierPayments'){
                                ew.selectedCc.add(leadEmailContactCC);
                            }
                        }
                        if(et[0].ET_Template_Name__c.indexOf('Supplier') != -1 && et[0].To_Address_Filter__c != null && selectedId != null){ //For Supplier Email Templates
                            String availableTypes = '';
                            for(String str : et[0].To_Address_Filter__c.split(';')){
                                availableTypes += '\''+str+'\',';
                            }
                            availableTypes = availableTypes.removeEnd(',');
                            if(objName == 'Supplier__c'){ 
                                for(Supplier_Contact__c sc : Database.query('Select Id,SC_Email__c,SC_First_Name__c,SC_Last_Name__c,Type__c from  Supplier_Contact__c where SC_Supplier__c = :selectedId  and SC_Email__c != null and Type__c includes ('+availableTypes+')')){
                                    ew.selectedTo.add(new pickListValue(sc.SC_Email__c,sc.SC_First_Name__c+' '+sc.SC_Last_Name__c+' - '+sc.Type__c+' ('+sc.SC_Email__c+')'));
                                }    
                            }
                            if(objName == 'Supplier_Payment__c'){
                                List<Supplier_Payment__c> lstSP = [Select SP_Supplier__c from Supplier_Payment__c where Id =:selectedId];
                                if(lstSP.size() > 0){
                                    String selectedSupplierId = lstSP[0].SP_Supplier__c;
                                    for(Supplier_Contact__c sc : Database.query('Select Id,SC_Email__c,SC_First_Name__c,SC_Last_Name__c,Type__c from  Supplier_Contact__c where SC_Supplier__c = :selectedSupplierId and SC_Email__c != null and Type__c includes ('+availableTypes+')')){
                                        ew.selectedTo.add(new pickListValue(sc.SC_Email__c,sc.SC_First_Name__c+' '+sc.SC_Last_Name__c+' - '+sc.Type__c+' ('+sc.SC_Email__c+')'));
                                    } 
                                }
                            }
                        }
                        ew.selectedBcc.add(new pickListValue(UserInfo.getUserEmail(),UserInfo.getName()+' ('+UserInfo.getUserEmail()+')'));
                        ew.leadpassenger = [Select id,Salutation,firstname,lastname,C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c from Contact where id =: ContactId];
                        return ew;
                    }
                }  
            }   
        }
        catch(Exception e){
            System.assert(false,e.getMessage() + '       ' +e.getstacktraceString()+ '       ' +e.getLineNumber());
        }
        return null;
    }
   
    
    
    @remoteAction
    public static TemplateWrapper getFolderReports(String pageName, String oppID){
        pageName = pageName.replaceAll('sugati__','');

        List<Email_Template__c> et = [Select Id,ET_Email_Closing__c,ET_Email_Intro__c,ET_Template_Name__c from Email_Template__c where ET_Page_Section__c = :pageName and ET_User__c = :UserInfo.getUserId()];         
        if(et.size() == 0 ){
            et = [Select Id,ET_Email_Closing__c,ET_Email_Intro__c,ET_Template_Name__c from Email_Template__c where ET_Page_Section__c like :'%'+pageName+'%' order by ET_Template_Name__c ];                     
        }
        if(pageName.indexOf('SendEmail') != -1){
            et = [Select Id,ET_Email_Closing__c,ET_Email_Intro__c,ET_Template_Name__c from Email_Template__c where RecordType.DeveloperName = 'Email' order by ET_Template_Name__c ];                     
        }
        
        TemplateWrapper tw = new TemplateWrapper(oppID);
        tw.lstTemplate = et;
        //System.assert(false,tw);
        return tw;
    }
    
    public Class TemplateWrapper{
        public List<Folder> lstFolder{get; set;}
        public List<Email_Template__c> lstTemplate{get; set;}
        public Map<String,List<pickListValue>> mapRecords{get; set;}
        
        public TemplateWrapper(String OppID){
            lstFolder = new List<Folder>();
            lstTemplate = new List<Email_Template__c>();
            mapRecords = new Map<String,List<pickListValue>>();
            List<Opportunity> lstOpportunity = [Select Id,AccountId,Name from Opportunity where Id = :OppID];
            if(lstOpportunity.size() > 0){
                for(Opportunity opp : lstOpportunity){
                    if(!mapRecords.containsKey('Opportunity')){
                        mapRecords.put('Opportunity', new List<pickListValue>());
                    }
                    mapRecords.get('Opportunity').add(new pickListValue(opp.Id, opp.Name));
                }
                for(Account acc : [Select Id,Name from Account where Id = :lstOpportunity[0].AccountId ]){
                    if(!mapRecords.containsKey('Account')){
                        mapRecords.put('Account', new List<pickListValue>());
                    }
                    mapRecords.get('Account').add(new pickListValue(acc.Id, acc.Name));
                }
                for(Contact con : [Select Id,Name from Contact where AccountId = :lstOpportunity[0].AccountId]){
                    if(!mapRecords.containsKey('Contact')){
                        mapRecords.put('Contact', new List<pickListValue>());
                    }
                    mapRecords.get('Contact').add(new pickListValue(con.Id, con.Name));
                }
                for(Client_Payment__c cp : [Select Id, Name from Client_Payment__c where CP_Opportunity__c  = :lstOpportunity[0].Id ]){
                    if(!mapRecords.containsKey('Client_Payment__c')){
                        mapRecords.put('Client_Payment__c', new List<pickListValue>());
                    }
                    mapRecords.get('Client_Payment__c').add(new pickListValue(cp.Id, cp.Name));
                }
                for(Client_Invoice__c ci : [Select Id, Name from Client_Invoice__c  where I_Opportunity__c = :lstOpportunity[0].Id ]){
                    if(!mapRecords.containsKey('Client_Invoice__c')){
                        mapRecords.put('Client_Invoice__c', new List<pickListValue>());
                    }
                    mapRecords.get('Client_Invoice__c').add(new pickListValue(ci.Id, ci.Name));
                }
                for(Supplier_Payment__c sp : [Select Id, Name, SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__r.Name from Supplier_Payment__c  where SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c = :lstOpportunity[0].Id ]){
                    if(!mapRecords.containsKey('Supplier_Payment__c')){
                        mapRecords.put('Supplier_Payment__c', new List<pickListValue>());
                    }
                    mapRecords.get('Supplier_Payment__c').add(new pickListValue(sp.Id, sp.Name +' - '+sp.SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__r.Name));
                }
                for(Client_Group__c cg: [SELECT id, Name from Client_Group__c  where CG_Opportunity__c =:lstOpportunity[0].Id ]){
                    if(!mapRecords.containsKey('Client_Group__c')){
                        mapRecords.put('Client_Group__c', new List<pickListValue>());
                    }
                    mapRecords.get('Client_Group__c').add(new pickListValue(cg.Id, cg.Name));
                }
                
                Set<String> setOfSupplier = new Set<String>();
                for(Supplier_Booking__c sb : [Select Id, Name, SB_Supplier__c, SB_Supplier__r.Name from Supplier_Booking__c where SB_Opportunity__c = :lstOpportunity[0].Id and SB_Supplier__c != null]){
                    if(!setOfSupplier.contains(sb.SB_Supplier__c)){
                        if(!mapRecords.containsKey('Supplier__c')){
                            mapRecords.put('Supplier__c', new List<pickListValue>());
                        }
                        mapRecords.get('Supplier__c').add(new pickListValue(sb.SB_Supplier__c, sb.SB_Supplier__r.Name));
                        setOfSupplier.add(sb.SB_Supplier__c);
                    }
                }
                
            }
        }
    }
    
    public Class EmailWrapper{
        public List<pickListValue> selectedTo{get; set;}
        public List<pickListValue> selectedCc{get; set;}
        public List<pickListValue> selectedBcc{get; set;}
        public String subject{get; set;}
        public String emailBody{get; set;}
        public Contact leadpassenger{get;set;}
        public String selectedTemplateName{get;set;}
        public String followUpD{get; set;}
        public String followUpTime{get; set;}
        
        public EmailWrapper(String emailBody){
            this.selectedTo = new List<pickListValue>();    
            this.selectedCc = new List<pickListValue>();    
            this.selectedBcc = new List<pickListValue>();    
            this.subject = 'Recap Email';
            this.emailBody = emailBody;    
        }
    }
    public Class pickListValue{
        public String value{get; set;}
        public String label{get; set;}
        public pickListValue(String value, String label){
            this.value = value;
            this.label = label;
        }
    }
    
    
}
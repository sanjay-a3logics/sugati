public without sharing Class BookingFormController{

    public String oppID{get; set;}
    public List<GorupMembers> lstGroupMembers{get; set;}
    public Boolean isSiteUser{get; set;}
    public Boolean tc{get; set;}
    public Boolean insurance{get; set;} 
    public String policyNo{get; set;}
    public String policyProvider{get; set;}
    public String policyCon{get; set;}
    public String emergencyFirstName{get;set;}
    public String emergencyLastName{get;set;}
    public String emergencyEmail{get;set;}
    public String emergencyContact{get;set;}
    public String emergencyRelationship{get;set;}
    public String selectedContactId{get; set;}
    public List<SelectOption> countryOptions{get; set;}
    public Integer removedRow{get; set;}
    public String OBFNotes {get;set;}
    public Id cgid;
   
    public Opportunity opp{get; set;}
    Contact FoundContact = new Contact();
    public BookingFormController(ApexPages.StandardController controller) {
        try{
            oppID = controller.getId();
            lstGroupMembers = new List<GorupMembers>();
            cgid = apexpages.currentpage().getparameters().get('cgid');
            //Set<Id> cgId = new Set<Id>();
            /*for(Client_Group__c cg:[SELECT Id from Client_Group__c ]){
                cgId.add(cg.Id);
            }*/
            if(oppID != null){
                List<Profile> PROFILE = [SELECT Id, Name,UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                if(PROFILE[0].UserLicense.Name == 'Guest User License'){
                    isSiteUser =true;    
                }
                else{
                    isSiteUser =false;
                }
                if(cgid != null){
                    opp = [Select ID,Amount,Name,AccountID,O_Policy_No__c,O_Insurance_Company__c,O_RecordType__r.Name,O_Booking_Currency__c ,O_Outstanding__c,
                    (Select ID, GM_Contact__c,GM_Lead_Passenger__c from Group_Members__r where GM_Client_Group__c =:cgid ), 
                                O_Ts_Cs__c from Opportunity where Id = :oppId];
                }
                else{
                    opp = [Select ID,Amount,Name,AccountID,O_Policy_No__c,O_Insurance_Company__c,O_RecordType__r.Name,O_Booking_Currency__c ,O_Outstanding__c,
                    (Select ID, GM_Contact__c,GM_Lead_Passenger__c from Group_Members__r), 
                                O_Ts_Cs__c from Opportunity where Id = :oppId];    
                }
                tc = opp.O_Ts_Cs__c;
              //  if(opp.O_OBF_Requirements__c!= null)
                  //  OBFNotes = opp.O_OBF_Requirements__c;
               // insurance = opp.O_Insurance__c;
                policyNo = opp.O_Policy_No__c;
                policyProvider = opp.O_Insurance_Company__c;
              //  policyCon = opp.O_Insurance_Contact__c;
                
                Set<String> conIds = new Set<String>();
                Map<String,Boolean> isLeadMap = new Map<String,Boolean>();
                
                
                for(Group_Member__c gm : opp.Group_Members__r){
                    conIds.add(gm.GM_Contact__c);
                    isLeadMap.put(gm.GM_Contact__c,gm.GM_Lead_Passenger__c);
                    if(gm.GM_Lead_Passenger__c && cgid != null){
                        FoundContact.Id =  gm.GM_Contact__c;
                    }
                }
                
                if(cgid == null){
                    For(Account acc : [Select Id,Name,Phone,BillingStreet, 
                                    BillingState, BillingCountry , BillingCity ,BillingPostalCode, ShippingStreet ,ShippingState, 
                                    ShippingCountry,ShippingPostalCode ,ShippingCity,(Select Id,FirstName,lastname,Phone,C_Lead_Passenger__c,Email,MailingStreet,MailingState,
                                            MailingPostalCode,OtherStreet,OtherState,OtherCountry,OtherPostalCode  
                                   from Contacts where Id in :conIds order by createdDate) from Account where Id = :opp.AccountId]){
                        if(acc.Contacts.size() == 1){
                           // acc.A_Lead_Email__c = acc.Contacts[0].Email;
                            FoundContact = acc.Contacts[0];
                            acc.phone = acc.Contacts[0].phone;
                        }
                        else{
                            Boolean isFilled = false;
                            for(Contact c : acc.Contacts){
                                string cname = c.firstname + ' ' + c.lastname;
                                //System.assert(false, acc.Contacts + '****' + isLeadMap  + '****' + acc.name);
                                if (acc.name.contains(cname) && (isLeadMap.containsKey(c.Id) && isLeadMap.get(c.Id))) {
                                  //  acc.A_Lead_Email__c = c.Email;
                                    acc.phone = c.phone;
                                    FoundContact = c;
                                    isFilled = true;
                                }
                            } 
                            
                            if(!isFilled){
                                for(Contact c : acc.Contacts){
                                    if (FoundContact .Id == null && isLeadMap.get(c.Id)) { 
                                        acc.phone = c.phone;
                                        //acc.A_Lead_Email__c = c.Email;
                                        FoundContact = c;
                                    }
                                }        
                            }   
                        }
                    }
                }
                
                Integer count = 1;
                Integer count1 = 1;
                for(Contact contact : [Select Id,Salutation,FirstName,lastName,Email,C_Address_Line_2__c,Phone,Birthdate,MailingStreet,MailingCity,MailingPostalCode,
                                  C_Nationality__c,MailingCountry,C_Emergency_Contact_Name__c,C_Passport_Number__c,C_Expires_Date__c,C_Emergency_No__c,C_Emergency_Contact_Email__c, 
                                  (Select ID,AM_Member_Name__c,AM_Airline__c,Name from Airline_memberships__r order by createdDate)
                                   from Contact Where Id in :conIds]){
                    if(isLeadMap.containsKey(contact.Id)){
                        GorupMembers contactData = new GorupMembers();
                        contactData.count = count;
                        contactData.count1 = count1;
                        if(FoundContact.Id == contact.Id){
                            contactData.isLead = true;
                        }
                        else{
                            contactData.isLead = false;
                        }
                        if(FoundContact.Id == contact.Id){
                            count++; 
                        }
                        else{
                            count1++;
                        }
                        contactData.conId = contact.Id;
                        contactData.title = contact.salutation;
                        contactData.firstname = contact.firstname;
                        contactData.lastname = contact.lastname;
                        contactData.email = contact.email;
                        contactData.phone = contact.phone;
                        contactData.zip = contact.MailingPostalCode ;
                        contactData.city= contact.MailingCity ; 
                        contactData.street= contact.Mailingstreet;   
                        contactData.country = contact.MailingCountry;
                        contactData.passportNo = contact.C_Passport_Number__c;
                        if(contact.BirthDate != null){
                            contactData.dob = contact.BirthDate.format();
                        }
                        if(contact.C_Expires_Date__c != null){
                            contactData.passExpiryDate = contact.C_Expires_Date__c.format();
                        }
                        contactData.nationality = contact.C_Nationality__c;
                        contactData.Address_Line_2 =  contact.C_Address_Line_2__c;
                        //Airline membership
                        for(Airline_membership__c amc : contact.Airline_memberships__r ){
                           if(amc.AM_Member_Name__c == null || amc.AM_Member_Name__c == ''){
                              amc.AM_Member_Name__c = contactData.firstname +' '+contactData.lastname;
                              //amc.AM_Contact__c = contact.Id;
                           }
                        }
                        contactData.airlineMemberships.addAll(contact.Airline_memberships__r);
                        if(contactData.airlineMemberships.size() == 0){
                            contactData.airlineMemberships.add(new Airline_membership__c(AM_Contact__c = contact.Id, AM_Member_Name__c = contactData.firstname +' '+contactData.lastname));    
                        }
                        lstGroupMembers.add(contactData); 
                              
                    }
                    if(contact.Id == FoundContact.Id){
                        if(contact.C_Emergency_Contact_Name__c != null){
                            List<String> lstName = contact.C_Emergency_Contact_Name__c.split(' ');
                            if(lstName.size() >= 2){
                                emergencyFirstName = lstName[0];
                                emergencyLastName = lstName[lstName.size()-1];
                              }
                        }
                        emergencyEmail = contact.C_Emergency_Contact_Email__c;
                        emergencyContact = contact.C_Emergency_No__c;
                       //emergencyRelationship = contact.C_Emergency_Contact_Relationship__c;
                    }
                }
            }
            
            loadCountries();
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+'ddd'+e.getMessage());
        }
        
    }
    
    public List<SelectOption> getSalutaionOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--Select--'));
        for( Schema.PicklistEntry f : ple){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getnationalityOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.C_Nationality__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--Select--'));
        for( Schema.PicklistEntry f : ple){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public PageReference Confirm(){
        try{
            
            opp.O_Ts_Cs__c = tc;
            //opp.O_Insurance__c = insurance;
            opp.O_Policy_No__c = policyNo;
            opp.O_Insurance_Company__c = policyProvider;
           //opp.O_Insurance_Contact__c = policyCon;
           // opp.O_OBF_Requirements__c = OBFNotes;
            update opp;
            
            List<Contact> lstContact = new List<Contact>();
            List<Airline_membership__c> lstAM = new List<Airline_membership__c>();
            List<Airline_membership__c> lstAMDl = new List<Airline_membership__c>();
            for(GorupMembers gm : lstGroupMembers){
                Contact con = new Contact();
                con.Id = gm.conId;
                con.firstname = gm.firstname ;
                con.lastname = gm.lastname ;
                con.email = gm.email ;
                con.phone = gm.phone ;
                con.MailingPostalCode  = gm.zip ;
                con.MailingCity = gm.city;
                con.Mailingstreet = gm.street;
                con.C_Passport_Number__c = gm.passportNo;
                con.MailingCountry = gm.country ;
                con.C_Nationality__c = gm.nationality;
                con.C_Address_Line_2__c = gm.Address_Line_2;
                con.Salutation = gm.title;
                List<String> dd = gm.dob.split('/');
                if(dd.size()>=3){
                    DateTime dateD = DateTime.newInstance(Integer.valueOf(dd[2]),Integer.valueOf(dd[1]),Integer.valueOf(dd[0]));
                    con.birthdate = dateD.date();
                }
                dd = gm.passExpiryDate.split('/');
                if(dd.size()>=3){
                    DateTime dateD = DateTime.newInstance(Integer.valueOf(dd[2]),Integer.valueOf(dd[1]),Integer.valueOf(dd[0]));
                    con.C_Expires_Date__c = dateD.date();
                }
                if(FoundContact != null && FoundContact.iD == gm.conId){
                    con.C_Emergency_Contact_Name__c = emergencyFirstName+' '+emergencyLastName;
                   con.C_Emergency_Contact_Email__c = emergencyEmail;
                    con.C_Emergency_No__c = emergencyContact;
                   // con.C_Emergency_Contact_Relationship__c = emergencyRelationship;
                }
                lstContact.add(con);
                //Airline MembresShip
                for(Airline_membership__c am : gm.airlineMemberships){
                    if(am.AM_Member_Name__c != '' || am.AM_Airline__c != '' || am.Name != ''){
                        lstAM.add(am);
                    }
                    else if(am.Id != null){
                        lstAMDl.add(am);
                    }
                }
            }
            delete lstAMDl;
            update lstContact;
            upsert lstAM;
            //If outstanding amout is 0 then bypass payment page
            //System.assert(false, opp.O_Outstanding__c);
            if(opp.O_Outstanding__c == null || opp.O_Outstanding__c == 0)
                return new PageReference('/apex/ThankYouConfirmation?id='+oppId+'&cp=bypass');       
            else
                return new PageReference('/apex/BookingConfirmation?id='+oppId+'&cgid='+cgid); 
        }
        Catch(Exception e){
            //system.assert(false,e.getStackTraceString());
            ApexPages.addMessages(e);
            return null;
        }
       
    }
    
    public void addAirlineMembre(){
        try{
            
            for(GorupMembers gm : lstGroupMembers){
                if(gm.conId == selectedContactId){
                    gm.airlineMemberships.add(new Airline_membership__c(AM_Contact__c = selectedContactId, AM_Member_Name__c =(gm.firstname +' '+gm.lastname)));
                }
            }    
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    
    public void removeAirlineMembre(){
        for(GorupMembers gm : lstGroupMembers){
            if(gm.conId == selectedContactId && removedRow != null){
                gm.airlineMemberships.remove(removedRow);
            }
        } 
    }
    
     void loadCountries() {
        countryOptions= new List<Selectoption>();
        countryOptions.add(new selectoption('','-Select-'));    
        countryOptions.add(new Selectoption ('GB','United Kingdom'));
        countryOptions.add(new Selectoption ('US','United States'));
        countryOptions.add(new Selectoption ('AF','Afghanistan'));
        //countryOptions.add(new Selectoption ('Åland Islands','Åland Islands'));
        countryOptions.add(new Selectoption ('AL','Albania'));
        countryOptions.add(new Selectoption ('DZ','Algeria'));
        countryOptions.add(new Selectoption ('AS','American Samoa'));
        countryOptions.add(new Selectoption ('AD','Andorra'));
        countryOptions.add(new Selectoption ('AO','Angola'));
        countryOptions.add(new Selectoption ('AI','Anguilla'));
        countryOptions.add(new Selectoption ('AQ','Antarctica'));
        countryOptions.add(new Selectoption ('AG','Antigua and Barbuda'));
        countryOptions.add(new Selectoption ('AR','Argentina'));
        countryOptions.add(new Selectoption ('AM','Armenia'));
        countryOptions.add(new Selectoption ('AW','Aruba'));
        countryOptions.add(new Selectoption ('AU','Australia'));
        countryOptions.add(new Selectoption ('AT','Austria'));
        countryOptions.add(new Selectoption ('AZ','Azerbaijan'));
        countryOptions.add(new Selectoption ('BS','Bahamas'));
        countryOptions.add(new Selectoption ('BH','Bahrain'));
        countryOptions.add(new Selectoption ('BD','Bangladesh'));
        countryOptions.add(new Selectoption ('BB','Barbados'));
        countryOptions.add(new Selectoption ('BY','Belarus'));
        countryOptions.add(new Selectoption ('BE','Belgium'));
        countryOptions.add(new Selectoption ('BZ','Belize'));
        countryOptions.add(new Selectoption ('BJ','Benin'));
        countryOptions.add(new Selectoption ('BM','Bermuda'));
        countryOptions.add(new Selectoption ('BT','Bhutan'));
        countryOptions.add(new Selectoption ('BO','Bolivia'));
        countryOptions.add(new Selectoption ('BA','Bosnia and Herzegovina'));
        countryOptions.add(new Selectoption ('BW','Botswana'));
        countryOptions.add(new Selectoption ('BV','Bouvet Island'));
        countryOptions.add(new Selectoption ('BR','Brazil'));
        countryOptions.add(new Selectoption ('IO','British Indian Ocean Territory'));
        countryOptions.add(new Selectoption ('BN','Brunei Darussalam'));
        countryOptions.add(new Selectoption ('BG','Bulgaria'));
        countryOptions.add(new Selectoption ('BF','Burkina Faso'));
        countryOptions.add(new Selectoption ('BI','Burundi'));
        countryOptions.add(new Selectoption ('KH','Cambodia'));
        countryOptions.add(new Selectoption ('CM','Cameroon'));
        countryOptions.add(new Selectoption ('CA','Canada'));
        countryOptions.add(new Selectoption ('CV','Cape Verde'));
        countryOptions.add(new Selectoption ('KY','Cayman Islands'));
        countryOptions.add(new Selectoption ('CF','Central African Republic'));
        countryOptions.add(new Selectoption ('TD','Chad'));
        countryOptions.add(new Selectoption ('CL','Chile'));
        countryOptions.add(new Selectoption ('CN','China'));
        countryOptions.add(new Selectoption ('CX','Christmas Island'));
        countryOptions.add(new Selectoption ('CC','Cocos (Keeling) Islands'));
        countryOptions.add(new Selectoption ('CO','Colombia'));
        countryOptions.add(new Selectoption ('KM','Comoros'));
        countryOptions.add(new Selectoption ('CG','Congo'));
        countryOptions.add(new Selectoption ('CD, The Democratic Republic of The','Congo, The Democratic Republic of The'));
        countryOptions.add(new Selectoption ('CK','Cook Islands'));
        countryOptions.add(new Selectoption ('CR','Costa Rica'));
        countryOptions.add(new Selectoption ('CI','Cote D\'ivoire'));
        countryOptions.add(new Selectoption ('HR','Croatia'));
        countryOptions.add(new Selectoption ('CU','Cuba'));
        countryOptions.add(new Selectoption ('CY','Cyprus'));
        countryOptions.add(new Selectoption ('CZ','Czech Republic'));
        countryOptions.add(new Selectoption ('DK','Denmark'));
        countryOptions.add(new Selectoption ('DJ','Djibouti'));
        countryOptions.add(new Selectoption ('DM','Dominica'));
        countryOptions.add(new Selectoption ('DO','Dominican Republic'));
        countryOptions.add(new Selectoption ('EC','Ecuador'));
        countryOptions.add(new Selectoption ('EG','Egypt'));
        countryOptions.add(new Selectoption ('SV','El Salvador'));
        countryOptions.add(new Selectoption ('GQ','Equatorial Guinea'));
        countryOptions.add(new Selectoption ('ER','Eritrea'));
        countryOptions.add(new Selectoption ('EE','Estonia'));
        countryOptions.add(new Selectoption ('ET','Ethiopia'));
        countryOptions.add(new Selectoption ('FK','Falkland Islands (Malvinas)'));
        countryOptions.add(new Selectoption ('FO','Faroe Islands'));
        countryOptions.add(new Selectoption ('FJ','Fiji'));
        countryOptions.add(new Selectoption ('FI','Finland'));
        countryOptions.add(new Selectoption ('FR','France'));
        countryOptions.add(new Selectoption ('GF','French Guiana'));
        countryOptions.add(new Selectoption ('PF','French Polynesia'));
        countryOptions.add(new Selectoption ('TF','French Southern Territories'));
        countryOptions.add(new Selectoption ('GA','Gabon'));
        countryOptions.add(new Selectoption ('GM','Gambia'));
        countryOptions.add(new Selectoption ('GE','Georgia'));
        countryOptions.add(new Selectoption ('DE','Germany'));
        countryOptions.add(new Selectoption ('GH','Ghana'));
        countryOptions.add(new Selectoption ('GI','Gibraltar'));
        countryOptions.add(new Selectoption ('GR','Greece'));
        countryOptions.add(new Selectoption ('GL','Greenland'));
        countryOptions.add(new Selectoption ('GD','Grenada'));
        countryOptions.add(new Selectoption ('GP','Guadeloupe'));
        countryOptions.add(new Selectoption ('GU','Guam'));
        countryOptions.add(new Selectoption ('GT','Guatemala'));
        //countryOptions.add(new Selectoption ('Guernsey','Guernsey'));
        countryOptions.add(new Selectoption ('GN','Guinea'));
        countryOptions.add(new Selectoption ('GW','Guinea-bissau'));
        countryOptions.add(new Selectoption ('GY','Guyana'));
        countryOptions.add(new Selectoption ('HT','Haiti'));
        countryOptions.add(new Selectoption ('HM','Heard Island and Mcdonald Islands'));
        countryOptions.add(new Selectoption ('VA','Holy See (Vatican City State)'));
        countryOptions.add(new Selectoption ('HN','Honduras'));
        countryOptions.add(new Selectoption ('HK','Hong Kong'));
        countryOptions.add(new Selectoption ('HU','Hungary'));
        countryOptions.add(new Selectoption ('IS','Iceland'));
        countryOptions.add(new Selectoption ('IN','India'));
        countryOptions.add(new Selectoption ('ID','Indonesia'));
        countryOptions.add(new Selectoption ('IR, Islamic Republic of','Iran, Islamic Republic of'));
        countryOptions.add(new Selectoption ('IQ','Iraq'));
        countryOptions.add(new Selectoption ('IE','Ireland'));
        //countryOptions.add(new Selectoption ('Isle of Man','Isle of Man'));
        countryOptions.add(new Selectoption ('IL','Israel'));
        countryOptions.add(new Selectoption ('IT','Italy'));
        countryOptions.add(new Selectoption ('JM','Jamaica'));
        countryOptions.add(new Selectoption ('JP','Japan'));
        //countryOptions.add(new Selectoption ('Jersey','Jersey'));
        countryOptions.add(new Selectoption ('JO','Jordan'));
        countryOptions.add(new Selectoption ('KZ','Kazakhstan'));
        countryOptions.add(new Selectoption ('KE','Kenya'));
        countryOptions.add(new Selectoption ('KI','Kiribati'));
        countryOptions.add(new Selectoption ('KP, Democratic People\'s Republic of','Korea, Democratic People\'s Republic of'));
        countryOptions.add(new Selectoption ('KR','Korea, Republic of'));
        countryOptions.add(new Selectoption ('KW','Kuwait'));
        countryOptions.add(new Selectoption ('KG','Kyrgyzstan'));
        //countryOptions.add(new Selectoption ('Lao People\'s Democratic Republic','Lao People\'s Democratic Republic'));
        countryOptions.add(new Selectoption ('LV','Latvia'));
        countryOptions.add(new Selectoption ('LB','Lebanon'));
        countryOptions.add(new Selectoption ('LS','Lesotho'));
        countryOptions.add(new Selectoption ('LR','Liberia'));
        countryOptions.add(new Selectoption ('LY','Libyan Arab Jamahiriya'));
        countryOptions.add(new Selectoption ('LI','Liechtenstein'));
        countryOptions.add(new Selectoption ('LT','Lithuania'));
        countryOptions.add(new Selectoption ('LU','Luxembourg'));
        countryOptions.add(new Selectoption ('MO','Macao'));
        countryOptions.add(new Selectoption ('MK, The Former Yugoslav Republic of','Macedonia, The Former Yugoslav Republic of'));
        countryOptions.add(new Selectoption ('MG','Madagascar'));
        countryOptions.add(new Selectoption ('MW','Malawi'));
        countryOptions.add(new Selectoption ('MY','Malaysia'));
        countryOptions.add(new Selectoption ('MV','Maldives'));
        countryOptions.add(new Selectoption ('ML','Mali'));
        countryOptions.add(new Selectoption ('MT','Malta'));
        countryOptions.add(new Selectoption ('MH','Marshall Islands'));
        countryOptions.add(new Selectoption ('MQ','Martinique'));
        countryOptions.add(new Selectoption ('MR','Mauritania'));
        countryOptions.add(new Selectoption ('MU','Mauritius'));
        countryOptions.add(new Selectoption ('YT','Mayotte'));
        countryOptions.add(new Selectoption ('MX','Mexico'));
        countryOptions.add(new Selectoption ('FM','Micronesia, Federated States of'));
        countryOptions.add(new Selectoption ('MD, Republic of','Moldova, Republic of'));
        countryOptions.add(new Selectoption ('MC','Monaco'));
        countryOptions.add(new Selectoption ('MN','Mongolia'));
        countryOptions.add(new Selectoption ('ME','Montenegro'));
        countryOptions.add(new Selectoption ('MS','Montserrat'));
        countryOptions.add(new Selectoption ('MA','Morocco'));
        countryOptions.add(new Selectoption ('MZ','Mozambique'));
        countryOptions.add(new Selectoption ('MM','Myanmar'));
        countryOptions.add(new Selectoption ('NA','Namibia'));
        countryOptions.add(new Selectoption ('NR','Nauru'));
        countryOptions.add(new Selectoption ('NP','Nepal'));
        countryOptions.add(new Selectoption ('NL','Netherlands'));
        countryOptions.add(new Selectoption ('AN','Netherlands Antilles'));
        countryOptions.add(new Selectoption ('NC','New Caledonia'));
        countryOptions.add(new Selectoption ('NZ','New Zealand'));
        countryOptions.add(new Selectoption ('NI','Nicaragua'));
        countryOptions.add(new Selectoption ('NE','Niger'));
        countryOptions.add(new Selectoption ('NG','Nigeria'));
        countryOptions.add(new Selectoption ('NU','Niue'));
        countryOptions.add(new Selectoption ('NF','Norfolk Island'));
        countryOptions.add(new Selectoption ('MP','Northern Mariana Islands'));
        countryOptions.add(new Selectoption ('NO','Norway'));
        countryOptions.add(new Selectoption ('OM','Oman'));
        countryOptions.add(new Selectoption ('PK','Pakistan'));
        countryOptions.add(new Selectoption ('PW','Palau'));
        //countryOptions.add(new Selectoption ('Palestinian Territory, Occupied','Palestinian Territory, Occupied'));
        countryOptions.add(new Selectoption ('PA','Panama'));
        countryOptions.add(new Selectoption ('PG','Papua New Guinea'));
        countryOptions.add(new Selectoption ('PY','Paraguay'));
        countryOptions.add(new Selectoption ('PE','Peru'));
        countryOptions.add(new Selectoption ('PH','Philippines'));
        countryOptions.add(new Selectoption ('PN','Pitcairn'));
        countryOptions.add(new Selectoption ('PL','Poland'));
        countryOptions.add(new Selectoption ('PT','Portugal'));
        countryOptions.add(new Selectoption ('PR','Puerto Rico'));
        countryOptions.add(new Selectoption ('QA','Qatar'));
        countryOptions.add(new Selectoption ('RE','Reunion'));
        countryOptions.add(new Selectoption ('RO','Romania'));
        countryOptions.add(new Selectoption ('RU','Russian Federation'));
        countryOptions.add(new Selectoption ('RW','Rwanda'));
        countryOptions.add(new Selectoption ('SH','Saint Helena'));
        countryOptions.add(new Selectoption ('KN','Saint Kitts and Nevis'));
        countryOptions.add(new Selectoption ('LC','Saint Lucia'));
        countryOptions.add(new Selectoption ('PM','Saint Pierre and Miquelon'));
        countryOptions.add(new Selectoption ('VC','Saint Vincent and The Grenadines'));
        countryOptions.add(new Selectoption ('WS','Samoa'));
        countryOptions.add(new Selectoption ('SM','San Marino'));
        countryOptions.add(new Selectoption ('ST','Sao Tome and Principe'));
        countryOptions.add(new Selectoption ('SA','Saudi Arabia'));
        countryOptions.add(new Selectoption ('SN','Senegal'));
        countryOptions.add(new Selectoption ('RS','Serbia'));
        countryOptions.add(new Selectoption ('SC','Seychelles'));
        countryOptions.add(new Selectoption ('SL','Sierra Leone'));
        countryOptions.add(new Selectoption ('SG','Singapore'));
        countryOptions.add(new Selectoption ('SK','Slovakia'));
        countryOptions.add(new Selectoption ('SI','Slovenia'));
        countryOptions.add(new Selectoption ('SB','Solomon Islands'));
        countryOptions.add(new Selectoption ('SO','Somalia'));
        countryOptions.add(new Selectoption ('ZA','South Africa'));
        countryOptions.add(new Selectoption ('GS','South Georgia and The South Sandwich Islands'));
        countryOptions.add(new Selectoption ('ES','Spain'));
        countryOptions.add(new Selectoption ('LK','Sri Lanka'));
        countryOptions.add(new Selectoption ('SD','Sudan'));
        countryOptions.add(new Selectoption ('SR','Suriname'));
        countryOptions.add(new Selectoption ('SJ','Svalbard and Jan Mayen'));
        countryOptions.add(new Selectoption ('SZ','Swaziland'));
        countryOptions.add(new Selectoption ('SE','Sweden'));
        countryOptions.add(new Selectoption ('CH','Switzerland'));
        countryOptions.add(new Selectoption ('SY','Syrian Arab Republic'));
        countryOptions.add(new Selectoption ('TW','Taiwan, Province of China'));
        countryOptions.add(new Selectoption ('TZ','Tajikistan'));
        countryOptions.add(new Selectoption ('TZ','Tanzania, United Republic of'));
        countryOptions.add(new Selectoption ('TH','Thailand'));
        //countryOptions.add(new Selectoption ('Timor-leste','Timor-leste'));
        countryOptions.add(new Selectoption ('TG','Togo'));
        countryOptions.add(new Selectoption ('TK','Tokelau'));
        countryOptions.add(new Selectoption ('TO','Tonga'));
        countryOptions.add(new Selectoption ('TT','Trinidad and Tobago'));
        countryOptions.add(new Selectoption ('TN','Tunisia'));
        countryOptions.add(new Selectoption ('TR','Turkey'));
        countryOptions.add(new Selectoption ('TM','Turkmenistan'));
        countryOptions.add(new Selectoption ('TC','Turks and Caicos Islands'));
        countryOptions.add(new Selectoption ('TV','Tuvalu'));
        countryOptions.add(new Selectoption ('UG','Uganda'));
        countryOptions.add(new Selectoption ('UA','Ukraine'));
        countryOptions.add(new Selectoption ('AE','United Arab Emirates'));
        countryOptions.add(new Selectoption ('UM','United States Minor Outlying Islands'));
        countryOptions.add(new Selectoption ('UY','Uruguay'));
        countryOptions.add(new Selectoption ('UZ','Uzbekistan'));
        countryOptions.add(new Selectoption ('VU','Vanuatu'));
        countryOptions.add(new Selectoption ('VE','Venezuela'));
        countryOptions.add(new Selectoption ('VN','Viet Nam'));
        countryOptions.add(new Selectoption ('VG','Virgin Islands, British'));
        countryOptions.add(new Selectoption ('VI','Virgin Islands, U.S.'));
        countryOptions.add(new Selectoption ('WF','Wallis and Futuna'));
        countryOptions.add(new Selectoption ('EH','Western Sahara'));
        countryOptions.add(new Selectoption ('YE','Yemen'));
        countryOptions.add(new Selectoption ('ZM','Zambia'));
        countryOptions.add(new Selectoption ('ZW','Zimbabwe'));

    }
    
    public Class GorupMembers{
        public String conId{get; set;}
        public Integer count{get; set;}
        public Integer count1{get; set;}
        public string title{get;set;}
        public string firstname{get;set;}
        public string phone{get;set;}
        public String dob{get; set;}
        public string lastname{get;set;}
        public string country{get;set;}
        public string zip{get;set;}
        public string city{get;set;}
        public string street{get;set;}
        public string email{get;set;}
        public string nationality{get; set;}
        public String passportNo {get;set;}
        public String passExpiryDate {get; set;}
        public string Address_Line_2{get; set;}
        public Boolean isLead{get; set;}
        public List<Airline_membership__c> airlineMemberships{get;set;}
        
        public GorupMembers(){
            this.airlineMemberships = new List<Airline_membership__c>();
        }
    }            
}
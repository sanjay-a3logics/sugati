public without sharing Class BookingConfirmationController{

    public String oppID{get; set;}
    public Boolean isSiteUser{get; set;}
   
    public String selectedCurrency{get; set;}
    public String selectedCurrency1{get; set;}
    public Decimal paymentDue{get; set;}
    public Decimal AmountDue;
    public String nameOnCard{get; set;}
    public Boolean sameAsLead{get; set;}
    public String emergencyFirstName{get;set;}
    public String cardType{get;set;}
    public String cardNumber{get;set;}
    public String expiryMonth{get;set;}
    public String expiryYear{get;set;}
    public String securityCode{get;set;}
    public String addressLine1{get; set;}
    public String addressLine2{get; set;}
    public String addressLine3{get; set;}
    public String town{get; set;}
    public String zipCode{get; set;}
    public String country{get; set;}
    public String displayMessage{get; set;}
    public Boolean byTransfer{get; set;}
    public Boolean byCash{get; set;}
    public Boolean byCheque{get; set;}
    public Boolean byCardA{get; set;}
    public Boolean byCard{get; set;}
    public String card_token {get;set;}
    public String customerEmail {get;set;}
    public List<SelectOption> countryOptions{get; set;}
    public List<SelectOption> expiryYearOptions{get; set;}
    public String paymentTypeStr{get;set;}
    public Decimal creditCardCharges{get;set;}
    public Decimal totalPayment{get;set;}
    public Boolean showCashCheque{get; set;}
    public Opportunity opp{get; set;}    
    public Id cgid;
    
    Contact FoundContact;
    string groupMemberId = '';
    string paymentType ='Deposit';
    List<String> conIds = new List<String>();
    public static final String CHECKOUT_PUBLIC_KEY = 'pk_260e4aae-7b7b-4e0f-82be-139b2448bc80';
    public final string CHECKOUT_CARD_TOKEN_END_POINT = 'https://api2.checkout.com/v2/tokens/card';
    public Map<Id, Client_Group__c> clientGroups {get; set;}
    private boolean showAllOption;
    
    public BookingConfirmationController(ApexPages.StandardController controller) {
        try{
            //System.assert(false, 'aaaaa');
            oppID = controller.getId();
            expiryYearOptions = new List<SelectOption>();
            showCashCheque = false;
            byCard = false;
            byTransfer  = false; 
            byCheque = false;
            byCash = false;
            byCardA = false;
            cgid = apexpages.currentpage().getparameters().get('cgid');
            if(cgid!=null){
                selectedClientGroup =cgid;
            }
            if(oppID != null){
                List<Profile> PROFILE = [SELECT Id, Name,UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                if(PROFILE[0].UserLicense.Name == 'Guest User License'){
                    isSiteUser =true;    
                }
                else{
                    isSiteUser =false;
                }
                opp = [Select ID,Amount,Name,O_Deposit_Due_Date__c,CurrencyISOCode,O_Total_Payment_Without_CC__c ,pipeline__c,AccountID,O_Policy_No__c,O_Days_to_Departure__c,O_Insurance_Company__c,O_Credit_Card_Charges_P__c,O_Booking_Currency__c ,
                        O_Booking_Date__c,O_Departure_Date__c,O_Deposit_Required1__c,O_Total_Payment1__c,O_Total_Payment__c,
                        O_Outstanding__c,(Select ID, GM_Contact__c,GM_Lead_Passenger__c from Group_Members__r), 
                            O_Ts_Cs__c, (select id,CP_Client_Group_Payment__c from Client_Payments__r) 
                             from Opportunity where Id = :oppId];
                
                
                if(opp.O_Credit_Card_Charges_P__c != null){
                    creditCardCharges = opp.O_Credit_Card_Charges_P__c;
                }
                else{
                    creditCardCharges = 3;
                }
                
                 
                /*
                If(Opp.O_Deposit_Due_Date__c > System.today() && Opp.O_Total_Payment_Without_CC__c == 0){
                    paymentDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    AmountDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                }
                else{
                    paymentDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    AmountDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                }
                if(paymentDue < 0){
                    paymentDue = 0;    
                }
                
                //System.assert(false, Opp.O_Deposit_Due_Date__c > System.today());
                
                If(Opp.O_Deposit_Due_Date__c > System.today()){
                    if(opp.O_Deposit_Required1__c == null || Opp.O_Total_Payment_Without_CC__c > opp.O_Deposit_Required1__c || opp.O_Deposit_Required1__c == 0){
                        paymentDue = (opp.Amount - opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = paymentDue; 
                    }
                    else{
                        paymentDue = opp.O_Deposit_Required1__c.setScale(2); 
                        if(Opp.O_Total_Payment_Without_CC__c != null)
                            paymentDue = (opp.O_Deposit_Required1__c - Opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = paymentDue; 
                        //System.assert(false,paymentDue);
                    }
                }
                else{
                    paymentDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    AmountDue = paymentDue;
                }
                if(paymentDue < 0){
                    paymentDue = 0.00; 
                    AmountDue = 0.00;   
                }
                */
                selectedCurrency = opp.CurrencyISOCode;
                selectedCurrency1 = opp.CurrencyISOCode;
                for(Group_Member__c gm : opp.Group_Members__r){
                    conIds.add(gm.GM_Contact__c);
                }
                
            }
            
            loadCountries();
            sameAsLead = true;
            changeAddress();
            
            
            for(Integer i = system.today().year();i<=system.today().year()+10;i++){
                expiryYearOptions.add(new SelectOption(''+i,''+i));
            }
            cardNumber = '';
            nameOnCard = '';
            changeAddress();
             
            clientGroups = new Map<Id, Client_Group__c>([SELECT Id, Name, CG_Selling_Price__c, CG_Deposit_Required_I__c FROM Client_Group__c where CG_Opportunity__c = :oppId]); 
            
            //By Default show amount for first client group
            if(cgid!=null)
                showAllOption = true;
            else
                showAllOption = false;
             
            for(Client_Payment__c cp : opp.Client_Payments__r ){
                if(cp.CP_Client_Group_Payment__c)    
                    showAllOption = false;
            }
            changeClientGroup();
        }
        catch(Exception e){
            //System.assert(false,e.getLineNumber()+'     '+ e.getMessage());
            ApexPages.addMessages(e);
        }
    }
    
    public void changeAddress(){
        Contact FoundContact = new Contact();
        For(Account acc : [Select Id,Name,Phone,BillingStreet, 
                            BillingState, BillingCountry , BillingCity ,BillingPostalCode, ShippingStreet ,ShippingState, 
                            ShippingCountry,ShippingPostalCode ,ShippingCity,(Select Id,birthDate,salutation,FirstName,lastname,Phone,C_Lead_Passenger__c,Email,MailingStreet,MailingState,
                                    MailingPostalCode,MailingCountry,MailingCity,OtherStreet,OtherState,OtherCountry,OtherPostalCode  
                           from Contacts where Id in :conIds order by createdDate) from Account where Id = :opp.AccountID]){
            if(acc.Contacts.size() == 1){
                //acc.A_Lead_Email__c = acc.Contacts[0].Email;
                FoundContact = acc.Contacts[0];
                acc.phone = acc.Contacts[0].phone;
            }
            else{
                Boolean isFilled = false;
                for(Contact c : acc.Contacts){
                    string cname = c.firstname + ' ' + c.lastname;
                    if (acc.name.contains(cname)) {
                        //acc.A_Lead_Email__c = c.Email;
                        acc.phone = c.phone;
                        FoundContact = c;
                        isFilled = true;
                    }
                } 
                if(!isFilled){
                    for(Contact c : acc.Contacts){
                        if (FoundContact .Id == null && c.C_Lead_Passenger__c) {
                            acc.phone = c.phone;
                            //acc.A_Lead_Email__c = c.Email;
                            FoundContact = c;
                        }
                        
                    }        
                }   
            }     
        }
        if(Foundcontact != null){
            showCashCheque = true;
        }
        if(FoundContact.Id != null && sameAsLead){
            nameOncard = FoundContact.FirstName+' '+FoundContact.LastName;
            if(FoundContact.MailingStreet != null){
                addressLine1 = FoundContact.MailingStreet;
            }
            if(FoundContact.MailingState != null){
                addressLine2  = FoundContact.MailingState;
            }
            if(FoundContact.MailingCountry != null){
                country = FoundContact.MailingCountry;
            }
            if(FoundContact.MailingCity != null){
                town = FoundContact.MailingCity;
            }
            if(FoundContact.MailingPostalCode != null){
                zipCode = FoundContact.MailingPostalCode;
            }
        }
        if(!sameAsLead){
            nameOncard = ''; 
            addressLine1 = '';  
            addressLine2  = ''; 
            country = '';
            town = '';
            zipCode = '';
        }
        changeType();
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
    
    public void changeType(){
        if(byCard){
            if(creditCardCharges != 0){
                totalPayment = paymentDue+(paymentDue*creditCardCharges/100).setScale(2);  
            }
            else{
                totalPayment = paymentDue.setScale(2);      
            }
        }
          
    }
    
    Boolean isRedirect = false;
    public PageReference Confirm(){
        try{

            Boolean isValidatedSuccessfully = true;
            if (opp.id != null) {
                //opp.O_Reminder__c = isReminder;
                if (!(byTransfer || byCheque || byCash || byCard || byCardA)) {
                    displayMessage = 'Please select at least one payment type';
                    isValidatedSuccessfully = false;
                }
                else {
                    
                    if ((byTransfer || byCheque || byCash || byCard || byCardA) && paymentDue != null) {
                        if ( paymentDue < 0) {
                            displayMessage = 'Amount must be a positive number';
                            isValidatedSuccessfully = false;
                        }
                    }
                    
                    if (isValidatedSuccessfully) {
                        /*
                        if (AmountDue > paymentDue && isSiteUser == true ) {
                            displayMessage = 'The deposit required for this booking is ' + opp.O_Booking_Currency__c + ' ' + amountDue + ' and you are attempting to pay ' + opp.O_Booking_Currency__c + ' ' + paymentDue;
                            //system.assert(false, displayMessage);
                            isValidatedSuccessfully = false;
                        }
                        else {
                        */    
                        if(selectedClientGroup == '')
                            totalPaymentWithoutCC = Opp.O_Total_Payment_Without_CC__c;
                        if(totalPaymentWithoutCC == 0){
                            paymentType = 'Deposit';
                        }
                        else{
                            paymentType = 'Interim';    
                        }
                        if (AmountDue == paymentDue) {
                            paymentType = 'Full';
                        }
                        if(byTransfer || byCheque || byCash || byCardA){
                            String cp = createClientPayment();
                            if(isRedirect){
                                PageReference pg = new PageReference('/apex/ThankYouConfirmation?id='+oppId+'&cp='+paymentTypeStr);
                                pg.setRedirect(true);
                                return pg;
                            }
                            
                        }
                        //***Updated by Naval 14-OCT-15
                        else{
                            if(customerEmail == null){
                                displayMessage = 'Please makes sure that lead guest is having email id.';
                                return null;
                            }
                              
                            //System.assert(false, paymentDue+'***'+cardNumber+'*****'+addressLine1);
                            paymentTypeStr = 'credit card';
                            displayMessage = '';
                            Http h = new Http();
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint(CHECKOUT_CARD_TOKEN_END_POINT);
                            req.setHeader('Authorization',CHECKOUT_PUBLIC_KEY);
                            req.setHeader('Content-Type','application/json;charset=UTF-8');
                            req.setMethod('POST');
                            // Send the request, and return a response
                            String payLoad = '';
                              
                            Decimal duePaymentInCents = totalPayment*100;
                            payLoad += '{';
                            payLoad += '"customerEmail": "'+customerEmail+'",';
                            payLoad += '"number": "'+ cardNumber.trim() +'",';
                            payLoad += '"name": "'+ nameOncard +'",';
                            payLoad += '"customerName": "'+ nameOncard +'",';
                            payLoad += '"expiryMonth": "'+ expiryMonth +'",';
                            payLoad += '"expiryYear": "'+ expiryYear +'",';
                            payLoad += '"cvv": "'+ securityCode +'",';
                            payLoad += '"requestSource": "JS",';
                            payLoad += '"billingDetails": {';
                            payLoad += '"addressLine1": "'+ addressLine1 +'",';
                            payLoad += '"addressLine2": "'+ addressLine2 +'",';
                            payLoad += '"postcode": "'+ zipCode +'",';
                            payLoad += '"country": "'+ country +'",';
                            payLoad += '"city": "'+ town +'"';
                            payLoad += '}';
                            payLoad += '}';
                            //system.debug('*****Request Payload ******' +payLoad);
                            req.setBody(payLoad);
                            //system.assert(false, payLoad); 
                            HttpResponse res = h.send(req);
                            res.getBody();
                            system.debug('*****Response ******'+res.getBody());
                            if(res.getStatusCode() != 200){
                                ErrorResponse error = (ErrorResponse) JSON.deserialize(res.getBody(), ErrorResponse.class);
                                System.debug('******Card Token Error In Response*****'+ error.errors);
                                if(error.errors != null){
                                    for(String err : error.errors)
                                        displayMessage += '<br/>'+err;   
                                    String logId = createPaymentLog('Error \r\n'+displayMessage, paymentDue, selectedCurrency1, '', cardType);
                                }
                                createPaymentLog('Error \r\n'+res.getBody(), paymentDue, selectedCurrency1, '', cardType);
                                //system.assert(false,  log);
                            }
                            else{
                                CardTokenResponse cardToken  = (CardTokenResponse) JSON.deserialize(res.getBody(), CardTokenResponse.class);
                                
                                String logId = createPaymentLog('Success \r\n Card Token \r\n'+res.getBody(), totalPayment, selectedCurrency1, cardToken.id, cardToken.card.paymentMethod);
                                card_token = cardToken.id;
                                system.debug('******Card Token Error In Response*****'+  res.getBody());
                                PageReference pg = Page.ProcessPayments;
                                pg.getParameters().put('id',logId);
                                pg.getParameters().put('cc',String.valueOf(creditCardCharges));
                                String encodedName = EncodingUtil.urlEncode(nameOncard, 'UTF-8');
                                pg.getParameters().put('name', encodedName);
                                pg.getParameters().put('p', selectedClientGroup);
                                //pg.getParameters().put('card_token',card_token);
                                pg.setRedirect(true);
                                return pg;
                                
                            }
                        }
                                   
                    
                    }
                }
            }
        }
        Catch(Exception e){
            //System.assert(false, e.getMessage()+e.getStackTraceString());
            displayMessage = e.getMessage()+e.getStackTraceString();
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference back(){
        return new PageReference('/apex/BookingForm?id='+oppId);    
    }
    
    public String createPaymentLog(String descrptn, Decimal amt, String currencyCode, String cardToken, String cardType){
        try{
            Payment_Log__c log = new Payment_Log__c();
            log.PL_Opportunity__c =  opp.id;
            log.PL_Description__c = descrptn;
            log.PL_Payment_Amount__c = amt;
            log.PL_Currency_Code__c = currencyCode; 
            log.PL_Card_Token__c = cardToken;  
            log.PL_Card_Type__c = cardType;
            insert log;  
            return log.id;
        }catch(Exception e){
            System.debug('****** Error****' + e.getStackTraceString());
            return null;
        }
    }
    
    public String selectedClientGroup {get;set;}
    //Get Client Group Names as Select Option
    public List<SelectOption> getClientGroupNames(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'All'));
        if(clientGroups.size() != 0 ){
            for(Client_Group__c cg : clientGroups.values()){
                options.add(new SelectOption(cg.Id, cg.Name));
            }
        }
        return options;
    }
    
    Decimal totalPaymentWithoutCC = 0;
    public void changeClientGroup(){
        totalPaymentWithoutCC = 0;
        try{
            // Update all the fields if user selected a client group 
            if(selectedClientGroup != '' && selectedClientGroup != null){
                List<group_member__c> gms = [Select id,GM_Contact__c, GM_Contact__r.email from group_member__c where GM_Client_Group__c =:selectedClientGroup  AND GM_Lead_Passenger__c  = true AND GM_Contact__c != null];
                
                if (gms.size() > 0) {
                    groupMemberId = gms[0].id;
                    for(group_member__c gm : gms){
                        if(gm.GM_Contact__c != null && gm.GM_Contact__r.email != null){
                            customerEmail = gms[0].GM_Contact__r.email;
                            break;
                        }
                    }    
                }  
                Client_Group__c selectedCG = clientGroups.get(selectedClientGroup);
                for(Client_Payment__c cp : [Select Id, CP_Payee__c, CP_Receipt_AmountEx__c From Client_Payment__c where CP_Payee__c =: selectedClientGroup AND CP_Processed_On__c != null ]){
                    totalPaymentWithoutCC += cp.CP_Receipt_AmountEx__c;
                }
                If(Opp.O_Deposit_Due_Date__c > System.today()){
                    if(selectedCG.CG_Deposit_Required_I__c == null || totalPaymentWithoutCC > selectedCG.CG_Deposit_Required_I__c || selectedCG.CG_Deposit_Required_I__c == 0){
                        paymentDue = (selectedCG.CG_Selling_Price__c - totalPaymentWithoutCC).setScale(2);
                        AmountDue = paymentDue; 
                    }
                    else{
                        //paymentDue = selectedCG.CG_Deposit_Required_I__c.setScale(2); 
                        paymentDue = (selectedCG.CG_Deposit_Required_I__c - totalPaymentWithoutCC).setScale(2);
                        AmountDue = paymentDue; 
                        //System.assert(false,paymentDue);
                    }
                }
                else if(selectedCG.CG_Selling_Price__c != null){
                    paymentDue = (selectedCG.CG_Selling_Price__c - totalPaymentWithoutCC).setScale(2);
                    AmountDue = paymentDue;
                }
                if(paymentDue < 0){
                    paymentDue = 0.00; 
                    AmountDue = 0.00;   
                }
            }
            else{
                // Update all the fields if user selected All option
                List<group_member__c> gms = [Select id,GM_Contact__c,GM_Contact__r.email from group_member__c where GM_Opportunity__c =: opp.Id AND GM_Lead_Passenger__c  = true AND GM_Contact__c != null];
                if (gms.size() > 0) {
                    groupMemberId = gms[0].id;
                    for(group_member__c gm : gms){
                        if(gm.GM_Contact__c != null && gm.GM_Contact__r.email != null){
                            customerEmail = gms[0].GM_Contact__r.email;
                            break;
                        }
                    }    
                }  
                If(Opp.O_Deposit_Due_Date__c > System.today() && Opp.O_Total_Payment_Without_CC__c == 0){
                        paymentDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                }
                else{
                    if(opp.Amount != null){
                        paymentDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    }
                    else{
                        paymentDue = 0;
                        AmountDue = 0;
                    }
                }
                if(paymentDue < 0){
                    paymentDue = 0;    
                }
                
                //System.assert(false, Opp.O_Deposit_Due_Date__c > System.today());
                
                If(Opp.O_Deposit_Due_Date__c > System.today()){
                    if(opp.O_Deposit_Required1__c == null || Opp.O_Total_Payment_Without_CC__c > opp.O_Deposit_Required1__c || opp.O_Deposit_Required1__c == 0){
                        paymentDue = (opp.Amount - opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = paymentDue; 
                    }
                    else{
                        paymentDue = opp.O_Deposit_Required1__c.setScale(2); 
                        if(Opp.O_Total_Payment_Without_CC__c != null)
                            paymentDue = (opp.O_Deposit_Required1__c - Opp.O_Total_Payment_Without_CC__c).setScale(2);
                        AmountDue = paymentDue; 
                        //System.assert(false,paymentDue);
                    }
                }
                else{
                    if(opp.Amount != null)
                        paymentDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    else
                        paymentDue = 0;
                    AmountDue = paymentDue;
                }
                if(paymentDue < 0){
                    paymentDue = 0.00; 
                    AmountDue = 0.00;   
                }
            }
        }
        catch(Exception e){
            System.assert(false, e.getMessage() + '******' + e.getLineNumber()); 
            displayMessage = e.getMessage()+e.getStackTraceString();
            ApexPages.addMessages(e);
        }
    }
    
    String createClientPayment() {
        try{
            List<Client_Payment__c> lstClientPayments = new List<Client_Payment__c>();
            decimal amountPaid = 0;
               
            //Check if it's first payment from OBF
            boolean isFirstPayment = false;
            boolean isClientGroupPayment = false;
            if(selectedClientGroup != null && selectedClientGroup != '')
                isClientGroupPayment = true;    
            if(opp.O_Ts_Cs__c && opp.Client_Payments__r.size() == 0){
                isFirstPayment = true;
            } 
            if ( byCheque != false && paymentDue != 0) {
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid,CP_Client_Invoice__c = null,
                CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Cheque', CP_Payee__c = selectedClientGroup == '' ? null : selectedClientGroup, CP_Client_Group_Payment__c = isClientGroupPayment,
                CP_Transaction_Status__c = '', CP_Type__c ='PDQ', CP_Payment_Type__c=paymentType, CP_First_Payment__c = isFirstPayment ));
                
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'cheque';
            }
            if (byTransfer != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Bank/Transfer', CP_Payee__c = selectedClientGroup == '' ? null : selectedClientGroup, CP_Client_Group_Payment__c = isClientGroupPayment,
                CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType, CP_First_Payment__c = isFirstPayment));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'transfer';
            }
            
            if (byCash != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Cash', CP_Payee__c = selectedClientGroup == '' ? null : selectedClientGroup, CP_Client_Group_Payment__c = isClientGroupPayment,
                CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType, CP_First_Payment__c = isFirstPayment));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'cash';
            }
            if (byCardA != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Credit Card - Amex', CP_Payee__c = selectedClientGroup == '' ? null : selectedClientGroup, CP_Client_Group_Payment__c = isClientGroupPayment,
                CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType, CP_First_Payment__c = isFirstPayment));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'Amex';
            }
            
            //***Updated by veer 07-Jan-15
            if(opp.O_Days_to_Departure__c != null && opp.O_Days_to_Departure__c <= 60){
                paymentType = 'Full';
            }
            //***
            
            lstClientPayments = Utility.updatePayeeFieldOfClientPayment(new Set<String>{groupMemberId },lstClientPayments);
            insert lstClientPayments;

            System.debug('******Client Payments   '+  lstClientPayments);
            List<Client_Payment_Detail__c> paymentdetails = new List<Client_Payment_Detail__c>();
            for (Client_Payment__c cp: lstClientPayments) {
                paymentdetails.add(new Client_Payment_Detail__c(CPD_Client_Payment__c =cp.id,  CPD_Group_Member__c =groupMemberId ));
            }
            
            insert paymentdetails;
            
            if (paymentDue != null  ) {
                 opp.O_last_Payment__c = paymentDue;
            }
            opp.stagename = 'Booked';
            opp.pipeline__c = true;
            Utility.isCopied = true;
            update opp;
            
            if (!Utility.isInternalUser()) {
                Utility.saveSteps(opp.Id, 6);
            }
            isRedirect = true;
            if(lstClientPayments.size() > 0){
                return lstClientPayments[0].Id;
            }
            else{
                return null;
            }
        }
        catch(exception e){
            //System.assert(false, e);
            ApexPages.addMessages(e);
            displayMessage = e.getMessage()+e.getStackTraceString();
            return null;
        }
    }
    
          
    public void CalculateDue(){
        
        if(selectedCurrency1 == 'USD'){
             /*if(Opp.O_Exchange_Rate_USD__c != null){
               if(Opp.O_Exchange_Rate_USD__r.ER_Exchange_Rate__c > 0 && AmountDue > 0){
                    paymentDue = AmountDue * (Opp.O_Exchange_Rate_USD__r.ER_Exchange_Rate__c);
                    paymentDue = paymentDue.setScale(2);
                }
            }*/
        }
        else{
            paymentDue = AmountDue;
            paymentDue = paymentDue.setScale(2);
        }
        
    }  
    
    public class ErrorResponse{
        public String errorCode; 
        public String message;
        public List<String> errors;
    }
    
    public class CardTokenResponse{
        public String id; 
        public DateTime created;
        public boolean used;
        public CardInfo card;
    }
    public class CardInfo{
        public String expiryMonth; 
        public String expiryYear; 
        public String id; 
        public String last4 ; 
        public String  paymentMethod; 
        public String name; 
    }
    
}
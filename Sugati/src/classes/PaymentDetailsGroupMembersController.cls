public without sharing class PaymentDetailsGroupMembersController{
    public Contact contact{get;set;}
    
    public final string vspdirect_register = 'https://live.sagepay.com/gateway/service/vspdirect-register.vsp';
    public final string direct3dcallback = 'https://live.sagepay.com/gateway/service/direct3dcallback.vsp';
    
    public string typeofPaymentcard{get;set;}
    public string amount2{get;set;}
    public string creditcardcharges{get;set;}
    public string  totalpayment{get;set;}
    public String creditCardNumber{get;set;}
    public string fromdate{get;set;}
    public String cvvNumber{get;set;}
    public String expiryDate{get;set;}
    public String securityNumber{get;set;}
    public String IssueNumber{get;set;}
    public string nameonCard{get;set;}
    
    public Boolean isAddressSameAsClient{get;set;}
    public string country{get;set;}
    public string zip{get;set;}
    public string street{get;set;}
    public string city{get;set;}
    public string state{get;set;}
    public string address2{get;set;}
    public string address3{get;set;}
    
    public string amount{get;set;}
    public string amount1{get;set;}
    public String md{get;set;}
    public String pareq{get;set;}
    public Boolean is3DAUTH{get;set;}
    public String acsurl{get;set;}
    public String selectedCardType{get;set;}
    public string paymentMethod{get;set;}
    
    public Boolean Creditcardpayment{get;set;}
    public Boolean othertypePayment{get;set;}
    public Boolean othertypePayment2{get;set;}
    public Boolean othertypePayment3{get;set;}
    public Boolean othertypePayment4{get;set;}
    public Boolean othertypePayment5{get;set;}
    
    
    public Boolean isRedirectionSuccess{get;set;}
    public string queryString{get;set;}
    public String leadName{get; set;} 
    public string countryAuto{get;set;}
    public string zipAuto{get;set;}
    public string cityAuto{get;set;}
    public string streetAuto{get;set;}
    public string Address_Line_2Auto{get;set;}
    public string Address_Line_3Auto{get;set;}
    public Boolean isReminder{get;set;}
    public Boolean isOTUK{get; set;}
    public String expiryMonth{get; set;}
    public String expiryYear{get; set;}
    
    public list<SelectOption> cardTypes{
        get{
            if(cardTypes == null){
                cardTypes = new list<SelectOption>();
                cardTypes.add(new SelectOption('none','--none--'));
                if(isOTUK){
                    cardTypes.add(new SelectOption('AMEX','Amex (No fee)'));
                    cardTypes.add(new SelectOption('MAESTRO','Maestro (No fee)'));
                    cardTypes.add(new SelectOption('MC','Master Credit  (No fee)'));
                    cardTypes.add(new SelectOption('MCDEBIT','Master Debit (No fee)'));
                    cardTypes.add(new SelectOption('VISA','Visa Credit (No fee)'));
                    cardTypes.add(new SelectOption('DELTA','Visa Debit (No Fee)'));
                }
                else{
                    cardTypes.add(new SelectOption('AMEX','Amex (3% fee)'));
                    cardTypes.add(new SelectOption('MAESTRO','Maestro (No fee)'));
                    cardTypes.add(new SelectOption('MC','Master Credit (3% fee)'));
                    cardTypes.add(new SelectOption('MCDEBIT','Master Debit (No fee)'));
                    cardTypes.add(new SelectOption('VISA','Visa Credit (3% fee)'));
                    cardTypes.add(new SelectOption('DELTA','Visa Debit (No Fee)'));
                }
                
                
            }
            return cardTypes;
        }
        set;
    }
    
    public Opportunity opp{get;set;}
    public string displayMessage{get;set;}
    public string oppId{get;set;}
    public List<selectOption> countryOptions{get;set;}
    public Boolean IsInternalUser {get;set;}
    public String logDescription{get; set;}
    String logId = '';
    
    public PaymentDetailsGroupMembersController(Apexpages.standardController controller){
        try {
            expiryMonth = '';
            expiryYear = '';
            lstGroupMembers = new List<String>();
          //  isInternalUser = Utility.isInternalUser();
            queryString = '';
            isRedirectionSuccess = false;
            opp = new Opportunity();
            oppId = controller.getId();
            logId = ApexPages.CurrentPage().getParameters().get('logId');
            isOTUK = False;
            
            if (oppId  != null) {
                List<Opportunity> opps = [select id,O_RecordType__r.Name, stagename,O_Reminder__c,O_Days_to_Departure__c,accountid,amount, O_Requested_Amount__c,O_Outstanding__c,O_Booking_Currency__c,O_Total_Payment__c from opportunity where id=: controller.getId()];
                if (opps.size() > 0) {
                    opp = opps[0];
                }
                isReminder = opp.O_Reminder__c;
                
                if(opp.O_RecordType__r.Name != null){
                   // for(recordType rt : [Select Id, Name from recordType where Id = :opp.recordTypeId]){
                        if(opp.O_RecordType__r.Name == 'OTUK')
                            isOTUK = true;
                   // }
                }
                //*** Updated by veer 07-Jan
                if(opp.O_Requested_Amount__c == null && opp.O_Days_to_Departure__c <= 60){
                    opp.O_Requested_Amount__c = opp.O_Outstanding__c;    
                }
                else if(opp.O_Requested_Amount__c == null && opp.O_Days_to_Departure__c > 60){
                    if(isOTUK )
                        opp.O_Requested_Amount__c = opp.O_Outstanding__c*0.30;    
                    else
                        opp.O_Requested_Amount__c = opp.O_Outstanding__c*0.20;    
                }
                //****//
                Map<String,String> countryToCodeMap = new Map<String,String>{ 'United Kingdom'=>'GB', 'United States'=>'US', 
                'Afghanistan'=>'AF','Albania'=>'AL', 'Algeria'=>'DZ', 'American Samoa'=>'AS', 'Andorra'=>'AD', 'Angola'=>'AO', 
                'Anguilla'=>'AI', 'Antarctica'=>'AQ', 'Antigua and Barbuda'=>'AG', 'Argentina'=>'AR', 'Armenia'=>'AM', 'Aruba'=>'AW', 
                'Australia'=>'AU', 'AustriaAustria'=>'AT', 'Azerbaijan'=>'AZ', 'Bahamas'=>'BS', 'Bahrain'=>'BH', 'Bangladesh'=>'BD', 
                'Barbados'=>'BB', 'Belarus'=>'BY', 'Belgium'=>'BE', 'Belize'=>'BZ', 'Benin'=>'BJ', 'Bermuda'=>'BM', 'Bhutan'=>'BT', 
                'Bolivia'=>'BO', 'Bosnia and Herzegovina'=>'BA', 'Botswana'=>'BW', 'Bouvet Island'=>'BV', 'Brazil'=>'BR', 
                'British Indian Ocean Territory'=>'IO', 'Brunei Darussalam'=>'BN', 'Bulgaria'=>'BG', 'Burkina Faso'=>'BF', 
                'Burundi'=>'BI', 'Cambodia'=>'KH', 'Cameroon'=>'CM', 'Canada'=>'CA', 'Cape Verde'=>'CV', 'Cayman Islands'=>'KY', 
                'Central African Republic'=>'CF', 'Chad'=>'TD', 'Chile'=>'CL', 'China'=>'CN', 'Christmas Island'=>'CX', 
                'Cocos (Keeling) Islands'=>'CC', 'Colombia'=>'CO', 'Comoros'=>'KM', 'Congo'=>'CG', 'Congo, The Democratic Republic of The'=>'CD, The Democratic Republic of The',
                'Cook Islands'=>'CK', 'Costa Rica'=>'CR', 'Cote D\'ivoire'=>'CI', 'Croatia'=>'HR', 
                'Cuba'=>'CU', 'Cyprus'=>'CY', 'Czech Republic'=>'CZ', 'Denmark'=>'DK', 'Djibouti'=>'DJ', 'Dominica'=>'DM', 
                'Dominican Republic'=>'DO', 'Ecuador'=>'EC', 'Egypt'=>'EG', 'El Salvador'=>'SV', 'Equatorial Guinea'=>'GQ', 
                'Eritrea'=>'ER', 'Estonia'=>'EE', 'Ethiopia'=>'ET', 'Falkland Islands (Malvinas)'=>'FK', 'Faroe Islands'=>'FO', 
                'Fiji'=>'FJ', 'Finland'=>'FI', 'France'=>'FR', 'French Guiana'=>'GF', 'French Polynesia'=>'PF', 
                'French Southern Territories'=>'TF', 'Gabon'=>'GA', 'Gambia'=>'GM', 'Georgia'=>'GE', 'Germany'=>'DE', 
                'Ghana'=>'GH', 'Gibraltar'=>'GI', 'Greece'=>'GR', 'Greenland'=>'GL', 'Grenada'=>'GD', 'Guadeloupe'=>'GP', 
                'Guam'=>'GU', 'Guatemala'=>'GT', 'Guinea'=>'GN', 'Guinea-bissau'=>'GW', 'Guyana'=>'GY', 'Haiti'=>'HT', 
                'Heard Island and McDonald Islands'=>'HM', 'Holy See (Vatican City State)'=>'VA', 'Honduras'=>'HN', 'Hong Kong'=>'HK', 
                'Hungary'=>'HU', 'Iceland'=>'IS', 'India'=>'IN', 'Indonesia'=>'ID', 'Iran, Islamic Republic of'=>'IR, Islamic Republic of', 
                'Iraq'=>'IQ', 'Ireland'=>'IE', 'Israel'=>'IL', 'Italy'=>'IT', 'Jamaica'=>'JM', 'Japan'=>'JP', 'Jordan'=>'JO', 
                'Kazakhstan'=>'KZ', 'Kenya'=>'KE', 'Kiribati'=>'KI', 'Korea, Democratic People\'s Republic of'=>'KP, Democratic People\'s Republic of', 
                'Korea, Republic of'=>'KR', 'Kuwait'=>'KW', 'Kyrgyzstan'=>'KG', 'Latvia'=>'LV', 'Lebanon'=>'LB', 'Lesotho'=>'LS', 
                'Liberia'=>'LR', 'Libyan Arab Jamahiriya'=>'LY', 'Liechtenstein'=>'LI', 'Lithuania'=>'LT', 'Luxembourg'=>'LU', 'Macao'=>'MO', 
                'Macedonia, The Former Yugoslav Republic of'=>'MK, The Former Yugoslav Republic of', 'Madagascar'=>'MG', 'Malawi'=>'MW', 
                'Malaysia'=>'MY', 'Maldives'=>'MV', 'Mali'=>'ML', 'Malta'=>'MT', 'Marshall Islands'=>'MH', 'Martinique'=>'MQ', 'Mauritania'=>'MR',
                'Mauritius'=>'MU', 'Mayotte'=>'YT', 'Mexico'=>'MX', 'Micronesia, Federated States of'=>'FM', 'Moldova, Republic of'=>'MD, Republic of',
                'Monaco'=>'MC', 'Mongolia'=>'MN', 'Montenegro'=>'ME', 'Montserrat'=>'MS', 'Morocco'=>'MA', 'Mozambique'=>'MZ', 'Myanmar'=>'MM', 
                'Namibia'=>'NA', 'Nauru'=>'NR', 'Nepal'=>'NP', 'Netherlands'=>'NL', 'Netherlands Antilles'=>'AN', 'New Caledonia'=>'NC', 
                'New Zealand'=>'NZ', 'Nicaragua'=>'NI', 'Niger'=>'NE', 'Nigeria'=>'NG', 'Niue'=>'NU', 'Norfolk Island'=>'NF',
                'Northern Mariana Islands'=>'MP', 'Norway'=>'NO', 'Oman'=>'OM', 'Pakistan'=>'PK', 'Palau'=>'PW', 'Panama'=>'PA', 
                'Papua New Guinea'=>'PG', 'Paraguay'=>'PY', 'Peru'=>'PE', 'Philippines'=>'PH', 'Pitcairn'=>'PN', 'Poland'=>'PL', 
                'Portugal'=>'PT', 'Puerto Rico'=>'PR', 'Qatar'=>'QA', 'Reunion'=>'RE', 'Romania'=>'RO', 'Russian Federation'=>'RU', 
                'Rwanda'=>'RW', 'Saint Helena'=>'SH', 'Saint Kitts and Nevis'=>'KN', 'Saint Lucia'=>'LC', 'Saint Pierre and Miquelon'=>'PM',
                'Saint Vincent and The Grenadines'=>'VC', 'Samoa'=>'WS', 'San Marino'=>'SM', 'Sao Tome and Principe'=>'ST', 
                'Saudi Arabia'=>'SA', 'Senegal'=>'SN', 'Serbia'=>'RS', 'Seychelles'=>'SC', 'Sierra Leone'=>'SL', 'Singapore'=>'SG', 
                'Slovakia'=>'SK', 'Slovenia'=>'SI', 'Solomon Islands'=>'SB', 'Somalia'=>'SO', 'South Africa'=>'ZA', 
                'South Georgia and The South Sandwich Islands'=>'GS', 'Spain'=>'ES', 'Sri Lanka'=>'LK', 'Sudan'=>'SD', 'Suriname'=>'SR', 
                'Svalbard and Jan Mayen'=>'SJ', 'Swaziland'=>'SZ', 'Sweden'=>'SE', 'Switzerland'=>'CH', 'Syrian Arab Republic'=>'SY', 
                'Taiwan, Province of China'=>'TW', 'Tajikistan'=>'TZ', 'Tanzania, United Republic of'=>'TZ', 'Thailand'=>'TH', 'Togo'=>'TG',
                'Tokelau'=>'TK', 'Tonga'=>'TO', 'Trinidad and Tobago'=>'TT', 'Tunisia'=>'TN', 'Turkey'=>'TR', 'Turkmenistan'=>'TM', 
                'Turks and Caicos Islands'=>'TC', 'Tuvalu'=>'TV', 'Uganda'=>'UG', 'Ukraine'=>'UA', 'United Arab Emirates'=>'AE', 
                'United States Minor Outlying Islands'=>'UM', 'Uruguay'=>'UY', 'Uzbekistan'=>'UZ', 'Vanuatu'=>'VU', 'Venezuela'=>'VE', 
                'Viet Nam'=>'VN', 'Virgin Islands, British'=>'VG', 'Virgin Islands, U.S.'=>'VI', 'Wallis and Futuna'=>'WF', 
                'Western Sahara'=>'EH', 'Yemen'=>'YE', 'Zambia'=>'ZM', 'Zimbabwe'=>'ZW'};
            
                LIst<group_member__c> gms = [Select id,GM_Contact__c from group_member__c where GM_Opportunity__c=: opp.Id  and GM_Lead_Passenger__c  = true and GM_Contact__c != null];
        
                if (gms.size() > 0) {
                    List<Contact> contacts = [select id, Name, FirstName, LastName, MailingCountry, phone, MailingPostalCode, Mobilephone, 
                                    MailingStreet, Email, MailingCity, MailingState,C_Address_Line_2__c,C_Address_Line_3__c
                                    ,(Select id from group_members__r where GM_Opportunity__c=: opp.Id limit 1) from contact 
                                    where Id = :gms[0].GM_Contact__c limit 1];
                    if(contacts.size() > 0){
                        contact = contacts[0];   
                        leadName = contact.FirstName +' '+contact.LastName;
                        zipAuto = contact.MailingPostalCode ;
                        cityAuto= contact.MailingCity ; 
                        streetAuto= contact.Mailingstreet;  
                        if(countryToCodeMap.containsKey(contact.MailingCountry)){ 
                            countryAuto = countryToCodeMap.get(contact.MailingCountry);
                        }
                        Address_Line_2Auto = contact.C_Address_Line_2__c; 
                        Address_Line_3Auto = contact.C_Address_Line_3__c;
                        
                    }
                
                }
                
                if(logId != ''){
                    for(Payment_Log__c pl : [Select Id,PL_Description__c from Payment_Log__c where Id = :logId]){
                       logDescription = pl.PL_Description__c;
                    }
                }
               
                
                loadMembers();
                loadCountries();
            }
        }
        catch(Exception e) {
            displayMessage = e.getMessage();
        }
        
    }
    public void changeCountry(){}
    public void changeAddress(){
        if(isAddressSameAsClient){
            country = countryAuto;
            zip = zipAuto;
            street = streetAuto;
            address2 = Address_Line_2Auto;
            address3 = Address_Line_3Auto; 
            city = cityAuto;
        }
        else{
            country = '';
            zip = '';
            street = '';
            address2 = '';
            address3 = ''; 
            city = '';
        }
       
    }
    void loadCountries() {
        countryOptions= new List<Selectoption>();
        countryOptions.add(new selectoption('','-Select-'));    
        countryOptions.add(new Selectoption ('GB','United Kingdom'));
        countryOptions.add(new Selectoption ('US','United States'));
        countryOptions.add(new Selectoption ('AF','Afghanistan'));
        //countryOptions.add(new Selectoption ('�land Islands','�land Islands'));
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
    
    public List<GroupMembersWrapper> groupMembers{get;set;}
    public void loadMembers() {
        groupMembers = new List<GroupMembersWrapper>();
        for (Group_Member__c gm: [select id,GM_Contact__r.name  from Group_Member__c where GM_Opportunity__c =: opp.id order by GM_Contact__r.lastname, GM_Contact__r.firstname ]) {
            groupMembers.add( new GroupMembersWrapper (gm, false));
        }
    }
    
    public List<String> lstGroupMembers{get;set;}
    public List<Selectoption> getGroupMembers() {
        List<Selectoption> options = new List<Selectoption>();
        for (Group_Member__c gm: [select id,GM_Contact__r.name  from Group_Member__c where GM_Opportunity__c =: opp.id order by GM_Contact__r.lastname, GM_Contact__r.firstname ]) {
            options.add(new Selectoption(gm.id,gm.GM_Contact__r.name));
        }
        
        return options;
    }
    
    public Pagereference back() {
        return new Pagereference(Page.Summary.geturl() +'?id='+OppId) ;
    }
    
    public boolean isValidatedSuccessfully{get;set;}
    string paymentType ='Deposit';
    public Pagereference next() {
        
        if(expiryMonth == null){
            expiryMonth = '';    
        }
        if(expiryYear == null){
            expiryYear= '';    
        }
        expiryDate = expiryMonth+''+expiryYear;
        
        isValidatedSuccessfully = true;
        displayMessage ='';
        
        
        try {
            if (opp.id != null) {
                opp.O_Reminder__c = isReminder;
                Set<String> selectedGMIds = new Set<String>();
                queryString  ='';
                for (GroupMembersWrapper gm: groupMembers) {
                    if (gm.isSelected) {
                        selectedGMIds.add(gm.gm.id);
                    }
                }
            
                if (selectedGMIds.size() > 0) {
                    if (othertypePayment == false && othertypePayment2 == false && othertypePayment3 == false && othertypePayment4 == false && othertypePayment5 == false && Creditcardpayment == false) {
                        displayMessage = 'Please select at least one payment type';
                    }
                    else {
                        decimal totalpayment = 0;
                        if (othertypePayment && amount != null) {
                            if (amount.trim() =='' || decimal.valueOf(amount) < 0) {
                                displayMessage = 'Amount must be a positive number';
                                isValidatedSuccessfully = false;
                            }
                            else {
                                totalpayment += decimal.valueOf(amount) ;
                            }
                        }
                        if (othertypePayment2  && amount1 != null) {
                            if (amount1.trim() =='' || decimal.valueOf(amount1) < 0) {
                                displayMessage = 'Amount must be a positive number';
                                isValidatedSuccessfully = false;
                            }
                            else {
                                totalpayment += decimal.valueOf(amount1);
                            }
                        }
                        if (Creditcardpayment && amount2 != null) {
                            if (amount2.trim() =='' || decimal.valueOf(amount2) < 0) {
                                displayMessage = 'Amount must be a positive number';
                                isValidatedSuccessfully = false;
                            }
                            else {
                                totalpayment += decimal.valueOf(amount2);
                            }
                        }
                     
                        if (isValidatedSuccessfully) { 
                            if (opp.O_Outstanding__c < totalpayment && isInternalUser == false ) {
                                System.debug('Under Message');
                                displayMessage = 'Required amount is only ' + opp.O_Booking_Currency__c + ' ' + opp.O_Outstanding__c + ' and you are attemting to pay ' +  opp.O_Booking_Currency__c + ' ' + totalpayment ;
                                isValidatedSuccessfully = false;
                            }
                            else {
                                paymentType = 'Deposit';
                                if (opp.O_Outstanding__c == totalpayment) {
                                    paymentType = 'Full';
                                }
                                isRedirectionSuccess = true;
                                if (Creditcardpayment) {
                                    sagepay(selectedGMIds);
                                }
                                if (othertypePayment || othertypePayment2 || othertypePayment3 || othertypePayment4 || othertypePayment5) {
                                    if (isRedirectionSuccess ) {
                                        createClientPayment(selectedGMIds);
                                        if(queryString == ''){
                                            queryString = '?id='+opp.Id;
                                        }
                                    }
                                    Utility.isCopied = true;
                                    update opp;
                                }
                            } 
                        }
                    }
                }
                else {
                    displayMessage =' Please select a group member';
                }
            }
            else {
                displayMessage  ='Opps... Something went wrong. Please click here to reenter the payment details';
            }
        }
        catch(Exception e) {
            displayMessage = e.getMessage();
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    void createClientPayment(Set<String> selectedGMIds) {
        
        try {
            if (groupMembers.size() > 0 && opp.id != null) {
                
                List<Client_Payment__c> lstClientPayments = new List<Client_Payment__c>();
                decimal amountPaid = 0;
                if ( amount != null && othertypePayment && amount != '') {
                    amountPaid = decimal.valueOf(amount);
                    lstClientPayments.add(new Client_Payment__c(CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                    CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Cheque',
                    CP_Transaction_Status__c = '', CP_Type__c ='PDQ', CP_Payment_Type__c=paymentType));
                }
                if (amount1 != null && othertypePayment2 && amount1 != ''){
                    amountPaid = decimal.valueOf(amount1);
                    lstClientPayments.add(new Client_Payment__c(CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                    CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Bank/Transfer',
                    CP_Transaction_Status__c = '', CP_Type__c ='PDQ', CP_Payment_Type__c=paymentType));
                }
                //***Updated by veer 07-Jan-15
                if(opp.O_Days_to_Departure__c != null && opp.O_Days_to_Departure__c <= 60){
                    paymentType = 'Full';
                }
                //***
                if (othertypePayment3 ){
                    lstClientPayments.add(new Client_Payment__c(CP_Amount__c = null,CP_Client_Invoice__c = null,
                    CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Euro Transfer',
                    CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType ));
                }
                if (othertypePayment4 ){
                    lstClientPayments.add(new Client_Payment__c(CP_Amount__c = null,CP_Client_Invoice__c = null,
                    CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'US Transfer',
                    CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType ));
                }
                if (othertypePayment5 ){
                    lstClientPayments.add(new Client_Payment__c(CP_Amount__c = null,CP_Client_Invoice__c = null,
                    CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Off Shore',
                    CP_Transaction_Status__c = '', CP_Type__c ='PDQ',CP_Payment_Type__c=paymentType ));
                }
                
                lstClientPayments = Utility.updatePayeeFieldOfClientPayment(selectedGMIds,lstClientPayments);
                insert lstClientPayments;
                
                List<Client_Payment_Detail__c> paymentdetails = new List<Client_Payment_Detail__c>();
                for (String gmId: selectedGMIds) {
                    for (Client_Payment__c cp: lstClientPayments) {
                        paymentdetails.add(new Client_Payment_Detail__c(CPD_Client_Payment__c =cp.id,  CPD_Group_Member__c =gmId));
                    }
                }
                insert paymentdetails;
                
                
                opp.stagename = 'Booked';
                Utility.isCopied = true;
                update opp;
                
                //if (!Utility.isInternalUser()) {
                 //  Utility.saveSteps(opp.Id, 6);
               // }
            }  
        }
        catch(Exception e) {
            throw e;
        }  
    }
    
    public void sagepay(Set<String> selectedGMIds){
        try{
         String gmIds = '';
         for (String gmId : selectedGMIds) {
             if(gmIds == '') {
                 gmIds = gmId;
             }
             else {
                 gmIds += ',' + gmid;
             }
         }
         
          isRedirectionSuccess = true; 
         HttpRequest req = new HttpRequest();        
         // Create a new http object to send the request object
         // A response object is generated as a result of the request 
         
         Decimal totalpayment = 0;
         decimal ccCharges = 0;
         if (selectedCardType == 'MAESTRO' || selectedCardType == 'MCDEBIT' || selectedCardType == 'DELTA' || isOTUK) {
             
             if( amount2.trim() != '' ) {
                 totalpayment = decimal.valueOf(amount2);
             }
         }
         else {
             if (amount2.trim() != '') {
                 ccCharges =decimal.valueOf(amount2)* 3/100;
                 ccCharges = ccCharges.setScale(3);
                 totalpayment = decimal.valueOf(amount2)+ccCharges ;
             }
         }
         totalpayment = totalpayment .setScale(2);
         //system.assert(false,totalpayment);
         
         
         req.setEndpoint(vspdirect_register );
         string vTXT = 'originaltravel-PDGM-' + string.valueOf(Math.random());
         //string payBody = 'VPSProtocol=3.00&TxType=PAYMENT&Vendor=originaltravel&VendorTxCode='+vTXT +'&Amount='+amount2+'&Currency=GBP&Description=Test%20Payment&CardHolder=Test%20Payer&CardNumber='+creditCardNumber+'&CardType='+selectedCardType+'&CV2='+cvvNumber+'&ExpiryDate='+expiryDate+'&BillingSurname=Test&BillingFirstnames=Test&BillingAddress1=Test&BillingCity=Test&BillingPostCode=111111&BillingCountry=US&BillingState=AL&DeliverySurname=Test&DeliveryFirstnames=Test&DeliveryAddress1=Test&DeliveryCity=Test&DeliveryPostCode=111111&DeliveryCountry=US&DeliveryState=AL';
         string payBody = 'VPSProtocol=3.00&Apply3DSecure=1&TxType=PAYMENT&Vendor=originaltravel&VendorTxCode='+vTXT +'&Amount='+totalpayment+'&Currency='+opp.O_Booking_Currency__c+'&Description=Originaltravel%20online%20booking&CardHolder='+nameonCard+'&CardNumber='+creditCardNumber+'&CardType='+selectedCardType+'&CV2='+cvvNumber+'&ExpiryDate='+expiryDate+'&BillingSurname='+contact.lastname+'&BillingFirstnames='+contact.firstname+'&BillingAddress1='+street+'&BillingCity='+city+'&BillingPostCode='+zip+'&BillingCountry='+country+'&DeliveryFirstnames='+contact.firstname+'&DeliverySurname='+contact.lastname+'&DeliveryAddress1='+street+'&DeliveryAddress2='+address2+'&DeliveryCity='+city+'&DeliveryPostCode='+zip+'&DeliveryCountry='+country;
         
         if (country == 'US') {
         payBody += '&BillingState='+state+'&DeliveryState='+state;
         }
         
         req.setBody(payBody);
         req.setMethod('POST'); 
      
         Http http = new Http();
         HTTPResponse res = http.send(req);         
         if(res.getStatusCode() == 200){
             //system.assert(false,responseBody);
             
             //dummy response
             /*'VPSProtocol=3.00 Status=3DAUTH StatusDetail=2007 : Please redirect your customer to the ACSURL, passing the MD and PaReq. 
             3DSecureStatus=OK MD=2014101896985584551 ACSURL=https://test.sagepay.com/mpitools/accesscontroler?action=pareq 
             PAReq=eJxVUk1TwjAQvfsrOlydaZLSlMAsYUAO9oBWYRz1lkkzUO0XaUvx35uUViSnfW93X7JvA4tzljonpaukyOcj4uLRgt/B7qCVWm+VbLTisFFVJfbKSeL5yMPEJ5iwaTBllDKfUjLiEC1f1ZFDr8ONjEsADdAIaHkQec1ByOMqfOI+pgGdAOohZEqHa049PB77FE8Iwyww6QsNucgUf9bJPslF6uy0OKkUUMeCLJq81j+ceQGgAUCjU36o63KGUNu2btH31l2rKwu3+QZkiwBd3xY1NqqM6DmJub89vS3X7+LlM1xV6WpD7svyK27Jbv8xB2QrIBa14tYQPMXMIcHMI7MxA9TxIDL7Gk6wOWbSC4LSXrK8Sf2nwDiuVS6HgQYE6lwWuTIVHqC/GGJVSb61u4nEj7OJQnO5pQBdh3l4tLbL2jhJrONdZPUS4xQJ8EXQAkC2FvXLRP3aTXTzHX4BGZe38Q==';
             */
             
             
             string responseBody = res.getBody();
             String StatusResponse = responseBody.subString(responseBody.indexOf('Status'));
             system.debug(StatusResponse.indexOf('=')+1);
             system.debug(StatusResponse.indexOf('StatusDetail'));         
             String StatusValues = StatusResponse.subString(StatusResponse.indexOf('=')+1,StatusResponse.indexOf('StatusDetail'));
             system.debug('status Value'+StatusValues );
             //system.assert(false,responseBody );
             if(StatusValues.trim() !='3DAUTH' && StatusValues.trim() !='OK'){
                String errorResponse = StatusResponse.subString(StatusResponse.indexOf('StatusDetail'));
                String errorValue = errorResponse.subString(errorResponse.indexOf(':')+1,errorResponse.indexOf('.'));
                //ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, StatusValues+':' +errorValue);
                //Apexpages.addMessage(message);
                displayMessage =  errorValue;
                isRedirectionSuccess = false; 
                Payment_Log__c plog = new Payment_Log__c(PL_Opportunity__c = oppId,PL_Description__c =errorValue +'--------'+ payBody );
                 insert plog;
                
             }else{
                 Payment_Log__c log = new Payment_Log__c(PL_Opportunity__c = oppId,PL_Description__c =payBody );
                 insert log;
                 string tempSecureStatus = responseBody.subString(responseBody.indexOf('3DSecureStatus'));
                 
                 string SecureStatus = tempSecureStatus.split(' ')[0].trim().split('=')[1].trim();
                 
                 
                 if (SecureStatus.contains('OK')) {
                 
                     is3DAUTH = true;
                     
                     md = responseBody.substring(responseBody.indexof('MD=')+3, responseBody.indexof('ACSURL=')).trim();
                     acsurl= responseBody.substring(responseBody.indexof('ACSURL=')+7, responseBody.indexof('PAReq=')).trim();
                     pareq = responseBody.substring(responseBody.indexof('PAReq=')+6).trim();
                     
                     isRedirectionSuccess = true; 
                     queryString = '?amount='+ totalpayment+'&cardtype='+selectedCardType+'&id='+oppId+'&gmIds='+gmIds+'&3dStatus=OK&ccCharges='+ccCharges+'&paymentType='+paymentType ;
                     
                     system.debug('acsurl'+acsurl);
                     system.debug('Md'+md );
                     system.debug('PaReq'+PaReq);
                 
                 }
                 else if (SecureStatus.contains('NOTCHECKED')){
                     queryString = '?amount='+ totalpayment+'&cardtype='+selectedCardType+'&id='+oppId+'&gmIds='+gmIds+'&3dStatus=NOTCHECKED&ccCharges='+ccCharges+'&paymentType='+paymentType ;
                      isRedirectionSuccess = false; 
                 }
            }
         
         }
          else {
             isRedirectionSuccess = false; 
             displayMessage = res.getstatus();
         }
         //return null;
         //return new Pagereference(Page.Insurance.geturl() +'?id='+Apexpages.currentPage().getParameters().get('id')) ;
        }
        catch(exception e){
            apexPages.addMessages(e);
            displayMessage = e.getMessage() +'----------'+e.getLineNumber();
            isRedirectionSuccess = false;
        }
         
    }
    
    public class GroupMembersWrapper {
        public Group_Member__c gm{get;set;}
        public Boolean isSelected{get;set;}
        public GroupMembersWrapper(Group_Member__c gm,Boolean isSelected) {
            this.gm = gm;
            this.isSelected = isSelected;
        }
    }
}
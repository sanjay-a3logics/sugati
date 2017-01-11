public with sharing class ConvertLeadController {
    public Lead leadRec;
    public Boolean fromHE;
    
    //Constructor
    public ConvertLeadController(ApexPages.StandardController controller) {
        leadRec = [Select id, Name, createdDate, Salutation,CurrencyIsoCode, HasOptedOutOfEmail, Message__c, FirstName, LastName, Postalcode, L_Division__c, L_Location__c, Email, LeadSource, Phone, Description, IsConverted from Lead WHERE id =: controller.getId()];
    }
    
    //Method that will convert lead
    public PageReference initConversion(){
        SavePoint sp = Database.setSavePoint();
        try{
            LeadStatus convertStatus = [Select MasterLabel from LeadStatus  where IsConverted = true limit 1];
            Database.LeadConvert lc = new Database.LeadConvert();
            Database.LeadConvertResult lcResult;
            Opportunity Opp;
            Account accRec;
            Contact conRec;
            //Create a savepoint to rollback the changes in case of any exception
            
            String divisionName = '';
            if (!leadRec.isConverted) {
                divisionName = leadRec.L_Division__c;
                lc = new Database.LeadConvert();
                String oppName = leadRec.Name;
                lc.setLeadId(leadRec.Id);
                lc.setOpportunityName(oppName);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                boolean matchedRecordFound = false;
                boolean matchedRecordContcat = false;
                //Check for matched accounts
                
                String lName = '%'+leadRec.Name+'%';
                if(leadRec.Email != null && leadRec.Email != ''){
                    for(Account acc : [SELECT id FROM Account WHERE Name like :lName AND (A_Email__c = :leadRec.Email  OR Phone = :leadRec.Phone OR A_Postal_Code__c = :leadRec.PostalCode) order by lastModifiedDate  limit 1]){
                        lc.setAccountId(acc.id);
                        accRec = acc;
                    }
                }
                if(accRec != null && accRec.Id != null){
                    for(Contact con : [Select Id from Contact where AccountId = :accRec.Id And Name like :lName AND (Email = :leadRec.Email OR Phone = :leadRec.Phone OR MailingPostalCode = :leadRec.PostalCode) order by lastModifiedDate  limit 1]){
                        lc.setContactId(con.id);
                    }
                }
                List<Holiday_Type__c> lstHolidayType = [Select Id from Holiday_Type__c where Name = 'Generic' limit 1];
                lcResult = Database.convertLead(lc);
                List<Travelling_Country__c> travellingCountries = new List<Travelling_Country__c>();  
                Date d = Date.today();         
                /*** Create an opportunity *****/
                if(lcResult != null){
                    Opp = new Opportunity();
                    Opp.Id = lcResult.getOpportunityId();
                    Map<String,Id> recordTypeMap = new Map<String,Id>();
                    oppName = '';
                    if(leadRec.FirstName != null)
                        oppName = leadRec.FirstName+' ';
                    if(leadRec.LastName != null)
                        oppName += leadRec.LastName;
                    Opp.name = 'New Enquiry';
                    Opp.StageName = 'Enquiry';
                    Opp.CloseDate = Date.newInstance(d.year(), d.month(), d.day());
                    if(leadRec.Email != null)
                        Opp.O_Lead_Email_Address__c = leadRec.Email;
                    if(leadRec.LeadSource != null)
                        Opp.LeadSource = leadRec.LeadSource;
                    if(leadRec.Description != null)
                        Opp.Description = leadRec.Description;
                    opp.closeDate = leadRec.createdDate.date();
                    Opp.O_Booking_Currency__c = leadRec.CurrencyIsoCode; 
                    Opp.CurrencyIsoCode = leadRec.CurrencyIsoCode; 
                    if(lstHolidayType.size() > 0){
                        Opp.O_Holiday_Type__c = lstHolidayType[0].Id;
                    }
                    Opp.Pipeline__c = true;
                    Opp.Type = 'Individual';
                    if(leadRec.Message__c != null)
                        opp.Description = leadRec.Message__c;
                    
                    /** Contact **/
                    List<Account> lstAccount = [Select Id,BillingStreet,BillingCity,BillingState,BillingPostalcode,BillingCountry from Account where Id = :lc.getAccountId() limit 1];
                    Contact cont = new Contact();
                    cont.Id = lcResult.getContactId();
                    cont.HasOptedOutOfEmail = leadRec.HasOptedOutOfEmail;
                    cont.Occupancy_Type__c = 'Adult';
                    if(lstAccount.size() > 0 ){
                        cont.mailingStreet = lstAccount[0].BillingStreet;
                        cont.MailingCity = lstAccount[0].BillingCity;
                        cont.MailingState = lstAccount[0].BillingState;
                        cont.MailingPostalcode = lstAccount[0].BillingPostalcode;
                        cont.MailingCountry = lstAccount[0].BillingCountry;
                    }
                    cont.Description = '';
                    update cont;
                    
                    
                    if(accRec != null){
                        Opp.AccountId = accRec.Id;
                    }
                    else{
                        Account Acc = new Account();
                        acc.Id = lcResult.getAccountId();
                        String Name = '';
                        if(leadRec.Salutation != null){
                            name = leadRec.Salutation+' ';
                            Acc.A_Salutation__c = leadRec.Salutation;
                        }
                        if(leadRec.FirstName != null){
                            name += leadRec.FirstName+' ';
                            Acc.A_First_Name__c = leadRec.FirstName;
                        }
                        if(leadRec.LastName != null){
                            name += leadRec.LastName;
                            Acc.A_Last_Name__c = leadRec.LastName;
                        }
                        Acc.name = Name;
                        if(Opp.O_Lead_Email_Address__c != null)
                            Acc.A_Email__c = Opp.O_Lead_Email_Address__c;
                        if(leadRec.PostalCode != null){
                            Acc.BillingPostalCode = leadRec.PostalCode;
                        }
                        upsert Acc;
                    }
                    upsert opp;
                }
            }
            
            /** Create Travelling Country for each location  **/
            if(lcResult != null && leadRec.L_Location__c != null){
                List<String> countries = new List<String>();
                Map<String, Travelling_Country__c> mapTravellingCountries = new Map<String,Travelling_Country__c>();
                Map<String, Id> mapCountries = new Map<String, Id>();
                for(Country__c country : [Select id, name from Country__c where name != null]){
                    mapCountries.put(country.name.touppercase(), country.id);    
                }
                Map<String, String> wheretogotoCountrytMap = new Map<String,String>();
                for(Where_to_go__c wheretogo : [select id,name,W_Country__c,W_Country__r.Name from Where_to_go__c]){
                    wheretogotoCountrytMap.put(wheretogo.Name.touppercase(),wheretogo.W_Country__r.Name);
                }
                if(leadRec.L_Location__c != null && leadRec.L_Location__c.contains(';')){
                    for(String country : leadRec.L_Location__c.split(';')){
                        if(country.contains('|')){
                            countries.add(country.trim().split('\\|')[0]);
                        }
                        else{
                            countries.add(country.trim());
                        }
                    }
                } 
                else if(leadRec.L_Location__c != null && leadRec.L_Location__c.contains(',')){
                    for(String country : leadRec.L_Location__c.split(',')){
                        if(country.contains('|')){
                            countries.add(country.trim().split('\\|')[0]);
                        }
                        else{
                            countries.add(country.trim());
                        }
                    }
                }   
                else if(leadRec.L_Location__c != null){  
                    if(leadRec.L_Location__c.contains('|')){
                        countries.add(leadRec.L_Location__c.trim().split('\\|')[0]);
                    }
                    else{
                        countries.add(leadRec.L_Location__c.trim());
                    } 
                }  
                for(String countryName : countries){
                    if(mapCountries.containsKey(countryName.trim().touppercase())){
                        mapTravellingCountries.put(countryName.trim().touppercase(), new Travelling_Country__c(TC_Country__c = mapCountries.get(countryName.trim().touppercase()), TC_Opportunity__c = opp.id));    
                    }    
                    else if(wheretogotoCountrytMap.containsKey(countryname.touppercase())){
                        String countryNameTemp = wheretogotoCountrytMap.get(countryname.touppercase());
                        if(mapCountries.containsKey(countryNameTemp.trim().touppercase()))
                            mapTravellingCountries.put(countryName.trim().touppercase(), new Travelling_Country__c(TC_Country__c = mapCountries.get(countryNameTemp.trim().touppercase()), TC_Opportunity__c = opp.id));    

                    }
                }
                insert mapTravellingCountries.values();
            }
            if(ApexPages.currentPage().getParameters().get('ret') == 'HE'){
                PageReference pgRef = Page.HolidayEnquiry;
                pgRef.getParameters().put('Id',opp.Id);
                return pgRef;
            } 
            if(opp != null){
                PageReference pgRef = new PageReference('/'+opp.id);    
                return pgRef;
            }
            else{
                return null;    
            }
        }
        catch(Exception e){
            //Rollback the changes
            Database.rollback(sp);
            System.assert(false,e.getMessage() + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage() + '  ' + e.getStackTraceString()));
            PageReference pgRef = new PageReference('/'+leadRec.id);    
            return pgRef;
        }
    }
}
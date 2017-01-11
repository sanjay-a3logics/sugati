public with sharing class RefreshOpportunity{
    public string oppId{get;set;}
    public Opportunity opp{get;set;}
    public String countries {get; set;}
    public String ExchangeRate{get; set;}
    
    private String oldBookingCurrency = 'GBP';
    private list<Client_Group__c> lstCG = new List<Client_Group__c>();
    
    
    public RefreshOpportunity(Apexpages.standardController controller) {
        try{
            oppId = controller.getId();
            countries = '';
            ExchangeRate = '1';
            
            if (oppId != null) {
                Opp();
                Integer i=1;
                for(Travelling_Country__c tc : Opp.Travelling_Countries__r){
                    if(i != Opp.Travelling_Countries__r.size())    
                        countries += tc.TC_Country__r.name+', ';
                    else
                        countries += tc.TC_Country__r.name;
                i++;
                }
            }
        }
        Catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    private void Opp(){
        opp = [select id,Owner.Name,Name,Account.Name,Amount,O_Total_Payment__c,CurrencyIsoCode,O_Booking_Currency__c,CreatedDate,StageName, 
                (Select Id,CG_Selling_Price__c,Name,CG_Charity__c,CG_Arrival_Presents__c,CG_Regulatory_Charges__c,CG_FX_Transfer_Charges__c 
                  from  Client_Groups__r), O_Departure_Date__c,O_Reference_Number__c , O_Quote_No__c, O_Booking_Number__c from Opportunity where id =: oppId];
            oldBookingCurrency = opp.currencyISOCode;
    }
    
    public void calculate(){
        
        if(opp.StageName != 'Booked' && opp.StageName != 'Booking Optional' && opp.Amount != null ){
            lstCG = new List<Client_Group__c>();
            String newCurrency = opp.CurrencyIsoCode;
            Opp();
            opp.CurrencyIsoCode = newCurrency;
            Map<String,Exchange_Rate__c> childExr = new Map<String,Exchange_Rate__c>();
            for(Exchange_Rate__c er : [Select id, ER_Base_Currency__c, ER_Book_From__c, ER_Book_To__c, ER_Exchange_Rate__c, ER_Sales_Currency__c, 
                                      ER_Travel_From__c, ER_Travel_To__c from Exchange_Rate__c where recordType.Name = 'Sell' and ER_Sales_Currency__c= :newCurrency]){
                if(opp.CreatedDate >= er.ER_Book_From__c && opp.CreatedDate <= er.ER_Book_To__c && opp.O_Departure_Date__c >= er.ER_Travel_From__c &&
                  opp.O_Departure_Date__c <= er.ER_Travel_To__c){
                      childExr.put(er.ER_Base_Currency__c,er);    
                }
            }
            if(childExr.containsKey(oldBookingCurrency)){
                opp.O_Booking_Currency__c = Opp.CurrencyIsoCode;
                ExchangeRate = ''+(childExr.get(oldBookingCurrency).ER_Exchange_Rate__c).setScale(4, RoundingMode.HALF_UP);
                Decimal totalAdditional = 0;
                for(Client_Group__c cg : opp.Client_Groups__r){
                    cg.CG_Selling_Price__c = (cg.CG_Selling_Price__c/childExr.get(oldBookingCurrency).ER_Exchange_Rate__c).setScale(2, RoundingMode.HALF_UP);
                    lstCG.add(cg);
                }
                opp.Amount = (opp.Amount/childExr.get(oldBookingCurrency).ER_Exchange_Rate__c).setScale(2, RoundingMode.HALF_UP);    
                    
            }
            
        }
        if(opp.StageName == 'Booked' || opp.StageName == 'Booking Optional'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Can\'t refresh rates on Bookings'));    
        }
        
    } 
    public void save(){
        if(opp.StageName != 'Booked' && opp.StageName != 'Booking Optional'){
            upsert lstCG;
            upsert opp;
            List<Supplier_Cost__c> lstSC = [Select Id from Supplier_Cost__c where SC_Client_Group__c in : opp.Client_Groups__r];
            
            update lstSC;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Opportunity updated'));
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Can\'t refresh rates on Bookings'));
        }
    }   
}
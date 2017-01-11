public with sharing class OpportunityDetailController{
    
    
    public String OppId;
    public String logourl{get;set;}
    public OpportunityDetailController(){
        OppId = apexpages.currentpage().getParameters().get('id');
        if(oppId == '' || oppId == null){
            OppId = apexpages.currentpage().getParameters().get('HEoppId');    
        }
    }
    public Opportunity Opp{get;set;}
    public String nameSpacePrefix{get;set;}
    
    
    public Opportunity getOppD(){
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        if(OppId != '' && OppId != null){
            return  [select id,name,O_Reference_Number__c,Account.name,Account.Total_Credit_Memo__c,O_Departure_Date__c,O_Return_Date__c,
                    Account.A_Total_Compensation_Credit_Memo__c,Account.A_Total_Promotional_Credit_Memo__c,O_Pax__c from Opportunity where id =: OppId];
        }
        return null;
    }
    
    public void refreshComponent(){
    
    }
}
public with Sharing Class SupplierCostandPaymentReportController{
    
    public String SCPStr{get; set;}
    
    public SupplierCostandPaymentReportController(ApexPages.StandardController controller) {
        if(controller.getId() != null){
            Map<Integer,Map<String,List<Supplier_Cost_Payment__c>>> mapSCP = new Map<Integer,Map<String,List<Supplier_Cost_Payment__c>>>();
            for(Supplier_Cost_Payment__c scp : [Select Id,CurrencyIsoCode,SCP_Outstanding_Amount__c,SCP_Exchange_Rate__r.ER_Exchange_Rate__c,
                     SCP_Is_Agent__c,SCP_Opportunity__c,SCP_Opportunity__r.Name,SCP_Outstanding__c,SCP_Total__c,SCP_Total_Cost_in_GBP__c,createdDate,
                     SCP_Total_Payment__c,SCP_Opportunity__r.O_Departure_Date__c  from Supplier_Cost_Payment__c where 
                     SCP_Supplier__c = :controller.getId() and SCC_Opportunity_Stage__c = 'Booked' order by createdDate ASC]){
                 
                 if(!mapSCP.containsKey(scp.SCP_Opportunity__r.O_Departure_Date__c.Year())){
                     mapSCP.put(scp.SCP_Opportunity__r.O_Departure_Date__c.Year(), new Map<String,List<Supplier_Cost_Payment__c>>());
                 }
                 if(!mapSCP.get(scp.SCP_Opportunity__r.O_Departure_Date__c.Year()).containsKey(scp.CurrencyIsoCode)){
                     mapSCP.get(scp.SCP_Opportunity__r.O_Departure_Date__c.Year()).put(scp.CurrencyIsoCode, new List<Supplier_Cost_Payment__c>());
                 }
                 mapSCP.get(scp.SCP_Opportunity__r.O_Departure_Date__c.Year()).get(scp.CurrencyIsoCode).add(scp);
             }
             //System.assert(false,mapSCP);
            SCPStr = JSON.serialize(mapSCP);
        }
    }
    
}
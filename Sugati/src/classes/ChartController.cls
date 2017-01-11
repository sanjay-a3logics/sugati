global class ChartController {

    public ChartController() {
    
    }

    
    public ChartController(Apexpages.standardController controller) {
    
    }
    
    
    @RemoteAction
    global static Map<String,List<Supplier_Cost__c>> getChartDataStr(String oId) {
        try{
            Map<String,List<Supplier_Cost__c>> mapSuppleirCost = new Map<String,List<Supplier_Cost__c>>();
            for(Supplier_Cost__c sc : [select id, SC_Option__c, SC_Total_Client_Group_Cost__c,SC_Total_Net_CostSC__c from Supplier_Cost__c 
                                        where SC_Supplier_Booking__r.SB_Opportunity__c =: oId order by SC_Option__c]){
                if(!mapSuppleirCost.containsKey(sc.SC_Option__c)){
                    mapSuppleirCost.put(sc.SC_Option__c, new List<Supplier_Cost__c>());
                }   
                mapSuppleirCost.get(sc.SC_Option__c).add(sc);
            }
            return mapSuppleirCost;
        }
        Catch(Exception e){
            System.assert(false, e.getstacktraceString());
            return null;
        }
    }
    
    @RemoteAction
    global static Map<String,Map<String,List<Supplier_Cost__c>>> getChartDataByClient(String oId) {
        try{
            Map<String,Map<String,List<Supplier_Cost__c>>> mapSuppleirCost = new Map<String,Map<String,List<Supplier_Cost__c>>>();
            for(Supplier_Cost__c sc : [select id, SC_Client_Group__c,SC_Total_Net_CostSC__c, SC_Client_Group__r.Name, SC_Option__c, SC_Total_Client_Group_Cost__c 
                                        from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c =: oId order by SC_Option__c]){
                if(!mapSuppleirCost.containsKey(sc.SC_Client_Group__r.Name)){
                    mapSuppleirCost.put(sc.SC_Client_Group__r.Name, new Map<String,List<Supplier_Cost__c>>());
                }
                
                if(!mapSuppleirCost.get(sc.SC_Client_Group__r.Name).containsKey(sc.SC_Option__c)){
                    mapSuppleirCost.get(sc.SC_Client_Group__r.Name).put(sc.SC_Option__c, new List<Supplier_Cost__c>());
                }   
                mapSuppleirCost.get(sc.SC_Client_Group__r.Name).get(sc.SC_Option__c).add(sc);
            }
            return mapSuppleirCost;
        }
        Catch(Exception e){
            System.assert(false, e.getstacktraceString());
            return null;
        }
    }
    
    
    
}
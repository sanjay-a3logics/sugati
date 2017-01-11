public without sharing class  SupplierPaymentController{
    public String oppRecord {get;set;}
    public Opportunity opp{get;set;}
    public String nameSpacePrefix{get;set;}
    public transient  String pickLists {get; set;}
    public String lstSupplierBookings{get; set;}
    
    public SupplierPaymentController(Apexpages.standardcontroller controller){
        oppRecord = '';
        try{
            ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            opp = [SELECT id,Account.A_Total_Promotional_Credit_Memo__c, currencyISOCode,O_Days_to_Departure__c, Name, O_Booking_Currency__c, AccountId, Amount, O_Outstanding__c, O_Departure_Date__c,
                                (Select Id, Name from Client_Groups__r order by Name) from Opportunity where Id =: controller.getId()];
            
            List<Supplier_Cost_Payment__c> lstSBC = [Select Id,SCP_Outstanding_Amount__c,SCP_Supplier_Currency__c,CurrencyIsoCode, SCP_Supplier__r.Name, SCP_Total__c, 
                                                        SCP_Supplier__c from Supplier_Cost_Payment__c where SCP_Opportunity__c = :opp.Id order by SCP_Supplier__r.Name];
                                    
            lstSupplierBookings = JSON.serialize(lstSBC);
            oppRecord = JSON.serialize(opp);
            pickLists = JSON.serialize(Utility.describePickLists(Utility.getNameSpacePrefix()+'Supplier_Payment__c'));
        }
        Catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : '+e.getMessage());
            ApexPages.addmessage(myMsg);
        }
    }
    
    
    //Get all the client payments detail of this opportunity
    @RemoteAction
    public static String getSupplierPayments(String oppId){
        List<Supplier_Payment__c> lstSupplierPayments = [Select Id,SP_Bank_Account__c, SP_Note__c, SP_Transferred_To_Accts__c, P_Amount__c, SP_Authorised_by__c, SP_Comment__c, SP_Costing_ROE__c, 
                                                            SP_Currency__c, SP_Due_Date__c, SP_Exchange_Rate__c, SP_FX_Gain_Loss__c, P_Invoice__c, 
                                                            SP_Paid_By__c, SP_Payment_Date__c, SP_Payment_Method__c, SP_Payment_RoE__c, SB_Payment_Type__c
                                                            ,SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__r.Name, SBP_Supplier_Cost_Currency_Value__r.SCP_Is_Agent__c,SP_Inv_Date__c,SP_Remittance_Comments__c,SP_Remittance_Comments_office_copy__c  
                                                            from Supplier_Payment__c  where SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c = :oppId order by CreatedDate];    
            return JSON.serialize(lstSupplierPayments);       
    }
    
    //Get all supplier cost and payment
    @RemoteAction
    public static String getSupplierCostnPayment(String oppId){
        List<Supplier_Cost_Payment__c> lstSupplierCostPayment = [Select Id,SCP_Outstanding_Amount__c,SCP_Supplier_Currency__c,CurrencyIsoCode, SCP_Supplier__r.Name, SCP_Total__c, 
                                                        SCP_Supplier__c from Supplier_Cost_Payment__c where SCP_Opportunity__c = :oppId];    
        return JSON.serialize(lstSupplierCostPayment);     
    }
    
    
    //Save Supplier Payments
    @RemoteAction
    public static String saveSupplierPayments(String SPJSON, String oppId){
        try{
            Supplier_Payment__c selectedCP = (Supplier_Payment__c) JSON.deserialize(SPJSON, Supplier_Payment__c.class);
            upsert selectedCP;
            List<Supplier_Payment__c> lstSupplierPayments = [Select Id,SP_Bank_Account__c, SP_Note__c, SP_Transferred_To_Accts__c, P_Amount__c, SP_Authorised_by__c, SP_Comment__c, SP_Costing_ROE__c, 
                                                                SP_Currency__c, SP_Due_Date__c, SP_Exchange_Rate__c, SP_FX_Gain_Loss__c, P_Invoice__c, 
                                                                SP_Paid_By__c, SP_Payment_Date__c, SP_Payment_Method__c, SP_Payment_RoE__c, SB_Payment_Type__c
                                                                ,SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__r.Name, SBP_Supplier_Cost_Currency_Value__r.SCP_Is_Agent__c,SP_Inv_Date__c,SP_Remittance_Comments__c,SP_Remittance_Comments_office_copy__c 
                                                                from Supplier_Payment__c  where SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c = :oppId order by CreatedDate];    
            return JSON.serialize(lstSupplierPayments); 
        }catch(Exception e){System.assert(false, e.getMessage());return null;} 
        
    }
    
    //Save All Supplier Payments
    @RemoteAction
    public static String saveAllSupplierPayments(String SPJSON, String oppId){
        try{
            List<Supplier_Payment__c> selectedCP = (List<Supplier_Payment__c>) JSON.deserialize(SPJSON, List<Supplier_Payment__c>.class);
            insert selectedCP;
            List<Supplier_Payment__c> lstSupplierPayments = [Select Id,SP_Bank_Account__c, SP_Note__c, SP_Transferred_To_Accts__c, P_Amount__c, SP_Authorised_by__c, SP_Comment__c, SP_Costing_ROE__c, 
                                                                SP_Currency__c, SP_Due_Date__c, SP_Exchange_Rate__c, SP_FX_Gain_Loss__c, P_Invoice__c, 
                                                                SP_Paid_By__c, SP_Payment_Date__c, SP_Payment_Method__c, SP_Payment_RoE__c, SB_Payment_Type__c
                                                                ,SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__r.Name, SBP_Supplier_Cost_Currency_Value__r.SCP_Is_Agent__c 
                                                                from Supplier_Payment__c  where SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c = :oppId order by CreatedDate];    
            return JSON.serialize(lstSupplierPayments); 
        }catch(Exception e){System.assert(false, e.getMessage());return null;}   
    }

}
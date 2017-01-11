public with sharing class ClientPaymentsController {
    public String oppRecord {get;set;}
    public String clientGroupsOptions {get;set;}
    public String newClientPaymentRec {get;set;}
    public String clientInvoices{get; set;}
    public Opportunity opp{get;set;}
    public String nameSpacePrefix{get;set;}
    public String lstCreditMemos{get; set;}
    
    public ClientPaymentsController(ApexPages.StandardController controller) {
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
            oppRecord = JSON.serialize(opp);
            List<pickListValue> clientGroups = new List<pickListValue>();
            for(Client_Group__c cg : opp.Client_Groups__r){
                clientGroups.add(new pickListValue(cg.Id, cg.Name));
            }
            List<pickListValue> lstpk = new List<pickListValue>();
            for(Client_Invoice__c cin : [Select Id,Name from Client_Invoice__c where I_Opportunity__c = :opp.Id]){
                lstpk.add(new pickListValue(cin.id, cin.Name));
            }
            List<pickListValue> lstCM = new List<pickListValue>();
            for(Credit_Memo__c CM : [Select Id,Name,CM_Note__c from Credit_Memo__c where CM_Account__c = :Opp.AccountId and 
                                    CM_Amount__c > 0 and CM_Type__c = 'Promotion']){
                lstCM.add(new pickListValue(cm.Id,cm.Name+' - '+cm.CM_Note__c));
            }
            lstCreditMemos = JSON.Serialize(lstCM);
            clientGroupsOptions  = JSON.serialize(clientGroups);
            Client_Payment__c cpRec = new Client_Payment__c(CP_Opportunity__c = Opp.Id);
            cpRec.CP_Date__c = System.today();
            newClientPaymentRec = JSON.serialize(cpRec);
            clientInvoices = JSON.serialize(lstpk);
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '**********' + e.getStackTraceString());
        }  
        //System.assert(false, clientGroupsOptions  );
    }
    
    
    
    public String getPageMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('ClientPayments'));
    }
    
    //Returns a Javascript map of picklist values for all the fields
    public String getPickListValues(){
        try{
            return JSON.serialize(Utility.describePickLists(Utility.getNameSpacePrefix()+'Client_Payment__c'));
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '**********' + e.getStackTraceString());
            return null;
        }  
    }
    
    //Get opportunity detail
    @RemoteAction
    public static Opportunity getOpportunityDetail(String oppId){
        try{
            return [SELECT id, currencyISOCode,O_Days_to_Departure__c, Name, O_Booking_Currency__c, Amount, O_Outstanding__c, O_Departure_Date__c,
                                (Select Id, Name from Client_Groups__r order by Name) from Opportunity where Id =:oppId];
        }
        catch(Exception e){
            System.assert(false, e.getMessage());
            return null;
        }            
    }
    
    
    //Get all the client payments detail of this opportunity
    @RemoteAction
    public static List<Client_Payment__c> getClientPayments(String oppId){
        try{
            List<Client_Payment__c> lstClientPayment = [Select Id, CP_Credit_Memo__c, CP_Client_Group_Payment__c, CP_Amount__c,CP_Card_Type__c,CP_Sec_Number__c,CP_Payee__c, CP_Currency__c, CP_Card_Cheque_Doc_No__c, CP_Expiry_Cheque_Doc_Date__c, CP_Receipt_AmountEx__c,
                                 CP_Processed_On__c,CP_Credit_Card_Charge__c, CP_Credit_Card_Charges_Amount__c,  Name,CP_Client_Invoice__c, CP_Contact__c, CP_Date__c, CP_Opportunity__c, 
                                CP_Payment_Method_C__c, CP_Transaction_Status__c, CP_Type__c from Client_Payment__c where CP_Opportunity__c = :OppId order by createdDate DESC];    
            return lstClientPayment;
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '**********' + e.getStackTraceString());
            return null;
        }            
    }
    
    //Save client payment record 
    @RemoteAction
    public static List<Client_Payment__c> saveClientPayment(String CPJSON){
        try{
            Client_Payment__c selectedCP = (Client_Payment__c) JSON.deserialize(CPJSON, Client_Payment__c.class);
            Opportunity opp = [select id,currencyISOCode, name,O_EU__c ,O_Reference_Number__c,stageName, O_Outstanding__c,O_Departure_Date__c,Amount,(Select Id,GM_First_Name__c,GM_Occupancy_Type__c ,GM_DOB__c, GM_Last_Name__c,GM_Client_Group__c,GM_Opportunity__c,GM_Lead_Passenger__c from Group_Members__r),
                  (Select Id,TC_Country__r.C_EU__c from Travelling_Countries__r), (Select Id, Name,CG_Total_Recommended_Selling_Price__c,CG_Selling_Price__c,
                  CG_Charity__c, CG_Opportunity__r.O_Target_Mark_Up_Value__c, CG_Regulatory_Charges__c, CG_FX_Transfer_Charges__c, CG_Arrival_Presents__c,CG_Total_cost_in_selling_currency__c From Client_Groups__r order by Name), 
                   account.name, O_Pax__c,CreatedDate, O_Return_Date__c, O_Booking_Currency__c,
                    O_Charity__c, O_Arrival_Presents__c, O_FX_Transfer_Charges__c 
                      from Opportunity where id =: selectedCP.CP_Opportunity__c];
            selectedCP.currencyISOCode = opp.currencyISOCode;          
            if(selectedCP.CP_Processed_On__c != null){
                opp.Pipeline__c = true;
                Opp.stageName = 'Booked';
            }
            //System.assert(false, selectedCP);
            Map<String,String> mapGMContact = new Map<String,String>();
            Map<String,String> mapGMContactEmail = new Map<String,String>();
            for(Group_Member__c gm : [Select Id, GM_Contact__c, GM_Client_Group__c,GM_Contact__r.Email from Group_Member__c  where GM_Client_Group__c  = :selectedCP.CP_Payee__c and GM_Lead_Passenger__c = true]){
                mapGMContact.put(gm.GM_Client_Group__c, gm.GM_Contact__c); 
                if(gm.GM_Contact__r.Email != null)
                    mapGMContactEmail.put(gm.GM_Client_Group__c, gm.GM_Contact__r.Email);   
            }
           
            if(selectedCP.CP_Payee__c != null && mapGMContact.containsKey(selectedCP.CP_Payee__c)){
                selectedCP.CP_Contact__c = mapGMContact.get(selectedCP.CP_Payee__c) ;
                if(mapGMContactEmail.containsKey(selectedCP.CP_Payee__c))
                    selectedCP.CP_Client_Email__c = mapGMContactEmail.get(selectedCP.CP_Payee__c) ;
            }
            String paymentType = 'Deposit';
            
            Decimal outstanding = 0;
            if(opp.O_Outstanding__c != null){
                outstanding  = opp.O_Outstanding__c;
            }
            if(selectedCP.CP_Amount__c == null){
                selectedCP.CP_Amount__c = 0;
            }
            if (outstanding-selectedCP.CP_Amount__c<=0) {
                paymentType = 'Full';
            }
            selectedCP.CP_Payment_Type__c = paymentType ;
            upsert selectedCP;
            
            Utility.isCopied = true;
            update Opp;
            
            String groupMemberId = '';
            LIst<group_member__c> gms = [Select id from group_member__c where GM_Opportunity__c=: opp.Id  and GM_Lead_Passenger__c  = true];
            
            if (gms.size() > 0) {
                groupMemberId = gms[0].id;
            }
            
            List<Client_Payment_Detail__c> payments = [Select Id from Client_Payment_Detail__c where CPD_Client_Payment__c = :selectedCP.Id];
            if(payments.size() == 0 && groupMemberId  != '' && groupMemberId  != null){
                List<Client_Payment_Detail__c> paymentdetails = new List<Client_Payment_Detail__c>();
                paymentdetails.add(new Client_Payment_Detail__c(CPD_Client_Payment__c =selectedCP.id,  CPD_Group_Member__c = groupMemberId ));
                insert paymentdetails;
            }
            
            //return updated data so view will be changed
            List<Client_Payment__c> lstClientPayment = [Select Id, CP_Credit_Memo__c, CP_Client_Group_Payment__c, CP_Amount__c,CP_Card_Type__c,CP_Sec_Number__c,CP_Payee__c, CP_Currency__c, CP_Card_Cheque_Doc_No__c, CP_Expiry_Cheque_Doc_Date__c, CP_Receipt_AmountEx__c,
                                 CP_Processed_On__c,CP_Credit_Card_Charge__c, CP_Credit_Card_Charges_Amount__c,  Name,CP_Client_Invoice__c, CP_Contact__c, CP_Date__c, CP_Opportunity__c, 
                                CP_Payment_Method_C__c, CP_Transaction_Status__c, CP_Type__c from Client_Payment__c where CP_Opportunity__c = :Opp.Id order by createdDate DESC];    
            return lstClientPayment;
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + '**********' + e.getMessage() + '**********' + e.getStackTraceString());
            return null;
        }
    }
    
    //Wrapper Classes for Picklist options
    public Class pickListValue{
        public String value{get; set;}
        public String label{get; set;}
        
        public pickListValue(String value, String label){
            this.value = value;
            this.label = label;
        }
    }
    
}
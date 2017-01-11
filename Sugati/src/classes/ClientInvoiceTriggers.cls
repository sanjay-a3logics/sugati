public with sharing Class ClientInvoiceTriggers{

    public ClientInvoiceTriggers(){
        
    }
    
    public static void ClientInvoiceTriggerBefore(){
        if(Site__c.getInstance().Run_Trigger__c){
            Integer InvoiceStartNumber = 10000;
            Invoice_Number__c Inv = new Invoice_Number__c();
            Map<String,Invoice_Number__c> RecInv = new Map<String,Invoice_Number__c>();
            
            Set<String> OppIds = new Set<String>();
            Map<String,String> OppRec  = new Map<String,String>();
            RecordType RecType = new RecordType();
            
            Set<String> OppRecTypes = new Set<String>();
            
            Map<String,String> CIRecMap = new Map<String,String>();
            //String recordTypeId='';
            for(RecordType Rt : [Select Id,Name,DeveloperName from RecordType where SObjectType = :Utility.getNameSpacePrefix()+'Client_Invoice__c']){
                if(Rt.DeveloperName == 'Committed'){
                    RecType = Rt;
                }
                CIRecMap.put(Rt.Id,Rt.DeveloperName);
            }
            
            if(Trigger.Isdelete){
                
                    for(Client_Invoice__c CI : (List<Client_Invoice__c>)Trigger.Old){
                        if(CIRecMap.containsKey(CI.RecordTypeId)){
                            if(CIRecMap.get(CI.RecordTypeId) == 'Committed'){
                               CI.RecordTypeId.addError('This record can\'t be deleted.');
                            }
                        }
                        /*
                        if(CI.CL_Opportunity_Locked__c){
                            CI.addError('Opportunity has been locked please contact to system admin.');
                        }
                        */
                    }
                
            }
            else{
                for(Client_Invoice__c i : (List<Client_Invoice__c>)trigger.new){
                     OppIds.add(i.I_Opportunity__c);
                }
                
                //Map Rule with Opportunity
                List<Rule__c> lstRules = [Select Id,R_Percentage__c,R_Days_to_Departure_From__c,R_Days_to_Departure_To__c,
                                         R_Deposit_Only__c,R_Supplier__c from Rule__c where RecordType.DeveloperName = 'Client_Payment' and Is_Active__c = true];
                Map<String,Rule__c> mapRuleWithOpp = new Map<String,Rule__c>();
                
                for(opportunity opp : [select id,name,O_Booking_to_Departure__c from opportunity where id in : oppIds]){
                    OppRec.put(opp.id,opp.name);
                    OppRecTypes.add(opp.name);
                    for(Rule__c r : lstRules){
                        if(r.R_Days_to_Departure_From__c < opp.O_Booking_to_Departure__c && r.R_Days_to_Departure_To__c > opp.O_Booking_to_Departure__c){
                            mapRuleWithOpp.put(opp.Id,r);
                        }
                    }
                }
                
                Set<String> Offices = new Set<String>();
                For(Invoice_Number__c InvNo : [select IN_Office__c From Invoice_Number__c]){
                    Offices.add(InvNo.IN_Office__c);
                }
                
                if(Offices.size() < 3){
                    if(!Offices.contains('Sugati')){
                        Invoice_Number__c InvSG = new Invoice_Number__c(IN_Last_Invoice_Number__c=0,IN_Office__c='Sugati');
                        insert InvSG;
                    }
                }
                
                for(Invoice_Number__c qs : [Select IN_Last_Invoice_Number__c,IN_Office__c From Invoice_Number__c where IN_Office__c ='Sugati' Order By LastModifiedDate DESC]){
                    RecInv.put(qs.IN_Office__c,qs);
                }
            
                for(Client_Invoice__c i : (List<Client_Invoice__c>)trigger.new){
                    if(CIRecMap.containsKey(i.RecordTypeId)){
                        if(CIRecMap.get(i.RecordTypeId) == 'Credit Note'){
                            if(i.CI_Credit_Note_Amount__c != null && i.CI_Credit_Note_Amount__c >= 0){
                                //i.CI_Credit_Note_Amount__c = i.CI_Credit_Note_Amount__c * (-1);
                                i.CI_Credit_Note_Amount__c.addError('Credit Note Amount must be in negative.');
                            }
                            if(i.I_Description__c == null || i.I_Description__c == ''){
                                //i.CI_Credit_Note_Amount__c = i.CI_Credit_Note_Amount__c * (-1);
                                i.I_Description__c.addError('Description field must be filled in.');
                            }
                        }
                    }
                    
                    Invoice_Number__c qs = RecInv.get('Sugati');
                    if(qs.IN_Last_Invoice_Number__c != null){
                        double dblInvNum = qs.IN_Last_Invoice_Number__c;
                        InvoiceStartNumber = dblInvNum.intValue();
                    }
                    
                    If(i.I_Invoice_Number__c == null){
                        InvoiceStartNumber = InvoiceStartNumber + 1;
                    }
                    
                    /** Check Description Text*********/
                    If(i.I_Description__c == null || i.I_Description__c == ''){
                        i.I_Description__c = 'To ensure that we receive the full amount of the bank transfer, please instruct your bank to remit the total amount net of all bank charges, failure to do so may lead you to being rebilled.';
                    }
                    /**/
                    
                    if(i.I_Invoice_Date__c != null && i.I_Invoice_Number__c == null){
                        qs.IN_Last_Invoice_Number__c = InvoiceStartNumber;
                        if(RecType != null && CIRecMap.get(i.RecordTypeId) == 'Proforma'){
                            i.RecordtypeId = RecType.id;
                        }
                        if(CIRecMap.get(i.recordTypeId) != 'Proforma'){
                            i.I_Invoice_Number__c = InvoiceStartNumber;
                            i.CI_Invoice_Number__c = 'CI-000'+i.I_Invoice_Number__c;
                            update qs;
                        }
                        
                    }
                    else{}  
                }
                
                //##-----------------------Client Invoice if client group selected -------##/
                
                List<Opportunity> lstOpp = [select id, O_Days_to_Departure__c,CurrencyIsoCode,Name,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                           O_Adult__c,O_Children__c,O_Infant__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Reference_Number__c,O_Due_Date__c,O_Country__c,O_Deposit_Required1__c,
                           O_Itinerary_Display_Price__c,O_Total_Payment__c,(select GM_Contact__r.Name
                                             from Group_Members__r),O_Suggested_Margin__r.M_Margin__c,
                             (Select ID,CG_Deposit_Required_I__c,Previous_Recommended_Selling_Price__c,CG_Recommended_Selling_Price_Rp__c, Name,CG_Total_Recommended_Selling_Price__c,CG_Selling_Price__c,
                           CG_Charity__c, CG_Regulatory_Charges__c,CG_Deposit_Overwrite__c, CG_FX_Transfer_Charges__c, CG_Arrival_Presents__c from Client_Groups__r)
                           from Opportunity where Id in :OppIds];
                    
                    Map<String,List<Client_Payment__c>> lstClientPayment = new Map<String,List<Client_Payment__c>>();
                    for(Client_payment__c  cp : [Select Id,CP_Receipt_AmountEx__c,CP_Opportunity__c,CP_Amount__c,CP_Payee__c,CP_Client_Invoice__c from Client_payment__c where CP_Opportunity__c in :OppIds and 
                                                                    CP_Processed_On__c != null and CP_Payee__c != null]){
                        if(!lstClientPayment.containsKey(cp.CP_Opportunity__c)){
                            lstClientPayment.put(cp.CP_Opportunity__c, new List<Client_Payment__c>());
                        }
                        lstClientPayment.get(cp.CP_Opportunity__c).add(cp);
                    }
                    Map<String,List<Supplier_Cost__c>> lstSupplierCost = new Map<String,List<Supplier_Cost__c>>();
                    for(Supplier_Cost__c sbc :  [Select Id,SC_Supplier_Booking__c,SC_Supplier_Booking__r.SB_Opportunity__c,SC_Total_Net_CostSC__c,SC_Supplier_Booking__r.recordType.Name,SC_Client_Group__c  
                                                                    from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c in :OppIds]){
                        if(!lstSupplierCost.containsKey(sbc.SC_Supplier_Booking__r.SB_Opportunity__c)){
                            lstSupplierCost.put(sbc.SC_Supplier_Booking__r.SB_Opportunity__c, new List<Supplier_Cost__c>());
                        }
                        lstSupplierCost.get(sbc.SC_Supplier_Booking__r.SB_Opportunity__c).add(sbc);
                    }
                    
                    Map<String,Decimal> mapPayment = new Map<String,Decimal>();
                    Map<String,Decimal> mapDeposit = new Map<String,Decimal>();
                    Map<String,String> mapCurrency = new Map<String,string>();
                    Map<String,Opportunity> mapOpportunity = new Map<String,Opportunity>();
                    for(Opportunity opp : lstOpp){
                        mapCurrency.put(opp.Id,opp.currencyISOCode);
                        Map<String,Integer> mapCountOfSB = new Map<String,Integer>();
                        if(lstSupplierCost.containsKey(opp.Id)){
                            for(Supplier_Cost__c sbc : lstSupplierCost.get(opp.Id)){
                                if(!mapCountOfSB.containsKey(sbc.SC_Supplier_Booking__c)){
                                    mapCountOfSB.put(sbc.SC_Supplier_Booking__c,0);
                                } 
                                Integer count = mapCountOfSB.get(sbc.SC_Supplier_Booking__c);
                                mapCountOfSB.put(sbc.SC_Supplier_Booking__c,count+1);
                            }
                        }
                        
                        for(Client_Group__c cg : opp.Client_Groups__r){
                            decimal  totalClientPayment = 0 ;
                            decimal depositRequired = 0;
                            if(lstClientPayment.containsKey(opp.Id)){
                                for(Client_Payment__c cp : lstClientPayment.get(opp.Id)){
                                    if(cp.CP_Payee__c == cg.Id){
                                        if(!mapPayment.containsKey(cp.CP_Payee__c)){
                                            mapPayment.put(cp.CP_Payee__c,0);
                                        }
                                        Decimal totalPayment = mapPayment.get(cp.CP_Payee__c )+cp.CP_Receipt_AmountEx__c;
                                        mapPayment.put(cp.CP_Payee__c,totalPayment);
                                    }
                                }
                            }
                        if(!mapDeposit.containsKey(cg.Id)){
                            mapDeposit.put(cg.Id,0);
                        }
                        Decimal totalDeposit = mapDeposit.get(cg.Id)+depositRequired;
                        if(cg.CG_Deposit_Overwrite__c == null){
                            mapDeposit.put(cg.Id,cg.CG_Deposit_Required_I__c);
                        }
                        else{
                            mapDeposit.put(cg.Id,cg.CG_Deposit_Overwrite__c);
                        }
                    }
                    mapOpportunity.put(opp.Id,opp);
                }
                
                //Update Client Invoice fields 
                set<Opportunity> setOppToUpdate = new set<Opportunity>();
                for(Client_Invoice__c i : (List<Client_Invoice__c>)trigger.new){
                    if(mapRuleWithOpp.containsKey(i.I_Opportunity__c) && i.CI_Payment_Rule__c == null){
                        i.CI_Payment_Rule__c = mapRuleWithOpp.get(i.I_Opportunity__c).Id;
                    }
                    //Opportunity Rule field 
                    if(mapRuleWithOpp.containsKey(i.I_Opportunity__c)){
                        Opportunity opp = new Opportunity(Id = i.I_Opportunity__c);
                        opp.O_Payment_Rule__c = mapRuleWithOpp.get(i.I_Opportunity__c).Id; 
                        setOppToUpdate.add(opp);
                    }
                    if(mapCurrency.containsKey(i.I_Opportunity__c)){
                        i.currencyISOCode = mapCurrency.get(i.I_Opportunity__c);
                    }
                    if(i.CI_Client_Group__c != null && mapDeposit.containskey(i.CI_Client_Group__c)){
                        i.I_Total_Price_CG__c = mapDeposit.get(i.CI_Client_Group__c);
                    }
                    else{
                        i.I_Total_Price_CG__c = null;
                    }
                    if(i.CI_Client_Group__c != null && mapPayment.containskey(i.CI_Client_Group__c)){
                        i.I_Payment_Received_CG__c = mapPayment.get(i.CI_Client_Group__c);
                    }
                    else{
                        i.I_Payment_Received_CG__c = null;
                    }
                    
                    if(i.CI_Proforma_Type__c == null && CIRecMap.get(i.recordTypeId) == 'Proforma' && mapOpportunity.containsKey(i.I_Opportunity__c) && mapOpportunity.get(i.I_Opportunity__c).O_Days_to_Departure__c > 60){
                        i.CI_Proforma_Type__c = 'Deposit';
                    }
                    else if(i.CI_Proforma_Type__c == null &&  CIRecMap.get(i.recordTypeId) == 'Proforma'){
                        i.CI_Proforma_Type__c = 'Committed';
                    }
                }
                
                //Update Opportunity for Client Rule Field
                Utility.isCopied = true;
                List<Opportunity> lstOppToUpdate = new List<Opportunity>();
                lstOppToUpdate .addAll(setOppToUpdate);
                Update lstOppToUpdate;
            }       
        }
    }
}
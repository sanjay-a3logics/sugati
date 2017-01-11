public with sharing Class ClientPaymentTriggers{

    public ClientPaymentTriggers(){
        
    }
    
    public static void ClientPaymentTriggerBefore(){
        if(Site__c.getInstance().Run_Trigger__c){
            Savepoint sp = Database.setSavepoint();
            try{
                List<String> lstOpps = new List<String>();
                //List<String> lstCMIds = new List<String>();
                Map<String,Client_Payment__c> mapClientPayments = new Map<String,Client_Payment__c>();
                for(Client_Payment__c cp : (List<Client_Payment__c>)trigger.new){
                    if(cp.CP_Processed_On__c != null){
                        lstOpps.add(cp.CP_Opportunity__c);
                       // lstCMIds.add(cp.CP_Credit_Memo__c);
                        if(!mapClientPayments.containsKey(cp.CP_Opportunity__c)){
                            mapClientPayments.put(cp.CP_Opportunity__c, cp);
                        }
                    }    
                }
                Map<String, Map<String,Exchange_Rate__c>> mapExchangeRates = Utility.getExchangeRates(lstOpps);
                /*Map<String,Credit_Memo__c> mapPositiveCM = new Map<String,Credit_Memo__c>();
                for(Credit_Memo__c cm : [Select Id, CM_Credit_Expiry_Date__c from Credit_Memo__c where Id in :lstCMIds]){
                    mapPositiveCM.put(cm.Id,cm);
                }*/
                lstOpps = new List<String>();
                List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
               // List<Credit_Memo__c> lstCms = new List<Credit_Memo__c>();
                List<String> lstOppsForInvoice = new List<String>();
                
               
                for(Client_Payment__c cp : (List<Client_Payment__c>)trigger.new){
                    if(cp.CP_Processed_On__c != null){
                        lstOpps.add(cp.CP_Opportunity__c);
                        /*
                        if(mapExchangeRates.containsKey(cp.CP_Opportunity__c) && cp.CP_Credit_Memo__c!= null && mapPositiveCM.containsKey(cp.CP_Credit_Memo__c)){
                            if(trigger.isInsert){
                                //Credit Memo
                                if(cp.CP_Payment_Method_C__c == 'Credit Memo' && cp.CP_Credit_Memo__c != null){
                                    lstCms.add(new Credit_Memo__c(CM_Credit_Expiry_Date__c = mapPositiveCM.get(cp.CP_Credit_Memo__c).CM_Credit_Expiry_Date__c,CM_Opportunity__c = cp.CP_Opportunity__c,CM_Exchange_Rate__c = mapExchangeRates.get(cp.CP_Opportunity__c).get('GBP').Id,  CM_Amount__c = -cp.CP_Amount__c, CM_Type__c = 'Promotion'));
                                }
                            }
                            else if(trigger.isUpdate){
                                if(cp.CP_Processed_On__c != ((Client_Payment__c)Trigger.oldMap.get(cp.Id)).CP_Processed_On__c && cp.CP_Payment_Method_C__c == 'Credit Memo' && cp.CP_Credit_Memo__c != null){
                                    lstCms.add(new Credit_Memo__c(CM_Credit_Expiry_Date__c = mapPositiveCM.get(cp.CP_Credit_Memo__c).CM_Credit_Expiry_Date__c,CM_Opportunity__c = cp.CP_Opportunity__c, CM_Exchange_Rate__c = mapExchangeRates.get(cp.CP_Opportunity__c).get('GBP').Id,  CM_Amount__c = -cp.CP_Amount__c, CM_Type__c = 'Promotion'));
                                }    
                            }                        
                        }*/
                    }
                }
                
                //insert lstCms;
                Map<String,Client_Invoice__c> mapAlreadyExistedInvoices = new Map<String,Client_Invoice__c>();
                for(Client_Invoice__c cin : [Select Id,CI_Client_Group__c from Client_Invoice__c where I_Opportunity__c = :lstOpps]){
                    mapAlreadyExistedInvoices.put(cin.CI_Client_Group__c, cin);
                }
                for(Opportunity opp : [Select Id,StageName,(Select Id,CI_Client_Group__c from Client_Invoices__r),(Select Id from Client_Groups__r),O_Booking_to_Departure__c from Opportunity where 
                                        Id in :lstOpps]){
                    if(opp.StageName != 'Booked'){
                        opp.stageName = 'Booked';
                        opp.O_Booking_Date__c  = System.today();
                        lstOppsToUpdate.add(opp);
                        Boolean present = false;
                        for(Client_Invoice__c CI : opp.Client_Invoices__r){
                            if(mapClientPayments.get(opp.Id).CP_Payee__c == CI.CI_Client_Group__c){
                                present = true;
                            }
                        }
                        if(!present){
                            lstOppsForInvoice.add(opp.Id);
                        }
                    }
                    else{
                        if(opp.Client_Groups__r.size() > opp.Client_Invoices__r.Size()){
                            lstOppsForInvoice.add(opp.Id);
                        }    
                    }
                    
                }
                Update lstOppsToUpdate;
               
                if(lstOppsForInvoice.size() > 0){
                    //Map Rule with Opportunity
                    List<Rule__c> lstRules = [Select Id,R_Percentage__c,R_Days_to_Departure_From__c,R_Days_to_Departure_To__c,
                                             R_Deposit_Only__c,R_Supplier__c from Rule__c where RecordType.DeveloperName = 'Client_Payment' and Is_Active__c = true];
                    Map<String,List<Rule__c>> mapRuleWithOpp = new Map<String,List<Rule__c>>();
                    Map<String,String> mapRecordType = new Map<String,String>();
                    Map<String,Rule__c> mapRuleToSaveCP = new Map<String,Rule__c>();
                    
                    for(RecordType rt : [Select Id,DeveloperName from RecordType where SOBjectType = :Utility.getNameSpacePrefix()+'Client_Invoice__c']){
                        mapRecordType.put(rt.DeveloperName, rt.Id);
                    }
                    
                    for(Opportunity opp : [Select Id,O_Booking_to_Departure__c from Opportunity where Id in :lstOppsForInvoice]){
                        if(!mapRuleWithOpp.containsKey(opp.Id)){
                            mapRuleWithOpp.put(opp.Id, new List<Rule__c>());
                        }
                        for(Rule__c r : lstRules){
                            if(r.R_Days_to_Departure_From__c < opp.O_Booking_to_Departure__c){
                                mapRuleWithOpp.get(opp.Id).add(r);
                            }
                            if(r.R_Days_to_Departure_From__c < opp.O_Booking_to_Departure__c && r.R_Days_to_Departure_To__c > opp.O_Booking_to_Departure__c){
                                mapRuleToSaveCP.put(opp.Id,r);    
                            }
                        }
                    }
                    
                    //Create Invoice records
                    List<Client_Invoice__c> lstClientInvoice = new List<Client_Invoice__c>();
                    Map<String,String> mapClientInvoiceCP = new map<String,String>();
                    
                    for(String oppId : mapRuleWithOpp.keySet()){
                        for(Rule__c r : mapRuleWithOpp.get(oppId)){
                            
                            if(r.R_Deposit_Only__c && mapRecordType.containsKey('Deposit')){
                                Client_Invoice__c cInv = new Client_Invoice__c(I_Opportunity__c = oppId, recordTypeId = mapRecordType.get('Deposit'),
                                                     I_Invoice_Date__c = system.today(), CI_Payment_Rule__c  = r.Id);
                                if(mapClientPayments.containsKey(oppId)){
                                    cInv.CI_Client_Group__c = mapClientPayments.get(oppId).CP_Payee__c;
                                }
                                if(!mapAlreadyExistedInvoices.containsKey(cInv.CI_Client_Group__c)){                 
                                    lstClientInvoice.add(cInv);
                                }
                            }
                            if(!r.R_Deposit_Only__c && mapRecordType.containsKey('Committed')){
                                Client_Invoice__c cInv = new Client_Invoice__c(I_Opportunity__c = oppId, recordTypeId = mapRecordType.get('Committed'),
                                                     I_Invoice_Date__c = system.today(), CI_Payment_Rule__c  = r.Id);
                                if(mapClientPayments.containsKey(oppId)){
                                    cInv.CI_Client_Group__c = mapClientPayments.get(oppId).CP_Payee__c;
                                }  
                                if(!mapAlreadyExistedInvoices.containsKey(cInv.CI_Client_Group__c)){                                
                                    lstClientInvoice.add(cInv);
                                }
                            }
                            
                        }
                    }
                    
                    insert lstClientInvoice;
                    
                    List<Client_Payment__c> lstCP = new List<Client_Payment__c>();
                    for(Client_Payment__c cp : (List<Client_Payment__c>)trigger.new){
                        for(Client_Invoice__c CI : lstClientInvoice){
                            if(mapRuleToSaveCP.containsKey(CI.I_Opportunity__c) && mapRuleToSaveCP.get(CI.I_Opportunity__c).Id == CI.CI_Payment_Rule__c){
                                    cp.CP_Client_Invoice__c = CI.Id;
                                    lstCP.add(cp);
                            }   
                        }
                    }
                    //update lstCP;
                }    
            }
            Catch(Exception e){
                Database.rollback(sp);    
                System.assert(false,e.getMessage());
            }
        }
    }
    
    public static void ClientPaymentTriggerAfter(){
        if(Site__c.getInstance().Run_Trigger__c){
            
            
        }
    }
}
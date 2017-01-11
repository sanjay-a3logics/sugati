/************************************************************************************************
*        Name           : SupplierPaymentServices
*        Author         : Naval Sharma (naval.sharma@purple-vision.com)
*        Date           : 11th August 2016
*        Description    : This Service class used to automate creation of supplier payment 
*                         records when an opportunty is booked
*************************************************************************************************/

public without sharing class SupplierPaymentServices{
    
    //Set to true while updating Balance Supplier Payment records
    public static boolean isRefresh = false;
    
    /** Method to create supplier payments for provided set of opportunities ***/
    public static void createSupplierPayments(Set<Id> setBookedOppIds){
        
        try{
            //Get supplier rules for all the supplier which are part of these bookings
            Map<String, List<Supplier_Payment_Rule__c>> mapSupplierPaymentRules = new Map<String, List<Supplier_Payment_Rule__c>>();
            
            Map<String, Map<String, Map<String, Supplier_Payment__c>>> mapOppSCPToSupplierPaymentsExist = new Map<String, Map<String, Map<String, Supplier_Payment__c>>>();
            
            Map<String, Supplier_Bank_Detail__c> mapSupplierToBankDetail = new Map<String, Supplier_Bank_Detail__c>();
            
            //Get Supplier Payment Invoice Record Type so we can create the Invoice Supplier Payments 
            //RecordType supplierPaymentInvoiceRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Supplier_Payment__c' AND RecordType.Name = 'Invoice' Limit 1];
            
            //Query opportunity with related Supplier Payment Cost and Supplier Payment records 
            List<Opportunity> lstOpportunities = [SELECT Id, O_Booking_Date__c, O_Service_From_Date__c,   
                                                 (SELECT Id, SBP_Supplier_Cost_Currency_Value__c, SP_Booking__c, P_Amount__c, SP_Type__c FROM Supplier_Payments__r /*WHERE RecordTypeId = :supplierPaymentInvoiceRT.Id*/ ORDER BY SP_Order__c),
                                                 (SELECT Id, SCP_Supplier__c, SCP_Supplier__r.S_Payment_Method__c, SCP_Supplier__r.S_Payment_From_Bank_Account__c, SCP_Total_Payment__c FROM Supplier_Cost_Payments__r)  
                                                 FROM Opportunity WHERE Id in :setBookedOppIds];
            System.debug('####### List of opportunities ########## ' + lstOpportunities);
            
            //Get the suppliers which have been used in the bookings
            for(Opportunity opp : lstOpportunities){
                
                //Check for Opportunity key exist in the Map
                if(!mapOppSCPToSupplierPaymentsExist.containsKey(opp.Id))
                    mapOppSCPToSupplierPaymentsExist.put(opp.Id, new Map<String, Map<String, Supplier_Payment__c>>());
                    
                for(Supplier_Cost_Payment__c scp : opp.Supplier_Cost_Payments__r){
                    
                    //Intialize mapSupplierPaymentRules map with the supplier Ids 
                    //so we can query the supplier rules for the each supplier
                    if(!mapSupplierPaymentRules.containsKey(scp.SCP_Supplier__c))
                        mapSupplierPaymentRules.put(scp.SCP_Supplier__c, new List<Supplier_Payment_Rule__c>());        
                        
                    //Intialize mapOppToSupplierPayments map's opportunities with the supplier cost and payment ids 
                    //so we can create the supplier payment for each supplier cost and payment         
                    if(!mapOppSCPToSupplierPaymentsExist.get(opp.Id).containsKey(scp.Id))
                        mapOppSCPToSupplierPaymentsExist.get(opp.Id).put(scp.Id, new Map<String, Supplier_Payment__c>());  
                      
                }
                
                //Get all the supplier payments created for the each supplier cost and payment record
                for(Supplier_Payment__c sp : opp.Supplier_Payments__r){
                                              
                     mapOppSCPToSupplierPaymentsExist.get(sp.SP_Booking__c).get(sp.SBP_Supplier_Cost_Currency_Value__c).put(sp.SP_Type__c, sp);
                }
            }
            
            //Fetch all the found supplier's Supplier_Payment_Rule__c and associate them with the relevent supplier
            for(Supplier_Payment_Rule__c spr : [SELECT Id, SPR_Amount__c, SPR_Balance_Due_Date__c, SPR_Balance_Due_Day__c, SPR_Confirmation_From_Date__c, SPR_Confirmation_To_Date__c, 
                                                SPR_Deposit_Due__c, SPR_Deposit_Due_Date__c, SPR_Deposit_Due_Day__c, SPR_Notify_for_Balance__c, SPR_Notify__c, Percent_Value__c, 
                                                SPR_Service_From_Date__c, SPR_Service_To_Date__c, SPR_Supplier__c,SPR_Supplier_Payment_Due_Type__c, SPR_Active__c,
                                                RecordType.Name    
                                                FROM Supplier_Payment_Rule__c 
                                                WHERE SPR_Supplier__c IN : mapSupplierPaymentRules.keySet()
                                                ORDER BY SPR_Rule_Execution_Order__c]){
                
                mapSupplierPaymentRules.get(spr.SPR_Supplier__c).add(spr);
            }
            System.debug('####### Supplier Payment Rules ########## ' + mapSupplierPaymentRules);
            
            //Fetch Bank details of all the suppliers
            for(Supplier_Bank_Detail__c sbd : [SELECT Id, SBD_Supplier__c FROM Supplier_Bank_Detail__c WHERE SBD_Supplier__c IN :mapSupplierPaymentRules.keySet() AND SBD_Primary__c = TRUE]){
                
                mapSupplierToBankDetail.put(sbd.SBD_Supplier__c, sbd);
            }

            //Now create supplier payment for each supplier cost & payment record based on the supplier rule
            Map<String, Map<String, Supplier_Payment__c>> mapSCPNewSupplierPayments = new Map<String, Map<String, Supplier_Payment__c>>();
            
            for(Opportunity opp : lstOpportunities){
                
                //Iterate over Supplier Cost and Payment records for this opportunity
                for(Supplier_Cost_Payment__c scp : opp.Supplier_Cost_Payments__r){
                    
                    //Iterate over the supplier payment rules
                    for(Supplier_Payment_Rule__c rule : mapSupplierPaymentRules.get(scp.SCP_Supplier__c)){

                        //Check for supplier cost and payment's opportunity booking and service date
                        if(mapSupplierPaymentRules.containsKey(scp.SCP_Supplier__c) && 
                           opp.O_Booking_Date__c >= rule.SPR_Confirmation_From_Date__c && 
                           opp.O_Booking_Date__c <= rule.SPR_Confirmation_To_Date__c && 
                           opp.O_Service_From_Date__c >= rule.SPR_Service_From_Date__c &&
                           opp.O_Service_From_Date__c <= rule.SPR_Service_To_Date__c &&
                           rule.SPR_Active__c 
                        ){
                            //Check if supplier payment record has already been created for the opportunity, if not then create the records
                            if(mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).isEmpty()){
                                
                                if(!mapSCPNewSupplierPayments.containsKey(scp.Id)){
                                
                                    mapSCPNewSupplierPayments.put(scp.Id, new Map<String, Supplier_Payment__c>());
                                }
                                
                                //Check that there is no supplier payment is created for this supplier cost and payment record
                                if(!mapSCPNewSupplierPayments.get(scp.Id).containsKey(rule.RecordType.Name)){
                                    
                                    String bankDetailsRecordId = mapSupplierToBankDetail.containsKey(scp.SCP_Supplier__c) ? mapSupplierToBankDetail.get(scp.SCP_Supplier__c).Id : NULL;
                                    Decimal depositAmount = mapSCPNewSupplierPayments.get(scp.Id).containsKey('Deposit') ? mapSCPNewSupplierPayments.get(scp.Id).get('Deposit').P_Amount__c : 0;
                                    Supplier_Payment__c payment = SupplierPaymentServices.getSupplierPayment(opp, scp, rule,/* supplierPaymentInvoiceRT,*/ bankDetailsRecordId, depositAmount);
                                    
                                    mapSCPNewSupplierPayments.get(scp.Id).put(rule.RecordType.Name, payment);
                                }
                            }
                            else{
                                
                                if(!mapSCPNewSupplierPayments.containsKey(scp.Id)){
                                
                                    mapSCPNewSupplierPayments.put(scp.Id, new Map<String, Supplier_Payment__c>());
                                }
                                //Check there should not be existing supplier payment for this opportunity's supplier 
                                if(!mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).containsKey(rule.RecordType.Name)){
                                    
                                    if(!mapSCPNewSupplierPayments.get(scp.Id).containsKey(rule.RecordType.Name)){
                                        
                                        String bankDetailsRecordId = mapSupplierToBankDetail.containsKey(scp.SCP_Supplier__c) ? mapSupplierToBankDetail.get(scp.SCP_Supplier__c).Id : NULL;
                                        Decimal depositAmount = 0;
                                        if(mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).containsKey('Deposit'))
                                            depositAmount = mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).get('Deposit').P_Amount__c;
                                        else
                                            depositAmount = mapSCPNewSupplierPayments.get(scp.Id).containsKey('Deposit') ? mapSCPNewSupplierPayments.get(scp.Id).get('Deposit').P_Amount__c : 0;
                                        
                                        Supplier_Payment__c payment = SupplierPaymentServices.getSupplierPayment(opp, scp, rule/*, supplierPaymentInvoiceRT*/, bankDetailsRecordId, depositAmount);
                                        
                                        mapSCPNewSupplierPayments.get(scp.Id).put(rule.RecordType.Name, payment);
                                    }
                                }
                                else{
                                    //Logic to update existing balance supplier payment
                                    System.debug('####### Is Refresh ########## ' + isRefresh);
                                    if(isRefresh && rule.RecordType.Name == 'Balance'){
                                    
                                        String bankDetailsRecordId = mapSupplierToBankDetail.containsKey(scp.SCP_Supplier__c) ? mapSupplierToBankDetail.get(scp.SCP_Supplier__c).Id : NULL;
                                        Decimal depositAmount = 0;
                                        if(mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).containsKey('Deposit'))
                                            depositAmount = mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).get('Deposit').P_Amount__c;
                                        else
                                            depositAmount = mapSCPNewSupplierPayments.get(scp.Id).containsKey('Deposit') ? mapSCPNewSupplierPayments.get(scp.Id).get('Deposit').P_Amount__c : 0;
                                        
                                        Supplier_Payment__c payment = SupplierPaymentServices.getSupplierPayment(opp, scp, rule/*, supplierPaymentInvoiceRT*/, bankDetailsRecordId, depositAmount);
                                        payment.Id = mapOppSCPToSupplierPaymentsExist.get(opp.Id).get(scp.Id).get('Balance').Id;
                                        
                                        mapSCPNewSupplierPayments.get(scp.Id).put(rule.RecordType.Name, payment);        
                                    }
                                }
                            }
                        }
                    }        
                }    
            }
            System.debug('####### Created Supplier Payments ########## ' + mapSCPNewSupplierPayments);

            //Create a list of supplier payment records to insert
            List<Supplier_Payment__c> lstSupplierPayments = new List<Supplier_Payment__c>();
            for(String key : mapSCPNewSupplierPayments.keySet()){
                
                lstSupplierPayments.addAll(mapSCPNewSupplierPayments.get(key).values());        
            }
            
            if(!lstSupplierPayments.isEmpty())
                upsert lstSupplierPayments;
        }
        catch(Exception e){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage());
        } 
    }     
    
    
    /**** Method to create supplier payment based on the pre set of conditions  *****/
    public static Supplier_Payment__c getSupplierPayment(Opportunity opp, Supplier_Cost_Payment__c scp, Supplier_Payment_Rule__c rule/*, RecordType supplierPaymentInvoiceRT*/, String bankDetailsRecordId, Decimal depositAmount){
            
        Supplier_Payment__c payment = new Supplier_Payment__c(SP_Booking__c = opp.Id, /*SP_Supplier__c = scp.SCP_Supplier__c, */
                                                              SBP_Supplier_Cost_Currency_Value__c = scp.Id/*, 
                                                              RecordTypeId = supplierPaymentInvoiceRT.Id*/);
        
        //At Confirmation which means Due Date is Opportunity Booking Date
        if(rule.SPR_Supplier_Payment_Due_Type__c == 'At Confirmation')
            payment.SP_Due_Date__c = opp.O_Booking_Date__c;
        
        //End of Month after Service Date which means last day of the Month(Opportunity Service Date)
        else if(rule.SPR_Supplier_Payment_Due_Type__c == 'End of Month after Serv Date')  
            payment.SP_Due_Date__c = opp.O_Service_From_Date__c.addMonths(1).toStartofMonth().addDays(-1);  
        
        //Service Date which means Service From Date
        else if(rule.SPR_Supplier_Payment_Due_Type__c == 'Service Date') 
            payment.SP_Due_Date__c = opp.O_Service_From_Date__c;
        
        //Specific Date which is based on Due Date (date field) or Due Day which is + or - x number of days based on the Service Date  
        else if(rule.SPR_Supplier_Payment_Due_Type__c == 'Specific Date'){ 
            
            if(rule.SPR_Deposit_Due_Date__c != NULL)
                payment.SP_Due_Date__c = rule.SPR_Deposit_Due_Date__c;
            else
                payment.SP_Due_Date__c = opp.O_Service_From_Date__c.addDays(rule.SPR_Deposit_Due_Day__c!= NULL ? Integer.valueOf(rule.SPR_Deposit_Due_Day__c) : 0);
        }
        
        //Set all other essential field values
        //payment.SP_Supplier_Bank_Details__c = bankDetailsRecordId;
        payment.SP_Payment_Method__c = scp.SCP_Supplier__r.S_Payment_Method__c;
        payment.SP_Payment_From_Bank_Account__c = scp.SCP_Supplier__r.S_Payment_From_Bank_Account__c;
        payment.SP_Supplier_Payment_Rule__c = rule.Id;
        payment.SP_Booking__c = opp.Id;
        payment.SBP_Supplier_Cost_Currency_Value__c= scp.Id;
        //payment.SP_Serv_Date__c = opp.O_Service_From_Date__c;
        payment.SP_Type__c = rule.RecordType.Name;
        
        //Set the amount value based on the rule record type
        if(rule.RecordType.Name == 'Deposit')
            payment.P_Amount__c = rule.Percent_Value__c == 'Value' ? rule.SPR_Amount__c : scp.SCP_Total_Payment__c * rule.SPR_Amount__c / 100;
        else
            payment.P_Amount__c = scp.SCP_Total_Payment__c - depositAmount;
            
        return payment;
    }  
    
    
    public static boolean isBookedRecently(Opportunity newOpp, Opportunity oldOpp){
        if(oldOpp.StageName != 'Confirmed Booking' && oldOpp.StageName != 'Confirmed Web Booking' && oldOpp.StageName != 'Booked' && oldOpp.StageName != 'Web Booking')
            return (newOpp.StageName == 'Confirmed Booking' || newOpp.StageName == 'Confirmed Web Booking' || newOpp.StageName == 'Booked' || newOpp.StageName == 'Web Booking');
        return false;    
        
    }
    
    public static boolean isBooked(Opportunity newOpp){
        return (newOpp.StageName == 'Confirmed Booking' || newOpp.StageName == 'Confirmed Web Booking' || newOpp.StageName == 'Booked' || newOpp.StageName == 'Web Booking');
        
    }
}
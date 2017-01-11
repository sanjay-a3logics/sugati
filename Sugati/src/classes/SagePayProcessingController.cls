public without sharing class SagePayProcessingController {
    public final string direct3dcallback = 'https://live.sagepay.com/gateway/service/direct3dcallback.vsp';
    string oppId;
    String groupMemberId = '';
    public SagePayProcessingController(Apexpages.standardController controller ) {
        oppId = controller.getId();
        if(oppId != null){
            Opportunity opp = [Select Id,accountId from Opportunity where Id = : oppId ];
            LIst<group_member__c> gms = [Select id from group_member__c where GM_Opportunity__c=: opp.Id  
            and GM_Lead_Passenger__c  = true];
        
            if (gms.size() > 0) {
                groupMemberId = gms[0].id;
            }
        }
        
    }
    
    public Pagereference processing() {
        string pageName = Page.thankyou.geturl();
        String logIds = '';
        try {
            
            string s_3dStatus = Apexpages.currentpage().getParameters().get('3dStatus') ;
            
            if (s_3dStatus == 'NOTCHECKED') {
                // in case of non 3d secure card.
                createPayment();
                createLogs('card 3d status is not checked:::'+s_3dStatus );
            }
            else if (s_3dStatus == 'OK') {
                string pares = Apexpages.currentPage().getParameters().get('PaRes');
                string md = Apexpages.currentPage().getParameters().get('MD');
            
                if (pares != null && md  != null) {
                
                    HttpRequest req = new HttpRequest();        
                    req.setEndpoint(direct3dcallback);
                    string request = 'MD='+md+'&PARes='+pares ;
                    req.setBody(request);
                    req.setMethod('POST'); 
                    
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    createLogs('pares & md response:::'+res.getstatusCode() +'###'+res.getBody() );
                    if (res.getstatusCode() == 200) {
                        //VPSProtocol=3.00 Status=REJECTED StatusDetail=4026 : 3D-Authentication failed. This vendor's rules require a successful 3D-Authentication. VPSTxId={7D5EE647-0A01-7B7A-2D41-670E40E62E36} SecurityKey=N8YL1GG51C
                        string response = res.getBody();
                        if (response != null) {
                            String StatusResponse = response.subString(response.indexOf('Status')).trim();
                            String StatusValues = StatusResponse.subString(StatusResponse.indexOf('=')+1,StatusResponse.indexOf('StatusDetail')).trim();
                            createLogs('pares & md StatusResponse and StatusValues  :::'+StatusResponse  +'###'+StatusValues  );
                            if (StatusValues == 'OK') {
                                createPayment();
                            }
                            else if(StatusValues == 'REJECTED') {
                                logIds = createLogs('Transaction has been rejected by user.:::'+ response );
                                //pageName = Page.PaymentDetails.geturl();
                            }
                            else {
                                logIds = createLogs('StatusValues ::'+ StatusValues + response );
                                //pageName = Page.PaymentDetails.geturl();
                            }
                            //system.assert(false,StatusValues );
                        }
                    }
                }
                else {
                    logIds = createLogs('pares and md values are null :::'+pares +'---'+ md);
                }
            }
            else {
                logIds = createLogs('3d status value:::::'+ s_3dStatus+'Opp Id ='+oppId );
            }
            
        }
        catch(Exception e) {
            //Apexpages.addMessages(e);
            logIds = createLogs(e.getMessage() + '------' + e.getstacktracestring());
        }
        system.debug('pageName*******'+pageName+'oppid*******'+oppId);
        if(logIds != '')
            return new Pagereference(pageName +'?id='+oppId+'&logId='+logIds);
        else
            return new Pagereference(pageName +'?id='+oppId);
    }
    
    String createLogs(string msg) {
       /* if (!Utilitycontroller.isInternalUser()) {
            Utilitycontroller.saveSteps(oppId, 7);
        }*/
        Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = oppId,PL_Description__c =msg);
        insert pl;
        return pl.Id;
    }
    
    void createPayment() {
        try {
            if (Apexpages.currentpage().getParameters().get('amount') != null && 
               Apexpages.currentpage().getParameters().get('cardtype') != null &&
               Apexpages.currentpage().getParameters().get('id') != null ) {
            
                string amountPaid = Apexpages.currentpage().getParameters().get('amount');
                string paymentMethod = Apexpages.currentpage().getParameters().get('cardtype');
                string tempCCcharges = Apexpages.currentpage().getParameters().get('ccCharges');
                string paymentType = Apexpages.currentpage().getParameters().get('paymentType');
                
                decimal ccCharges = 0;
                if (tempCCcharges != null && tempCCcharges != '') {
                    ccCharges = decimal.valueOf(tempCCcharges) ;
                }
                Decimal amountWithoutCC = decimal.valueOf(amountPaid)-ccCharges;
                Decimal cc = (ccCharges/decimal.valueOf(amountPaid))*100;
                if(ccCharges>0){
                    cc = 3;
                }
                
                Client_Payment__c cp = new Client_Payment__c(CP_Card_Type__c = paymentMethod, CP_Receipt_AmountEx__c = amountWithoutCC, CP_Amount__c = decimal.valueOf(amountPaid),CP_Client_Invoice__c = null,
                CP_Contact__c = null,CP_Date__c = date.today(), CP_Opportunity__c =oppId, CP_Payment_Method_C__c = 'Credit/Debit',
                CP_Credit_Card_Charge__c = cc , CP_Processed_On__c = date.today(),
                CP_Transaction_Status__c = '', CP_Type__c ='SagePay', CP_Payment_Type__c=paymentType);
                
                Set<String> selectedGMIds = new Set<String>();
                selectedGMIds.add(groupMemberId);
                
                List<Client_Payment__c> lstCP = new List<Client_Payment__c>(); 
                lstCP.add(cp);
                //lstCP = UtilityController.updatePayeeFieldOfClientPayment(selectedGMIds,lstCP);
                insert lstCP;
                
                Opportunity opp = [select id , stagename, O_last_Payment__c from Opportunity where id =:oppId];
                opp.O_last_Payment__c  = decimal.valueOf(amountPaid);
                opp.Pipeline__c = true;
                opp.stagename = 'Booked';
                //UtilityController.isCopied = true;
                update opp;
                
                if(groupMemberId != ''){
                    Client_Payment_Detail__c cpd = new Client_Payment_Detail__c(CPD_Client_Payment__c =cp.id,  CPD_Group_Member__c =groupMemberId );
                    insert cpd ;
                }
                
            }
        }
        catch(Exception e) {
            createLogs('Exception::' + e.getMessage() +'-' + e.getstacktraceString());
            throw e;
        }
    }
}
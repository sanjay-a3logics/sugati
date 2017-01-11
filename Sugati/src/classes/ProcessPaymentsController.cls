public without sharing class ProcessPaymentsController{
    public string oppId {get;set;}
    public String customerEmail;
    public boolean isPaymentSuccess;
    public boolean paymentProccessed {get;set;}
    public String responseMsg {get;set;}
    public String status {get;set;}
    String groupMemberId = '';
    String selectedClientGroup = null;
    String chargeId;
    public String cardToken {get;set;}
    Opportunity opp;
    Decimal creditCharge;
    String decodedName;
    Payment_log__c paymentLog;
    boolean isClientGroupPayment = false;
    public static final String CHECKOUT_SECRET_KEY = 'sk_67252c87-f0dd-4b6f-a020-84f882e7d02d';
    public final string CHECKOUT_CHARGE_END_POINT = 'https://api2.checkout.com/v2/charges/token';
    
    public ProcessPaymentsController() {
        try{
            paymentProccessed = false;
            String logId = ApexPages.currentPage().getParameters().get('id'); 
            decodedName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');
            paymentLog = [Select id, PL_Card_Token__c, PL_Currency_Code__c, PL_Card_Type__c, PL_Opportunity__c, PL_payment_type__c, PL_Payment_Amount__c from Payment_Log__c where id=:logid];
            oppId = paymentLog.PL_Opportunity__c;
            List<Opportunity> OPPlst = [Select Id, O_RecordType__r.Id, O_Reference_Number__c, O_Credit_Card_Charges_P__c,O_Ts_Cs__c,O_Total_Payment__c,O_Days_to_Departure__c,O_last_Payment__c, O_Outstanding__c, amount, stageName, accountId, (select id from Client_Payments__r) from Opportunity where id=:oppId];
            system.debug('Opportunity List **** ' + Opplst);
            System.debug('Opportunity ID **** '+ oppId);
            if(OPPlst.size()>0)
                opp = opplst[0];
            if(opp.O_Credit_Card_Charges_P__c  != null){    
                creditCharge = opp.O_Credit_Card_Charges_P__c; 
            }
            else{
                creditCharge = 3;
            }
            if(opp.Id != null){
                String groupMemberIdParam = ApexPages.currentPage().getParameters().get('p'); 
                LIst<group_member__c> gms;
                isClientGroupPayment = false;       
                if(groupMemberIdParam != null && groupMemberIdParam != ''){
                    selectedClientGroup = groupMemberIdParam;
                    gms = [Select id, GM_Contact__r.email from group_member__c where GM_Client_Group__c =: groupMemberIdParam  and GM_Lead_Passenger__c  = true];
                    isClientGroupPayment = true;  
                }
                else{
                    Map<Id, Client_Group__c> clientGroups = new Map<Id, Client_Group__c>([SELECT Id, Name, CG_Selling_Price__c, CG_Deposit_Required_I__c FROM Client_Group__c where CG_Opportunity__c = :Opp.Id]); 
                    selectedClientGroup = clientGroups.values()[0].Id;
                    gms = [Select id, GM_Contact__r.email from group_member__c where GM_Client_Group__c =: selectedClientGroup and GM_Lead_Passenger__c  = true];
                }
                if (gms.size() > 0) {
                    groupMemberId = gms[0].Id;
                    if(gms[0].GM_Contact__c != null)
                        customerEmail = gms[0].GM_Contact__r.email;
                }
            }
        }catch(Exception e){
            //System.assert(false, e.getMessage() + '*****' + e.getLineNumber());
            createPaymentLog('Error \r\n Before processing payment \r\n '+ e.getMessage(), null,  null, '###ERROR###');
            responseMsg = e.getMessage();
            status = 'Failed'; 
            paymentProccessed = false;
        }
    }


    public Pagereference processing() {
         isPaymentSuccess = false;
         paymentProccessed = false;
        
         try{
             if (paymentLog.PL_Card_Token__c != null) {  
                HttpRequest req = new HttpRequest();   
                req.setHeader('Authorization',CHECKOUT_SECRET_KEY);
                req.setHeader('Content-Type','application/json;charset=UTF-8');     
                req.setEndpoint(CHECKOUT_CHARGE_END_POINT);
                String payLoad = '';
                Decimal duePaymentInCents = paymentLog.PL_Payment_Amount__c*100;
                payLoad += '{';
                payLoad += '"email": "'+customerEmail+'",';
                payLoad += '"trackId": "'+paymentLog.id+'",';
                payLoad += '"description": "  Reference Number    '+opp.O_Reference_Number__c+'  ****  Customer Name   '+decodedName+'",';
                payLoad += '"value": "'+ duePaymentInCents.intValue() +'",';
                payLoad += '"currency": "'+ paymentLog.PL_Currency_Code__c +'",';
                payLoad += '"cardToken": "'+ paymentLog.PL_Card_Token__c +'",';
                payLoad += '"metadata":{"oppId": "'+oppId+'"}';
                payLoad += '}';
                req.setBody(payLoad);
                req.setMethod('POST'); 
                System.debug('********* Card Charge Request********'+ payLoad);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('********* Card Charge Response ********'+ res.getBody());
                if (res.getstatusCode() == 400) {
                    ErrorWrapper error = (ErrorWrapper) JSON.deserialize(res.getBody(), ErrorWrapper.class); 
                    responseMsg = error.message;
                    responseMsg += '  ';
                    if(error.errors != null)
                        responseMsg += String.join(error.errors, ', ');    
                    status = 'Failed';
                    createPaymentLog('Error \r\n'+ responseMsg +' \r\n ' + res.getBody() , paymentLog.PL_Payment_Amount__c, 
                                          paymentLog.PL_Currency_Code__c, 'Card Charge Failed');
                    System.debug('############  Card Charge due to bad request############  '+ 'Error \r\n'+ res.getBody());
                }
                else if(res.getstatusCode() == 200){
                    
                    ResponseWrapper response = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class); 
                    if(response.responseCode == '10000' || response.responseCode =='10100'){
                        isPaymentSuccess = true;
                        createPaymentLog(response.status+ '  \r\n '+ res.getBody(), paymentLog.PL_Payment_Amount__c, 
                                         paymentLog.PL_Currency_Code__c, 'Card Charge Success');
                        System.debug('############ Card Charge Success ############   '+response.responseMessage);
                        chargeId = response.id;
                        System.debug('############ Card Charge Success ############   '+response);
                        createClientPayment((ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class));
                        PageReference pg = new PageReference('/apex/ThankYouConfirmation?id='+oppId+'&statusCode='+response.responseCode+'&msg='+response.responseMessage+'&cp='+paymentLog.PL_Card_Type__c);
                        pg.setRedirect(true);
                        return pg;
                    }
                    else{
                        createPaymentLog(response.status+ '  \r\n '+ response.responseMessage + '  \r\n '+ response.responseAdvancedInfo + '  \r\n '+ res.getBody(), paymentLog.PL_Payment_Amount__c, 
                                          '', '');
                        System.debug('############ Card Charge Failed ############ ' + response.responseMessage+'################'+response.responseAdvancedInfo);
                        status = response.status;
                        responseMsg = response.responseMessage;
                    }
                    
                }
                else{
                    createPaymentLog('Failed \r\n '+ res.getBody(), paymentLog.PL_Payment_Amount__c, 
                                         '', '');
                    responseMsg = res.getStatus();
                    status = 'Failed';
                    System.debug('############ Card Charge Failed ############'+ 'Error \r\n'+ res.getBody());
                }
            }
            else{
                status = 'Failed';
                createPaymentLog('Failure \r\n'+ 'Card Token not found', 0, '', '');
                responseMsg = 'Unable to process payment. Please try again later.';
                System.debug('************* Card Token not Found ***********');
            }
        }catch(Exception e){
            createPaymentLog('Error \r\n'+ e.getMessage(), null,  null, '###ERROR###');
            responseMsg = e.getMessage();
            status = 'Failed'; 
            paymentProccessed = false;
            System.debug('##########Exception Occureed ########'+ e);
        }
        paymentProccessed = true;
        return null;    
    }
    
    public void createPaymentLog(String descrptn, Decimal amt, String currencyCode, String cardToken){
        try{
            Payment_Log__c log = new Payment_Log__c();
            log.PL_Opportunity__c = oppId;
            log.PL_Description__c = descrptn;
            log.PL_Payment_Amount__c = amt;
            log.PL_Currency_Code__c = currencyCode; 
            log.PL_Card_Token__c = cardToken;  
            log.PL_Card_Type__c = paymentLog.PL_Card_Type__c;
            Database.insert(log, true);  
        }catch(Exception e){
            System.debug('****** Error****' + e.getStackTraceString());
        }
    }
    void createClientPayment(ResponseWrapper response) {
        try{
            System.debug('****Creating Client Payment for the paid amount *******');
            List<Client_Payment__c> lstClientPayments = new List<Client_Payment__c>();
            decimal amountPaid = 0;
            Double paymentDue = paymentLog.PL_Payment_Amount__c;
            if (paymentDue != 0){
                amountPaid = paymentDue;
                decimal receiptAmt = (100 / (100 + creditCharge))*amountPaid;
                receiptAmt  = receiptAmt.setScale(2);
                String paymentType = getDepositType(receiptAmt);
                //Check if it's first payment from OBF
                boolean isFirstPayment = false;
                if(opp.O_Ts_Cs__c && opp.Client_Payments__r.size() == 0){
                    isFirstPayment = true;
                }
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = receiptAmt, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null, CP_Credit_Card_Charge__c = creditCharge,CP_Client_Group_Payment__c= isClientGroupPayment,
                CP_Date__c = date.today(), CP_Opportunity__c =oppId, CP_Payment_Method_C__c = 'Credit Card', CP_Processed_On__c = date.today(), CP_First_Payment__c = isFirstPayment, CP_Payee__c = selectedClientGroup,
                CP_Transaction_Status__c = 'Completed : '+chargeId, CP_Card_Type__c = paymentLog.PL_Card_Type__c, CP_Type__c ='Checkout',CP_Payment_Type__c= paymentType, CP_Transaction_Notes__c = response.responseCode +' : '+ response.responseMessage));
                opp.O_last_Payment__c = paymentDue;
                
                
            }
            /*            
            if(opp.O_Days_to_Departure__c != null && opp.O_Days_to_Departure__c <= 60){
                paymentType = 'Full';
            }
            */
            lstClientPayments = Utility.updatePayeeFieldOfClientPayment(new Set<String>{groupMemberId},lstClientPayments);
            insert lstClientPayments;
            
            List<Client_Payment_Detail__c> paymentdetails = new List<Client_Payment_Detail__c>();
            for (Client_Payment__c cp: lstClientPayments) {
                paymentdetails.add(new Client_Payment_Detail__c(CPD_Client_Payment__c =cp.id,  CPD_Group_Member__c =groupMemberId ));
            }
            
            insert paymentdetails;
            
            if (paymentDue != null  ) {
                 opp.O_last_Payment__c = paymentDue;
            }
            opp.stagename = 'Booked';
            Utility.isCopied = true;
            update opp;
            
            if (!Utility.isInternalUser()) {
                Utility.saveSteps(opp.Id, 6);
            }
        }
        catch(exception e){
            //System.assert(false,e.getStackTraceString()+'*********'+e.getMessage());
            createPaymentLog('Error \r\n While creating client payment \r\n '+ e.getMessage(), null,  null, '###ERROR###');
            ApexPages.addMessages(e);
            responseMsg = e.getMessage()+e.getStackTraceString();
        }
    }
    
    public String getDepositType(decimal paidAmountWithoutCCCharges){         
        String paymentTypeString = '';
        if(opp.O_Total_Payment__c == 0 && paidAmountWithoutCCCharges < opp.amount)
            paymentTypeString = 'Deposit';
        else if(paidAmountWithoutCCCharges < opp.O_Outstanding__c)
            paymentTypeString = 'Interim';
        else if(paidAmountWithoutCCCharges >= opp.O_Outstanding__c)
            paymentTypeString = 'Full';
        return paymentTypeString;
    }
    
    
    public class ErrorWrapper {
        String errorCode;
        String message;
        List<String> errors;
    }
    
    public class ResponseWrapper {
        public  String id;
        public  String created;
        public  String value;
        public  String currencyCode;
        public  String trackId;
        public  String email;
        public  String chargeMode;
        public  String responseMessage;
        public  String responseAdvancedInfo;
        public  String responseCode;
        public  String status;
        public  String authCode;
        public  CardInfo card;
        public MetaDataInfo metadata;
        public void setCurrency(String currencyCode){
            this.currencyCode = currencyCode;
        }
        public String setCurrency(){
            return this.currencyCode;
        }
    }
    public class CardInfo{
        public String customerId;
        public String expiryMonth; 
        public String expiryYear; 
        public String id; 
        public String last4 ; 
        public String  paymentMethod; 
        public String name; 
        public String fingerprint;
    } 
    public class MetaDataInfo {
        public String oppId;    
    }

}
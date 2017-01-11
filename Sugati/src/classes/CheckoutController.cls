public without sharing Class CheckoutController{

    public String oppID{get; set;}
    public Boolean isSiteUser{get; set;}
   
    public String selectedCurrency{get; set;}
    public String selectedCurrency1{get; set;}
    public Decimal paymentDue{get; set;}
    public Decimal AmountDue;
    public String nameOnCard{get; set;}
    public Boolean sameAsLead{get; set;}
    public String emergencyFirstName{get;set;}
    public String cardType{get;set;}
    public String cardNumber{get;set;}
    public String expiryMonth{get;set;}
    public String expiryYear{get;set;}
    public String securityCode{get;set;}
    public String addressLine1{get; set;}
    public String addressLine2{get; set;}
    public String addressLine3{get; set;}
    public String town{get; set;}
    public String zipCode{get; set;}
    public String country{get; set;}
    public String displayMessage{get; set;}
    public Boolean byTransfer{get; set;}
    public Boolean byCash{get; set;}
    public Boolean byCheque{get; set;}
    public Boolean byCardA{get; set;}
    public Boolean byCard{get; set;}
    public String card_token {get;set;}
    public String customerEmail {get;set;}
    public List<SelectOption> countryOptions{get; set;}
    public List<SelectOption> expiryYearOptions{get; set;}
    public String paymentTypeStr{get;set;}
    public Decimal creditCardCharges{get;set;}
    public Decimal totalPayment{get;set;}
    public Boolean showCashCheque{get; set;}
    public String leadPessanger;
    public Opportunity opp{get; set;}    
    
    Contact FoundContact;
    string groupMemberId = '';
    string paymentType ='Deposit';
    List<String> conIds = new List<String>();
    
    public static final String CHECKOUT_PUBLIC_KEY = 'pk_260e4aae-7b7b-4e0f-82be-139b2448bc80';
    public final string CHECKOUT_CARD_TOKEN_END_POINT = 'https://api2.checkout.com/v2/tokens/card';
    
    public CheckoutController(ApexPages.StandardController controller) {
        try{
            //System.assert(false, 'aaaaa');
            oppID = controller.getId();
            expiryYearOptions = new List<SelectOption>();
            showCashCheque = false;
            byCard = false;
            byTransfer  = false; 
            byCheque = false;
            byCash = false;
            byCardA = false;
            if(oppID != null){
                List<Profile> PROFILE = [SELECT Id, Name,UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                if(PROFILE[0].UserLicense.Name == 'Guest User License'){
                    isSiteUser =true;    
                }
                else{
                    isSiteUser =false;
                }
                opp = [Select ID,Amount,Name,CurrencyISOCode,O_Total_Payment_Without_CC__c ,pipeline__c,AccountID,O_Policy_No__c,O_Days_to_Departure__c,O_Insurance_Company__c,O_Credit_Card_Charges_P__c,O_RecordType__r.Name,O_Booking_Currency__c ,
                        O_Booking_Date__c,O_Departure_Date__c,O_Deposit_Required1__c,O_Total_Payment1__c,O_Total_Payment__c,
                        O_Outstanding__c,(Select ID, GM_Contact__c,GM_Lead_Passenger__c from Group_Members__r), 
                            O_Ts_Cs__c
                             from Opportunity where Id = :oppId];
                
                
                if(opp.O_Credit_Card_Charges_P__c != null){
                    creditCardCharges = opp.O_Credit_Card_Charges_P__c;
                }
                else{
                    creditCardCharges = 3;
                }
                List<group_member__c> gms = [Select id,GM_Contact__c,GM_Contact__r.email from group_member__c where GM_Opportunity__c=: opp.Id  and GM_Lead_Passenger__c  = true and GM_Contact__c != null];
                
                if (gms.size() > 0) {
                    groupMemberId = gms[0].id;
                    for(group_member__c gm : gms){
                        if(gm.GM_Contact__c != null && gm.GM_Contact__r.email != null){
                            leadPessanger = gms[0].GM_Contact__c;
                            customerEmail = gms[0].GM_Contact__r.email;
                            break;
                        }
                    }
                        
                }  
                 
                If( Opp.O_Total_Payment_Without_CC__c == 0){
                    paymentDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    AmountDue = (opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c).setScale(2);
                }
                else{
                    paymentDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                    AmountDue = (opp.Amount-opp.O_Total_Payment_Without_CC__c).setScale(2);
                }
                if(paymentDue < 0){
                    paymentDue = 0;    
                }
                
                selectedCurrency = opp.CurrencyISOCode;
                selectedCurrency1 = opp.CurrencyISOCode;
                for(Group_Member__c gm : opp.Group_Members__r){
                    conIds.add(gm.GM_Contact__c);
                }
                
            }
            loadCountries();
            sameAsLead = true;
            changeAddress();
            
            
            for(Integer i = system.today().year();i<=system.today().year()+10;i++){
                expiryYearOptions.add(new SelectOption(''+i,''+i));
            }
            cardNumber = '';
            nameOnCard = '';
             changeAddress();
        }
        catch(Exception e){
            System.assert(false,e.getStackTraceString()+'     '+ e.getMessage());
            ApexPages.addMessages(e);
        }
    }
    
    public void changeAddress(){
        Contact FoundContact = new Contact();
        For(Account acc : [Select Id,Name,Phone,BillingStreet, 
                            BillingState, BillingCountry , BillingCity ,BillingPostalCode, ShippingStreet ,ShippingState, 
                            ShippingCountry,ShippingPostalCode ,ShippingCity,(Select Id,birthDate,salutation,FirstName,lastname,Phone,C_Lead_Passenger__c,Email,MailingStreet,MailingState,
                                    MailingPostalCode,MailingCountry,MailingCity,OtherStreet,OtherState,OtherCountry,OtherPostalCode  
                           from Contacts where Id in :conIds order by createdDate) from Account where Id = :opp.AccountID]){
            if(acc.Contacts.size() == 1){
            ///    acc.A_Lead_Email__c = acc.Contacts[0].Email;
                FoundContact = acc.Contacts[0];
                acc.phone = acc.Contacts[0].phone;
            }
            else{
                Boolean isFilled = false;
                for(Contact c : acc.Contacts){
                    string cname = c.firstname + ' ' + c.lastname;
                    if (acc.name.contains(cname)) {
                    //    acc.A_Lead_Email__c = c.Email;
                        acc.phone = c.phone;
                        FoundContact = c;
                        isFilled = true;
                    }
                } 
                if(!isFilled){
                    for(Contact c : acc.Contacts){
                        if (FoundContact .Id == null && c.C_Lead_Passenger__c) {
                            acc.phone = c.phone;
                            //acc.A_Lead_Email__c = c.Email;
                            FoundContact = c;
                        }
                        
                    }        
                }   
            }     
        }
        if(Foundcontact != null && ((opp.O_RecordType__r.name == 'SG' && (Foundcontact.mailingCountry == 'SG' || Foundcontact.mailingCountry == 'Singapore')) || (opp.O_RecordType__r.name == 'HK' && (Foundcontact.mailingCountry == 'HK' || Foundcontact.mailingCountry == 'Hong Kong')) || (opp.O_RecordType__r.name == 'DXB' && (Foundcontact.mailingCountry == 'AE' || Foundcontact.mailingCountry == 'Dubai')))){
            showCashCheque = true;
        }
        if(FoundContact.Id != null && sameAsLead){
            nameOncard = FoundContact.FirstName+' '+FoundContact.LastName;
            if(FoundContact.MailingStreet != null){
                addressLine1 = FoundContact.MailingStreet;
            }
            if(FoundContact.MailingState != null){
                addressLine2  = FoundContact.MailingState;
            }
            if(FoundContact.MailingCountry != null){
                country = FoundContact.MailingCountry;
            }
            if(FoundContact.MailingCity != null){
                town = FoundContact.MailingCity;
            }
            if(FoundContact.MailingPostalCode != null){
                zipCode = FoundContact.MailingPostalCode;
            }
        }
        if(!sameAsLead){
            nameOncard = ''; 
            addressLine1 = '';  
            addressLine2  = ''; 
            country = '';
            town = '';
            zipCode = '';
        }
        changeType();
    }
    
     void loadCountries() {
        countryOptions= new List<Selectoption>();
        countryOptions = Countries.loadCountries();

    }
    
    public void changeType(){
        if(byCard){
            if(creditCardCharges != 0){
                totalPayment = paymentDue+(paymentDue*creditCardCharges/100).setScale(2);  
            }
            else{
                totalPayment = paymentDue.setScale(2);      
            }
        }
          
    }
    
    Boolean isRedirect = false;
    public PageReference Confirm(){
        try{
            
            Boolean isValidatedSuccessfully = true;
            if (opp.id != null) {
                //opp.O_Reminder__c = isReminder;
                
                if (!(byTransfer || byCheque || byCash || byCard || byCardA)) {
                    displayMessage = 'Please select at least one payment type';
                    isValidatedSuccessfully = false;
                }
                else {
                     
                    if ((byTransfer || byCheque || byCash || byCard || byCardA) && paymentDue != null) {
                        if ( paymentDue < 0) {
                            displayMessage = 'Amount must be a positive number';
                            isValidatedSuccessfully = false;
                        }
                    }
                    
                    if (isValidatedSuccessfully) {
                        
                        if (AmountDue < paymentDue && isSiteUser == true ) {
                            displayMessage = 'Required amount is only ' + opp.O_Booking_Currency__c + ' ' + opp.O_Outstanding__c + ' and you are attemting to pay ' + opp.O_Booking_Currency__c + ' ' + paymentDue;
                            isValidatedSuccessfully = false;
                        }
                        else {
                            
                            paymentType = 'Deposit';
                            if (AmountDue == paymentDue) {
                                paymentType = 'Full';
                            }
                            if(byTransfer || byCheque || byCash || byCardA){
                                String cp = createClientPayment();
                                if(isRedirect){
                                    PageReference pg = new PageReference('/apex/ThankYouConfirmation?id='+oppId+'&cp='+paymentTypeStr);
                                    pg.setRedirect(true);
                                    return pg;
                                }
                                
                            }
                            //***Updated by Naval 14-OCT-15
                            else{
                                if(customerEmail == null){
                                    displayMessage = 'Please makes sure that lead guest is having email id.';
                                    return null;
                                }
                                  
                                //System.assert(false, paymentDue+'***'+cardNumber+'*****'+addressLine1);
                                paymentTypeStr = 'credit card';
                                displayMessage = '';
                                Http h = new Http();
                                HttpRequest req = new HttpRequest();
                                req.setEndpoint(CHECKOUT_CARD_TOKEN_END_POINT);
                                req.setHeader('Authorization',CHECKOUT_PUBLIC_KEY);
                                req.setHeader('Content-Type','application/json;charset=UTF-8');
                                req.setMethod('POST');
                                // Send the request, and return a response
                                String payLoad = '';
                                  
                                Decimal duePaymentInCents = totalPayment*100;
                                payLoad += '{';
                                payLoad += '"customerEmail": "'+customerEmail+'",';
                                payLoad += '"number": "'+ cardNumber.trim() +'",';
                                payLoad += '"name": "'+ nameOncard +'",';
                                payLoad += '"customerName": "'+ nameOncard +'",';
                                payLoad += '"expiryMonth": "'+ expiryMonth +'",';
                                payLoad += '"expiryYear": "'+ expiryYear +'",';
                                payLoad += '"cvv": "'+ securityCode +'",';
                                payLoad += '"requestSource": "JS",';
                                payLoad += '"billingDetails": {';
                                payLoad += '"addressLine1": "'+ addressLine1 +'",';
                                payLoad += '"addressLine2": "'+ addressLine2 +'",';
                                payLoad += '"postcode": "'+ zipCode +'",';
                                payLoad += '"country": "'+ country +'",';
                                payLoad += '"city": "'+ town +'"';
                                payLoad += '}';
                                payLoad += '}';
                                //system.debug('*****Request Payload ******' +payLoad);
                                req.setBody(payLoad);
                                //system.assert(false, payLoad); 
                                HttpResponse res = h.send(req);
                                res.getBody();
                                system.debug('*****Response ******'+res.getBody());
                                if(res.getStatusCode() != 200){
                                    ErrorResponse error = (ErrorResponse) JSON.deserialize(res.getBody(), ErrorResponse.class);
                                    System.debug('******Card Token Error In Response*****'+ error.errors);
                                    if(error.errors != null){
                                        for(String err : error.errors)
                                            displayMessage += '<br/>'+err;   
                                        String lodId = createPaymentLog('Error \r\n'+displayMessage, paymentDue, selectedCurrency1, '', cardType);
                                    }
                                    createPaymentLog('Error \r\n'+res.getBody(), paymentDue, selectedCurrency1, '', cardType);
                                    //system.assert(false,  log);
                                }
                                else{
                                    CardTokenResponse cardToken  = (CardTokenResponse) JSON.deserialize(res.getBody(), CardTokenResponse.class);
                                    
                                    String lodId = createPaymentLog('Success \r\n Card Token \r\n'+res.getBody(), totalPayment, selectedCurrency1, cardToken.id, cardToken.card.paymentMethod);
                                    card_token = cardToken.id;
                                    system.debug('******Card Token Error In Response*****'+  res.getBody());
                                    PageReference pg = Page.ProcessPayments;
                                    pg.getParameters().put('id',lodId);
                                    pg.getParameters().put('cc',String.valueOf(creditCardCharges));
                                    String encodedName = EncodingUtil.urlEncode(nameOncard, 'UTF-8');
                                    pg.getParameters().put('name', encodedName);
                                    //pg.getParameters().put('card_token',card_token);
                                    pg.setRedirect(true);
                                    return pg;
                                    
                                }
                            }
                                       
                        }
                    }
                }
            }
        }
        Catch(Exception e){
            displayMessage = e.getMessage()+e.getStackTraceString();
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference back(){
        return new PageReference('/apex/BookingForm?id='+oppId);    
    }
    
    public String createPaymentLog(String descrptn, Decimal amt, String currencyCode, String cardToken, String cardType){
        try{
            Payment_Log__c log = new Payment_Log__c();
            log.PL_Opportunity__c =  opp.id;
            log.PL_Description__c = descrptn;
            log.PL_Payment_Amount__c = amt;
            log.PL_Currency_Code__c = currencyCode; 
            log.PL_Card_Token__c = cardToken;  
            log.PL_Card_Type__c = cardType;
            insert log;  
            return log.id;
        }catch(Exception e){
            System.debug('****** Error****' + e.getStackTraceString());
            return null;
        }
    }
    
    String createClientPayment() {
        try{
            List<Client_Payment__c> lstClientPayments = new List<Client_Payment__c>();
            decimal amountPaid = 0;
            String conLeadPassId;
            if(leadPessanger != null){
                for(Contact con : [Select id, email from contact where id = :leadPessanger limit 1]){
                    conLeadPassId = con.Id;   
                }
            }     
            if ( byCheque != false && paymentDue != 0) {
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid,CP_Client_Invoice__c = null,
                CP_Contact__c = conLeadPassId, CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Cheque',
                CP_Transaction_Status__c = '', CP_Type__c ='Checkout', CP_Payment_Type__c=paymentType ));
                
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'cheque';
            }
            if (byTransfer != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Contact__c = conLeadPassId, CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Bank/Transfer',
                CP_Transaction_Status__c = '', CP_Type__c ='Checkout',CP_Payment_Type__c=paymentType));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'transfer';
            }
            
            if (byCash != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Contact__c = conLeadPassId, CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Cash',
                CP_Transaction_Status__c = '', CP_Type__c ='Checkout',CP_Payment_Type__c=paymentType));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'cash';
            }
            if (byCardA != false && paymentDue != 0){
                amountPaid = paymentDue;
                lstClientPayments.add(new Client_Payment__c(CP_Receipt_AmountEx__c = amountPaid, CP_Amount__c = amountPaid ,CP_Client_Invoice__c = null,
                CP_Contact__c = conLeadPassId, CP_Date__c = date.today(), CP_Opportunity__c =opp.Id, CP_Payment_Method_C__c = 'Credit Card - Amex',
                CP_Transaction_Status__c = '', CP_Type__c ='Checkout',CP_Payment_Type__c=paymentType));
                opp.O_last_Payment__c = paymentDue;
                paymentTypeStr = 'Amex';
            }
            
            //***Updated by veer 07-Jan-15
            if(opp.O_Days_to_Departure__c != null && opp.O_Days_to_Departure__c <= 60){
                paymentType = 'Full';
            }
            //***
            
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
            opp.pipeline__c = true;
            Utility.isCopied = true;
            update opp;
            
         //   if (!Utility.isInternalUser()) {
         //Utility.saveSteps(opp.Id, 6);
         //   }
            isRedirect = true;
            if(lstClientPayments.size() > 0){
                return lstClientPayments[0].Id;
            }
            else{
                return null;
            }
        }
        catch(exception e){
            ApexPages.addMessages(e);
            displayMessage = e.getMessage()+e.getStackTraceString();
            return null;
        }
    }
    
          
    public void CalculateDue(){
        
        if(selectedCurrency1 == 'USD'){
            /*if(Opp.O_Exchange_Rate_USD__c != null){
                if(Opp.O_Exchange_Rate_USD__r.ER_Exchange_Rate__c > 0 && AmountDue > 0){
                    paymentDue = AmountDue * (Opp.O_Exchange_Rate_USD__r.ER_Exchange_Rate__c);
                    paymentDue = paymentDue.setScale(2);
                }
            }*/
        }
        else{
            paymentDue = AmountDue;
            paymentDue = paymentDue.setScale(2);
        }
        
    }  
    
    public class ErrorResponse{
        public String errorCode; 
        public String message;
        public List<String> errors;
    }
    
    public class CardTokenResponse{
        public String id; 
        public DateTime created;
        public boolean used;
        public CardInfo card;
    }
    public class CardInfo{
        public String expiryMonth; 
        public String expiryYear; 
        public String id; 
        public String last4 ; 
        public String  paymentMethod; 
        public String name; 
    }
    
}
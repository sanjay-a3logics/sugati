public class InvoiceController{
    public string oppId {get;set;}
    public string InvId {get;set;}
    public Opportunity Opp{get;set;}
    public Client_Invoice__c ClientInv {get; set;}
    public Decimal totalClientPayment{get; set;}
    public Decimal depositRequired{get; set;}
    public Contact GroupMemberContact {get;set;}
    public List<HeaderFooter> lstHF{get; set;}
    
    public PaymentMethods objPaymentMethods{get; set;}
    public Map<String,Exchange_Rate__c> mapExchangeRate{get;set;}
    
    public InvoiceController(Apexpages.standardcontroller controller){
        try{
            InvId = controller.getId();
            totalClientPayment = 0;
            depositRequired = 0;
            if (controller.getId() != null) {
                for(Client_Invoice__c CI : [select id,name,CI_Deposit_Overwrite__c ,CI_Proforma_Type__c,CI_Client_Group__c,CI_Client_Group__r.CG_Selling_Price__c,
                                            recordType.Name,recordTypeId,I_Opportunity__c,I_Invoice_Date__c,I_Total_Price__c,I_Balance_Outstanding__c,CI_Client_Group__r.CG_Lead_Group_Member__c,
                                            I_Final_Payment_Due__c,I_Payment_Received__c,I_Invoice_Number__c,CI_Credit_Note_Amount__c,I_Description__c,CI_Client_Group__r.CG_Lead_Group_Member__r.GM_Contact__c,
                                            CI_Invoice_Number__c from Client_Invoice__c where id = : InvId]){
                    ClientInv = CI;
                }   
                
                Opp = [select id,currencyISOCode,closeDate, O_RecordType__c,O_Exchange_Rate__r.ER_Exchange_Rate__c, Name,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                       O_Adult__c,O_Children__c,O_Infant__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Reference_Number__c,O_Due_Date__c,O_Country__c,O_Deposit_Required1__c,
                       O_Itinerary_Display_Price__c,O_Total_Payment__c,(select GM_Contact__r.C_Full_Name_on_Passport__c
                                         from Group_Members__r),O_Suggested_Margin__r.M_Margin__c,
                         (Select ID,Previous_Recommended_Selling_Price__c,CG_Deposit_Required_I__c,CG_Recommended_Selling_Price_Rp__c, Name,CG_Total_Recommended_Selling_Price__c,CG_Selling_Price__c,
                       CG_Charity__c, CG_Regulatory_Charges__c, CG_FX_Transfer_Charges__c, CG_Arrival_Presents__c from Client_Groups__r)
                       from Opportunity where Id=:ClientInv.I_Opportunity__c];
                
                //Proporma Invoice Functionality
                if(ClientInv.recordType.Name == 'Proforma Invoice'){
                    ClientInv.recordType.Name = ClientInv.CI_Proforma_Type__c;
                }
                
                List<Client_Payment__c> lstClientPayment = [Select Id,CP_Receipt_AmountEx__c,CP_Amount__c,CP_Payee__c,CP_Client_Invoice__c from Client_payment__c where CP_Opportunity__c = :opp.Id and 
                                                            CP_Processed_On__c != null and CP_Payee__c != null];   
                List<Supplier_Cost__c> lstSupplierCost = [Select Id,SC_Supplier_Booking__c,SC_Total_Net_CostSC__c,SC_Supplier_Booking__r.recordType.Name,SC_Client_Group__c  
                                                                from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c = :opp.Id];
                Map<String,Integer> mapCountOfSB = new Map<String,Integer>();
                for(Supplier_Cost__c sbc : lstSupplierCost){
                    if(!mapCountOfSB.containsKey(sbc.SC_Supplier_Booking__c)){
                        mapCountOfSB.put(sbc.SC_Supplier_Booking__c,0);
                    } 
                    Integer count = mapCountOfSB.get(sbc.SC_Supplier_Booking__c);
                    mapCountOfSB.put(sbc.SC_Supplier_Booking__c,count+1);
                }
                if(ClientInv.CI_Client_Group__c != null && ClientInv.CI_Client_Group__r.CG_Lead_Group_Member__c != null && ClientInv.CI_Client_Group__r.CG_Lead_Group_Member__r.GM_Contact__c != null)
                    GroupMemberContact = [Select id, salutation, firstName, lastName, MailingStreet, MailingState, MailingPostalCode,MailingCountry,
                                          MailingCity from Contact where id =: ClientInv.CI_Client_Group__r.CG_Lead_Group_Member__r.GM_Contact__c];
                //system.assert(false,GroupMemberContact); 
                for(Client_Group__c cg : opp.Client_Groups__r){
                    if(ClientInv.CI_Client_Group__c != null && cg.id == ClientInv.CI_Client_Group__c){
                        for(Client_Payment__c cp : lstClientPayment){
                            if(ClientInv.CI_Client_Group__c == cp.CP_Payee__c ){
                                totalClientPayment  +=  cp.CP_Receipt_AmountEx__c;
                            }
                        }
                        if(cg.CG_Deposit_Required_I__c != null){ 
                            depositRequired += cg.CG_Deposit_Required_I__c;
                        }
                        
                        
                    }    
                }
                
            }
        
            //Set Header/ Footer
            lstHF = new List<HeaderFooter>();
            List<Document> lstDoc = [Select Id,Name from Document where Name like '%Client Invoice%'];
            HeaderFooter header = new HeaderFooter('','');
            HeaderFooter footer = new HeaderFooter('','');
           
            for(Document doc : lstDoc){
                if(doc.name.contains('Header')){
                    header.imageId = doc.Id;
                }    
                if(doc.name.contains('Footer')){
                    footer.imageId = doc.Id;
                }
            }
            lstHF.add(header);
            lstHF.add(footer);
            
            //Payment Methods
            mapExchangeRate = new Map<String,Exchange_Rate__c>();
            Set<String> lstPmsCurrency = new Set<String>();
            List<Payment_Method__c> lstPM = [Select Id,CurrencyISOCode,recordType.DeveloperName,PM_Description__c from Payment_Method__c 
                                        where PM_Record_Type__c = :Opp.O_RecordType__c];
            List<Date> lstMinMaxDPDate = Utility.FindMinMaxDate(new Set<Date>{Opp.CloseDate});
            List<Date> lstMinMaxCloseDate = Utility.FindMinMaxDate(new Set<Date>{Opp.O_Departure_Date__c});
            
            for(Payment_Method__c pm : lstPM){
                lstPmsCurrency.add(pm.currencyISOCode);
            }
            for(Exchange_Rate__c er : SOQLServices.getExchangeRate(lstPmsCurrency,lstMinMaxCloseDate,lstMinMaxDPDate,'Sell')){
                if(er.ER_Base_Currency__c == Opp.CurrencyISOCOde){
                    mapExchangeRate.put(er.ER_Sales_Currency__c, er);
                }
            }
            objPaymentMethods = new PaymentMethods(new List<Payment_Method__c>(), new Payment_Method__c(), new Payment_Method__c(), new Payment_Method__c());
            for(Payment_Method__c pm : lstPM){
                if(pm.recordType.DeveloperName == 'Payment_Method'){
                    objPaymentMethods.lstMethods.add(pm);
                }
                if(pm.recordType.DeveloperName  == 'Important_Notes'){
                    objPaymentMethods.imprtantNotes = pm;
                }
                if(pm.recordType.DeveloperName == 'Cheques_Notes'){
                    objPaymentMethods.chequesNotes = pm;
                }
                if(pm.recordType.DeveloperName == 'Footer'){
                    objPaymentMethods.footer = pm;
                }
                
            }
            
            
        }
        catch(Exception e){
            System.assert(false, e.getStackTraceString());
        }
        
    }
    
    public Class PaymentMethods{
        public List<Payment_Method__c> lstMethods{get; set;}
        public Payment_Method__c imprtantNotes{get; set;}
        public Payment_Method__c  chequesNotes{get; set;}
        public Payment_Method__c footer{get;set;}
        public Exchange_Rate__c ex{get; set;}
        
        public PaymentMethods(List<Payment_Method__c> lstMethods, Payment_Method__c  imprtantNotes, Payment_Method__c  chquesNotes, Payment_Method__c footer){
            this.lstMethods = lstMethods;
            this.imprtantNotes = imprtantNotes;
            this.chequesNotes = chequesNotes;
            this.footer = footer;
        }
    }
    public class HeaderFooter{
        public String imageId{get; set;}
        public String text{get; set;}
        public HeaderFooter(String imageId, String text){
            this.imageId = imageId;
            this.text = text;
        }
    }
    
}
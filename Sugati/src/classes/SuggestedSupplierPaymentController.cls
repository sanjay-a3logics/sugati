public with sharing class SuggestedSupplierPaymentController {
    public Supplier_Payment__c supplierPayment{get;set;}
    public Supplier_Payment__c supplierPayment1{get;set;}

    public String bankAccountNumber{get;set;}
    public String supplierName{get;set;}
    public String bookingRef{get;set;}
    public String revAnalysis{get;set;}
    public final Integer PAGESIZE{get;set;} 
    public Boolean isAscending {get;set;}
    public Boolean checkSetcon;
    String Mainquery;
    String previousSortField = 'SP_Supplier_Name__c';
    public Set<String> setOfSupplier;
    
    public List<Selectoption> suppliers{get;set;}
    public String fileName {get;set;}
    
    
    public List<Supplier_Payment__c> spList = new List<Supplier_Payment__c>();
    
    public SuggestedSupplierPaymentController() {
        PAGESIZE = 20;
        supplierPayment = new Supplier_Payment__c();
        supplierPayment1 = new Supplier_Payment__c();
        
        isAscending = true;
        sortField = '';
        Mainquery = '';
        checkSetcon = false;
      
    }
    
    public List<Selectoption> getBankAccounts() {
        bankAccountNumber = 'All';
        return Utility.getBankAccounts();
    }
    public void loadSupplier() {
        
        suppliers= new List<Selectoption>();
        suppliers.add(new Selectoption('','-Select-'));
        suppliers.add(new Selectoption('All','All'));
        Set<String> SupplierNamesSet = new Set<String>();
        setOfSupplier =new Set<String>();
        
        for(Supplier_Payment__c sp : [SELECT id, SP_Supplier__c,SP_Opportunity__c,SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c, 
        SP_Supplier_Name__c FROM Supplier_Payment__c 
        WHERE SP_Due_Date__c >=: supplierPayment.SP_Due_Date__c AND SP_Due_Date__c <=: supplierPayment1.SP_Due_Date__c
        ORDER BY SP_Supplier_Name__c ]){ 
          if (!setOfSupplier.contains(sp.SP_Supplier__c)) {
                suppliers.add(new Selectoption (sp.SP_Supplier__c,sp.SP_Supplier_Name__c));
                setOfSupplier.add(sp.SP_Supplier__c);
           } 
        }
        supplierName = 'All';
        
    }
    
    
    string query ; 
    public Pagereference search() {
        try {
             
             checkSetcon = true;
             setCon = null;
             if (validate()) {
                //supplierPayments = new List<Supplier_Payment__c>();
                query = '' ;
                Mainquery = '';
                query = 'SELECT  SP_Supplier_Name__c ,SP_Opportunity__c ,SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c,SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__r.stagename,SBP_Supplier_Cost_Currency_Value__r.SCP_Total__c,SBP_Supplier_Cost_Currency_Value__r.SCP_Total_Payment__c,CurrencyIsoCode,SP_Due_Date__c, id,SBP_Supplier_Cost_Currency_Value__r.SCP_Outstanding_Amount__c,SP_Bank_Accounts__r.Id,SP_Bank_Accounts__r.Name,SP_Comment__c FROM Supplier_Payment__c ';

                String whereClause = ' WHERE ';
                String whereClauseCondition = ''; 
                String operator = ' AND ';
                system.debug('-----------------'+supplierName);
                if (bankAccountNumber != null && bankAccountNumber !='' && bankAccountNumber != 'All') {
                    whereClauseCondition += 'SP_Bank_Accounts__r.Id= '+  '\''+bankAccountNumber+'\'' + operator ;
                }
                if (supplierName!= null && supplierName !='' && supplierName != 'All') {
                    whereClauseCondition += ' SBP_Supplier_Cost_Currency_Value__r.SCP_Supplier__c= '+  '\''+supplierName+'\'' + operator;
                }
                else if(supplierName == 'All'){
                    whereClauseCondition += ' SP_Supplier__c in :setOfSupplier ' + operator; 
                }
                if (bookingRef != null && bookingRef != '' ) { 
                    whereClauseCondition += 'SP_Opportunity__c like '+  '\'%'+bookingRef+'%\'' + operator;
                }
               /* if(revAnalysis != null && revAnalysis != ''){
                    whereClauseCondition += ' SP_Rev_Analysis_Code__c= '+  '\''+revAnalysis+'\'' + operator;
                }*/
                if (supplierPayment.SP_Due_Date__c != null) {
                    whereClauseCondition += ' SP_Due_Date__c >= ' +formatDate(supplierPayment.SP_Due_Date__c ) + operator;
                }
                if (supplierPayment1.SP_Due_Date__c != null) {
                    whereClauseCondition += ' SP_Due_Date__c <= '+  formatDate(supplierPayment1.SP_Due_Date__c ) + operator;
                }
               
                if (whereClauseCondition !='') {
                    query = query + whereClause + whereClauseCondition ;
                    query = query.trim().substring(0, query.trim().length() - 3);
                    Mainquery = query + ' and  SBP_Supplier_Cost_Currency_Value__c != null and SBP_Supplier_Cost_Currency_Value__r.SCP_Outstanding_Amount__c > 0 and (SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__r.stagename like \'%book%\' or SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__r.stagename like \'%Cancel%\') Order by SP_Supplier_Name__c,  SP_Due_Date__c  ';
                }
            }             
        }
        catch(Exception e) {
            Apexpages.addMessages(e);
        }    

        return null;
    }

    private boolean validate(){
        //return true;

        String message = '';

        if (bankAccountNumber  == null || bankAccountNumber =='') {
            message = ' You must select Bank Account Number' ;
        }
       
        else if (supplierPayment.SP_Due_Date__c == null) {
            message = ' You must select Start Payment Date';
        }
        else if (supplierPayment1.SP_Due_Date__c == null) {
            message = ' You must select End Payment Date' ;
        }
        if (supplierPayment.SP_Due_Date__c != null && supplierPayment1.SP_Due_Date__c != null) {
            if (supplierPayment.SP_Due_Date__c > supplierPayment1.SP_Due_Date__c) {
                message = ' Start Payment Date must be less than End Payment Date' ;
            }
        }

        if (message !='') {        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message );
            Apexpages.addMessage(myMsg);
            return false;
        }

        return true;
    }

    /*
     *@ Sort Column of data Seached 
     *@ SortField- Name of column on which user clicked to sort
     */


    public Pagereference DoSort(){
        setCon = null;
        Mainquery = '';
        //supplierPayments = new List<Supplier_Payment__c >();
        Mainquery = query ;
        
        if(Mainquery != null){
            if(isAscending){
                Mainquery = Mainquery + ' Order By  '  + string.escapeSingleQuotes(SortField) + ' ASC Limit 1000';
            } 
            else{
                Mainquery = Mainquery + ' Order By  '  + string.escapeSingleQuotes(SortField) + ' DESC nulls last Limit 1000';
            }
        }

        return null;
    }

    // Set Sort Status - Ascending/Descending
    private void setAscendingStatus() {
        if(previousSortField == sortField) {
            isAscending = !isAscending;
            return;
        }
        this.isAscending = true;  
    }


    public string sortField {
        get;
        set {
            this.previousSortField = sortField;
            this.sortField = value;
            setAscendingStatus();
        }
    }

    private string formatDate(Date d){
        if (d != null) {
            return  d.year() + '-' + (d.month() < 10? '0'+d.month() : ''+d.month()) +'-' + (d.day() < 10? '0'+d.day() : ''+d.day());
        }
        return '';
    }

    public Pagereference print() {
        return Page.SuggestedSupplierPaymentPrint;
    }
    public Pagereference printPreview() {
        return Page.SuggestedSupplierPaymentPDF;
    }
    public Pagereference export() {
        fileName = 'Suggested Supplier Payment ' + Datetime.now();
        return Page.SuggestedSupplierPaymentExport;
    }

    //Return list of Supplier Payment record match to given criteria
    public List<Supplier_Payment__c> getsupplierPayments() {
        if(checkSetcon && setCon != null){
            return (List<Supplier_Payment__c>)setCon.getRecords();
        }


        return new List<Supplier_Payment__c>();

    } 

    //Get supplier Payment Records using Query 
    public ApexPages.StandardSetController setCon {
        get{
            try{
                if(setCon == null){
                    if(Mainquery != null && Mainquery != ''){
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(Mainquery));
                        setCon.setPageSize(PAGESIZE);
                     }
                   
                }
               }
               catch(exception e){
                   Apexpages.addMessages(e);
               } 
               return setCon;
               
            
        }set;
    }
    
    //Picklist options of rev ref no. field of supplie payment
    public List<SelectOption> getRevOptions(){
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('','-Select-'));
        Schema.DescribeFieldResult fieldResult =
        Supplier_Payment__c.SP_Rev_Analysis_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    // Pagination of Search Record
    public Boolean hasNext {
        get {
            if(setCon != null)
                return setCon.getHasNext();
            return false;
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            if(setCon != null)
                return setCon.getHasPrevious();
             return false;
        }
        set;
    }

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

    public void first() {
        
        setCon.first();
    }

    public void last() {
        setCon.last();
    }

    public void previous() {
        if (setCon != null ) {
            setCon.previous();
        }
    }

    public void next() {
        if (setCon != null ) {
            setCon.next();
        }
    }


}
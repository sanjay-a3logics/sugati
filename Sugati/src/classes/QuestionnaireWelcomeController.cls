public without sharing class  QuestionnaireWelcomeController{

    public String UrlId  {get;set;}
    public List<Opportunity> HolidayQuesRec{get;set;}
    public List<SelectOption> charityLst{get;set;}
    //public Property__c objProperty {get;set;}
    public String userName {get;set;}
    public String visitDate {get;set;}
    public Questinnaire__c NewQuestionnaire {get;set;}
    public String verifyClientProperty{get;set;}
    public String oppAccName{get;set;}
    public String oppReferenceNo{get;set;}
    public String oppPropertyName{get;set;}
    public Date oppDepDate{get;set;}
    public String oppDepDate1 {get;set;}
    public Decimal oppCharityValue{get;set;}
    public String oppDestination{get;set;}
    public String propertyRegion {get;set;}
    public String auditByName {get;set;}
    
    public QuestionnaireWelcomeController(){
        UrlId  = APexpages.currentpage().getParameters().get('id');
        HolidayQuesRec = new List<Opportunity>();
        //objProperty = new Property__c() ;
        userName = userinfo.getname() ;
        NewQuestionnaire = new Questinnaire__c();
        visitDate = date.today().format();
        verifyClientProperty = '';
        oppDepDate1 = '' ;
        if(UrlId  != null){
        
            //if(UrlId.startsWithIgnoreCase('006')){
                verifyClientProperty = 'opp';
                HolidayQuesRec = [select id,Account.name,O_Reference_Number__c,O_Departure_Date__c,O_Charity__c,O_Destination__c from opportunity where id =: UrlId];
                Schema.DescribeFieldResult describeField = Opportunity.O_Charity__c.getDescribe();
                List<Schema.PicklistEntry> pickListValues = describeField.getPicklistValues();  
                charityLst = new List<SelectOption>();
                    
                for(Schema.PicklistEntry f : pickListValues){
                    charityLst.add(new selectOption(f.getLabel(),f.getValue()));
                }
                
                oppAccName = HolidayQuesRec[0].Account.name;
                oppReferenceNo = HolidayQuesRec[0].O_Reference_Number__c;
                //oppPropertyName = HolidayQuesRec[0].O_Property__c;
                oppDepDate =  HolidayQuesRec[0].O_Departure_Date__c;
                if(oppDepDate != null)
                    oppDepDate1 = oppDepDate.format();
                oppCharityValue =  HolidayQuesRec[0].O_Charity__c;
                oppDestination = HolidayQuesRec[0].O_Destination__c;
                propertyRegion = '';
                auditByName = '';
            //}
           /* else{
                verifyClientProperty = 'property';
                objProperty = [Select id,Name,P_Locality__r.Name,P_Region__c from Property__c  where id =: UrlId  ] ;
                auditByName = UserInfo.getName();
                propertyRegion = objProperty.P_Region__c;
                NewQuestionnaire.Q_Completed_Date__c = Date.today();
                NewQuestionnaire.Q_Date_of_visit__c = Date.today();
            }*/
        }
    }
    public pageReference BeginQuesionnaire(){
        //system.assert(false,'wwwwwwwwwwwwwwwwwwwwwww');
        if(UrlId  != null){
             recordtype rt;
             
             //if(UrlId.startsWithIgnoreCase('006')){
             
                rt = [select id from RecordType where sobjectType = :Utility.getNameSpacePrefix()+'Questinnaire__c' and developername = 'Client' limit 1];
                NewQuestionnaire = new Questinnaire__c(Q_Category_Checker__c = 1,Q_Booking__c = UrlId,Q_Date_of_visit__c = Date.today(),RecordTypeId =rt.id,Q_Stage__c = 'In Progress');
                
             /*}else{
                
                rt = [select id,name from RecordType where sobjectType = 'Questinnaire__c' and developername = 'H_S' limit 1];
                NewQuestionnaire = new Questinnaire__c(Q_Category_Checker__c = 1, Q_Audit_By__c=auditByName, Q_Completed_Date__c = NewQuestionnaire.Q_Completed_Date__c, Q_Property__c = UrlId,Q_Date_of_visit__c = NewQuestionnaire.Q_Date_of_visit__c ,RecordTypeId =rt.id,Q_Stage__c = 'In Progress',StatusNA__c='Green');
                
             }*/
             insert NewQuestionnaire;
             if(oppCharityValue != null && oppCharityValue != HolidayQuesRec[0].O_Charity__c){
                 HolidayQuesRec[0].O_Charity__c = oppCharityValue;
                 upsert HolidayQuesRec[0];
             }
             if(UrlId.startsWithIgnoreCase('006')){
                 pageReference pr = new pageReference('/apex/Client_Questionnaire?id='+UrlId);
                 return pr;
             }
            /* else{
                  pageReference pr = new pageReference('/apex/Client_Questionnaire?id='+UrlId+'&flag=New&RecId='+NewQuestionnaire.id);
                 return pr;
            
             }*/
         }
         return null;
    }
    public pageReference VerifyExisitingUser(){
        List<Questinnaire__c> ExistingQuestionnaire;
        if(UrlId.startsWithIgnoreCase('006')){
        
            ExistingQuestionnaire = [select id from Questinnaire__c where Q_Booking__c =:UrlId];
            
            if(ExistingQuestionnaire != null && ExistingQuestionnaire.size()>0) {
                return new pageReference('/apex/Client_Questionnaire?id='+UrlId);
            }
        } else{
            Boolean isCloned = APexpages.currentpage().getParameters().get('clone') != null ? true : false;
                
            if(!isCloned && APexpages.currentpage().getParameters().get('flag') == null){
                String RecordId = APexpages.currentpage().getParameters().get('RecId');
                return new pageReference('/apex/Client_Questionnaire?id='+UrlId+'&RecId='+RecordId);  
            }
        }
        return null;
        
    }
}
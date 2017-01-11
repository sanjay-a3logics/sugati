public without sharing class BookingDetailsController {

    public string oppId{get;set;}
    public Opportunity opp{get;set;}
    public String countries {get; set;}
    public contact leadGuest{get; set;}
    public List<contact> otherGuests{get; set;}
    public Boolean daysToDeparture{get; set;}
    public Decimal paymentDue{get; set;}
    /* changes----*/
    public Id cgid{get;set;}
    
    List<String> conIds = new List<String>();
    public BookingDetailsController() {
        try {
            cgid = apexpages.currentpage().getparameters().get('cgid');  
            oppId = Apexpages.currentPage().getParameters().get('id');
            System.debug(Apexpages.currentPage().getParameters().get('id'));
            countries = '';
            if (oppId != null) {
                List<Opportunity> opps= [select id,O_Deposit_Required1__c,O_Total_Payment_Without_CC__c,O_Booking_Date__c,O_Total_Payment1__c,currencyISOCode,AccountID,Owner.Name,Name,Amount,O_Outstanding__c,O_Insurance_Company__c,
                (Select Id,TC_Country__r.name from  Travelling_Countries__r), (Select ID, GM_Contact__c,GM_Lead_Passenger__c from Group_Members__r),O_Departure_Date__c,O_Reference_Number__c , O_Quote_No__c, O_Booking_Number__c from Opportunity where id =: oppId];
                if (opps.size() > 0) {
                    opp = opps[0];
                    Date d1 = (Opp.O_Departure_Date__c).addDays(70);
                    If(Opp.O_Booking_Date__c > d1){
                        daysToDeparture = true;
                        paymentDue = opp.O_Deposit_Required1__c-opp.O_Total_Payment_Without_CC__c;
                    }
                    else{
                        daysToDeparture = false;
                        if(opp.Amount != null && opp.O_Total_Payment_Without_CC__c != null)
                            paymentDue = opp.Amount-opp.O_Total_Payment_Without_CC__c;
                        else
                         paymentDue = 0;
                    }
                    Integer i=1;
                    for(Travelling_Country__c tc : Opp.Travelling_Countries__r){
                        if(i != Opp.Travelling_Countries__r.size())    
                            countries += tc.TC_Country__r.name+', ';
                        else
                            countries += tc.TC_Country__r.name;
                    i++;
                    }
                    for(Group_Member__c gm : opp.Group_Members__r){
                        conIds.add(gm.GM_Contact__c);
                    }
                }
            }
            guests();
        }
        Catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+'--'+e.getStackTraceString()));
            //throw e;
        }
        
        
    }
    
    public String getFileId() {
        String CoverImg;
        //String fileId = '';
        List<Travelling_Country__c> lstTC = [select TC_ImageID__c,TC_Cover_Image__c  from Travelling_Country__c
                 where TC_Opportunity__r.Id= :oppId
                 AND TC_Selected__c != NULL 
                 AND TC_ImageID__c!= NULL 
                 //AND TC_Cover_Image__c = true
                Order by TC_Selected__c desc
                ];
                  //Name ='Cover.png' AND ParentId = :Opp.o_country__r.id];
          if(lstTC.size()>0) {
              if (lstTC[0].TC_Cover_Image__c) {
                  CoverImg = lstTC[0].TC_ImageID__c;
              }
          }
       
        
        return CoverImg;   
     }

     void guests(){
         Set<Id> conIds = new Set<Id>();
         otherGuests = new List<Contact>();
         leadGuest = new Contact();
         String leadConId ;
         for(Group_Member__c gm : [SELECT Id, Name,GM_Contact__c,GM_Lead_Passenger__c from Group_Member__c where GM_Opportunity__c=:opp.Id AND GM_Client_Group__c=:cgid]){
             conIds.add(gm.GM_Contact__c);
             if(gm.GM_Lead_Passenger__c){
                 leadConId = gm.GM_Contact__c;
             }
         }
         
         For(Contact con: [Select Id,birthDate,salutation,FirstName,lastname,Phone,C_Lead_Passenger__c,Email,MailingStreet,MailingState,
                                    MailingPostalCode,MailingCountry,MailingCity,OtherStreet,OtherState,OtherCountry,OtherPostalCode  
                           from Contact where Id in :conIds  order by createdDate]){ 
            if(con.Id == leadConId){
                leadGuest = con;
            }
            else{
                otherGuests.add(con);
            }    
        }
     }
    
}
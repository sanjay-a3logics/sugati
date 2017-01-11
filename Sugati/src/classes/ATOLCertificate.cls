public without sharing class ATOLCertificate {

  public Opportunity CurrentOpportunity {get;set;}
  public List<Group_Member__c> listGM {get;set;}
  public List<FB> listFB {get;set;}
  Public List<TC> listTC {get;set;}
  
  public string Resort {get;set;}
  public string ResortLink {get;set;}
  public string ResortImage {get;set;}
 
  public string BackgroundImage {get;set;}
  public decimal NumberOfPessenger {get;set;}
  
  public ATOLCertificate(ApexPages.StandardController controller){
    Resort = '';
    ResortLink = '#';
    ResortImage = '';
    BackgroundImage = 'pbrbg.gif';
 
 
   // Opportunity Details
     if(ApexPages.CurrentPage().getParameters().get('id') != null){
        
        for(Opportunity opp : [Select Id, Amount,O_Infant__c, Name, O_ATOL__c, Account.Name,O_No_of_Nights__c,O_Pax__c,O_Reference_Number__c,O_Booking_Date__c
                               From Opportunity Where Id = : ApexPages.CurrentPage().getParameters().get('id') ]){
                                   
            CurrentOpportunity = opp;
            
            NumberOfPessenger = opp.O_Pax__c - opp.O_Infant__c;
                                   
        }
    }
      
      
    // List of Group Memember Records 
    listGM = new List<Group_Member__c>();
    listGM = [Select Id,GM_Salutation__c,GM_First_Name__c,GM_Last_Name__c,GM_Age__c,GM_DOB__c,GM_Contact__r.C_Full_Name_on_Passport__c
              From Group_Member__c Where GM_Opportunity__c = : CurrentOpportunity.Id 
              Order By  GM_DOB__c DESC,GM_Last_Name__c ASC, GM_First_Name__c ASC];
      
      

    // List of Flight Details From Supplier Booking Records
    listFB = new List<FB>();
    for(Supplier_Booking__c f : [Select Id,RecordType.Name,SB_Arrival_Airport_l__c,SB_Departure_Time__c,SB_Check_In_Time__c ,SB_Departure_Airport_l__c,SB_To_Date__c,SB_From_Date__c,SB_From_Time__c,
                                SB_To_Time__c,SB_Pax_for_Costing__c,SB_Flight_No__c
                                From Supplier_Booking__c 
                                Where SB_Opportunity__c = : CurrentOpportunity.Id AND 
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                Order by SB_From_Date__c])
    {
       FB fb = new FB();
       f.SB_Pax_for_Costing__c = ''+NumberOfPessenger;
       
       fb.FBooking = f;
        listFB.add(fb);
    }
      // List of Flight Details From Supplier Booking Records
    listTC = new List<TC>();
    for(Travelling_Country__c t : [Select Id,TC_Country__r.Name
                                From Travelling_Country__c 
                                Where TC_Opportunity__c = : CurrentOpportunity.Id ])
    {
       TC tc = new TC();
       tc.TCountry = t;
        listTC.add(tc);
    }
  
  }
   
     
    Public class FB{
        public Supplier_Booking__c FBooking {get;set;}
     }
    
    Public Class TC{
        Public Travelling_Country__c TCountry {get;set;}
    }
}
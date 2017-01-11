public class PreviewPdfController{
    
    public string oppId{get;set;}
    public Opportunity Opp{get;set;}
    public transient List<Attachment> attachedFiles{get; set;}
    public List<Selected_Itinerary_Content_Category__c> lstSelectedItinerary{get;set;}
    public List<Attachment>lstStr{get;set;}
    public  List<Attachment> attachedMap {get; set;}
    public transient List<Attachment> attachedLogo {get; set;}
    Public transient List<Attachment> attachedUserPhoto {get;set;}
    Public transient List <Supplier_Booking__c> lstSupplierBooking {get;set;}
    Public transient List<Group_Member__c> lstGroupMember {get;set;}
    Public transient List<Supplier_Booking__c> lstFlightBook {get;set;}
    Public transient List<Supplier_Booking__c> lstSupAcc  {get;set;}
    public transient List<Supplier_Booking__c> lstDetailedItinerary {get; set;}
    public List<Travelling_Country__c> lstTC {get;set;}
    public List<Travelling_Country__c> lstTCMap {get;set;}
    public List<Travelling_Country__c> lstTravelCountry {get;set;}
    public List<Country__c> lstCountry {get;set;}
    public string UserfullPhoto{get;set;} 
    public string UserSmallPhoto{get;set;}
    public string CoverImg{get;set;}
    public string MapImg{get;set;}
    Public string tailordesc{get;set;}
    Public string tailordesc1{get;set;}
    Public string WhatCostdesc{get;set;}
    Public set<string> travelcountry{get;set;}
    Public set<string> setFlight{get;set;}
    Public string hType;
    
    public Map<String,Boolean> mapSelected{get; set;}
    public Map<String,String> mapSelectedContentIds{get; set;}
    public String mapContains{get; set;}
    public List<String> selectedItineraryContent = new List<String>();
 
    Public List<string> HolidayType = new List<string>();
    Public Boolean stageMsg = False;  
    public decimal roundedPayment{get;set;}
    
    
    
    
    
    
    public PreviewPdfController(Apexpages.standardcontroller controller) {
        oppId = controller.getId();
        if (controller.getId() != null) {
            Opp = [select id, Name,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                   O_Adult__c,O_Children__c,O_Infant__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Reference_Number__c,O_Due_Date__c,
                   O_Itinerary_Display_Price__c,O_Total_Payment__c,(select  GM_Contact__r.C_Full_Name_on_Passport__c         from Group_Members__r)
                   from Opportunity 
            where Id=:oppId];
            
           Decimal toround = Opp.O_Total_Payment__c;
           roundedPayment = toround.setScale(2);
            
           if(Opp.O_Holiday_Type__c != NULL)
           { 
               hType=Opp.O_Holiday_Type__c;
           
            HolidayType = hType.split(';');
               
           }
            
             
            
         } 
        
              
         
        // Display Only Selected category's Content 
          
        mapSelected = new Map<String, Boolean>();
        mapSelectedContentIds= new Map<String, String>();
        LIST<Opportunity> selectedOpp = new List<Opportunity>();
        if(oppId != null){
            selectedOpp =  [Select Id, (Select Id, Name,SICC_Itinerary_Content_Category__r.name from Itinerary_Content_Categories__r) from Opportunity where Id = :oppId ];
        }
        for(Itinerary_Content_Category__c icc : [Select Id, Name from Itinerary_Content_Category__c]){
            mapSelected.put(icc.Name, false);  
            mapContains += ' '+icc.Name;  
        }
        if(selectedOpp.size()> 0){
            for(Selected_Itinerary_Content_Category__c sIc : selectedOpp[0].Itinerary_Content_Categories__r){
                selectedItineraryContent.add(sIc.SICC_Itinerary_Content_Category__r.name); 
                mapSelected.put(sIc.SICC_Itinerary_Content_Category__r.name, true);
                mapSelectedContentIds.put(sIc.SICC_Itinerary_Content_Category__r.name, sIc.SICC_Itinerary_Content_Category__c);                   
            }    
        }
        
    }
    
        
    
    
   // Where You will stay 
    
    Public List<Supplier_Booking__c> getWhereYouWillStay(){
      lstSupplierBooking = new List<Supplier_Booking__c>();
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Itinerary_Description__c,SB_Supplier__c, (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r limit 2 ) 
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_From_Date__c ASC])
                          {
                                  if(s.SB_Itinerary_Description__c == null){
                                      s.SB_Itinerary_Description__c = '<br/>';
                                  }
                                  lstSupplierBooking.add(s);      
                          }
        
       
               
             return lstSupplierBooking;
   
    }
    
 
    
Public List<WhereYouWillStay> lstWhereStay {get;set;}
Public List<Supplier_Booking__c> lstSupplierBooking1 {get;set;}
public  Map<String, Supplier_Booking__c> mapOldSBIds{get;set;}
public  List<Supplier_Booking__c> lstWhereSB{get;set;}
Public Map<string,boolean> mapIT_Check1 {get;set;}  
    
    Public List<WhereYouWillStay> getWhereStay(){
        lstWhereStay =  new  List<WhereYouWillStay>();
        lstSupplierBooking1 = new List<Supplier_Booking__c>();
        mapOldSBIds = new Map<String,Supplier_Booking__c>(); 
        lstWhereSB = new List<Supplier_Booking__c>();
        mapIT_Check1 = new MAP<string,boolean>();
    
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Itinerary_Description__c,SB_Supplier__c,SB_Order__c, (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r  where (SBI_Order__c = 3 or SBI_Order__c = 4) limit 2 ) 
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation')) AND 
                                    SB_Opportunity__c = :Opp.Id Order by SB_Order__c ]){
              if ( s.SB_Supplier__c != NULL) {                           
                    mapOldSBIds.put(s.SB_Supplier__c, s);
                    if(s.SB_Itinerary_Description__c == null){
                                      s.SB_Itinerary_Description__c = '<br/>';
                                  }
                    lstWhereSB.add(s);
              }
           } 
    
     List<String> lstSBSuppIds = new List<String>();
       for(Supplier_Booking__c  sb : lstWhereSB)
         lstSBSuppIds.add(sb.SB_Supplier__c);
    
            Map<String,Itinerary_Text__c> mapQT = new Map<String,Itinerary_Text__c>();
            Map<String,String> mapQTmsg = new Map<String,String>();       
            
            for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                    from Itinerary_Text__c
                                    where (IT_Holiday_Type__r.Name In :HolidayType)
                                    AND IT_SUPPLIER__C in :lstSBSuppIds  order by IT_SUPPLIER__C desc]){
                               
                              mapIT_Check1.put(qt.IT_SUPPLIER__C,TRUE);    
                              mapQT.put(qt.IT_Supplier__c,qt);
                              mapQTmsg.put(qt.IT_Supplier__c,qt.IT_Message__c);                                        
                               // lstWhereStay.add(new WhereYouWillStay(mapOldSBIds.get(qt.IT_SUPPLIER__C),qt.IT_Message__c));            
           }    
    
     for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                    from Itinerary_Text__c
                                    where  (IT_Holiday_Type__r.Name NOT IN :HolidayType  
                                    AND IT_Holiday_Type__r.Name='Generic')
                                    AND IT_SUPPLIER__C in :lstSBSuppIds  order by IT_SUPPLIER__C desc]){
                               
                                        if(!mapIT_check1.containsKey(qt.IT_SUPPLIER__C))  
                                        {
                                        mapQT.put(qt.IT_Supplier__c,qt);
                                        mapQTmsg.put(qt.IT_Supplier__c,qt.IT_Message__c);
                                        }                                       
                               // lstWhereStay.add(new WhereYouWillStay(mapOldSBIds.get(qt.IT_SUPPLIER__C),qt.IT_Message__c));            
           }    
       Set<String> suppIds = new Set<String>();
       for(Supplier_Booking__c sb : lstWhereSB){
           if(!suppIds.contains(sb.SB_Supplier__c)){ 
               lstWhereStay.add(new WhereYouWillStay(sb,mapQTmsg.get(sb.SB_SUPPLIER__C)));
               suppIds.add(sb.SB_Supplier__c);    
           }        
       }
                   
    //for(integer i=0;i<lstWhereStay.size();i++)
     //   system.debug('lstWhereStay'+lstWhereStay[i].sb.SB_Supplier__r.name);
    
     return lstWhereStay;

           
    }
   
    
    

// Itinerary Glance
     
     //OT Traveller Section   
    /*Public List<Group_Member__c> getItineraryGlanceOT(){
         lstGroupMember = new List<Group_Member__c>();
        
        AggregateResult[] ar =[SELECT COUNT(Id) from Group_Member__c where GM_Opportunity__r.Id= :Opp.Id];
        for(integer i=0;i<ar.size();i++)
            system.debug('agg res is '+ar.get(i));
        
        if(ar.size()>0){
    for(Group_Member__c Gm: [select Name,GM_Contact__r.Name from Group_Member__c where GM_Opportunity__r.Id= :Opp.Id]){
                lstGroupMember.add(Gm);
    }}
        
        
        return lstGroupMember;
   
    }*/
    
    
    //Flights Section
   Public integer countf=0;
    Public integer getflight(){
     lstFlightBook = new List<Supplier_Booking__c>();
             
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                                From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id AND 
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                Order by SB_Order__c])
        {
               lstFlightBook.add(flight);                        
        }
         
        countf = lstFlightBook.size();
        return countf;
      
            }
    
    public Map<String,Integer> mapFlightDateCount {get; set;}
    Public List<Supplier_Booking__c> getItineraryGlanceFlight(){
        mapFlightDateCount = new Map<String,Integer>();
        lstFlightBook = new List<Supplier_Booking__c>();
             
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,SB_Order__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,
                                (select FB_Group_Member__c,FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                 from Flight_Bookings1__r)         
                                From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id AND 
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                Order by SB_Order__c])
        {
            
            lstFlightBook.add(flight); 
            if(flight.SB_To_Date__c > flight.SB_From_Date__c){
                Integer count = flight.SB_From_Date__c.daysBetween(flight.SB_To_Date__c);
                mapFlightDateCount.put(flight.Id, count);
            }
            else
                mapFlightDateCount.put(flight.Id, 0);
        }
         
       
      
     
        return lstFlightBook;
    }
    

    
// Flight NOT HELD msg
Public Integer getItineraryFlightMessage(){
   
     
         integer NotHeld = 0;    
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_Order__c]){
                                          
                                             if(flight.SB_Not_Held__c == TRUE){
                                                 
                                              NotHeld++ ;
                                             
                                             }
                                             
                                 }  
      
     
        return NotHeld;
    }  
 
   // Flight HELD msg 
Public Integer getItineraryFlightMessage1(){
   
     
         integer Held = 0;    
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_Order__c]){
                                           
                                             if(flight.SB_Not_Held__c == False){
                                                 
                                              Held++ ;
                                             
                                             }
                                             
                                 }  
      
     
        return Held;
    }  
        
    
// Flight Booked msg
Public Integer getItineraryFlightBookedMessage(){
   
      
         integer BookMsg = 0;    
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                              From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id AND SB_Opportunity__r.StageName IN ('Booking Optional','Booked','Booking cancelled') AND
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_Order__c]){
       
                                             if(flight.SB_Own_Arrangement__c == FALSE){
                                                 
                                              BookMsg++ ;
                                             
                                             }
                                             
                                 }  
      
     
        return BookMsg;
    }
    
Public Integer getItineraryFlightBookedMessage1(){
   
      
         integer BookMsg1 = 0;    
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                              From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id
                                AND SB_Opportunity__r.StageName IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_Order__c]){
       
                                             if(flight.SB_Own_Arrangement__c == TRUE){
                                                 
                                              BookMsg1++ ;
                                             
                                             }
                                             
                                 }  
      
     
        return BookMsg1;
    }  
    

    
    
   
    
// Flight Group Member 
public  Map<String, Supplier_Booking__c> mapSBIds{get;set;}
Public List <Group_Member__c> lstGM {get;set;}  
    
Public  List<Group_Member__c> getGroupMembers(){   
     mapSBIds = new Map<String,Supplier_Booking__c>(); 
     setFlight = new Set<string>();
    lstGM = new List<Group_Member__c>();
    
    
      for(Supplier_Booking__c s :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                               From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id AND 
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                    Order by SB_Order__c]){
                                        
             mapSBIds.put(s.Id, s);
           }  
    
    
    // system.debug('size of mapSBIds'+mapSBIds.size());

    for(Flight_Booking__c fb: [select FB_Group_Member__c
                               from Flight_Booking__c
                               where FB_Supplier_Booking__c in :mapSBIds.keySet() ]){
                                            
                          setFlight.add(fb.FB_Group_Member__c);        
            
                       }  
    // system.debug('size of setFlight'+setFlight.size());
    
    for(Group_Member__c gm : [select Id,GM_Contact__c,GM_Contact__r.C_Full_Name_on_Passport__c from Group_Member__c
                             where Id in :setFlight]){
                             lstGM.add(gm);
     }
    
   // system.debug('size of lstGM'+lstGM.size());
    return lstGM;

} 
   
    Public integer countA=0;
    Public integer getAcc(){
     lstSupAcc = New List<Supplier_Booking__c>();       
        for(Supplier_Booking__c s:[SELECT SB_From_Date__c,SB_To_Date__c,SB_From_Place__c,SB_Meal_Basis__c,SB_Supplier_Name__c,SB_Room_Type__c,SB_No_of_Rooms__c,SB_From_Time__c
                                   from Supplier_Booking__c 
                                   where RecordTypeId in (SELECT Id FROM RecordType WHERE Name = 'Accommodation')
                                   AND SB_Opportunity__r.Id= :Opp.Id
                                   Order by SB_Order__c])
        {
               lstSupAcc.add(s);                        
        }
        
        //for(integer i=0;i<lstSupAcc.size();i++)
           // system.debug('lstSupAcc' +lstSupAcc[i].SB_From_Date__c);
        countA=lstSupAcc.size();
        return countA;
    }
    
    
    //Accommodation section
    Public List<Supplier_Booking__c> getItineraryGlanceAccommodation(){
       
        lstSupAcc = New List<Supplier_Booking__c>();       
        for(Supplier_Booking__c s:[SELECT SB_From_Date__c,SB_To_Date__c,SB_From_Place__c,SB_Meal_Basis__c,SB_Supplier_Name__c,SB_Room_Type__c,SB_No_of_Rooms__c,SB_From_Time__c
                                   from Supplier_Booking__c 
                                   where RecordTypeId in (SELECT Id FROM RecordType WHERE Name = 'Accommodation')
                                   AND SB_Opportunity__r.Id= :Opp.Id
                                   Order by SB_Order__c])
        {
               lstSupAcc.add(s);                        
        }
        
      //  for(integer i=0;i<lstSupAcc.size();i++)
          //  system.debug('lstSupAcc' +lstSupAcc[i].SB_From_Date__c);
        return lstSupAcc;
    }
    
              
    
    
    //  PDF Logos 
    
    Public string getLogo() { 
        
        string recordtype_Name = string.valueof('');
       
        string Image;
        boolean show = False;
        
        if(recordtype_Name == 'OT' || recordtype_Name == 'OD' ){
             Image = 'Logos/OT.jpg';
        }
        
      /*  else if(recordtype_Name == 'OD'){
            Image = 'Logos/OT.jpg';
        }*/
        
         else if(recordtype_Name == 'ST'){
            Image = 'Logos/ST.jpg';
        }
        
                         
        else {
            Image = '';
        }   
        
      system.debug('logo '+Image);
     return Image;
    }
    
    
    
    
    
    //  OTUK logo
      Public String likestr1 = 'Logo';
     Public String likeclause1 = '%str%';
    
    Public string getOTUKLogo(){
        system.Debug('OTUK Logo');
        String ImageId = '';
        string AgentId = Opp.O_Agent__c;
        if(AgentId != NULL)
        {
            attachedLogo = [select Id from Attachment where Name like 'Logo%' AND ParentId = :Opp.O_Agent__r.Id Limit 1];
            if(attachedLogo.size()>0) {
                ImageId = attachedLogo[0].Id;
            }
        }    
        else
        {
              ImageId = 'Logos/OTUK.jpg';   
                
        }
    system.debug('OTUK LogoImageId ' + ImageId); 
    return ImageId;
    } 
    
    //Title and Footer Color
    
   Public  string Color1;
        
     Public string getColor() { 
        
        string recordtype_Name = string.valueof('');
       
      
        if(recordtype_Name == 'OT'){
             Color1= 'rgb(138,207,181)';
        }
        
        else if(recordtype_Name == 'OD'){
            Color1= 'rgb(138,207,181)';
        }
        
         else if(recordtype_Name == 'ST'){
            Color1= '#DF0174';
        }
         
         else if(recordtype_Name == 'OTUK'){
            Color1= 'rgb(138,207,181)';
        }
     return Color1;
    }
      //Title and Footer Color
    
   
    
    //Get Your Guides
    public class YourGuides{
        public List<String> attachmentIds{get; set;}
        public List<Opportunity_Supplier__c> lstGuides{get; set;}
        public YourGuides(){
            lstGuides = new List<Opportunity_Supplier__c>();
            attachmentIds = new List<String>();
        }
    }   
    
    public YourGuides getYourGuides(){
        YourGuides objGuide = new YourGuides();
        Set<Id> supplierIDs = new Set<Id>();
        List<String> attachmentIds = new List<String>();
        
        for(Opportunity_Supplier__c os : [Select Id, OS_Your_Guide__c ,OS_Supplier__c, OS_Supplier__r.Name from Opportunity_Supplier__c where OS_Opportunity__c = :Opp.Id order by Createddate limit 2]){
            objGuide.lstGuides.add(os);
            supplierIDs.add(os.OS_Supplier__c );
        }
        for(Attachment att : [Select Id from Attachment where ParentId in :supplierIDs and Name like '%Your Guide%' limit 2]){
            attachmentIds.add(att.Id);
        } 
        objGuide.attachmentIds.addAll(attachmentIds);  
        return objGuide; 
    }
     
    
     
     // Detailed Itinerary
     
    
   
     Public List<ItineraryDetail> liDetail {get; set;}
    Private Map<String,ItineraryDetail> mapDetail{get; set;} 
    Public List<Supplier_Booking__c> mySupp {get;set;}
    
  Public List<ItineraryDetail> getDetailedItinerary1(){   
    liDetail = new list<ItineraryDetail>();
    mySupp = new List<Supplier_Booking__c>();
    Set<String> processedDate = new Set<String>();
    mySupp = [Select SB_Itinerary_Description__c,SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                        SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                    SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,
                    (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 limit 2 ) 
                                   from Supplier_Booking__c where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In('Car Hire','Rail','Excursion','Transfer','Days at Leisure','Accommodation','Int Flight','Light Aircraft','Dom Flights','Notes','Own arrangement','Description')) AND 
                                    SB_Opportunity__r.Id= :Opp.Id Order by SB_Order__c];
            for(Supplier_Booking__c sSupplier : mySupp){
                if(!processedDate.contains(sSupplier.SB_From_Date__c+'-'+sSupplier.SB_To_Date__c)){
                    processedDate.add(sSupplier.SB_From_Date__c+'-'+sSupplier.SB_To_Date__c);
                    liDetail.add(new ItineraryDetail(new SupplierBookingWrapper (sSupplier, true)));
                }
                else{
                    liDetail.add(new ItineraryDetail(new SupplierBookingWrapper (sSupplier, false)));
                }
            }  
            //System.assert(false,mapDetail);
            for(integer i=0;i<liDetail.size();i++){
                system.debug('from date'+ liDetail[i].Idate);
                system.debug('to date'+ liDetail[i].todate);
            }
            return liDetail; 
    } 

    

   
/* ----------- End of Confirmation Letter ----------------- */ 
   
public class SupplierBookingWrapper {
    public Boolean showDate {get;set;}
    public Supplier_Booking__c  sb{get;set;}
    public SupplierBookingWrapper (Supplier_Booking__c  sb, Boolean showDate){
        this.showDate = showDate;
        this.sb = sb;
    }
}

public class ItineraryDetail
{
    public list<SupplierBookingWrapper> liSupp {get; set;}
    public Date Idate {get; set;}
    public Date todate {get; set;}
    
    public ItineraryDetail(SupplierBookingWrapper sSupp)
    {
        Idate = sSupp.sb.SB_From_Date__c;
        todate = sSupp.sb.SB_To_Date__c;
        if(sSupp.sb.SB_Itinerary_Description__c != null){
            sSupp.sb.SB_Itinerary_Description__c = sSupp.sb.SB_Itinerary_Description__c.replaceAll('&lt;PB/&gt;','<div  layout="block" style="page-break-before:always;"></div>');
        }
        liSupp = new list<SupplierBookingWrapper>{sSupp};
    }
}

    

    
public class WhereYouWillStay
{
    public Supplier_Booking__c sb{get;set;}
    //public Itinerary_Text__c qt{get;set;}
    public string qtMsg {get;set;}
    public WhereYouWillStay(Supplier_Booking__c s, string str ){
        sb = s;
        qtMsg = str;
        
    }
} 

public class countryQuote
{
    public Country__c objCountry{get;set;}
    //public Itinerary_Text__c qt{get;set;}
    public string qtMsg {get;set;}
    public countryQuote(Country__c c, string str ){
        objCountry = c;
        qtMsg = str;
        
    }
}           
    
    


}
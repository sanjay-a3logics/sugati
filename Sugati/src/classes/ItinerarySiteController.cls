public without sharing class ItinerarySiteController{
  
     
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
    public Map<String,String> SICCIdMap{get;set;}
    public List<String> IntroImgsIds{get;set;}
    public Map<String,String> lstRecordTypeIds {get;set;}
    public String mapContainsIds{get; set;}
    public Map<String, Set<String>> mapCountryToRegions {get;set;}
    public Map<String, Set<String>> mapCountryToAccom {get;set;}
    public String accommodationsNames {get;set;}
    public Map<String,String> mapSBToFlightDep  {get;set;}
    public String pageLogo{get; set;}
    public String emailAdd{get; set;}
    public String comment{get; set;}
    public String saveMsg{get; set;}
    public String nameSpacePrefix{get;set;}
    
    
    
    /* -------- Final Document - Tickets and Vouchers (Variables Declaration)----------------- */
     
    Public List<Supplier_Booking__c> lstTV_SBFlights {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBAccomm {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBTransfer {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBLocalArrange {get;set;}
    
    
    /* -------- Final Document - Tickets and Vouchers (End of Variables Declaration)----------------- */
     //For save itinerary PDF page use only
    public void savePDF(){
        try{
            if(oppId != null){
                saveMsg = '';
                Pagereference PDF = Page.ItineraryPDFA5;
                PDF.getParameters().put('id',oppId);
                Attachment att = new Attachment();
                att.parentId = oppId;
                att.body = PDF.getContentAsPDF();
                att.Name = Opp.name+'.pdf';
                insert att;
               
            }
        }
        catch(Exception e){
            saveMsg = e.getMessage();    
        }
    }
    
    
    public void saveComment(){
        try{
            saveMsg = '';
            List<Group_Member__c> lstGm = [Select Id,GM_Contact__r.Name from Group_Member__c where GM_Contact__r.email = :emailAdd 
                                            and GM_Opportunity__c = :oppId];
            if(lstGm.size() > 0 && oppId != null){
                Note msg = new Note();
                msg.parentId = oppId;
                String contributor = lstGm[0].GM_Contact__r.Name;
                msg.title = contributor;
                msg.body = comment;
                insert msg;
                saveMsg = 'Thanks for your comment.';
            }
            else if(lstGm.size() == 0){
                saveMsg = 'You don\'t have the permission to comment on this trip proposal. If you are travelling on this trip, please get in touch with the Sales Consultant so that you can collborate online.';
            }
        }
        Catch(Exception e){
            saveMsg = e.getMessage();   
        }
        
    }
    
    public ItinerarySiteController(Apexpages.standardcontroller controller) {
        try{
            oppId = controller.getId();
            
            ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            
            List<Document> lstDocument = [Select Id from Document where Name = 'Site Page Logo'];
            if(lstDocument.size() > 0){
                pageLogo = lstDocument[0].Id;
            }
            if (controller.getId() != null) {
                Opp = [select id, Name,O_Suggested_Margin__r.M_Margin__c,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                       O_Adult__c,O_Children__c,O_Infant__c,O_Holiday_Type__c, O_Destination_Map_Image_ID__c,O_Map_Type__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Reference_Number__c,O_Due_Date__c,O_No_of_Nights__c,O_Country__c,
                       O_Itinerary_Display_Price__c,O_Total_Payment__c,(select GM_Contact__r.C_Full_Name_on_Passport__c  from Group_Members__r)
                       from Opportunity 
                where Id=:oppId];
               if(opp.O_Map_Type__c == null)
                   opp.O_Map_Type__c = 'Multiple'; 
               Decimal toround = Opp.O_Total_Payment__c;
               roundedPayment = toround.setScale(2);
                
               if(Opp.O_Holiday_Type__c != NULL)
               { 
                   hType=Opp.O_Holiday_Type__c;
               
                HolidayType.add(hType);
                   
               }
                
                 
                
             } 
            
                  
             
            // Display Only Selected category's Content 
              
            mapSelected = new Map<String, Boolean>();
            mapSelectedContentIds= new Map<String, String>();
            LIST<Opportunity> selectedOpp = new List<Opportunity>();
            if(oppId != null){
                selectedOpp =  [Select Id, (Select Id, Name,SICC_Itinerary_Content_Category__r.name from Itinerary_Content_Categories__r
                                 where RecordType.DeveloperName = 'Web') from Opportunity where Id = :oppId ];
            }
            for(Itinerary_Content_Category__c icc : [Select Id, Name from Itinerary_Content_Category__c]){
                mapSelected.put(icc.Name, false);  
                mapContains += ' '+icc.Name;  
            }
            SICCIdMap = new Map<String,String>();
            IntroImgsIds = new List<String>();
            if(selectedOpp.size()> 0){
                for(Selected_Itinerary_Content_Category__c sIc : selectedOpp[0].Itinerary_Content_Categories__r){
                    SICCIdMap.put(sIc.Id,sIc.SICC_Itinerary_Content_Category__r.name);
                }
                /** Getting Images for INTRODUCTION 
                for(Introduction_Image__c at :[select id,name,II_Attachement_Id__c,II_Selected_Itinerary_Content_Category__c  from Introduction_Image__c where 
                                                II_Selected_Itinerary_Content_Category__c in : SICCIdMap.keyset() limit 3]){
                    if(SICCIdMap.get(at.II_Selected_Itinerary_Content_Category__c ) == 'INTRODUCTION'){
                        IntroImgsIds.add(at.II_Attachement_Id__c);
                    }
                }
                 End */   
                
                for(Selected_Itinerary_Content_Category__c sIc : selectedOpp[0].Itinerary_Content_Categories__r){
                    selectedItineraryContent.add(sIc.SICC_Itinerary_Content_Category__r.name); 
                    mapSelected.put(sIc.SICC_Itinerary_Content_Category__r.name, true);
                    mapSelectedContentIds.put(sIc.SICC_Itinerary_Content_Category__r.name, sIc.SICC_Itinerary_Content_Category__c); 
                                  
                }    
            }
    
            lstRecordTypeIds = new Map<String,String>();
            lstRecordTypeIds.put('', '');
            for(RecordType rt : [Select Id, Name from recordTYpe where SObjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c']){
                mapContainsIds += ' '+rt.Id;
                lstRecordTypeIds.put(rt.Id,rt.Name);
            }
            
            WTGMap = new Map<String,Set<String>>();
            mapCountryToRegions = new Map<String,Set<String>>();
            Countrieslst = '';
            CountryListAcc = '';
        }
        Catch(Exception e){
            system.assert(false, e.getStackTraceString()+'****');
             
        }
    }
    
    //Get Travel Designer Details
    public user getUserDet(){
        user currentUser = new User();
        for(User u : [Select Name,Title,FirstName,LastName, SmallPhotoUrl, FullPhotoUrl,Email,U_Image__c,U_Our_Expertise__c,Phone From User where Username =:opp.Owner.Username]){
            currentUser = u;
        }
        return currentUser;
    }    
    
    /** Get Supplier Booking records for Travel Summary */
    public Map<String,Integer> mapDaysFlights{get; set;}
    public Boolean showEticket{get;set;}
    public List<Supplier_Booking__c> getSupplierBookings(){
        List<Supplier_Booking__c> lstSB = new List<Supplier_Booking__c>();
        showEticket = false;
        mapDaysFlights = new Map<String,Integer>();
        for(Supplier_Booking__c sb : SOQlServices.getSupplierBookings(oppId)){
            //## Notes ##//
            if(sb.recordType.Name == 'Int Flight' || sb.recordType.Name == 'Light Aircraft' || sb.recordType.Name == 'Domestic Flight'){
                //if(sb.Show_ETicket__c){
                //    showEticket = true;
               // }
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Carrier__c != null)
                        sb.SB_Notes__c = sb.SB_Carrier__c;
                    if(sb.SB_Flight_No__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Flight_No__c;
                    if(sb.SB_Class__c!= null)
                        sb.SB_Notes__c += ', '+sb.SB_Class__c;    
                }
                if(sb.SB_From_Date__c != null && sb.SB_To_Date__c != null)
                    mapDaysFlights.put(sb.Id,sb.SB_From_Date__c.daysBetween(sb.SB_To_Date__c));
                else
                    mapDaysFlights.put(sb.Id,1);
            }
            else if(sb.recordType.Name == 'Accommodation'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c = sb.SB_Supplier_Name__c;
                    if(sb.SB_Room_Type__c != null)
                        sb.SB_Notes__c  += ', '+sb.SB_Room_Type__c;
                    if(sb.SB_Meal_Basis__c != null)
                        //sb.SB_Notes__c += ', '+sb.SB_Meal_Basis__c;
                    if(sb.SB_Room_Details__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Room_Details__c;    
                }
            }
            else If(sb.recordType.Name == 'Car Hire'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c = sb.SB_Supplier_Name__c;
                    if(sb.SB_Drop_off_Point__c != null)
                        sb.SB_Notes__c  += ', '+sb.SB_Drop_off_Point__c;  
                    if(sb.SB_Pickup_Point__c != null)
                        sb.SB_Notes__c  += ', '+sb.SB_Pickup_Point__c; 
                } 
            }
            else if(sb.recordType.Name == 'Transfer'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Transfer_Car_Hire_Option__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Transfer_Car_Hire_Option__r.Name;    
                }
            }
            else if(sb.recordType.Name =='Rail'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_From_Station__c!= null)
                        sb.SB_Notes__c += ', '+sb.SB_From_Station__c;
                    if(sb.SB_To_Station__c!= null)
                        sb.SB_Notes__c += ', '+sb.SB_To_Station__c;
                }
            }
            else if(sb.recordType.Name =='Bulk Cost'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                }
            }
            else if(sb.recordType.Name == 'Private Road Transfer' || sb.recordType.Name == 'Shared Road Transfer' || sb.recordType.Name == 'Private Transfer with Excursion' || sb.recordType.Name == 'Shared Transfer with Excursion'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Length_of_Journey__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Length_of_Journey__c;
                    if(sb.SB_Ground_Handler__r.Name != null)
                        sb.SB_Notes__c += ', '+sb.SB_Ground_Handler__r.Name;
                    if(sb.SB_Reservation_Ref__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Reservation_Ref__c;
                        
                }
                System.debug(sb.SB_Length_of_Journey__c+'------- '+sb.id+' ------> p '+sb.SB_Notes__c);
            }
            else if(sb.recordType.Name == 'Ferry' || sb.recordType.Name == 'Private Speed Boat Transfer' || sb.recordType.Name == 'Shared Speed Boat Transfer'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Length_of_Journey__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Length_of_Journey__c;
                    if(sb.SB_Reservation_Ref__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Reservation_Ref__c;
                        
                }
                System.debug(sb.SB_Length_of_Journey__c+'------- '+sb.id+' ------> p '+sb.SB_Notes__c);
            }
            else if(sb.recordType.Name == 'Meet & Greet' || sb.recordType.Name == 'VIP Meet & Greet' || sb.recordType.Name == 'Visa Fast Track'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Ground_Handler__r.Name != null)
                        sb.SB_Notes__c += ', '+sb.SB_Ground_Handler__r.Name;
                    if(sb.SB_Reservation_Ref__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Reservation_Ref__c;
                        
                }
                System.debug(sb.SB_Length_of_Journey__c+'------- '+sb.id+' ------> p '+sb.SB_Notes__c);
            }
            else if(sb.recordType.Name == 'Private Jet'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Length_of_Journey__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Length_of_Journey__c;
                    if(sb.SB_Jet_Model__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Jet_Model__c;
                    if(sb.SB_Pilot_Details__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Pilot_Details__c;
                    if(sb.SB_Reservation_Ref__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Reservation_Ref__c;
                        
                }
                System.debug(sb.SB_Length_of_Journey__c+'------- '+sb.id+' ------> p '+sb.SB_Notes__c);
            }
            else if(sb.recordType.Name == 'Sea Plane'){
                if(sb.SB_Notes__c == null){
                    sb.SB_Notes__c = '';
                    if(sb.SB_Supplier_Name__c != null)
                        sb.SB_Notes__c += sb.SB_Supplier_Name__c;
                    if(sb.SB_Reservation_Ref__c != null)
                        sb.SB_Notes__c += ', '+sb.SB_Reservation_Ref__c;
                        
                }
                System.debug(sb.SB_Length_of_Journey__c+'------- '+sb.id+' ------> p '+sb.SB_Notes__c);
            }
            if(sb.recordType.Name != 'Bulk Cost'){
                lstSB.add(sb);
            }
        }
        return lstSB;
    } 
    
    /** END */ 
    
    
    // Get Cover Image 
     
   
    public String getFileId() {
        for(Travelling_Country__c tc : [select TC_ImageID__c,TC_Accommodation_Region__c,TC_Cover_Image__c  from Travelling_Country__c
             where TC_Opportunity__r.Id= :OppId AND TC_Selected__c != NULL AND TC_ImageID__c!= NULL
             Order by TC_Selected__c desc]){
            return tc.TC_ImageID__c;     
        }
        return null;
    }
    
    
    //Content Page
    
    
    Public list <Selected_Itinerary_Content_Category__c> getSelectedItineraryContent(){
            lstSelectedItinerary = new List<Selected_Itinerary_Content_Category__c>();   
            for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_Itinerary_Content_Category__r.Name,ICC_Page_No__c from Selected_Itinerary_Content_Category__c 
                                         where ICC_Opportunity__r.Id=:oppId AND
                                         SICC_Itinerary_Content_Category__r.Name NOT IN ('CONTENT','TICKETS AND VOUCHERS','CONFIRMATION LETTER','CONFIRMATION INVOICE','FINAL DOCS LETTER') 
                                         order by SICC_Itinerary_Content_Category__r.ICC_Order__c]){
                     
                      lstSelectedItinerary.add(l);                      
                             
              }
            return lstSelectedItinerary;
    }
    
    
    // Tailored for you and Holiday Map
    
    Public string getTailorDescription(){
               for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_message__c,
                                                              RecordType.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId AND
                                                        SICC_Itinerary_Content_Category__r.name ='Tailored For You' Limit 1]){
                     
                     if(l.SICC_message__c == null)
                         l.SICC_message__c = '<div style="font-size: 20pt; color: #447198;">WHY BOOK WITH SUGATI?</div> <ul style="margin-left: 40px;"><li>Fully flexible itineraries, made to fit individual requirements</li><li>Specialised and up to date destination knowledge and advice</li><li>Competitive pricing – we should be no more expensive than booking direct</li><li>Financial protection through River of Footsteps travel agency licenses</li><li>Global contracts with hotels and suppliers to ensure the best access for our guests</li><li>A concierge approach to travel with pre-booked restaurants, spa treatments and activity recommendations</li><li>24/7 emergency contact, so should anything arise, we will be on hand to assist you at any time</li></ul>';    
                     tailordesc = l.SICC_message__c;                      
                             
              }
        
        return tailordesc;
    }
    
    // Tailored for you and Holiday Map
    
    Public string getTailorDescription1(){
               for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_message1__c,
                                                              RecordType.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId AND
                                                        SICC_Itinerary_Content_Category__r.name ='Tailored For You' Limit 1]){
                     
                   
                     tailordesc1 = l.SICC_message1__c;                      
                             
              }
        system.debug('tailordesc  '+ tailordesc1);
        return tailordesc1;
    }
    
    
    
    Public List<Travelling_Country__c> getTravellingCountry(){
      lstTravelCountry = new List<Travelling_Country__c>();
      for(Travelling_Country__c tc: [select Name,TC_Country__r.name,TC_Country__r.C_Notes__c from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
        
      lstTravelCountry.add(tc);
      
      }
      /*for(integer i=0;i<lstTravelCountry.size();i++)
      system.debug(lstTravelCountry[i].TC_Country__r.name);*/
    return lstTravelCountry;
      
    }
    
     
     Public Map<string,Supplier_Booking__c> MapCountry{get;set;}
    Public List<string> lstCstr{get;set;}
    
     /*Public List<Country__c> getCountry(){
      lstCstr = new List<string>();   
     lstCountry = new List<Country__c>();
     MapCountry= new Map<string, Supplier_Booking__c>();
      string Tcountry ='';
       Integer  Count_Tcountry;
         AggregateResult[] aggr_tcountry = [select COUNT(Name) noOfCountry from Travelling_Country__c];
       
         for(AggregateResult sobj : aggr_tcountry)
        {   
             Count_Tcountry = Integer.valueOf(sobj.get('noOfCountry'));
        }
         
       
         
       //  system.debug('Count_Tcountry' +Count_Tcountry);
         
         if(Count_Tcountry ==1)  { 
     for(Travelling_Country__c t: [select Name,TC_Country__r.name,TC_Country__r.Id,CreatedDate
                      from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId order by CreatedDate]){
                               
                   Tcountry =   t.TC_Country__r.name;        
      for(Country__c c: [select Name,C_Notes__c, (select Id from Attachments where Name like:likeclause Limit 1 )
                 from Country__c
                       where Name= :Tcountry]){
        
      lstCountry.add(c);
      
                       }}
         }

         else if (Count_Tcountry >1){  
     for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ASC]) {

                                Boolean b= MapCountry.containsKey(s.SB_Where_to_go__r.W_Country__r.Name);
                            
                                if(b == false)
                                {
                                MapCountry.put(s.SB_Where_to_go__r.W_Country__r.Name,s);
                                string CName = s.SB_Where_to_go__r.W_Country__r.Name;
                                    
                                for(Country__c c: [select Name,C_Notes__c, (select Id from Attachments where Name like:likeclause Limit 1 )
                                from Country__c
                                where Name = :CName]){
        
                                  lstCountry.add(c);
                                 
                                }
                                }
                                    }  } 
                              
    
          return lstCountry;
      
    }
    */
    
  Public String likestr = 'Map';
  Public String likeclause = '%'+likestr+'%';
    
       
 Public List<string> lstTCountry {get;set;}
 Public Map<string,string> mapIT_TCmsg {get;set;} 
 Public Map<string,boolean> mapIT_Check {get;set;}   
 Public List<Travelling_Country__c>  lstT {get;set;}
 Public List<countryQuote> lstCountryQuote {get;set;}
 Public Map<String,Set<String>> WTGMap {get;set;}
 public String Countrieslst {get;set;}
 public String CountryListAcc {get;set;}
 Public List<countryQuote> getCountryQuote(){
     
            lstTCountry = new List<String>();
            lstCountryQuote = new List<countryQuote>();
            lstT = new List<Travelling_Country__c>();
            mapIT_TCmsg = new MAP<string,string>();
            mapIT_Check = new MAP<string,boolean>();
            WTGMap = new Map<String,Set<String>>();
            mapCountryToAccom = new Map<String,Set<String>>();
            Countrieslst = '';
            CountryListAcc = '';
            
            List<String> lstOfCountries = new  List<String>();
            Set<String> setOfCountries = new  Set<String>();
            for(Supplier_Booking__c sb : [Select id, SB_What_to_do__r.WH_Country__c, SB_Supplier__c, SB_Supplier__r.Name, SB_Supplier__r.S_Type__c, SB_Supplier__r.S_Country__c, SB_Supplier__r.S_Where_to_go__r.W_Country__c, SB_Where_to_go__c,SB_Where_to_go__r.W_Country__c,SB_Where_to_go__r.W_Country__r.name,SB_Where_to_go__r.name from
                                          Supplier_Booking__c where SB_Opportunity__c = :opp.Id 
                              order by SB_Order__c]){
                                  /** List of selected where to go for travelling country*/
                                  if((sb.SB_Where_to_go__r.W_Country__r.name != null && sb.SB_Where_to_go__r.W_Country__r.name != '') && (sb.SB_Where_to_go__r.name != null && sb.SB_Where_to_go__r.name != '')){
                                      
                                      if(!WTGMap.containsKey(sb.SB_Where_to_go__r.W_Country__r.name)){
                                          WTGMap.put(sb.SB_Where_to_go__r.W_Country__r.name,new Set<String>());
                                      }
                                      
                                      Set<String> lstWTG = WTGMap.get(sb.SB_Where_to_go__r.W_Country__r.name);
                                      lstWTG.add(sb.SB_Where_to_go__r.name);
                                      WTGMap.put(sb.SB_Where_to_go__r.W_Country__r.name,lstWTG);
                                      Countrieslst += sb.SB_Where_to_go__r.W_Country__r.name+'  ';
                                  }
                                  
                                  /** List of selected accommodation for travelling country*/
                                  if((sb.SB_Supplier__c != null && sb.SB_Supplier__r.name != '') && (sb.SB_Supplier__r.S_Country__c != null && sb.SB_Supplier__r.S_Type__c == 'Hotel')){
                                      if(!mapCountryToAccom.containsKey(sb.SB_Supplier__r.S_Country__c)){
                                          mapCountryToAccom.put(sb.SB_Supplier__r.S_Country__c, new Set<String>());
                                      }
                                      mapCountryToAccom.get(sb.SB_Supplier__r.S_Country__c).add(sb.SB_Supplier__r.name);
                                      CountryListAcc += sb.SB_Supplier__r.S_Country__c +'  ';
                                  }
                                  /** */
                                  
                                  if(!setOfCountries.contains(sb.SB_Where_to_go__r.W_Country__c) && sb.SB_Where_to_go__r.W_Country__c != null){                              
                                    lstOfCountries.add(sb.SB_Where_to_go__r.W_Country__c);
                                      setOfCountries.add(sb.SB_Where_to_go__r.W_Country__c);
                                      }
                                  else if(!setOfCountries.contains(sb.SB_What_to_do__r.WH_Country__c) && sb.SB_What_to_do__r.WH_Country__c != null){                              
                                    lstOfCountries.add(sb.SB_What_to_do__r.WH_Country__c);
                                          setOfCountries.add(sb.SB_What_to_do__r.WH_Country__c);
                                          }
                                      else if(!setOfCountries.contains(sb.SB_Supplier__r.S_Where_to_go__r.W_Country__c) && sb.SB_Supplier__r.S_Where_to_go__r.W_Country__c != null){                              
                                    lstOfCountries.add(sb.SB_Supplier__r.S_Where_to_go__r.W_Country__c);
                                      setOfCountries.add(sb.SB_Supplier__r.S_Where_to_go__r.W_Country__c);
                                      }
            }
            //system.assert(false,WTGMap);
            Map<String,Travelling_Country__c> mapTravellingCountry = new Map<String,Travelling_Country__c>();
            for(Travelling_Country__c tc: [select Name,TC_Country__c,TC_DestinationMap_Image_ID__c,TC_Accommodation_Region__c ,TC_Country__r.name,TC_Country__r.C_Notes__c from Travelling_Country__c
                                           where TC_Opportunity__r.Id= :opp.Id
                                           Order By CreatedDate]){
                                               mapTravellingCountry.put(tc.TC_Country__c, tc);    
            }
            for(String str : lstOfCountries){
                if(mapTravellingCountry.containsKey(str)){
                    lstTCountry.add(mapTravellingCountry.get(str).TC_Country__r.Name);
                    lstT.add(mapTravellingCountry.get(str));
                }
             }
            for(Itinerary_Text__c qt: [select IT_Message__c,IT_Holiday_Type__c,IT_Holiday_Type__r.Name,IT_Country__r.Name,IT_Country__c
                                    from Itinerary_Text__c
                                    where IT_Holiday_Type__c In :HolidayType 
                                    AND
                                    IT_Country__r.Name In :lstTCountry]){
                                      
                                                mapIT_Check.put(qt.IT_Country__c,TRUE);
                                                mapIT_TCmsg.put(qt.IT_Country__c,qt.IT_Message__c); 
                                         }  
     
       for(Itinerary_Text__c qt: [select IT_Message__c,IT_Holiday_Type__c,IT_Holiday_Type__r.Name,IT_Country__r.Name,IT_Country__c
                                from Itinerary_Text__c where (IT_Holiday_Type__c NOT IN :HolidayType AND IT_Holiday_Type__r.Name='Generic') AND
                                IT_Country__r.Name In :lstTCountry]){
            if(!mapIT_check.containsKey(qt.IT_Country__c)){
                   mapIT_TCmsg.put(qt.IT_Country__c,qt.IT_Message__c); 
            } 
        } 
        Set<String> tcIds = new Set<String>();
        for(Travelling_Country__c tc : lstT){
            if(!tcIds.contains(tc.TC_Country__c)){ 
                for(Country__c c: [select Name,C_Notes__c,C_Archive__c, (select Id from Attachments where Name like :likeclause Limit 1 )
                                    from Country__c where Name = :tc.TC_Country__r.Name  AND C_Archive__c = False limit 1]) {                   
                    countryQuote cq = new countryQuote(c,mapIT_TCmsg.get(tc.TC_Country__c));
                    if(tc.TC_DestinationMap_Image_ID__c == null &&  c.Attachments.size() > 0 ){
                        cq.imageId = c.Attachments[0].Id;
                    }
                    else if(tc.TC_DestinationMap_Image_ID__c != null){
                        cq.imageId = tc.TC_DestinationMap_Image_ID__c;
                    }
                    if(tc.TC_Accommodation_Region__c != null)
                        cq.accommodationRegion = tc.TC_Accommodation_Region__c;
                    else
                        cq.accommodationRegion = 'Region';
                    lstCountryQuote.add(cq);
                    //mapCountryToRegions.put(c.id, new Set<String>());
                    
                }  
            }  
        }  
        //ystem.assert(false,lstCountryQuote);
        return lstCountryQuote;
           
    } 
     
    
// Unforgettable Experience


   /* Public string getItineraryContentDescription(){
        String strDescription ='';
        list <Itinerary_Content__c> lstDes = new List<Itinerary_Content__c>();
        
        lstDes= [select Id, IC_Description__c from Itinerary_Content__c where IC_Itinerary_Content_Category__r.Name = 'UNFORGETTABLE EXPERIENCES'];
        strDescription = string.valueof(lstDes[0].IC_Description__c);    
        
        return strDescription;
     }
    
    Public list <Attachment> getItineraryContentAttachement(){
      list <Attachment> lstAttachments = new List<Attachment>();  
      list <Itinerary_Content__c> lsttemp = new List<Itinerary_Content__c>();
        
        lsttemp= [select Id from Itinerary_Content__c where IC_Itinerary_Content_Category__r.Name = 'UNFORGETTABLE EXPERIENCES'];
        
        
     lstAttachments = [SELECT Id FROM Attachment where ParentId = :lsttemp[0].id];
           
        
        return  lstAttachments;
    }*/
    
    
    
    
    // Holiday Map 
    
    /*public string getMapId() {
      
      string MapId = '';
      attachedMap = [select Id from Attachment where Name ='Map.png' 
                AND ParentId = :lstTravelCountry[0].TC_Country__r.id];
           if(attachedMap.size()>0) {
             
          MapId = attachedMap[0].Id;
       }
       
       return MapId;
    }
         
    Public List<Attachment> getMapId(){
       String AId ='';
       List<Attachment> attachedMap1 = new List<Attachment>();
       
      
       
      for(Travelling_Country__c t: [select Name,TC_Country__r.name,TC_Country__r.Id 
                      from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
        
      AId = String.valueof(t.TC_Country__r.Id);
      
      attachedMap = [select Id from Attachment where Name ='Map.png' 
                AND ParentId = :AId];
                
                attachedMap1.addall(attachedMap);  
   
             } 
           return attachedMap1;
           }
      
   */
     
 // What It Cost
      Public string getBcurrency(){
     
     string b = '';
          
     list <Opportunity> OpAmount = new List<Opportunity>();
     OpAmount= [select O_Booking_Currency__c from Opportunity where id= :oppId];
     b=string.valueof(OpAmount[0].O_Booking_Currency__c);
         
     return b;
     }
    
     Public Decimal getAmount(){
     
     Decimal a = 0;
          
     list <Opportunity> OpAmount = new List<Opportunity>();
     OpAmount= [select Amount from Opportunity where id= :oppId];
     a=Integer.valueof(OpAmount[0].Amount);
         
     return a;
     }
    
     Public string getCostDescription(){
               for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_message__c,
                                                              RecordType.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId AND
                                                        SICC_Itinerary_Content_Category__r.name ='What It Costs' Limit 1]){
                     
                   
                     WhatCostdesc = l.SICC_message__c;   
                                     
                             
              }
        system.debug('tailordesc  '+ WhatCostdesc);
        
        return WhatCostdesc;
        
    }
    
     
     Public List <Itinerary_Content__c>  getItineraryContentWhatItCost(){
       
        list <Itinerary_Content__c> lstCost = new List<Itinerary_Content__c>();
        
        lstCost = [select  IC_Description__c,IC_Title__c,IC_Order__c from Itinerary_Content__c 
        where IC_Itinerary_Content_Category__r.Name = 'QUOTATION' 
                   order by IC_Order__c];
        
         return lstCost;
     }
    
    
    Public integer countWC=0;
    public integer countWCR;
    Public integer getWCount(){
        
        
       countWC=countWC+1;
        countWCR = math.mod(countWC, 3);
        return countWCR;
      
            }
    
    
    // Please Don't Forget 
    Public Set <string> Forget_TravelCountry {get;set;}
    
     Public List <Itinerary_Content__c>  getItineraryContentPleaseDontForget(){
    
        list <Itinerary_Content__c> lstForget = new List<Itinerary_Content__c>();
        list <Itinerary_Content__c> lstForget1 = new List<Itinerary_Content__c>();
        set <string>travelcountry = new set<string>();
      // set <string>Forget_TravelCountry = new set<string>(); 
        String lstTravelC ='';
        
     for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
    
              travelcountry.add(t.TC_Country__r.name);                   
                             }
         
         
     /*   for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Domestic Flight','Days at Leisure')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ASC]) {
                                        
                                        
                                        Forget_TravelCountry.add(s.SB_Where_to_go__r.W_Country__r.Name);
                                        
                                    } */
      
        
        lstForget = [select IC_Title__c,IC_Description__c,IC_New_Page__c,IC_Itinerary__c,(select Id from Attachments limit 1)
                     from Itinerary_Content__c 
                     where IC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                    AND ((IC_Country__r.Name in :travelCountry)OR (IC_Country__r.Name = ''))
                    // AND  RecordType.name =:Opp.RecordType.name
                     AND IC_Itinerary__c = TRUE
                     order by IC_Order__c];
             lstForget1.addall(lstForget);        
        
        
         
         
         return lstForget1;
     }




  //User Expertise
  
        Public List <User> getUserExpertise(){
           List <User> lstExpertise = new List<User>(); 
        
           lstExpertise = [select U_Our_Expertise__c,Username,Name,Email,U_Field_1__c,U_Field_2__c,U_Field_3__c,U_Field_4__c,U_Field_5__c,U_Field_6__c ,U_Field_7__c,
                                U_Field_Title_1__c,U_Field_Title_2__c,U_Field_Title_3__c,U_Field_Title_4__c,U_Field_Title_5__c,U_Field_Title_6__c,U_Field_Title_7__c
                           from User where Username =:opp.Owner.Username];
           
           return lstExpertise;
        }
    
    public string getUserPhoto(){
        User p = [Select Name, SmallPhotoUrl, FullPhotoUrl,Email,U_Image__c From User where Username =:opp.Owner.Username];
        return p.U_Image__c;
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
    
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Itinerary_Description__c,SB_Supplier__c,SB_Order__c, (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r  where (SBI_Order__c = 3 or SBI_Order__c = 4) order by SBI_Order__c limit 2) 
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ]){
              if ( s.SB_Supplier__c != NULL) {                           
                  mapOldSBIds.put(s.SB_Supplier__c, s);
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
                                    where (IT_Holiday_Type__c In :HolidayType)
                                    AND IT_SUPPLIER__C in :lstSBSuppIds  order by IT_SUPPLIER__C desc]){
                               
                              mapIT_Check1.put(qt.IT_SUPPLIER__C,TRUE);    
                              mapQT.put(qt.IT_Supplier__c,qt);
                              mapQTmsg.put(qt.IT_Supplier__c,qt.IT_Message__c);                                        
                               // lstWhereStay.add(new WhereYouWillStay(mapOldSBIds.get(qt.IT_SUPPLIER__C),qt.IT_Message__c));            
           }    
    
     for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                    from Itinerary_Text__c
                                    where  (IT_Holiday_Type__c NOT IN :HolidayType  
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
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
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c         
                                From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id AND 
                                RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
                                Order by SB_Order__c])
        {
            //,
            //                    (select FB_Group_Member__c,FB_Group_Member__r.GM_Contact__r.TitleOnPP__c, FB_Group_Member__r.GM_Contact__r.FirstNameOnPP__c, FB_Group_Member__r.GM_Contact__r.LastNameOnPP__c
            //                     from Flight_Bookings1__r)
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight')
                                    Order by SB_Order__c]){
                                        
             mapSBIds.put(s.Id, s);
           }  
    
    
    // system.debug('size of mapSBIds'+mapSBIds.size());
    /*
    for(Flight_Booking__c fb: [select FB_Group_Member__c
                               from Flight_Booking__c
                               where FB_Supplier_Booking__c in :mapSBIds.keySet() ]){
                                            
                          setFlight.add(fb.FB_Group_Member__c);        
            
                       }  
    */                   
    // system.debug('size of setFlight'+setFlight.size());
    
    for(Group_Member__c gm:[select Id,GM_Contact__c,GM_Contact__r.C_Full_Name_on_Passport__c   from Group_Member__c
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
        
        string recordtype_Name = '';//string.valueof(Opp.RecordType.name);
       
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
     Public String likeclause1 = '%'+likestr+'%';
    
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
    
   Public  string Colorr;
        
     Public string getColorr() { 
        
        string recordtype_Name = '';//string.valueof(Opp.RecordType.name);
       
      
        if(recordtype_Name == 'OT'){
             Colorr = 'rgb(138,207,181)';
        }
        
        else if(recordtype_Name == 'OD'){
            Colorr = 'rgb(138,207,181)';
        }
        
         else if(recordtype_Name == 'ST'){
            Colorr = '#DF0174';
        }
         
         else if(recordtype_Name == 'OTUK'){
            Colorr = 'rgb(138,207,181)';
        }
        
                         
      
     return Colorr;
    }
      //Title and Footer Color
    
   Public  string Color;
        
     Public string getColor() { 
        
        string recordtype_Name = '';//string.valueof(Opp.RecordType.name);
       
      
        if(recordtype_Name == 'OT'){
             Color = 'rgb(138,207,181)';
        }
        
        else if(recordtype_Name == 'OD'){
            Colorr = 'rgb(138,207,181)';
        }
        
         else if(recordtype_Name == 'ST'){
            Color = '#DF0174';
        }
         
         else if(recordtype_Name == 'OTUK'){
            Color = 'rgb(138,207,181)';
        }
  
     return Color;
    }
    
    //Get Your Guides
    /*
    public class YourGuides{
        public List<String> attachmentIds{get; set;}
        public List<Opportunity_Supplier__c> lstGuides{get; set;}
        public YourGuides(){
            lstGuides = new List<Opportunity_Supplier__c>();
            attachmentIds = new List<String>();
        }
    }   
    */
    /*
    public YourGuides getYourGuides(){
        //YourGuides objGuide = new YourGuides();
        
        Set<Id> supplierIDs = new Set<Id>();
        List<String> attachmentIds = new List<String>();
        
        for(Opportunity_Supplier__c os : [Select Id, OS_Your_Guide__c ,OS_Supplier__c from Opportunity_Supplier__c where OS_Opportunity__c = :Opp.Id order by Createddate limit 2]){
            objGuide.lstGuides.add(os);
            supplierIDs.add(os.OS_Supplier__c );
        }
        for(Attachment att : [Select Id from Attachment where ParentId in :supplierIDs and Name like '%Your Guide%' limit 2]){
            attachmentIds.add(att.Id);
        } 
        objGuide.attachmentIds.addAll(attachmentIds); 
        return objGuide; 
    }
    */ 
    
     Map<String,Supplier_Booking__c> mapAccSB = new Map<String,Supplier_Booking__c>();
     
     /*
     public Map<Decimal,List<Supplier_Booking__c>> getSBookings(){
        Decimal countIt = 0;
        mapSBToFlightDep = new Map<String, String>();
        try{
            List<DetailItinerary> lstDI = new List<DetailItinerary>();
            mySupp = new List<Supplier_Booking__c>();
            Map<Decimal,List<Supplier_Booking__c>> SBlst = new Map<Decimal,List<Supplier_Booking__c>>();
            
            mySupp = [Select SB_Itinerary_Description__c,SB_Supplier__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                     SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                     SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,SB_Where_to_go__r.name,SB_Transfer_Car_Hire_Option__r.name,SB_What_to_do__r.name,
                     SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,SB_To_Place__c,SB_Booking_Status__c, 
                     (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 order by SBI_Order__c limit 2 ) 
                       from Supplier_Booking__c
                        where RecordTypeId in (SELECT Id FROM RecordType where recordtype.name != 'Bulk Cost') AND 
                        SB_Opportunity__r.Id= :Opp.Id 
                        
                        Order by SB_Day__c,SB_order__c];
            
            for(Supplier_Booking__c SB : mySupp){
                if(SB.SB_New_Page__c){
                    countIt++;
                    SBlst.put(countIt,new List<Supplier_Booking__c>());
                }
                List<Supplier_Booking__c> SBList= SBlst.get(countIt);
                SBList.add(SB);
                SBlst.put(countIt,SBList);    
                
                if(sb.recordtype.name == 'Accommodation'){
                    mapAccSB.put(sb.Id,sb);
                }
                mapSBToFlightDep.put(sb.id, '');
                if(sb.SB_From_date__c != null && sb.SB_To_Date__c != null){
                    if(sb.SB_To_Date__c > sb.SB_From_date__c)
                        mapSBToFlightDep.put(sb.id, '+1');
                }
            }
            return SBlst;
        }
        Catch(Exception e){
             return null;
        }
       
     }
     */
     public List<SupplierBookingsWrapper> getSBookings(){
        Decimal countIt = 0;
        mapSBToFlightDep = new Map<String, String>();
        try{
            List<DetailItinerary> lstDI = new List<DetailItinerary>();
            mySupp = new List<Supplier_Booking__c>();
            Map<Decimal,List<Supplier_Booking__c>> SBlst = new Map<Decimal,List<Supplier_Booking__c>>();
            
            mySupp = [Select SB_Itinerary_Description__c,SB_Supplier__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                     SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                     SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,SB_Where_to_go__r.name,SB_Transfer_Car_Hire_Option__r.name,SB_What_to_do__r.name,
                     SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,SB_To_Place__c,SB_Booking_Status__c, 
                     (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 order by SBI_Order__c limit 2 ) 
                       from Supplier_Booking__c
                        where RecordTypeId in (SELECT Id FROM RecordType where recordtype.name != 'Bulk Cost') AND 
                        SB_Opportunity__r.Id= :Opp.Id 
                        
                        Order by SB_Day__c,SB_order__c];
            
            for(Supplier_Booking__c SB : mySupp){
                if(SB.SB_New_Page__c){
                    countIt++;
                    SBlst.put(countIt,new List<Supplier_Booking__c>());
                }
                List<Supplier_Booking__c> SBList= SBlst.get(countIt);
                SBList.add(SB);
                SBlst.put(countIt,SBList);    
                
                if(sb.recordtype.name == 'Accommodation'){
                    mapAccSB.put(sb.Id,sb);
                }
                mapSBToFlightDep.put(sb.id, '');
                if(sb.SB_From_date__c != null && sb.SB_To_Date__c != null){
                    if(sb.SB_To_Date__c > sb.SB_From_date__c)
                        mapSBToFlightDep.put(sb.id, '+1');
                }
            }
            //return SBlst;
            List<SupplierBookingsWrapper> bookings = new List<SupplierBookingsWrapper>();
            for(Decimal count : SBlst.keySet()){
                bookings.add(new SupplierBookingsWrapper(count, SBlst.get(count)));        
            }
            return bookings;
        }
        
        Catch(Exception e){
             return null;
        }
       
     }
     
     public class SupplierBookingsWrapper{
         public Decimal totalCount {get;set;}
         public List<Supplier_Booking__c> lstSupplierBookings {get;set;} 
         public SupplierBookingsWrapper(){
             totalCount = 0;
             lstSupplierBookings = new List<Supplier_Booking__c>();
         }  
         public SupplierBookingsWrapper(Decimal count, List<Supplier_Booking__c> sb){
             totalCount = count;
             lstSupplierBookings = sb;
         }   
     }
     
     
     // Detailed Itinerary
     
     public Map<Decimal,List<Supplier_Booking__c>> getIDetails(){
        List<DetailItinerary> lstDI = new List<DetailItinerary>();
        mySupp = new List<Supplier_Booking__c>();
        Map<Decimal,List<Supplier_Booking__c>> SBlst = new Map<Decimal,List<Supplier_Booking__c>>();
        mySupp = [Select SB_Itinerary_Description__c,SB_Supplier__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                 SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                 SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,SB_Where_to_go__r.name,SB_Transfer_Car_Hire_Option__r.name,SB_What_to_do__r.name,
                 SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,SB_To_Place__c,SB_Booking_Status__c, 
                 (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 order by SBI_Order__c limit 2 ) 
                   from Supplier_Booking__c
                    where RecordTypeId in (SELECT Id FROM RecordType where recordtype.name != 'Bulk Cost') AND 
                    SB_Opportunity__r.Id= :Opp.Id 
                    
                    Order by SB_Day__c,SB_order__c];
        for(Supplier_Booking__c SB : mySupp){
            if(!SBlst.containsKey(SB.SB_Day__c)){
                SBlst.put(SB.SB_Day__c,new List<Supplier_Booking__c>());
            }
            if(sb.recordtype.name == 'Accommodation'){
                mapAccSB.put(sb.Id,sb);
            }
            List<Supplier_Booking__c> SBList= SBlst.get(SB.SB_Day__c);
            SBList.add(SB);
            SBlst.put(SB.SB_Day__c,SBList);
        }
        return SBlst;
     }
    
    public String containsCheck{get; set;}
    public Map<String,Itinerary_Text__c> getSBQuote(){
        containsCheck = '';
        Map<String,Itinerary_Text__c> mapQuoteText = new Map<String,Itinerary_Text__c>();
        if(mapAccSB.size() > 0){
            List<String> lstSuppliers = new List<String>();
            for(Supplier_Booking__c sb  : mapAccSB.Values()){
                if(sb.SB_Supplier__c != null){
                    lstSuppliers.add(sb.SB_Supplier__c);
                    mapQuoteText.put(sb.Id,new Itinerary_Text__c()); 
                }
                else{
                    mapQuoteText.put(sb.Id,new Itinerary_Text__c()); 
                }
            }
            for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                  from Itinerary_Text__c where (IT_Holiday_Type__r.Name='Generic' or IT_Holiday_Type__c = :opp.O_Holiday_Type__c) AND IT_SUPPLIER__C in :lstSuppliers
                                  order by IT_SUPPLIER__C desc ]){
                for(Supplier_Booking__c sb  : mapAccSB.Values()){
                    containsCheck = sb.SB_Supplier__c+',';
                    if(sb.SB_Supplier__c == qt.IT_SUPPLIER__C){
                        mapQuoteText.put(sb.Id,qt); 
                    }
                }
            }
        }
        return mapQuoteText;
    }
    
    public class DetailItinerary{
        public List<Supplier_Booking__c> lstSB{get;set;}
        public DetailItinerary(){
            lstSB = new List<Supplier_Booking__c>();
        }
    }
    
    Public List<ItineraryDetail> liDetail {get; set;}
    Private Map<date,ItineraryDetail> mapDetail{get; set;} 
    Public List<Supplier_Booking__c> mySupp {get;set;}
    
    Public List<ItineraryDetail> getDetailedItinerary1(){   
        getIDetails();
        mapDetail = new map<date,ItineraryDetail>();
        liDetail = new list<ItineraryDetail>();
        mySupp = new List<Supplier_Booking__c>();

        mySupp = [Select SB_Itinerary_Description__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                                SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                            SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,
                                        SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,
                            (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 order by SBI_Order__c limit 2 ) 
                                           from Supplier_Booking__c
                                            where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In('Car Hire','Rail','Excursion','Transfer','Days at Leisure','Accommodation','Int Flight','Light Aircraft','Domestic Flight','Notes','Own arrangement','Description')) AND 
                                            SB_Opportunity__r.Id= :Opp.Id 
                                            
                                            Order by SB_Day__c];


        for(Supplier_Booking__c sSupplier : mySupp )
        {
            if(mapDetail.get(sSupplier.SB_From_Date__c) == null)
            {
                //mapDetail.put(sSupplier.SB_From_Date__c, new ItineraryDetail(sSupplier));
                mapDetail.put(sSupplier.SB_From_Date__c, new ItineraryDetail(new SupplierBookingWrapper (sSupplier, true)));
                liDetail.add(mapDetail.get(sSupplier.SB_From_Date__c));
            }
            else
            {
                mapDetail.get(sSupplier.SB_From_Date__c).liSupp.add(new SupplierBookingWrapper (sSupplier, false));
            }
        }  
      
        for(integer i=0;i<liDetail.size();i++){
          system.debug('from date'+ liDetail[i].Idate);
          system.debug('to date'+ liDetail[i].todate);
        }
        return liDetail; 
    } 

    
/* ---------------- Final Documents - Tickets and Vouchers ---------------------- */
    
    Public List<Supplier_Booking__c> getTicketsVouchers_Flights(){
        
        lstTV_SBFlights = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Flight_Ref__c,SB_Flight_No__c,SB_Departure_Airport_l__r.Name,SB_Arrival_Airport_l__r.Name,SB_From_Date__c,SB_Departure_Time__c,SB_From_Time__c,SB_Notes__c,RecordType.Name,
                                    SB_To_Date__c,SB_To_Time__c,SB_Class__c,SB_Check_In_Time__c,SB_Supplier__r.Name,SB_Carrier__c,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight') AND
                                    SB_Own_Arrangement__c = FALSE
                                    Order by SB_Order__c]){
                                    //,
                                    //(select FB_Group_Member__r.GM_Contact__r.TitleOnPP__c, FB_Group_Member__r.GM_Contact__r.FirstNameOnPP__c, FB_Group_Member__r.GM_Contact__r.LastNameOnPP__c
                                    // from Flight_Bookings1__r)    
                                        lstTV_SBFlights.add(s);
                                    }
        return lstTV_SBFlights;
    }
    
    
    Public List<Supplier_Booking__c> getTicketsVouchers_Accomm(){
        
        lstTV_SBAccomm = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Supplier__r.Name,SB_Ground_Handler__r.S_Emergency_Phone__c, SB_From_Date__c,SB_To_Date__c,SB_Room_Type__c,SB_Meal_Basis__c,
                                    SB_Supplier__r.S_Street__c,SB_Supplier__r.S_City__c,SB_Supplier__r.S_State__c,SB_Supplier__r.S_Country__c,
                                    SB_Supplier__r.S_Postcode__c,SB_Supplier__r.S_Phone__c,SB_Night__c,SB_From_Time__c,SB_Payment_Type__c,SB_Booking_No__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Ground_Handler__c,SB_Ground_Handler__r.Name
                                   From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Accommodation')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBAccomm.add(s);
                                    }
        return lstTV_SBAccomm;
    }
    
    
     Public List<Supplier_Booking__c> getTicketsVouchers_Transfer(){
        
       lstTV_SBTransfer = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_From_Place__c,SB_To_Place__c,SB_From_Date__c,SB_To_Date__c,SB_Pickup_Point__c,SB_Itinerary_Description__c,
                                    SB_Supplier__r.S_Phone__c,SB_From_Time__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.Name,SB_Ground_Handler__r.Name
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Transfer')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBTransfer.add(s);
                                    }
         system.debug('size transfer '+lstTV_SBTransfer.size());
        return lstTV_SBTransfer;
    }
    
  
     Public List<Supplier_Booking__c> getTicketsVouchers_LocalArrange(){
        
        lstTV_SBLocalArrange = new List<Supplier_Booking__c>();
    
        for(Supplier_Booking__c s :[select SB_From_Date__c,SB_Local_Arrangements_Content__c,SB_To_Date__c,SB_Supplier__r.S_Phone__c,SB_Supplier__r.Name,SB_Name__c,SB_Payment_Type__c,SB_Supplier__r.S_Emergency_Phone__c 
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Excursion')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBLocalArrange.add(s);
                                    }
       
        return lstTV_SBLocalArrange;
    }
    
    Public Integer getCount_TVFlights(){
        
        lstTV_SBFlights = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Flight_Ref__c,SB_Flight_No__c,SB_Departure_Airport_l__r.Name,SB_Arrival_Airport_l__r.Name,SB_From_Date__c,SB_Departure_Time__c,SB_Notes__c,RecordType.Name,
                                    SB_To_Date__c,SB_To_Time__c,SB_Class__c,SB_Check_In_Time__c,SB_Supplier__r.Name,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Int Flight','Light Aircraft','Domestic Flight') AND
                                    SB_Own_Arrangement__c = FALSE
                                    Order by SB_Order__c]){
                                        //,
                                        //(select FB_Group_Member__r.GM_Contact__r.TitleOnPP__c, FB_Group_Member__r.GM_Contact__r.FirstNameOnPP__c, FB_Group_Member__r.GM_Contact__r.LastNameOnPP__c
                                        //from Flight_Bookings1__r)   
                                        lstTV_SBFlights.add(s);
                                    }
        return lstTV_SBFlights.size();
    }
    
     Public Integer getCount_TVAccomm(){
        
        lstTV_SBAccomm = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Supplier__r.Name,SB_From_Date__c,SB_To_Date__c,SB_Room_Type__c,SB_Meal_Basis__c,
                                    SB_Supplier__r.S_Street__c,SB_Supplier__r.S_City__c,SB_Supplier__r.S_State__c,SB_Supplier__r.S_Country__c,SB_Payment_Type__c,
                                    SB_Supplier__r.S_Postcode__c,SB_Supplier__r.S_Phone__c,SB_Night__c,SB_Booking_No__c 
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Accommodation')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBAccomm.add(s);
                                    }
        return lstTV_SBAccomm.size();
    }
    
    
     Public Integer getCount_TVTransfer(){
        
       lstTV_SBTransfer = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select  SB_From_Place__c,SB_To_Place__c,SB_From_Date__c,SB_To_Date__c,SB_Pickup_Point__c,SB_Itinerary_Description__c,
                                    SB_Supplier__r.S_Phone__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.Name
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Transfer')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBTransfer.add(s);
                                    }
        return lstTV_SBTransfer.size();
    }
    
  
     Public Integer getCount_TVLocalArrange(){
        
        lstTV_SBLocalArrange = new List<Supplier_Booking__c>();
    
        for(Supplier_Booking__c s :[select SB_From_Date__c,SB_To_Date__c,SB_Supplier__r.S_Phone__c,SB_Supplier__r.Name,SB_Name__c,SB_Payment_Type__c,SB_Supplier__r.S_Emergency_Phone__c  
                                    From Supplier_Booking__c
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Excursion')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBLocalArrange.add(s);
                                    }
       
        return lstTV_SBLocalArrange.size();
    }
    
   
    
    
/*------------- Final docs, Confirmation, Invoice  Letter -----------------*/

    Public Date Confirm_date {get;set;}
    Public List<string> lstCL_travelcountry{get;set;}
    Public Integer counttc {get;set;}
    Public List<Group_Member__c> lstGMAddress{get;set;}
  
    Public Date getTodayDate(){
        
        Confirm_date = Date.today();
        return Confirm_date;
    }
    
    
    
    Public List<string> getConfirmLetter_TravelCountry(){
        
        lstCL_travelcountry = new List<string>(); 
        for(Travelling_Country__c t: [select Name,TC_Accommodation_Region__c,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
                                 
                                 lstCL_travelcountry.add(t.TC_Country__r.name);
                             }
        
         return lstCL_travelcountry;
    }
    
     Public Integer getConfirmLetter_CountTravelCountry(){
        
        lstCL_travelcountry = new List<string>(); 
        for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
                                 
                                 lstCL_travelcountry.add(t.TC_Country__r.name);
                             }
        
         counttc= lstCL_travelcountry.size();
         return counttc;
    }
    
    
    Public List<Group_Member__c> getInvoiceAddress(){
         lstGMAddress = new List<Group_Member__c>();
         lstGMAddress = [select GM_Contact__r.MailingAddress,GM_Contact__r.MailingStreet,GM_Contact__r.MailingCity,GM_Contact__r.MailingState,GM_Contact__r.MailingCountry,GM_Contact__r.MailingPostalCode
                  from Group_Member__c
                  where GM_Opportunity__c=:oppId AND GM_Lead_Passenger__c = TRUE Limit 1];
        
        return lstGMAddress;
    }
    
  public List<Selected_ICC_Copy__c> lstSICCO {get;set;} 
  Public Set <string> Final_Forget_TravelCountry {get;set;}
  Public Set <string> Final_TravelCountry {get;set;}   
    
     Public List <Selected_ICC_Copy__c>  getFinalDocsPleaseDontForget(){
    
        lstSICCO = new List<Selected_ICC_Copy__c>();
        set <string> Final_Forget_TravelCountry = new set<string>();
        set <string> Final_travelcountry = new set<string>();
       
        
     for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
       
                            Final_Travelcountry.add(t.TC_Country__r.name);                   
                         }
         
         
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Domestic Flight','Days at Leisure')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ASC]) {
                                        
                                        
                                        Final_Forget_TravelCountry.add(s.SB_Where_to_go__r.W_Country__r.Name);
                                        
                                    } 
      
        
          lstSICCO = [select Id,SICCO_Title__c,SICCO_Description__c,SICCO_Order__c,SICCO_Country__r.Name,CurrencyIsoCode,SICCO_Category__c,SICCO_Country__c,
                     SICCO_FinalDoc__c,SICCO_Confirmation_Letter__c
                    from Selected_ICC_Copy__c 
                    where SICCO_Category__r.ICC_Opportunity__c = :Opp.ID
                    AND SICCO_Category__r.SICC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                    AND ((SICCO_Country__r.Name in :Final_Travelcountry)OR (SICCO_Country__r.Name = ''))
                    AND (SICCO_Title__c != 'Confirmation Letter Intro' AND SICCO_Title__c !='Confirmation Letter Closing')
                    AND  SICCO_FinalDoc__c = TRUE 
                    order by SICCO_Order__c];
         
         return lstSICCO;
     }
    
  public List<Selected_ICC_Copy__c> lstC_SICCO {get;set;} 
  Public Set <string> C_Forget_TravelCountry {get;set;}
  Public Set <string> C_TravelCountry {get;set;}   
        

 Public List <Selected_ICC_Copy__c>  getConfirmLetterPleaseDontForget(){
    
        lstC_SICCO = new List<Selected_ICC_Copy__c>();
        set <string> C_Forget_TravelCountry = new set<string>();
        set <string> C_travelcountry = new set<string>();
      
        
     for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
       
                            C_Travelcountry.add(t.TC_Country__r.name);                   
                         }
         
         
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Domestic Flight','Days at Leisure')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ASC]) {
                                        
                                        
                                        C_Forget_TravelCountry.add(s.SB_Where_to_go__r.W_Country__r.Name);
                                        
                                    } 
      
        
          lstC_SICCO = [select Id,SICCO_Title__c,SICCO_Description__c,SICCO_Order__c,SICCO_Country__r.Name,CurrencyIsoCode,SICCO_Category__c,SICCO_Country__c,
                        SICCO_FinalDoc__c,SICCO_Confirmation_Letter__c
                    from Selected_ICC_Copy__c 
                    where SICCO_Category__r.ICC_Opportunity__c = :Opp.ID
                    AND SICCO_Category__r.SICC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                    AND ((SICCO_Country__r.Name in : C_Travelcountry)OR (SICCO_Country__r.Name = ''))
                    AND (SICCO_Title__c != 'Final Letter Intro' AND SICCO_Title__c !='Final Letter Closing')
                    AND SICCO_Confirmation_Letter__c = TRUE     
                    order by SICCO_Order__c];
         
         return lstC_SICCO;
     }


  // Signature
    Public string SignatureURL {get;set;}
    
    Public String getUserSign(){
     SignatureURL ='';   
     User p = [Select Name, U_User_Signature__c From User where Username =:Opp.Owner.Username]; 
    
    for(Document d : [Select Id, Name From Document Where Name = :p.U_User_Signature__c Limit 1]){
        
     SignatureURL = '/servlet/servlet.ImageServer/?&id=' + d.id+'&oid=' + UserInfo.getOrganizationId();
         
       // system.debug('sign '+SignatureURL);
        
    }
 return SignatureURL;
    }
    
    // Final Letter Emergency Details
    string str_phone ='';
    string str_phone2 ='';
    string str_name ='';
    string SBEmergency ='';
    
    Public set<string> setSB_Emergency {get;set;}   
       
    Public string getEmergencyDetail(){
        setSB_Emergency = new set<string>();
        for(Supplier_Booking__c s :[select SB_Supplier__r.Name,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.S_Emergency_Phone_2__c
                                   From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Accommodation','Transfer','Excusrion')
                                    Order by SB_Order__c]){
                                     
                                        //setSB_Emergency.add(s.SB_Supplier__r.Name);
                                    }
        
        for(Supplier_Booking__c s :[select SB_Supplier__r.Name,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.S_Emergency_Phone_2__c
                                   From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Accommodation','Transfer','Excusrion')
                                    Order by SB_Order__c]){
                                     
                                       
                                         if(!(setSB_Emergency.contains(s.SB_Supplier__r.Name ))){
                                         setSB_Emergency.add(s.SB_Supplier__r.Name);
                                        if(s.SB_Supplier__r.Name != NULL && s.SB_Supplier__r.Name !='')
                                            str_name = s.SB_Supplier__r.Name;
                                        if(s.SB_Supplier__r.S_Emergency_Phone__c != NULL && s.SB_Supplier__r.S_Emergency_Phone__c !='')
                                            str_phone =', '+s.SB_Supplier__r.S_Emergency_Phone__c;
                                        if(s.SB_Supplier__r.S_Emergency_Phone_2__c != NULL && s.SB_Supplier__r.S_Emergency_Phone_2__c !='')
                                            str_phone2 =', '+s.SB_Supplier__r.S_Emergency_Phone_2__c+'<br/>';
                                        
                                        SBEmergency = SBEmergency + str_name+str_phone+str_phone2;
                                    }
                                    }     
        return SBEmergency; 
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


public List<ExtraQuote> getExtraQuote(){
    List<ExtraQuote> lstExtra = new List<ExtraQuote>();
    Map<String,List<Supplier_Cost__c>> mapCost = new Map<String,List<Supplier_Cost__c>>();
    Decimal oppMarkup = opp.O_Suggested_Margin__r.M_Margin__c;
    
    for(Supplier_Cost__c sbc : [Select Id,SC_Supplier_Booking__r.recordType.Name,SC_Total_Net_CostSC__c,SC_Description__c,SC_Option__c  from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c = :opp.id and SC_Option__c != 'Option 1' order by SC_Option__c]){
        if(!mapCost.containsKey(sbc.SC_Option__c)){
            mapCost.put(sbc.SC_Option__c,new List<Supplier_Cost__c>());
        }
        mapCost.get(sbc.SC_Option__c).add(sbc);
    }
    
    
    
    for(String str : mapCost.keySet()){
        ExtraQuote ext = new ExtraQuote();
        String note = '';
        Decimal total = 0;
        Decimal scIntFlight = 0;
        Decimal scNoIntFlight = 0;
        Decimal scIntFlightToday = 0;
        Decimal scNoIntFlightToday = 0;
        Set<String> countOfIntFlightComponent = new Set<String>();
        for(Supplier_Cost__c sbc : mapCost.get(str)){
            if(sbc.SC_Description__c != null)
                note += sbc.SC_Description__c+' ';
            total += sbc.SC_Total_Net_CostSC__c;
            if(sbc.SC_Supplier_Booking__r.recordType.Name != 'Int Flight'){
                scNoIntFlight += sbc.SC_Total_Net_CostSC__c;    
            }
            else{
                scIntFlight  += (sbc.SC_Total_Net_CostSC__c);    
                countOfIntFlightComponent.add(sbc.SC_Supplier_Booking__c);
            }
        }
        if(countOfIntFlightComponent.size() > 0){
            scIntFlight  = scIntFlight + 50*countOfIntFlightComponent.size();    
            scIntFlightToday  = scIntFlightToday + 50*countOfIntFlightComponent.size();    
        }
        ext.Option = str;
        ext.notes = note;
        ext.totalExtra = (((scNoIntFlight)/(1-opp.O_Suggested_Margin__r.M_Margin__c/100))+(scIntFlight)).setScale(2, RoundingMode.HALF_UP);
        lstExtra.add(ext);    
    }
    return lstExtra;
}

public class ExtraQuote{
    public String Option{get; set;}
    public String notes{get; set;}
    public Decimal totalExtra{get; set;}
    
    public extraQuote(){
    }
}

public class countryQuote
{
    public Country__c objCountry{get;set;}
    //public Itinerary_Text__c qt{get;set;}
    public string qtMsg {get;set;}
    public String imageId{get; set;}
    public String accommodationRegion {get;set;}
    public countryQuote(Country__c c, string str ){
        objCountry = c;
        qtMsg = str;
        
    }
}           
    
    


}
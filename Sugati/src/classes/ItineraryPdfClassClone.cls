public class ItineraryPdfClassClone{
  
     
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
    Public List<string> travelcountry{get;set;}
    Public set<string> setFlight{get;set;}
    Public string hType;
    
    public Map<String,Boolean> mapSelected{get; set;}
    public Map<String,String> mapContentLabel{get; set;}
    public String mapContentLabelStr{get; set;}
    public Map<String,String> mapSelectedContentIds{get; set;}
    public String mapContains{get; set;}
    public List<String> selectedItineraryContent = new List<String>();
 
    Public List<string> HolidayType = new List<string>();
    Public Boolean stageMsg = False;  
    public decimal roundedPayment{get;set;}
    
    public Boolean showTicketVoucher{get; set;}
    
    
    /* -------- Final Document - Tickets and Vouchers (Variables Declaration)----------------- */
     
    Public List<Supplier_Booking__c> lstTV_SBFlights {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBAccomm {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBTransfer {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBLocalArrange {get;set;}
    Public List<Supplier_Booking__c> lstTV_SBCarHire{get;set;}
    Public List<Integer> lstRows{get;set;}
    
    /* -------- Final Document - Tickets and Vouchers (End of Variables Declaration)----------------- */
    
    
    public ItineraryPdfClassClone(Apexpages.standardcontroller controller) {
        oppId = controller.getId();
        if (controller.getId() != null) {
            Opp = [select id, Name, O_Holiday_Type__c,O_Itinerary_At_Glance_Rows__c,O_Holiday_Type__r.Name,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                   O_Adult__c,O_Children__c,O_Infant__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Reference_Number__c,O_Due_Date__c,
                   O_Itinerary_Display_Price__c,O_Total_Payment__c,(select  GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Group_Members__r)
                   from Opportunity 
            where Id=:oppId];
           lstRows = new List<Integer>(); 
           try{
               if(opp.O_Itinerary_At_Glance_Rows__c != null){
                   for(String row : opp.O_Itinerary_At_Glance_Rows__c.split(','))
                       lstRows.add(Integer.valueOf(row));
               }
           }
           catch(Exception e){
               
           }
           Decimal toround = Opp.O_Total_Payment__c;
           roundedPayment = toround.setScale(2);
           travelcountry= new List<String>();
           showTicketVoucher = false;
            for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                                 where TC_Opportunity__r.Id= :OppId]){
        
                  travelcountry.add(t.TC_Country__r.name);                   
            } 
           if(Opp.O_Holiday_Type__c != NULL)
           { 
               hType=Opp.O_Holiday_Type__r.Name;
           
            HolidayType.add(Opp.O_Holiday_Type__r.Name);
               
           }
            
           for(Supplier_Booking__c sb : [Select Id from Supplier_Booking__c where SB_Opportunity__c = :opp.Id and recordType.Name in ('Car Hire','Excursion','Transfer','Accommodation','Int Flight','Light Aircraft','Dom Flights','Private Jet') and SB_Show_Voucher__c = true]){
               showTicketVoucher  = true;    
           }  
           
         } 
        
              
         
        // Display Only Selected category's Content 
          
        mapSelected = new Map<String, Boolean>();
        mapContentLabel = new Map<String, String>();
        mapContentLabelStr = '';
        mapSelectedContentIds = new Map<String, String>();
        LIST<Opportunity> selectedOpp = new List<Opportunity>();
        if(oppId != null){
            selectedOpp =  [Select Id, (Select Id, Name,SICC_Itinerary_Content_Category__r.name, SICC_Itinerary_Content_Category__r.ICC_Content_Category_Label__c from Itinerary_Content_Categories__r) from Opportunity where Id = :oppId ];
        }
        for(Itinerary_Content_Category__c icc : [Select Id, Name,ICC_Content_Category_Label__c  from Itinerary_Content_Category__c]){
            mapSelected.put(icc.Name, false); 
            mapContentLabel.put(icc.Name, ''+icc.ICC_Content_Category_Label__c); 
            if(icc.ICC_Content_Category_Label__c != null){
                mapContentLabelStr += icc.Name+' ';
            }
            mapContains += ' '+icc.Name;  
        }
        if(selectedOpp.size()> 0){
            for(Selected_Itinerary_Content_Category__c sIc : selectedOpp[0].Itinerary_Content_Categories__r){
                selectedItineraryContent.add(sIc.SICC_Itinerary_Content_Category__r.name); 
                mapSelected.put(sIc.SICC_Itinerary_Content_Category__r.name, true);
                mapContentLabel.put(sIc.SICC_Itinerary_Content_Category__r.Name, ''+sIc.SICC_Itinerary_Content_Category__r.ICC_Content_Category_Label__c); 
                if(sIc.SICC_Itinerary_Content_Category__r.ICC_Content_Category_Label__c != null){
                    mapContentLabelStr += sIc.SICC_Itinerary_Content_Category__r.Name+' ';
                }
                mapSelectedContentIds.put(sIc.SICC_Itinerary_Content_Category__r.name, sIc.SICC_Itinerary_Content_Category__c);                   
            }    
        }
        //system.assert(false, mapSelected +'--'+ mapContains );
        
    }
    
        
    
     // Get Cover Image 
     
   
   public String getFileId() {
        
        //String fileId = '';
        lstTC = [select TC_ImageID__c,TC_Cover_Image__c  from Travelling_Country__c
                 where TC_Opportunity__r.Id= :OppId  
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
    
    
    //Content Page
    
    
    Public list <Selected_Itinerary_Content_Category__c> getSelectedItineraryContent(){
            lstSelectedItinerary = new List<Selected_Itinerary_Content_Category__c>();   
            Set<String> addedCategories = new Set<String>();
            for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_Itinerary_Content_Category__r.Name,ICC_Page_No__c from Selected_Itinerary_Content_Category__c 
                                         where ICC_Opportunity__r.Id=:oppId AND
                                         SICC_Itinerary_Content_Category__r.Name NOT IN ('CONTENT','TICKETS AND VOUCHERS','CONFIRMATION LETTER','CONFIRMATION INVOICE','FINAL DOCS LETTER') 
                                         order by SICC_Itinerary_Content_Category__r.ICC_Order__c]){
                      
                      if(l.SICC_Itinerary_Content_Category__r.Name != 'YOUR GUIDE' && !addedCategories.contains(l.SICC_Itinerary_Content_Category__r.Name)){
                          lstSelectedItinerary.add(l);                 
                      }
                      addedCategories.add(l.SICC_Itinerary_Content_Category__r.Name);
                      //else if(opp.recordType.Name == 'ST'){
                      //    lstSelectedItinerary.add(l);                 
                      //}     
                             
              }
            return lstSelectedItinerary;
    }
    
    
    // Tailored for you and Holiday Map
    
    Public string getTailorDescription(){
               for(Selected_Itinerary_Content_Category__c l: [select Name,SICC_message__c,
                                                              RecordType.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId AND
                                                        RecordType.Name ='Tailored For You' Limit 1]){
                     
                   
                     tailordesc = l.SICC_message__c;                      
                             
              }
        system.debug('tailordesc  '+ tailordesc);
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
 Public List<countryQuote> getCountryQuote(){
     
            lstTCountry = new List<String>();
            lstCountryQuote = new List<countryQuote>();
            lstT = new List<Travelling_Country__c>();
            mapIT_TCmsg = new MAP<string,string>();
            mapIT_Check = new MAP<string,boolean>();
            
            List<String> lstOfCountries = new  List<String>();
            Set<String> setOfCountries = new  Set<String>();
            for(Supplier_Booking__c sb : [Select id, SB_What_to_do__r.WH_Country__c,SB_Supplier__r.S_Where_to_go__r.W_Country__c, SB_Where_to_go__c,SB_Where_to_go__r.W_Country__c from
                                          Supplier_Booking__c where SB_Opportunity__c = :opp.Id 
                              order by SB_Order__c]){
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
            Map<String,Travelling_Country__c> mapTravellingCountry = new Map<String,Travelling_Country__c>();
            for(Travelling_Country__c tc: [select Name,TC_Country__c,TC_Country__r.name,TC_Country__r.C_Notes__c from Travelling_Country__c
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
                                    from Itinerary_Text__c
                                    where 
                                   (IT_Holiday_Type__c NOT IN :HolidayType  
                                    AND IT_Holiday_Type__r.Name='Generic') AND
                                    IT_Country__r.Name In :lstTCountry]){
                                        
                                        if(!mapIT_check.containsKey(qt.IT_Country__c))
                                        {
                                               mapIT_TCmsg.put(qt.IT_Country__c,qt.IT_Message__c); 
                                        } } 
       
         Set<String> tcIds = new Set<String>();
        for(Travelling_Country__c tc : lstT){
           if(!tcIds.contains(tc.TC_Country__c)){ 
               
               for(Country__c c: [select Name,C_Notes__c,C_Archive__c, (select Id from Attachments where Name like :likeclause Limit 1 )
                                           from Country__c
                                  where Name = :tc.TC_Country__r.Name  AND C_Archive__c = False limit 1]) {                   
                                  
                   lstCountryQuote.add(new countryQuote(c,mapIT_TCmsg.get(tc.TC_Country__c)));
                              
                                  }  }  
       
               }        
      
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
                                                        RecordType.Name ='What It Costs' Limit 1]){
                     
                   
                     WhatCostdesc = l.SICC_message__c;   
                                     
                             
              }
        system.debug('tailordesc  '+ WhatCostdesc);
        
        return WhatCostdesc;
        
    }
    
     
     Public List <Itinerary_Content__c>  getItineraryContentWhatItCost(){
        list <Itinerary_Content__c> lstCost = new List<Itinerary_Content__c>();
        lstCost = [select  IC_Description__c,IC_Title__c,IC_Order__c from Itinerary_Content__c 
                   where IC_Itinerary_Content_Category__r.Name = 'WHAT IT COSTS' order by IC_Order__c];
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
        List <string>travelcountry = new List<string>();
      // set <string>Forget_TravelCountry = new set<string>(); 
        String lstTravelC ='';
        
     for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
    
              travelcountry.add(t.TC_Country__r.name);                   
                             }
         
         
     /*   for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                   from Supplier_Booking__c 
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Dom Flights','Days at Leisure')) AND 
                                    SB_Opportunity__c = :Opp.Id
                                    Order by SB_Order__c ASC]) {
                                        
                                        
                                        Forget_TravelCountry.add(s.SB_Where_to_go__r.W_Country__r.Name);
                                        
                                    } */
      
        
        lstForget = [select IC_Title__c,IC_Description__c,IC_New_Page__c,IC_Itinerary__c,(select Id from Attachments limit 1)
                     from Itinerary_Content__c 
                     where IC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                    AND ((IC_Country__r.Name in :travelCountry)OR (IC_Country__r.Name = ''))
                     //AND  RecordType.name =:Opp.RecordType.name
                     AND IC_Itinerary__c = TRUE
                     order by IC_Order__c];
             lstForget1.addall(lstForget);        
        
        
         
         
         return lstForget1;
     }




    //User Expertise
    Public List <User> getUserExpertise(){
        List <User> lstExpertise = new List<User>(); 
        lstExpertise = [select U_Our_Expertise__c,Username,Name,Email,U_Why_Us__c,U_Field_1__c,U_Field_2__c,U_Field_3__c,U_Field_4__c,U_Field_5__c,U_Field_6__c ,U_Field_7__c,
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
    
        for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Itinerary_Description__c,SB_Supplier__c,SB_Order__c, (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r  where (SBI_Order__c = 3 or SBI_Order__c = 4) limit 2 ) 
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
                                RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet')
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
    
    for(Group_Member__c gm:[select Id,GM_Contact__c,GM_Contact__r.C_Full_Name_on_Passport__c
                             from Group_Member__c
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
        List<Document> lstDoc = [Select Id from Document where Name = 'ROF Logo'];
        if(lstDoc.size() > 0 ){
            return lstDoc[0].Id;        
        }
        return null;
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
        
        string recordtype_Name = '';//tring.valueof(Opp.RecordType.name);
       
      
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
    Private Map<date,ItineraryDetail> mapDetail{get; set;} 
    Public List<Supplier_Booking__c> mySupp {get;set;}
    
  Public List<ItineraryDetail> getDetailedItinerary1(){   
      liDetail = new list<ItineraryDetail>();
    mySupp = new List<Supplier_Booking__c>();
    Set<String> processedDate = new Set<String>();
    mySupp = [Select SB_Itinerary_Description__c,SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c,SB_Day__c,SB_From_Date__c,SB_To_Date__c,SB_Notes__c,
                        SB_From_Place__c,SB_Meal_Basis__c,SB_Room_Type__c,SB_Night__c,SB_Supplier_Name__c,SB_New_Page__c,SB_Order__c,RecordType.name,
                    SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_Departure_Time__c,SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Carrier__c,SB_From_Time__c,
                    (select SBI_Attachement_Id__c,SBI_Image__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 limit 2 ) 
                                   from Supplier_Booking__c where SB_Show_in_Itinerary__c = true AND 
                                    SB_Opportunity__r.Id= :Opp.Id Order by SB_Order__c];
            for(Supplier_Booking__c sSupplier : mySupp){
                sSupplier.SB_Itinerary_Description__c = '<strong>'+sSupplier.RecordType.Name+' : </strong>'+sSupplier.SB_Itinerary_Description__c;
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

    
/* ---------------- Final Documents - Tickets and Vouchers ---------------------- */
    
    Public List<Supplier_Booking__c> getTicketsVouchers_Flights(){
        
        lstTV_SBFlights = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Flight_Ref__c,SB_Flight_No__c,SB_Departure_Airport_l__r.Name,SB_Arrival_Airport_l__r.Name,SB_From_Date__c,SB_Departure_Time__c,SB_From_Time__c,SB_Notes__c,RecordType.Name,
                                    SB_To_Date__c,SB_To_Time__c,SB_Class__c,SB_Check_In_Time__c,SB_Supplier__r.Name,SB_Carrier__c,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c ,(select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c)
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights','Private Jet') AND
                                    SB_Own_Arrangement__c = FALSE and SB_Show_Voucher__c = true
                                    Order by SB_Order__c]){
                                        lstTV_SBFlights.add(s);
                                    }
        return lstTV_SBFlights;
    }
    
    
    Public List<Supplier_Booking__c> getTicketsVouchers_Accomm(){
        
        lstTV_SBAccomm = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Supplier__r.Name,SB_Ground_Handler__r.S_Phone__c,SB_Ground_Handler__r.S_Emergency_Phone__c, SB_From_Date__c,SB_To_Date__c,SB_Room_Type__c,SB_Meal_Basis__c,
                                    SB_Supplier__r.S_Street__c,SB_Supplier__r.S_City__c,SB_Supplier__r.S_State__c,SB_Supplier__r.S_Country__c,
                                    SB_Supplier__r.S_Postcode__c,SB_Supplier__r.S_Phone__c,SB_Night__c,SB_From_Time__c,SB_Payment_Type__c,SB_Booking_No__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Ground_Handler__c,SB_Ground_Handler__r.Name
                                   ,(select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c) From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Accommodation') and SB_Show_Voucher__c = true
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBAccomm.add(s);
                                    }
        return lstTV_SBAccomm;
    }
    
    
     Public List<Supplier_Booking__c> getTicketsVouchers_Transfer(){
        
       lstTV_SBTransfer = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_From_Place__c,SB_To_Place__c,SB_From_Date__c,SB_To_Date__c,SB_Pickup_Point__c,SB_Itinerary_Description__c,SB_Ground_Handler__r.S_Phone__c,
                                    SB_Supplier__r.S_Phone__c,SB_From_Time__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.Name,SB_Ground_Handler__r.Name
                                    ,(select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c) From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Transfer') and SB_Show_Voucher__c = true
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBTransfer.add(s);
                                    }
         system.debug('size transfer '+lstTV_SBTransfer.size());
        return lstTV_SBTransfer;
    }
    
  
     Public List<Supplier_Booking__c> getTicketsVouchers_LocalArrange(){
        
        lstTV_SBLocalArrange = new List<Supplier_Booking__c>();
    
        for(Supplier_Booking__c s :[select SB_Ground_Handler__r.S_Phone__c,SB_From_Date__c,SB_Local_Arrangements_Content__c,SB_To_Date__c,SB_Supplier__r.S_Phone__c,SB_Supplier__r.Name,SB_Name__c,SB_Payment_Type__c,SB_Supplier__r.S_Emergency_Phone__c 
                                    ,(select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c) From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Excursion') and SB_Show_Voucher__c = true
                                    Order by SB_Order__c]){
                                        lstTV_SBLocalArrange.add(s);
                                    }
       
        return lstTV_SBLocalArrange;
    }
    
    Public List<Supplier_Booking__c> getTicketsVouchers_CarHire(){
        
        lstTV_SBCarHire = new List<Supplier_Booking__c>();
    
        for(Supplier_Booking__c s :[select SB_Ground_Handler__r.S_Phone__c,SB_Local_Arrangements_Content__c,SB_Flight_Ref__c,SB_Flight_No__c,SB_From_Time__c ,SB_Supplier__r.S_Phone__c,SB_Departure_Airport_l__r.Name,SB_Arrival_Airport_l__r.Name,SB_From_Date__c,SB_Departure_Time__c,SB_Notes__c,RecordType.Name,
                                    SB_To_Date__c,SB_To_Time__c,SB_Class__c,SB_Check_In_Time__c,SB_Supplier__r.Name,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c,
                                    (select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c),SB_Pickup_Point__c,SB_Drop_off_Point__c,SB_Vehicle__c,SB_Name__c, SB_Provider_Telephone__c
                                    From Supplier_Booking__c Where SB_Opportunity__c = :Opp.Id AND RecordType.Name In ('Car Hire') and SB_Show_Voucher__c = true Order by SB_Order__c]){
                                        lstTV_SBCarHire.add(s);
                                    }
       
        return lstTV_SBCarHire;
    }
    
    Public Integer getCount_TVFlights(){
        
        lstTV_SBFlights = new List<Supplier_Booking__c>();
        
        for(Supplier_Booking__c s :[select SB_Flight_Ref__c,SB_Flight_No__c,SB_Supplier__r.S_Phone__c,SB_Departure_Airport_l__r.Name,SB_Arrival_Airport_l__r.Name,SB_From_Date__c,SB_Departure_Time__c,SB_Notes__c,RecordType.Name,
                                    SB_To_Date__c,SB_To_Time__c,SB_Class__c,SB_Check_In_Time__c,SB_Supplier__r.Name,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c,
                                    (select FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c
                                     from Flight_Bookings1__r order by FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c)
                                    From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights') AND
                                    SB_Own_Arrangement__c = FALSE
                                    Order by SB_Order__c]){
                                        
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
    
    
    Public Integer getCount_TVCarHire(){
        
        lstTV_SBCarHire = new List<Supplier_Booking__c>();
    
        for(Supplier_Booking__c s :[select SB_From_Date__c,SB_To_Date__c,SB_Supplier__r.S_Phone__c,SB_Supplier__r.Name,SB_Name__c,SB_Payment_Type__c,SB_Supplier__r.S_Emergency_Phone__c  
                                    From Supplier_Booking__c
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Car Hire')
                                    Order by SB_Order__c]){
                                        
                                        lstTV_SBCarHire.add(s);
                                    }
       
        return lstTV_SBCarHire.size();
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
        for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
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
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Dom Flights','Days at Leisure','Private Jet')) AND 
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
                                    where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Dom Flights','Days at Leisure','Private Jet')) AND 
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
    
    
    
    //Itinerary At a Glance 
    public List<Supplier_Booking__c> getItineraryAtGlance(){
        
        List<Supplier_Booking__c> lstSB = [select id, name,SB_Where_to_go__c,SB_Where_to_go__r.W_Country__r.Name, recordtype.name,SB_What_to_do__c,SB_What_to_do__r.Name,SB_Pickup_Point__c, 
                                            SB_From_Date__c,SB_To_Date__c,SB_Room_Type__c,SB_Supplier__r.S_Country__c,SB_From_Place__c,SB_To_Place__c,SB_From_Time__c,SB_To_Time__c,
                                            SB_Carrier__c,SB_Class__c,SB_Meal_Basis__c,SB_Night__c,SB_Supplier__r.Name,SB_Flight_No__c,SB_Name__c,
                                            SB_New_Page__c,SB_Supplier_Name__c , SB_Itinerary_Description__c,SB_Order__c,SB_Supplier__c,SB_Ticket_No__c,SB_Vehicle__c  
                                            from Supplier_Booking__c  where SB_Opportunity__c =: opp.Id and SB_Show_in_Itinerary__c = true Order by SB_From_Date__c,SB_Order__c,createdDate];
        return lstSB;
            
    }
    
   
/* ----------- End of Confirmation Letter ----------------- */ 
    
    
    
public class Life{
    public Supplier_Booking__c SB{get; set;}
    public Itinerary_Text__c QT{get; set;}
    public Attachment att{get; set;}
    
    public Life(Supplier_Booking__c sb,Itinerary_Text__c QT,Attachment att){
        this.sb = sb;
        this.qt = qt;
        this.att = att;
    }
}    
    
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
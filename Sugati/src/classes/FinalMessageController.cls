public with sharing class FinalMessageController {
    public String oppId{get;set;}
    public Opportunity Opp{get;set;}
    public list<SelectedTravellingCountry> lstTravelCountry{get;set;}
    Public List <Selected_Itinerary_Content_Category__c> lstTailorCat{get;set;} 
    Public List <Selected_Itinerary_Content_Category__c> lstCostCat{get;set;}     
    Public List <Selected_Itinerary_Content_Category__c> lstFlightCat{get;set;}     
    Public List <Travelling_Country__c> lstTC{get;set;} 
    Public String travelMessage;
    Public String CostMessage;
    public String FlightMessage;
    
    public string strMessage {get;set;}
        
     public FinalMessageController(Apexpages.standardcontroller controller) {
        OppId = controller.getId();
        strMessage = '';
        
        if (controller.getId() != null) {
            Opp = [select id, Name,AccountId,Account.Name,Owner.Name,Owner.Username,Description
                   from Opportunity 
                   where Id=:oppId];
                   
            /*Map<Id,string> maprecordtype = new Map<id,String>();       
            for (Recordtype rt : [select id, name from recordtype where sobjecttype = 'Opportunity']) {
                maprecordtype.put(rt.id,rt.name);   
            }
            
            //for (id rtId: maprecordtype.keyset()) {
              if(maprecordtype.containsKey(opp.recordtypeId)){
                if (maprecordtype.get(opp.recordtypeId) == 'GB') {
                    strMessage = 'Original Travel';
                }
                else if (maprecordtype.get(opp.recordtypeId) == 'MU') {
                    strMessage = 'Original Music';
                }
                else if (maprecordtype.get(opp.recordtypeId) == 'OD') {
                    strMessage = 'Original Diving';
                }
                else if (maprecordtype.get(opp.recordtypeId) == 'OTUK') {
                    strMessage = 'Original Britain';
                }
                else if (maprecordtype.get(opp.recordtypeId) == 'ST') {
                    strMessage = 'Simoon Travel';
                }
                else if (maprecordtype.get(opp.recordtypeId) == 'TB') {
                    strMessage = 'Tim Best Travel';
                }
            }*/
           // }
        } 
    }
   
    Public list<Selected_Itinerary_Content_Category__c> getTailoredCategory(){
        try{
           lstTailorCat = new List<Selected_Itinerary_Content_Category__c>();
           for(Selected_Itinerary_Content_Category__c sic: [select id, Name,SICC_message__c,SICC_message1__c,
                                                           SICC_Itinerary_Content_Category__r.Name
                                                            from Selected_Itinerary_Content_Category__c 
                                                            where ICC_Opportunity__r.Id=:oppId
                                                            AND SICC_Itinerary_Content_Category__r.Name ='TAILORED FOR YOU'
                                                            Limit 1]){
                                                            
                                                            lstTailorCat.add(sic);  
                                                            travelMessage = sic.SICC_message__c;
                                       
             }
             
            
          
           if(travelMessage == null)
          {    
            if(Opp.Account.Name != null)  
             travelMessage ='Dear '+Opp.Account.Name+',<br/><br/>';
            
            String HolidayQuestion ;
            HolidayQuestion = '<br/>' ;
           
            for(Holiday_Question__c hq : [Select id,name,HQ_Answer__c,HQ_Order__c,HQ_Question__r.Q_Question_Name__c from Holiday_Question__c where 
                                      HQ_Opportunity__c =: Opp.Id OR HQ_Account__c =: Opp.AccountId order by HQ_Order__c]){
                                        
                  HolidayQuestion = '> ' +hq.HQ_Question__r.Q_Question_Name__c+'-<strong>'+hq.HQ_Answer__c +'</strong><br/>';
                  travelMessage = travelMessage +' '+HolidayQuestion ;
                      
             }
              if(opp.Description != null && opp.Description !=''){
                   travelMessage += '> Client Holiday Description'+' - '+opp.Description+'<br/>' ; 
               }
          
            
            if(Opp.Owner.Name != NULL)    
            travelMessage = travelMessage+'<br/>Yours Sincerely,<br/><br/>'+Opp.Owner.Name+'<br/>' + strMessage ;//Original Travel;   
          }  
           
            if(lstTailorCat.size() > 0){
                lstTailorCat[0].SICC_message__c = travelMessage;
                if(lstTailorCat[0].SICC_message1__c == '' || lstTailorCat[0].SICC_message1__c == null){
                    lstTailorCat[0].SICC_message1__c = '';
                    Set<Integer> setDAysDiff = new Set<Integer>();
                    for(Supplier_Booking__c sb : getItineraryGlanceFlight()){
                        if(sb.SB_To_Date__c > sb.SB_From_Date__c){
                            Integer count = sb.SB_From_Date__c.daysBetween(sb.SB_To_Date__c);
                            
                            
                            if (!setDAysDiff.contains(count)) {
                                lstTailorCat[0].SICC_message1__c += '(+'+count+') in the details section means arrival '+count+' day later<br/>';
                                setDAysDiff.add(count);
                            }
                        }
                    }
                    if(getItineraryFlightMessage()>0){
                        lstTailorCat[0].SICC_message1__c += '<strong>Please note these flights are not on hold for you so price and availability may be subject to change.</strong><br/><br/>';
                    }
                    
                    if(getItineraryFlightMessage1()>0 && getItineraryFlightMessage()<=0 && getItineraryFlightMessage3() >0 && getItineraryFlightMessage2() <=0){
                        lstTailorCat[0].SICC_message1__c += 'The names which we have held your flights under are as follows:<ul>';
                        for(Group_Member__c gm : getGroupMembers()){
                            String data = '';
                            if(gm.GM_Contact__r.C_Full_Name_on_Passport__c!= null)
                                data += gm.GM_Contact__r.C_Full_Name_on_Passport__c;
                        
                            lstTailorCat[0].SICC_message1__c += '<li>'+data+'</li>';    
                        }
                    }
                 
                    if(getItineraryFlightBookedMessage()>0 ){
                        lstTailorCat[0].SICC_message1__c += 'The names which we have booked your flights under are as follows:<ul>';
                        for(Group_Member__c gm : getGroupMembers()){
                            String data = '';
                            if(gm.GM_Contact__r.C_Full_Name_on_Passport__c!= null)
                                data += gm.GM_Contact__r.C_Full_Name_on_Passport__c;
                        
                            lstTailorCat[0].SICC_message1__c += '<li>'+data+'</li>';    
                        }
                    }  

                       if(getItineraryFlightBookedMessage1() > 0 && getItineraryFlightBookedMessage() <= 0){
                        lstTailorCat[0].SICC_message1__c += 'The flights displayed above are booked under your own arrangements and are there for reference purposes only.<br/>';
                    }
                    lstTailorCat[0].SICC_message1__c += '</ul>It is very important that your flights are booked using the exact first name and surname that appear in your passport. Airlines are extremely strict on this point and often refuse to make even minor adjustments and insist on a new booking being made. This can lead to the loss of a flight reservation or an increase in fare. Please inform us at the earliest opportunity should the above details not be correct.'; 
                 
                 }
             }
            return lstTailorCat;
        }
        catch(Exception e){
            
            return null;
        }
    }
    
    
     Public list<Selected_Itinerary_Content_Category__c> getWhatItCostsCategory(){
        
       lstCostCat = new List<Selected_Itinerary_Content_Category__c>();
       for(Selected_Itinerary_Content_Category__c s: [select Name,SICC_message__c,
                                                       SICC_Itinerary_Content_Category__r.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId
                                                       // AND RecordType.Name='What It Costs'
                                                        AND SICC_Itinerary_Content_Category__r.Name ='WHAT IT COSTS'
                                                        Limit 1]){
                            
                                                        lstCostCat.add(s);                     
                                                        CostMessage = s.SICC_message__c;
         }
        system.debug('size of lstCost cat in' + lstCostCat.size());
         
       if(CostMessage == NULL || CostMessage == '')
      {    
        //CostMessage  = '<p><b>Price Includes:</b><br style=""> <span style=" font-family: arial,helvetica,sans-serif; font-size: 12px;">• International and domestic flights as detailed</span><br style=""> <span style="font-family: arial,helvetica,sans-serif; font-size: 12px;">• Accommodation on board basis shown in the itinerary</span><br style=""> <span style=" font-family: arial,helvetica,sans-serif; font-size: 12px;">• Transfers and air taxes </span><br style=""> <span style=" font-family: arial,helvetica,sans-serif; font-size: 12px;">• Car hire </span><br style=""> <br style=""> <b>Additional Costs:</b><br style=""> <span style="font-family: arial,helvetica,sans-serif; font-size: 12px;">• Travel insurance</span><br style=""> <span style="font-family: arial,helvetica,sans-serif; font-size: 12px;">• Visas</span><br style=""> <span style="font-family: arial,helvetica,sans-serif; font-size: 12px;">• Any required inoculations</span><br style=""> <span style=" font-family: arial,helvetica,sans-serif; font-size: 12px;">• Guided sightseeing (unless detailed)</span><br style=""> <span style="font-family: arial,helvetica,sans-serif; font-size: 12px;">• Entrance fees</span><br style=""> <span style=" font-family: arial,helvetica,sans-serif; font-size: 12px;">• Gratuities and items of a personal nature</span></p> ';  
 
         //CostMessage  = '<p><b>Price Includes:</b><br> <span>• International and domestic flights as detailed</span><br> <span>• Accommodation on board basis shown in the itinerary</span><br> <span>• Transfers and air taxes </span><br> <br> <b>Additional Costs:</b><br> <span>• Travel insurance</span><br> <span>• Visas</span><br> <span>• Car hire </span><br> <span>• Any required inoculations</span><br> <span>• Guided sightseeing (unless detailed)</span><br> <span>• Entrance fees</span><br> <span>• Gratuities and items of a personal nature</span></p> ';  
         CostMessage = '<p><strong>Price Includes:</strong></p><ul style=" font-family: arial,helvetica,sans-serif; font-size: 12px;"><li>International and domestic flights as detailed</li><li>Accommodation on board basis shown in the itinerary</li><li>Transfers and air taxes</li></ul><p><br /><strong>Additional Costs:</strong></p><ul style=" font-family: arial,helvetica,sans-serif; font-size: 12px;"><li>Travel insurance</li><li>Visas</li><li>Car hire</li><li>Any required inoculations</li><li>Guided sightseeing (unless detailed)</li><li>Entrance fees</li><li>Gratuities and items of a personal nature</li></ul>';
      }  
       
        if(lstCostCat.size() > 0)
        lstCostCat[0].SICC_message__c = CostMessage ;
        return lstCostCat;
    }
    
    
    Public list<Selected_Itinerary_Content_Category__c> getFlightSection(){
        
      lstFlightCat = new List<Selected_Itinerary_Content_Category__c>();
       for(Selected_Itinerary_Content_Category__c s: [select Name,SICC_message__c,
                                                        SICC_Itinerary_Content_Category__r.Name
                                                        from Selected_Itinerary_Content_Category__c 
                                                        where ICC_Opportunity__r.Id=:oppId
                                                       // AND RecordType.Name='What It Costs'
                                                        AND SICC_Itinerary_Content_Category__r.Name ='TAILORED FOR YOU 1'
                                                        Limit 1]){
                            
                                                        lstFlightCat .add(s);                     
                                                        FlightMessage = s.SICC_message__c;
         }
        system.debug('size of lstCost cat in' + lstCostCat.size());
        if(FlightMessage == NULL)        {    
            FlightMessage = '' ;
        }  
         
        if(lstFlightCat.size() > 0)
            lstFlightCat [0].SICC_message__c += FlightMessage;
        return lstFlightCat;
    }
    
    Public List<Supplier_Booking__c> getItineraryGlanceFlight(){
        List<Supplier_Booking__c> lstFlightBook = new List<Supplier_Booking__c>();
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,
                                (select FB_Group_Member__c,FB_Group_Member__r.GM_Contact__r.C_Full_Name_on_Passport__c     from Flight_Bookings1__r)         
                                From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                               // AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                Order by SB_From_Date__c]){
            
            lstFlightBook.add(flight); 
            
        }
        return lstFlightBook;
    }
    
    Public Integer getItineraryFlightMessage(){
        integer NotHeld = 0;    
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_From_Date__c]){
                                          
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
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_From_Date__c]){
                                           
                                             if(flight.SB_Not_Held__c == False){
                                                 
                                              Held++ ;
                                             
                                             }
                                          
                                 }  
      
     
        return Held;
    }  
    
     Public Integer getItineraryFlightMessage2(){
       
         integer ownt = 0; 
        
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_From_Date__c]){
                                           
                                              if(flight.SB_Own_Arrangement__c == TRUE){
                                                 
                                              ownt++ ;
                                                 
                                             }
                                 }  
      
     
        return ownt;
    }  
    
      Public Integer getItineraryFlightMessage3(){
  
          integer ownf = 0;
         
        for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                                 From Supplier_Booking__c 
                                Where SB_Opportunity__c = :Opp.Id 
                                AND SB_Opportunity__r.StageName NOT IN ('Booking Optional','Booked','Booking cancelled') 
                                AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                         Order by SB_From_Date__c]){
                                           
                  
                                             if(flight.SB_Own_Arrangement__c == FALSE){
                                                 
                                              ownf++ ;
                                                 
                                             }
                                             
                                 }  
            return ownf;
    }  
         
    // Flight Booked msg
    Public Integer getItineraryFlightBookedMessage(){
       
          
             integer BookMsg = 0;    
            for(Supplier_Booking__c flight :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                    SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c,SB_Own_Arrangement__c
                                  From Supplier_Booking__c 
                                  Where SB_Opportunity__c = :Opp.Id 
                                  AND SB_Opportunity__r.StageName IN ('Booking Optional','Booked','Booking cancelled')
                                  AND RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                             Order by SB_From_Date__c]){
           
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
                                         Order by SB_From_Date__c]){
       
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
         lstGM = new List<Group_Member__c>();
         Set<string> setFlight = new Set<string>();
        
          for(Supplier_Booking__c s :[select SB_Arrival_Airport_l__r.Name,SB_Departure_Airport_l__r.Name,SB_To_Date__c,SB_From_Date__c,SB_Departure_Time__c,
                                    SB_To_Time__c,SB_Flight_No__c,SB_Class__c,SB_Itinerary_Description__c,SB_Carrier__c,SB_From_Time__c,SB_Not_Held__c
                                   From Supplier_Booking__c 
                                    Where SB_Opportunity__c = :Opp.Id AND 
                                    RecordType.Name In ('Int Flight','Light Aircraft','Dom Flights')
                                        Order by SB_From_Date__c]){
                                            
                 mapSBIds.put(s.Id, s);
               }  
        
        
        
    
        for(Flight_Booking__c fb: [select FB_Group_Member__c
                                   from Flight_Booking__c
                                   where FB_Supplier_Booking__c in :mapSBIds.keySet() ]){
                                                
                              setFlight.add(fb.FB_Group_Member__c);        
                
                           }  
       
        
        for(Group_Member__c gm:[select Id,GM_Contact__c,GM_Contact__r.C_Full_Name_on_Passport__c   from Group_Member__c
                                where Id in :setFlight]){
                                    
                                    lstGM.add(gm);
                                    
                                }
        
      
        return lstGM;
    
    } 
    


    Public List<SelectedTravellingCountry> getTravellingCountry(){
        
      lstTravelCountry = new List<SelectedTravellingCountry>();
        
      for(Travelling_Country__c tc: [select id,Name,TC_Country__c,TC_Country__r.name,TC_Country__r.C_Notes__c from Travelling_Country__c
                             where TC_Opportunity__r.Id= :OppId]){
        
      lstTravelCountry.add( new SelectedTravellingCountry(tc, true) );
      
      }
     system.debug('size of lstTC' + lstTravelCountry.size()); 
    return lstTravelCountry;
      
    }
    
    
     public Pagereference save() {
       try{
             if(lstTailorCat!= null && lstTailorCat.size() != 0)
                 upsert lstTailorCat;
             if(lstCostCat!= null && lstCostCat.size() != 0)
                 upsert lstCostCat;
             if(lstFlightCat != null && lstFlightCat.size() != 0)
                 upsert lstFlightCat;
           List<Travelling_Country__c> lstTravellingForDel = [select id,TC_Country__c,TC_Selected__c,TC_ImageID__c,TC_Cover_Image__c from Travelling_Country__c  where TC_Opportunity__r.Id = :Opp.Id];
           Map<Id,Travelling_Country__c> mapTravellingC = new Map<Id,Travelling_Country__c>();
           for(Travelling_Country__c tc : lstTravellingForDel ){
               mapTravellingC.put(tc.TC_Country__c, tc);        
           }
           
           delete lstTravellingForDel;
            
            List<Travelling_Country__c> lstTC = new List<Travelling_Country__c>();
             system.debug('size of lstTC' + lstTC.size()); 
           
           for (SelectedTravellingCountry stc: lstTravelCountry ) {
                
                if (stc.selected == TRUE) {
                    system.debug('stc.objTC.TC_Country__c  '+stc.objTC.TC_Country__c);
                     system.debug('stc.objTC.TC_Country__r.name  '+stc.objTC.TC_Country__r.name);
                     Travelling_Country__c tcNew = new Travelling_Country__c(TC_Opportunity__c=opp.Id,TC_Country__c=stc.objTC.TC_Country__c);
                       if(mapTravellingC.containsKey(stc.objTC.TC_Country__c)){
                           tcNew.TC_ImageID__c = mapTravellingC.get(stc.objTC.TC_Country__c).TC_ImageID__c;
                           tcNew.TC_Cover_Image__c = mapTravellingC.get(stc.objTC.TC_Country__c).TC_Cover_Image__c;
                           tcNew.TC_Selected__c = mapTravellingC.get(stc.objTC.TC_Country__c).TC_Selected__c;
                           //UtilityController.runCoverImage = false;
                       }
                   lstTC.add(tcNew );
                }
       
            }
           
          system.debug('size of lstTC' + lstTC.size());
           insert lstTC;  
              
            
        }  
        catch(DMLException dex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dex.getDMLMessage(0))); 
        }   
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }      
        return null;
    }
    
     public Pagereference cancel() {
        
       // return new Pagereference('/'+ oppId);
        return null ;
    }
    
    
    
     public class SelectedTravellingCountry{
        
        Public  Travelling_Country__c objTC {get;set;}
        Public Boolean selected {get;set;}
        
        Public SelectedTravellingCountry(Travelling_Country__c tc, Boolean val)
        {
            this.objTC = tc;
            this.selected = val;
        }
        
    }
    

}
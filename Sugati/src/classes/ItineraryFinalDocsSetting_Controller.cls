public class ItineraryFinalDocsSetting_Controller {
    
    public string oppId;
    public Opportunity Opp{get;set;}
    public list <Itinerary_Content__c> lstForget {get;set;}
    public String lstForgetStr{get;set;}
    public set <string> Forget_TravelCountry {get;set;}
    public set <string> travelcountry {get;set;}
    public List<Selected_ICC_Copy__c> lstSICCO {get;set;}
    public String lstSICCOStr{get;set;}
    public Integer countSICCO {get;set;}
    public Integer countSICC {get;set;}
    public ID SICCO {get;set;}
    public List<Selected_Itinerary_Content_Category__c> lstSICC{get;set;}
    public string CLetterIntro {get;set;}
    public string CLetterEnd {get;set;}
    public string FLetterIntro {get;set;}
    public string FLetterEnd {get;set;}
    public Date Confirm_date {get;set;}
    Public set<string> setSB_Emergency {get;set;} 
    Public set<string> setSB_groundHandler {get;set;}
    
    Set<String> uniqueSupplier = new Set<String>();
     public ItineraryFinalDocsSetting_Controller(ApexPages.StandardController controller) {
        try{
            oppId = controller.getId();
            
              if (controller.getId() != null) {
                Opp = [select id, Name,O_Display_Due_Date__c,  Account.Name,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,Owner.FirstName,
                       O_Adult__c,O_Children__c,O_Infant__c,Amount,O_Outstanding__c,O_Booking_Currency__c,O_Itinerary_Cover_Name__c,O_Total_Payment__c,StageName,O_Due_Date__c
                       from Opportunity 
                where Id=:oppId];
                
              }
             
            lstSICCO = new List<Selected_ICC_Copy__c>();
            lstForget = new List<Itinerary_Content__c>();
            lstSICC = new List<Selected_Itinerary_Content_Category__c>();
            Forget_TravelCountry = new set<string>();
            travelcountry = new set<string>();
             CLetterIntro = ''; 
             CLetterEnd = '';
             FLetterIntro = ''; 
             FLetterEnd = '';
             DateTime F_date = Date.today();
             String Confirm_Date = F_date.formatGMT('dd MMMMM yyyy');
             Integer CountTravelC = 0;
             String TravelC ='';
             String Departure_Date ='';
             String DueDate ='';
                     
             
             /* Departure date */
             if(Opp.O_Departure_Date__c != NULL){
             DateTime Opp_Departure = Opp.O_Departure_Date__c;
              Departure_Date = Opp_Departure.formatGMT('dd MMMMM yyyy');  
             }
             
             /*Due Date */
              if(Opp.O_Due_Date__c != NULL){
             DateTime Opp_Due = Opp.O_Due_Date__c;
              DueDate = Opp_Due.formatGMT('dd MMMMM yyyy');  
             }
             
             
            /* Retrieve Travelling Countries */
           for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                       from Supplier_Booking__c 
                                        where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Dom Flights','Days at Leisure')) AND 
                                        SB_Opportunity__c = :Opp.Id
                                        Order by SB_Order__c ASC]) {
                                            
                                            if(s.SB_Where_to_go__c != NULL)
                                            Forget_TravelCountry.add(s.SB_Where_to_go__r.W_Country__r.Name);
                                          
                                    } 
             
              for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                                 where TC_Opportunity__r.Id= :OppId]){
            
                            travelcountry.add(t.TC_Country__r.name);
                                                              
                                 }
             
                
             
            /*  Retrieve Travelling Country for letter */
             
              CountTravelC = travelCountry.size();
             
             for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                                 where TC_Opportunity__r.Id= :OppId]){
            
                            
                            TravelC = TravelC + t.TC_Country__r.name;  
                                     
                                     if( CountTravelC >1 )
                                       TravelC  = TravelC +', ';
                              CountTravelC = CountTravelC - 1;           
    
                                 }
             /* for(Supplier_Booking__c s: [Select Name,SB_Supplier_Name__c,SB_Where_to_go__r.W_Country__r.Name,SB_Order__c
                                       from Supplier_Booking__c 
                                        where RecordTypeId in (SELECT Id FROM RecordType WHERE Name In ('Accommodation','Int Flight','Light Aircraft','Dom Flights','Days at Leisure')) AND 
                                        SB_Opportunity__c = :Opp.Id
                                        Order by SB_Order__c ASC]) {
                                            
                                            if(s.SB_Where_to_go__c != NULL)
                                             TravelC = TravelC + s.SB_Where_to_go__r.W_Country__r.Name;  
                                     
                                     if( CountTravelC >1 )
                                       TravelC  = TravelC +', ';
                              CountTravelC = CountTravelC - 1; 
                                            
                                          
                                    } */
             
          
          
          /* Retrieve content from Selected_ICC_Copy object  */  
            lstSICCO = [select Id,SICCO_Title__c,SICCO_Description__c,SICCO_Order__c,SICCO_Country__r.Name,CurrencyIsoCode,SICCO_Category__c,SICCO_Country__c,
                        SICCO_FinalDoc__c,SICCO_Confirmation_Letter__c
                        from Selected_ICC_Copy__c 
                        where SICCO_Category__r.ICC_Opportunity__c = :Opp.ID
                        AND SICCO_Category__r.SICC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                        AND ((SICCO_Country__r.Name in :travelcountry)OR (SICCO_Country__r.Name = ''))
                       // AND  RecordType.name =:Opp.RecordType.name
                        order by SICCO_Order__c];
             lstSICCOStr = JSON.serialize(lstSICCO);
             /* Retrieve content from Itinerary content */ 
             lstForget = new List<Itinerary_Content__c>();
             
             for(Itinerary_Content__c  ic : [select Id,IC_Title__c,IC_Description__c,IC_Order__c,IC_Country__r.Name, IC_Itinerary_Content_Category__c,IC_Country__c,RecordTypeId,CurrencyIsoCode,IC_ConfirmationLetter__c,IC_FinalDoc__c
                         from Itinerary_Content__c 
                         where IC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' 
                         AND ((IC_Country__r.Name in :travelcountry)OR (IC_Country__r.Name = ''))
                         
                         AND (IC_FinalDoc__c = TRUE OR IC_ConfirmationLetter__c = TRUE)
                         order by IC_Order__c]){
                 if(ic.IC_Title__c == 'Medical Advice'){
                     ic.IC_Description__c = '<span Class="label">'+ic.IC_Title__c+'</span><br/><br/>'+ic.IC_Description__c;
                 }       
                 lstForget.add(ic);    
             }
             lstForgetStr = JSON.serialize(lstForget); 
               /* Get SICCO Category ID */
               lstSICC = [select ID from Selected_Itinerary_Content_Category__c
                         where  ICC_Opportunity__c = :Opp.Id
                         AND SICC_Itinerary_Content_Category__r.Name = 'PLEASE DON\'T FORGET' ];
             
                   countSICCO =  lstSICCO.size();
                   countSICC = lstSICC.size();
             
            
       
            setSB_Emergency = new set<string>();
            string SBGroundHandler =''; 
            
            Map<String,List<Supplier_Booking__c>> mapOfSupplierBooking = new Map<String,List<Supplier_Booking__c>>();
            Map<String,List<Supplier_Booking__c>> mapOfSupplierBookingG = new Map<String,List<Supplier_Booking__c>>();
            for(Supplier_Booking__c s :[select RecordType.Name,SB_Booking_No__c,SB_Supplier__c ,SB_Supplier__r.S_Street__c,SB_Supplier__r.S_State__c,
                                         SB_Supplier__r.S_Postcode__c,SB_Supplier__r.S_City__c,SB_Supplier__r.S_Country__c,
                                         SB_Supplier__r.Name,SB_Supplier__r.S_Phone__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Supplier__r.S_Emergency_Phone_2__c,SB_Ground_Handler__r.S_Phone__c,SB_Ground_Handler__r.S_Street__c,SB_Ground_Handler__r.S_State__c,
                                     SB_Ground_Handler__r.S_Postcode__c,SB_Ground_Handler__r.S_City__c,SB_Ground_Handler__r.S_Country__c,   
                                     SB_Ground_Handler__r.S_Emergency_Phone__c,SB_Ground_Handler__r.S_Emergency_Phone_2__c,SB_Ground_Handler__c,SB_Ground_Handler__r.Name
                                       From Supplier_Booking__c Where SB_Opportunity__c = :Opp.Id  Order by SB_Order__c]){
                if(!mapOfSupplierBooking.containsKey(s.SB_Supplier__r.Name) && s.SB_Supplier__c != null){
                    mapOfSupplierBooking.put(s.SB_Supplier__r.Name, new List<Supplier_Booking__c>());
                }   
                mapOfSupplierBooking.get(s.SB_Supplier__r.Name).add(s);            
                
                if((s.recordType.Name == 'Transfer' ||  s.recordType.Name == 'Accommodation') && s.SB_Ground_Handler__c != null){
                    if(!mapOfSupplierBookingG.containsKey(s.SB_Ground_Handler__r.Name)){
                        mapOfSupplierBookingG.put(s.SB_Ground_Handler__r.Name, new List<Supplier_Booking__c>());
                    }   
                    mapOfSupplierBookingG.get(s.SB_Ground_Handler__r.Name).add(s);  
                }
            }   
                
                for(String str : mapOfSupplierBooking.keySet()){
                    Supplier_Booking__c s = mapOfSupplierBooking.get(str)[0];    
                     // Final Letter Emergency Details
                    string str_phone ='';
                    string str_phone2 ='';
                    string str_name ='';
                    string SBEmergency ='';
                    string str_groundHandlerName =''; 
                    string str_groundHandlerphone ='';
                    string str_groundHandlerphone2 ='';
                    String str_address = '';
                    String bookingRef = '';
                    
                    Integer countSB = 0;
                    for(Supplier_Booking__c s1 : mapOfSupplierBooking.get(str)){
                        if(s1.SB_Booking_No__c!= null){
                            countSB++;
                        }
                    }
                    
                    Integer ccc = 1;
                    for(Supplier_Booking__c s1 : mapOfSupplierBooking.get(str)){
                        if(s1.SB_Booking_No__c!= null){
                            bookingRef += s1.SB_Booking_No__c;
                            if(ccc != countSB){
                                bookingRef += ', ';
                            }
                            ccc++;
                        }
                    }
                    if(bookingRef != '' && ccc == 2){
                        bookingRef  = '- Booking reference: '+bookingRef ;
                    }
                    if(bookingRef != '' && ccc > 2){
                        bookingRef  = '- Booking references: '+bookingRef ;
                    }
                    
                    if(s.SB_Supplier__r.Name != NULL && s.SB_Supplier__r.Name !=''){
                            str_name = s.SB_Supplier__r.Name;
                    }
                    
                    if(s.SB_Supplier__r.S_Phone__c != NULL && s.SB_Supplier__r.S_Phone__c !=''){
                        str_phone =', '+s.SB_Supplier__r.S_Phone__c;
                    }
                    
                    if(s.SB_Supplier__r.S_Street__c != null)
                        str_address += s.SB_Supplier__r.S_Street__c+', ';
                    if(s.SB_Supplier__r.S_State__c != null)
                        str_address += s.SB_Supplier__r.S_State__c+', ' ;
                    if(s.SB_Supplier__r.S_Postcode__c!= null)
                        str_address += s.SB_Supplier__r.S_Postcode__c+', ';
                    if(s.SB_Supplier__r.S_City__c != null)
                        str_address += s.SB_Supplier__r.S_City__c+', ';
                    if(s.SB_Supplier__r.S_Country__c != null)
                        str_address += s.SB_Supplier__r.S_Country__c;
                    
                    if(!(setSB_Emergency.contains(s.SB_Supplier__r.Name ))){
                        setSB_Emergency.add(s.SB_Supplier__r.Name);
                        SBEmergency = SBEmergency + str_name+str_phone+str_phone2+'<br/>';
                        SBGroundHandler = SBGroundHandler + '<ul style="line-height:0; padding:0; line-spacing:0;"><li style="line-height:0; padding:0; line-spacing:0;"><strong>'+str_name +':</strong> '+str_address+' '+str_phone+' '+bookingRef+' </li></ul>';  
                    }
                    
                } 
                
               for(String str : mapOfSupplierBookingG.keySet()){
                    Supplier_Booking__c s = mapOfSupplierBookingG.get(str)[0];    
                    string str_phone ='';
                    string str_phone2 ='';
                    string str_name ='';
                    string SBEmergency ='';
                    string str_groundHandlerName =''; 
                    string str_groundHandlerphone ='';
                    string str_groundHandlerphone2 ='';
                    String str_address = '';
                    String bookingRef = '';
                                    
                                    
                    if(s.SB_Ground_Handler__r.Name != NULL && s.SB_Ground_Handler__r.Name !=''){
                        if(s.SB_Ground_Handler__c != NULL && s.SB_Ground_Handler__r.Name !='')
                            str_groundHandlerName = s.SB_Ground_Handler__r.Name;
                        if(s.SB_Ground_Handler__r.S_Phone__c != NULL && s.SB_Ground_Handler__r.S_Phone__c !='')
                            str_groundHandlerphone2 =', '+s.SB_Ground_Handler__r.S_Phone__c;
                        
                        Integer countSB = 0;
                        for(Supplier_Booking__c s1 : mapOfSupplierBookingG.get(str)){
                            if(s1.SB_Booking_No__c!= null){
                                countSB++;
                            }
                        }
                        
                        integer ccc = 1;
                        for(Supplier_Booking__c s1 : mapOfSupplierBookingG.get(str)){
                            if(s1.SB_Booking_No__c!= null){
                                bookingRef += s1.SB_Booking_No__c;
                                if(ccc != countSB){
                                    bookingRef += ', ';
                                }
                                ccc++;
                            }
                        }
                        if(bookingRef != '' && ccc == 2){
                            bookingRef  = '- Booking reference: '+bookingRef ;
                        }
                        if(bookingRef != '' && ccc > 2){
                            bookingRef  = '- Booking references: '+bookingRef ;
                        }  
                        if(s.SB_Ground_Handler__r.S_Street__c != null)
                            str_address += s.SB_Ground_Handler__r.S_Street__c+', ';
                        if(s.SB_Ground_Handler__r.S_State__c != null)
                            str_address += s.SB_Ground_Handler__r.S_State__c+', ' ;
                        if(s.SB_Ground_Handler__r.S_PostCode__c != null)
                            str_address += s.SB_Ground_Handler__r.S_PostCode__c+', ';
                        if(s.SB_Ground_Handler__r.S_City__c != null)
                            str_address += s.SB_Ground_Handler__r.S_City__c+', ' ;
                        if(s.SB_Ground_Handler__r.S_Country__c != null)
                            str_address  += s.SB_Ground_Handler__r.S_Country__c;
                            
                        if(!setSB_Emergency.contains(str_groundHandlerName) ){
                            SBGroundHandler = SBGroundHandler + '<ul style="line-height:0; padding:0; line-spacing:0;"><li style="line-height:0; padding:0; line-spacing:0;"><strong>'+str_groundHandlerName+':</strong> '+str_address+' '+str_groundHandlerphone+' '+bookingRef+' </li></ul>';     
                            setSB_Emergency.add(str_groundHandlerName);
                        }
                    }    
                    
                }
             
             
           
            CLetterIntro = CLetterIntro  + Confirm_date + '<br/><br/>' + 'Dear ';
            IF(Opp.O_Itinerary_Cover_Name__c != NULL)
                CLetterIntro = CLetterIntro + Opp.O_Itinerary_Cover_Name__c;
            else
                CLetterIntro = CLetterIntro;
            
            String suffix = '';
            if(Opp.O_Display_Due_Date__c> 60){
                suffix = ' (90 days prior to departure)';
            }
            else{
                suffix = ' (60 days prior to departure)';
            }
            
            If(Opp.O_Outstanding__c > 0)
                CLetterIntro = CLetterIntro  + '<br/><br/>' + 'It is with great pleasure that we attach your confirmation and itinerary for your holiday to ' +TravelC +'.' +' We are grateful to have received a deposit of '+Opp.O_Booking_Currency__c+' '+Opp.O_Total_Payment__c+'    to confirm all arrangements. Please note that your final balance is due by '+DueDate+''+suffix+' for the amount of '+Opp.O_Booking_Currency__c+' '+Opp.O_Outstanding__c+'. Please read through the attached itinerary and double check that all is in order.'+'<br/>';
            If(Opp.O_Outstanding__c == 0)
                CLetterIntro = CLetterIntro  + '<br/><br/>'+'We are grateful to have received full payment of '+ Opp.O_Booking_Currency__c+' '+Opp.O_Total_Payment__c+' to confirm all arrangements. Please read through the attached itinerary and double check that all is in order.';
           /*  
            IF(Opp.RecordType.name == 'OD' || Opp.RecordType.name == 'ST' || Opp.RecordType.name == 'OT') 
                CLetterEnd  = CLetterEnd + '<Strong>N.B. While every care has been taken in preparing our travel advice, neither Original Travel nor any member of its staff abroad can accept liability for injury, loss or damage arising in any respect of any statement contained therein.</Strong><br/><br/>';
             
            CLetterEnd  = CLetterEnd + 'Please do not hesitate to give me a call if you have any queries on the above or on your enclosed itinerary. On behalf of ';
            
            IF(Opp.RecordType.name == 'OD') 
                CLetterEnd  = CLetterEnd + 'Original Diving';
            else IF(Opp.RecordType.name == 'ST')
                CLetterEnd  = CLetterEnd + 'Simoon Travel';
            else IF(Opp.RecordType.name == 'OT')
                CLetterEnd  = CLetterEnd + 'Original Travel';
            
            CLetterEnd  = CLetterEnd +' we thank you for booking with us and hope that you have a wonderful time in '+TravelC+'.'; 
            
            FLetterIntro = FLetterIntro  + Confirm_date + '<br/><br/><br/><br/>' + 'It is with great pleasure that I enclose your final itinerary and pack for your holiday to '+TravelC+' departing on the '+Departure_Date+'. These are some further notes which we hope will facilitate your travels:'+'<br/>';
          
            IF(Opp.RecordType.name == 'OD' || Opp.RecordType.name == 'ST' || Opp.RecordType.name == 'OT') 
                FLetterEnd = FLetterEnd + '<Strong>N.B. While every care has been taken in preparing our travel advice, neither Original Travel nor any member of its staff abroad can accept liability for injury, loss or damage arising in any respect of any statement contained therein.</Strong><br/><br/>';
            
            FLetterEnd = FLetterEnd + '<span style="color:#000000"><strong><span style="font-size:11.5px">Important Contact Details</span></strong></span>'+'<br/>';
           // FLetterEnd = FLetterEnd + SBEmergency+SBGroundHandler+'<br/>'+'Alternatively you can call ';
            if(SBGroundHandler != '')
                 FLetterEnd = FLetterEnd + SBGroundHandler+'Alternatively you can call ';
             else
                 FLetterEnd = FLetterEnd +'<br/>Alternatively you can call ';
                 
               IF(Opp.RecordType.name == 'OD') 
                  FLetterEnd  = FLetterEnd + 'Original Diving\'s';
             else IF(Opp.RecordType.name == 'ST')
                   FLetterEnd  = FLetterEnd + 'Simoon Travel\'s';
              else IF(Opp.RecordType.name == 'OT')
                   FLetterEnd  = FLetterEnd + 'Original Travel\'s';
             
            FLetterEnd = FLetterEnd + '<Strong> emergency number on + 44 20 7978 7333.</Strong>'+' Outside of office hours (6pm – 9am) we have a 24 hour team who are on hand to answer any calls and subsequently contact myself or one of my colleagues. Please do pass these numbers as a form of contact for friends and relatives should you wish.<br/><br/>';
           // FLetterEnd = FLetterEnd + TravelC +' and I very much look forward to hearing your feedback on your return.'+'<br/><br/>';
            FLetterEnd = FLetterEnd + '<Strong>Relevant Exchange Rates:</Strong>'+'<br/>'+'The current exchange rate for the [Insert currency name] [Insert currency symbol] to Sterling is:'+'<br/>'+'1 GBP = [insert rate to 2 decimal points] [insert currency symbol]';
            FLetterEnd = FLetterEnd + '<br/><br/>'+'Please do not hesitate to give me a call if you have any queries on the above or on your enclosed itinerary. On behalf of ';
              
             IF(Opp.RecordType.name == 'OD') 
                  FLetterEnd  = FLetterEnd + 'Original Diving';
             else IF(Opp.RecordType.name == 'ST')
                   FLetterEnd = FLetterEnd + 'Simoon Travel';
              else IF(Opp.RecordType.name == 'OT')
                   FLetterEnd  = FLetterEnd + 'Original Travel';
             
             FLetterEnd = FLetterEnd + ' I hope that you have a wonderful time in '+TravelC+' and I very much look forward to hearing your feedback on your return.';  
            */  
          }
          Catch(Exception e){
              System.debug('VVVVVVVVVVVVVVVVVVVVVVVVV'+e.getStackTraceString()+'ddddd'+e.getMessage());
          } 
      }
    
     public Pagereference save() {
        
        try{
           //system.assert(false, 'testing...' + countSICCO);
            If(countSICCO <= 0)  
               {
                  
                   if(countSICC > 0)
                   {
                       
                    SICCO = lstSICC[0].ID;
                   
                    /* Insert records from Itinerary content to Copied Object */
                    for(Itinerary_Content__c ic :lstForget){
                         lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Country__c=ic.IC_Country__c,SICCO_Title__c = ic.IC_Title__c,SICCO_Description__c = ic.IC_Description__c,SICCO_Order__c = ic.IC_Order__c, CurrencyIsoCode=ic.CurrencyIsoCode,SICCO_FinalDoc__c = ic.IC_FinalDoc__c,SICCO_Confirmation_Letter__c= ic.IC_ConfirmationLetter__c)); 
                    }
                    insert lstSICCO;
                    lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Confirmation Letter Intro',SICCO_Description__c =CLetterIntro,SICCO_FinalDoc__c=FALSE,SICCO_Confirmation_Letter__c=TRUE,SICCO_Order__c = '0',CurrencyIsoCode='GBP')); 
                    lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Confirmation Letter Closing',SICCO_Description__c =CLetterEnd,SICCO_FinalDoc__c=FALSE,SICCO_Confirmation_Letter__c=TRUE,SICCO_Order__c = '998',CurrencyIsoCode='GBP')); 
                    lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Final Letter Intro',SICCO_Description__c =FLetterIntro,SICCO_FinalDoc__c=TRUE,SICCO_Confirmation_Letter__c=FALSE,SICCO_Order__c = '0',CurrencyIsoCode='GBP')); 
                    lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Final Letter Closing',SICCO_Description__c =FLetterEnd,SICCO_FinalDoc__c=TRUE,SICCO_Confirmation_Letter__c=FALSE,SICCO_Order__c = '999',CurrencyIsoCode='GBP')); 
                    
                   }
             
               }
         //System.assert(false, lstSICCO);
         upsert lstSICCO;
         return null;
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
      
        return null;
    }

}
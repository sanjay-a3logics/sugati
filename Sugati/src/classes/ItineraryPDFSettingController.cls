public with sharing class ItineraryPDFSettingController {

    public List<Supplier_Booking__c> supplierBookings1{get;set;}
    Public List<WhereYouWillStay> supplierBookings2{get;set;}
    public string oppId;
    public Opportunity Opp{get;set;}
    public String sbId{get;set;}
    Public string hType;
    public String aa{get;set;}
    Public List<string> HolidayType = new List<string>();
    public  Map<String, Supplier_Booking__c> mapOldSBIds{get;set;}
    public  List<Supplier_Booking__c> lstSB{get;set;}
    Public Map<string,boolean> mapIT_Check1 {get;set;} 
    public Boolean youWillStay{get; set;}
    public List<String> IntroImgsIds {get;set;}
    public Selected_Itinerary_Content_Category__c SICCIntro {get;set;}
    public String containsSB{get; set;}
    public List<DestinationImages> DestinationImgs{get; set;}
    public Boolean IsCountryMap{get; set;}
    public String typeOfMap {get; set;}
    public String accommodationOrRegion {get; set;}
    public Map<Id, Travelling_Country__c> mapTCRecords {get;set;}
    public Boolean IsSingleMap{get; set;}
    public String nameSpacePrefix{get;set;}
    public List<Client_Group__c> lstClientGroups {get;set;}
    String returnPage;
    
    
    Map<Decimal,Supplier_Booking__c> mapSupplierBookings = new Map<Decimal,Supplier_Booking__c>();
    public ItineraryPDFSettingController(ApexPages.StandardController controller) {
        try{
            oppId = controller.getId();
            ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'HolidayEnquiryController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            containsSB = '';
            mapTCRecords = new Map<Id, Travelling_Country__c>();
            DestinationImgs = new List<DestinationImages>();
            if(ApexPages.CurrentPage().getParameters().get('Page') != null && ApexPages.CurrentPage().getParameters().get('Page') != '')
                returnPage = '/apex/ItineraryBuilder?id='+oppId;
            else
                returnPage = '/'+oppId;
            youWillStay = false;
              if (controller.getId() != null) {
                Opp = [select id, Name,Account.Name,O_Agent__r.id,O_Agent__r.Name,O_Show_Option_text_for_quotation__c, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                       O_Adult__c,O_Children__c,O_Infant__c,O_Map_Type__c,O_Holiday_Type__c,O_Quotation_Default_Text__c,O_Quotation_Type__c,Amount,O_Outstanding__c,O_Destination_Map_Image_ID__c,O_Booking_Currency__c,
                       (Select Id, name, TC_Country__r.Name,TC_DestinationMap_Image_ID__c,TC_Accommodation_Region__c from Travelling_Countries__r order by TC_Country__r.Name)
                       from Opportunity 
                where Id=:oppId];
                //(Select Id, OS_Opportunity__c, OS_Supplier__c, OS_Your_Guide__c,OS_Supplier__r.Name from Opportunity_Supplier_Guides__r limit 2),            
               if(opp.O_Quotation_Type__c == null)
                   opp.O_Quotation_Type__c = 'Default';
               
               for(Travelling_Country__c tc : Opp.Travelling_Countries__r){
                   Boolean hasImages = false;
                   if(tc.TC_Accommodation_Region__c == null)
                       tc.TC_Accommodation_Region__c = 'Region';
                   mapTCRecords.put(tc.id, tc);
                   if(tc.TC_DestinationMap_Image_ID__c != null)
                       hasImages =  true;
                   DestinationImgs.add(new DestinationImages(tc.TC_Country__r.Name,hasImages,tc.TC_DestinationMap_Image_ID__c ,tc.id ));    
               }
               if(opp.O_Show_Option_text_for_quotation__c == null){
                    opp.O_Show_Option_text_for_quotation__c = false;       
               }
               
               if(Opp.O_Holiday_Type__c != NULL)
               { 
                   hType=Opp.O_Holiday_Type__c;
               
                HolidayType.add(hType);
               }
                   
               if(opp.O_Map_Type__c == null || opp.O_Map_Type__c == '')
                   opp.O_Map_Type__c = 'Single';     
                   
               lstSB = new List<Supplier_Booking__c>();
               supplierBookings1 = new List<Supplier_Booking__c>();
               supplierBookings2 = new List<WhereYouWillStay>();
               mapOldSBIds = new Map<String,Supplier_Booking__c>(); 
               mapIT_Check1 = new MAP<string,boolean>();
               
               
               List<String> setOfCountries = new List<String>();
               for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                   setOfCountries.add(tc.TC_Country__r.Name);
               } 
               
              
               
            
            for (Supplier_Booking__c  sb:[select id, name, SB_Day__c,recordtype.name,SB_Departure_Airport_l__c ,SB_Own_Arrangement__c, SB_Arrival_Airport_l__c,SB_From_Place__c , SB_To_Place__c ,SB_Name__c, SB_Transfer_Car_Hire_Option__c, SB_What_To_Do__r.Name, 
                                        SB_Supplier__r.Name, SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c,SB_Order__c,SB_Supplier__c,
            (select id,SBI_Attachement_Id__c,SBI_Order__c  from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 order by SBI_Order__c)
            from Supplier_Booking__c 
            where SB_Opportunity__c =: controller.getId() Order by SB_Day__c,SB_Order__c ]) {           
    
                 if(sb.recordtype.name =='Accommodation' || sb.recordtype.name =='Car Hire' || sb.recordtype.name =='Days at Leisure' ||
                       sb.recordtype.name =='Domestic Flight' || sb.recordtype.name =='Excursion' || sb.recordtype.name =='Int Flight' ||
                       sb.recordtype.name =='Light Aircraft' || sb.recordtype.name =='Notes' || sb.recordtype.name =='Own arrangement' 
                       || sb.recordtype.name =='Rail'|| sb.recordtype.name =='Transfer'|| sb.recordtype.name =='Description')
                 {
                    supplierBookings1.add(sb);
                }
                
                 if (sb.recordtype.name == 'Accommodation' && sb.SB_Supplier__c != NULL) {
                  
                     mapOldSBIds.put(sb.SB_Supplier__c, sb); 
                     //lstSB.add(sb);
                }
                if(!mapSupplierBookings.containsKey(sb.SB_Day__c)){
                    mapSupplierBookings.put(sb.SB_Day__c,sb);
                    sb.SB_New_Page__c = true;
                }
                
           }
           //**Updated 23-12**/
           for (Supplier_Booking__c  sb:[select id, name, recordtype.name,SB_Departure_Airport_l__c , SB_Arrival_Airport_l__c,SB_From_Place__c , SB_To_Place__c ,SB_Name__c, SB_Transfer_Car_Hire_Option__c, SB_What_To_Do__r.Name, 
                                        SB_Supplier__r.Name,SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c,SB_Order__c,SB_Supplier__c,
            (select id,SBI_Attachement_Id__c,SBI_Order__c  from SupplierBookingImages__r where (SBI_Order__c = 3 or SBI_Order__c = 4) order by SBI_Order__c)
            from Supplier_Booking__c 
            where SB_Opportunity__c =: controller.getId() and recordtype.name = 'Accommodation' and SB_Supplier__c != NULL Order by SB_Order__c ]){
                 lstSB.add(sb);
           }
            
           List<String> lstSBSuppIds = new List<String>();
           for(Supplier_Booking__c  sb : lstSB)
             lstSBSuppIds.add(sb.SB_Supplier__c); 
            
         
            // system.debug('mapoldSBIds'+mapOldSBIds.keySet());
           Map<String,Itinerary_Text__c> mapQT = new Map<String,Itinerary_Text__c>();
           Map<String,String> mapQTmsg = new Map<String,String>();       
           for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                  from Itinerary_Text__c                                    
                                  where (IT_Holiday_Type__c In :HolidayType)
                                  AND IT_SUPPLIER__C in :lstSBSuppIds and IT_Status__c = 'Approved' order by IT_SUPPLIER__C desc ]){  
                                      
                   mapIT_Check1.put(qt.IT_SUPPLIER__C,TRUE);  
                   mapQT.put(qt.IT_Supplier__c,qt);
                   mapQTmsg.put(qt.IT_Supplier__c,qt.IT_Message__c);
                  //supplierBookings2.add(new WhereYouWillStay(mapOldSBIds.get(qt.IT_SUPPLIER__C),qt.IT_Message__c,qt));                         
           }   
            for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c
                                  from Itinerary_Text__c                                    
                                  where (IT_Holiday_Type__c NOT In :HolidayType AND IT_Holiday_Type__r.Name='Generic')
                                  AND IT_SUPPLIER__C in :lstSBSuppIds and IT_Status__c = 'Approved' order by IT_SUPPLIER__C desc ]){                              
                                      if(!mapIT_check1.containsKey(qt.IT_SUPPLIER__C))
                                      {
                                         mapQT.put(qt.IT_Supplier__c,qt);
                                         mapQTmsg.put(qt.IT_Supplier__c,qt.IT_Message__c);
                                      }
                  //supplierBookings2.add(new WhereYouWillStay(mapOldSBIds.get(qt.IT_SUPPLIER__C),qt.IT_Message__c,qt));                         
           }    
           Set<String> suppIds = new Set<String>();
           for(Supplier_Booking__c sb : lstSB){
               if(!suppIds.contains(sb.SB_Supplier__c)){ 
                   supplierBookings2.add(new WhereYouWillStay(sb,mapQTmsg.get(sb.SB_SUPPLIER__C),mapQT.get(sb.SB_SUPPLIER__C)));
                   suppIds.add(sb.SB_Supplier__c);    
               }        
           }
           
           system.debug('********'+supplierBookings2);
           system.debug('***mapQT*****'+mapQT);
           system.debug('****mapQTmsg****'+mapQTmsg);
               
                    
            }
            
            
          //   for(integer i=0;i<supplierBookings2.size();i++)
        //    system.debug('lstWhereStay'+supplierBookings2[i].qt);
            
               //system.assert(false, supplierBookings2);     
               SICCIntro = new Selected_Itinerary_Content_Category__c();
               IntroImgsIds = new List<String>();  
               
               for(Selected_Itinerary_Content_Category__c SICC : [select id,name from Selected_Itinerary_Content_Category__c where ICC_Opportunity__c =: oppId and SICC_Itinerary_Content_Category__r.name = 'INTRODUCTION']){
                   SICCIntro = SICC;
               }
               for(Introduction_Image__c at :[select id,II_Attachement_Id__c from Introduction_Image__c where II_Selected_Content_Category__c =: SICCIntro.Id limit 3]){
                   IntroImgsIds.add(at.II_Attachement_Id__c);
               }  
                 
               for(Decimal d : mapSupplierBookings.keySet()){
                   containsSB +=  mapSupplierBookings.get(d).Id+' ';   
               }   
               
               lstClientGroups = [Select name, CG_PDF_Quotation__c from Client_Group__c where CG_Opportunity__c =: opp.Id];
           }
           Catch(Exception e){
              ApexPages.addMessages(e);
           }
           
      }
     
    public Pagereference save() {
        
        try{
             
            List<Itinerary_Text__c> lstOfQuoteText = new List<Itinerary_Text__c>(); 
            List<Supplier_Booking__c> lstOfSB = new List<Supplier_Booking__c>();
            for (WhereYouWillStay ws: supplierBookings2) {
                if (ws.qtMsg != NULL) {
                    if(ws.QT != null){ 
                        ws.QT.IT_Message__c = ws.qtMsg ;
                    }  
                    lstOfSB.add(ws.sb);
                    lstOfQuoteText.add(ws.QT);
                }
            }
            upsert lstOfSB; 
            upsert lstOfQuoteText;
             
             List<SupplierBookingImage__c> lstImages = new List<SupplierBookingImage__c>();
             for(Supplier_Booking__c sb : supplierBookings1){
                 if(!sb.SB_New_Page__c){
                     lstImages.addAll(sb.SupplierBookingImages__r);    
                 }
             }
             
             update lstClientGroups;
             upsert supplierBookings1;
             upsert opp;
             upsert mapTCRecords.values();
             //Save Your Guides
             //saveGuides();
             //system.assert(false, opp);
        }  
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
            
        }    
        return null;  
    }
    
    
    //Fetch all the PDF Setting Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('PDFSetting'));
    }
    
    public void callController(){}
    
    public Pagereference changeImage() {
        
        try {
            Boolean IsSb = false;
            save();
            Pagereference pf;
            
            for(Supplier_Booking__c Sb : [select Id,name from Supplier_Booking__c where Id =: sbId]){
                if(SB != null){
                    IsSb = true;
                    pf = new Pagereference(Page.selectImages.getUrl()+'?id=' + sbId+'&stay='+youWillStay+'&IsSB=true');
                }
            }
            
            if(IsSb == false){
                pf = new Pagereference(Page.selectImages.getUrl()+'?id=' + sbId+'&stay='+youWillStay+'&IsSB=false');
            }
            if(IsCountryMap){
                pf = new Pagereference(Page.selectImages.getUrl()+'?id=' + sbId+'&IsCountryMap=true&IsSB=false');
            }
            
            if(IsSingleMap){
                pf = new Pagereference(Page.selectImages.getUrl()+'?id=' + opp.id+'&SingleMap=true&IsSB=false');
            }
            return pf;
        }
        catch(Exception e) {
            
            Apexpages.addMessages(e);
            return null;
        }
        
    }
    
    public Pagereference cancel() {
        
        return new PageReference(returnPage);
    }
        
    public class WhereYouWillStay
    {
        public Supplier_Booking__c sb{get;set;}
        public Itinerary_Text__c QT{get;set;}
        
        public string qtMsg {get;set;}
        public WhereYouWillStay(Supplier_Booking__c s,string str, Itinerary_Text__c qt  ){
            sb = s;
            this.QT = qt;
            qtMsg = str;
            
        }
    } 
    
    public class DestinationImages{
        public String Countryname{get;set;}
        public Boolean HasImage{get;set;}
        public String ImgId{get;set;}
        public String TCId{get; set;}
        
        public DestinationImages(String Countryname,Boolean HasImage, String ImgId, String TCId){
            this.Countryname = Countryname;
            this.HasImage = HasImage;
            this.ImgId = ImgId;
            this.TCId = TCId;
        }    
    }
    
    public void SaveIntroImgs(){
       List<Introduction_Image__c> lstSICCImgs = new List<Introduction_Image__c>(); 
       if(IntroImgsIds.size() == 0){
            List<String> countries = new List<String>();
            for (travelling_country__c tc : [select id,tc_country__c,tc_opportunity__c 
            from Travelling_Country__c where tc_opportunity__c =: oppId]) {
                countries.add(tc.tc_country__c);
            }
            for(Attachment att : [select id,ParentId,BodyLength,Body,IsDeleted,IsPrivate,ContentType,Description,Name from Attachment where parentId in: countries  and (NOT (Name  like '%cover%'))
                            order by lastmodifieddate desc limit 3]){
                
                Introduction_Image__c NewAt = new Introduction_Image__c();
                NewAt.II_Selected_Content_Category__c = SICCIntro.Id;
                NewAt.II_Opportunity__c = oppId;
                NewAt.II_Attachement_Id__c = att.id;
                IntroImgsIds.add(att.Id);
                lstSICCImgs.add(NewAt);
            }
       }
       upsert lstSICCImgs;
    }
    
    
    // Get Map Type options
    public List<SelectOption> getTypeOfMapOptions(){
        List<SelectOption> lstOpt = new List<SelectOption>();    
        lstOpt.add(new SelectOption('Single', 'Single')); 
        lstOpt.add(new SelectOption('Multiple', 'Multiple')); 
        return lstOpt;   
    }
    
    // Get Accommodation/Region options
    public List<SelectOption> getAccommodationRegionOption(){
        List<SelectOption> lstOpt = new List<SelectOption>();    
        lstOpt.add(new SelectOption('Region', 'Region')); 
        lstOpt.add(new SelectOption('Accommodation', 'Accommodation')); 
        return lstOpt;   
    }
    
    
    //public List<yourGuideWrapper> lstGuideWrapper{get; set;}
    public String selectedSupplier{get; set;}
    //Get Your Gudies
    /* 
    public void getYourGuides(){
        lstGuideWrapper = new List<yourGuideWrapper>();
        for(Opportunity_Supplier__c os : opp.Opportunity_Supplier_Guides__r){
            lstGuideWrapper.add(new yourGuideWrapper(os, os.OS_Supplier__c, os.OS_Supplier__r.Name));
        }
        for(Integer i=0; i<2-lstGuideWrapper.size(); i++){
            lstGuideWrapper.add(new yourGuideWrapper(new Opportunity_Supplier__c(OS_Opportunity__c = opp.Id),'',''));
        }
        //System.assert(False,lstGuideWrapper);
    }
    */
    //Guide Wrapper Class
    /*
    public Class yourGuideWrapper{
        public String supplierId{get; set;}
        public String supplierName{get; set;}
        public Opportunity_Supplier__c guide{get; set;}
        
        public yourGuideWrapper(Opportunity_Supplier__c os, String supplierId, String supplierName){
            guide = os;
            this.supplierId = supplierId;
            this.supplierName = supplierName;
        }
    }
    */
    //Get the guideDetail
    /*
    public void guideDetail(){
        Set<Id> setOfSupplier = new Set<Id>();
        for(yourGuideWrapper ygw : lstGuideWrapper){
            if(ygw.supplierId != null && ygw.supplierId != ''){
                setOfSupplier.add(ygw.supplierId);
            }
        }
        
        Map<String,Supplier__c> mapSupplier = new Map<String,Supplier__c>();
        for(Supplier__c sup : [Select Id, S_Your_Guide__c from Supplier__c where Id in :setOfSupplier]){
            mapSupplier.put(sup.Id,sup);
        }
       
        for(yourGuideWrapper ygw : lstGuideWrapper){
            if(ygw.supplierId != null && ygw.supplierId != ''  && (ygw.guide.OS_Your_Guide__c == null || ygw.guide.OS_Your_Guide__c == '')){
                ygw.guide.OS_Supplier__c = ygw.supplierId;
                ygw.guide.OS_Your_Guide__c =  mapSupplier.get(ygw.supplierId).S_Your_Guide__c;
            }
        }
    }
    */
    /*
    public void saveGuides(){
        List<Opportunity_Supplier__c> lstYourGuide = new List<Opportunity_Supplier__c>();
        for(yourGuideWrapper ygw : lstGuideWrapper){
            if(ygw.supplierId != null && ygw.supplierId != ''){
                ygw.guide.OS_Supplier__c = ygw.supplierId;
                lstYourGuide.add(ygw.guide);    
            }
        }
        upsert lstYourGuide;
        
    }
    */    
}
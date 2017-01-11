public with sharing class SupplierBookingSwapImagesController{
    
    public string searchText{get;set;}
    public transient List<Supplier_Booking__c> lstHolidaySuggestion{get;set;}
    public List<HolidaySuggestionImagesWrapper > lstWheretogoWrapper{get;set;}
    
    public String  OppId{get;set;}
    public string selectedRecordIds{get;set;}
    public string deletedRecordIds{get;set;}
    public Set<String> selectedHSIds{get;set;}    
    
    Set<String> existingRecordIds;    
    public String displayMessage{get;set;}
    String supplierBookingId;
    Map<String,string> mapHolidaySuggestion;
    String isWillStay = 'false';
    public String ObjId;
    public Boolean IsSb{get; set;}
    public Boolean IsCountryMap{get; set;}
    public Boolean isSingleMap {get;set;}
    public Travelling_Country__c tc;
    public Opportunity oppPDF;
    
    
    Map<String,SupplierBookingImage__c> mapSBI = new Map<String,SupplierBookingImage__c>();
    public SupplierBookingSwapImagesController(ApexPages.StandardController controller){}
    public SupplierBookingSwapImagesController() {
        try{
            displayMessage ='';
            OppId = '' ;
            selectedHSIds = new Set<String>();
            existingRecordIds = new Set<String>();
            ObjId = '';
            IsSb = false;
            IsCountryMap = false;
            isSingleMap = false;
            tc = new Travelling_Country__c();
            
            ObjId = Apexpages.currentPage().getParameters().get('Id');
            IsSb = Boolean.valueOf(Apexpages.currentPage().getParameters().get('IsSB'));
            String mapCountry = Apexpages.currentPage().getParameters().get('IsCountryMap');
            String SingleMap = Apexpages.currentPage().getParameters().get('SingleMap');
            
            if(mapCountry != null)
                IsCountryMap = Boolean.valueOf(mapCountry);
                
            if(SingleMap != null)            
                isSingleMap = Boolean.valueOf(SingleMap);
                
            if(IsCountryMap){
               lstWheretogoWrapper = new List<HolidaySuggestionImagesWrapper>();     
               
               tc = [select Id,Name,TC_Country__c,TC_Country__r.name,TC_Country__r.C_Notes__c,TC_DestinationMap_Image_ID__c,TC_Opportunity__c from Travelling_Country__c where Id = :ObjId];
               OppId = tc.TC_Opportunity__c;
                                  
               for (Attachment att : [select id, parentId,name from attachment where parentId =: tc.TC_Country__c and name like '%Map%']) {
                     if(tc.TC_DestinationMap_Image_ID__c != null && tc.TC_DestinationMap_Image_ID__c == att.Id){
                         lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, true,att.name));
                     }
                     else{
                         lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, false,att.name));
                     }
               }
            }
            else if (IsSb) {
                supplierBookingId = ObjId;
                isWillStay = ApexPages.currentPage().getParameters().get('stay');
                mapHolidaySuggestion = new Map<String,String>();
                for ( Supplier_Booking__c sb: [select id, SB_Where_to_go__c,SB_Opportunity__c
                                       from Supplier_Booking__c
                                       where id=:supplierBookingId ]) {
                   OppId = sb.SB_Opportunity__c ;
                   if (sb.SB_Where_to_go__c!= null) {
                       mapHolidaySuggestion.put('WTG',sb.SB_Where_to_go__c);
                       
                   }
                     
                }
                
                String query = '';
                if(isWillStay == 'true'){
                    query = 'Select id,SBI_Order__c,SBI_Attachement_Id__c from SupplierBookingImage__c where SBI_Supplier_Booking__c=: supplierBookingId and (SBI_Order__c = 3 or  SBI_Order__c = 4)';
                }
                else{
                    query = 'Select id,SBI_Order__c,SBI_Attachement_Id__c from SupplierBookingImage__c where SBI_Supplier_Booking__c=: supplierBookingId and (SBI_Order__c != 3 and SBI_Order__c != 4)';
                }
                
                for (SupplierBookingImage__c hsi: Database.Query(query )) {
                    existingRecordIds.add(hsi.SBI_Attachement_Id__c);
                    mapSBI.put(hsi.SBI_Attachement_Id__c,hsi);
                }
                lstWheretogoWrapper = new List<HolidaySuggestionImagesWrapper>();     
                                  
               for (Attachment att : [select id, parentId,name from attachment 
               where id in: existingRecordIds]) {
                     HolidaySuggestionImagesWrapper  hsw = new HolidaySuggestionImagesWrapper (att.parentid, att.id, true,att.name);
                     hsw.order = mapSBI.get(att.id).SBI_Order__c;
                     lstWheretogoWrapper.add(hsw);    
              /*  Rajeev  30-9          
                   if (mapHolidaySuggestion.containskey('WTG')) {               
                       lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, true));
                   }
               */    
               }
           
           
            }
            else if(isSingleMap){
               lstWheretogoWrapper = new List<HolidaySuggestionImagesWrapper>();     
               Set<String> setIds = new Set<String>();
               for(Travelling_Country__c tc : [select Id,Name,TC_Country__c,TC_Country__r.name,TC_Country__r.C_Notes__c,TC_DestinationMap_Image_ID__c,TC_Opportunity__c from Travelling_Country__c]){
                   setIds.add(tc.TC_Country__c);
               }  
               selectedHSIds.addAll(setIds);             
               oppPDF = [select id,O_Destination_Map_Image_ID__c from Opportunity where id =:ObjId];
               OppId = oppPDF.id;                   
               for (Attachment att : [select id, parentId,name from attachment where parentId in : setIds and name like '%Map%']) {
                     if(oppPDF.O_Destination_Map_Image_ID__c != null && oppPDF.O_Destination_Map_Image_ID__c == att.Id){
                         lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, true,att.name));
                     }
                     else{
                         lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, false,att.name));
                     }
               }
            }
            else{
                lstWheretogoWrapper = new List<HolidaySuggestionImagesWrapper>(); 
                /** Getting existing selected images from */
                for(Selected_Itinerary_Content_Category__c SICC : [select id,name,ICC_Opportunity__c from Selected_Itinerary_Content_Category__c where Id = : ObjId]){
                    OppId = SICC.ICC_Opportunity__c;
                }
                
                String introductionID = null;
                for(Itinerary_Content_Category__c icc : [Select ID from Itinerary_Content_Category__c where name = 'INTRODUCTION' Limit 1]){
                    introductionID = icc.Id;
                }
                Set<String> imageIds = new Set<String>();
                for(Introduction_Image__c att :[select id,Name,II_Attachement_Id__c,II_Selected_Content_Category__c from 
                                                Introduction_Image__c where II_Selected_Content_Category__c =: ObjId ]){
                    imageIds.add(att.II_Attachement_Id__c);
                }
                for(Attachment att :[select id,name,ParentId from attachment where ParentId =:introductionID and Id in :imageIds  order by Name]){
                    lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, true ,att.name));
                }
                for(Attachment att :[select id,name,ParentId from attachment where ParentId =:introductionID and Id not in :imageIds order by Name]){
                    lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, att.id, imageIds.contains(att.id),att.name));
                }
                /** End */
            }
        }
       Catch(Exception e){
            ApexPages.addMessages(e);
       }
    }
    
    public void doSearch() {
    
        try {
            If(IsCountryMap){
                selectedHSIds.add(selectedRecordIds);
                selectedHSIds.remove(deletedRecordIds); 
                selectedHSIds.add(ObjId);    
                for (Attachment att : [select id, parentId,name from attachment 
                where (parentId in:selectedHSIds) and (Name like '%map%') ]) {
                       
                           lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid,
                           att.id,false,att.name));
                      
                }    
            }
            else if(isSingleMap){
                //selectedHSIds.add(selectedRecordIds);
                //selectedHSIds.remove(deletedRecordIds); 
                //selectedHSIds.add(ObjId);    
                for (Attachment att : [select id, parentId,name from attachment 
                where (parentId in:selectedHSIds) and (Name like '%map%') ]) {
                       
                           lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid,
                           att.id,false,att.name));
                      
                }    
            }
            else if(IsSb){
                selectedHSIds.add(selectedRecordIds);
                selectedHSIds.remove(deletedRecordIds);           
                selectedHSIds.addAll(existingRecordIds );
                lstWheretogoWrapper = new List<HolidaySuggestionImagesWrapper>();     
                                  
                for (Attachment att : [select id, parentId,name from attachment 
                where (id in: existingRecordIds) and (NOT Name like '%cover%') ]) {
                       HolidaySuggestionImagesWrapper  hsw = new HolidaySuggestionImagesWrapper (att.parentid, 
                       att.id,existingRecordIds.contains(att.id) ,att.name);
                       if(mapSBI.containsKey(att.id)){
                           hsw.order = mapSBI.get(att.id).SBI_Order__c;
                       }
                       lstWheretogoWrapper.add(hsw);
                 
                }
                for (Attachment att : [select id, parentId,name from attachment 
                where id not in: existingRecordIds and parentId in:selectedHSIds  and (NOT Name like '%cover%') ]) {
                       lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid, 
                       att.id,existingRecordIds.contains(att.id) ,att.name));
                 
                }
            }
            else{
                selectedHSIds.add(selectedRecordIds);
                selectedHSIds.remove(deletedRecordIds); 
                selectedHSIds.add(ObjId);    
                for (Attachment att : [select id, parentId,name from attachment 
                where (parentId in:selectedHSIds) and (NOT Name like '%cover%') ]) {
                       
                           lstWheretogoWrapper.add(new HolidaySuggestionImagesWrapper (att.parentid,
                           att.id,false,att.name));
                      
                }
            }
        }
        catch(Exception e ) {
            throw e;
        }   
        
    }   
    public class HolidaySuggestionImagesWrapper {
        public string recordId{get;set;}
        public String attachmentId{get;set;}
        public Boolean isselected{get;set;}
        public String ImageName{get;set;}
        public Decimal order{get; set;}
        
        public HolidaySuggestionImagesWrapper(String recordId, string attachmentId, Boolean isselected, String ImageName) {
            this.recordId = recordId;
            this.attachmentId = attachmentId;
            this.isselected= isselected;
            this.ImageName = ImageName;
        }
    }
    public Pagereference save() {
        
        Savepoint sp = Database.setSavepoint();
        try {
            if(IsCountryMap){
                displayMessage ='';
                integer selectedImagesCount = 0;
                Set<String> attachmentIds = new Set<String>();
                for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                    if (hsw.isSelected) {
                        selectedImagesCount  ++;
                        attachmentIds.add(hsw.attachmentId);
                    }
                }
                
                
                if (selectedImagesCount  > 1) {
                    displayMessage = 'Please select only one image';
                    return null;
                }
                else {
                     for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                        if (hsw.isSelected) {
                            tc.TC_DestinationMap_Image_ID__c = hsw.attachmentId;
                        }
                     }
                }
               update tc;
            }
            else if(isSingleMap){
                displayMessage ='';
                integer selectedImagesCount = 0;
                Set<String> attachmentIds = new Set<String>();
                for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                    if (hsw.isSelected) {
                        selectedImagesCount  ++;
                        attachmentIds.add(hsw.attachmentId);
                    }
                }
                
                
                if (selectedImagesCount  > 1) {
                    displayMessage = 'Please select only one image';
                    return null;
                }
                else {
                     for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                        if (hsw.isSelected) {
                            oppPDF.O_Destination_Map_Image_ID__c = hsw.attachmentId;
                        }
                     }
                }
               update oppPDF;
            }
            else if(IsSb){
                displayMessage ='';
                integer selectedImagesCount = 0;
                Set<String> attachmentIds = new Set<String>();
                Map<String,Decimal> mapOrder = new Map<String,Decimal>();
                for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                    if (hsw.isSelected) {
                        selectedImagesCount  ++;
                        attachmentIds.add(hsw.attachmentId);
                        mapOrder.put(hsw.attachmentId,hsw.order);
                    }
                }
                
                
                if (selectedImagesCount  > 2) {
                    displayMessage = 'Please select only two images';
                    return null;
                }
                else {
                    String query = '';
                    if(isWillStay == 'true'){
                        delete [Select id,SBI_Attachement_Id__c from SupplierBookingImage__c where SBI_Supplier_Booking__c=: supplierBookingId and (SBI_Order__c = 3 or  SBI_Order__c = 4)];
                    }
                    else{
                        Delete [Select id,SBI_Attachement_Id__c from SupplierBookingImage__c where SBI_Supplier_Booking__c=: supplierBookingId and (SBI_Order__c != 3 and SBI_Order__c != 4)];
                    }
                    List<SupplierBookingImage__c> lstSBImages = new List<SupplierBookingImage__c>();
                    Integer order = 3;
                    for (String attId : attachmentIds) {
                        if(isWillStay == 'true'){
                            lstSBImages.add(new SupplierBookingImage__c(SBI_Order__c= order,SBI_Supplier_Booking__c= supplierBOokingId,
                             SBI_Attachement_Id__c= attId));
                             order++;
                        }
                        else{
                            SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Supplier_Booking__c= supplierBOokingId,
                             SBI_Attachement_Id__c= attId);
                            if(mapOrder.containsKey(attId)){
                                sbi.SBI_Order__c = mapOrder.get(attId);
                            }
                            lstSBImages.add(sbi);
                        }
                    }
                    
                    insert lstSBImages ; 
                }
            }
            else{
                displayMessage ='';
                integer selectedImagesCount = 0;
                Set<String> attachmentIds = new Set<String>();
                for (HolidaySuggestionImagesWrapper hsw: lstWheretogoWrapper ) {
                    if (hsw.isSelected) {
                        selectedImagesCount  ++;
                        attachmentIds.add(hsw.attachmentId);
                    }
                }
                if (selectedImagesCount  > 3) {
                    displayMessage = 'Please select only three images';
                    return null;
                }
                else {
                    String query = '';
                    if(ObjId != null){
                        Delete [select id  from Introduction_Image__c where II_Selected_Content_Category__c =: ObjId and Id not in : attachmentIds];
                    }
                    
                    List<Introduction_Image__c> lstSICCImgs = new List<Introduction_Image__c>();
                    
                    System.debug(' ---------------> Attachment '+attachmentIds);
                    
                    for(attachment at : [select id,ParentId,BodyLength,Body,IsDeleted,IsPrivate,ContentType,Description,Name from Attachment where id in: attachmentIds]){
                        Introduction_Image__c NewAt = new Introduction_Image__c();
                        if(at.ParentId != ObjId && OppId != null){
                            NewAt.II_Selected_Content_Category__c = ObjId;
                            NewAt.II_Opportunity__c = OppId;
                            NewAt.II_Attachement_Id__c = at.Id;
                            lstSICCImgs.add(NewAt);
                        }
                    }
                    
                    insert lstSICCImgs; 
                }
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            Apexpages.addMessages(e);
        }                          
        return navigateTo();
    }
    
    public pagereference navigateTo() {
        return new Pagereference('/apex/PDFSettingPageOld?id='+OppId+'#sup'+ObjId );
    }
    
}
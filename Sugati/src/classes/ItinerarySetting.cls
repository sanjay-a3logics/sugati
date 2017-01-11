public without sharing class ItinerarySetting{

    public ItinerarySetting(HolidayEnquiryController controller) {

    }


    public Opportunity opp{get; set;}
    public String oppStr{get; set;}
    public String DestinationImgs{get; set;}
    public Boolean isOTUK{get; set;}
    public Supplier_Booking__c sbRecord{get; set;}
    public List<picklistValues> recordTypeOptions{get; set;}
    public transient String autoSuggestSupplier{get; set;}
    public transient String autoSuggestTime{get; set;}
    public Boolean haveTravellingCountry{get; set;}
    public transient  String pickLists{get; set;}
    public String lstSupp{get; set;}
    public String nameSpacePrefix{get; set;}
    String oppId;
    static String oppIdS;
        
    public ItinerarySetting(ApexPages.StandardController controller) {
        oppId = controller.getId(); 
        oppIdS = controller.getId();
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }  
        isOTUK  = false;
        recordTypeOptions = new List<picklistValues>();
        List<DestinationImages> lstDestinationImgs = new List<DestinationImages>();
        lstSupp = '';
        
        sbRecord = new Supplier_Booking__c();
        if(oppId != null){
            opp = [select id, O_Show_Option_text_for_quotation__c, O_Quotation_Type__c, O_Quotation_Default_Text__c, Name,Account.Name,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                       O_Adult__c,O_Children__c,O_Infant__c,O_Map_Type__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Destination_Map_Image_ID__c,O_Booking_Currency__c,
                       (Select Id,Name,CG_PDF_Quotation__c from Client_Groups__r),
                       (Select Id, name, TC_Country__r.Name,TC_DestinationMap_Image_ID__c,TC_Accommodation_Region__c from Travelling_Countries__r order by TC_Country__r.Name)
                       from Opportunity  where Id=:oppId];
            setAutoSuggest();
        }
        for(Travelling_Country__c tc : Opp.Travelling_Countries__r){
           lstDestinationImgs.add(new DestinationImages(tc));    
        }
        
        DestinationImgs = JSON.serialize(lstDestinationImgs);
        oppStr = JSON.serialize(opp);
        pickLists = JSON.serialize(Utility.describePickLists('Opportunity'));
    }
    
    
    //Fetch all the PDF Setting Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('PDFSetting'));
    }
    
    void setAutoSuggest(){
        //Set Supplier 
       
        
    }
   
    public string getData(){  
       String oppId = ApexPages.currentPage().getParameters().get('id');
       List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
       if(oppId != ''){
            for(Supplier_Booking__c sb : [select id, name, recordtype.name, SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c, SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c, SB_To_Date__c,SB_Order__c,
                                        SB_Supplier__c,(select id,SBI_Attachement_Id__c,SBI_Order__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 limit 4) 
                                        from Supplier_Booking__c  where SB_Opportunity__c =: oppId and SB_Show_in_Itinerary__c = true Order by SB_Order__c ASC]){
                if(sb.SB_Itinerary_Description__c == null){
                    sb.SB_Itinerary_Description__c = '<div><br/></div>';
                }
                lstSupplierBooking.add(sb);
            }
        }
        //system.assert(False,JSON.serialize(lstSupplierBooking));
        return JSON.serialize(lstSupplierBooking);
    } 
    
    
    
    public string getDataStay(){  
       String oppId = ApexPages.currentPage().getParameters().get('id');
       List<whereWillYouStay> lstSupplierBooking = new List<whereWillYouStay>();
       if(oppId != ''){
            Set<String> setSBIds = new Set<String>();
            String holidayType;
            List<Supplier_Booking__c> lstSB = [select id, name,SB_Opportunity__r.O_Holiday_Type__c, SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c, recordtype.name, SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c, SB_To_Date__c,SB_Order__c,
                                        SB_Supplier__c,SB_Supplier__r.name,(select id,SBI_Attachement_Id__c,SBI_Order__c from SupplierBookingImages__r where SBI_Order__c = 3 OR SBI_Order__c = 4) 
                                        from Supplier_Booking__c  where SB_Opportunity__c =: oppId and recordtype.Name in ('Accommodation') Order by SB_Order__c];
            for(Supplier_Booking__c sb : lstSB){
                if(sb.SB_Supplier__c != null){
                    setSBIds.add(sb.SB_Supplier__c);
                }
                if(holidayType == null){
                    holidayType = sb.SB_Opportunity__r.O_Holiday_Type__c;
                }    
            }
            
            Map<String,Itinerary_Text__c> mapQT = new Map<String,Itinerary_Text__c>();
            if(holidayType != null){
                for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c from Itinerary_Text__c where (IT_Holiday_Type__c = :holidayType)
                                        AND IT_SUPPLIER__C in :setSBIds order by IT_SUPPLIER__C desc ]){                              
                    mapQT.put(qt.IT_SUPPLIER__C,qt);   
                }   
            }
            for(Itinerary_Text__c qt: [select IT_Message__c,IT_SUPPLIER__C,IT_Holiday_Type__c from Itinerary_Text__c where 
                                     (IT_Holiday_Type__c != :Opp.O_Holiday_Type__c OR IT_Holiday_Type__r.Name='Generic')
                                          AND IT_SUPPLIER__C in :setSBIds order by IT_SUPPLIER__C desc ]){ 
                if(!mapQT.containsKey(qt.IT_SUPPLIER__C)){ 
                    mapQT.put(qt.IT_SUPPLIER__C,qt);       
                }      
            }       
            Set<String> setOfSupplier = new  Set<String>();   
            for(Supplier_Booking__c sb : lstSB){
                if(!setOfSupplier.contains(sb.SB_Supplier__c)){    
                    
                    if(mapQT.containsKey(sb.SB_Supplier__c)){
                        lstSupplierBooking.add(new whereWillYouStay(sb,mapQT.get(sb.SB_Supplier__c))); 
                        setOfSupplier.add(sb.SB_Supplier__c);   
                          
                    }
                    else{
                        lstSupplierBooking.add(new whereWillYouStay(sb,new Itinerary_Text__c()));   
                        setOfSupplier.add(sb.SB_Supplier__c);          
                    }
                }
            }
        }
        return JSON.serialize(lstSupplierBooking);
    } 
    
    
    public String getRecordType() {
        List<picklistValues > options = new List<picklistValues >();
        options.add(new picklistValues('','--Select--'));
        for (recordType  obj : [Select Id,Name from recordType where SobjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c']) {
            options.add(new picklistValues(obj.Id,obj.Name));
        }
        
        return JSON.serialize(options);
    } 
    
    public void saveSB(){
        Utility.isCopied = true;
        update (List<Supplier_Booking__c>)JSON.deserialize(lstSupp, List<Supplier_Booking__c>.class);
    }
    
    @remoteAction
    public static String saveSBI(String SBID,String jsonDataImages,String oppId,boolean stay){
        if(!stay){
            List<SupplierBookingImage__c> lstSBImages = (List<SupplierBookingImage__c>)JSON.deserialize(jsonDataImages, List<SupplierBookingImage__c>.class);
            List<String> lstSBId = new List<String>();
            List<SupplierBookingImage__c> lstSBImages1 = new List<SupplierBookingImage__c>();
            String sbIds = SBID.trim().remove('"');
            delete Database.query('Select Id from SupplierBookingImage__c where SBI_Supplier_Booking__c =\''+sbIds+'\' and SBI_Order__c!= 3 and SBI_Order__c != 4');
            
            Integer order =1;
            for(SupplierBookingImage__c sbi: lstSBImages){
                if(sbi.SBI_Attachement_Id__c == null){
                    lstSBId.add(sbi.SBI_Supplier_Booking__c);
                }
                else{
                    sbi.Id = null;
                    sbi.SBI_Order__c = order;
                    lstSBImages1.add(sbi);
                    order++;
                }
            }
            //delete [Select Id from SupplierBookingImage__c where SBI_Supplier_Booking__c in :lstSBId and SBI_Supplier_Booking__r.SB_Opportunity__c =:oppId and SBI_Order__c!= 3 and SBI_Order__c != 4];
            Utility.isCopied = true;
            upsert lstSBImages1;
            return 'Success'+SBID;
        }
        else{
            List<SupplierBookingImage__c> lstSBImages = (List<SupplierBookingImage__c>)JSON.deserialize(jsonDataImages, List<SupplierBookingImage__c>.class);
            List<String> lstSBId = new List<String>();
            List<SupplierBookingImage__c> lstSBImages1 = new List<SupplierBookingImage__c>();
            String sbIds = SBID.trim().remove('"');
            delete Database.query('Select Id from SupplierBookingImage__c where SBI_Supplier_Booking__c =\''+sbIds+'\' and (SBI_Order__c= 3 or SBI_Order__c = 4)');
            
            Integer order =3;
            for(SupplierBookingImage__c sbi: lstSBImages){
                if(sbi.SBI_Attachement_Id__c == null){
                    lstSBId.add(sbi.SBI_Supplier_Booking__c);
                }
                else{
                    sbi.Id = null;
                    sbi.SBI_Order__c = order;
                    lstSBImages1.add(sbi);
                    order++;
                }
            }
            //delete [Select Id from SupplierBookingImage__c where SBI_Supplier_Booking__c in :lstSBId and SBI_Supplier_Booking__r.SB_Opportunity__c =:oppId and SBI_Order__c!= 3 and SBI_Order__c != 4];
            Utility.isCopied = true;
            upsert lstSBImages1;
            return 'Success'+SBID;    
        }
    }
    
    
    @remoteAction
    public static String saveSBITC(String jsonDataImages,String oppId){
        if(true){
            return 'Success';    
        }
        return null;
    }
    
    @remoteAction
    public static String saveSB(String jsonData,String jsonDataImages,String oppId){
        try{
           /*List<SupplierBookingImage__c> lstSBImages = (List<SupplierBookingImage__c>)JSON.deserialize(jsonDataImages, List<SupplierBookingImage__c>.class);
             List<Supplier_Booking__c> lstSB = (List<Supplier_Booking__c>)JSON.deserialize(jsonData, List<Supplier_Booking__c>.class);
             List<String> lstSBId = new List<String>();
            
            for(SupplierBookingImage__c sbi: lstSBImages){
                if(sbi.SBI_Attachement_Id__c == null){
                    lstSBId.add(sbi.SBI_Supplier_Booking__c);
                }
            }
            delete [Select Id from SupplierBookingImage__c where SBI_Supplier_Booking__c in :lstSBId and SBI_Supplier_Booking__r.SB_Opportunity__c =:oppId and SBI_Order__c!= 3 and SBI_Order__c != 4];
            upsert lstSBImages;*/
            
           
            Utility.isCopied = true;
            update (List<Supplier_Booking__c>)JSON.deserialize(jsonData, List<Supplier_Booking__c>.class);
            
            
           List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
           if(oppId != ''){
                for(Supplier_Booking__c sb : [select id, name, SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c, recordtype.name, SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c, SB_To_Date__c,SB_Order__c,
                                            SB_Supplier__c,(select id,SBI_Attachement_Id__c,SBI_Order__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 limit 4) 
                                            from Supplier_Booking__c  where SB_Opportunity__c =:oppId and recordtype.Name in ('Accommodation','Car Hire','Days at Leisure','Dom Flights','Excursion','Int Flight','Light Aircraft','Notes','Own arrangement','Rail','Transfer','Description') Order by SB_Order__c]){
                    if(sb.SB_Itinerary_Description__c == null){
                        sb.SB_Itinerary_Description__c = '<div><br/></div>';
                    }
                    lstSupplierBooking.add(sb);
                }
            }
            
            return JSON.serialize(lstSupplierBooking);
        }
        Catch(Exception e){
            return e.getMessage()+e.getStackTraceString();
        }
    }
    
    @remoteAction
    public static String saveSBS(String jsonData,String jsonDataImages,String oppstr, String lstDestinationImgstr, string clientGroups){
        try{
            
            Opportunity opp = (Opportunity)JSON.deserialize(oppstr, Opportunity.class);
            update opp;
            
            List<Client_Group__c> lstClientGroups = (List<Client_Group__c>)JSON.deserialize(clientGroups, List<Client_Group__c>.class);
            update lstClientGroups;
            
            List<DestinationImages> lstDestination = (List<DestinationImages>)JSON.deserialize(lstDestinationImgstr, List<DestinationImages>.class);
            List<Travelling_Country__c> lstTc = new List<Travelling_Country__c>();
            for(DestinationImages maps: lstDestination){
                lstTc.add(maps.tc);
            }
            update lstTc;
            
            Utility.isCopied = true;
            update (List<Supplier_Booking__c>)JSON.deserialize(jsonData, List<Supplier_Booking__c>.class);
            
            
           List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
           if(opp.Id != null){
                for(Supplier_Booking__c sb : [select id, name, SB_Remove_Images__c,SB_Remove_TextArea__c,SB_Remove_Date_Title__c, recordtype.name, SB_New_Page__c, SB_Itinerary_Description__c,SB_From_Date__c, SB_To_Date__c,SB_Order__c,
                                            SB_Supplier__c,(select id,SBI_Attachement_Id__c,SBI_Order__c from SupplierBookingImages__r where SBI_Order__c != 3 and SBI_Order__c != 4 limit 4) 
                                            from Supplier_Booking__c  where SB_Opportunity__c =: opp.Id and recordtype.Name in ('Accommodation','Car Hire','Days at Leisure','Dom Flights','Excursion','Int Flight','Light Aircraft','Notes','Own arrangement','Rail','Transfer','Description') Order by SB_Order__c]){
                    if(sb.SB_Itinerary_Description__c == null){
                        sb.SB_Itinerary_Description__c = '<div><br/></div>';
                    }
                    lstSupplierBooking.add(sb);
                }
            }
            
            return JSON.serialize(lstSupplierBooking);
        }
        Catch(Exception e){
            System.assert(false, e.getMessage()+e.getStackTraceString());
            return e.getMessage()+e.getStackTraceString();
        }
    }
    
    @remoteAction
    public static List<attachment> search(String searchContext){
        List<String> lstSelected = searchContext.split(',');
        
        if(lstSelected.size() != 0){
         return [select id, parentId,name from attachment 
            where (parentId in : lstSelected) and (NOT Name like '%cover%') ];
        }
        else{
            return null;
        }
    }
    
    @RemoteAction
    public static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId) {
        if(acctId != null) {
            if(acctId  != null) {
                if(attachmentBody != null) {
                    Attachment att = new Attachment();
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = acctId;
                    }
                    upsert att;
                    if(acctId != null){
                        List<Travelling_Country__c> lstTC = new List<Travelling_Country__c>();
                        for(Travelling_Country__c tc : [Select Id from Travelling_Country__c where Id = :acctId]){
                            tc.TC_DestinationMap_Image_ID__c = att.Id;
                            lstTC.add(tc);
                        }
                        update lstTC;
                    }
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
    
    
    public Class whereWillYouStay{
        public Supplier_Booking__c sb{get; set;}
        public Itinerary_Text__c qt{get; set;}
        
        public whereWillYouStay(Supplier_Booking__c sb, Itinerary_Text__c qt){
            this.sb = sb;
            this.qt = qt;    
        }
    }
    
    public class DestinationImages{
        public Travelling_Country__c tc{get;set;}
        public DestinationImages(Travelling_Country__c  tc){
            this.tc = tc;
        }    
    }
    
    public class picklistValues{
        String label {get; set;}
        String value {get; set;}
        
        public picklistValues(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
}
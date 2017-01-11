public with sharing class CategoryController {

    public String oppId{get;set;}
    public Opportunity Opp{get;set;}
    public String recordtype{get; set;}
    public String contentcategoty{get;set;}
    
    public List <ItineraryContentCategory> FinalDocs_CategoryList {get;set;}
    public Map<String,Selected_Itinerary_Content_Category__c> mapSelectedCotegory {get;set;}

    public Static String nameSpacePrefix{get;set;}
    public CategoryController(Apexpages.standardcontroller controller) {
        oppId = controller.getId();
        Opp = (Opportunity)controller.getRecord();
        ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        recordtype = '';
        mapSelectedCotegory = new Map<String,Selected_Itinerary_Content_Category__c>();
        contentcategoty = JSON.serialize(getCategories());
        if (controller.getId() != null) {
            Opp = [select id, Name, O_RecordType__c, O_RecordType__r.Name from Opportunity where Id=:oppId];
            if(Opp.O_RecordType__c != null){
                recordtype  = opp.O_RecordType__r.Name;
            }
        }  
         
    }
    
    public String getPageMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('ItineraryCategory'));
    }
    
    //Fetch all the PDF Setting Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('FinalDoc'));
    }
    
    
    /* This Method returns All categories and corrosponding to selected categories checkbox is true*/ 
    Map<String,String> mapSelectedMessage = new Map<String,String>();
    Set<String> setSelectedMessage  = new Set<String>();
    
    public List<ContentCategory> getCategories(){
      try{
        List<ContentCategory> categoryList = new List<ContentCategory>();
        Set<String>  existingCCs = new Set<String>();
        setSelectedMessage  = new Set<String>();
        Map<string,Decimal> mapSelPageNo = new Map<String,Decimal>();
        mapSelectedMessage = new Map<String,String>();
        
        for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__r.Name,SICC_message__c
                                                        from Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :Opp.Id 
                                                        AND SICC_Itinerary_Content_Category__r.Name NOT IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                        and recordType.developerName = 'Categories'] ){
            if(sc.SICC_Itinerary_Content_Category__r.name == 'Tailored for you' || sc.SICC_Itinerary_Content_Category__r.Name == 'What it costs'){
                mapSelectedMessage.put(sc.SICC_Itinerary_Content_Category__c,sc.SICC_message__c);
                setSelectedMessage.add(sc.SICC_Itinerary_Content_Category__c);
            }
            mapSelectedCotegory.put(sc.SICC_Itinerary_Content_Category__c, sc);
        }
        

        for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__c,ICC_Page_No__c from 
                                                        Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :Opp.Id
                                                       AND SICC_Itinerary_Content_Category__r.Name NOT IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                       and recordType.developerName = 'Categories'] ){
            existingCCs.add(sc.SICC_Itinerary_Content_Category__c);  
            mapSelPageNo.put(sc.SICC_Itinerary_Content_Category__c,sc.ICC_Page_No__c);
        }
        Set<String> condition = new Set<String>{'TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER'};
        
        if(recordtype != 'ST'){
            condition.add('YOUR GUIDE');
        }
            
        for(Itinerary_Content_Category__c cc :[select id, Name, ICC_Order__c from Itinerary_Content_Category__c
                                               Where Name NOT IN :condition
                                               Order By ICC_Order__c]) {
           if (existingCCs.size() >0) {
               CategoryList.add(new ContentCategory(cc,existingCCs.contains(cc.id), mapSelPageNo.get(cc.id)));
           }
           else {
               CategoryList.add(new ContentCategory(cc,true,mapSelPageNo.get(cc.id)));
           }
        }
        return CategoryList;
       }catch(exception e){
           system.assert(false,e.getMessage()+e.getLineNumber());
           return null;
       }
    }
    
    Set<String> FinalDocs_existingICCs = new Set<String>();
    Map<String,String> FinalDocs_mapSelectedMessage = new Map<String,String>();
    Set<String> FinalDocs_setSelectedMessage  = new Set<String>();
    public List<ItineraryContentCategory> getFinalDocsCategories(){
        
        FinalDocs_categoryList = new List<ItineraryContentCategory>();
         
        FinalDocs_existingICCs = new Set<String>();
        FinalDocs_setSelectedMessage  = new Set<String>();
        Map<string,Decimal> FinalDocs_mapSelPageNo = new Map<String,Decimal>();
        FinalDocs_mapSelectedMessage = new Map<String,String>();
       

        for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__c,ICC_Page_No__c from 
                                                        Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :Opp.Id
                                                       AND SICC_Itinerary_Content_Category__r.Name  IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') ] ){
             FinalDocs_existingICCs.add(sc.SICC_Itinerary_Content_Category__c );  
             FinalDocs_mapSelPageNo.put(sc.SICC_Itinerary_Content_Category__c,sc.ICC_Page_No__c);
        }
            
        for(Itinerary_Content_Category__c Ic :[select id, Name, ICC_Order__c from Itinerary_Content_Category__c 
                                               Where Name IN  ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                               Order By ICC_Order__c]) {
           if ( FinalDocs_existingICCs.size() >0) {
                FinalDocs_CategoryList.add(new ItineraryContentCategory(Ic, FinalDocs_existingICCs.contains(ic.id),  FinalDocs_mapSelPageNo.get(ic.id)));
           }
           else {
                FinalDocs_CategoryList.add(new ItineraryContentCategory(Ic,true, FinalDocs_mapSelPageNo.get(ic.id)));
           }
        }
        
                
        return  FinalDocs_CategoryList;
    }
    
     /* Save new Selected categories */
    Public PageReference FinalDocs_Save(){
        try{
            
            delete [select id from Selected_Itinerary_Content_Category__c  where ICC_Opportunity__r.Id = :Opp.Id AND SICC_Itinerary_Content_Category__r.Name IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER')];
            
            List<Selected_Itinerary_Content_Category__c> FinalDocs_lstSICC = new List<Selected_Itinerary_Content_Category__c>();
            
            for (ItineraryContentCategory icc: FinalDocs_categoryList ) {
                if (icc.selected) {
                    
                        FinalDocs_lstSICC.add(new Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = icc.category.id, ICC_Opportunity__c = opp.id,ICC_Page_No__c=icc.PageNo));
                }
            }
            insert FinalDocs_lstSICC;
        }  
        catch(DMLException dex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dex.getDMLMessage(0))); 
        }   
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }      
        return null;
    }
  
  
  
    @RemoteAction
    public static List<ContentCategory>changeCategories(String type, String OppId){
      try{
                  
        List<ContentCategory> categoryList = new List<ContentCategory>();
        Set<String>  existingCCs = new Set<String>();
        Set<String> setSelectedMessage  = new Set<String>();
        Map<string,Decimal> mapSelPageNo = new Map<String,Decimal>();
        Map<String,String> mapSelectedMessage = new Map<String,String>();
        Map<String,Selected_Itinerary_Content_Category__c> mapSelectedCotegory = new Map<String,Selected_Itinerary_Content_Category__c>();
        
        
        if(type != 'FinalDoc'){
            for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__r.Name,SICC_message__c
                                                            from Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :oppId
                                                            AND SICC_Itinerary_Content_Category__r.Name NOT IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                            and recordType.developerName = :type] ){
                if(sc.SICC_Itinerary_Content_Category__r.name == 'Tailored for you' || sc.SICC_Itinerary_Content_Category__r.Name == 'What it costs'){
                    mapSelectedMessage.put(sc.SICC_Itinerary_Content_Category__c,sc.SICC_message__c);
                    setSelectedMessage.add(sc.SICC_Itinerary_Content_Category__c);
                }
                mapSelectedCotegory.put(sc.SICC_Itinerary_Content_Category__c, sc);
            }
            
    
            for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__c,ICC_Page_No__c from 
                                                            Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :oppId
                                                           AND SICC_Itinerary_Content_Category__r.Name NOT IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                           and recordType.developerName = :type] ){
                existingCCs.add(sc.SICC_Itinerary_Content_Category__c);  
                mapSelPageNo.put(sc.SICC_Itinerary_Content_Category__c,sc.ICC_Page_No__c);
            }
            Set<String> condition = new Set<String>{'TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER'};
            for(Itinerary_Content_Category__c cc :[select id, Name, ICC_Order__c from Itinerary_Content_Category__c
                                                   Where Name NOT IN :condition
                                                   Order By ICC_Order__c]) {
               if (existingCCs.size() >0) {
                   CategoryList.add(new ContentCategory(cc,existingCCs.contains(cc.id), mapSelPageNo.get(cc.id)));
               }
               else {
                   CategoryList.add(new ContentCategory(cc,true,mapSelPageNo.get(cc.id)));
               }
            }
        }
        else{
            for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__r.Name,SICC_message__c
                                                            from Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :oppId
                                                            AND SICC_Itinerary_Content_Category__r.Name IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                            and recordType.developerName = 'Categories'] ){
                if(sc.SICC_Itinerary_Content_Category__r.name == 'Tailored for you' || sc.SICC_Itinerary_Content_Category__r.Name == 'What it costs'){
                    mapSelectedMessage.put(sc.SICC_Itinerary_Content_Category__c,sc.SICC_message__c);
                    setSelectedMessage.add(sc.SICC_Itinerary_Content_Category__c);
                }
                mapSelectedCotegory.put(sc.SICC_Itinerary_Content_Category__c, sc);
            }
            
    
            for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__c,ICC_Page_No__c from 
                                                            Selected_Itinerary_Content_Category__c where ICC_Opportunity__r.Id = :oppId
                                                           AND SICC_Itinerary_Content_Category__r.Name IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') 
                                                           and recordType.developerName = :type] ){
                existingCCs.add(sc.SICC_Itinerary_Content_Category__c);  
                mapSelPageNo.put(sc.SICC_Itinerary_Content_Category__c,sc.ICC_Page_No__c);
            }
            Set<String> condition = new Set<String>{'TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER'};
            for(Itinerary_Content_Category__c cc :[select id, Name, ICC_Order__c from Itinerary_Content_Category__c
                                                   Where Name IN :condition
                                                   Order By ICC_Order__c]) {
               if (existingCCs.size() >0) {
                   CategoryList.add(new ContentCategory(cc,existingCCs.contains(cc.id), mapSelPageNo.get(cc.id)));
               }
               else {
                   CategoryList.add(new ContentCategory(cc,true,mapSelPageNo.get(cc.id)));
               }
            }    
        }
        return CategoryList;
       }catch(exception e){
           system.assert(false,e.getMessage()+e.getLineNumber());
           return null;
       }
    }
    
    @RemoteAction
    Public static void Save(List<ContentCategory> categoryList,String oppid, String type){
        try{
            if(type != 'FinalDoc'){
                Map<String,Selected_Itinerary_Content_Category__c> mapSelectedCotegory = new Map<String,Selected_Itinerary_Content_Category__c>();
                for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__r.Name,SICC_message__c 
                                                            from Selected_Itinerary_Content_Category__c 
                                                            where ICC_Opportunity__r.Id = :oppId and recordType.developerName = :type and
                                                            SICC_Itinerary_Content_Category__r.Name NOT IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') ] ){
                   mapSelectedCotegory.put(sc.SICC_Itinerary_Content_Category__c, sc);
                }
                List<Selected_Itinerary_Content_Category__c> lstSCC = new List<Selected_Itinerary_Content_Category__c>();
                List<Selected_Itinerary_Content_Category__c> delSCC = new List<Selected_Itinerary_Content_Category__c>();
                String rId;
                List<RecordType> lstRt = [Select id, DeveloperName from RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Selected_Itinerary_Content_Category__c' and DeveloperName =:type];
                if(lstRt .size() > 0 ){
                    rId = lstRt[0].Id;
                    for (ContentCategory cc: categoryList ) {
                        if (cc.selected) {
                            if(mapSelectedCotegory.containsKey(cc.category.id)){
                                Selected_Itinerary_Content_Category__c scc = mapSelectedCotegory.get(cc.category.id);
                                scc.ICC_Page_No__c= cc.PageNo;
                                scc.RecordTypeId = rId;
                                lstSCC.add(scc);
                            }
                            else{
                                Selected_Itinerary_Content_Category__c newRec = new Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = cc.category.id, ICC_Opportunity__c = oppid,ICC_Page_No__c= cc.PageNo);   
                                newRec.RecordTypeId = rId;
                                lstSCC.add(newRec);
                            }
                        }
                        else if(mapSelectedCotegory.get(cc.category.id) != null){                
                            delSCC.add(mapSelectedCotegory.get(cc.category.id));
                        }
                    }
                }
                delete delSCC;
                upsert lstSCC;
            }
            else{
                
                Map<String,Selected_Itinerary_Content_Category__c> mapSelectedCotegory = new Map<String,Selected_Itinerary_Content_Category__c>();
                for(Selected_Itinerary_Content_Category__c sc :[select Id,SICC_Itinerary_Content_Category__r.Name,SICC_message__c 
                                                            from Selected_Itinerary_Content_Category__c 
                                                            where ICC_Opportunity__r.Id = :oppId and recordType.developerName = 'Categories' and
                                                            SICC_Itinerary_Content_Category__r.Name IN ('TICKETS AND VOUCHERS','CONFIRMATION LETTER','FINAL DOCS LETTER') ] ){
                   mapSelectedCotegory.put(sc.SICC_Itinerary_Content_Category__c, sc);
                }
                List<Selected_Itinerary_Content_Category__c> lstSCC = new List<Selected_Itinerary_Content_Category__c>();
                List<Selected_Itinerary_Content_Category__c> delSCC = new List<Selected_Itinerary_Content_Category__c>();
                String rId;
                List<RecordType> lstRt = [Select id, DeveloperName from RecordType WHERE SObjectType = :Utility.getNameSpacePrefix()+'Selected_Itinerary_Content_Category__c' and DeveloperName = 'Categories'];
                if(lstRt .size() > 0 ){
                    rId = lstRt[0].Id;
                    for (ContentCategory cc: categoryList) {
                        if (cc.selected) {
                            if(mapSelectedCotegory.containsKey(cc.category.id)){
                                Selected_Itinerary_Content_Category__c scc = mapSelectedCotegory.get(cc.category.id);
                                scc.ICC_Page_No__c= cc.PageNo;
                                scc.RecordTypeId = rId;
                                lstSCC.add(scc);
                            }
                            else{
                                Selected_Itinerary_Content_Category__c newRec = new Selected_Itinerary_Content_Category__c(SICC_Itinerary_Content_Category__c = cc.category.id, ICC_Opportunity__c = oppid,ICC_Page_No__c= cc.PageNo);   
                                newRec.RecordTypeId = rId;
                                lstSCC.add(newRec);
                            }
                        }
                        else if(mapSelectedCotegory.get(cc.category.id) != null){                
                            delSCC.add(mapSelectedCotegory.get(cc.category.id));
                        }
                    }
                }
                delete delSCC;
                upsert lstSCC;    
            }
            
        }  
        catch(DMLException e){
            system.assert(false,e.getMessage()+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0))); 
        }   
        catch(Exception e){
            system.assert(false,e.getMessage()+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
        }      
    }
    
    public class ContentCategory{
        Public Itinerary_Content_Category__c category {get;set;}
        Public Boolean selected {get;set;}
        public Decimal PageNo {get;set;}
        
        Public ContentCategory(Itinerary_Content_Category__c c, Boolean val, Decimal p)
        {
            this.category = c;
            this.selected = val;
            this.PageNo = p;
        }
        
    }
    
    public class ItineraryContentCategory{
        
        Public Itinerary_Content_Category__c category {get;set;}
        Public Boolean selected {get;set;}
        public Decimal PageNo {get;set;}
        
        Public ItineraryContentCategory(Itinerary_Content_Category__c c, Boolean val, Decimal p)
        {
            this.category = c;
            this.selected = val;
            this.PageNo = p;
        }
        
    }
}
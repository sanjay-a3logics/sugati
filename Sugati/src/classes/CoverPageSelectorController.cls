public without sharing class CoverPageSelectorController {
    public List<CountryImageWrapper> lstCountryImageWrapper;
    public List<WTGImageWrapper> lstWTGImageWrapper;
    public String displayMessage{get;set;}
    public string oppId{get;set;}
    public Boolean isSuccess{get;set;}
    public Map<String,string> mapTC;
    public String nameSpacePrefix{get;set;}
    
    public CoverPageSelectorController(Apexpages.standardController controller ) {
        oppId = controller.getId();
        if (OppId != null) {
             ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'HolidayEnquiryController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            lstCountryImageWrapper = new List<CountryImageWrapper>();
            mapTC = new Map<String,string>();
            Set<String> setTCCoverImage = new set<String>(); 
            Set<String> setTC = new Set<String>();    
            Set<String> countries = new Set<String>();
            for (Travelling_Country__c tc: [select id, TC_country__c,TC_Cover_Image__c ,TC_ImageID__c from Travelling_Country__c 
                                where TC_Opportunity__c =: controller.getId() order by lastmodifieddate desc]) {
                 countries.add(tc.tc_country__c);   
                 mapTC.put(tc.tc_country__c,tc.id);  
                 setTC.add(tc.Id);
                 if (tc.TC_Cover_Image__c != null && setTCCoverImage.size() == 0 ) { 
                     setTCCoverImage.add( tc.TC_ImageID__c); 
                 }    
            }
            //system.assert(false, setTCCoverImage);
            for (Attachment att : [select id,name, parentId from attachment 
               where parentId in: countries AND name LIKE '%cover%']) {
                lstCountryImageWrapper.add(new CountryImageWrapper(mapTC.get(att.parentid), att.id,setTCCoverImage.contains(att.id), att.name));
            }
            
            lstWTGImageWrapper = new List<WTGImageWrapper>();
            Map<String,string> mapWTG = new Map<String,string>();
            Set<String> setWTGCoverImage = new set<String>();     
            Set<String> wheretogo = new Set<String>();
            List<Travelling_Country__c> lstTCWTG = new List <Travelling_Country__c>();
            for (Where_To_Go__c wtg: [select id, name,W_Country__c from Where_to_go__c 
                                where W_Country__c In : countries order by lastmodifieddate desc]) {
                 wheretogo.add(wtg.Id);   
                 mapWTG.put(wtg.id,wtg.id);  
            }
            Set<String> setTCImageId = new Set<String>();
            for(Travelling_Country__c tc :[select id, TC_country__c,TC_Cover_Image__c ,TC_ImageID__c from Travelling_Country__c 
                                          where id IN: setTC  ]){
                setTCImageId.add(tc.TC_ImageID__c);
            }
            
            for (Attachment att : [select id,name, parentId from attachment 
                                   where parentId in: wheretogo AND name LIKE '%cover%']) {
                lstWTGImageWrapper.add(new WTGImageWrapper(mapWTG.get(att.parentid), att.id,setTCImageId.contains(att.Id),att.name));
            }
         }
      
    }
    
    public String getTravellingCountryImages(){
        return JSON.serialize(lstCountryImageWrapper);
    }
    
    public String getWTGImages(){
        return JSON.serialize(lstWTGImageWrapper);
    }
   


    public class CountryImageWrapper{
        public string recordId{get;set;}
        public String attachmentId{get;set;}
        public Boolean isselected{get;set;}
        public String CountryImageName{get;set;}
        public CountryImageWrapper(String recordId, string attachmentId, Boolean isselected, String CountryImageName) {
            this.recordId = recordId;
            this.attachmentId = attachmentId;
            this.isselected= isselected;
            this.CountryImageName = CountryImageName;
        }
    }
    
    public class WTGImageWrapper{
        public string WTGrecordId{get;set;}
        public String WTGattachmentId{get;set;}
        public Boolean isselected{get;set;}
        public String WTGImageName{get;set;}
        public WTGImageWrapper(String WTGrecordId, string WTGattachmentId, Boolean isselected,String WTGImageName) {
            this.WTGrecordId = WTGrecordId;
            this.WTGattachmentId = WTGattachmentId;
            this.isselected= isselected;
            this.WTGImageName = WTGImageName;
        }
    }
    
    @remoteAction
    public static String saveCoverImages(List<CountryImageWrapper> lstCountryImageWrapper, List<WTGImageWrapper> lstWTGImageWrapper,String tcId, String WTGId,String attId, String oppid ) {
        String displayMessage = '' ;
        try {
            Map<String,string> mapTC = new Map<String,string>();
            Map<String, String> pageMessage = ErrorMessageController.getErrorMessage('CoverPageSelector');
            
            for (Travelling_Country__c tc: [select id, TC_country__c,TC_Cover_Image__c ,TC_ImageID__c from Travelling_Country__c 
                                where TC_Opportunity__c =: oppid order by lastmodifieddate desc]) {   
                 mapTC.put(tc.tc_country__c,tc.id);  
            }
            
            if(tcId != '' && tcId != null) {
                List<Travelling_Country__c> lstTC = [select id,TC_ImageID__c,TC_Selected__c,TC_Cover_Image__c from Travelling_Country__c  where id =:tcId];
                if (lstTC.size() > 0) {
                    lstTC[0].TC_ImageID__c = attId;
                    lstTC[0].TC_Selected__c  = datetime.now();
                    lstTC[0].TC_Cover_Image__c = true;
                    upsert lstTC;
                }
                displayMessage = pageMessage.get('CPS_Cover_Image_Update_Success');
            }
            
           else if (WTGId != '' && WTGId != null) {
                List<Where_To_Go__c> lstWTG = [select id,name,W_Country__c from Where_to_go__c  where id =:WTGId];
                if(lstWTG.size() > 0){
                    List<Travelling_Country__c> lstTC = [select id,TC_ImageID__c,TC_Selected__c,TC_Cover_Image__c from Travelling_Country__c where id =: mapTC.get(lstWTG[0].W_Country__c)];
                    if (lstTC.size() > 0) {
                        lstTC[0].TC_ImageID__c = attId;
                        lstTC[0].TC_Selected__c  = datetime.now();
                        lstTC[0].TC_Cover_Image__c = true;
                        upsert lstTC;
                    }
                }    
                displayMessage = pageMessage.get('CPS_Cover_Image_Update_Success');
            }                     
           else {
                List<Travelling_Country__c> lstTC = [select id,TC_ImageID__c,TC_Selected__c,TC_Cover_Image__c from Travelling_Country__c  where TC_Opportunity__c = :oppId  and TC_Cover_Image__c = true];
                if(lstTC.size() == 0)
                    displayMessage = pageMessage.get('CPS_Must_Select_Image');
                else{
                    displayMessage  = ''; 
                }
            }
            return displayMessage;
        }
        catch(exception e) {
            return 'Error while saving the record ' + e.getMessage();    
        }
        
        //return null;
        
    }
    
    public Pagereference navigateTo() {
        return new Pagereference('/'+oppId);
     
    }
}
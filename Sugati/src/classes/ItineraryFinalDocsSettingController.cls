public class ItineraryFinalDocsSettingController{
    
   
    public String lstSICCOStr{get;set;}
    public String lstForgetStr{get;set;}
    public String letterStr{get; set;}
    public String errorMsg{get; set;}
    public String nameSpacePrefix{get;set;}
    
    Set<String> travelCountries = new Set<String>();
    Opportunity Opp;
    List<Selected_Itinerary_Content_Category__c> lstSICC;
    
    public ItineraryFinalDocsSettingController(ApexPages.StandardController controller){
        String oppId;
        try{
            oppId = controller.getId();
            String finalDocHolder;
            
            ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'ItineraryFinalDocsSettingController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            for(Itinerary_Content_Category__c IC : [Select Id from Itinerary_Content_Category__c where Final_Doc__c = true]){
                finalDocHolder = IC.Id;
            }
            if (controller.getId() != null) {
                List<DocWrapper> lstDocWrapper = new List<DocWrapper>();
                List<DocWrapper> lstForgetWrapper = new List<DocWrapper>();
                lstSICC = new List<Selected_Itinerary_Content_Category__c>();
                Set<String> setContentPresent = new Set<String>();
                
                
                Opp = [select id, Name,O_Display_Due_Date__c,  Account.Name,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c,
                         O_Return_Date__c,Owner.Name,Owner.Username,Owner.FirstName,O_Adult__c,O_Children__c,O_Infant__c,Amount,
                         O_Outstanding__c,O_Booking_Currency__c,O_Itinerary_Cover_Name__c,O_Total_Payment__c,StageName,O_Due_Date__c
                        from Opportunity where Id=:oppId];
                //Set Of Travelling Countries
                for(Travelling_Country__c t: [select Name,TC_Country__r.name from Travelling_Country__c
                                             where TC_Opportunity__r.Id= :OppId]){
                    travelCountries.add(t.TC_Country__r.name);
                }
                
                List<Itinerary_Content__c> lstContent = [select Id,IC_Title__c,IC_Description__c,IC_Order__c,IC_Country__r.Name, IC_Itinerary_Content_Category__c,IC_Country__c,RecordTypeId,CurrencyIsoCode,IC_ConfirmationLetter__c,IC_FinalDoc__c
                                                   from Itinerary_Content__c where IC_Itinerary_Content_Category__c = :finalDocHolder 
                                                   AND ((IC_Country__r.Name in :travelCountries)OR (IC_Country__r.Name = '')) AND 
                                                   (IC_FinalDoc__c = TRUE OR IC_ConfirmationLetter__c = TRUE)  order by IC_Order__c];
                
                //Get Selected_ICC_Copy__c
                for(Selected_ICC_Copy__c SCCIO : [select Id,SICCO_Title__c,  SICCO_Content__r.IC_Description__c,SICCO_Description__c,SICCO_Order__c,SICCO_Country__r.Name,
                                                 CurrencyIsoCode,SICCO_Content__c,SICCO_Category__c,SICCO_Country__c,SICCO_FinalDoc__c,SICCO_Confirmation_Letter__c
                                                 from Selected_ICC_Copy__c  where SICCO_Category__r.ICC_Opportunity__c = :Opp.ID
                                                 AND SICCO_Category__r.SICC_Itinerary_Content_Category__c = :finalDocHolder 
                                                 AND ((SICCO_Country__r.Name in :travelCountries)OR (SICCO_Country__r.Name = ''))
                                                 order by SICCO_Order__c]){
                    setContentPresent.add(SCCIO.SICCO_Content__c);
                    DocWrapper dwr = new DocWrapper(SCCIO.SICCO_Content__c, SCCIO.Id, SCCIO.SICCO_Title__c,SCCIO.SICCO_Order__c,SCCIO.SICCO_Country__r.Name,SCCIO.SICCO_Country__c,
                        SCCIO.SICCO_Confirmation_Letter__c,SCCIO.SICCO_FinalDoc__c,SCCIO.SICCO_Description__c, SCCIO.CurrencyIsoCode);
                    dwr.Original_Description = SCCIO.SICCO_Content__r.IC_Description__c;
                    lstDocWrapper.add(dwr);
                }
                
                lstSICCOStr = JSON.serialize(lstDocWrapper);
                if(lstDocWrapper.size() == 0){
                    for(Itinerary_Content__c  ic : lstContent){
                        if(ic.IC_Title__c == 'Medical Advice'){
                            ic.IC_Description__c = '<span Class="label">'+ic.IC_Title__c+'</span><br/><br/>'+ic.IC_Description__c;
                        }       
                        lstForgetWrapper.add(new DocWrapper(ic.Id,'', ic.IC_Title__c,ic.IC_Order__c,ic.IC_Country__r.Name,ic.IC_Country__c,ic.IC_ConfirmationLetter__c,
                                            ic.IC_FinalDoc__c,ic.IC_Description__c,ic.CurrencyIsoCode));
                    }
                    lstForgetStr = JSON.serialize(lstForgetWrapper);
                }
                else{
                    for(Itinerary_Content__c  ic : [select Id,IC_Title__c,IC_Description__c,IC_Order__c,IC_Country__r.Name, IC_Itinerary_Content_Category__c,IC_Country__c,RecordTypeId,CurrencyIsoCode,IC_ConfirmationLetter__c,IC_FinalDoc__c
                                                   from Itinerary_Content__c where IC_Itinerary_Content_Category__c = :finalDocHolder And Id not in  :setContentPresent
                                                   AND ((IC_Country__r.Name in :travelCountries)OR (IC_Country__r.Name = '')) AND
                                                   (IC_FinalDoc__c = TRUE OR IC_ConfirmationLetter__c = TRUE)  order by IC_Order__c]){
                        if(ic.IC_Title__c == 'Medical Advice'){
                            ic.IC_Description__c = '<span Class="label">'+ic.IC_Title__c+'</span><br/><br/>'+ic.IC_Description__c;
                        }       
                        lstForgetWrapper.add(new DocWrapper(ic.Id,'', ic.IC_Title__c,ic.IC_Order__c,ic.IC_Country__r.Name,ic.IC_Country__c,ic.IC_ConfirmationLetter__c,
                                            ic.IC_FinalDoc__c,ic.IC_Description__c,ic.CurrencyIsoCode));
                    }
                    lstForgetStr = JSON.serialize(lstForgetWrapper);
                }
                
                letterStr = JSON.serialize(new LetterWrapper('','','',''));
                
                
            }
            
            if(finalDocHolder == null){
                errorMsg = 'Please select Content Category to store final doc.';
            }
        }
        Catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    
    //Save ICCO
    @remoteAction
    public static String saveICCO(List<DocWrapper> lstDocWrapper, String oppId, LetterWrapper letterObj, List<DocWrapper> lstOldDataWrapper) {
        try{
            String finalDocHolder;
            for(Itinerary_Content_Category__c IC : [Select Id from Itinerary_Content_Category__c where Final_Doc__c = true]){
                finalDocHolder = IC.Id;
            }
            //List<DocWrapper> lstDocWrapper = (List<DocWrapper>)JSON.deserialize(JSONICCO,List<DocWrapper>.class);
            List<Selected_Itinerary_Content_Category__c> lstSICC = [select ID from Selected_Itinerary_Content_Category__c where  ICC_Opportunity__c = :oppId
                              AND SICC_Itinerary_Content_Category__c = :finalDocHolder ];
            
            List<Selected_ICC_Copy__c> lstSICCO = new List<Selected_ICC_Copy__c>();
            if(lstSICC.size() > 0 && lstDocWrapper.size() > 0){
                String SICCO = lstSICC[0].Id;                  
                /* Insert records from Itinerary content to Copied Object */
                for(DocWrapper ic :lstDocWrapper){
                     lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Content__c = Ic.DocId,SICCO_Category__c = SICCO,SICCO_Country__c=ic.SICCO_CountryID,SICCO_Title__c = ic.SICCO_Title,SICCO_Description__c = ic.SICCO_Description,SICCO_Order__c = ic.SICCO_Order, CurrencyIsoCode=ic.CurrencyCode,SICCO_FinalDoc__c = ic.SICCO_FinalDoc,SICCO_Confirmation_Letter__c= ic.SICCO_Confirmation_Letter)); 
                }
                insert lstSICCO;
                lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Confirmation Letter Intro',SICCO_Description__c = letterObj.CLetterIntro,SICCO_FinalDoc__c=FALSE,SICCO_Confirmation_Letter__c=TRUE,SICCO_Order__c = '0',CurrencyIsoCode='GBP')); 
                lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Confirmation Letter Closing',SICCO_Description__c = letterObj.CLetterEnd,SICCO_FinalDoc__c=FALSE,SICCO_Confirmation_Letter__c=TRUE,SICCO_Order__c = '998',CurrencyIsoCode='GBP')); 
                lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Final Letter Intro',SICCO_Description__c = letterObj.FLetterIntro,SICCO_FinalDoc__c=TRUE,SICCO_Confirmation_Letter__c=FALSE,SICCO_Order__c = '0',CurrencyIsoCode='GBP')); 
                lstSICCO.add(new Selected_ICC_Copy__c(SICCO_Category__c = SICCO,SICCO_Title__c = 'Final Letter Closing',SICCO_Description__c = letterObj.FLetterEnd,SICCO_FinalDoc__c=TRUE,SICCO_Confirmation_Letter__c=FALSE,SICCO_Order__c = '999',CurrencyIsoCode='GBP')); 
                upsert lstSICCO;
            }
            else if(lstSICC.size() > 0 && lstOldDataWrapper.size() > 0){
                String SICCO = lstSICC[0].Id;                  
                for(DocWrapper ic :lstOldDataWrapper){
                     lstSICCO.add(new Selected_ICC_Copy__c(Id = Ic.recId,SICCO_Content__c = Ic.DocId,SICCO_Category__c = SICCO,SICCO_Country__c=ic.SICCO_CountryID,SICCO_Title__c = ic.SICCO_Title,SICCO_Description__c = ic.SICCO_Description,SICCO_Order__c = ic.SICCO_Order, CurrencyIsoCode=ic.CurrencyCode,SICCO_FinalDoc__c = ic.SICCO_FinalDoc,SICCO_Confirmation_Letter__c= ic.SICCO_Confirmation_Letter)); 
                }
                update lstSICCO;
            }
            if(lstSICC.size() == 0){
                return 'Error';
            }
            else{
                return 'Ok';
            }
        }
        Catch(Exception e){
            System.assert(false,e.getstacktraceString()+'############'+e.getMessage());
            return e.getMessage();
        }
    }
    
     //Fetch all the HE Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('FinalDoc'));
    }
    
    //To Refresh Content
    @remoteAction
    public static String refreshContent(String sccId, String OppId){
        //List<Selected_ICC_Copy__c>    lstSelectedIccCopy  = [Select Id, SICCO_Content__c from Selected_ICC_Copy__c where Id = ! :sccId and ]
        return null;
    }
    
    public Class DocWrapper{
        public String DocId{get; set;}
        public String recId{get; set;}
        public String SICCO_Title{get; set;}
        public String SICCO_Order {get; set;}
        public String SICCO_Country{get; set;}
        public String SICCO_CountryID{get; set;}
        public Boolean SICCO_Confirmation_Letter{get; set;}
        public Boolean SICCO_FinalDoc{get; set;}
        public String SICCO_Description{get; set;}
        public String Original_Description{get; set;}
        public String CurrencyCode{get; set;}
        
        public DocWrapper(String DocId, String recId, String SICCO_Title, String SICCO_Order , String SICCO_Country, String SICCO_CountryID,
                            Boolean SICCO_Confirmation_Letter, Boolean SICCO_FinalDoc,String SICCO_Description, String CurrencyCode){
            this.DocId = DocId;
            this.recId = recId;
            this.SICCO_Title = SICCO_Title;
            this.SICCO_Order = SICCO_Order;
            this.SICCO_Country = SICCO_Country;
            this.SICCO_CountryID = SICCO_CountryID;
            this.SICCO_Confirmation_Letter = SICCO_Confirmation_Letter;
            this.SICCO_FinalDoc  = SICCO_FinalDoc;
            this.SICCO_Description = SICCO_Description;
            this.CurrencyCode = CurrencyCode;
        }
    }
    
    public Class LetterWrapper{
        public string CLetterIntro{get;set;}
        public string CLetterEnd{get;set;}
        public string FLetterIntro{get;set;}
        public string FLetterEnd{get;set;}
            
        public LetterWrapper(String CLetterIntro, String CLetterEnd, String FLetterIntro, String FLetterEnd){
            this.CLetterIntro = CLetterIntro;
            this.CLetterEnd = CLetterEnd;
            this.FLetterIntro = FLetterIntro;
            this.FLetterEnd = FLetterEnd;
           
        }
    }
}
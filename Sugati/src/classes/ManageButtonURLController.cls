public with sharing class ManageButtonURLController {

    public String opp { get; set; }

     
        public ManageButtonURLController(){
         
         
        }
     
        public String getPageNames(){
            List<ApexPage> lst = [select id,Name,MasterLabel from Apexpage order by Name];
            Set<pickListValue> listApexpage = new Set<pickListValue>();
            for(Apexpage temp : lst){
                listApexpage.add(new pickListValue(temp.name,temp.MasterLabel));
            }
            return JSON.serialize(listApexPage);
        }
        
        public Class pickListValue{
            public String value{get; set;}
            public String label{get; set;}
            public String type{get; set;}
            
            public pickListValue(String value, String label){
                this.value = value;
                this.label = label;
                this.type = '';
            }
        }
    
        public String getCustomNames(){
            List<Custom_Button_URL__c> customList = [SELECT Id, Name, Acknowledgement_Email__c,ATOL__c,Client_Payments__c,Cover_Image__c,External_Booking_Form__c,
                            Final_Docs_Category__c,Final_Docs_Setting__c,Final_Message__c,Holiday_Enquiry__c,Itinerary_Settings__c,Itinerary_Web__c,
                            Holiday_Suggestion__c,Internal_Booking_Form__c,Itinerary_Builder__c,Itinerary_Category__c,Itinerary_Pdf__c,Questionnaire__c,
                            Send_Email__c,Supplier_Payments__c,Manage_Tasks__c FROM Custom_Button_URL__c order by Name];
            return JSON.serialize(customList);
        }
        
        
        @RemoteAction
         Public static void Save(String JSONStr){
             try{
             Custom_Button_URL__c custDeserialize= (Custom_Button_URL__c) JSON.deserialize(JSONStr, Custom_Button_URL__c.Class);
             //system.assert(false,custDeserialize);
             upsert custDeserialize;
             
             }catch(Exception ex){
                 
                 System.assert(false,ex.getMessage()); 
             }
         }


}
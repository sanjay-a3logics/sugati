global with sharing class TravellingCountryMapController {
    
    global String mapURL {get;set;}
    global TravellingCountryMapController(){
        mapURL = '';
        for(CSS_Styler__c cs : [select CS_Travelling_Country_Marker__c from CSS_Styler__c where Is_Active__c = true limit 1]){
            if(cs.CS_Travelling_Country_Marker__c != null)
                mapURL = cs.CS_Travelling_Country_Marker__c;
        }
    }
    
    
    @RemoteAction
    global static List<String> getTravellingCountriesLocation(String oppId){
        List<String> tcLst = new List<String>();
        for(Travelling_Country__c tc : [Select TC_Country__c, TC_Country__r.Name from Travelling_Country__c where TC_Opportunity__c =: oppId]){
            if(tc.TC_Country__c != null)
                tcLst.add(tc.TC_Country__r.Name);    
        }
        return tcLst;
    }
}
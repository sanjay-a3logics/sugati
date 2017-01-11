public with sharing class ErrorMessageController {

    public ErrorMessageController(Object obj) {

    }
    
    public ErrorMessageController(ApexPages.StandardController controller){
     
    }
    
    public static string HOLIDAY_SUGGESTION = 'HolidaySuggestion';
    public static string HOLIDAY_ENQUIRY = 'HolidayEnquiry';
    public static string ITINERARY_BUILDER = 'ItineraryBuilder';
        
    
    public static Map<String, String> getErrorMessage(string pagename) {
         pagename = pagename.replaceAll('sugati__','');
         Map<String,String> mapErrorMessage;
         if (mapErrorMessage == null) {
             mapErrorMessage = new Map<String,String>();
             for(Error_Message__c errorMessage: [select id, name, page_name__c, error_message__c from error_message__c where page_name__c=: pagename]) {
                 mapErrorMessage.put(errorMessage.name, errorMessage.error_message__c );
             }
         }
         return mapErrorMessage;
    }
    
    public static string getHolidaySuggestionText(string pagename, String errorMessageName) {
        return getErrorMessage(pagename).get(HOLIDAY_SUGGESTION + errorMessageName);
    }
    public static string getHolidayEnquiryText(string pagename, String errorMessageName) {
        return getErrorMessage(pagename).get(HOLIDAY_ENQUIRY + errorMessageName);
    }
    
    @remoteAction
    public static Map<string, String> getErrorMessages(String pagename) {
        return getErrorMessage(pagename);
    }
}
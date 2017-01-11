/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "ErrorMessageController"
* 
**/
 
@isTest
public class  ErrorMessageControllerTest {

    /** Create test data for executing test cases  **/
    @testSetup
    static void createTestData(){
        
        List<Error_Message__c> lstErrorMessage = new List<Error_Message__c>();
        lstErrorMessage.add(new Error_Message__c(Page_Name__c = 'HolidayEnquiry', Name = 'HolidayEnquiryTestMessage', Error_Message__c = 'test'));
        lstErrorMessage.add(new Error_Message__c(Page_Name__c = 'ItineraryBuilder', Name = 'ItineraryBuilderTestMessage', Error_Message__c = 'test'));
        lstErrorMessage.add(new Error_Message__c(Page_Name__c = 'HolidaySuggestion', Name = 'HolidaySuggestionTestMessage', Error_Message__c = 'test'));
        insert lstErrorMessage;
    }
    /** Test various operations of ErrorMessageController  **/
    static testMethod void errorMessageTest1(){
        
        Error_Message__c em = new Error_Message__c();
        ApexPages.standardController controller = new ApexPages.standardController(em);
        
        ErrorMessageController emc = new ErrorMessageController(controller);
        ErrorMessageController emc1 = new ErrorMessageController(em);
        
        ErrorMessageController.getHolidaySuggestionText('HolidaySuggestion', 'TestMessage');
        ErrorMessageController.getHolidayEnquiryText('HolidayEnquiry', 'TestMessage');
        ErrorMessageController.getErrorMessages('HolidayEnquiry'); 
    }
    
}
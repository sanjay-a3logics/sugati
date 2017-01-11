/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "CSSController"
* 
**/
 
@isTest
Private class CSSControllerTest {
   
    /** Test various operations of CSSController for new record **/
    Private Static testMethod void TestCSSController1(){
        
        Test.startTest();
        
        CSSController css = new CSSController();  
        String JSONData = css.getCSSData();
        css.getPageNames();
        CSSController.SaveCssData(JSONData); 
        
        Test.stopTest();
    }
    
    /** Test various operations of CSSController for existing record **/
    Private Static testMethod void TestCSSController2(){
        
        CSS_Styler__c cssRecord = new CSS_Styler__c(
            CS_Address_Marker__c = 'test', 
            Backgroundcolor__c = 'test', 
            CS_Itinerary_Page_Marker__c = 'test', 
            H1color__c  = 'test', 
            H2color__c  = 'test', 
            H3color__c  = 'test', 
            H4color__c  = 'test', 
            Hr_Background__c = 'test', 
            Hr_Height__c = 'test', 
            Email_Font_Family__c = 'test', 
            Email_Font_Style__c = 'test', 
            Email_Font_Color__c = 'test', 
            Font_Family__c = 'test', 
            Font_Size__c = 'test', 
            Font_Style__c = 'test',            
            Is_Active__c = true,
            Button__c = true,
            Email__c = true,
            Typography__c = true
        );
        insert cssRecord; 
        cssRecord.Id = null; 
        insert cssRecord; 
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', cssRecord.Id);
        CSSController css = new CSSController();
        CSSController.getAddressMarkerURL();      
        CSSController.getItineraryMarkerURL();     
        String JSONData = css.getCSSData();
        CSSController.SaveCssData(JSONData); 
        
        Test.stopTest();
    }
}
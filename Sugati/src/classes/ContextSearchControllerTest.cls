/**
*  @Author         :   Naval Sharma
*  @Date           :   25-Feb-2016
*  @Description    :   Test class for "ContextSearchController"
* 
**/

@isTest
class ContextSearchControllerTest{
    
    @testSetup
    static void setupTestData(){
        TestServices.createTriggerCustomSetting();
        TestServices.createSiteCustomSetting();
        List<Country__c> lstCountry = TestServices.createCountryRecords();
        TestServices.createWTGRecords(lstCountry[0].Id);   
        TestServices.createWTGRecords(lstCountry[1].Id);   
        TestServices.createHolidaySuggestions(TestServices.createSupplierRecords(lstCountry[0].Id)[0].Id, TestServices.createOpportunityRecords(1, null)[0].Id);
        TestServices.createHolidaySuggestions(TestServices.createSupplierRecords(lstCountry[1].Id)[0].Id, TestServices.createOpportunityRecords(1, null)[0].Id);
    }
    
    static testMethod void testSearchContext1(){
        Test.startTest();
        ContextSearchController csc = new ContextSearchController();
        Apexpages.currentpage().getParameters().put('q', 'test');
        csc.doSearch();
        System.assertNotEquals(csc.json, '');
        
        Apexpages.currentpage().getParameters().put('q', 'i');  
        csc.doSearch();  
        
        Apexpages.currentpage().getParameters().put('q', 'india');  
        csc.doSearch(); 
        
        Apexpages.currentpage().getParameters().put('q', 'test');  
        csc.doSearch();  
        csc.getResult();
        Test.stopTest();
    }
    
    static testMethod void testSearchContext2(){
        Test.startTest();
        ContextSearchController csc = new ContextSearchController();
        Country__c con = [Select id from Country__c WHERE name like '%india%' limit 1];
        con.Name = 'testCountry';
        update con;
        Apexpages.currentpage().getParameters().put('q', 'testCountry');  
        csc.doSearch();  
        
        Supplier__c supplier = [Select id from Supplier__c limit 1];
        supplier.Name = 'testSupplierABC';
        update supplier;
        Apexpages.currentpage().getParameters().put('q', 'testSupplierABC');  
        csc.doSearch(); 
        Test.stopTest(); 
    }
}
/**
 *  @Author         :   Naval Sharma
 *  @Date           :   24-Feb-2016
 *  @Description    :   Test class for "CategoryController"
 * 
 * */

@isTest
private class CategoryControllerTest{

    /** Setting up test data  **/
    
    @testSetup
    static void setupTestData(){
        Account TestAcc = new Account(Name = 'TestAccount');
        insert TestAcc ;  
        system.assert(TestAcc.Id != null);  
        
        //Create Record Type
        Record_Type__c rt = new Record_Type__c(Name = 'ST', RT_SObject_Type__c = 'Opportunity', RT_Active__c = true);
        insert rt;
        List<Opportunity>oppList=new List<Opportunity>();
        Opportunity opp=new Opportunity();
        opp.name='opp1';
        opp.stageName='Enquiry';
        opp.CloseDate=system.today()+4;
        opp.CurrencyIsoCode='GBP';
        opp.AccountId = TestAcc.Id;
        opp.O_RecordType__c = rt.Id;
        oppList.add(opp);
        insert oppList;
        
        Contact cont = new Contact(Salutation='testsal',LastName='testL',FirstName='testF',email='testemail@a.com',AccountId=TestAcc.Id);
        insert cont;
        system.assert(cont.Id != null);
        
        //Create ITC Records
        TestServices.createITCRecords();
        Country__c country = TestServices.createCountryRecords()[0];
        TestServices.createWTGRecords(country.Id);
        List<Supplier__c> lstSuppliers = TestServices.createSupplierRecords(country.Id);
        TestServices.createHolidaySuggestions(lstSuppliers[0].Id, opp.Id);
        TestServices.createSICCRecords(opp.Id, TestServices.createITCRecords()); 
        
    }
    
    /** Test various operations of the controller **/
    public static testMethod void testCategoryForData(){
        Opportunity opp = [SELECT id from Opportunity Limit 1];
        
        Test.StartTest();
        /*** Test Starts here  ****/
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp); 
        ApexPages.currentPage().getParameters().put('id',opp.id); 
        
        CategoryController AIC = new CategoryController(stdctrl);
        AIC.getCategories();
        AIC.getPageMessage();
        AIC.getFinalDocsCategories();
        AIC.FinalDocs_Save();
        CategoryController.changeCategories('Categories', opp.Id);
        CategoryController.Save(AIC.getCategories(), opp.Id, 'Categories');
        CategoryController.changeCategories('FinalDoc', opp.Id);
        CategoryController.Save(AIC.getCategories(), opp.Id, 'FinalDoc');
        
        /*** Test Ends here  ****/        
        Test.StopTest();

    }
    
     /** Test various operations of the controller **/
    public static testMethod void testCategoryForNoData(){
        Opportunity opp = [SELECT id from Opportunity Limit 1];
        delete [Select id from Selected_Itinerary_Content_Category__c];
        Test.StartTest();
        /*** Test Starts here  ****/
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp); 
        ApexPages.currentPage().getParameters().put('id',opp.id); 
        
        CategoryController AIC = new CategoryController(stdctrl);
        AIC.getCategories();
        AIC.getPageMessage();
        AIC.getFinalDocsCategories();
        AIC.FinalDocs_Save();
        CategoryController.changeCategories('Categories', opp.Id);
        CategoryController.Save(AIC.getCategories(), opp.Id, 'Categories');
        CategoryController.changeCategories('FinalDoc', opp.Id);
        CategoryController.Save(AIC.getCategories(), opp.Id, 'FinalDoc');
        
        /*** Test Ends here  ****/        
        Test.StopTest();

    }
}
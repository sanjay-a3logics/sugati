@isTest
public with sharing class ProcessPaymentsControllerTest{
    
    /*** Test case for successful payment ****/
    public static testMethod void uniTest1(){
        Account acc =new Account(name ='Test Account Checkout');
        insert acc;
        
        Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
        insert con;
        
        Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
        insert opp;
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        
        Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id, GM_Client_Group__c = clientGroups[0].Id, GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
        insert gm; 
        
        Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id, PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
        insert pl;                                        
        System.assertNotEquals(pl.id, NULL);
        Test.setCurrentPage(Page.ProcessPayments);
        ApexPages.currentPage().getParameters().put('id', pl.id);
        ApexPages.currentPage().getParameters().put('name', 'test%20user');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CheckoutMockChargeSuccess());
        ProcessPaymentsController ppc = new  ProcessPaymentsController();
        ppc.processing();
    }
    
    
    /*** Test case for api error ****/
    public static testMethod void uniTest3(){
        Account acc =new Account(name ='Test Account Checkout');
        insert acc;
        
        Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
        insert con;
        
        Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
        insert opp;
        
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        
        Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id, GM_Client_Group__c = clientGroups[0].Id, GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
        insert gm; 
        
        
        Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
        insert pl;                                        
        System.assertNotEquals(pl.id, NULL);
        
        Test.setCurrentPage(Page.ProcessPayments);
        ApexPages.currentPage().getParameters().put('id', pl.id);
        ApexPages.currentPage().getParameters().put('name', 'test%20user');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CheckoutMockChargeAPIError());
        ProcessPaymentsController ppc = new  ProcessPaymentsController();
        ppc.processing();
    }
    
    /*** Test case for payment error ****/
    public static testMethod void uniTest4(){
        Account acc =new Account(name ='Test Account Checkout');
        insert acc;
        
        Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
        insert con;
        
        Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
        insert opp;
        
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        
        Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id, GM_Client_Group__c = clientGroups[0].Id, GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
        insert gm;  
        
        Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
        insert pl;                                        
        System.assertNotEquals(pl.id, NULL);
        
        Test.setCurrentPage(Page.ProcessPayments);
        ApexPages.currentPage().getParameters().put('id', pl.id);
        ApexPages.currentPage().getParameters().put('name', 'test%20user');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CheckoutMockChargeFail());
        ProcessPaymentsController ppc = new  ProcessPaymentsController();
        ppc.processing();
    }
    
    /*** Test case for failed payment ****/
    public static testMethod void uniTest2(){
        Account acc =new Account(name ='Test Account Checkout');
        insert acc;
        
        Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
        insert con;
        
        Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
        insert opp;
        
        List<Client_Group__c> clientGroups = TestServices.createClientGroupRecords(2, opp.Id);
        
        Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id, GM_Client_Group__c = clientGroups[0].Id, GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
        insert gm; 
        
        Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
        insert pl;                                        
        System.assertNotEquals(pl.id, NULL);
        
        Test.setCurrentPage(Page.ProcessPayments);
        ApexPages.currentPage().getParameters().put('id', pl.id);
        ApexPages.currentPage().getParameters().put('name', 'test%20user');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CheckoutMockChargePaymentError());
        ProcessPaymentsController ppc = new  ProcessPaymentsController();
        ppc.processing();
        
        ApexPages.currentPage().getParameters().put('id', '');
        ApexPages.currentPage().getParameters().put('name', '');
        ppc = new  ProcessPaymentsController();
        ppc.processing();
        Test.StopTest();
    }
}
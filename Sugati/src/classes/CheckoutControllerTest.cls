@isTest
public with sharing class CheckoutControllerTest{

  public static testMethod void uniTest1(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCash = true;
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
  }
 public static testMethod void uniTest2(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byTransfer = true;
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
  } 
 public static testMethod void uniTest3(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCard = true;
     Test.StartTest();
     Test.setMock(HttpCalloutMock.class, new TestCheckoutMock());
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
     Test.stopTest();
     
  } 
 public static testMethod void uniTest4(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCardA = true;
     Test.StartTest();
     Test.setMock(HttpCalloutMock.class, new TestCheckoutMock());
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
     Test.stopTest();
     
  } 
  public static testMethod void uniTest5(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCard = true;
     Test.StartTest();
     Test.setMock(HttpCalloutMock.class, new CheckoutMockChargeFail());
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
     Test.stopTest();
     
  }
  public static testMethod void uniTest6(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
    
     
  }
  public static testMethod void uniTest7(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com',AccountId=acc.id);
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCheque=true;
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), null);
     chc.CalculateDue();
      
     
  }

  public static testMethod void uniTest8(){
     Account acc =new Account(name ='Test Account Checkout');
     insert acc;
     
     Contact con = new Contact(FirstName='Test1',LastName='State1',email='clone@abc.com');
     insert con;
     
     Opportunity opp = new Opportunity(name = 'Test opp checkout',accountId = acc.id,CloseDate = date.today(),stageName = 'Closed Won',
                                        Amount = 1559,CurrencyISOCode = 'GBP' ,pipeline__c = false,O_Departure_Date__c = date.today(),
                                         O_Ts_Cs__c = false);
     insert opp;
     
     Group_Member__c gm = new Group_Member__c(GM_Contact__c =con.id,GM_Lead_Passenger__c =true,GM_Opportunity__c = opp.id);
     insert gm; 
     
     Payment_Log__c pl = new Payment_Log__c(PL_Opportunity__c = opp.id,PL_Description__c ='hiiiii',PL_Payment_Amount__c = 123.00,PL_Currency_Code__c = 'GBP',
                                             PL_Card_Token__c='2345',PL_Card_Type__c ='Visa');
     insert pl;                                        
     System.assertNotEquals(pl.id, NULL);
     
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     CheckoutController chc = new  CheckoutController(sc);
     chc.byCash = true;
     chc.changeAddress();
     chc.confirm();
     chc.back();
     System.assertNotEquals(chc.createPaymentLog(pl.PL_Description__c,pl.PL_Payment_Amount__c,pl.PL_Currency_Code__c,pl.PL_Card_Token__c,pl.PL_Card_Type__c), NULL);
     chc.CalculateDue();
  }
}
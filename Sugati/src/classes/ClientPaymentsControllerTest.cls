/************************************************
** Module Name : ClientPaymentsControllerTest
** Description : Testing various operations of client payment
** Calls : TestServices
** Test Class : <Name of the test class that is used test this class>
** 
** Organization : Sugati
**
** Revision History:-
** Version    Date          Author          WO#     Description of Action
** 1.0        2-8-2016      Suraj Tripathi  NA      <NNNN>  Initial Version
** 1.0        2-25-2016     Naval Sharma    NA      Fixed the test methods which was written with wrong approach
************************************************/
@isTest
private class ClientPaymentsControllerTest {
     public static testMethod Void testMyController2(){
          
          test.startTest();
          List<Account>AccList=new List<Account>();
          Account Acc=new Account();
          Acc.Name='Test2';
          AccList.add(Acc);
          insert Acc;
          
          List<Contact>ConList=new List<Contact>();
          Contact Con=new Contact();
          Con.LastName='Con2';
          Con.CurrencyIsoCode='GBP';
          Con.AccountId=Acc.Id;
          con.Email = 'test@test.com';
          ConList.add(Con);
          insert ConList;
          
         
          List<Opportunity> oppList=new List<Opportunity>();
          Opportunity opp=new Opportunity();
          opp.name='opp1';
          opp.StageName='Enquiry';
          opp.CloseDate=system.today()+4;
          opp.AccountId=Acc.Id;
          opp.CurrencyIsoCode='GBP';
          oppList.add(opp);
          insert oppList;
         
          List<Client_Group__c> cgList = TestServices.createClientGroupRecords(2, oppList[0].Id);   
          Group_Member__c gm = new Group_Member__c(GM_Opportunity__c = oppList[0].Id, GM_Client_Group__c = cgList[0].Id, GM_Contact__c = con.Id, GM_Lead_Passenger__c = true);
          insert gm;
          List<Client_Payment__c> clList = new List<Client_Payment__c>();
          Client_Payment__c cl = new Client_Payment__c();
          cl.CP_Opportunity__c = oppList[0].Id;
          cl.CP_Amount__c = 100.00; 
          cl.CP_Processed_On__c = System.today();
          cl.CP_Payee__c = cgList[0].Id;
          clList.add(cl);
          insert cl;
          
          String oppId = oppList[0].Id;
          String CPJSON = JSON.serialize(cl);
         
          ApexPages.StandardController sc = new ApexPages.StandardController(opp);
          ClientPaymentsController ClientPay = new ClientPaymentsController(sc);
          ClientPay.getPickListValues();
          ClientPaymentsController.getClientPayments (oppId);
          ClientPaymentsController.saveClientPayment(CPJSON);
          cl.CP_Amount__c = null; 
          CPJSON = JSON.serialize(cl);
          ClientPaymentsController.saveClientPayment(CPJSON);
          ClientPay.getPageMessage();
     }

}
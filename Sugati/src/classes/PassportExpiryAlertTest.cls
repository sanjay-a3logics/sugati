@isTest
private class PassportExpiryAlertTest{
    
    @testSetup 
    static void testData() {
      Opportunity opp = new Opportunity();
      opp.Name='Test'; 
      opp.StageName='Active';
      opp.O_Departure_Date__c=date.newInstance(2016,9,4);
      opp.StageName = 'Booked';
      opp.CloseDate=system.today();
      insert opp;
      
      Contact con = new Contact();
      con.LastName = 'Test LastName';
      con.C_Expires_Date__c =date.newInstance(2016,8,27);
      insert con;
      
      Group_Member__c gmc = new Group_Member__c();
      gmc.GM_Opportunity__c=opp.Id;
      gmc.GM_Contact__c=con.Id;
      insert gmc;    
      
      Task tsk = new Task();
      tsk.Type='Email';
      tsk.Subject='Test';
      tsk.WhoId=con.Id;
      tsk.WhatId=opp.Id;
      insert tsk;
 
    }
    
     static testMethod void batchTestExecute(){
        
      List<Task> qry = new List<Task>([SELECT Id from Task LIMIT 1 ]);
      Test.startTest();
      PassportExpiryAlert passalert = new PassportExpiryAlert();
      Database.executeBatch(passalert,1);
      Test.stopTest();
    
    }
    


}
@isTest
private class BirthDateAlertTest{
    
    @testSetup 
    static void testData() {
      Opportunity opp = new Opportunity();
      opp.Name='Test'; 
      opp.StageName='Active';
      opp.O_Departure_Date__c=date.newInstance(2016, 8, 4);
      opp.O_Return_Date__c=date.newInstance(2016, 8, 14);
      opp.StageName = 'Booked';
      opp.CloseDate=system.today();
      insert opp;
      
      Contact con = new Contact();
      con.LastName = 'Test LastName';
      con.Birthdate=date.newInstance(1995, 8, 4);
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
    static testMethod void batchTestOne(){
        
      List<Task> qry = new List<Task>([SELECT Id from Task LIMIT 1 ]);
      Test.startTest();
      BirthDateAlert bdayalert = new BirthDateAlert();
      Database.executeBatch(bdayalert,1);
      Test.stopTest();
    
    }
    
   

}
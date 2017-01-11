global class BirthDateAlert implements Database.Batchable<Sobject>,Database.Stateful{
     
    global List<Group_Member__c> grpMemberListUpdate = new List<Group_Member__c>();
    global List<Task> alertTaskList = new List<Task>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id opid;
        String query='SELECT Id,GM_Contact__c, GM_Opportunity__r.OwnerId,Name,GM_Opportunity__r.Id,GM_Contact__r.id,GM_Opportunity__r.O_Departure_Date__c,GM_Contact__r.Birthdate,GM_Opportunity__r.O_Return_Date__c,BirthDate_Formula__c,Birthday_Alert_Check__c from Group_Member__c where GM_Opportunity__r.StageName=\'Booked\' AND  BirthDate_Formula__c= true AND Birthday_Alert_Check__c=false';
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC,List<Group_Member__c> scope){
        Set<Id> conId = new Set<Id>();
       
        for(Group_Member__c gm : scope){
          Task alertTask= new Task();
          if(gm.BirthDate_Formula__c){ 
             gm.Birthday_Alert_Check__c=true;
             alertTask.OwnerId =gm.GM_Opportunity__r.OwnerId;
             alertTask.Type='Email';
             alertTask.Subject='Happy Birthday!!';
             alertTask.WhoId=gm.GM_Contact__r.id;
             alertTask.WhatId= gm.GM_Opportunity__r.Id;
             grpMemberListUpdate.add(gm);
             alertTaskList.add(alertTask);
            }
        }
     }
    
    global void finish(Database.BatchableContext BC){
        try{
            insert alertTaskList;
            update grpMemberListUpdate;
            
        }
        catch(system.DMLException e){
            system.debug('Following Error has Occured'+ e.getMessage());
        }
    }


}
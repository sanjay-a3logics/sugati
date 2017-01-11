global class PassportExpiryAlert implements Database.Batchable<Sobject>, Database.Stateful{
     
     global List<Task> alertTaskList = new List<Task>();
     global List<Group_Member__c> grpMemberListUpdate = new List<Group_Member__c>();
     
     global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, GM_Contact__r.Id, GM_Contact__r.C_Expires_Date__c, GM_Contact__r.C_Passport_Number__c,GM_Opportunity__r.O_Departure_Date__c,GM_Opportunity__r.Id,GM_Opportunity__r.OwnerId,Passport_Expiry_Check__c from Group_Member__c where GM_Opportunity__r.StageName=\'Booked\' AND GM_Contact__r.C_Expires_Date__c!=null AND Passport_Expiry_Check__c=false';
        return Database.getQueryLocator(query);
     }
    
     global void execute(Database.BatchableContext BC,List<Group_Member__c> scope){
           for(Group_Member__c gm : scope){
               Task alertTask= new Task();
               if(gm.GM_Contact__r.C_Expires_Date__c<System.today() || ((gm.GM_Opportunity__r.O_Departure_Date__c.daysBetween(gm.GM_Contact__r.C_Expires_Date__c))/7)<5){  
                     gm.Passport_Expiry_Check__c=true;
                     alertTask.OwnerId =gm.GM_Opportunity__r.OwnerId;
                     alertTask.Type='Email';
                     alertTask.Subject='Passport is Going to Expire Soon!!!';
                     alertTask.WhoId=gm.GM_Contact__r.id;
                     alertTask.WhatId= gm.GM_Opportunity__r.Id; 
                     alertTaskList.add(alertTask);
                     grpMemberListUpdate.add(gm);
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
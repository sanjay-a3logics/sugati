public Class HolidayQuestion{

    public HolidayQuestion(){
    }
    
    public Static void TriggerBefore(){
         if(Site__c.getInstance().Run_Trigger__c){
             List<Holiday_Question__c> selectedHQ = new List<Holiday_Question__c>();
             List<String> lstHQIDS = new List<String>();
             Map<String,Task> mapExistingTasks = new Map<String,Task>();
             List<Task> newTasks = new List<Task>();
             for(Holiday_Question__c hq : (List<Holiday_Question__c>)Trigger.New){
                 if(hq.HQ_Create_Task__c){
                     selectedHQ.add(hq);
                     lstHQIDS.add(hq.Id);
                 }
             }
             for(Task tk : [Select Id,WhatId,Status,Subject,ActivityDate,Preference__c from Task where Preference__c in :lstHQIDS]){
                 mapExistingTasks.put(tk.Preference__c, tk);
             }
             for(Holiday_Question__c hq : selectedHQ){
                 if(mapExistingTasks.containsKey(hq.Id)){
                     Task tsk = mapExistingTasks.get(hq.Id);
                     tsk.ActivityDate  = Date.parse(hq.HQ_Answer__c);
                     newTasks.add(tsk);
                 }
                 else{
                     newTasks.add(new Task(OwnerId = hq.HQ_OwnerID_F__c,Subject = hq.HQ_Question_F__c,WhatId = hq.HQ_Opportunity__c,ActivityDate = Date.parse(hq.HQ_Answer__c),Status='Not Started',Preference__c=hq.Id));
                 }
             }
             
             upsert newTasks;
         }        
    }
}
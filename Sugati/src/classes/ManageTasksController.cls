public without sharing class ManageTasksController {

    public String oppId{get;set;}
    public Opportunity Opp{get;set;}
    public String recordtype{get; set;}
    public String contentcategoty{get;set;}
    public List <ItineraryContentCategory> FinalDocs_CategoryList {get;set;}
    public Map<String,Selected_Itinerary_Content_Category__c> mapSelectedCotegory {get;set;}
    public Static String nameSpacePrefix{get;set;}
    public String tasksFieldSet{get;set;}
    public String pickLists{get;Set;}
   
    
    public ManageTasksController(Apexpages.standardcontroller controller) {
        oppId = controller.getId();
        Opp = [select id, Name, O_RecordType__c, O_RecordType__r.Name,OwnerId,O_Departure_Date__c from Opportunity where Id=:oppId];
        ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        recordtype = '';
        mapSelectedCotegory = new Map<String,Selected_Itinerary_Content_Category__c>();
        pickLists = JSON.serialize(Utility.describePickListsStr('Opportunity,Task'));    
        tasksFieldSet = JSON.serialize(Utility.readFieldSet('Task').get('Sugati Tasks'));
        
        if (controller.getId() != null) {
            if(Opp.O_RecordType__c != null){
                recordtype  = opp.O_RecordType__r.Name;
            }
        }  
         
    }
    
    public String getPageMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('ManageTasks'));
    }
    
   
    /* This Method returns All categories and corrosponding to selected categories checkbox is true*/ 
    Map<String,String> mapSelectedMessage = new Map<String,String>();
    Set<String> setSelectedMessage  = new Set<String>();
    
    
    
    @RemoteAction
    public static String getTasks(String type, String oppId){
      try{
          ApexClass cs =[select NamespacePrefix from ApexClass where Name ='HolidayEnquiryController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        Opportunity Opp = [select id, Name, O_RecordType__c, O_RecordType__r.Name,OwnerId,O_Departure_Date__c from Opportunity where Id=:oppId];
        List<ContentCategory> categoryList = new List<ContentCategory>();
        Map<String,Task> existingQues = new Map<String,Task>();
        List<Task> lstOtherTasks = new List<Task>();
        Set<String> fieldNames = new Set<String>();
        List<Task> lstTasksAvl = new List<Task>();
        for(Schema.FieldSetMember fs : Utility.readFieldSet('Task').get('Sugati Tasks')){
            String fieldName = fs.fieldPath;
            fieldNames.add(fieldName.toLowerCase());   
        }
        
        if(type != '' && type != null){
            lstTasksAvl = Utility.getTasks(fieldNames, '('+nameSpacePrefix+'Preference__r.'+nameSpacePrefix+'HQ_Opportunity__c = \''+opp.Id+'\' Or WhatId = \''+opp.Id+'\') and '+nameSpacePrefix+'Type__c = \''+Type+'\'  order by activitydate limit 1000');
        }
        else{
            lstTasksAvl = Utility.getTasks(fieldNames, '('+nameSpacePrefix+'Preference__r.'+nameSpacePrefix+'HQ_Opportunity__c = \''+opp.Id+'\' Or WhatId = \''+opp.Id+'\')  order by activitydate limit 1000');    
        }
        for(Task tsk : lstTasksAvl){
            if(tsk.Preference__r.HQ_Question__c != null){
                existingQues.put(tsk.Preference__r.HQ_Question__c, tsk);
            }
            else{
                lstOtherTasks.add(tsk);
            }
        }
        
        if(type == '' || type == null){
            for(Question__c ques : [select Id, Name, Q_Question_Name__c from Question__c
                                                   Where Q_Task__c = true and Q_Stage__c = 'Enquiry' and Is_Active__c = true  Order By Name]) {
               if (existingQues.containsKey(ques.id)) {
                   CategoryList.add(new ContentCategory(ques,existingQues.containsKey(ques.id), 0, existingQues.get(ques.id)));
               }
               else {
                   CategoryList.add(new ContentCategory(ques,false,0, new Task(OwnerId = opp.OwnerId,Subject = 
                                   ques.Q_Question_Name__c,WhatId = opp.Id,ActivityDate = opp.O_Departure_Date__c,
                                   Status='Not Started')));
               }
            }
        }
        for(Task tsk : lstOtherTasks){
            CategoryList.add(new ContentCategory(null,true,0, tsk));
        }
        
        return JSON.serialize(CategoryList);
       }catch(exception e){
           system.assert(false,e.getMessage()+e.getLineNumber());
           return null;
       }
    }
    @RemoteAction
    public static List<ContentCategory> SavePopupTask(String taskStr, String oppId){
        try{
            Task tsk = (Task)JSON.deserialize(taskStr,Task.class);
            if(tsk.Id == null){
                Opportunity Opp = [select id, Name, O_RecordType__c, O_RecordType__r.Name,OwnerId,O_Departure_Date__c from Opportunity where Id=:oppId];
                tsk.OwnerId = opp.OwnerId;
                tsk.WhatId = opp.Id;
                if(tsk.ActivityDate == null){
                    tsk.ActivityDate = opp.O_Departure_Date__c;
                }
                if(tsk.Priority == null){
                    tsk.Priority = 'Normal';
                }
            }
            upsert tsk;
        }
        Catch(Exception e){
            system.assert(false,e.getMessage()+e.getLineNumber());    
        }
        return null;    
    }
    @RemoteAction
    public static List<ContentCategory> changeCategories(String type, String OppId){
      try{
       
        return null;
       }catch(exception e){
           system.assert(false,e.getMessage()+e.getLineNumber());
           return null;
       }
    }
    
    @RemoteAction
    Public static void Save(String categoryListstr,String oppid, String type){
        try{
            List<ContentCategory> categoryList = (List<ContentCategory>)JSON.deserialize(categoryListstr,List<ContentCategory>.class);
            List<Task> newTasks = new List<Task>();
            List<Task> deleteableTask = new List<Task>();
            for(ContentCategory cc : categoryList){
                if(cc.selected){
                    if(cc.tsk.Id == null){
                        newTasks.add(cc.tsk);
                    }
                }
                else{
                    if(cc.tsk.Id != null){
                        deleteableTask.add(cc.tsk);
                    }
                }
            }
            upsert newTasks;
            delete deleteableTask;   
        }  
        catch(DMLException e){
            system.assert(false,e.getMessage()+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0))); 
        }   
        catch(Exception e){
            system.assert(false,e.getMessage()+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
        }      
    }
    
    public class ContentCategory{
        Public Question__c questions{get;set;}
        Public Task tsk{get;set;}
        Public Boolean selected {get;set;}
        public Decimal PageNo {get;set;}
        
        Public ContentCategory(Question__c c, Boolean val, Decimal p, Task tsk)
        {
            this.questions = c;
            this.selected = val;
            this.PageNo = p;
            this.tsk = tsk;
        }
        
    }
    
    public class ItineraryContentCategory{
        
        Public Itinerary_Content_Category__c category {get;set;}
        Public Boolean selected {get;set;}
        public Decimal PageNo {get;set;}
        
        Public ItineraryContentCategory(Itinerary_Content_Category__c c, Boolean val, Decimal p)
        {
            this.category = c;
            this.selected = val;
            this.PageNo = p;
        }
        
    }
    
    public PageReference pageReferenceMethod() {
        if(Pro_UE__c.getInstance().Task_Management__c){
            return null;
        }
        else{
            PageReference pageRef = new PageReference('/apex/'+nameSpacePrefix+'NeedUpgrade');
            pageRef.setRedirect(true);
            return pageRef ;
        }
        
    }
}
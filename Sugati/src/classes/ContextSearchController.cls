public class ContextSearchController{
    public String json {get;set;}
     
    public void doSearch() {       
      try { 
      String searchFor = Apexpages.currentpage().getParameters().get('q');     
      String likeclause = '%'+searchfor+'%';
      String accom = 'Accommodation' ;
      String hot = 'Hotel' ;
     
      String wherequery = 'select id,name,W_Country__r.name,W_Where_to_go__r.name from Where_to_go__c where  W_Archive__c = false and ((name!=null AND W_Country__r.name != null) and (name like: likeclause OR W_Where_to_go__r.name like : likeclause )) ';
      String WhatQuery = 'select id,name,WH_Country__r.name,WH_Where_to_go__r.name from Activity__c where  WH_Archive__c = false and ((name!=null AND WH_Country__r.name != null) and (name like: likeclause OR WH_Where_to_go__r.name like : likeclause  ))  ';
      
      String SupplierQuery = 'Select id,Name,S_Country__c,S_Where_to_go__r.name from Supplier__c where S_Archive__c = false and (( S_Type__c =  \''+accom+'\' OR S_Type__c = \''+hot+'\' ) AND ( Name!=null AND S_Country__c!= null  ) and (Name like: likeclause  OR S_Where_to_go__r.name like : likeclause   ))  ';
      String CountryQuery = 'Select id,name from Country__c where C_Archive__c = false and ( name != null AND  name like: likeclause) ' ; 
                                                                                                       
      List<Where_to_go__c> wheretogo= Database.query(wherequery);
      integer i = 0;
      json = '[';
      for (Where_to_go__c wtg: wheretogo) {
          if (i ==0) {
              json += '{"value": "'+wtg.id+'", "name": "'+wtg.name+'", "Country": "'+wtg.W_Country__r.name+'" ,"WhereToGo": "'+ +'" ,"type":"WhereToGo"}';
              i ++;
          }
          else {
              json += ','+ '{"value": "'+wtg.id+'", "name": "'+wtg.name+'","Country": "'+wtg.W_Country__r.name+'" , "WhereToGo": "'+ +'" , "type":"WhereToGo"}';
          }
      }
      
      List<Country__c> countr = Database.query(CountryQuery);
      for (Country__c coun: countr) {
          if (i ==0) {
              json += '{"value": "'+coun.id+'", "name": "'+coun.name+'","Country": "'+ +'" ,"WhereToGo": "'+ +'" ,"type":"Country"}';
              i ++;
          }
          else {
              json += ','+ '{"value": "'+coun.id+'", "name": "'+coun.name+'","Country": "'+ +'" ,"WhereToGo": "'+ +'" ,"type":"Country"}';
          }
      }
      
      
      
      List<Activity__c> whattodo = Database.query(Whatquery);
      for (Activity__c wtd: whattodo ) {
          if (i ==0) {
              json += '{"value": "'+wtd.id+'", "name": "'+wtd.name+'","Country": "'+wtd.WH_Country__r.name+'" ,"WhereToGo": "'+wtd.WH_Where_to_go__r.name+'" , "type":"WhatToDo"}';
              i ++;
          }
          else {
              json += ','+ '{"value": "'+wtd.id+'", "name": "'+wtd.name+'","Country": "'+wtd.WH_Country__r.name+'" ,"WhereToGo": "'+wtd.WH_Where_to_go__r.name+'" , "type":"WhatToDo"}';
          }
      }
      
      List<Supplier__c> supplier = Database.query(SupplierQuery);
      for (Supplier__c supp: supplier ) {
          if (i ==0) {
              json += '{"value": "'+supp.id+'", "name": "'+supp.Name+'","Country": "'+supp.S_Country__c+'" ,"WhereToGo": "'+supp.S_Where_to_go__r.name+'",  "type":"WhereToStay"}';
              i ++;
          }
          else {
              json += ','+ '{"value": "'+supp.id+'", "name": "'+supp.Name+'","Country": "'+supp.S_Country__c+'" ,"WhereToGo": "'+supp.S_Where_to_go__r.name+'", "type":"WhereToStay"}';
          }
      }
      
                
      json += ']';
      
      } 
      catch(Exception e) {
          throw e;
      }     
    }
   
    // Returns the JSON result string
    public String getResult() {
        return json;
    }
    
    
     
}
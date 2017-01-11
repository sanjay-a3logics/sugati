public with sharing class SObjectJSONCreator {

public String nameSpacePrefix{get; set;}

    public SObjectJSONCreator(){  
        
       ApexClass cs =[select NamespacePrefix from ApexClass where Name ='SObjectJSONCreator'];
       if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }   
    }

    public String getJSON()
    {
       try{
           String conditions = Apexpages.currentPage().getParameters().get('Condition'); 
            String sObjectName = Apexpages.currentPage().getParameters().get('sObjName');
                       
            List<sObjectWrapper> wrp = new List<sObjectWrapper>();
            
              if(sObjectName != null){
            
                // Convert to schema.sObjectType
                Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(sObjectName);
                
                String query='';
                if(conditions != null)
                {
                    query= 'Select Id, Name From '+ sObjectName +' Where '+ conditions; 
                }
                else
                {
                    query= 'Select Id, Name From '+ sObjectName; 
                }                
               
                for(SObject record : Database.query(query)){              
                   sObjectWrapper w = new sObjectWrapper((String)record.get('Name'), (String)record.get('Id'));
                   wrp.add(w);           
                }  
         
            }           
            return JSON.serialize(wrp);
         }
       catch(Exception e)
       {
           system.assert(false, e.getMessage());    
           return  null;
       }
    } 
   
    public class sObjectWrapper
    {
        String label,value;

        public sObjectWrapper(String aName, String i)
        {
            label = aName;
            value= i ;
        }
    }
    
}
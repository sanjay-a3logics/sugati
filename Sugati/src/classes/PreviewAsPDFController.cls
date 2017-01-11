public without sharing class PreviewAsPDFController{
    public string selectedClientGroup{get;set;}   
    public Opportunity Opp{get;set;}
    public String nameSpacePrefix{get;set;}
    
    public PreviewAsPDFController(Apexpages.standardcontroller controller){
        if (controller.getId() != null) {
            Opp = [select id, Name from Opportunity where Id = : controller.getId()];
        }
        ApexClass cs =[select NamespacePrefix from ApexClass where Name ='PreviewAsPDFController'];
        if(cs.NamespacePrefix != null){
            nameSpacePrefix = cs.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
    }
     
    public PageReference checkCGs(){
        if([Select Id from Client_Group__c where CG_Opportunity__c = :Opp.Id].size() <= 1){
            PageReference ref = new PageReference('/apex/'+nameSpacePrefix+'ItineraryPDFA4?id='+opp.Id);    
            ref.setRedirect(true);
            return ref;
        }
        else{
            return null;
        }
    }
    
    public List<SelectOption> getClientGroup(){ 
        List<SelectOption> lstCgs = new List<SelectOption>();
         try{
            for(Client_Group__c cg  : [SELECT Id,Name from Client_Group__c where CG_Opportunity__c = :Opp.Id order by Name]){   
                if(selectedClientGroup == null){
                    selectedClientGroup = cg.Id;
                }
                lstCgs.add(new selectOption(cg.Id, cg.Name));
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error : '+e.getMessage()));
        }
        return lstCgs;
    }
}
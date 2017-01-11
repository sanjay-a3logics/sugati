public class HolidaySuggestionController{

    public HolidaySuggestionController(ApexPages.StandardController controller){
        
    }
    
    public PageReference pageReferenceMethod() {
        
        if(Pro_UE__c.getInstance().Holiday_Suggestion__c){
            return null;
        }
        else{
            PageReference pageRef = new PageReference('/apex/'+Site__c.getInstance().Namespace__c+'NeedUpgrade');
            pageRef.setRedirect(true);
            return pageRef ;
        }
        
    }



}
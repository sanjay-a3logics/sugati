public class UnLockOpportunityController {
    public String OppIds{get; set;}
    public UnLockOpportunityController(Apexpages.standardController controller) {
        
        
    }
    
    public Pagereference UnLockOpportunity() {
        try{
            String oppId = Apexpages.currentPage().getParameters().get('id');
            //Check logged in user's profile is LF Management Team
            String profileId = UserInfo.getProfileId();
            Profile profile = [select name from Profile where id =: profileId];
            if(profile.Name != Trigger_Setting__c.getInstance().Unlock_Opportunit_approver_profile__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not authorized to lock this opportunity.'));
                return null;
            }
           
            Opportunity opp=[Select id,O_Lock__c from opportunity where id=:oppId ];
            opp.O_Lock__c=false;
            
            List<Supplier_Booking__c> SupplierBookings = new List<Supplier_Booking__c>();
            Set<Id> supplierRequest = new Set<Id>();
            for(Supplier_Booking__c sb:[Select id,SB_Lock__c from Supplier_Booking__c where SB_Opportunity__c=:oppId]){
                sb.SB_Lock__c=false;
                supplierBookings.add(sb);
            }
           
            Update opp;
            Update supplierBookings;
            return new Pagereference('/'+oppId);
        }
        Catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select Unlock field on Opportunity detail page.');
            ApexPages.AddMessage(myMsg );
            return null;
        }
    }
}
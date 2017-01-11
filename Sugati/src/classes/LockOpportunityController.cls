public class LockOpportunityController {
    public String OppIds{get; set;}
    public LockOpportunityController(Apexpages.standardController controller) {
        
        
    }
    
    public Pagereference lockOpportunity() {
        try{
            //Check logged in user's profile is LF Management Team
            /*String profileId = UserInfo.getProfileId();
            Profile profile = [select name from Profile where id =: profileId];
            if(profile.Name != 'System Administrator'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not authorized to lock this opportunity.'));
                return null;
            }
            */
            String oppId = Apexpages.currentPage().getParameters().get('id');
            OppIds = oppId ;
            Opportunity opp=[Select id,O_Lock__c from opportunity where id=:oppId ];
            opp.O_Lock__c=True;
            List<Supplier_Booking__c> SupplierBookings = new List<Supplier_Booking__c>();
            for(Supplier_Booking__c sb:[Select id,SB_Lock__c from Supplier_Booking__c where SB_Opportunity__c=:oppId]){
                sb.SB_Lock__c =True;
                supplierBookings.add(sb);
            }
           Update opp;
           Update supplierBookings;
           
            return new Pagereference('/'+oppId);
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+'DDD'+e.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select lock field on Opportunity detail page.');
            ApexPages.AddMessage(myMsg );
            return null;
        }
    }
}
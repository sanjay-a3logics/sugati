public with sharing Class TriggerHandler implements ITrigger{
    
    public TriggerHandler(){
    
    }
    
    public void bulkBefore(Schema.sObjectType soType) {
        /*if(soType == Travelling_Country__c.sObjectType){ 
            Triggers.TravellingCountryTrigger(); 
        }*/
        if(soType == Supplier_Cost__c.sObjectType){
            Triggers.SupplierCostTrigger();    
        }
        if(soType == Opportunity.sObjectType){
            Triggers.OpportunityTrigger();    
        }
        if(soType == Client_Invoice__c.sObjectType){
            ClientInvoiceTriggers.ClientInvoiceTriggerBefore();
        }
        if(soType == Client_Payment__c.sObjectType){
            ClientPaymentTriggers.ClientPaymentTriggerBefore();
        }
        if(soType == Contact.sObjectType){
            Triggers.ContactTriggerBefore();
        }
    }
    
    public void bulkAfter(Schema.sObjectType soType){
        if(soType == Travelling_Country__c.sObjectType){
            Triggers.TravellingCountryTrigger();   
        }
        if(soType == Group_Member__c.sObjectType){
            Triggers.GroupMembersTrigger();   
        }
        if(soType == Supplier_Cost__c.sObjectType){
            Triggers.SupplierCostTrigger();    
        }
        if(soType == Opportunity.sObjectType){
            Triggers.OpportunityTrigger();    
        }
        if(soType == Supplier_Booking__c.sObjectType){
            Triggers.SupplierBookingTrigger();
        }
        if(soType == Client_Payment__c.sObjectType){
            ClientPaymentTriggers.ClientPaymentTriggerAfter();
        }
        if(soType == Holiday_Question__c.sObjectType){
            HolidayQuestion.TriggerBefore();
        }
    }
        
    public void beforeInsert(SObject so){
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {   
        
    }
    
    public void afterInsert(SObject so)
    {
    }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {
    }
    
    public void afterDelete(SObject so)
    {
    }
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
       
    }
}
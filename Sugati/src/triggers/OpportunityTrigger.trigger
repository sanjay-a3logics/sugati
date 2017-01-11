trigger OpportunityTrigger on Opportunity(before insert, before update,after insert, after update, after delete) {
    //Run this trigger only if Custom setting field is checked
    if(Configurations.triggerSettings.Opportunity_Trigger__c)
        TriggerFactory.createHandler(Opportunity.sObjectType);
}
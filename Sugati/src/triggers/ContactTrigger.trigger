trigger ContactTrigger on Contact (before insert,before update) {
    if(Configurations.triggerSettings.Contact_Trigger__c)
        TriggerFactory.createHandler(Contact.sObjectType);  
}
trigger PreferencesTrigger on Holiday_Question__c (after insert, after update) {
     //Run this trigger only if Custom setting field is checked
    if(Configurations.triggerSettings.Holiday_Question__c)
        TriggerFactory.createHandler(Holiday_Question__c.sObjectType);
}
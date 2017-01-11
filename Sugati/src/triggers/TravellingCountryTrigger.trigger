trigger TravellingCountryTrigger on Travelling_Country__c(before insert, before update,after insert, after update, after delete) {
    //Run this trigger only if Custom setting field is checked
    if(Configurations.triggerSettings.Travelling_Country_Trigger__c)
        TriggerFactory.createHandler(Travelling_Country__c.sObjectType);
}
trigger GroupMembersTrigger on Group_Member__c(after insert, after update, after delete) {
    if(Configurations.triggerSettings.Group_MembersTrigger__c)
        TriggerFactory.createHandler(Group_Member__c.sObjectType);
}
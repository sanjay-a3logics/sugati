trigger ClientPayment on Client_Payment__c(before insert, before update) {
    TriggerFactory.createHandler(Client_Payment__c.sObjectType);   
}
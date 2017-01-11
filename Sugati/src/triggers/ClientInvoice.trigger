trigger ClientInvoice on Client_Invoice__c (before insert) {
    TriggerFactory.createHandler(Client_Invoice__c.sObjectType);    
}
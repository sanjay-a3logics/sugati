trigger SupplierCostTrigger on Supplier_Cost__c(before insert, before update,after insert, after update, after delete) {
    //Run this trigger only if Custom setting field is checked
    if(Configurations.triggerSettings.Supplier_Cost_Trigger__c)
        TriggerFactory.createHandler(Supplier_Cost__c.sObjectType);
}
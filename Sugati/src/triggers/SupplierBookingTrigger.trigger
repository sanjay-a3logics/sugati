trigger SupplierBookingTrigger on Supplier_Booking__c(before insert, before update,after insert, after update, after delete) {
    //Run this trigger only if Custom setting field is checked
    if(Configurations.triggerSettings.Supplier_Booking_Trigger__c)
        TriggerFactory.createHandler(Supplier_Booking__c.sObjectType);
}
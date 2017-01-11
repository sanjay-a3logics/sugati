global class ApexScheduledClassBirthDateAndPassport Implements Schedulable{
     
    global void execute(SchedulableContext sc) {
         ID BirthdayBatchId = Database.executeBatch(new BirthDateAlert(), 200);
         Id PassportBatchId = Database.executeBatch(new PassportExpiryAlert(), 200);
    } 
    
}
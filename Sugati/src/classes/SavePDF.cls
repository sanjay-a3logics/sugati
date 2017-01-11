public Class SavePDF{
    
    String oppId;
    Opportunity opp;
    public SavePDF(Apexpages.standardcontroller controller){
        oppId = controller.getId();
        if (controller.getId() != null) {
            Opp = [select id, Name,O_Margin__c, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                   O_Adult__c,O_Children__c,O_Infant__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Booking_Currency__c,StageName,O_Itinerary_Cover_Name__c,O_Due_Date__c,
                   O_Itinerary_Display_Price__c,O_Total_Payment__c
                   from Opportunity 
            where Id=:oppId];
            
        }
    }
    
    //For save itinerary PDF page use only
    public void savePDF(){
        if(oppId != null){
            Pagereference PDFSS = new Pagereference('/apex/ItineraryPDFA4');
            PDFSS.getParameters().put('id',oppId);
            Attachment att = new Attachment();
            att.parentId = oppId;
            if(!Test.isRunningTest()){
                att.body = PDFSS.getContentAsPDF();
            }
            else{
                att.body = Blob.valueOf('Unit Test Attachment Body');
            }
            att.Name = Opp.name+'.pdf';
            insert att;
        }
    }
}
global class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            createHEQuestionCategories();
            
            createItineraryCategories();
            
            createErrorMessages();
        }
        if(context.isUpgrade()) {
      
        }
        if(context.isPush()) {
     
        }
    }
    
    public void createHEQuestionCategories() {
        
        List<HE_Question_Categories__c> hcs = new List<HE_Question_Categories__c>();
        hcs.add( new HE_Question_Categories__c(name = 'General' , QC_Active__c = true, QC_Order__c = 0));
        hcs.add( new HE_Question_Categories__c(name = 'Accommodation' , QC_Active__c = true, QC_Order__c = 1));
        hcs.add( new HE_Question_Categories__c(name = 'Activities' , QC_Active__c = true, QC_Order__c = 2));
        hcs.add( new HE_Question_Categories__c(name = 'Logistics' , QC_Active__c = true, QC_Order__c = 3));
        //hcs.add( new HE_Question_Categories__c(name = 'General' , QC_Active__c = true, QC_Order__c = 4));
        //hcs.add( new HE_Question_Categories__c(name = 'General' , QC_Active__c = true, QC_Order__c = 5));
        
        insert hcs;
        
        createQuestions(hcs);
    }
    
    public void createQuestions(List<HE_Question_Categories__c> hcs ) {
        
        List<Question__c> questions = new List<Question__c>();
        for (HE_Question_Categories__c hc: hcs) {
            
            if (hc.name == 'General')  {
                questions.add( new Question__c(
                Q_Question_Name__c ='What is the most important thing for you on this trip?', 
                Q_Ack_Question_Title__c='What is the most important thing for you on this trip?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Account', Q_Order__c = 1 ));
                
            }
            if (hc.name == 'Accommodation')  {
                questions.add( new Question__c(
                Q_Question_Name__c ='What is your preferred type of accommodation, e.g. rustic or modern, small or large, remote close to other things to do etc.?', 
                Q_Ack_Question_Title__c='What is your preferred type of accommodation, e.g. rustic or modern, small or large, remote close to other things to do etc.?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Picklist', 
                Q_Options__c ='Room only, Self catering, Bed and breakfast, Half board, Full board, All inclusive',
                Q_Related_To__c='Account', Q_Order__c = 1 ));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Are there particular hotels you have stayed at before that you really liked/disliked?', 
                Q_Ack_Question_Title__c='Are there anything that you like and dislike about this hotel?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Account', Q_Order__c = 2 ));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Are there any particular facilities you require, e.g. spa, gym, tennis court etc?', 
                Q_Ack_Question_Title__c='Are there any particular facilities you require, e.g. spa, gym, tennis court etc?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 3));
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='What type of room do you want, e.g. entry-level, junior suite, water villa vs. beach bungalow etc.?', 
                Q_Ack_Question_Title__c='What type of room do you want, e.g. entry-level, junior suite, water villa vs. beach bungalow etc.?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 4));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='For families: Are there any particular family facilities you require, e.g. babysitting, kids club, doctor etc.?', 
                Q_Ack_Question_Title__c='For families: Are there any particular family facilities you require, e.g. babysitting, kids club, doctor etc.?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 5));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Anything else?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 6));
                
            }
            
            if (hc.name == 'Activities')  {
                questions.add( new Question__c(
                Q_Question_Name__c ='Are there any specific activities you like to do, e.g. water sports, hiking, biking etc.?', 
                Q_Ack_Question_Title__c='Are there any specific activities you like to do, e.g. water sports, hiking, biking etc.?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Account', Q_Order__c = 1 ));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Are all members of the group swimmers?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Radio', 
                Q_Options__c = 'Yes, No',
                Q_Related_To__c='Opportunity', Q_Order__c = 2 ));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Are all members of the group divers?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Radio', 
                Q_Options__c = 'Yes, No',
                Q_Related_To__c='Opportunity', Q_Order__c = 3));
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Do you have any specific activities in mind ?', 
                Q_Ack_Question_Title__c='Do you have any specific activities in mind ?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Checkbox', 
                Q_Options__c = 'Walking, Swimming, Diving, Cycling',
                Q_Related_To__c='Opportunity', Q_Order__c = 4));
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Anything else?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 5));
                
            }
            
            if (hc.name == 'Logistics')  {
                questions.add( new Question__c(
                Q_Question_Name__c ='Where will you be travelling from?', 
                Q_Ack_Question_Title__c='Travelling from?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 1 ));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Where will you be returning to?', 
                Q_Ack_Question_Title__c='Where will you be returning to?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 2));
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Do you have any airline preference?', 
                Q_Ack_Question_Title__c='Do you have any airline preference?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 3));
                
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Do you have a preferred class of travel?', 
                Q_Ack_Question_Title__c='Do you have a preferred class of travel?',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Picklist', 
                Q_Options__c = 'Economy, Business, First, Private',
                Q_Related_To__c='Opportunity', Q_Order__c = 4));
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='If hiring a car, what do you prefer?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 5));
                
                
                questions.add( new Question__c(
                Q_Question_Name__c ='Anything else?', 
                Q_Ack_Question_Title__c='',
                Is_Active__c = true, Q_Category__c = hc.Id, Q_Type__c ='Text', 
                Q_Related_To__c='Opportunity', Q_Order__c = 6));
                
            }
            
        }
        insert questions;
    }
    
    public void createItineraryCategories() {
        List<Itinerary_Content_Category__c> iccs = new List<Itinerary_Content_Category__c>();
        iccs.add(new Itinerary_Content_Category__c( name = 'COVER', ICC_Order__c = '1'));
        iccs.add(new Itinerary_Content_Category__c( name = 'BOOKING PROCESS', ICC_Order__c = '2'));
        iccs.add(new Itinerary_Content_Category__c( name = 'TAILORED FOR YOU', ICC_Order__c = '3'));
        iccs.add(new Itinerary_Content_Category__c( name = 'A NOTE FROM YOUR DESIGNER', ICC_Order__c = '4'));
        iccs.add(new Itinerary_Content_Category__c( name = 'ITINERARY AT A GLANCE', ICC_Order__c = '5'));
        iccs.add(new Itinerary_Content_Category__c( name = 'YOUR ITINERARY', ICC_Order__c = '6'));
        iccs.add(new Itinerary_Content_Category__c( name = 'HOLIDAY OVERVIEW', ICC_Order__c = '7'));
        iccs.add(new Itinerary_Content_Category__c( name = 'TRAVEL SUMMARY', ICC_Order__c = '8'));
        iccs.add(new Itinerary_Content_Category__c( name = 'QUOTATION', ICC_Order__c = '9'));
        iccs.add(new Itinerary_Content_Category__c( name = 'ITINERARY END', ICC_Order__c = '10'));
        iccs.add(new Itinerary_Content_Category__c( name = 'WHAT IT COSTS', ICC_Order__c = '11'));
        iccs.add(new Itinerary_Content_Category__c( name = 'PLEASE DON\'T FORGET', ICC_Order__c = '12'));
        iccs.add(new Itinerary_Content_Category__c( name = 'OUR EXPERTISE', ICC_Order__c = '13'));
        iccs.add(new Itinerary_Content_Category__c( name = 'WHY US', ICC_Order__c = '14'));
        iccs.add(new Itinerary_Content_Category__c( name = 'TICKETS AND VOUCHERS', ICC_Order__c = '15'));
        iccs.add(new Itinerary_Content_Category__c( name = 'CONFIRMATION LETTER', ICC_Order__c = '16'));
        iccs.add(new Itinerary_Content_Category__c( name = 'CONFIRMATION INVOICE', ICC_Order__c = '17'));
        iccs.add(new Itinerary_Content_Category__c( name = 'FINAL DOCS LETTER', ICC_Order__c = '18'));
        insert iccs;
        
        
    }
    
    public void createErrorMessages() {
    
        List<Error_Message__c> errorMessages = new List<Error_Message__c>();
        
        errorMessages.add(new Error_Message__c( name ='HE_EmailInvalid', Error_Message__c ='Invalid email address!', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_LastnameRequired', Error_Message__c ='This field is required', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_PhoneInvalid', Error_Message__c ='Please enter valid phone number', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_ReferrerInvalid', Error_Message__c ='Invalid referrer address', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='editable', Error_Message__c ='Please provide valid value', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_AirlineMembership_Save', Error_Message__c ='Airline membership information successfully saved.', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_NoMatchedAccountFound', Error_Message__c ='No account found with the provided information.', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_Fill_Required_Details', Error_Message__c ='Please fill all the required details!', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_Brochure_Request_Created', Error_Message__c ='Brochure Request has been created', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_Select_Record', Error_Message__c ='Please select a record', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_Create_Account_First', Error_Message__c ='Please create an account first.', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='Mail_Sent', Error_Message__c ='Mail has been sent to provided email addresses.', page_name__c ='HolidayEnquiry'));
        errorMessages.add(new Error_Message__c( name ='HE_Invalid_Departure_Returning_Dates', Error_Message__c ='Please make sure travelling dates are valid!', page_name__c ='HolidayEnquiry'));
        
        errorMessages.add(new Error_Message__c( name ='HE_Brochure_Request_Created', Error_Message__c ='Brochure Request has been created', page_name__c ='HolidaySuggestion'));
        errorMessages.add(new Error_Message__c( name ='HE_Select_Record', Error_Message__c ='Please select a record', page_name__c ='HolidaySuggestion'));
        errorMessages.add(new Error_Message__c( name ='Mail_Sent', Error_Message__c ='Mail has been sent to provided email addresses.', page_name__c ='HolidaySuggestion'));
        
        
        errorMessages.add(new Error_Message__c( name ='Mail_Sent', Error_Message__c ='Acknowledgement email successfully sent.', page_name__c ='AckPage'));
        errorMessages.add(new Error_Message__c( name ='Client_Payment_Save', Error_Message__c ='Client payment has been saved successfully.', page_name__c ='ClientPayments'));
        errorMessages.add(new Error_Message__c( name ='Mail_Sent', Error_Message__c ='Email successfully sent.', page_name__c ='SendEmail'));
        errorMessages.add(new Error_Message__c( name ='Mail_Sent', Error_Message__c ='Email successfully sent.', page_name__c ='SupplierPayments'));
        
        errorMessages.add(new Error_Message__c( name ='CPS_Cover_Image_Update_Success', Error_Message__c ='Cover Image has been updated Successfully.', page_name__c ='CoverPageSelector'));
        errorMessages.add(new Error_Message__c( name ='CPS_Must_Select_Image', Error_Message__c ='You must select a cover image.', page_name__c ='CoverPageSelector'));
        errorMessages.add(new Error_Message__c( name ='IB_Airport_Not_Found', Error_Message__c ='Airport not found to attach transfer option', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Cant_Delete_Supplier_Cost', Error_Message__c ='Can\'t Delete Supplier Cost, Please remove supplier payment first.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Cant_Overwrite_Existing_Itinerary_Text', Error_Message__c ='Can\'t overwrite the existing Itinerary Text. Please contact the Content Team to update the record.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Fill_Holiday_Type_Enquiry', Error_Message__c ='Please fill the holiday type for enquiry.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Fill_Required_Fields', Error_Message__c ='Please fill the required fields.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Fill_Supplier_WTG_WTD_Airport', Error_Message__c ='Please fill supplier/WTG/WTD/Airport to save itinerary text.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Itinerary_Text_Created', Error_Message__c ='A itinerary text message has been created.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Records_Updated_Success', Error_Message__c ='Records have been updated successfully.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Select_Component_First', Error_Message__c ='Please select component first.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Supplier_Costs_Updated', Error_Message__c ='Supplier Costs have been updated.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IB_Transfer_Option_Created', Error_Message__c ='A transfer option has been created.', page_name__c ='ItineraryBuilder'));
        errorMessages.add(new Error_Message__c( name ='IC_Records_Updated_Success', Error_Message__c ='Records have been updated successfully.', page_name__c ='ItineraryCategory'));
        
        
    }
}
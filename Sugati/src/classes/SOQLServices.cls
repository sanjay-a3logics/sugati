public with sharing Class SOQLServices{
    public SOQLServices(){
        
    }
    public static List<Opportunity> getOpportunities(Set<String> Ids){
        List<Opportunity> lstOpp = [Select Id, name,type, O_Lock__c,O_Is_Group_Booking__c,O_Maximum_Occupancy__c,O_Minimum_Occupancy__c,O_Break_Through_No__c,O_Sales_Commission__c,O_Sales_CommissionP__c,O_Sales_Commission_Type__c,owner.Sales_Commission__c,
                                    owner.Sales_CommissionP__c,O_Total_Sales_Commission__c,O_Agent_Commission_percent__c,
                                O_Agent__c,O_Agent__r.S_Commission__c,O_Agent__r.S_Commission_Value__c,O_Agent_Commission_Type__c,O_Margin_Value_With_Commission__c,
                                    O_Map_Type__c,O_Days_to_Departure__c,O_Booking_to_Departure__c,O_Include_Flight_Margin__c,O_EU__c,O_Steps_Completed__c,O_Quote_Date__c,O_Total_Credit_Card_Charges__c,O_Bond_Type__c,O_Atol__c,O_Credit_Card_Charges_Amount__c,
                                    O_Agent_Commission_Amount__c,O_Suggested_Margin_Value__c,Costing_Type__c,O_Credit_Card_Charges__c,O_Agent_Commission__c,O_Finders_Commission__c,
                                     O_Suggested_Margin__r.M_Margin__c,O_Target_Mark_Up_Value__c ,O_No_of_Nights__c, AccountId, O_Target_Mark_Up__r.TMU_TOMS_APC__c,
                                     O_Target_Mark_Up__r.TMU_TOMS_FFP__c,O_Suggested_Margin__c, O_Target_Mark_Up__r.TMU_APC__c, O_Target_Mark_Up__r.TMU_FFP__c,
                                     O_Target_Mark_Up__r.TMU_Target_Margin__c,Amount, CloseDate, StageName, O_Update__c, O_Total_Selling_Price__c,
                                    (Select Id,GM_Name__c,GM_Occupancy_Type__c ,GM_DOB__c, GM_Client_Group__c,GM_Opportunity__c,GM_Lead_Passenger__c,GM_Contact__r.Occupancy_Type__c,GM_Contact__r.Birthdate from Group_Members__r),
                                      (Select Id,TC_Country__r.C_EU__c,TC_Country__r.Name from Travelling_Countries__r), 
                                      (Select Id, Name,CG_Total_Recommended_Selling_Price__c,CG_Selling_Price__c,CG_Recommended_Selling_Price_Rp__c,
                                       CG_Charity__c, CG_Regulatory_Charges__c, CG_FX_Transfer_Charges__c, CG_Arrival_Presents__c,CG_Opportunity__r.O_Target_Mark_Up_Value__c,
                                       CG_Total_cost_in_selling_currency__c  From Client_Groups__r order by Name), 
                                       (Select ID,SB_Own_Arrangement__c from Supplier_Booking__r), 
                                       account.name, account.A_Total_Compensation_Credit_Memo__c, account.Total_Credit_Memo__c,O_Pax__c,O_Live_Margin__c, O_Departure_Date__c,CreatedDate, O_Return_Date__c,O_Holiday_Type__c,O_Holiday_Type__r.name, O_Booking_Currency__c, 
                                    O_Total_Recommended_Selling_Price__c, O_Margin__c,O_Additional_Reps_Agents_Arrival_report__c,
                                    O_Booking_Note_Internal__c,O_Other_Invoice_Comments__c from Opportunity where Id in :Ids];
        return lstOpp;
    }
    
    
    public static List<Supplier_Booking__c> getSupplierBookings(String oppId){
        List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
        if(oppId != ''){
            lstSupplierBooking =  [select id,SB_Show_in_Itinerary__c,SB_Is_Standard__c,SB_PBR_Number__c,SB_Show_Voucher__c,SB_Arrival_Airport_l__c,SB_Departure_Airport_l__c,SB_Name_Of_Driver__c,SB_Jet_Model__c,SB_Pilot_Details__c,SB_Cost__c,SB_Not_Held__c,SB_Provider_Telephone__c,SB_Phone_No__c,SB_Length_of_Journey__c,SB_Booking_Ref__c,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Reservation_Ref__c,SB_Supplier__r.S_Emergency_Phone__c,SB_Payment_Type__c,SB_Duration__c,SB_Avrage_Margin__c,SB_Notes__c,SB_Ground_Handler__c,RecordType.Name,SB_Holiday_Suggestion__r.HS_Message__c, SB_Arrival_Terminal__c,SB_Day__c,SB_From_Time__c,SB_Carrier__c ,
                                  SB_Supplier__r.Name,SB_Occupancy__c,SB_Room_Type__c,SB_Booking_No__c,SB_Meal_Basis__c,SB_No_of_Rooms__c,
                                  SB_From_Date__c,SB_Check_In_Time__c,SB_Supplier_Name__c , SB_Own_Arrangement__c ,SB_Flight_No__c,SB_Class__c, SB_To_Date__c ,SB_Night__c, SB_Base_Currency__c,SB_From_Place__c ,SB_To_Time__c,
                                  SB_To_Place__c,SB_Type__c ,SB_Source__c ,SB_Departure_Terminal__c ,SB_Departure_Time__c,SB_Holiday_Suggestion__c,recordtypeid,SB_Opportunity__c,
                                  SB_Vehicle__c,SB_Total_Vehicle__c,SB_From_Station__c ,SB_To_Station__c ,SB_What_to_do__c,SB_Pickup_Point__c,SB_Name__c,SB_Drop_off_Point__c,SB_Option__c,SB_Client_Group__c,SB_Adjustment__c
                                  ,SB_Itinerary_Description__c,SB_Transfer_Car_Hire_Option__r.Name,SB_Transfer_Car_Hire_Option__c,SB_What_To_Do__r.Name, SB_Where_To_Go__r.Name,SB_Supplier__c, SB_Room_Details__c, SB_Order__c,
                                  SB_Invoice_Notes__c,SB_Supplier_Notes__c from Supplier_Booking__c where SB_Opportunity__c =: oppId order by SB_Order__c];
        }
        
        return lstSupplierBooking;
    }
    
    public static List<Supplier_Booking__c> getOneSupplierBookings(String SBId){
        List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
        if(SBId != ''){
            lstSupplierBooking =  [select id,SB_Show_in_Itinerary__c,SB_Is_Standard__c,SB_PBR_Number__c,SB_Show_Voucher__c,SB_Arrival_Airport_l__c,SB_Departure_Airport_l__c,SB_Name_Of_Driver__c,SB_Jet_Model__c,SB_Pilot_Details__c,SB_Cost__c,SB_Not_Held__c,SB_Provider_Telephone__c,SB_Phone_No__c,SB_Length_of_Journey__c,SB_Reservation_Ref__c,SB_Booking_Ref__c,SB_Payment_Type__c,SB_Booking_Status__c,SB_Ticket_No__c,SB_Luggage_Note__c,SB_Avrage_Margin__c,SB_Duration__c,SB_Notes__c,SB_Ground_Handler__c,RecordType.Name,SB_Holiday_Suggestion__r.HS_Message__c, SB_Arrival_Terminal__c,SB_Day__c,SB_From_Time__c,SB_Carrier__c ,
                                  SB_Supplier__r.Name,SB_Occupancy__c,SB_Room_Type__c,SB_Booking_No__c,SB_Meal_Basis__c,SB_No_of_Rooms__c,
                                  SB_From_Date__c,SB_Check_In_Time__c,SB_Supplier_Name__c , SB_Own_Arrangement__c ,SB_Flight_No__c,SB_Class__c, SB_To_Date__c ,SB_Night__c, SB_Base_Currency__c,SB_From_Place__c ,SB_To_Time__c,
                                  SB_To_Place__c,SB_Type__c ,SB_Source__c ,SB_Departure_Terminal__c ,SB_Departure_Time__c,SB_Holiday_Suggestion__c,recordtypeid,SB_Opportunity__c,
                                  SB_Vehicle__c,SB_Total_Vehicle__c,SB_From_Station__c ,SB_To_Station__c ,SB_What_to_do__c,SB_Pickup_Point__c,SB_Name__c,SB_Drop_off_Point__c,SB_Option__c,SB_Client_Group__c,SB_Adjustment__c
                                  ,SB_Itinerary_Description__c,SB_Transfer_Car_Hire_Option__r.Name,SB_Transfer_Car_Hire_Option__c,SB_What_To_Do__r.Name, SB_Where_To_Go__r.Name,SB_Supplier__c, SB_Room_Details__c, SB_Order__c
                                  from Supplier_Booking__c where Id =: SBId order by SB_Order__c];
        }
        
        return lstSupplierBooking;
    }
    
    public static List<Supplier_Booking__c> getSupplierBookingWithCost(String OppId){
        List<Supplier_Booking__c> lstSupplierBookings = new List<Supplier_Booking__c>();
        if(oppId != ''){
            lstSupplierBookings =  [select Id, Name, SB_Show_in_Itinerary__c,recordType.Name,SB_Show_Voucher__c,SB_Cost__c,SB_From_Date__c,SB_Day__c, SB_Invoice_Notes__c, SB_Supplier_Notes__c, SB_TO_Date__c,(Select ID,
                                SC_Client_Group__c,SC_Client_Group__r.Name,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.CurrencyISOCode,
                                SC_Supplier_Booking__c,SC_Supplier_Booking__r.SB_Supplier__c,SC_Supplier_Booking__r.SB_Supplier__r.Name,
                                SC_Supplier_Booking__r.recordType.DeveloperName,SC_Supplier_Booking__r.recordType.Name,SC_Occupancy_Type__c,
                                SC_Margin_Value__c,SC_Margin_Type__c, SC_Occupancy_No__c,SC_Total_Net_CostSC__c,SC_Selected__c, SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c,SC_Option__c,  
                                SC_Total_Client_Group_Cost__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c,SC_Description__c
                                from Supplier_Costs__r order by SC_Supplier_Booking__r.SB_Supplier__r.Name,SC_Option__c,createdDate) 
                                  from Supplier_Booking__c where SB_Opportunity__c =: oppId order by SB_Order__c];
        }
        return lstSupplierBookings;
    }
    
    public static List<Client_Group__c> getClientGorupWithCost(String OppId){
        List<Client_Group__c> lstClientGroup = new List<Client_Group__c>();
        if(oppId != ''){
            lstClientGroup =  [Select ID,Name,CG_Deposit_Required_I__c,CG_Deposit_Required_II__c,CG_Total_Flight_Cost__c,CG_Recommended_Selling_Price__c, CG_Arrival_Presents__c,CG_Exchange_Rate_GBP__c,CG_Deposit_Overwrite__c,CG_Opportunity__r.O_Target_Mark_Up_Value__c,CG_Charity__c,CG_FX_Transfer_Charges__c,CG_Lead_Group_Member__c,CG_Total_cost_in_selling_currency__c,CG_Opportunity__c,
                                Previous_Recommended_Selling_Price__c,CG_Recommended_Selling_Price_Rp__c, CG_Regulatory_Charges__c
                                ,CG_Total_Adult_Members__c,CG_Total_Child_Members__c,CG_Total_Group_Members__c,CG_Opportunity__r.O_Payment_Rule__r.R_Percentage__c,
                                CG_Opportunity__r.O_Payment_Rule__c,Recommended_Selling_Price__c,CG_Selling_Price__c,CG_Opportunity__r.O_Days_to_Departure__c
                                ,(Select Id, GM_Contact__r.Birthdate, GM_Occupancy_Type__c from Group_Members__r)
                                ,(Select ID,SC_Margin_Value__c,SC_Margin_Type__c,SC_Client_Group__c,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.CurrencyISOCode,SC_Supplier_Booking__c,SC_Supplier_Booking__r.SB_Supplier__c,SC_Supplier_Booking__r.SB_Supplier__r.Name,SC_Supplier_Booking__r.recordType.DeveloperName,SC_Supplier_Booking__r.recordType.Name,
                                SC_Total_Net_CostSC__c,SC_Selected__c, SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c,SC_Option__c,  SC_Total_Client_Group_Cost__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c
                                from Supplier_Costs__r where SC_Selected__c = true order by SC_Supplier_Booking__r.SB_Supplier__r.Name) from Client_Group__c where CG_Opportunity__c = :OppId order by Name];
        }
        
        return lstClientGroup;
    }
    
    public static List<Supplier__c> getSuppliers(Set<String> travellingCountries){
        if(travellingCountries.size() > 0){
            String queryString = '';
            for(String includeValue : travellingCountries)
                queryString += '\''+includeValue+'\'' + ',';
            queryString = queryString.removeEnd(',');
            return [Select Id, Name, S_Type__c,S_Where_to_go__c,S_Recommended__c,S_Widgety_Reference_ID__c from Supplier__c where S_Archive__c = False AND  (S_Operating_Countries__c includes ('+queryString+') OR S_Country__c in :travellingCountries or S_Country__c = null)  order by name ];
            // Query For Operating Countries 
            //return Database.Query('Select Id, Name, S_Type__c from Supplier__c where S_Archive__c = False AND  S_Operating_Countries__c includes ('+queryString+') order by name');
        }    
        return new List<Supplier__c>();
    }
    
    public static List<Margin__c> getMargin(List<Date> closeDate, List<Date> departureDate){
        if(closeDate.size() > 0 && departureDate.size() > 0){
            List<Margin__c> lstMR = [Select Id, M_Book_From__c,M_Book_To__c,M_Country__c,M_Margin__c,M_Travel_From__c,
                                            M_Travel_To__c from Margin__c where 
                                            (M_Book_From__c <= :closeDate[0] OR M_Book_From__c <= :closeDate[1])  And 
                                            (M_Book_To__c >= :closedate[0] OR M_Book_To__c >= :closedate[1])  And 
                                            
                                            (M_Travel_From__c <= :departureDate[0] OR M_Travel_From__c <= :departureDate[1])  And 
                                            (M_Travel_To__c >= :departureDate[0] OR M_Travel_To__c >= :departureDate[1])];
            return lstMR;
        }
        else{
            return new List<Margin__c>();
        }
    }
    
    //For Errata_Text__c
    public static Map<String,String> getErrataMsg(String OppId, List<String> lstWTG, List<String> lstWTD, List<String> lstSupp){
        Map<String,String> mapMsgs = new Map<String,String>();
        List<Opportunity> lstOpp = [Select Id, CloseDate, O_Departure_Date__c from Opportunity where Id = :oppId];
        for(Errata_Text__c ET : [Select Id,ET_Where_to_go__c,ET_Travel_To__c,ET_Travel_From__c,ET_Supplier__c,ET_Message__c, ET_Book_To__c,
                                ET_Book_From__c, ET_Activity__c from Errata_Text__c where (ET_Activity__c in :lstWTD OR ET_Supplier__c in :lstSupp OR ET_Where_to_go__c in :lstWTG)
                                And  ET_Book_From__c <= :lstOpp[0].closeDate  And ET_Book_To__c >= :lstOpp[0].closedate
                                And  ET_Travel_From__c <= :lstOpp[0].O_Departure_Date__c  And ET_Travel_To__c >= :lstOpp[0].O_Departure_Date__c
                                ]){
            if(ET.ET_Where_to_go__c != null){
                mapMsgs.put(ET.ET_Where_to_go__c,ET.ET_Message__c);
            }
            if(ET.ET_Supplier__c != null){
                mapMsgs.put(ET.ET_Supplier__c,ET.ET_Message__c);
            }
            if(ET.ET_Activity__c  != null){
                mapMsgs.put(ET.ET_Activity__c,ET.ET_Message__c);
            }
        }
        return mapMsgs;
    }
    
    
    //For Single Opportunity
    public static List<Exchange_Rate__c> getExchangeRate(String sellingCurrency, Date closeDate, String rdType){
        List<Exchange_Rate__c> lstER = [Select id, ER_Base_Currency__c, ER_Book_From__c, ER_Book_To__c, ER_Exchange_Rate__c, ER_Sales_Currency__c, 
                                        ER_Travel_From__c, ER_Travel_To__c from Exchange_Rate__c where ER_Sales_Currency__c = :sellingCurrency And 
                                        ER_Book_From__c <= :closeDate  And ER_Book_To__c >= :closedate and recordType.Name = :rdType];
        return lstER;
    }
    
    //For Multiple Opportunity
    public static List<Exchange_Rate__c> getExchangeRate(Set<String> sellingCurrency, List<Date> closeDate, List<Date> departureDate, String rdType){
        if(closeDate.size() > 0 && departureDate.size() > 0){
            List<Exchange_Rate__c> lstER = [Select id, ER_Base_Currency__c, ER_Book_From__c, ER_Book_To__c, ER_Exchange_Rate__c, ER_Sales_Currency__c, 
                                            ER_Travel_From__c, ER_Travel_To__c from Exchange_Rate__c where ER_Sales_Currency__c in :sellingCurrency And 
                                            (ER_Book_From__c <= :closeDate[0] OR ER_Book_From__c <= :closeDate[1])  And 
                                            (ER_Book_To__c >= :closedate[0] OR ER_Book_To__c >= :closedate[1])  And 
                                            
                                            (ER_Travel_From__c <= :departureDate[0] OR ER_Travel_From__c <= :departureDate[1])  And 
                                            (ER_Travel_To__c >= :departureDate[0] OR ER_Travel_To__c >= :departureDate[1]) and recordType.Name = :rdType];
            return lstER;
        }
        else{
            return new List<Exchange_Rate__c>();
        }
    }
}
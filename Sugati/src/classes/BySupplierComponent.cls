public Class BySupplierComponent{

    public PageReference refreshComponent() {
        return null;
    }

    public Opportunity opp{get; set;}
    public List<SBCostWrapper> lstSBWrapper{get; set;}
    
    String oppId = '';
    
    public BySupplierComponent(){
        oppId = ApexPages.currentPage().getParameters().get('Id');
        lstSBWrapper = new List<SBCostWrapper>();
        /*for (Supplier_Booking__c sb: [select id, SB_Opportunity__r.CurrencyISOCode,SB_Cost__c,SB_Notes__c,(Select Id, SBC_Description__c, SBC_Cost__c, SBC_Nights__c, SC_Client_Group__c, SC_Type__c,
            SC_Total_Net_Cost_PP__c, SC_Total_Client_Group_Cost__c, SC_Shared_Cost_Per_Night__c, SC_Occupancy_Type__c,
            SC_Occupancy_No__c,IsDeleted,SC_Margin__c,SC_MarkUp_Cost_for_Selling_Price__c from Split_Base_Costs__r),
            SB_Holiday_Suggestion__r.HS_Message__c, SB_Arrival_Terminal__c,SB_Day__c,SB_From_Time__c,SB_Carrier__c ,SB_Arrival_Airport__c ,SB_Total_PP_Net_Cost__c,SB_Cost_PP__c,SB_Supplier__r.Name,SB_Pax_for_Costing__c,SB_Occupancy__c,SB_Room_Type__c,SB_Meal_Basis__c,SB_No_of_Rooms__c,
            SB_From_Date__c,SB_Check_In_Time__c,SB_Supplier_Name__c , SB_Own_Arrangement__c ,SB_Flight_No__c,SB_Class__c, SB_To_Date__c ,SB_Base_Cost__c,SB_Nights__c,SB_Night__c, SB_Base_Currency__c,SB_From_Place__c ,SB_To_Time__c,
            SB_To_Place__c,SB_Departure_Airport__c,SB_Cost_Group__c ,SB_Type__c ,SB_Source__c ,SB_Departure_Terminal__c ,SB_Departure_Time__c,SB_Holiday_Suggestion__c,recordtypeid,SB_Opportunity__c,
            SB_Vehicle__c,SB_Total_Vehicle__c,SB_From_Station__c ,SB_To_Station__c ,SB_What_to_do__c,SB_Pickup_Point__c,SB_Name__c,SB_Drop_off_Point__c,SB_Option__c,SB_Client_Group__c,SB_Adjustment__c
            ,SB_Itinerary_Description__c,SB_Transfer_Car_Hire_Option__c,SB_What_To_Do__r.Name, SB_Where_To_Go__r.Name,SB_Supplier__c, SB_Room_Details__c, SB_Order__c
            from Supplier_Booking__c 
            where SB_Opportunity__c =: oppId order by SB_Supplier__r.Name]) {
            
            
        }*/
        
        
    }
    
    List<SBCostWrapper> lstSBWrapperPv;
    public List<SBCostWrapper> getSBCostWrapper(){
        lstSBWrapperPv = new List<SBCostWrapper>();
        for(Supplier_Cost_Payment__c sccv : [Select Id, SCP_Supplier__r.Name,SCP_Opportunity__r.currencyISOCode,
                                                 SCP_Exchange_Rate__c, SCP_Exchange_Rate__r.ER_Exchange_Rate__c, SCP_Is_Agent__c, SCP_Opportunity__c, 
                                                SCP_Outstanding_Amount__c, SCP_Supplier__c, SCP_Total__c, SCP_Total_Payment__c,
                                                (Select Id, SC_Description__c, SC_Cost__c, SC_Nights__c, SC_Client_Group__c, SC_Type__c,
                SC_Total_Net_Cost_PP__c, SC_Total_Client_Group_Cost__c, SC_Shared_Cost_Per_Night__c, SC_Occupancy_Type__c,
                SC_Occupancy_No__c,IsDeleted,SC_Margin__c,SC_MarkUp_Cost_for_Selling_Price__c,SC_Total_Net_CostSC__c from Supplier_Costs__r) 
                                                 from Supplier_Cost_Payment__c where SCP_Opportunity__c = :oppId
                                                 order by SCP_Supplier__r.Name]){
        
            if(sccv.Supplier_Costs__r.size() > 0){
                SBCostWrapper objSB = new SBCostWrapper();
                objSB.sccv = sccv;
                objSB.lstSupplierCost.addAll(sccv.Supplier_Costs__r);
                for(Supplier_Cost__c sbc : sccv.Supplier_Costs__r){
                    objSB.totalCost += sbc.SC_Total_Client_Group_Cost__c;        
                }
                lstSBWrapperPv.add(objSB );
            }
        }
        return lstSBWrapperPv;
    }
    public class SBCostWrapper{
        public Supplier_Cost_Payment__c sccv{get; set;}
        public List<Supplier_Cost__c > lstSupplierCost{get; set;}
        public Decimal totalCost{get; set;}
        
        public SBCostWrapper(){
            totalCost = 0;
            lstSupplierCost = new List<Supplier_Cost__c >();
        }
    }
}
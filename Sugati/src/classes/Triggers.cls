public with sharing Class Triggers{

    public Triggers(){
    
    }
    
    public static void TravellingCountryTrigger(){
        
        Site__c customSetiing = Site__c.getInstance();
        if(customSetiing.Run_Trigger__c){
            boolean isIntFlight = false;
            Set<String> countries = new Set<String>();
            Set<String> oppIds = new Set<String>();
            Set<String> usrIds = new Set<String>();
            if(!trigger.isDelete){
                for (Travelling_Country__c  tc: (List<Travelling_Country__c>)Trigger.New) {
                    countries.add(tc.TC_country__c);
                    oppIds.add(tc.TC_Opportunity__c);
                }
            
            }
            else{
                for (Travelling_Country__c  tc : (List<Travelling_Country__c>)Trigger.old) {
                    oppIds.add(tc.TC_Opportunity__c);
                }
            }
            if (Trigger.isBefore && !trigger.isDelete) {
                Map<String, String> mapParentAttachment = new Map<String, String>();
                List<Attachment> lstAtt = [Select Id, ParentId, Name from Attachment where parentid in: countries AND name LIKE '%cover%' order by createdDate];
                Set<String> setAttIds = new Set<String>();
                String imageId;
                for(Attachment att : lstAtt){
                    setAttIds.add(att.Id);
                }
                
                for(Opportunity opp : [Select Id,OwnerId from Opportunity where Id =:oppIds]){
                    usrIds.add(opp.OwnerId);
                }
                for(Images_AI__c img : [Select Id,AI_Image_ID__c,AI_Count__c from Images_AI__c where AI_User__c in :usrIds and AI_Image_ID__c in :setAttIds Order by AI_Count__c limit 1]){
                    imageId = img.AI_Image_ID__c;
                }
                //System.assert(false,usrIds +'*****'+[Select Id,AI_Image_ID__c,AI_Count__c from Images_AI__c where AI_User__c in :usrIds and AI_Image_ID__c in :setAttIds Order by AI_Count__c limit 1]);
                for (Attachment att : [Select Id, ParentId, Name from Attachment where parentid in: countries AND name LIKE '%cover%' order by createdDate limit 1]) {
                    mapParentAttachment.put(att.ParentId, att.id);
                }
                
                for (Travelling_Country__c  tc : (List<Travelling_Country__c>)Trigger.New) {
                    if(tc.TC_ImageID__c == null && Utility.changeCoverImage){
                        if(imageId == null){
                            tc.TC_ImageID__c = mapParentAttachment.get(tc.TC_country__c);
                        }
                        else{
                            tc.TC_ImageID__c = imageId;
                        }
                        tc.TC_Selected__c  = datetime.now();
                        tc.TC_Cover_Image__c = true;    
                    }
                    //else if(Utility.changeCoverImage)
                    //    tc.TC_Cover_Image__c = false;
                }
            }
            else{
                
                List<Opportunity> Opps = [select id, closeDate,O_Target_Mark_Up__r.TMU_APC__c, O_Target_Mark_Up__r.TMU_FFP__c,  
                                            O_Target_Mark_Up__r.TMU_TOMS_APC__c,O_Target_Mark_Up__r.TMU_TOMS_FFP__c,O_Target_Mark_Up__r.TMU_Target_Margin__c ,
                                            (Select Id, TC_Country__c, TC_Country__r.name from Travelling_Countries__r),  O_Departure_Date__c,O_Suggested_Margin__r.M_Margin__c,O_Return_Date__c ,O_Suggested_Margin__c from Opportunity
                                         where id in: oppIds];
                
                Map<String,List<Supplier_Booking__c>> mapOppSB = new Map<String,List<Supplier_Booking__c>>();
                for(Supplier_Booking__c sb : [Select Id, recordTypeId,recordType.Name,SB_Own_Arrangement__c,SB_Opportunity__c  from Supplier_Booking__c
                                             where SB_Opportunity__c in : oppIds order by SB_Order__c]){
                    if(!mapOppSB.containsKey(sb.SB_Opportunity__c)){
                        mapOppSB.put(sb.SB_Opportunity__c, new List<Supplier_Booking__c>());    
                    }
                    mapOppSB.get(sb.SB_Opportunity__c).add(sb);
                }
                
                Map<Decimal , Target_Mark_Up__c > mapTargetMarkUP = new Map<Decimal , Target_Mark_Up__c>();
                for(Target_Mark_Up__c tmnu  : [Select Id, TMU_APC__c, TMU_FFP__c, TMU_TOMS_APC__c, TMU_TOMS_FFP__c, TMU_Target_Margin__c from 
                        Target_Mark_Up__c ]){
                    mapTargetMarkUP.put(tmnu.TMU_Target_Margin__c,tmnu);
                }
                isIntFlight= false;
                Map<String,String> mapRecordtype = new Map<String,String>();
                String objectName = Utility.getNameSpacePrefix()+'Supplier_Booking__c';
                for (Recordtype rt: [select id,name,sobjecttype  from recordtype where sobjecttype = :objectName order by name]) {
                    mapRecordtype.put(rt.id,rt.name);
                }
                Margin__c heighestMargin = new Margin__c();
                List<Opportunity> lstOpp = new List<Opportunity>();
                     for (Opportunity opp: Opps ) {
                         if(mapOppSB.containsKey(opp.Id)){
                             for(Supplier_Booking__c sb : mapOppSB.get(opp.Id)){
                                 if(sb.recordType.Name == 'Int Flight'){
                                    isIntFlight = true;
                                }
                             }
                         }
                         
                         List<String> travellingC = new List<String>();
                         for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                             travellingC.add(tc.TC_Country__c);
                         }
                         if(trigger.isDelete){
                            if (opp.O_Suggested_Margin__c != null) {
                                opp.O_Suggested_Margin__c = null;
                            }
                         }
                        Decimal oppMargin = opp.O_Suggested_Margin__r.M_Margin__c; 
                        for (Margin__c m : [select id,M_Book_From__c,M_Book_To__c ,M_Travel_From__c,M_Travel_To__c,M_Margin__c, M_Country__r.C_EU__c   from Margin__c 
                            where M_Country__c in : travellingC order by M_Margin__c asc]) {
                            ///System.assert(false, opp.closeDate + '***' + m.M_Book_From__c + '***' +m.M_Travel_From__c);
                                if (opp.closeDate >= m.M_Book_From__c &&
                                opp.closeDate <= m.M_Book_To__c && 
                                opp.O_Departure_Date__c >= m.M_Travel_From__c &&
                                opp.O_Return_Date__c <= m.M_Travel_To__c ){
                                
                                if(opp.O_Suggested_Margin__c == null || oppMargin  <= m.M_Margin__c){
                                    opp.O_Suggested_Margin__c = m.id;
                                    oppMargin = m.M_Margin__c;
                                    if(mapTargetMarkUP.containsKey(m.M_Margin__c)){
                                        opp.O_Target_Mark_Up__c = mapTargetMarkUP.get(m.M_Margin__c).Id;
                                        List<Margin__c> mg = [Select Id, M_Margin__c, M_Country__r.C_EU__c from Margin__c  where Id  = :Opp.O_Suggested_Margin__c];
                                        if(mg.size() != 0){
                                            if(mg[0].M_Country__r.C_EU__c){
                                                if(isIntFlight){
                                                    opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(m.M_Margin__c).TMU_TOMS_APC__c; 
                                                }
                                                else{
                                                    opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(m.M_Margin__c).TMU_TOMS_FFP__c; 
                                                }
                                            }
                                            else{
                                                if(isIntFlight){
                                                    opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(m.M_Margin__c).TMU_APC__c; 
                                                }
                                                else{
                                                    opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(m.M_Margin__c).TMU_FFP__c; 
                                                }   
                                            }
                                        }
                                        
                                    }
                                    if(m.M_Country__r.C_EU__c){
                                        opp.O_EU__c = true;
                                    }
                                    else{
                                        opp.O_EU__c = false;
                                    }
                                }
                            }
                        }
                       
                        
                                   
                    //## add country in O_Country__c of Opp
                    String  country= '';
                    opp.O_Country__c = '';
                    for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                        country += tc.TC_Country__r.name+', ';
                    }
                    country = country.removeEnd(', ');
                    opp.O_Country__c = country;
                    lstOpp.add(opp);
                }
                update lstOpp;
            }    
        }
    }
    
    //******** Supplier_Cost__cTrigger *******//
    public static void SupplierCostTrigger(){
        Site__c customSetiing = Site__c.getInstance();
        if(customSetiing.Run_Trigger__c){
            if(trigger.isBefore){
                if(!trigger.isDelete){
                    List<String> lstSupplierBooking = new List<String>();
                    List<String> lstOpp = new List<string>();
                    Map<String,Supplier_Booking__c> mapSBOpportunity  = new Map<String, Supplier_Booking__c>();
                    Map<String, Map<String,Exchange_Rate__c>> exchangeRateByCurrency = new Map<String, Map<String,Exchange_Rate__c>>();
                    Map<String, Margin__c> defualtMargin = new Map<String, Margin__c>();
                    Set<Date> setOfDepartureDates = new Set<Date>();
                    Set<Date> setOfCloseDates = new Set<Date>();
                    Set<String> setOfSellingCurency = new Set<String>();
                    Map<String,Supplier_Booking__c> MapRecordTypes = new Map<String,Supplier_Booking__c>();
                
                    //Load all supplier booking ids 
                    for(Supplier_Cost__c sbc : (List<Supplier_Cost__c>)trigger.new){
                        lstSupplierBooking.add(sbc.SC_Supplier_Booking__c);        
                    }
                    //Load Supplier booking records
                    for(Supplier_Booking__c sb : [Select Id, SB_Opportunity__c,RecordType.Name,SB_Opportunity__r.O_Include_Flight_Margin__c from Supplier_Booking__c where Id in :lstSupplierBooking]){
                        lstOpp.add(sb.SB_Opportunity__c);
                        mapSBOpportunity.put(sb.Id,sb);
                        MapRecordTypes.put(sb.Id,sb);
                    }
                    //Load Opportunities
                    List<Opportunity> lstOpportunities = [Select id,(Select Id, Name, TC_Country__c, TC_Country__r.Name from Travelling_Countries__r),
                                            CloseDate,CurrencyISOCode,CreatedDate,O_Departure_Date__c from Opportunity where Id in :lstOpp];
                    //Put data in all sets
                    for(Opportunity opp : lstOpportunities){
                        setOfDepartureDates.add(opp.O_Departure_Date__c);
                        setOfCloseDates.add(opp.CloseDate);
                        setOfSellingCurency.add(opp.CurrencyISOCode);
                    }
                    //Get minimum and maximum close and departure date.
                    List<Date> lstMinMaxDPDate = Utility.FindMinMaxDate(setOfDepartureDates);
                    List<Date> lstMinMaxCloseDate = Utility.FindMinMaxDate(setOfCloseDates);
                    //Get exchange and margin                        
                    List<Exchange_Rate__c> fullExchangeRate = SOQLServices.getExchangeRate(setOfSellingCurency,lstMinMaxCloseDate,lstMinMaxDPDate,'Sell');
                    List<Margin__c> fullMargin = SOQLServices.getMargin(lstMinMaxCloseDate,lstMinMaxDPDate);
                    
                    
                    //Calculate exchange rate and margin for supplier cost.
                    for(Opportunity opp : lstOpportunities){
                        Map<String,Exchange_Rate__c> childExr = new Map<String,Exchange_Rate__c>();
                        Set<String> travellingCountryIds = new Set<String>();
                        Margin__c mmg = new Margin__c();
                        
                        for(Exchange_Rate__c er : fullExchangeRate){
                            if((er.ER_Sales_Currency__c == opp.CurrencyISOCode) 
                              && opp.closeDate >= er.ER_Book_From__c && opp.closeDate <= er.ER_Book_To__c && opp.O_Departure_Date__c >= er.ER_Travel_From__c &&
                              opp.O_Departure_Date__c <= er.ER_Travel_To__c){
                                  childExr.put(er.ER_Base_Currency__c,er);    
                            }
                        }
                        for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                            travellingCountryIds.add(tc.TC_Country__c);
                        }
                        exchangeRateByCurrency.put(opp.Id, childExr);
                        
                        Decimal  highestMargin = 0;
                       
                        for(Margin__c mg : fullMargin ){
                            if(opp.closeDate >= mg.M_Book_From__c && opp.closeDate <= mg.M_Book_To__c && 
                                opp.O_Departure_Date__c >= mg.M_Travel_From__c &&  opp.O_Departure_Date__c <= mg.M_Travel_To__c
                                && travellingCountryIds.contains(mg.M_Country__c)){
                                
                                if(highestMargin <= mg.M_Margin__c){
                                    highestMargin = mg.M_Margin__c;
                                    mmg = mg;
                                }
                            }   
                            
                        }
                         
                        if(mmg.Id != null)
                            defualtMargin.put(opp.Id,mmg);
                        }
                        
                        for(Supplier_Cost__c sbc : (List<Supplier_Cost__c>)trigger.new){
                            if(MapRecordTypes.containsKey(sbc.SC_Supplier_Booking__c)){
                                String rt = MapRecordTypes.get(sbc.SC_Supplier_Booking__c).recordType.Name;
                                if(rt == 'Int Flight' || rt == 'Dom Flights' || rt == 'Light Aircraft' || rt == 'Private Jet' || rt == 'Sea Plane'){
                                    sbc.SC_Is_Flight_Cost__c = true;
                                }
                            }
                            if(exchangeRateByCurrency.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).size() != 0 && sbc.currencyISOCode != null && exchangeRateByCurrency.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).containsKey(sbc.currencyISOCode)) {
                                sbc.SC_Exchange_Rate_Lookup__c = exchangeRateByCurrency.get(mapSBOpportunity.get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).get(sbc.currencyISOCode).Id;
                            }
                            else{
                                try{
                                    sbc.addError('Exchange rate is not updated for this supplier cost for '+sbc.currencyISOCode+' currency');
                                }
                                catch(Exception e){
                                    throw(e);
                                }
                            }
                            if(defualtMargin.containsKey(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c)){
                                sbc.SC_Margin_Lookup__c = defualtMargin.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).id;
                                Supplier_Booking__c suppBooking = mapSBOpportunity.get(sbc.SC_Supplier_Booking__c);
                                if((suppBooking.recordType.Name == 'Int Flight' || suppBooking.recordType.Name == 'Light Aircraft' || suppBooking.recordType.Name == 'Dom Flights' || suppBooking.recordType.Name == 'Private Jet' || suppBooking.recordType.Name == 'Sea Plane') && !(suppBooking.SB_Opportunity__r.O_Include_Flight_Margin__c)){
                                    sbc.SC_Margin__c = 0;    
                                    sbc.SC_Margin_Value__c = 0;    
                                }
                                else if(sbc.SC_Margin__c == null){
                                    sbc.SC_Margin__c  = defualtMargin.get(suppBooking.SB_Opportunity__c).M_Margin__c;  
                                }
                            }
                            else if(sbc.SC_Margin__c == null){
                                try{
                                    sbc.addError('Margin records is not updated for this supplier cost for '+sbc.currencyISOCode+' currency');
                                }
                                catch(Exception e){
                                    throw(e);
                                }
                            }
                            
                            if(sbc.SC_Exchange_Rate_Lookup__c != null && exchangeRateByCurrency.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).size() != 0){
                                try{
                                    
                                    if(mapSBOpportunity .containsKey(sbc.SC_Supplier_Booking__c) && exchangeRateByCurrency.containsKey(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c) && exchangeRateByCurrency.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).get(sbc.currencyISOCode).ER_Exchange_Rate__c != null){    
                                        sbc.SC_Total_Net_CostSC__c = (sbc.SC_Total_Client_Group_Cost__c/exchangeRateByCurrency.get(mapSBOpportunity .get(sbc.SC_Supplier_Booking__c).SB_Opportunity__c).get(sbc.currencyISOCode).ER_Exchange_Rate__c).setScale(2,RoundingMode.HALF_UP);
                                        if(sbc.SC_Margin_Value__c == null || sbc.SC_Margin_Type__c == 'Percentage'){
                                            sbc.SC_MarkUp_Cost_for_Selling_Price__c  = sbc.SC_Total_Net_CostSC__c*(1+(sbc.SC_Margin__c/100));
                                        }
                                        else if(sbc.SC_Margin_Type__c == 'Value'){
                                            sbc.SC_MarkUp_Cost_for_Selling_Price__c  = sbc.SC_Total_Net_CostSC__c+sbc.SC_Margin_Value__c;
                                        }
                                        if(sbc.SC_Margin_Type__c == 'Percentage'){
                                            sbc.SC_Margin_Value__c = null;
                                        }
                                        
                                    }
                                    else{
                                        sbc.addError('Exchange rate is not updated for this supplier cost for '+sbc.currencyISOCode+' currency');
                                    }
                                }
                                Catch(Exception e){
                                    throw(e);
                                }
                                
                            }
                            else{
                                try{
                                    sbc.addError('Exchange rate is not updated for this supplier cost for '+sbc.currencyISOCode+' currency');
                                }
                                catch(Exception e){
                                    throw(e);
                                }
                            }
                        }
                    }
                    else{ //Trigger.Delete section
                        List<String> lstSCCV = new List<String>();
                        for(Supplier_Cost__c sbc : (List<Supplier_Cost__c>)trigger.old){
                            lstSCCV.add(sbc.SC_Supplier_Cost_Payment__c);
                        }
                        
                        for(Supplier_Cost_Payment__c SCCV : [Select ID, SCP_Outstanding_Amount__c, SCP_Total_Payment__c from Supplier_Cost_Payment__c where Id in :lstSCCV]){
                            for(Supplier_Cost__c sbc : (List<Supplier_Cost__c>)trigger.old){
                                if(SCCV.Id == sbc.SC_Supplier_Cost_Payment__c && SCCV.SCP_Total_Payment__c  > 0){
                                    sbc.addError('Error - Payment has been already process for this cost.');
                                }
                            }
                        }
                    }
                }
                Triggers.SupplierCostAndPayment();
            }
        }
        
        
        //**** Supplier Cost & Payment by supplier cost*****//
        public static void SupplierCostAndPayment(){
            Map<Id,List<Supplier_Cost__c>> mapSupplierBookingsCosts = new Map<Id,List<Supplier_Cost__c>>();
            if(trigger.isBefore){
                if(trigger.isInsert || trigger.isUpdate){
                    for(Supplier_Cost__c cost : (List<Supplier_Cost__c>)trigger.new){
                        if(cost.SC_Selected__c){
                            if(!mapSupplierBookingsCosts.containsKey(cost.SC_Supplier_Booking__c)){
                                mapSupplierBookingsCosts.put(cost.SC_Supplier_Booking__c, new List<Supplier_Cost__c>());
                            }
                            mapSupplierBookingsCosts.get(cost.SC_Supplier_Booking__c).add(cost);
                        }
                    }
                    
                    
                    Map<Id,Supplier_Booking__c> mapSupplierBookings = new Map<Id,Supplier_Booking__c>([select id,SB_Opportunity__c,SB_Ground_Handler__c,recordType.Name,SB_Supplier__c from Supplier_Booking__c
                    where id in: mapSupplierBookingsCosts.keyset() ]);
                    
                       
                    if (mapSupplierBookings .size() > 0) {
                        
                        Set<String> suppliers = new Set<String>();
                        Set<String> opportunities = new Set<String>();
                        Map<String,Supplier_Cost_Payment__c> mapSupplierCostCurrencyValue = new Map<String, Supplier_Cost_Payment__c>();
                        Map<String,List<Supplier_Cost__c>> mapSupplierCurrencyCost = new Map<String,List<Supplier_Cost__c>>();
                        Map<String,Supplier_Cost_Payment__c> mapSupplierCurrency = new Map<String,Supplier_Cost_Payment__c>();
                        Map<Supplier_Cost_Payment__c,List<Supplier_Cost__c>> mapSupplierCurrencyValuesUpsert = new Map<Supplier_Cost_Payment__c,List<Supplier_Cost__c>>();
                        integer countofSupplierCurrnecy = 0;
                        
                        for (Supplier_Booking__c sb: mapSupplierBookings.values() ) {
                            opportunities.add(sb.SB_Opportunity__c);
                        }
                        
                        for(Supplier_Cost_Payment__c SCCV: [Select Id, CurrencyIsoCode, SCP_Opportunity__c, 
                            SCP_Total__c, SCP_Supplier__c from Supplier_Cost_Payment__c 
                            where SCP_Opportunity__c in: opportunities and SCP_Is_Agent__c = false]){
                            mapSupplierCostCurrencyValue.put(SCCV.SCP_Opportunity__c+''+SCCV.SCP_Supplier__c+''+SCCV.CurrencyIsoCode, SCCV);
                        }
                        
                        
                        for (Supplier_Booking__c sb: mapSupplierBookings.values()) {
                            String supplierId;
                            if(sb.SB_Ground_Handler__c != null && (sb.recordType.Name == 'Accommodation' || sb.recordType.Name == 'Transfer')){
                                suppliers.add(sb.SB_Ground_Handler__c);
                                supplierId = sb.SB_Ground_Handler__c;
                            }
                            else{
                                suppliers.add(sb.SB_Supplier__c );
                                supplierId = sb.SB_Supplier__c;
                            }
                            
                            for ( Supplier_Cost__c  cost : mapSupplierBookingsCosts.get(sb.id)) {
                                if (cost.CurrencyISOCode != null && supplierId != null && cost.SC_Total_Client_Group_Cost__c != null && cost.SC_Selected__c) {
                                    string key = sb.SB_opportunity__c +''+ supplierId+''+cost.CurrencyISOCode;
                                    if(mapSupplierCostCurrencyValue.containsKey(key)){
                                        Supplier_Cost_Payment__c SCCV = mapSupplierCostCurrencyValue.get(key);
                                        SCCV.SCP_Exchange_Rate__c = cost.SC_Exchange_Rate_Lookup__c;
                                        Decimal odlValue = 0;
                                        if(trigger.oldMap != null && trigger.oldMap.containsKey(cost.Id)){
                                            odlValue = ((Supplier_Cost__c)trigger.oldMap.get(cost.Id)).SC_Total_Client_Group_Cost__c;
                                        }
                                        SCCV.SCP_Total__c = (SCCV.SCP_Total__c+cost.SC_Total_Client_Group_Cost__c)-odlValue;
                                        if(!mapSupplierCurrency.containsKey(key)){
                                            mapSupplierCurrency.put(key,sccv);
                                            mapSupplierCurrencyCost.put(key,new List<Supplier_Cost__c>());
                                        }
                                        mapSupplierCurrencyCost.get(key).add(cost);
                                        
                                            
                                    }
                                    else{
                                        
                                        Supplier_Cost_Payment__c SCCV = new Supplier_Cost_Payment__c(
                                        SCP_Opportunity__c = sb.SB_opportunity__c ,
                                        SCP_Exchange_Rate__c = cost.SC_Exchange_Rate_Lookup__c,
                                        CurrencyIsoCode=cost.CurrencyISOCode, 
                                        SCP_Supplier__c=supplierId,SCP_Total__c=cost.SC_Total_Client_Group_Cost__c);
                                        
                                        
                                        if(!mapSupplierCurrency.containsKey(key)){
                                            countofSupplierCurrnecy ++;
                                            mapSupplierCurrency.put(key,sccv);
                                            mapSupplierCurrencyCost.put(key,new List<Supplier_Cost__c>());
                                        }
                                        mapSupplierCurrencyCost.get(key).add(cost);
                                        mapSupplierCostCurrencyValue.put(key,SCCV);
                                    }    
                                }
                            }
                            
                        }
                        
                        if (mapSupplierCurrency.size() > 0) {
                           upsert mapSupplierCurrency.values();
                           
                           for ( String count : mapSupplierCurrencyCost.keyset() ) {
                               for ( Supplier_Cost__c sbb : mapSupplierCurrencyCost.get(count)) {
                                   sbb.SC_Supplier_Cost_Payment__c = mapSupplierCurrency.get(count).id;
                               }
                           }
                        }
                        
                    }
                }
                else{ //#### Delete Case ##########//
                    for(Supplier_Cost__c cost : (List<Supplier_Cost__c>)trigger.old){
                        if(cost.SC_Selected__c){
                            if(!mapSupplierBookingsCosts.containsKey(cost.SC_Supplier_Booking__c)){
                                mapSupplierBookingsCosts.put(cost.SC_Supplier_Booking__c, new List<Supplier_Cost__c>());
                            }
                            mapSupplierBookingsCosts.get(cost.SC_Supplier_Booking__c).add(cost);
                        }                       
                    }
                    Map<Id,Supplier_Booking__c> mapSupplierBookings = new Map<Id,Supplier_Booking__c>([select id,SB_Opportunity__c,SB_Ground_Handler__c,recordType.Name,SB_Supplier__c from Supplier_Booking__c
                    where id in: mapSupplierBookingsCosts.keyset() ]);
                    
                    
                    
                    if (mapSupplierBookings .size() > 0) {
                        
                        Set<String> suppliers = new Set<String>();
                        Set<String> opportunities = new Set<String>();
                        for (  Supplier_Booking__c sb: mapSupplierBookings.values() ) {
                            opportunities.add(sb.SB_Opportunity__c);
                        }
                        
                        Map<String,Supplier_Cost_Payment__c> mapSupplierCostCurrencyValue = new Map<String, Supplier_Cost_Payment__c>();
                        
                        for(Supplier_Cost_Payment__c SCCV: [Select Id, CurrencyIsoCode, SCP_Opportunity__c, 
                            SCP_Total__c, SCP_Supplier__c from Supplier_Cost_Payment__c 
                            where SCP_Opportunity__c in: opportunities and SCP_Is_Agent__c = false]){
                            
                            mapSupplierCostCurrencyValue.put(SCCV.SCP_Opportunity__c+''+SCCV.SCP_Supplier__c+''+SCCV.CurrencyIsoCode, SCCV);
                        }
                        
                        
                        
                        Map<String,List<Supplier_Cost__c>> mapSupplierCurrencyCost = new Map<String,List<Supplier_Cost__c>>();
                        Map<String,Supplier_Cost_Payment__c> mapSupplierCurrency = new Map<String,Supplier_Cost_Payment__c>();
                        
                        
                        Map<Supplier_Cost_Payment__c,List<Supplier_Cost__c>> mapSupplierCurrencyValuesUpsert = new Map<Supplier_Cost_Payment__c,List<Supplier_Cost__c>>();
                        
                        integer countofSupplierCurrnecy = 0;
                        for (  Supplier_Booking__c sb: mapSupplierBookings.values() ) {
                            String supplierId;
                            if(sb.SB_Ground_Handler__c != null && (sb.recordType.Name == 'Accommodation' || sb.recordType.Name == 'Transfer')){
                                suppliers.add(sb.SB_Ground_Handler__c);
                                supplierId = sb.SB_Ground_Handler__c;
                            }
                            else{
                                suppliers.add(sb.SB_Supplier__c );
                                supplierId = sb.SB_Supplier__c;
                            }
                            for ( Supplier_Cost__c  cost : mapSupplierBookingsCosts.get(sb.id)) {
                                
                                if (cost.CurrencyISOCode != null && supplierId  != null) {
                                    string key = sb.SB_opportunity__c +''+ supplierId +''+cost.CurrencyISOCode;
                                    if(mapSupplierCostCurrencyValue.containsKey(key)){
                                        Supplier_Cost_Payment__c SCCV = mapSupplierCostCurrencyValue.get(key);
                                        Decimal odlValue = 0;
                                        if(trigger.oldMap != null && trigger.oldMap.containsKey(cost.Id)){
                                            odlValue = ((Supplier_Cost__c)trigger.oldMap.get(cost.Id)).SC_Total_Client_Group_Cost__c;
                                        }
                                        SCCV.SCP_Total__c = (SCCV.SCP_Total__c-odlValue);
                                        if(!mapSupplierCurrency.containsKey(key)){
                                            mapSupplierCurrency.put(key,sccv);
                                            mapSupplierCurrencyCost.put(key,new List<Supplier_Cost__c>());
                                        }
                                        mapSupplierCurrencyCost.get(key).add(cost);
                                        
                                            
                                    } 
                                }
                            }
                        }
                        if (mapSupplierCurrency.size() > 0) {
                           upsert mapSupplierCurrency.values();
                        } 
                    }
                      
                }
            }
            else if(trigger.isAfter){
                List<String> supplierBookingId  = new List<String>();
                List<String> OppIds = new List<String>();
                Map<Id,Supplier_Cost__c> updatedCost = new Map<Id,Supplier_Cost__c>();
                Map<String,String> mapUpdatedSCCV = new Map<String,String>();
                Map<String,List<Supplier_Cost__c>> lstSplitBaseCost = new Map<String,List<Supplier_Cost__c>>();
                List<Supplier_Cost_Payment__c> UpdatedSCCV = new List<Supplier_Cost_Payment__c>();
                if(trigger.isUpdate){
                    for(Supplier_Cost__c cost : (List<Supplier_Cost__c>)trigger.new){
                        supplierBookingId.add(cost.SC_Supplier_Booking__c);    
                        updatedCost.put(cost.Id, cost);
                    }
                    for(Supplier_Booking__c  sb :[select id,SB_Opportunity__c,SB_Supplier__c from Supplier_Booking__c where id in: supplierBookingId]){
                        oppIds.add(sb.SB_Opportunity__c);
                    }    
                    
                    for(Supplier_Cost__c cost : [Select Id,SC_Selected__c,SC_Total_Client_Group_Cost__c,SC_Supplier_Cost_Payment__c, SC_Supplier_Booking__c,SC_Exchange_Rate_Lookup__c, CurrencyISOCode from Supplier_Cost__c 
                                                    where SC_Supplier_Booking__r.SB_Opportunity__c in  :oppIds]){
                        if(!lstSplitBaseCost.containsKey(cost.SC_Supplier_Cost_Payment__c)){
                            lstSplitBaseCost.put(cost.SC_Supplier_Cost_Payment__c, new List<Supplier_Cost__c >());
                        }
                        lstSplitBaseCost.get(cost.SC_Supplier_Cost_Payment__c).add(cost);
                    }
                }
                else if(trigger.isDelete){
                    for(Supplier_Cost__c cost : (List<Supplier_Cost__c>)trigger.old){
                        supplierBookingId.add(cost.SC_Supplier_Booking__c);        
                    }
                    List<Supplier_Cost_Payment__c> lstSCCV = new List<Supplier_Cost_Payment__c>();
                    for(Supplier_Cost_Payment__c sccv : [Select Id, (Select Id from Supplier_Payments__r), (Select Id from Supplier_Costs__r) from Supplier_Cost_Payment__c where SCP_Opportunity__c in : OppIds]){
                        if(sccv.Supplier_Payments__r.size() == 0 && sccv.Supplier_Costs__r.size() == 0){
                            lstSCCV.add(sccv);
                        }
                    }
                    Delete lstSCCV;
                }
                
                for(Supplier_Cost_Payment__c sccv : [Select Id, CurrencyIsoCode, SCP_Opportunity__c, 
                            SCP_Total__c, SCP_Supplier__c from Supplier_Cost_Payment__c 
                            where Id in :lstSplitBaseCost.KeySet() and SCP_Is_Agent__c = false]){
                    sccv.SCP_Total__c = 0;
                    for(Supplier_Cost__c cost : lstSplitBaseCost.get(sccv.Id)){
                        if(cost.SC_Selected__c){
                            sccv.SCP_Total__c += cost.SC_Total_Client_Group_Cost__c;
                        }
                    }
                    UpdatedSCCV.add(sccv);            
                }
                update UpdatedSCCV;
                for(Supplier_Booking__c sb : [Select Id, SB_Opportunity__c from Supplier_Booking__c where Id in :supplierBookingId]){
                    OppIds.add(sb.SB_Opportunity__c);
                }
                List<Supplier_Cost_Payment__c> lstSCCV = new List<Supplier_Cost_Payment__c>();
                List<Supplier_Cost_Payment__c> lstSCCVUP = new List<Supplier_Cost_Payment__c>();
                for(Supplier_Cost_Payment__c sccv : [Select Id, (Select Id from Supplier_Payments__r), (Select Id from Supplier_Costs__r) from Supplier_Cost_Payment__c where SCP_Opportunity__c in : OppIds]){
                    if(sccv.Supplier_Payments__r.size() == 0 && sccv.Supplier_Costs__r.size() == 0){
                        lstSCCV.add(sccv);
                    }
                }
                Delete lstSCCV;
                Delete [Select Id from Supplier_Cost_Payment__c where SCP_Opportunity__c = null];
            }
        }  
        
        //**** Client Group Count and Group Members*****//
        public static void GroupMembersTrigger(){
            Site__c customSetiing = Site__c.getInstance();
            if(customSetiing.Run_Trigger__c){
                Set<String> setOfOppIds = new Set<String>();
                if(!trigger.isDelete){
                    for(Group_Member__c gm : (List<Group_Member__c>)trigger.new){
                        if(gm.GM_Client_Group__c != null){
                            setOfOppIds.add(gm.GM_Opportunity__c);
                        }
                    }
                }
                else{
                    for(Group_Member__c gm : (List<Group_Member__c>)trigger.old){
                        if(gm.GM_Client_Group__c != null){
                            setOfOppIds.add(gm.GM_Opportunity__c);
                        }
                    }
                }
                
                List<Client_Group__c>  lstClientGroup = [Select Id, (Select Id, GM_Contact__r.Birthdate,GM_Contact__r.Occupancy_Type__c from Group_Members__r) from Client_Group__c 
                                                        where CG_Opportunity__c in :setOfOppIds];
                List<Client_Group__c> lstCGs = new List<Client_Group__c>();
                for(Client_Group__c cg : lstClientGroup){
                    Integer totalGMs = 0;
                    Integer countOfAdult = 0;
                    Integer countOfChildMermbers = 0;
                    Integer countOfInfatMermbers = 0;
                    for(Group_Member__c cgm : cg.Group_Members__r){
                        totalGMs++;
                        
                        if(cgm.GM_Contact__r.Birthdate != null){
                            Decimal age = Math.floor((cgm.GM_Contact__r.Birthdate).daysBetween(Date.today())/365.2425);
                            if(age < 2){
                                countOfInfatMermbers++;
                            }
                            else if(age > 2 && age <12)
                                countOfChildMermbers++;
                            else if(cgm.GM_Contact__r.Occupancy_Type__c != 'Child' && cgm.GM_Contact__r.Occupancy_Type__c != 'Infant'){
                                countOfAdult++;
                            }
                        } 
                        else if(cgm.GM_Contact__r.Occupancy_Type__c == 'Child'){
                            countOfChildMermbers++;
                        }
                        else if(cgm.GM_Contact__r.Occupancy_Type__c == 'Infant'){
                            countOfInfatMermbers++;
                        }
                        else{
                            countOfAdult++;        
                        }   
                    }
                    cg.CG_Total_Adult_Members__c = countOfAdult;
                    cg.CG_Total_Child_Members__c = countOfChildMermbers;
                    cg.CG_Total_Infant_Members__c = countOfInfatMermbers;
                    cg.CG_Total_Group_Members__c = totalGMs;
                    lstCGs.add(cg);
                }
                update lstCGs;
            }
        }    
        
        
        //Calculate Deposit Required
        public static List<Map<String,Decimal>> getDepositRequiredCG(Set<String> OppIds){
            List<Map<String,Decimal>> lstOfMaps = new List<Map<String,Decimal>>();
            Map<String,Decimal> Depositmap = new Map<String,Decimal>();
            Map<String,Decimal> DepositmapII = new Map<String,Decimal>();
            Decimal Deposit = 0.0;
            Map<String,List<Supplier_Booking__c>> mapSupplierBookings = new Map<String,List<Supplier_Booking__c>>();
            List<Rule__c> lstRules = [Select Id,R_Percentage__c,R_Days_to_Departure_From__c,R_Days_to_Departure_To__c
                                      from Rule__c where recordType.DeveloperName = 'Client_Payment' and Is_Active__c = true];
            for(Supplier_Booking__c sb : [Select Id,SB_Opportunity__r.O_Suggested_Margin__r.M_Margin__c,(Select ID,SC_Supplier_Booking__r.SB_Opportunity__r.O_Days_to_Departure__c,SC_Client_Group__c,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.CurrencyISOCode,SC_Supplier_Booking__c,SC_Supplier_Booking__r.SB_Supplier__c,SC_Supplier_Booking__r.SB_Supplier__r.Name,SC_Supplier_Booking__r.recordType.DeveloperName,SC_Supplier_Booking__r.recordType.Name,
                                    SC_Total_Net_CostSC__c,SC_Selected__c, SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c,SC_Option__c,  SC_Total_Client_Group_Cost__c, SC_Margin__c, SC_MarkUp_Cost_for_Selling_Price__c
                                    from Supplier_Costs__r where SC_Selected__c = true order by SC_Supplier_Booking__r.SB_Supplier__r.Name) from Supplier_Booking__c where SB_Opportunity__c in :OppIds]){
                if(!mapSupplierBookings.containsKey(sb.SB_Opportunity__c)){
                    mapSupplierBookings.put(sb.SB_Opportunity__c, new List<Supplier_Booking__c>());
                }
                mapSupplierBookings.get(sb.SB_Opportunity__c).add(sb);
            }
            for(String Oppid : mapSupplierBookings.Keyset()){
                Deposit = 0.0;
                Map<String,Set<String>> supplierBookingCountByCG = new Map<String,Set<String>>();
                for(Supplier_Booking__c Sb : mapSupplierBookings.get(Oppid)){
                    for(Supplier_Cost__c sc : sb.Supplier_Costs__r){
                        /*if(sc.SC_Supplier_Booking__r.recordType.Name == 'Int Flight' || sc.SC_Supplier_Booking__r.recordType.Name == 'Light Aircraft' || sc.SC_Supplier_Booking__r.recordType.Name == 'Dom Flights' || sc.SC_Supplier_Booking__r.recordType.Name == 'Private Jet' || sc.SC_Supplier_Booking__r.recordType.Name == 'Sea Plane'){
                            if(sc.SC_Total_Net_CostSC__c!= null){
                                if(!supplierBookingCountByCG.containsKey(sc.SC_Client_Group__c)){
                                    supplierBookingCountByCG.put(sc.SC_Client_Group__c,new Set<String>());
                                }
                                supplierBookingCountByCG.get(sc.SC_Client_Group__c).add(sc.SC_Supplier_Booking__c);
                                
                                if(!Depositmap.containsKey(sc.SC_Client_Group__c)){
                                    Depositmap.put(sc.SC_Client_Group__c,0);
                                }
                                if(!DepositmapII.containsKey(sc.SC_Client_Group__c)){
                                    DepositmapII.put(sc.SC_Client_Group__c,0);
                                }
                                Decimal oAmount = Depositmap.get(sc.SC_Client_Group__c);
                                Decimal oAmountII = DepositmapII.get(sc.SC_Client_Group__c);
                                Depositmap.put(sc.SC_Client_Group__c,sc.SC_MarkUp_Cost_for_Selling_Price__c+oAmount);
                                DepositmapII.put(sc.SC_Client_Group__c,sc.SC_MarkUp_Cost_for_Selling_Price__c+oAmountII);
                            }
                        }
                        else{*/
                            if(sc.SC_MarkUp_Cost_for_Selling_Price__c != null){
                                if(sc.SC_Total_Net_CostSC__c != null && sb.SB_Opportunity__c != null){
                                    if(!Depositmap.containsKey(sc.SC_Client_Group__c)){
                                        Depositmap.put(sc.SC_Client_Group__c,0);
                                    }
                                    if(!DepositmapII.containsKey(sc.SC_Client_Group__c)){
                                        DepositmapII.put(sc.SC_Client_Group__c,0);
                                    }
                                    Decimal oAmount = Depositmap.get(sc.SC_Client_Group__c);
                                    Decimal oAmountII = DepositmapII.get(sc.SC_Client_Group__c);
                                    Decimal depositPI  = 1;
                                    Decimal depositPII  = 1;
                                    for(Rule__c rule : lstRules){
                                        if(rule.R_Days_to_Departure_From__c <= sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Days_to_Departure__c 
                                                    && rule.R_Days_to_Departure_To__c > sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Days_to_Departure__c){
                                            depositPI  = rule.R_Percentage__c/100;
                                        }
                                        if(rule.R_Days_to_Departure_From__c <= sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Days_to_Departure__c 
                                                    && rule.R_Days_to_Departure_To__c < sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Days_to_Departure__c){
                                            depositPII  = rule.R_Percentage__c/100;
                                        }
                                    }
                                   
                                    Depositmap.put(sc.SC_Client_Group__c,sc.SC_MarkUp_Cost_for_Selling_Price__c*depositPI+oAmount);
                                    DepositmapII.put(sc.SC_Client_Group__c,sc.SC_MarkUp_Cost_for_Selling_Price__c*depositPII+oAmountII);
                                }
                            }
                        //}
                    }
                }
                for(String cgId : Depositmap.keySet()){
                    if(supplierBookingCountByCG.containsKey(cgId)){
                        Decimal totalCost = Depositmap.get(cgId);
                        Decimal totalCostII = DepositmapII.get(cgId);
                        Decimal flightCharge = supplierBookingCountByCG.get(cgId).size()*50;
                        Depositmap.put(cgId,totalCost+flightCharge);
                        DepositmapII.put(cgId,totalCostII+flightCharge);
                    }
                }
            }
            lstOfMaps.add(Depositmap);
            lstOfMaps.add(DepositmapII);
            return lstOfMaps;
        }
        
        
        /********* OpportunityTrigger *************
        **********                    *************/
        
        public static void OpportunityTrigger(){
            if(trigger.IsAfter && !Utility.isCopied ){
                Set<String> oppIds = new Set<String>();
                Set<String> oppAI = new Set<String>();
                Set<Id> oppSP = new Set<Id>();
                Map<String,Boolean> mapFieldChanged = new Map<String,Boolean>();
                Decimal OriginalBWeekDay;
                Decimal OriginalEWeekDay;
                Decimal OriginalQWeekDay;
                Date Bookingdate;
                Date Enquirydate;
                Date Quotedate;
                
                
                if(!trigger.IsDelete){
                    //####WEEK TRIGGER
                    for(Opportunity opp : (List<Opportunity>)trigger.new){
                        oppIds.add(opp.id);
                        OriginalBWeekDay = opp.O_Booking_Week__c;
                        Bookingdate = opp.O_Booking_Date__c;
                        
                        OriginalEWeekDay = opp.O_Enquiry_Week__c;
                        Enquirydate = opp.CloseDate;
                        
                        OriginalQWeekDay = opp.O_Quote_Week__c;
                        Quotedate = opp.O_Quote_Date__c;
                        
                        //IF User Change INCLUDE FLIGHT MARGIN field 
                        if (Trigger.isUpdate) { 
                            if (opp.O_Include_Flight_Margin__c != ((Opportunity)Trigger.oldMap.get(opp.Id)).O_Include_Flight_Margin__c) { 
                                mapFieldChanged.put(opp.Id, true);
                            }
                            if (opp.StageName != ((Opportunity)Trigger.oldMap.get(opp.Id)).StageName && opp.StageName == 'Booked') { 
                                oppAI.add(opp.Id);
                                oppSP.add(opp.Id);
                            }
                        }
                        
                                   
                    }
                    //Update AI Objects records
                   // SupplierPaymentServices.createSupplierPayments(oppSP);
                    Triggers.UpdateAI(oppAI);
                    
                    //Update All Supplier Cost Where INCLUDE FLIGHT MARGIN Field has been changes
                    List<Supplier_Cost__c> lstSupplierCost = new List<Supplier_Cost__c>();
                    for(Supplier_Booking__c sb : [select Id, (Select ID from Supplier_Costs__r) from Supplier_Booking__c 
                                                where SB_Opportunity__c in: mapFieldChanged.keySet() order by SB_Order__c]){
                        for(Supplier_Cost__c sc : sb.Supplier_Costs__r){
                            lstSupplierCost.add(sc);    
                        }
                    }
                    update lstSupplierCost;
                    
                    if (CalculateWeekClass.RunOnce()) {
                        if(Bookingdate != NULL) {  
                            CalculateWeekClass t = new CalculateWeekClass();
                            t.calculateBWeek(oppIds , OriginalBWeekDay);
                        }
                        if(Enquirydate != NULL) {  
                            CalculateWeekClass t = new CalculateWeekClass();
                            t.calculateEWeek(oppIds , OriginalEWeekDay);
                        }
                        
                        if(Quotedate != NULL) {  
                            CalculateWeekClass t = new CalculateWeekClass();
                            t.calculateQWeek(oppIds ,OriginalQWeekDay);
                        }
                    }
                    //Create Cost for secondary accounts
                    if(!Utility.copyCost){
                        Utility.copyCost = true;
                        Utility.fillCostForSecAccounts(oppIds);
                    }
                }
            }
            else if(Trigger.isBefore){
                Site__c sc = Site__c.getInstance();
                if(sc.LastReferenceNumber__c == null)
                    sc.LastReferenceNumber__c = 1;
                if (Trigger.IsInsert) {
                    //Getting last reference number assign to opportunity
                    Integer lastautoNumber = Integer.valueOf(sc.LastReferenceNumber__c);
                    Integer NewAutoNumber; 
                    String formatted = '';                   
                    for (Opportunity oppNew : (List<Opportunity>)Trigger.New) {
                        NewAutoNumber = lastautoNumber  + 1;
                        if(String.valueOf(NewAutoNumber).length()<4){
                            Integer num = String.valueOf(NewAutoNumber).length();
                            for(integer i = num ; i<6 ; i++){
                                formatted =formatted + '0';
                            }
                            formatted = 'RF-'+formatted + String.valueOf(NewAutoNumber) ;
                        }else{
                            formatted = 'RF-'+String.valueOf(NewAutoNumber);
                        }
                        //Asign next number to new opportunity
                        oppNew.O_Reference_Number__c = formatted;
                        lastautoNumber  = NewAutoNumber;
                        //update custom setting reference number with last reference number assigned
                        sc.LastReferenceNumber__c = NewAutoNumber;
                    }
                    upsert sc;
                } 
            } 
        }
        
        
        /******* Supplier_Booking__cTrigger********
        *********                           ******/
        
        public static void SupplierBookingTrigger(){
            if(trigger.isAfter && Trigger.isInsert){
                List<String> lstOppId = new List<String>();
                List<Opportunity> lstOpp = new List<Opportunity>();
                List<String> lstUserIds = new List<String>();
                Map<String,String> mapUsers = new Map<String,String>();
                for (Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.new){
                    lstOppId.add(sb.SB_Opportunity__c);
                }
                
                for(Opportunity opp : [Select Id, OwnerId, StageName, (Select Id from Supplier_Booking__r) from Opportunity where Id in :lstOppId]){
                    
                    if(opp.Supplier_Booking__r.size() == 1 && opp.StageName == 'Enquiry'){
                        opp.StageName = 'Quote pending';        
                    }
                    
                    lstOpp.add(opp);
                    lstuserIds.add(opp.OwnerId);
                    mapUsers.put(opp.Id,opp.OwnerId);
                }
                Utility.isCopied = true;
                update lstOpp;
                
                //Upsert Images If new SB loaded
                Map<String,String> mapRecords = new Map<String, String>();
                String objectName =  Utility.getNameSpacePrefix()+'Supplier_Booking__c';
                for(RecordType rt : [Select Id, Name,DeveloperName from Recordtype where sobjecttype = :objectName]){
                    mapRecords.put(rt.DeveloperName, rt.Id);
                }
                integer limitCount = 2;
                Map<String,Integer> mapSupplierImageCount = new Map<String,Integer>();
                Map<String,Set<String>> mapSupplierImages = new Map<String,Set<String>>();
                if (Trigger.isupdate) {
                    for(Supplier_Booking__c sb : [select id, (select id,SBI_Attachement_Id__c  from SupplierBookingImages__r) from  Supplier_Booking__c 
                                                    where id in:trigger.new]) {
                        mapSupplierImageCount.put(sb.id,sb.SupplierBookingImages__r.size());
                        mapSupplierImages.put(sb.id, new set<String>());
                        for (SupplierBookingImage__c img : sb.SupplierBookingImages__r) {
                            mapSupplierImages.get(sb.id).add(img.SBI_Attachement_Id__c );
                        }
                    }
                    
                }
                
                Map<String,String> mapSBOppIds = new Map<String,String>();
                for (Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.new ) {
                    if(sb.RecordTypeId == mapRecords.get('Int_Flight') || sb.RecordTypeId == mapRecords.get('Dom_Flights') || sb.RecordTypeId == mapRecords.get('Light_Aircraft') || sb.RecordTypeId == mapRecords.get('Private_Jet') || sb.RecordTypeId == mapRecords.get('Sea_Plane')){
                        mapSBOppIds.put(sb.id,sb.SB_Opportunity__c);
                    }
                }
                Map<string,set<string>> mapOppTCImages = new Map<String,Set<String>>();
                Map<String,Set<String>> mapOppTCIds = new Map<String,Set<String>>();
                
                if (mapSBOppIds.size() > 0) {
                    
                    Set<String> countries = new Set<String>();
                    String oppId = '';
                    for (travelling_country__c tc : [select id,tc_country__c,tc_opportunity__c 
                                                    from Travelling_Country__c where tc_opportunity__c in: mapSBOppIds.values()]) {
                        countries.add(tc.tc_country__c);
                        oppId = tc.tc_opportunity__c;                
                        if (!mapOppTCImages.containskey(tc.tc_opportunity__c)) {
                            mapOppTCImages.put(tc.tc_opportunity__c, new set<String>());
                            mapOppTCIds.put(tc.tc_opportunity__c, new Set<String>());
                        }
                        mapOppTCIds.get(tc.tc_opportunity__c).add(tc.tc_country__c);
                    }
                    
                    Set<String> flightImages = new Set<String>();
                    for (Attachment att :[select id, parentId from Attachment where parentId in: countries and (NOT Name  like '%cover%')  and Name  like '%default%' 
                                    order by lastmodifieddate desc limit 2]) { //limit : limitCount 
                        mapOppTCImages.get(oppId).add(att.id);
                        flightImages.add(att.Id);
                    }
                    if(mapOppTCImages.size() != 2){
                        Integer limitR = 0;
                        if(oppId != null && mapOppTCImages.get(oppId).size() == 0){
                            limitR = 2;    
                        }
                        else{
                            limitR = 1;
                        }
                        for (Attachment att :[select id, parentId from Attachment where parentId in: countries and (NOT Name  like '%cover%')  and Id != :flightImages 
                                        order by lastmodifieddate desc limit : limitR]) { //limit : limitCount 
                            mapOppTCImages.get(oppId).add(att.id);
                        }
                    }
                    System.debug('DDDDDDDDDDDDDDDDDDDDDFFFFFFFFFFFFFFF'+mapOppTCImages);
                      
                }
                
                Set<String> recordIds = new Set<String>();
                Set<String> accommodations = new Set<String>();
                Set<String> sbIds = new Set<String>();
                
                
                for (Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.new ) {
                    
                    
                    if(sb.RecordTypeId == mapRecords.get('Accommodation')){
                        if(sb.SB_Supplier__c != null){
                            recordIds.add(sb.SB_Supplier__c);
                        }
                        //accommodations.add(sb.SB_Supplier__c);
                    }
                    else if (sb.RecordTypeId == mapRecords.get('Excursion')){
                        if(sb.SB_What_to_do__c != null){
                            recordIds.add(sb.SB_What_to_do__c);
                        }
                    }
                    else if (sb.RecordTypeId == mapRecords.get('Days_at_Leisure')){
                        if(sb.SB_Where_To_Go__c!= null) {
                            recordIds.add(sb.SB_Where_to_go__c);
                        }
                    }
                    
                }
                
                
                
                Map<String, List<String>> mapParentAttachments = new Map<String, List<String>>();
                List<String> coverIds = new List<String>();
                
                
                if (trigger.isInsert) {
                    Integer limits = recordIds.size()*4;
                    for (Attachment att :[select id, parentId from Attachment where (NOT Name  like '%cover%') and Name  like '%default%' and parentId in: recordIds 
                                    order by lastmodifieddate desc limit :limits]) { //limit : limitCount 
                        if (!mapParentAttachments.containskey(att.parentid)) {            
                            mapParentAttachments.put(att.parentid, new LIst<string>()); 
                        }
                        mapParentAttachments.get(att.parentid).add(att.id);
                        coverIds.add(att.id);
                    }
                    for (Attachment att :[select id, parentId from Attachment where Id not in :coverIds and (NOT Name  like '%cover%') and parentId in: recordIds 
                                    order by lastmodifieddate desc limit :limits]) { //limit : limitCount 
                        if (!mapParentAttachments.containskey(att.parentid)) {            
                            mapParentAttachments.put(att.parentid, new LIst<string>()); 
                        }
                        mapParentAttachments.get(att.parentid).add(att.id);
                    }
                    
                }
                else {
                    
                    Integer limits = recordIds.size()*4;
                    for (Attachment att :[select id, parentId from Attachment where Id not in :coverIds and (NOT Name  like '%cover%') and Name  like '%default%'
                                     and parentId in: recordIds order by lastmodifieddate desc Limit :limits]) { //limit : limitCount 
                        if (!mapParentAttachments.containskey(att.parentid)) {            
                            mapParentAttachments.put(att.parentid, new LIst<string>()); 
                        }
                        mapParentAttachments.get(att.parentid).add(att.id);
                        coverIds.add(att.id);
                    }
                    for (Attachment att :[select id, parentId from Attachment where Id not in :coverIds  and (NOT Name  like '%cover%') and parentId in: recordIds 
                                    order by lastmodifieddate desc Limit :limits]) { //limit : limitCount 
                        if (!mapParentAttachments.containskey(att.parentid)) {            
                            mapParentAttachments.put(att.parentid, new LIst<string>()); 
                        }
                        mapParentAttachments.get(att.parentid).add(att.id);
                    }
                    
                }
                
                Map<String,List<String>> mapImages_AI = new Map<String,List<String>>();
                for(Images_AI__c IAI : [Select Id, AI_Parent_ID__c, AI_Image_ID__c, AI_User__c from Images_AI__c where AI_Parent_ID__c 
                                        in :mapParentAttachments.keySet() and AI_User__c in :lstuserIds order by AI_Count__c]){
                    if(!mapImages_AI.containsKey(IAI.AI_Parent_ID__c+'##'+IAI.AI_User__c)){
                        mapImages_AI.put(IAI.AI_Parent_ID__c+'##'+IAI.AI_User__c, new List<String>());    
                    }
                    mapImages_AI.get(IAI.AI_Parent_ID__c+'##'+IAI.AI_User__c).add(IAI.AI_Image_ID__c);
                }
                
                
                List<SupplierBookingImage__c> lstSBImage = new List<SupplierBookingImage__c>();
                for (Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.new ) {
                    
                    List<SupplierBookingImage__c> lstSBImageChild = new List<SupplierBookingImage__c>();
                    if(sb.RecordTypeId == mapRecords.get('Accommodation')){
                        
                        if (mapParentAttachments.containskey(sb.SB_Supplier__c)) {
                            Integer order = 0;
                            for (String attachId : mapParentAttachments.get(sb.SB_Supplier__c)) {
                                if (trigger.isInsert) {
                                    order++;
                                    SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Order__c = order,SBI_Supplier_Booking__c= sb.Id,SBI_Attachement_Id__c= attachId);
                                    if(mapUsers.containsKey(sb.SB_Opportunity__c) && mapImages_AI.containsKey(sb.SB_Supplier__c+'##'+mapUsers.get(sb.SB_Opportunity__c)) && mapImages_AI.get(sb.SB_Supplier__c+'##'+mapUsers.get(sb.SB_Opportunity__c)).size() >=  order){
                                        sbi.SBI_Attachement_Id__c = mapImages_AI.get(sb.SB_Supplier__c+'##'+mapUsers.get(sb.SB_Opportunity__c))[order-1];
                                    }
                                    lstSBImageChild.add(sbi) ;
                                    if (lstSBImageChild.size() == 4) {
                                        break;
                                    }
                                }
                            }
                            lstSBImage.addAll(lstSBImagechild);
                            
                        }
                        
                    }
                    else if (sb.RecordTypeId == mapRecords.get('Int_Flight') || sb.RecordTypeId == mapRecords.get('Dom_Flights') || sb.RecordTypeId == mapRecords.get('Light_Aircraft') || sb.RecordTypeId == mapRecords.get('Private_Jet') || sb.RecordTypeId == mapRecords.get('Sea_Plane')) {
                        
                        if (mapOppTCImages.containskey(sb.sb_opportunity__c)) {
                            Integer order = 0;
                            for (string attachId : mapOppTCImages.get(sb.sb_opportunity__c)) {
                                if (trigger.isInsert) {
                                    if (lstSBImageChild.size() == 2) {
                                        break;
                                    }
                                    order++;
                                    SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Supplier_Booking__c= sb.Id,SBI_Attachement_Id__c= attachId );
                                    if(mapOppTCIds.containsKey(sb.sb_opportunity__c)){
                                        for(String tcId : mapOppTCIds.get(sb.sb_opportunity__c)){
                                            if(mapUsers.containsKey(sb.SB_Opportunity__c) && mapImages_AI.containsKey(tcId+'##'+mapUsers.get(sb.SB_Opportunity__c)) && mapImages_AI.get(tcId+'##'+mapUsers.get(sb.SB_Opportunity__c)).size() >=  order){
                                                sbi.SBI_Attachement_Id__c = mapImages_AI.get(tcId+'##'+mapUsers.get(sb.SB_Opportunity__c))[order-1];
                                            }
                                        }
                                    }
                                    lstSBImageChild.add(sbi) ;
                                    
                                }
                            }
                            lstSBImage.addAll(lstSBImagechild);
                        }
                    }
                    else if(sb.RecordTypeId == mapRecords.get('Excursion') || sb.RecordTypeId == mapRecords.get('Days_at_Leisure') || sb.RecordTypeId == mapRecords.get('Cruise')){
                        
                        if (mapParentAttachments.containskey(sb.SB_Where_to_go__c)) {
                            Integer order = 0;    
                            for (String attachId : mapParentAttachments.get(sb.SB_Where_to_go__c)) {
                                if (trigger.isInsert) {
                                    order++;
                                    SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Supplier_Booking__c= sb.Id,SBI_Attachement_Id__c= attachId );
                                    if(mapUsers.containsKey(sb.SB_Opportunity__c) && mapImages_AI.containsKey(sb.SB_Where_to_go__c+'##'+mapUsers.get(sb.SB_Opportunity__c)) && mapImages_AI.get(sb.SB_Where_to_go__c+'##'+mapUsers.get(sb.SB_Opportunity__c)).size() >=  order){
                                        sbi.SBI_Attachement_Id__c = mapImages_AI.get(sb.SB_Where_to_go__c+'##'+mapUsers.get(sb.SB_Opportunity__c))[order-1];
                                    }
                                    lstSBImageChild.add(sbi) ;
                                    if (lstSBImageChild.size() == 2) {
                                        break;
                                    }
                                }
                            }
                            lstSBImage.addAll(lstSBImagechild);
                            
                        }
                        else if (mapParentAttachments.containskey(sb.SB_what_to_do__c)) {
                                    Integer order = 0;    
                                    for (String attachId : mapParentAttachments.get(sb.SB_what_to_do__c)) {
                                        if (trigger.isInsert) {
                                            order++;
                                            SupplierBookingImage__c sbi = new SupplierBookingImage__c(SBI_Supplier_Booking__c= sb.Id,SBI_Attachement_Id__c= attachId );
                                            if(mapUsers.containsKey(sb.SB_Opportunity__c) && mapImages_AI.containsKey(sb.SB_what_to_do__c+'##'+mapUsers.get(sb.SB_Opportunity__c)) && mapImages_AI.get(sb.SB_what_to_do__c+'##'+mapUsers.get(sb.SB_Opportunity__c)).size() >=  order){
                                                sbi.SBI_Attachement_Id__c = mapImages_AI.get(sb.SB_what_to_do__c+'##'+mapUsers.get(sb.SB_Opportunity__c))[order-1];
                                            }
                                            lstSBImageChild.add(sbi) ;
                                            if (lstSBImageChild.size() == 2) {
                                                break;
                                            }
                                        }
                                    }
                                    lstSBImage.addAll(lstSBImagechild);
                                }
                        }
                       
                       
                }
                //List<SupplierBookingImage__c> lstSBImage1 = new List<SupplierBookingImage__c>();
                //lstSBImage1.addAll(lstSBImage);
                insert lstSBImage;
            }
            if(trigger.isAfter){
                List<String> OppIds = new List<String>();
                if(trigger.isDelete){
                    for(Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.old){
                        OppIds.add(sb.SB_Opportunity__c);   
                    }
                    
                    //Update All Supplier Cost to update Deposit Required
                    List<Supplier_Cost__c> lstSupplierCost = new List<Supplier_Cost__c>();
                    for(Supplier_Booking__c sb : [select Id, (Select ID from Supplier_Costs__r) from Supplier_Booking__c 
                                                where SB_Opportunity__c in: OppIds order by SB_Order__c]){
                        for(Supplier_Cost__c sc : sb.Supplier_Costs__r){
                            lstSupplierCost.add(sc);    
                        }
                    }
                    update lstSupplierCost;
                    
                    List<Supplier_Cost_Payment__c> lstSCCV = new List<Supplier_Cost_Payment__c>();
                    for(Supplier_Cost_Payment__c sccv : [Select Id, (Select Id from Supplier_Payments__r), (Select Id from Supplier_Costs__r) from Supplier_Cost_Payment__c where SCP_Opportunity__c in : OppIds]){
                        if(sccv.Supplier_Payments__r.size() == 0 && sccv.Supplier_Costs__r.size() == 0){
                            lstSCCV.add(sccv);
                        }
                    }
                    Delete lstSCCV;
                }
                //Target Markup Update and Cost Margin Update
                if(!trigger.isDelete){
                    for(Supplier_Booking__c sb : (List<Supplier_Booking__c>)trigger.new){
                        OppIds.add(sb.SB_Opportunity__c); 
                    }    
                }
                List<Supplier_Cost__c> lstSupplierCosts = new List<Supplier_Cost__c>();
                for(Supplier_Booking__c sb  :  [Select Id,SB_Opportunity__r.O_Target_Mark_Up_Value__c,SB_Opportunity__r.O_Old_Markup_Value__c,
                                                (Select Id,SC_Margin__c from Supplier_Costs__r) from Supplier_Booking__c where 
                                                SB_Opportunity__c in :OppIds and SB_Opportunity__r.O_Total_Flight_Cost__c > 0]){
                    if(sb.SB_Opportunity__r.O_Target_Mark_Up_Value__c != sb.SB_Opportunity__r.O_Old_Markup_Value__c){
                        for(Supplier_Cost__c sc : sb.Supplier_Costs__r){
                            if(sb.SB_Opportunity__r.O_Old_Markup_Value__c == sc.SC_Margin__c){
                                sc.SC_Margin__c = sb.SB_Opportunity__r.O_Target_Mark_Up_Value__c;
                                lstSupplierCosts.add(sc);
                            }
                        }
                    }
                }
                Update lstSupplierCosts;
                List<Travelling_Country__c> lsTC = [Select Id from Travelling_Country__c where TC_Opportunity__c in :OppIds];
                Update lsTC;
            }    
            
        }
        
        //Update WTG,Activity,Supplier,Images count & Create Credit Memo records
        public static void UpdateAI(Set<String> setOppIDs){
            Set<String> setAICountry = new Set<String>();
            Set<String> setAIWTG = new Set<String>();
            Set<String> setAIActivity = new Set<String>();
            Set<String> setAISupplier = new Set<String>();
            Set<String> setSBImageIDs = new Set<String>();
            Set<String> setSBIDs = new Set<String>();
            Set<String> allIds = new Set<String>();
            Set<String> setUsers = new Set<String>();
            Set<String> allImages = new Set<String>();
            
            Map<String,String> mapUserId = new Map<String,String>();
            for(Opportunity opp : [Select Id,OwnerId,(Select Id,Name,TC_Country__c,TC_Cover_Image__c,TC_ImageID__c from Travelling_Countries__r),
                                    (Select Id,SB_Supplier__c,SB_Where_to_go__c,SB_What_to_do__c from Supplier_Booking__r) from Opportunity where Id in :setOppIDs]){ // Owner = :UserInfo.getId()]){
                for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                    setAICountry.add(tc.TC_Country__c);
                    allIds.add(tc.TC_Country__c+'##'+opp.OwnerId);
                    mapUserId.put(tc.TC_Country__c,opp.OwnerId);
                    if(tc.TC_ImageID__c != null){
                        setSBImageIDs.add(tc.TC_ImageID__c);
                        mapUserId.put(tc.TC_ImageID__c,opp.OwnerId);
                        allIds.add(tc.TC_ImageID__c+'##'+opp.OwnerId);
                        allImages.add(tc.TC_ImageID__c);
                    }
                    setUsers.add(opp.OwnerId);
                }
                for(Supplier_Booking__c sb : opp.Supplier_Booking__r){
                    if(sb.SB_Supplier__c != null){
                        setAISupplier.add(sb.SB_Supplier__c);
                        mapUserId.put(sb.SB_Supplier__c,opp.OwnerId);
                        allIds.add(sb.SB_Supplier__c+'##'+opp.OwnerId);
                        setUsers.add(opp.OwnerId);
                    }
                    if(sb.SB_Where_to_go__c != null){
                        mapUserId.put(sb.SB_Where_to_go__c,opp.OwnerId);
                        setAIWTG.add(sb.SB_Where_to_go__c);
                        allIds.add(sb.SB_Where_to_go__c+'##'+opp.OwnerId);
                        setUsers.add(opp.OwnerId);
                    }
                    if(sb.SB_What_to_do__c != null){
                        mapUserId.put(sb.SB_What_to_do__c,opp.OwnerId);
                        setAIActivity.add(sb.SB_What_to_do__c);
                        allIds.add(sb.SB_What_to_do__c+'##'+opp.OwnerId);
                        setUsers.add(opp.OwnerId);
                    }
                    setSBIDs.add(sb.Id);
                    
                }
            }
            for(SupplierBookingImage__c SBI : [Select Id,SBI_Attachement_Id__c,SBI_Supplier_Booking__r.SB_Opportunity__r.OwnerId from SupplierBookingImage__c where SBI_Supplier_Booking__c in :setSBIDs]){
                setSBImageIDs.add(sbi.SBI_Attachement_Id__c);
                allIds.add(sbi.SBI_Attachement_Id__c+'##'+SBI.SBI_Supplier_Booking__r.SB_Opportunity__r.OwnerId);
                mapUserId.put(sbi.SBI_Attachement_Id__c,SBI.SBI_Supplier_Booking__r.SB_Opportunity__r.OwnerId);
                setUsers.add(SBI.SBI_Supplier_Booking__r.SB_Opportunity__r.OwnerId);
                allImages.add(sbi.SBI_Attachement_Id__c);

            }
            Map<String,Images_AI__c> mapAI = new Map<String,Images_AI__c>();
            for(Images_AI__c IAI : [Select Id,AI_Count__c,AI_User__c,AI_Country__c,AI_Activity__c,AI_Image_ID__c,AI_Where_to_go__c,AI_Supplier__c from Images_AI__c where 
                                    (AI_Where_to_go__c in :setAIWTG OR AI_Supplier__c in :setAISupplier OR AI_Image_ID__c in :setSBImageIDs 
                                    OR AI_Country__c in :setAICountry OR AI_Activity__c in :setAIActivity) and AI_User__c in : setUsers]){
                if(IAI.AI_Where_to_go__c != null){
                    mapAI.put(IAI.AI_Where_to_go__c+'##'+IAI.AI_User__c, IAI);
                }
                if(IAI.AI_Supplier__c != null){
                    mapAI.put(IAI.AI_Supplier__c+'##'+IAI.AI_User__c, IAI);
                }
                if(IAI.AI_Image_ID__c != null){
                    mapAI.put(IAI.AI_Image_ID__c+'##'+IAI.AI_User__c, IAI);
                }
                if(IAI.AI_Country__c != null){
                    mapAI.put(IAI.AI_Country__c+'##'+IAI.AI_User__c, IAI);
                }
                if(IAI.AI_Activity__c != null){
                    mapAI.put(IAI.AI_Activity__c+'##'+IAI.AI_User__c, IAI);
                }
            }
            //Create or update AI object records
            List<Images_AI__c> lstImageAI = new List<Images_AI__c>();
            Map<String,String> mapParentByAttId = new Map<String,String>();
            for(Attachment att : [Select Id,ParentId from Attachment where Id in :allImages]){
                mapParentByAttId.put(att.Id, att.ParentId);    
            }
            
            //System.assert(false,mapAI+'**********'+allIds);
            for(String str : allIds){
                if(mapAI.containsKey(str)){
                    Images_AI__c IAI = mapAI.get(str);
                    IAI.AI_Count__c = IAI.AI_Count__c+1;
                    if(mapParentByAttId.containsKey(str)){
                        IAI.AI_Parent_ID__c = mapParentByAttId.get(str);
                    }
                    lstImageAI.add(IAI);
                }
                else{
                    List<String> str1 = str.split('##');
                    if(setAICountry.contains(str1[0])){
                        Images_AI__c IAI = new Images_AI__c(AI_Count__c = 1, AI_Country__c = str1[0], AI_User__c = mapUserId.get(str1[0]));
                        lstImageAI.add(IAI);
                    }
                    else if(setAISupplier.contains(str1[0])){
                        Images_AI__c IAI = new Images_AI__c(AI_Count__c = 1, AI_Supplier__c = str1[0], AI_User__c = mapUserId.get(str1[0]));
                        lstImageAI.add(IAI);
                    }
                    else if(setAIWTG.contains(str1[0])){
                        Images_AI__c IAI = new Images_AI__c(AI_Count__c = 1, AI_Where_to_go__c = str1[0], AI_User__c = mapUserId.get(str1[0]));
                        lstImageAI.add(IAI);
                    }
                    else if(setAIActivity.contains(str1[0])){
                        Images_AI__c IAI = new Images_AI__c(AI_Count__c = 1, AI_Activity__c = str1[0], AI_User__c = mapUserId.get(str1[0]));
                        lstImageAI.add(IAI);
                    }
                    else if(setSBImageIDs.contains(str1[0])){
                        Images_AI__c IAI = new Images_AI__c(AI_Count__c = 1, AI_Image_ID__c = str1[0], AI_User__c = mapUserId.get(str1[0]));
                        if(mapParentByAttId.containsKey(str1[0])){
                            IAI.AI_Parent_ID__c = mapParentByAttId.get(str1[0]);
                        }
                        lstImageAI.add(IAI);
                    }
                }
                upsert lstImageAI;
            }
            
            List<CurrencyType> lstORGCurrency = [SELECT Id,IsoCode,IsCorporate FROM CurrencyType where IsCorporate = true limit 1];
            //Create Credit Memo record 
            Set<String> setOfSellingCurency = new Set<String>();
            Set<Date> setOfDepartureDates = new Set<Date>();
            Set<Date> setOfCloseDates = new Set<Date>();
            setOfSellingCurency.add(lstORGCurrency[0].IsoCode);
            for(Opportunity opp : (List<Opportunity>)trigger.new){
                setOfDepartureDates.add(opp.O_Departure_Date__c);
                setOfCloseDates.add(opp.CloseDate);
            }
            //Get minimum and maximum close and departure date.
            List<Date> lstMinMaxDPDate = Utility.FindMinMaxDate(setOfDepartureDates);
            List<Date> lstMinMaxCloseDate = Utility.FindMinMaxDate(setOfCloseDates);
            //Get exchange and margin                        
            List<Exchange_Rate__c> fullExchangeRate = SOQLServices.getExchangeRate(setOfSellingCurency,lstMinMaxCloseDate,lstMinMaxDPDate,'Sell');
            
            List<Credit_Memo__c> lstCM = new List<Credit_Memo__c>();
            for(Supplier_Cost__c sc : [Select Id,CurrencyIsoCode,SC_Supplier_Booking__r.SB_Opportunity__c,SC_Total_Client_Group_Cost__c,
                                       SC_Supplier_Booking__r.SB_Opportunity__r.closeDate ,SC_Supplier_Booking__r.SB_Opportunity__r.O_Departure_Date__c ,
                                       SC_Supplier_Booking__r.SB_Opportunity__r.AccountId from Supplier_Cost__c where SC_Supplier_Booking__r.SB_Opportunity__c in  : setOppIDs and SC_Supplier_Booking__r.RecordType.DeveloperName = 'Credit_Memo']){
                Map<String,Exchange_Rate__c> childExr = new Map<String,Exchange_Rate__c>();
                for(Exchange_Rate__c er : fullExchangeRate){
                    if((er.ER_Sales_Currency__c == lstORGCurrency[0].IsoCode) 
                      && sc.SC_Supplier_Booking__r.SB_Opportunity__r.closeDate >= er.ER_Book_From__c && 
                      sc.SC_Supplier_Booking__r.SB_Opportunity__r.closeDate <= er.ER_Book_To__c && 
                      sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Departure_Date__c >= er.ER_Travel_From__c &&
                      sc.SC_Supplier_Booking__r.SB_Opportunity__r.O_Departure_Date__c <= er.ER_Travel_To__c){
                          childExr.put(er.ER_Base_Currency__c,er);    
                    }
                }
                Exchange_Rate__c er = new Exchange_Rate__c();
                if(childExr.containsKey(sc.CurrencyISOCode)){
                    er = childExr.get(sc.CurrencyISOCode);
                }
                lstCM.add(new Credit_Memo__c(CM_Exchange_Rate__c = er.Id, CM_Account__c = sc.SC_Supplier_Booking__r.SB_Opportunity__r.AccountId,currencyISOCode = sc.CurrencyISOCode, CM_Amount__c = sc.SC_Total_Client_Group_Cost__c, CM_Opportunity__c = sc.SC_Supplier_Booking__r.SB_Opportunity__c, CM_Type__c = 'Compensation'));
            }
            insert lstCM;
        }
        
        
        //****** ContactTrigger ****//
        public Static void ContactTriggerBefore(){
            Site__c customSetiing = Site__c.getInstance();
            if(customSetiing.Run_Trigger__c){
                if(!trigger.isDelete){
                    for(Contact con : (List<Contact>)trigger.new){
                        if(con.BirthDate != null){
                            Integer days = con.BirthDate.daysBetween(Date.Today());
                            Integer age = Integer.valueOf(days/365);
                            if(age <= 2){
                                con.Occupancy_Type__c = 'Infant';
                            }
                            else if(age > 2 && age <= 12){
                                con.Occupancy_Type__c = 'Child';
                            }
                            else{
                                con.Occupancy_Type__c = 'Adult';
                            }
                        }
                    }
                }   
            } 
        }
}
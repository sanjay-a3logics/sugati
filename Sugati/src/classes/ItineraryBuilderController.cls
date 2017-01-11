Public with Sharing Class ItineraryBuilderController{
    public Opportunity opp{get; set;}
    public String oppStr{get; set;}
    public Boolean isOTUK{get; set;}
    public Supplier_Booking__c sbRecord{get; set;}
    public List<picklistValues> recordTypeOptions{get; set;}
    public String clientGroupstr{get; set;}
    public Boolean groupMemberRed{get; set;}
    public Boolean haveTravellingCountry{get; set;}
    public String StrRecordtype{get;set;}
    public transient String pickLists {get; set;}
    public transient String autoSuggestSupplier{get; set;}
    public transient String autoSuggestTime{get; set;}
    public transient String autoSuggestWhereToGo{get; set;}
    public transient String autoSuggestRoom{get; set;}
    public transient String itineraryTextTemplate{get; set;}
    public transient String itineraryTextTemplateWC{get; set;}
    public transient String autoSuggestTerminal{get; set;}
    public transient String autoSuggestClass{get; set;}
    public transient String autoSuggestAirport{get; set;}
    public transient String noneLicenceableTable{get; set;}
    public transient String widgetyReferences {get; set;}
    public transient String HEPageErrorMessage{get; set;}
    public String travellingCountries{get; set;}
    public transient String holidayType{get;set;}
    public String fieldSets{get; set;}
    public String nameSpacePrefix{get;set;}
    public String mapSupplierPayment{get; set;}
    public String mapSBSupplierPayment{get; set;}
    
    public Decimal totalMemo{get;set;}
    
    public String oppId;
    Map<String,String> mapRecordtype;
    
    public ItineraryBuilderController(ApexPages.StandardController controller){
        try{
            oppId = controller.getId();
            totalMemo = 50.50; 
            isOTUK  = false;
            groupMemberRed  = false;
            recordTypeOptions = new List<picklistValues>();
            List<picklistValues> clientGroups = new List<picklistValues>();
            ApexClass cs =[select NamespacePrefix from ApexClass where Name ='ItineraryBuilderController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            sbRecord = new Supplier_Booking__c();
            if(oppId != null){
                opp = SOQLServices.getOpportunities(new Set<String>{oppId})[0];
                
                for(Client_Group__c cg : opp.client_Groups__r){
                    clientGroups.add(new picklistValues(cg.Id, cg.Name));
                }
                
                for(Group_Member__c gm : opp.Group_Members__r){
                    if(gm.GM_Client_Group__c == null){
                        groupMemberRed = true; 
                        if(clientGroups.size() == 1){
                            gm.GM_Client_Group__c  = clientGroups[0].value;
                        }
                    }
                }    
                oppStr = JSON.serialize(opp);  
                setAutoSuggest();
            }
            clientGroupstr = JSON.serialize(clientGroups);
            pickLists = JSON.serialize(Utility.describePickListsStr(Utility.getNameSpacePrefix()+'Supplier_Booking__c,'+Utility.getNameSpacePrefix()+'Supplier_Cost__c,contact,'+Utility.getNameSpacePrefix()+'Communication_Preference__c'));    
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+e.getMessage());
        }
        //System.assert(false,pickLists);
    }
    
    public ItineraryBuilderController(){
        try{
            oppId = ApexPages.CurrentPage().getParameters().get('Id'); 
            isOTUK  = false;
            groupMemberRed  = false;
            recordTypeOptions = new List<picklistValues>();
            List<picklistValues> clientGroups = new List<picklistValues>();
            ApexClass cs =[select NamespacePrefix from ApexClass where Name ='ItineraryBuilderController'];
            if(cs.NamespacePrefix != null){
                nameSpacePrefix = cs.NamespacePrefix+'__';
            }
            else{
                nameSpacePrefix = '';
            }
            sbRecord = new Supplier_Booking__c();
            if(oppId != null){
                opp = SOQLServices.getOpportunities(new Set<String>{oppId})[0];
                
                for(Client_Group__c cg : opp.client_Groups__r){
                    clientGroups.add(new picklistValues(cg.Id, cg.Name));
                }
                
                for(Group_Member__c gm : opp.Group_Members__r){
                    if(gm.GM_Client_Group__c == null){
                        groupMemberRed = true; 
                        if(clientGroups.size() == 1){
                            gm.GM_Client_Group__c  = clientGroups[0].value;
                        }
                    }
                }    
                oppStr = JSON.serialize(opp);  
                setAutoSuggest();
            }
            clientGroupstr = JSON.serialize(clientGroups);
            pickLists = JSON.serialize(Utility.describePickListsStr(Utility.getNameSpacePrefix()+'Supplier_Booking__c,'+Utility.getNameSpacePrefix()+'Supplier_Cost__c,contact,'+Utility.getNameSpacePrefix()+'Communication_Preference__c'));    
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+e.getMessage());
        }
        //System.assert(false,pickLists);
    }
        
    void setAutoSuggest(){
    
        List<picklistValues> lstSuppliers = new List<picklistValues>();
        List<picklistValues> lstWhereToGo = new List<picklistValues>();
        List<picklistValues> lstTerminals = new List<picklistValues>();
        List<picklistValues> lstClass = new List<picklistValues>();
        List<picklistValues> lstHolidayTypes = new List<picklistValues>();
        List<picklistValues> lstAirport = new List<picklistValues>();
        Map<String, String> mapSupplierWidgetyReference = new Map<String, String>();
        Set<String> travellingCountryName = new Set<String>();
        Map<String,Map<String,List<picklistValues>>> mapRoomTypes = new Map<String,Map<String,List<picklistValues>>>();
        for(Travelling_Country__c tc : opp.Travelling_Countries__r){
            haveTravellingCountry = True ;
            travellingCountryName.add(tc.TC_Country__r.Name);
            picklistValues pv = new picklistValues(tc.TC_Country__c, tc.TC_Country__r.Name);
            pv.type = 'Country';
            lstWhereToGo.add(pv);
        }
        travellingCountries = JSON.serialize(travellingCountryName);
        
        //Set Supplier for Accomodation
        List<picklistValues> supplierAcc = new List<picklistValues>();
        
        for(Supplier__c sup : SOQLServices.getSuppliers(travellingCountryName)){
            picklistValues pv = new picklistValues(sup.Id,sup.Name);
            pv.type = sup.S_Type__c;
            pv.wtg = sup.S_Where_to_go__c;
            if(sup.S_Recommended__c)
                pv.recommend = true;
            lstSuppliers.add(pv);
            if(sup.S_Widgety_Reference_ID__c != null)
                mapSupplierWidgetyReference.put(sup.Id, sup.S_Widgety_Reference_ID__c);
            else
                mapSupplierWidgetyReference.put(sup.Id, '');
        }
        
        //WhereToGo
        for(Where_to_go__c wtg : [select id, Name  from Where_to_go__c where W_country__r.Name in :travellingCountryName]){
            picklistValues pv = new picklistValues(wtg.Id, wtg.Name);
            pv.type = 'WTG';
            lstWhereToGo.add(pv);    
        }
        for(Airport__c airport : [Select ID, name from Airport__c ]){
            lstAirport.add(new picklistValues(airport.Id,airport.Name));
        }
        //Load Airport Terminals
        for(Airport_Terminal__c tr : [select id, Name,AT_Class__c,AT_Carrier_Name__c,AT_Airport__r.Name  from Airport_Terminal__c order by Name]){
            if(tr.AT_Class__c == null){
                picklistValues pv = new picklistValues(tr.Name, tr.Name);
                pv.type = tr.AT_Airport__c;
                lstTerminals.add(pv);
            }
            else{
                picklistValues pv = new picklistValues(tr.AT_Class__c, tr.AT_Class__c);
                pv.type = tr.AT_Carrier_Name__c;
                lstClass.add(pv);    
            }
        }
        
        
        //Accommodation Room Type
        for(Room_Type__c rt : [Select Id,RT_Field_Name__c,RT_Supplier__c,RT_Name__c from Room_Type__c where (RT_Supplier__r.S_Country__c in :travellingCountryName OR RT_Supplier__r.S_Country__c = null) and RT_Supplier__c != null and RT_Field_Name__c != null]){
            if(!mapRoomTypes.containsKey(rt.RT_Supplier__c)){
                mapRoomTypes.put(rt.RT_Supplier__c, new Map<String,List<picklistValues>>());    
            }    
            if(!mapRoomTypes.get(rt.RT_Supplier__c).containsKey(rt.RT_Field_Name__c)){
                 mapRoomTypes.get(rt.RT_Supplier__c).put(rt.RT_Field_Name__c, new List<picklistValues>());
            } 
            mapRoomTypes.get(rt.RT_Supplier__c).get(rt.RT_Field_Name__c).add(new picklistValues(rt.RT_Name__c,rt.RT_Name__c));
        }
        
        
        //Set Time
        List<picklistValues> lstSupplier1 = new List<picklistValues>();
        String strTimes = '';
        for (integer i = 0 ; i < 24; i ++) {
            for (integer j = 0 ; j < 60; j++) {
                
                if( i < 10) {
                    if ( j < 10) {
                        if (strTimes == '') {
                            strTimes = '0'+i +':'+ '0'+ j;
                        }
                        else {
                            strTimes += ',' + '0'+i +':'+ '0'+ j;
                        }
                    }
                    else {
                        strTimes += ',' + '0'+i +':'+  j;
                    }
                }
                else {
                    if ( j < 10) {
                        strTimes += ',' + i +':'+ '0'+ j;
                    }
                    else {
                        strTimes += ',' + i +':' + j ;
                    }
                    
                }
            }
        }
        
        for(String sb : strTimes.split(',')){
            lstSupplier1.add(new picklistValues(sb,sb));
        }
        
        //Load Templated for Itinerary Text
        Map<String,List<Email_Template__c>> mapTextTemplateWC = new Map<String,List<Email_Template__c>>();
        Map<String,String> mapTextTemplate = new Map<String,String>();
        for(Email_Template__c ETemp : [Select Id,ET_Condition__c,ET_Page_Section__c,ET_Email_Intro__c,ET_Email_Closing__c from Email_Template__c where recordType.DeveloperName = 'Print_Template' and (ET_User__c = :userInfo.getUserId() or ET_User__c = null)]){
            String body = '';
            if(ETemp.ET_Email_Intro__c != null)
                body = ETemp.ET_Email_Intro__c;
            if(ETemp.ET_Email_Closing__c != null)
                body = body+'<br/>'+ETemp.ET_Email_Closing__c;
            if(!mapTextTemplateWC.containsKey(ETemp.ET_Page_Section__c)){
                mapTextTemplateWC.put(ETemp.ET_Page_Section__c, new List<Email_Template__c>());    
            }
            mapTextTemplateWC.get(ETemp.ET_Page_Section__c).add(ETemp);    
            mapTextTemplate.put(ETemp.ET_Page_Section__c,body);
        }
        for(Holiday_Type__c ht : [Select Id,Name from Holiday_Type__c where HT_HE__c = true]){
            lstHolidayTypes.add(new picklistValues(ht.Id,ht.Name));
        }
        
        //Load None Liceancable Cost
        List<None_Licenseable_Protection_Cost__c> lstNLP = [Select id, NLPC_High_Band__c, NLPC_Low_Band__c, NLPC_Premium_PP__c 
                                    from  None_Licenseable_Protection_Cost__c];
        
        //Supplier Payment done or not
        List<picklistValues> mapSupplierPay  = new List<picklistValues>();
        Map<String,Set<String>> mapSBSupplierPay = new Map<String,Set<String>>();
        List<String> lstSBP = new List<String>();
        for(Supplier_Payment__c sp : [Select Id, SP_Supplier__c, SBP_Supplier_Cost_Currency_Value__c from Supplier_Payment__c where SBP_Supplier_Cost_Currency_Value__r.SCP_Opportunity__c = :oppId]){
            mapSupplierPay.add(new picklistValues(sp.SP_Supplier__c,sp.SP_Supplier__c));
            lstSBP.add(sp.SBP_Supplier_Cost_Currency_Value__c);
        }
        for(Supplier_Cost_Payment__c scp : [Select Id,SCP_Supplier__c,(Select Id,SC_Supplier_Booking__c from Supplier_Costs__r) from 
                Supplier_Cost_Payment__c where Id in : lstSBP]){
            If(!mapSBSupplierPay.containsKey(scp.SCP_Supplier__c)){
                mapSBSupplierPay.put(scp.SCP_Supplier__c, new Set<String>());
            }
            for(Supplier_Cost__c sc : scp.Supplier_Costs__r){
                mapSBSupplierPay.get(scp.SCP_Supplier__c).add(sc.SC_Supplier_Booking__c);
            }
        }
        
        //Supplier Booking Field Sets
        fieldSets = JSON.serialize(Utility.readFieldSet(nameSpacePrefix+'Supplier_Booking__c'));
        holidayType = JSON.serialize(lstHolidayTypes);
        noneLicenceableTable  = JSON.serialize(lstNLP);
        autoSuggestTerminal = JSON.serialize(lstTerminals);
        autoSuggestClass = JSON.serialize(lstClass);
        itineraryTextTemplate = JSON.serialize(mapTextTemplate);
        itineraryTextTemplateWC =  JSON.serialize(mapTextTemplateWC);
        autoSuggestTime  = JSON.serialize(lstSupplier1);
        autoSuggestSupplier  = JSON.serialize(lstSuppliers);
        autoSuggestWhereToGo = JSON.serialize(lstWhereToGo);
        autoSuggestRoom = JSON.serialize(mapRoomTypes);
        autoSuggestAirport = JSON.serialize(lstAirport);
        mapSupplierPayment = JSON.serialize(mapSupplierPay);
        mapSBSupplierPayment = JSON.serialize(mapSBSupplierPay);
        widgetyReferences = JSON.serialize(mapSupplierWidgetyReference);
        //HEPageErrorMessage = '[]';
        Map<String,String> mapError = ErrorMessageController.getErrorMessage('ItineraryBuilder');
        Map<String,String> mapErrorHE = ErrorMessageController.getErrorMessage('HolidayEnquiry');
        mapError.putAll(mapErrorHE);
        HEPageErrorMessage = JSON.serialize(mapError);
    }
    
    
    public string getData(){  
       String oppId = ApexPages.currentPage().getParameters().get('id');
       List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
       if(oppId != ''){
            lstSupplierBooking =  SOQLServices.getSupplierBookings(oppId);
        }
        Integer sbCount = lstSupplierBooking.size();
        if(sbCount < 10 ){
            for(Integer i=1; i<=10-sbCount; i++){
                lstSupplierBooking.add(new Supplier_Booking__c(SB_Opportunity__c = oppId, SB_Order__c = i+sbCount-1,SB_Is_Standard__c = true));    
            }
        }
        return JSON.serialize(lstSupplierBooking);
    } 
    
    public void refresh(){
        
    }
    
    @remoteAction
    public static  void includeFlightMargin(Boolean  flightMargin, String oppId){
        try{
            Opportunity opp = [Select Id,O_Include_Flight_Margin__c from Opportunity where Id = :oppId];
            opp.O_Include_Flight_Margin__c = flightMargin;
            update opp; 
        }
        Catch(Exception e){
            System.assert(false,e.getMessage());
        }
    }
    
    @remoteAction
    public static  Boolean saveGroupMembers(String  gmJSON){
        List<Group_Member__c> lstGMs = (List<Group_Member__c>)JSON.deserialize(gmJSON, List<Group_Member__c>.class);
        Savepoint sp = Database.setSavepoint();
        try{
            update lstGMs;
            return false;
        }
        Catch(Exception e){
            Database.rollback(sp);
            System.assert(false,e.getMessage());
            return true;
        }
    }
    
    @remoteAction
    public static String getSupplierBookings(String oppId){
       
       List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
       if(oppId != ''){
            lstSupplierBooking =  SOQLServices.getSupplierBookings(oppId);
        }
        Map<String,String> mapRecordType = new Map<String,String>();
        for(RecordType  rt : [Select Id, name,developerName from RecordType where developerName in ('Int_Flight', 'Accommodation', 'Transfer') and SobjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c']){
            mapRecordType.put(rt.developerName, rt.Id);
        }
        Integer sbCount = lstSupplierBooking.size();
        if(sbCount < 10 ){
            for(Integer i=1;i<=10-sbCount; i++){
                Integer sbOrder = (i+sbCount)-1;
                Supplier_Booking__c sb = new Supplier_Booking__c(SB_Opportunity__c = oppId, recordTypeId = null, SB_Order__c = sbOrder,SB_Is_Standard__c = true);
                if(sbCount == 0 && i==1 && mapRecordType.containsKey('Int_Flight')){
                    sb.recordTypeId =  mapRecordType.get('Int_Flight');   
                    sb.SB_Day__c = 1;
                    sb.SB_Duration__c = 0;
                }
                else if(sbCount == 0 && i==3 && mapRecordType.containsKey('Accommodation')){
                    sb.recordTypeId =  mapRecordType.get('Accommodation');   
                    sb.SB_Day__c = 1;
                }
                else if(sbCount == 0 && i==2 && mapRecordType.containsKey('Transfer')){
                    sb.recordTypeId =  mapRecordType.get('Transfer');   
                    sb.SB_Day__c = 1;
                    sb.SB_Duration__c = 0;
                }
                lstSupplierBooking.add(sb);    
            }
        }
        return JSON.serialize(lstSupplierBooking);
    }
    
    @remoteAction
    public static String deleteSB(String SBId){
        try{
            List<Supplier_Cost__c> lstCost = [Select Id,SC_Supplier_Cost_Payment__c,SC_Supplier_Cost_Payment__r.SCP_Total_Payment__c from Supplier_Cost__c where SC_Supplier_Booking__c =:SBId];
            
            if(lstCost.size()== 0 || (lstCost.size() > 0 && lstCost[0].SC_Supplier_Cost_Payment__r.SCP_Total_Payment__c == 0)){
                Delete [Select Id from Supplier_Booking__c where Id =:SBId];
                return 'Success';
            }
            else{
                return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Cant_Delete_Supplier_Cost');
            }
        }
        Catch(Exception e){
            return e.getMessage();
        }
    }
    @remoteAction
    public static List<Supplier_Booking__c> saveOrder(String lstSB,String oppId){
        try{
            List<Supplier_Booking__c> lstSBs = (List<Supplier_Booking__c>)JSON.deserialize(lstSB,List<Supplier_Booking__c>.class);
            List<Supplier_Booking__c> lstUpdateSB  = new List<Supplier_Booking__c>();
            for(Supplier_Booking__c SB : lstSBs){
                if(sb.RecordTypeId != null){
                    lstUpdateSB.add(sb);
                }
            }
            upsert lstUpdateSB;
            List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
            if(oppId != ''){
                lstSupplierBooking =  SOQLServices.getSupplierBookings(oppId);
            }
            Integer sbCount = lstSupplierBooking.size();
            if(sbCount < 10 ){
                for(Integer i=1;i<=10-sbCount; i++){
                    lstSupplierBooking.add(new Supplier_Booking__c(SB_Opportunity__c = oppId, SB_Order__c = i+sbCount-1));    
                }
            }
            return lstSupplierBooking;
        }
        Catch(Exception e){
            System.assert(false,e.getMessage());
            return null;
        }
    }
    
    @remoteAction
    public static List<Supplier_Booking__c> saveSB(String lstSB,String oppId){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Supplier_Booking__c> lstSBs = (List<Supplier_Booking__c>)JSON.deserialize(lstSB,List<Supplier_Booking__c>.class);
            List<Supplier_Booking__c> lstUpdateSB  = new List<Supplier_Booking__c>();
            for(Supplier_Booking__c SB : lstSBs){
                if(sb.RecordTypeId != null){
                    lstUpdateSB.add(sb);
                }
            }
            upsert lstUpdateSB;
        }
        Catch(Exception e){
            Database.rollback(sp);
            System.assert(false,e.getMessage());
        }
        List<Supplier_Booking__c> lstSupplierBooking = new List<Supplier_Booking__c>();
        
        if(oppId != ''){
            lstSupplierBooking =  SOQLServices.getSupplierBookings(oppId);
        }
        Integer sbCount = lstSupplierBooking.size();
        if(sbCount < 10 ){
            for(Integer i=1;i<=10-sbCount; i++){
                lstSupplierBooking.add(new Supplier_Booking__c(SB_Opportunity__c = oppId, SB_Order__c = i+sbCount-1));    
            }
        }
        return lstSupplierBooking;
    }
    
    @remoteAction
    public static String deleteSupplierCost(String costId){
        try{
            if(costId != null && costId != ''){
                List<Supplier_Cost__c> lstCost = [Select Id from Supplier_Cost__c where Id = :costId.trim() and (SC_Supplier_Cost_Payment__r.SCP_Total_Payment__c = 0 OR SC_Supplier_Cost_Payment__c = null)];
                if(lstCost.size()>0){
                    delete lstCost;
                    return 'Success';
                }
                else{
                    return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Cant_Delete_Supplier_Cost');   
                }
            }
            else{
                return null;
            }
        }
        Catch(Exception e){
            return e.getMessage();
        }
    }
    
    //Notes Opportunity 
    @remoteAction
    public static string saveOpportunityNOtes(String oppId, String Note_Interna,String Other_Invoice_Comments,String Additional_Reps){
        try{
            Opportunity opp = new Opportunity(Id = oppId);
            opp.O_Booking_Note_Internal__c = Note_Interna;
            opp.O_Other_Invoice_Comments__c = Other_Invoice_Comments;
            opp.O_Additional_Reps_Agents_Arrival_report__c = Additional_Reps;
            update opp;
        }
        Catch(Exception e){
            System.assert(false,e.getMessage());
            return null;
        }
        return null;
    }
    
    //Save Opportunity 
    @remoteAction
    public static string saveOpportunity(String OppStr){
        try{
            Opportunity opp = (Opportunity)JSON.deserialize(OppStr,Opportunity.class);
            List<Opportunity> lstOpp = [Select Id,StageName,(Select Id,Name from Client_Groups__r),
                                        (Select Id,TC_Country__r.Name from Travelling_Countries__r) from Opportunity where Id =: opp.Id];
            opp.StageName = lstOpp[0].StageName;
            opp = ItineraryBuilderController.updateOppName(lstOpp[0],opp);
            update opp;
            return JSON.serialize(SOQLServices.getOpportunities(new Set<String>{opp.Id})[0]);   
        }
        Catch(Exception e){
            System.assert(false,e.getMessage());
            return null;
        }
    }
    
    static Opportunity updateOppName(Opportunity oldOpp,Opportunity opp){
        if(oldOpp.Client_Groups__r.size() == 1){
            opp.Name = oldOpp.Client_Groups__r[0].name;
        }
        else{
            opp.Name = '';
        }
        
        if(oldOpp.Travelling_Countries__r.size() > 0){
            if(opp.Name != ''){
                opp.Name += ' - ';
            }
            for(Travelling_Country__c country : oldOpp.Travelling_Countries__r){
                opp.Name += country.TC_Country__r.Name+',';
            }
            opp.Name = opp.Name.removeEnd(',');
        }
        opp.Name += ': '+ datetime.newinstance(opp.O_Departure_Date__c.year(), opp.O_Departure_Date__c.month(), opp.O_Departure_Date__c.day()).format('dd.MM.yyyy')+' - '+datetime.newinstance(opp.O_Return_Date__c.year(), opp.O_Return_Date__c.month(), opp.O_Return_Date__c.day()).format('dd.MM.yyyy');
        return opp;
    }
    
    @remoteAction
    public static Supplier_Booking__c savePopupSB(String singleSB, String oppId, String rtName, String costString, Map<String,List<FlightMembers>> lstflightMembers){
        Savepoint sp = Database.setSavepoint();
        try{
            Supplier_Booking__c supplierBooking = (Supplier_Booking__c)JSON.deserialize(singleSB,Supplier_Booking__c.class);
            //Logic for Room Type, Occupancy, Meal Basis predictive text
            if(rtName == 'Accommodation'){
                if(supplierBooking.SB_Room_Type__c != null && supplierBooking.SB_Supplier__c != null){
                    List<Room_Type__c> lstRoomType = [Select Id from Room_Type__c where RT_Name__c = :supplierBooking.SB_Room_Type__c And RT_Supplier__c = :supplierBooking.SB_Supplier__c];
                    if(lstRoomType.size() == 0 ){
                        insert new Room_Type__c(RT_Name__c = supplierBooking.SB_Room_Type__c, RT_Supplier__c = supplierBooking.SB_Supplier__c, RT_Field_Name__c = 'Room Type');
                    }
                }
                if(supplierBooking.SB_Meal_Basis__c != null && supplierBooking.SB_Supplier__c != null){
                    List<Room_Type__c> lstRoomType = [Select Id from Room_Type__c where RT_Name__c = :supplierBooking.SB_Meal_Basis__c And RT_Supplier__c = :supplierBooking.SB_Supplier__c];
                    if(lstRoomType.size() == 0 ){
                        insert new Room_Type__c(RT_Name__c = supplierBooking.SB_Meal_Basis__c, RT_Supplier__c = supplierBooking.SB_Supplier__c, RT_Field_Name__c = 'Meal Basis');
                    }
                }
                if(supplierBooking.SB_Occupancy__c != null && supplierBooking.SB_Supplier__c != null){
                    List<Room_Type__c> lstRoomType = [Select Id from Room_Type__c where RT_Name__c = :supplierBooking.SB_Occupancy__c And RT_Supplier__c = :supplierBooking.SB_Supplier__c];
                    if(lstRoomType.size() == 0 ){
                        insert new Room_Type__c(RT_Name__c = supplierBooking.SB_Occupancy__c, RT_Supplier__c = supplierBooking.SB_Supplier__c, RT_Field_Name__c = 'Occupancy');
                    }
                }
            }
            else if((rtName == 'Int Flight' || rtName == 'Dom Flights' || rtName == 'Light Aircraft')){  //Logic to save Airport Terminals
                if((supplierBooking.SB_Arrival_Terminal__c != null || supplierBooking.SB_Departure_Terminal__c != null)){        
                    if(supplierBooking.SB_Arrival_Terminal__c != null){
                        List<Airport__c> airport = [Select ID, name from Airport__c where Id = :supplierBooking.SB_Arrival_Airport_l__c];
                        List<Airport_Terminal__c> lstAT = [Select ID, name from Airport_Terminal__c where name = :supplierBooking.SB_Arrival_Terminal__c];
                        if(lstAT.size() == 0 && airport.size() > 0){
                            insert new Airport_Terminal__c(AT_Airport__c=airport[0].Id, Name=supplierBooking.SB_Arrival_Terminal__c);
                        }
                    }
                    if(supplierBooking.SB_Departure_Terminal__c != null){
                        List<Airport__c> airport = [Select ID, name from Airport__c where Id = :supplierBooking.SB_Departure_Airport_l__c];
                        List<Airport_Terminal__c> lstAT = [Select ID, name from Airport_Terminal__c where name = :supplierBooking.SB_Departure_Terminal__c];
                        if(lstAT.size() == 0 && airport.size() > 0){
                            insert new Airport_Terminal__c(AT_Airport__c=airport[0].Id, Name=supplierBooking.SB_Departure_Terminal__c);
                        }
                    }
                }
                if(supplierBooking.SB_Class__c != null && supplierBooking.SB_Carrier__c != null){
                    List<Airport_Terminal__c> lstClass = [Select Id from Airport_Terminal__c where AT_Carrier_Name__c = :supplierBooking.SB_Carrier__c AND AT_Class__c = :supplierBooking.SB_Class__c];
                    if(lstClass.size() == 0){
                        insert new Airport_Terminal__c(Name = 'Carrier-'+supplierBooking.SB_Carrier__c, AT_Class__c = supplierBooking.SB_Class__c, AT_Carrier_Name__c = supplierBooking.SB_Carrier__c);
                    }
                } 
            }
            
            
            upsert supplierBooking;
            
            
            //Supplier Cost 
            if(!supplierBooking.SB_Own_Arrangement__c){
                List<SupplierCostWrapper> lstCostWrapper = (List<SupplierCostWrapper>)JSON.deserialize(costString,List<SupplierCostWrapper>.class);
                
                List<Supplier_Cost__c> lstSupplierCost = new List<Supplier_Cost__c>();
                for(SupplierCostWrapper scw : lstCostWrapper){
                    for(Supplier_Cost__c sc : scw.lstSupplierCost){
                        if(scw.selectedClient != null && sc.currencyISOCode != null && sc.SC_Total_Net_Cost_PP__c != null && sc.SC_Total_Client_Group_Cost__c != null && sc.SC_Total_Client_Group_Cost__c != 0){
                            sc.SC_Client_Group__c = scw.selectedClient;
                            if(sc.SC_Supplier_Booking__c == null){
                                sc.SC_Supplier_Booking__c = supplierBooking.Id;
                            }
                            
                            lstSupplierCost.add(sc);
                        }
                    }
                }
                upsert lstSupplierCost;
            }
            else{ //Delete Supplier Cost In case of Own Arrangment
                delete [Select Id from Supplier_Cost__c where SC_Supplier_Booking__c  = : supplierBooking.Id];
            }
            
            //Flight Members
            List<Flight_Booking__c> lstFB = new List<Flight_Booking__c>();
            List<Flight_Booking__c> lstFBDeleteable = new List<Flight_Booking__c>();
            for(List<FlightMembers> lstwrapper : lstflightMembers.values()){
                for(FlightMembers fb : lstwrapper){
                    if(fb.isSelected){
                        lstFB.add(fb.fb);
                    }
                    else if(fb.fb.Id != null){
                        lstFBDeleteable.add(fb.fb);
                    }
                    
                    if(fb.fb.Id == null){
                        fb.fb.FB_Supplier_Booking__c = supplierBooking.Id;
                    }
                }
            }
            upsert lstFB;
            delete lstFBDeleteable;
            
            return SOQLServices.getOneSupplierBookings(supplierBooking.Id)[0];
        }
        Catch(Exception e){
             Database.rollback(sp);
            System.assert(false,e.getMessage()+'Line ##'+e.getStackTraceString());
            return null;
        }
    }
    
    //Load Itinerary Description
    @remoteAction
    public static String loadItineraryDescription(String singleSB, String rtName, List<String> travellingCountries, String holidayTypeId){
        Supplier_Booking__c sb = (Supplier_Booking__c)JSON.deserialize(singleSB,Supplier_Booking__c.class);
        ItineraryDescription descriptionWrapper = new ItineraryDescription();
        if(rtName == 'Transfer' || rtName == 'Car Hire'){
             List<Transfer_Option__c> lstTransferOption = new List<Transfer_Option__c>();
             if(sb.SB_From_Place__c != null){
                 lstTransferOption = [Select Id,name,TO_Where_to_go__c,TO_Description__c,TO_Airport__c,TO_Supplier__c,TO_Where_to_go__r.name 
                                             from Transfer_Option__c where (TO_Where_to_go__r.Name = :sb.SB_From_Place__c OR TO_Airport__r.Name = :sb.SB_From_Place__c) and TO_Archive__c = false  order by name];
             }  
             //System.assert(false,sb.SB_Supplier__c);  
             if(sb.SB_Supplier__c != null){
                     lstTransferOption.addAll([Select Id,name,TO_Description__c,TO_Where_to_go__c,TO_Airport__c,TO_Supplier__c,TO_Where_to_go__r.name 
                                             from Transfer_Option__c where TO_Supplier__c = :sb.SB_Supplier__c  and TO_Archive__c = false order by name]);
             }
             for (Transfer_Option__c tc : lstTransferOption) {
                 descriptionWrapper.lstOptions.add(new picklistValues(tc.Id, tc.Name));
                 descriptionWrapper.mapDescriptions.put(tc.Id,tc.TO_Description__c);
             }
        }
        else if(rtName == 'Excursion' || rtName == 'Days at Leisure'){
            Set<String> setActIds  = new Set<String>();
            for(Activity__c act : [select id, Name  from Activity__c where WH_Where_to_go__r.W_Country__r.Name in :travellingCountries and WH_Where_to_go__c = : sb.SB_Where_to_go__c]){
                descriptionWrapper.lstOptions.add(new picklistValues(act.Id, act.Name));
                setActIds.add(act.Id);
            }
            For(Itinerary_Text__c it :[Select Id,IT_What_to_do__c,IT_Message__c from Itinerary_Text__c
                                    where (IT_Status__c='approved' OR IT_Status__c ='submitted') and IT_Holiday_Type__c =:holidayTypeId  
                                    AND IT_What_to_do__c in : setActIds]){
                 descriptionWrapper.mapDescriptions.put(it.IT_What_to_do__c,it.IT_Message__c);
            }   
            For(Itinerary_Text__c it :[Select Id,IT_What_to_do__c,IT_Message__c from Itinerary_Text__c
                                    where (IT_Status__c='approved' OR IT_Status__c ='submitted') and IT_Holiday_Type__r.Name = 'Generic'
                                    AND IT_What_to_do__c in : setActIds and IT_What_to_do__c not in : descriptionWrapper.mapDescriptions.keySet()]){
                 descriptionWrapper.mapDescriptions.put(it.IT_What_to_do__c,it.IT_Message__c);
            } 
            //Days at Leisure where to go and supplier text
            if(rtName == 'Days at Leisure'){
                For(Itinerary_Text__c it :[Select Id,IT_What_to_do__c,IT_Where_to_go__c,IT_Supplier__c,IT_Message__c from Itinerary_Text__c
                                        where (IT_Status__c='approved' OR IT_Status__c ='submitted') and IT_Holiday_Type__c =:holidayTypeId  
                                        AND ((IT_Where_to_go__c = :sb.SB_Where_to_go__c And IT_Where_to_go__c != null) OR (IT_Supplier__c = :sb.SB_Supplier__c And IT_Supplier__c!= null)) ]){
                     if(it.IT_Where_to_go__c != null){
                         descriptionWrapper.mapDescriptions.put(it.IT_Where_to_go__c,it.IT_Message__c);
                     }
                     else{
                         descriptionWrapper.mapDescriptions.put(it.IT_Supplier__c,it.IT_Message__c);
                     }
                }   
                For(Itinerary_Text__c it :[Select Id,IT_What_to_do__c,IT_Where_to_go__c,IT_Supplier__c,IT_Message__c from Itinerary_Text__c
                                        where (IT_Status__c='approved' OR IT_Status__c ='submitted') and IT_Holiday_Type__r.Name = 'Generic'
                                        AND ((IT_Where_to_go__c = :sb.SB_Where_to_go__c And IT_Where_to_go__c != null) OR (IT_Supplier__c = :sb.SB_Supplier__c And IT_Supplier__c!= null)) ]){
                     if(it.IT_Where_to_go__c != null && !descriptionWrapper.mapDescriptions.containskey(it.IT_Where_to_go__c)){
                         descriptionWrapper.mapDescriptions.put(it.IT_Where_to_go__c,it.IT_Message__c);
                     }
                     else if(it.IT_Supplier__c != null &&  !descriptionWrapper.mapDescriptions.containskey(it.IT_Supplier__c)){
                         descriptionWrapper.mapDescriptions.put(it.IT_Supplier__c,it.IT_Message__c);
                     }
                }        
            }
        }
        
        return JSON.serialize(descriptionWrapper);
    }
    
    @remoteAction //*** Save Itinerary Text As Template ***//
    public static String saveAsTemplate(String SBText, String parent,String iText, String selectedHT, Boolean transferOption){
        try{
            Supplier_Booking__c sb = (Supplier_Booking__c)JSON.deserialize(SBText,Supplier_Booking__c.class);
            if(selectedHT != '' && parent != '' && selectedHT != 'undefined' && parent != 'undefined' && !transferOption || (selectedHT != 'undefined' && parent != 'undefined' && transferOption && sb.SB_Supplier__c == parent)){
                Itinerary_Text__c objQT = new Itinerary_Text__c() ;
                String existingITId;
                Boolean alreadyApproved = false;
                
                for(Itinerary_Text__c it : [Select Id,IT_Country__c,IT_Status__c,LastModifiedDate ,IT_Supplier__c,IT_Message__c, 
                    IT_Holiday_Type__c,IT_What_to_do__c,IT_Where_to_go__c, IT_Hotel__c from Itinerary_Text__c where 
                    IT_Holiday_Type__c = :selectedHT AND (IT_Where_To_Go__c = :parent OR IT_What_To_Do__c = :parent OR IT_Supplier__c = :parent) AND (IT_Status__c = 'Approved' OR IT_Status__c = 'Under Review') Limit 1]){
                    if(it.IT_Status__c !='approved' &&  it.IT_Status__c !='submitted')
                        objQT.id  = it.Id ;
                    else{
                        alreadyApproved = true;    
                    }
                }
                
                if(alreadyApproved){
                    String msg = ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Cant_Overwrite_Existing_Itinerary_Text');
                    return JSON.serialize(msg);
                }
                else{
                    if(objQT.id == null && sb.SB_What_to_do__c == parent){
                        objQT.IT_What_to_do__c = sb.SB_What_to_do__c;
                    }
                    
                    if(objQT.id == null && sb.SB_Where_to_go__c  == parent){
                        objQT.IT_Where_to_go__c = sb.SB_Where_to_go__c; 
                    }
                    
                    if(objQT.id == null && sb.SB_Supplier__c == parent){
                        objQT.IT_Supplier__c = sb.SB_Supplier__c;
                    }
                    
                    objQT.IT_Message__c =  iText;
                    objQT.IT_Holiday_Type__c = selectedHT;
                    objQT.IT_Status__c = 'Under Review' ;
                    upsert objQT ;
                    return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Itinerary_Text_Created');
                }
            }
            else if(transferOption && sb.SB_Supplier__c != parent){
                List<Airport__c> lstAirports = [Select Id,Name from Airport__c where Id = :parent limit 1];
                if(lstAirports.size() > 0){
                    String Name = sb.SB_From_Place__c;
                    if(sb.SB_To_Place__c != null){
                        Name = Name +' to '+sb.SB_To_Place__c;
                    }
                    Transfer_Option__c to = new Transfer_Option__c(TO_Airport__c = lstAirports[0].Id, 
                    TO_Description__c = iText, Name = Name);
                    insert to;
                    return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Transfer_Option_Created');
                }
                else{
                    Transfer_Option__c to = new Transfer_Option__c(TO_Description__c = iText);
                    String Name = '';
                    
                    if(sb.SB_What_to_do__c == parent){
                        to.TO_What_to_do__c = sb.SB_What_to_do__c;
                        List<Activity__c> lstAct = [Select Id, Name from Activity__c where Id = : sb.SB_What_to_do__c];
                        if(lstAct.size() > 0){
                            Name = lstAct[0].Name +' to '+sb.SB_To_Place__c;
                        }
                    }
                    
                    if(sb.SB_Where_to_go__c  == parent){
                        to.TO_Where_to_go__c = sb.SB_Where_to_go__c; 
                        List<Where_to_go__c> lstAct = [Select Id, Name from Where_to_go__c where Id = : sb.SB_Where_to_go__c];
                        if(lstAct.size() > 0){
                            Name = lstAct[0].Name +' to '+sb.SB_To_Place__c;
                        }
                    }
                    
                    to.Name = Name ;
                    insert to;
                    return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Transfer_Option_Created');
                }
                
            } 
        }
        Catch(Exception e){
            System.assert(false,e.getMessage()+e.getStackTraceString());
        }
        return null;
    }
    
    /*
    @remoteAction
    public static String getPicklistValues(String objtype, String fieldName) {
        Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry plv : pickListValues) {
            options.add(new SelectOption(plv.getValue(),plv.getLabel()));
        }
        return JSON.serialize(options);
    } 
    */
    
    public String getRecordType() {
        List<picklistValues> options = new List<picklistValues >();
        options.add(new picklistValues('','--Select--'));
        mapRecordtype = new Map<String,String>();
        for (recordType  obj : [Select Id,Name from recordType where SobjectType = :Utility.getNameSpacePrefix()+'Supplier_Booking__c']) {
            options.add(new picklistValues(obj.Id,obj.Name));
            mapRecordtype.put(obj.Id,obj.Name);
        }
        StrRecordtype = JSON.serialize(mapRecordtype);
        return JSON.serialize(options);
    }
    
     //Fetch all the IB Page Messages
    public String getIBPageMessages(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('ItineraryBuilder'));
    }
    
    
    //*** Get Supplier Cost for popup ***//
    @remoteAction
    public static List<SupplierCostWrapper> getSupplierCost(String SBID, String OppId){
        List<SupplierCostWrapper> lstSCWrapper = new List<SupplierCostWrapper>();
        Map<String,List<Supplier_Cost__c>> mapSupplierCost = new Map<String,List<Supplier_Cost__c>>();
        if(SBID != '' && SBID != null){
            for(Supplier_Cost__c sc : [Select ID,SC_Margin_Type__c,SC_Margin_Value__c,SC_Client_Group__c,SC_Supplier_Booking__c,SC_Cost__c,SC_Description__c, currencyISOCode,
                                     SC_Exchange_Rate_Lookup__c, SC_Margin__c, SC_Nights__c, SC_Occupancy_No__c, SC_Occupancy_Type__c, SC_Option__c, 
                                     SC_Shared_Cost_Per_Night__c, SC_Supplier_Cost_Payment__c, SC_Total_Client_Group_Cost__c, SC_Total_Net_Cost_PP__c, 
                                      SC_Type__c,SC_Selected__c from Supplier_Cost__c where SC_Supplier_Booking__c = :SBID order by createdDate]){
                if(!mapSupplierCost.containsKey(sc.SC_Client_Group__c)){
                    mapSupplierCost.put(sc.SC_Client_Group__c, new List<Supplier_Cost__c>());
                }
                mapSupplierCost.get(sc.SC_Client_Group__c).add(sc);
            }
            for(String cId : mapSupplierCost.keySet()){
                SupplierCostWrapper scw = new SupplierCostWrapper(OppId);
                scw.selectedClient = cId;
                scw.lstSupplierCost.addAll(mapSupplierCost.get(cId));
                lstSCWrapper.add(scw);
            }
        }
        if(lstSCWrapper.size() == 0){
            SupplierCostWrapper scw = new SupplierCostWrapper(OppId);
            if(scw.mapClientGroup.size() == 1){
                if(scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Adult_Members__c != 0 && scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Adult_Members__c != null){
                    scw.lstSupplierCost.add(new Supplier_Cost__c(SC_Option__c = '1', SC_Selected__c = true, SC_Occupancy_No__c = scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Adult_Members__c, sc_occupancy_type__c = 'Adult'));
                }
                if(scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Child_Members__c != 0 && scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Child_Members__c != null){
                    scw.lstSupplierCost.add(new Supplier_Cost__c(SC_Option__c = '1', SC_Selected__c = true, SC_Occupancy_No__c = scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Child_Members__c, sc_occupancy_type__c = 'Child'));    
                }
                if(scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Infant_Members__c != 0 && scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Infant_Members__c != null){
                    scw.lstSupplierCost.add(new Supplier_Cost__c(SC_Option__c = '1', SC_Selected__c = true, SC_Occupancy_No__c = scw.mapClientGroup.get(scw.lstClients[0].value).CG_Total_Infant_Members__c, sc_occupancy_type__c = 'Infant'));    
                }
            }
            else{
                //scw.lstSupplierCost.add(new Supplier_Cost__c(SC_Option__c = '1', SC_Selected__c = true));
            }
            lstSCWrapper.add(scw);
        }
        return lstSCWrapper;         
    }
    
    
    @remoteAction
    public static Map<String,List<FlightMembers>> getFlightMembers(String SBID, String OppId){
        
        Map<String,List<FlightMembers>> mapFlightMembers = new Map<String,List<FlightMembers>>();
        List<String> lstAlreadyExistGm = new List<String>();
        if(SBID != '' && SBID != null){
            for(Flight_Booking__c fb : [Select Id,FB_Group_Member__c,FB_Group_Member__r.GM_Client_Group__c,FB_Seat_No__c,
                                            FB_Group_Member__r.GM_Client_Group__r.Name, FB_Group_Member__r.GM_Name__c, FB_Group_Member__r.GM_Lead_Passenger__c
                                         from Flight_Booking__c where FB_Supplier_Booking__c = :SBID order by FB_Group_Member__r.GM_Name__c]){
                lstAlreadyExistGm.add(fb.FB_Group_Member__c);
                if(!mapFlightMembers.containsKey(fb.FB_Group_Member__r.GM_Client_Group__c+'##'+fb.FB_Group_Member__r.GM_Client_Group__r.Name)){
                    mapFlightMembers.put(fb.FB_Group_Member__r.GM_Client_Group__c+'##'+fb.FB_Group_Member__r.GM_Client_Group__r.Name, new List<FlightMembers>());
                }
                mapFlightMembers.get(fb.FB_Group_Member__r.GM_Client_Group__c+'##'+fb.FB_Group_Member__r.GM_Client_Group__r.Name).add(new FlightMembers(fb.FB_Group_Member__r.GM_Name__c,fb.FB_Group_Member__r.GM_Lead_Passenger__c,fb,true));
            }   
        }
        for(Group_Member__c gm : [Select Id,GM_Client_Group__c,GM_Client_Group__r.Name, GM_Name__c, GM_Lead_Passenger__c
                                     from Group_Member__c where GM_Opportunity__c = :OppId and Id not in :lstAlreadyExistGm order by GM_Name__c]){
            if(!mapFlightMembers.containsKey(gm.GM_Client_Group__c+'##'+gm.GM_Client_Group__r.Name)){
                mapFlightMembers.put(gm.GM_Client_Group__c+'##'+gm.GM_Client_Group__r.Name, new List<FlightMembers>());
            }
            mapFlightMembers.get(gm.GM_Client_Group__c+'##'+gm.GM_Client_Group__r.Name).add(new FlightMembers(gm.GM_Name__c, gm.GM_Lead_Passenger__c, new Flight_Booking__c(FB_Group_Member__c = gm.Id),false));
        }  
        
        return mapFlightMembers;             
    }
    
    @remoteAction
    public static Decimal getTotalCMemo(String OppId, String SID){
        
        Decimal totalCMemo = 0;
        for(Supplier_Cost__c sc : [Select id, SC_MarkUp_Cost_for_Selling_Price__c from Supplier_Cost__c where 
                                  SC_Supplier_Booking__r.SB_Opportunity__c = :OppId and  SC_Supplier_Booking__c != :SID and SC_Supplier_Booking__r.RecordType.Name = 'Credit Memo']){
            totalCMemo += sc.SC_MarkUp_Cost_for_Selling_Price__c;
        }
        return totalCMemo;             
    }
    
    //Save Cost margin client group
    @remoteAction
    public static String saveCost(Opportunity OppStr, List<SBCostWrapperByCG> clientStr){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Opportunity> lstOpp = [Select Id,StageName from Opportunity where Id =: OppStr.Id];
            OppStr.StageName = lstOpp[0].StageName;
            update OppStr;
            List<Client_Group__c> lstClientGroup = new List<Client_Group__c>();
            for(SBCostWrapperByCG scg : clientStr){
                lstClientGroup.add(scg.cg);
            }
            update lstClientGroup;
            return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Records_Updated_Success');
        }
        catch(Exception e){
            Database.rollback(sp);
            return e.getMessage();
        }
    }
    
    //***To get Supplier Cost Group By Supplier ****//
    @remoteAction
    public static List<SBCostWrapperBySupplier> getSupplierCostBySupplier(String OppId){
        List<SBCostWrapperBySupplier> lstSBWrapperPv = new List<SBCostWrapperBySupplier>();
        List<Opportunity> lstOpp = [Select Id,O_Target_Mark_Up_Value__c from Opportunity where Id = :OppId];
        if(lstOpp.size() > 0 && lstOpp[0].O_Target_Mark_Up_Value__c == null){
            System.assert(false,'Target Mark-up not available, please contact to system admin.');
        }
        for(Supplier_Cost_Payment__c scp : [Select Id, SCP_Supplier__r.Name,SCP_Opportunity__r.currencyISOCode,
                                    SCP_Exchange_Rate__c, SCP_Exchange_Rate__r.ER_Exchange_Rate__c, SCP_Is_Agent__c, SCP_Opportunity__c, 
                                    SCP_Outstanding_Amount__c, SCP_Supplier__c, SCP_Total__c, SCP_Total_Payment__c,
                                    (Select Id, SC_Description__c, SC_Cost__c, SC_Nights__c, SC_Client_Group__c, SC_Type__c,
                                    SC_Total_Net_Cost_PP__c, SC_Total_Client_Group_Cost__c, currencyIsoCode, SC_Shared_Cost_Per_Night__c, 
                                    SC_Occupancy_Type__c,SC_Occupancy_No__c,IsDeleted,SC_Margin__c,SC_MarkUp_Cost_for_Selling_Price__c 
                                    from Supplier_Costs__r where SC_Selected__c = true) from Supplier_Cost_Payment__c where SCP_Opportunity__c = :oppId order by SCP_Supplier__r.Name]){
        
            if(scp.Supplier_Costs__r.size() > 0){
                SBCostWrapperBySupplier objSB = new SBCostWrapperBySupplier();
                objSB.scp = scp;
                objSB.lstSupplierCost.addAll(scp.Supplier_Costs__r);
                for(Supplier_Cost__c sbc : scp.Supplier_Costs__r){
                    objSB.totalCost += sbc.SC_Total_Client_Group_Cost__c;        
                }
                lstSBWrapperPv.add(objSB );
            }
        }
        return lstSBWrapperPv;  
    }
    
    ///****To Get Supplier Cost By Client Gorup***//
    @remoteAction
    public static costByClientAndOpp getSupplierCostByClient(String OppId, String oppStr){
        try{
            List<SBCostWrapperByCG> lstCGWrapper = new List<SBCostWrapperByCG>();
            Opportunity opp = (Opportunity)JSON.deserialize(oppStr,Opportunity.class);
            Map<String,Map<String,List<Supplier_Cost__c>>> mapCostRTSC = new Map<String,Map<String,List<Supplier_Cost__c>>>(); // RTSC = Record Type Supplier Currency
            Map<String,List<String>> mapSBCurrency = new Map<String,List<String>>();
            Boolean isFight = false;
            Decimal exGBP = 1;
            Boolean sellPriceChangeable = false;
            Decimal totalSellingPrice = 0;
            Decimal grandTotalBaseCost = 0;
            Decimal totalGift = 0;
            Decimal totalAdditionalCharges = 0;
            Decimal totalFlightCosts = 0;
            Boolean isSellingPriceChanged = false;
            List<Client_Group__c> lstClientGroup = SOQLServices.getClientGorupWithCost(OppId);
            Map<String,Decimal> mapTodaysCGCost = new Map<String,Decimal>();
            Map<String, Exchange_Rate__c> exchangeRateByCurrencyToday = new Map<String, Exchange_Rate__c>();
            
            //Payment Rules for deposit required
            Opportunity updateOpp = [Select Id,Amount,O_Margin__c,O_Booking_to_Departure__c,O_Days_to_Departure__c from Opportunity where Id = :oppId];
            Integer days;
            
            if(updateOpp.O_Margin__c != null && updateOpp.Amount != null){
                isSellingPriceChanged = true;
            }
            if(updateOpp.O_Booking_to_Departure__c != null){
                days = Integer.valueOf(updateOpp.O_Booking_to_Departure__c);
            }
            else{
                days = Integer.valueOf(updateOpp.O_Days_to_Departure__c);
            }
            List<Rule__c> lstRules = [Select Id,R_Percentage__c,R_Days_to_Departure_From__c,R_Days_to_Departure_To__c
                                 from Rule__c where recordType.DeveloperName = 'Client_Payment' and
                 R_Days_to_Departure_From__c < :days AND R_Days_to_Departure_To__c>= :days and Is_Active__c = true  limit 1]; 
            
            //Todays Exchange Rates 
            for(Exchange_Rate__c er : SOQLServices.getExchangeRate(opp.CurrencyISOCode, System.today(), 'Sell')){
                if((er.ER_Sales_Currency__c == opp.CurrencyISOCode) 
                    && System.today() >= er.ER_Book_From__c && System.today() <= er.ER_Book_To__c && opp.O_Departure_Date__c >= er.ER_Travel_From__c &&
                    opp.O_Departure_Date__c <= er.ER_Travel_To__c){
                    exchangeRateByCurrencyToday.put(er.ER_Base_Currency__c,er);  
                }
            }
            
            
            for(Client_Group__c cg : lstClientGroup){
                mapCostRTSC = new Map<String,Map<String,List<Supplier_Cost__c>>>();
                totalFlightCosts += cg.CG_Total_Flight_Cost__c;
                for(Supplier_Cost__c sc : cg.Supplier_Costs__r){
                    String mapKey = sc.SC_Supplier_Booking__r.SB_Supplier__c;
                    String mapKey1 = sc.SC_Supplier_Booking__r.recordType.Name+'##'+sc.currencyIsoCode;
                    if(!mapCostRTSC.containsKey(sc.SC_Supplier_Booking__r.SB_Supplier__c)){
                        mapCostRTSC.put(mapKey, new Map<String,List<Supplier_Cost__c>>());
                    }
                    if(!mapCostRTSC.get(mapKey).containsKey(mapKey1)){
                        mapCostRTSC.get(mapKey).put(mapKey1, new List<Supplier_Cost__c>());
                    }
                    mapCostRTSC.get(mapKey).get(mapKey1).add(sc);
                    
                    if(!mapSBCurrency.containsKey(sc.SC_Supplier_Cost_Payment__c)){
                        mapSBCurrency.put(sc.SC_Supplier_Cost_Payment__c,new List<String>());    
                    }
                    mapSBCurrency.get(sc.SC_Supplier_Cost_Payment__c).add(sc.SC_Supplier_Cost_Payment__r.CurrencyISOCode);
                    if(sc.SC_Supplier_Booking__r.recordType.DeveloperName.indexOf('Flight') != -1 || sc.SC_Supplier_Booking__r.recordType.DeveloperName.indexOf('Aircraft') != -1){
                        isFight = true;
                    }
                }
                List<BySupplierWrapper> lstSuppliers = new List<BySupplierWrapper>();
                String supplierName = '';
                
                for(String rtsc : mapCostRTSC.keySet()){
                    Map<String,Decimal> mapCostWithCurrency = new Map<String,Decimal>();
                    List<ByComponentWrapper> lstComp = new List<ByComponentWrapper>();
                    for(String comp : mapCostRTSC.get(rtsc).keySet()){
                        List<String> lstCompCurrency = comp.split('##');
                        Decimal netCostInCC = 0;
                        Decimal roe = 1;
                        Decimal netCostInSC = 0;
                        Decimal margin = 0;
                        Decimal totalMarkUpValue = 0;
                        Integer count = 0;
                        
                        
                        for(Supplier_Cost__c sc : mapCostRTSC.get(rtsc).get(comp)){
                            supplierName = sc.SC_Supplier_Booking__r.SB_Supplier__r.Name;
                            if(sc.SC_Total_Client_Group_Cost__c != null)
                                netCostInCC += sc.SC_Total_Client_Group_Cost__c;
                            if(sc.SC_Total_Net_CostSC__c != null)
                                netCostInSC += sc.SC_Total_Net_CostSC__c;
                            roe = sc.SC_Exchange_Rate_Lookup__r.ER_Exchange_Rate__c;
                            if(sc.SC_Margin__c != null)
                                margin += sc.SC_Margin__c;
                            
                            if(sc.SC_MarkUp_Cost_for_Selling_Price__c != null)
                                totalMarkUpValue  += sc.SC_MarkUp_Cost_for_Selling_Price__c;
                            count++;
                            //Cost Calculation for todays exchange rate.
                            if(!mapTodaysCGCost.containsKey(sc.SC_Client_Group__c)){
                                mapTodaysCGCost.put(sc.SC_Client_Group__c,0);
                            }
                            Decimal oldCost = mapTodaysCGCost.get(sc.SC_Client_Group__c);
                            Decimal thisSC = 0;
                            if(exchangeRateByCurrencyToday.containsKey(sc.CurrencyIsoCode)){
                                if(sc.SC_Margin_Value__c == null || sc.SC_Margin_Type__c == 'Percentage'){
                                    thisSC  = (sc.SC_Total_Client_Group_Cost__c/exchangeRateByCurrencyToday.get(sc.CurrencyIsoCode).ER_Exchange_Rate__c)*(1+(sc.SC_Margin__c/100));
                                }
                                else if(sc.SC_Margin_Type__c == 'Value'){
                                    thisSC  = (sc.SC_Total_Client_Group_Cost__c/exchangeRateByCurrencyToday.get(sc.CurrencyIsoCode).ER_Exchange_Rate__c)+sc.SC_Margin_Value__c;
                                }
                            }
                            mapTodaysCGCost.put(sc.SC_Client_Group__c,oldCost+thisSC);
                        }
                        
                        margin = margin/count;
                        if(!mapCostWithCurrency.containsKey(lstCompCurrency[1])){
                        mapCostWithCurrency.put(lstCompCurrency[1],0);
                        }
                        mapCostWithCurrency.put(lstCompCurrency[1],mapCostWithCurrency.get(lstCompCurrency[1])+netCostInSC);
                        ByComponentWrapper compWrapper = new ByComponentWrapper(lstCompCurrency[0],lstCompCurrency[1],netCostInCC,roe,netCostInSC,margin,totalMarkUpValue);
                        lstComp.add(compWrapper);
                    }
                    
                    BySupplierWrapper objSupplier = new BySupplierWrapper(supplierName,lstComp,mapCostWithCurrency);
                    lstSuppliers.add(objSupplier);
                }
                
                //logic for additional charges 
                Integer supplierWithNoGBP = 0;
                for(String str : mapSBCurrency.keySet()){
                    Boolean isBookingCurrency = true;
                    for(String curr : mapSBCurrency.get(str)){
                        if(curr == opp.CurrencyISOCode){
                            isBookingCurrency = false;    
                        }
                    }
                    if(isBookingCurrency){
                        supplierWithNoGBP++;
                    }
                }
                cg = ItineraryBuilderController.CalculateAdditionalCharges(opp,cg,supplierWithNoGBP,isFight, lstRules);
                //Recommondend Selling Price Calculation 
                if(cg.CG_FX_Transfer_Charges__c != null && cg.CG_Arrival_Presents__c != null && cg.CG_Charity__c != null && cg.CG_Regulatory_Charges__c != null){
                    if(cg.CG_Opportunity__r.O_Target_Mark_Up_Value__c != null){
                        //Update 03-03-2016 By Veer
                        //cg.CG_Recommended_Selling_Price__c = cg.CG_Recommended_Selling_Price_Rp__c + (cg.CG_FX_Transfer_Charges__c+ cg.CG_Arrival_Presents__c+ cg.CG_Charity__c + cg.CG_Regulatory_Charges__c )*(1+ cg.CG_Opportunity__r.O_Target_Mark_Up_Value__c/100 );
                        
                        cg.CG_Recommended_Selling_Price__c = cg.CG_Recommended_Selling_Price_Rp__c + (cg.CG_FX_Transfer_Charges__c+ cg.CG_Arrival_Presents__c+ cg.CG_Charity__c + cg.CG_Regulatory_Charges__c );
                        if(mapTodaysCGCost.containsKey(cg.Id)){
                            cg.CG_Recommended_Selling_Price_Today__c = mapTodaysCGCost.get(cg.Id) + (cg.CG_FX_Transfer_Charges__c+ cg.CG_Arrival_Presents__c+ cg.CG_Charity__c + cg.CG_Regulatory_Charges__c );
                        }
                    }
                    else if(cg.CG_Opportunity__r.O_Target_Mark_Up_Value__c == null){
                        System.assert(false,'Target Mark-up not available, please contact to system admin.');
                    }    
                    if(cg.CG_Selling_Price__c == null && cg.CG_Recommended_Selling_Price__c != null){
                        cg.CG_Selling_Price__c = cg.CG_Recommended_Selling_Price__c.setScale(2);
                        sellPriceChangeable = true;
                    }
                    if(cg.CG_Recommended_Selling_Price__c != null){
                        lstCGWrapper.add(new SBCostWrapperByCG(cg,cg.CG_Recommended_Selling_Price_Rp__c,lstSuppliers));
                        totalSellingPrice += cg.CG_Selling_Price__c;
                        if(cg.CG_Total_cost_in_selling_currency__c != null){
                            grandTotalBaseCost += cg.CG_Total_cost_in_selling_currency__c;
                        }
                        totalGift += cg.CG_Arrival_Presents__c;
                        totalAdditionalCharges += cg.CG_FX_Transfer_Charges__c+ cg.CG_Arrival_Presents__c+ cg.CG_Charity__c + cg.CG_Regulatory_Charges__c;
                    }
                    
                }
            }
           
            opp = calculateMargin(opp,totalSellingPrice,grandTotalBaseCost,totalGift,totalAdditionalCharges,totalFlightCosts);
            if(!isFight){
                Decimal regulatoryCharges = (totalSellingPrice/opp.Group_Members__r.size()).setScale(2, RoundingMode.HALF_UP);
                List<None_Licenseable_Protection_Cost__c> lstNLP = [Select id, NLPC_High_Band__c, NLPC_Low_Band__c, NLPC_Premium_PP__c from  None_Licenseable_Protection_Cost__c
                        where NLPC_Low_Band__c <=:regulatoryCharges AND NLPC_High_Band__c >= :regulatoryCharges limit 1];
                totalAdditionalCharges  = 0;
                totalSellingPrice = 0;
                for(Client_Group__c cg : lstClientGroup){
                    List<Exchange_Rate__c> lstEx = [Select Id,ER_Exchange_Rate__c from Exchange_Rate__c where Id = :cg.CG_Exchange_Rate_GBP__c];
                    //System.assert(false,lstEx +'ddddd'+);
                    if(opp.Client_Groups__r.size() != 0 && lstEx.size() > 0){
                        exGBP = lstEx[0].ER_Exchange_Rate__c;
                        if(lstNLP.size() == 1 && cg.CG_Total_Adult_Members__c != null && cg.CG_Exchange_Rate_GBP__c != null){
                            Decimal oldCharge = cg.CG_Regulatory_Charges__c;
                            cg.CG_Regulatory_Charges__c = ((lstNLP[0].NLPC_Premium_PP__c*cg.CG_Total_Adult_Members__c*1.2)/lstEx[0].ER_Exchange_Rate__c).setScale(2);
                            
                            //Update all calcultion
                            totalAdditionalCharges += cg.CG_FX_Transfer_Charges__c+ cg.CG_Arrival_Presents__c+ cg.CG_Charity__c + cg.CG_Regulatory_Charges__c;
                            if(cg.CG_Recommended_Selling_Price__c != null){
                                cg.CG_Recommended_Selling_Price__c = (cg.CG_Recommended_Selling_Price__c+(cg.CG_Regulatory_Charges__c-oldCharge));
                                if(sellPriceChangeable){
                                    cg.CG_Selling_Price__c = cg.CG_Recommended_Selling_Price__c.setScale(2);
                                }
                            }
                            
                            if(cg.CG_Recommended_Selling_Price_Today__c != null){
                                if(mapTodaysCGCost.containsKey(cg.Id)){
                                    cg.CG_Recommended_Selling_Price_Today__c = (cg.CG_Recommended_Selling_Price_Today__c+(cg.CG_Regulatory_Charges__c-oldCharge));
                                }
                            }
                        }
                        else{
                            cg.CG_Regulatory_Charges__c = 0;   
                        }
                    }
                    if(cg.CG_Selling_Price__c != null){
                        totalSellingPrice += cg.CG_Selling_Price__c;
                    }
                }
                
            }
            opp = calculateMargin(opp,totalSellingPrice,grandTotalBaseCost,totalGift,totalAdditionalCharges,totalFlightCosts);
            costByClientAndOpp objClient = new costByClientAndOpp(opp,lstCGWrapper,isFight,exGBP);
            objClient.isSellingPriceChanged = isSellingPriceChanged;
            return objClient;
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+'$$$$'+e.getMessage());
            return null;
        }
    }
    
    //Calculate Additional Charges
    public static Client_Group__c  CalculateAdditionalCharges(Opportunity opp, Client_Group__c cg, Integer supplierWithNoGBP, Boolean isFight, List<Rule__c> lstRules){
        if(cg.CG_Arrival_Presents__c == null || cg.CG_Charity__c == null || cg.CG_FX_Transfer_Charges__c != null || cg.CG_FX_Transfer_Charges__c == null || cg.CG_Regulatory_Charges__c == null){
            Map<String,Exchange_Rate__c> mapExCurrency = new Map<String,Exchange_Rate__c>();
            for(Exchange_Rate__c er : SOQLServices.getExchangeRate(opp.CurrencyISOCode, opp.closeDate, 'Sell')){
                if((er.ER_Sales_Currency__c == opp.CurrencyISOCode) && opp.closedate >= er.ER_Book_From__c && 
                        opp.closedate <= er.ER_Book_To__c && opp.O_Departure_Date__c >= er.ER_Travel_From__c && opp.O_Departure_Date__c <= er.ER_Travel_To__c){
                    mapExCurrency.put(er.ER_Base_Currency__c,er);  
                }
            }
            List<Calculation_Variables__c> lstCV = [Select Id,CV_APC_Charges__c,CV_Arrival_Presents__c,CV_Charity__c,CV_Transfer_Charges__c
                            from Calculation_Variables__c where CV_Booking_From__c <= :opp.closeDate and CV_Booking_To__c >= :opp.closeDate and CurrencyISOCode = :opp.currencyISOCode];
            if(lstCV.size() > 0){
                if(cg.CG_Charity__c == null && cg.CG_Total_Group_Members__c != null){
                    cg.CG_Charity__c = cg.CG_Total_Group_Members__c*lstCV[0].CV_Charity__c; //exchangeRateByCurrency.get('GBP').ER_Exchange_Rate__c).setScale(2, RoundingMode.HALF_UP);    
                }
                
                if((cg.CG_Total_Child_Members__c > 0 && cg.CG_Arrival_Presents__c == null) ){
                    cg.CG_Arrival_Presents__c = cg.CG_Total_Child_Members__c*lstCV[0].CV_Arrival_Presents__c;    
                }
                else if(cg.CG_Arrival_Presents__c == null){
                    cg.CG_Arrival_Presents__c = 0;
                }
                cg.CG_FX_Transfer_Charges__c =  supplierWithNoGBP*lstCV[0].CV_Transfer_Charges__c/opp.Client_Groups__r.size();
                
                if(isFight && mapExCurrency.containsKey('GBP') && cg.CG_Total_Adult_Members__c != null){
                    cg.CG_Regulatory_Charges__c =  ((cg.CG_Total_Adult_Members__c*lstCV[0].CV_APC_Charges__c)/mapExCurrency.get('GBP').ER_Exchange_Rate__c).setScale(2);
                }
                else if(!mapExCurrency.containsKey('GBP')){
                    System.assert(false,'Exchange Rate not setup for GBP');
                }
                else{
                    cg.CG_Regulatory_Charges__c = 0;
                }
                if(mapExCurrency.containsKey('GBP')){
                    cg.CG_Exchange_Rate_GBP__c = mapExCurrency.get('GBP').Id;
                }
            }
            
        }
        /*if(cg.CG_Opportunity__r.O_Payment_Rule__c != null && cg.CG_Opportunity__r.O_Payment_Rule__r.R_Percentage__c != null){
            if(cg.CG_Selling_Price__c != null){
                cg.CG_Deposit_Required_I__c = (cg.CG_Selling_Price__c*cg.CG_Opportunity__r.O_Payment_Rule__r.R_Percentage__c/100);    
            }
            else{
                cg.CG_Deposit_Required_I__c = (cg.CG_Recommended_Selling_Price__c*cg.CG_Opportunity__r.O_Payment_Rule__r.R_Percentage__c/100);    
            }
        }
        else*/ 
        if(lstRules.size() > 0  && lstRules[0].R_Percentage__c != null){
            if(cg.CG_Selling_Price__c != null){
                cg.CG_Deposit_Required_I__c = (cg.CG_Selling_Price__c*lstRules[0].R_Percentage__c/100);    
            }
            else if(cg.CG_Recommended_Selling_Price__c != null){
                cg.CG_Deposit_Required_I__c = (cg.CG_Recommended_Selling_Price__c*lstRules[0].R_Percentage__c/100);    
            }
        }
        return cg;    
    }
    
    //Calcualte Margin and Recommonded Selling Price 
    public static Opportunity calculateMargin(Opportunity opp, Decimal totalSellingPrice, Decimal grandTotalBaseCost, Decimal totalGift,Decimal totalAdditionalCharges,Decimal totalFlightCosts){
        opp.O_TOMS_Applicable_Margin__c = (totalSellingPrice+Opp.O_Total_Credit_Card_Charges__c).setScale(2);
        System.debug('VVVVVVVVVVVV'+totalSellingPrice);
        opp.Amount = totalSellingPrice;
        if(!opp.O_EU__c){
            opp.O_TOMS_Charges__c = 0;
        }
        else{
            opp.O_TOMS_Charges__c = ((totalSellingPrice+Opp.O_Total_Credit_Card_Charges__c-grandTotalBaseCost-totalGift) - ((totalSellingPrice+Opp.O_Total_Credit_Card_Charges__c-grandTotalBaseCost-totalGift)/1.2)).setScale(2);
        }
        Decimal agentcommission  = 0;
        Decimal totalBaseCostandAdditional = 0;
        if(opp.O_Agent_Commission__c != null){
            agentcommission = opp.O_Agent_Commission__c;
        }
        if(!opp.O_Include_Flight_Margin__c){
            //totalBaseCostandAdditional = (grandTotalBaseCost+totalAdditionalCharges+opp.O_TOMS_Charges__c+agentcommission-totalFlightCosts);
            totalBaseCostandAdditional = (grandTotalBaseCost+totalAdditionalCharges+opp.O_TOMS_Charges__c-totalFlightCosts);
        }
        else{
            //totalBaseCostandAdditional = (grandTotalBaseCost+totalAdditionalCharges+opp.O_TOMS_Charges__c+agentcommission);
            totalBaseCostandAdditional = (grandTotalBaseCost+totalAdditionalCharges+opp.O_TOMS_Charges__c);
        }
        opp.O_Margin__c  = (totalSellingPrice - (totalBaseCostandAdditional)).setScale(2);
        return opp;
    }
    
    
    //####Cost Options Section
    @remoteAction
    public static List<CostOptionWrapper> CostOptions(String oppId){
        List<CostOptionWrapper>  lstCostWrapper = new List<CostOptionWrapper>();
        For(Supplier_Booking__c sb : SOQLServices.getSupplierBookingWithCost(oppId)){
            CostOptionWrapper cow = new CostOptionWrapper();
            Map<String,Map<String,List<Supplier_Cost__c>>> mapCostnByOptions = new Map<String,Map<String,List<Supplier_Cost__c>>>();
            for(Supplier_Cost__c sc : sb.Supplier_Costs__r){    
                String key = sc.SC_Client_Group__r.Name+'##'+sc.SC_Client_Group__r;
                if(!mapCostnByOptions.containsKey(key)){
                    mapCostnByOptions.put(key, new Map<String,List<Supplier_Cost__c>>());
                }
                if(!mapCostnByOptions.get(key).containsKey('Option '+sc.SC_Option__c)){
                    mapCostnByOptions.get(key).put('Option '+sc.SC_Option__c, new List<Supplier_Cost__c>());
                }   
                mapCostnByOptions.get(key).get('Option '+sc.SC_Option__c).add(sc);     
            }
            List<ClientGroupOptions> lstClientGroups = new List<ClientGroupOptions>();
            for(String cgId : mapCostnByOptions.keySet()){
                List<String> lstName = cgId.split('##');
                if(lstName.size() > 0){
                    ClientGroupOptions cgo = new ClientGroupOptions(lstName[0]);
                    cgo.mapCostnByOptions = mapCostnByOptions.get(cgId);
                    for(List<Supplier_Cost__c> lstSc : mapCostnByOptions.get(cgId).values()){
                        for(Supplier_Cost__c sc : lstSc){
                            if(sc.SC_Selected__c){
                                cgo.selectedOption = 'Option '+sc.SC_Option__c;
                            }
                        }
                    }
                    lstClientGroups.add(cgo);
                }
            }
            cow.lstClientGroups = lstClientGroups;
            cow.sb = sb;
            lstCostWrapper.add(cow);
        }
        return lstCostWrapper;    
    }
    
    //Update Options 
    @remoteAction
    public static String saveOptions(List<CostOptionWrapper> lstCow){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Supplier_Cost__c> lstSupplierCost = new List<Supplier_Cost__c>();
            for(CostOptionWrapper cow : lstCow){
                for(ClientGroupOptions co : cow.lstClientGroups){
                    for(List<Supplier_Cost__c> lstsc : co.mapCostnByOptions.Values()){
                        lstSupplierCost.addAll(lstsc);
                    }
                }
            }
            update lstSupplierCost;
            return ErrorMessageController.getErrorMessage('ItineraryBuilder').get('IB_Supplier_Costs_Updated');
        }
        Catch(Exception e){
            Database.rollback(sp);
            return e.getMessage();
        }
        return null;
    }
    
    //Get Contact Detail for contact popup
    @remoteAction
    public static String getContactDetail(String contactId){
        List<Contact> lstCon = [Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,C_Middle_Name__c,
                            C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,MailingCountry,MailingState,MailingPostalCode,
                            Description, email,phone,Birthdate,Occupancy_Type__c ,C_Lead_Passenger__c , Adult__c,C_Child__c,C_Infant__c,
                            (select id,Name,AM_Airline__c from Airline_memberships__r), (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) from Contact where Id  = :contactId];
        if(lstCon.size() > 0){
            return JSON.serialize(lstCon[0]);
        }
        return null;
    }
    
    @remoteAction
    public static Contact saveContactAddress(String jsoncon) {
       Contact con= (Contact)JSON.deserialize(jsoncon,Contact.class);
        
        upsert con;
        
        return [Select Id,BirthDate,Occupancy_Type__c from Contact where Id  =:con.Id];
    }
    
    // save airline member
    @remoteAction
    public static String saveAirlineMember(String jsonData, String conStr){
        //System.assert(false,jsonData);
        try{
            AirlineMemberShip member = (AirlineMemberShip) JSON.deserialize(jsonData, AirlineMemberShip.Class);
            Contact con = (Contact) JSON.deserialize(conStr, Contact.Class);
        
            //upsert contact as we need contact id to create airline membership
            //system.assert(false, member);
            upsert con;
            Airline_membership__c amc = new Airline_membership__c();
            amc.Id = member.id;
            amc.AM_Airline__c = member.airline;
            if(amc.Id == null){
                amc.AM_Contact__c = con.Id;
            }
            amc.Name = member.membershipnumber;
            upsert amc;
            return JSON.serialize([Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingState,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            , (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,  CP_State__c, CP_Street_1__c, 
                            CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) from Contact where Id= :con.Id]);
        }
        catch(Exception e){
            System.assert(false, e.getMessage()+'dsdsd'+e.getStackTraceString());
            return null;
        }
        
    } 
    
    // Delete airline member
    @remoteAction
    public static String DeleteAirlineMember(String airlineMembershipRecordId, String contactId){
        try{
            
            Airline_membership__c  member = [Select id from Airline_membership__c where id =: airlineMembershipRecordId];
            delete member;
        }
        catch(Exception e){
            System.assert(false, e);
        }
        return JSON.serialize([Select id,Salutation,AccountId,firstname,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,C_Passport_Number__c,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingCountry,MailingState,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r) , 
                            (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,  CP_State__c, CP_Street_1__c, 
                            CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r)
                            from Contact where Id= :contactId]);
    } 
    // save communication pre.
    @remoteAction
    public static String saveCommp(String jsonData, String conStr){
        //System.assert(false,jsonData);
        try{
            Communication_Preference__c commp = (Communication_Preference__c) JSON.deserialize(jsonData, Communication_Preference__c.Class);
            Contact con = (Contact) JSON.deserialize(conStr, Contact.Class);
            //upsert contact as we need contact id to create airline membership
            upsert con;
            if(commp.Id == null){
                commp.CP_Account__c = con.AccountId;
                commp.CP_Contact__c = con.Id;
            }
            upsert commp;
            
            return JSON.serialize([Select id,Salutation,AccountId,C_Passport_Number__c,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,firstname,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingState,MailingCountry,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            ,(Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c, CP_State__c, CP_Street_1__c,
                             CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :con.Id]);
        }
        catch(Exception e){
            System.assert(false, e.getMessage()+'dsdsd'+e.getStackTraceString());
            return null;
        }
        
    }
    // Delete Communication Pre.
    @remoteAction
    public static String DeleteCommp(String commpRecordId, String contactId){
        try{
            Communication_Preference__c member = [Select id from Communication_Preference__c where id =: commpRecordId];
            delete member;
        }
        catch(Exception e){
            System.assert(false, e);
        }
        return JSON.serialize([Select id,Salutation,AccountId,firstname,C_Age__c,C_Full_Name_on_Passport__c,C_Citizenship__c,C_Expires_Date__c,
                            C_Gender__c,C_Issued_Date__c,C_Issue_Place__c,C_Nationality__c,C_Place_of_Birth__c,C_Passport_Number__c,lastname,
                            C_Middle_Name__c,C_Prefered_Name__c,Languages__c,HomePhone,MobilePhone,OtherPhone,MailingCity,MailingStreet,
                            MailingCountry,MailingState,MailingPostalCode,Description, email,phone,Birthdate,Occupancy_Type__c ,
                            C_Lead_Passenger__c ,Adult__c,C_Child__c,C_Infant__c,(select id,Name,AM_Airline__c from Airline_memberships__r)
                            , (Select Id,CP_Account__c,CP_Country__c,CP_Postal_Code__c,CP_Opt_in__c,
                             CP_State__c, CP_Street_1__c, CP_Street_2__c, CP_Street_3__c, CP_Type__c, CP_City__c, CP_Email__c, CP_Phone__c from Communication_Preferences__r) 
                            from Contact where Id= :contactId]);
    } 
    
    
    public Class FlightMembers{
    
        public String Name{get; set;}
        public Boolean IsLead{get; set;}
        public Boolean IsSelected{get; set;}
        public Flight_Booking__c fb{get; set;}
        public FlightMembers(String Name, Boolean IsLead, Flight_Booking__c fb, Boolean IsSelected){
            this.Name = Name;
            this.IsLead = IsLead;
            this.fb = fb;
            this.IsSelected = IsSelected;
        }
        
    }
    
    public Class AirlineMemberShip{
        public Contact con {get;set;}
        public string airline{get;set;}
        public string id{get;set;}
        public String membershipNumber{get;set;}
        
        public AirlineMemberShip(Contact con, String airline, String amnumber){
            this.con = con;
            this.id = null;
            this.airline = airline;
            this.membershipnumber = amnumber;
        }
    }
    
    public Class CostOptionWrapper{
        public Supplier_Booking__c sb{get; set;}
        public List<ClientGroupOptions> lstClientGroups{get; set;}
        
        public CostOptionWrapper(){
            this.lstClientGroups = new List<ClientGroupOptions>();
        }
    }
    public Class ClientGroupOptions{
        public String ClientGroupName{get; set;}
        public String ClientGroupId{get; set;}
        public Map<String,List<Supplier_Cost__c>> mapCostnByOptions{get; set;}
        public String selectedOption{get; set;}   
        public ClientGroupOptions(String ClientGroupName){
            this.ClientGroupName = ClientGroupName;
            this.mapCostnByOptions = new Map<String,List<Supplier_Cost__c>>();     
        } 
    }
    
    public Class costByClientAndOpp{
        public Opportunity opp{get; set;}
        public List<SBCostWrapperByCG> SBCClient{get; set;}
        public Boolean isFlight{get; set;}
        public Decimal exGBP{get; set;}
        public Boolean isSellingPriceChanged{get; set;}
        public costByClientAndOpp(Opportunity opp, List<SBCostWrapperByCG> SBCClient, Boolean isFlight, Decimal exGBP){
            this.opp = opp;
            this.SBCClient = SBCClient;
            this.isFlight = isFlight;
            this.exGBP = exGBP;
            this.isSellingPriceChanged = false;
        }
    }
    
    
    public Class SBCostWrapperByCG{
        public Client_Group__c cg{get; set;}
        public Decimal totalNetCostSC{get; set;}
        public List<BySupplierWrapper> lstSuppliers{get; set;}
        
        public SBCostWrapperByCG(Client_Group__c cg, Decimal totalNetCostSC, List<BySupplierWrapper> lstSuppliers){
            this.cg = cg;
            this.totalNetCostSC = totalNetCostSC;
            this.lstSuppliers = lstSuppliers;
        }
    }
    
    
    public String getLoadCountries() {
        List<pickListValues> countryOptions = new List<pickListValues>();
        countryOptions.add(new pickListValues('','-Select-'));    
        countryOptions.add(new pickListValues ('GB','United Kingdom'));
        countryOptions.add(new pickListValues ('US','United States'));
        countryOptions.add(new pickListValues ('AF','Afghanistan'));
        //countryOptions.add(new pickListValues ('Åland Islands','Åland Islands'));
        countryOptions.add(new pickListValues ('AL','Albania'));
        countryOptions.add(new pickListValues ('DZ','Algeria'));
        countryOptions.add(new pickListValues ('AS','American Samoa'));
        countryOptions.add(new pickListValues ('AD','Andorra'));
        countryOptions.add(new pickListValues ('AO','Angola'));
        countryOptions.add(new pickListValues ('AI','Anguilla'));
        countryOptions.add(new pickListValues ('AQ','Antarctica'));
        countryOptions.add(new pickListValues ('AG','Antigua and Barbuda'));
        countryOptions.add(new pickListValues ('AR','Argentina'));
        countryOptions.add(new pickListValues ('AM','Armenia'));
        countryOptions.add(new pickListValues ('AW','Aruba'));
        countryOptions.add(new pickListValues ('AU','Australia'));
        countryOptions.add(new pickListValues ('AT','Austria'));
        countryOptions.add(new pickListValues ('AZ','Azerbaijan'));
        countryOptions.add(new pickListValues ('BS','Bahamas'));
        countryOptions.add(new pickListValues ('BH','Bahrain'));
        countryOptions.add(new pickListValues ('BD','Bangladesh'));
        countryOptions.add(new pickListValues ('BB','Barbados'));
        countryOptions.add(new pickListValues ('BY','Belarus'));
        countryOptions.add(new pickListValues ('BE','Belgium'));
        countryOptions.add(new pickListValues ('BZ','Belize'));
        countryOptions.add(new pickListValues ('BJ','Benin'));
        countryOptions.add(new pickListValues ('BM','Bermuda'));
        countryOptions.add(new pickListValues ('BT','Bhutan'));
        countryOptions.add(new pickListValues ('BO','Bolivia'));
        countryOptions.add(new pickListValues ('BA','Bosnia and Herzegovina'));
        countryOptions.add(new pickListValues ('BW','Botswana'));
        countryOptions.add(new pickListValues ('BV','Bouvet Island'));
        countryOptions.add(new pickListValues ('BR','Brazil'));
        countryOptions.add(new pickListValues ('IO','British Indian Ocean Territory'));
        countryOptions.add(new pickListValues ('BN','Brunei Darussalam'));
        countryOptions.add(new pickListValues ('BG','Bulgaria'));
        countryOptions.add(new pickListValues ('BF','Burkina Faso'));
        countryOptions.add(new pickListValues ('BI','Burundi'));
        countryOptions.add(new pickListValues ('KH','Cambodia'));
        countryOptions.add(new pickListValues ('CM','Cameroon'));
        countryOptions.add(new pickListValues ('CA','Canada'));
        countryOptions.add(new pickListValues ('CV','Cape Verde'));
        countryOptions.add(new pickListValues ('KY','Cayman Islands'));
        countryOptions.add(new pickListValues ('CF','Central African Republic'));
        countryOptions.add(new pickListValues ('TD','Chad'));
        countryOptions.add(new pickListValues ('CL','Chile'));
        countryOptions.add(new pickListValues ('CN','China'));
        countryOptions.add(new pickListValues ('CX','Christmas Island'));
        countryOptions.add(new pickListValues ('CC','Cocos (Keeling) Islands'));
        countryOptions.add(new pickListValues ('CO','Colombia'));
        countryOptions.add(new pickListValues ('KM','Comoros'));
        countryOptions.add(new pickListValues ('CG','Congo'));
        countryOptions.add(new pickListValues ('CD, The Democratic Republic of The','Congo, The Democratic Republic of The'));
        countryOptions.add(new pickListValues ('CK','Cook Islands'));
        countryOptions.add(new pickListValues ('CR','Costa Rica'));
        countryOptions.add(new pickListValues ('CI','Cote D\'ivoire'));
        countryOptions.add(new pickListValues ('HR','Croatia'));
        countryOptions.add(new pickListValues ('CU','Cuba'));
        countryOptions.add(new pickListValues ('CY','Cyprus'));
        countryOptions.add(new pickListValues ('CZ','Czech Republic'));
        countryOptions.add(new pickListValues ('DK','Denmark'));
        countryOptions.add(new pickListValues ('DJ','Djibouti'));
        countryOptions.add(new pickListValues ('DM','Dominica'));
        countryOptions.add(new pickListValues ('DO','Dominican Republic'));
        countryOptions.add(new pickListValues ('EC','Ecuador'));
        countryOptions.add(new pickListValues ('EG','Egypt'));
        countryOptions.add(new pickListValues ('SV','El Salvador'));
        countryOptions.add(new pickListValues ('GQ','Equatorial Guinea'));
        countryOptions.add(new pickListValues ('ER','Eritrea'));
        countryOptions.add(new pickListValues ('EE','Estonia'));
        countryOptions.add(new pickListValues ('ET','Ethiopia'));
        countryOptions.add(new pickListValues ('FK','Falkland Islands (Malvinas)'));
        countryOptions.add(new pickListValues ('FO','Faroe Islands'));
        countryOptions.add(new pickListValues ('FJ','Fiji'));
        countryOptions.add(new pickListValues ('FI','Finland'));
        countryOptions.add(new pickListValues ('FR','France'));
        countryOptions.add(new pickListValues ('GF','French Guiana'));
        countryOptions.add(new pickListValues ('PF','French Polynesia'));
        countryOptions.add(new pickListValues ('TF','French Southern Territories'));
        countryOptions.add(new pickListValues ('GA','Gabon'));
        countryOptions.add(new pickListValues ('GM','Gambia'));
        countryOptions.add(new pickListValues ('GE','Georgia'));
        countryOptions.add(new pickListValues ('DE','Germany'));
        countryOptions.add(new pickListValues ('GH','Ghana'));
        countryOptions.add(new pickListValues ('GI','Gibraltar'));
        countryOptions.add(new pickListValues ('GR','Greece'));
        countryOptions.add(new pickListValues ('GL','Greenland'));
        countryOptions.add(new pickListValues ('GD','Grenada'));
        countryOptions.add(new pickListValues ('GP','Guadeloupe'));
        countryOptions.add(new pickListValues ('GU','Guam'));
        countryOptions.add(new pickListValues ('GT','Guatemala'));
        //countryOptions.add(new pickListValues ('Guernsey','Guernsey'));
        countryOptions.add(new pickListValues ('GN','Guinea'));
        countryOptions.add(new pickListValues ('GW','Guinea-bissau'));
        countryOptions.add(new pickListValues ('GY','Guyana'));
        countryOptions.add(new pickListValues ('HT','Haiti'));
        countryOptions.add(new pickListValues ('HM','Heard Island and Mcdonald Islands'));
        countryOptions.add(new pickListValues ('VA','Holy See (Vatican City State)'));
        countryOptions.add(new pickListValues ('HN','Honduras'));
        countryOptions.add(new pickListValues ('HK','Hong Kong'));
        countryOptions.add(new pickListValues ('HU','Hungary'));
        countryOptions.add(new pickListValues ('IS','Iceland'));
        countryOptions.add(new pickListValues ('IN','India'));
        countryOptions.add(new pickListValues ('ID','Indonesia'));
        countryOptions.add(new pickListValues ('IR, Islamic Republic of','Iran, Islamic Republic of'));
        countryOptions.add(new pickListValues ('IQ','Iraq'));
        countryOptions.add(new pickListValues ('IE','Ireland'));
        //countryOptions.add(new pickListValues ('Isle of Man','Isle of Man'));
        countryOptions.add(new pickListValues ('IL','Israel'));
        countryOptions.add(new pickListValues ('IT','Italy'));
        countryOptions.add(new pickListValues ('JM','Jamaica'));
        countryOptions.add(new pickListValues ('JP','Japan'));
        //countryOptions.add(new pickListValues ('Jersey','Jersey'));
        countryOptions.add(new pickListValues ('JO','Jordan'));
        countryOptions.add(new pickListValues ('KZ','Kazakhstan'));
        countryOptions.add(new pickListValues ('KE','Kenya'));
        countryOptions.add(new pickListValues ('KI','Kiribati'));
        countryOptions.add(new pickListValues ('KP, Democratic People\'s Republic of','Korea, Democratic People\'s Republic of'));
        countryOptions.add(new pickListValues ('KR','Korea, Republic of'));
        countryOptions.add(new pickListValues ('KW','Kuwait'));
        countryOptions.add(new pickListValues ('KG','Kyrgyzstan'));
        //countryOptions.add(new pickListValues ('Lao People\'s Democratic Republic','Lao People\'s Democratic Republic'));
        countryOptions.add(new pickListValues ('LV','Latvia'));
        countryOptions.add(new pickListValues ('LB','Lebanon'));
        countryOptions.add(new pickListValues ('LS','Lesotho'));
        countryOptions.add(new pickListValues ('LR','Liberia'));
        countryOptions.add(new pickListValues ('LY','Libyan Arab Jamahiriya'));
        countryOptions.add(new pickListValues ('LI','Liechtenstein'));
        countryOptions.add(new pickListValues ('LT','Lithuania'));
        countryOptions.add(new pickListValues ('LU','Luxembourg'));
        countryOptions.add(new pickListValues ('MO','Macao'));
        countryOptions.add(new pickListValues ('MK, The Former Yugoslav Republic of','Macedonia, The Former Yugoslav Republic of'));
        countryOptions.add(new pickListValues ('MG','Madagascar'));
        countryOptions.add(new pickListValues ('MW','Malawi'));
        countryOptions.add(new pickListValues ('MY','Malaysia'));
        countryOptions.add(new pickListValues ('MV','Maldives'));
        countryOptions.add(new pickListValues ('ML','Mali'));
        countryOptions.add(new pickListValues ('MT','Malta'));
        countryOptions.add(new pickListValues ('MH','Marshall Islands'));
        countryOptions.add(new pickListValues ('MQ','Martinique'));
        countryOptions.add(new pickListValues ('MR','Mauritania'));
        countryOptions.add(new pickListValues ('MU','Mauritius'));
        countryOptions.add(new pickListValues ('YT','Mayotte'));
        countryOptions.add(new pickListValues ('MX','Mexico'));
        countryOptions.add(new pickListValues ('FM','Micronesia, Federated States of'));
        countryOptions.add(new pickListValues ('MD, Republic of','Moldova, Republic of'));
        countryOptions.add(new pickListValues ('MC','Monaco'));
        countryOptions.add(new pickListValues ('MN','Mongolia'));
        countryOptions.add(new pickListValues ('ME','Montenegro'));
        countryOptions.add(new pickListValues ('MS','Montserrat'));
        countryOptions.add(new pickListValues ('MA','Morocco'));
        countryOptions.add(new pickListValues ('MZ','Mozambique'));
        countryOptions.add(new pickListValues ('MM','Myanmar'));
        countryOptions.add(new pickListValues ('NA','Namibia'));
        countryOptions.add(new pickListValues ('NR','Nauru'));
        countryOptions.add(new pickListValues ('NP','Nepal'));
        countryOptions.add(new pickListValues ('NL','Netherlands'));
        countryOptions.add(new pickListValues ('AN','Netherlands Antilles'));
        countryOptions.add(new pickListValues ('NC','New Caledonia'));
        countryOptions.add(new pickListValues ('NZ','New Zealand'));
        countryOptions.add(new pickListValues ('NI','Nicaragua'));
        countryOptions.add(new pickListValues ('NE','Niger'));
        countryOptions.add(new pickListValues ('NG','Nigeria'));
        countryOptions.add(new pickListValues ('NU','Niue'));
        countryOptions.add(new pickListValues ('NF','Norfolk Island'));
        countryOptions.add(new pickListValues ('MP','Northern Mariana Islands'));
        countryOptions.add(new pickListValues ('NO','Norway'));
        countryOptions.add(new pickListValues ('OM','Oman'));
        countryOptions.add(new pickListValues ('PK','Pakistan'));
        countryOptions.add(new pickListValues ('PW','Palau'));
        //countryOptions.add(new pickListValues ('Palestinian Territory, Occupied','Palestinian Territory, Occupied'));
        countryOptions.add(new pickListValues ('PA','Panama'));
        countryOptions.add(new pickListValues ('PG','Papua New Guinea'));
        countryOptions.add(new pickListValues ('PY','Paraguay'));
        countryOptions.add(new pickListValues ('PE','Peru'));
        countryOptions.add(new pickListValues ('PH','Philippines'));
        countryOptions.add(new pickListValues ('PN','Pitcairn'));
        countryOptions.add(new pickListValues ('PL','Poland'));
        countryOptions.add(new pickListValues ('PT','Portugal'));
        countryOptions.add(new pickListValues ('PR','Puerto Rico'));
        countryOptions.add(new pickListValues ('QA','Qatar'));
        countryOptions.add(new pickListValues ('RE','Reunion'));
        countryOptions.add(new pickListValues ('RO','Romania'));
        countryOptions.add(new pickListValues ('RU','Russian Federation'));
        countryOptions.add(new pickListValues ('RW','Rwanda'));
        countryOptions.add(new pickListValues ('SH','Saint Helena'));
        countryOptions.add(new pickListValues ('KN','Saint Kitts and Nevis'));
        countryOptions.add(new pickListValues ('LC','Saint Lucia'));
        countryOptions.add(new pickListValues ('PM','Saint Pierre and Miquelon'));
        countryOptions.add(new pickListValues ('VC','Saint Vincent and The Grenadines'));
        countryOptions.add(new pickListValues ('WS','Samoa'));
        countryOptions.add(new pickListValues ('SM','San Marino'));
        countryOptions.add(new pickListValues ('ST','Sao Tome and Principe'));
        countryOptions.add(new pickListValues ('SA','Saudi Arabia'));
        countryOptions.add(new pickListValues ('SN','Senegal'));
        countryOptions.add(new pickListValues ('RS','Serbia'));
        countryOptions.add(new pickListValues ('SC','Seychelles'));
        countryOptions.add(new pickListValues ('SL','Sierra Leone'));
        countryOptions.add(new pickListValues ('SG','Singapore'));
        countryOptions.add(new pickListValues ('SK','Slovakia'));
        countryOptions.add(new pickListValues ('SI','Slovenia'));
        countryOptions.add(new pickListValues ('SB','Solomon Islands'));
        countryOptions.add(new pickListValues ('SO','Somalia'));
        countryOptions.add(new pickListValues ('ZA','South Africa'));
        countryOptions.add(new pickListValues ('GS','South Georgia and The South Sandwich Islands'));
        countryOptions.add(new pickListValues ('ES','Spain'));
        countryOptions.add(new pickListValues ('LK','Sri Lanka'));
        countryOptions.add(new pickListValues ('SD','Sudan'));
        countryOptions.add(new pickListValues ('SR','Suriname'));
        countryOptions.add(new pickListValues ('SJ','Svalbard and Jan Mayen'));
        countryOptions.add(new pickListValues ('SZ','Swaziland'));
        countryOptions.add(new pickListValues ('SE','Sweden'));
        countryOptions.add(new pickListValues ('CH','Switzerland'));
        countryOptions.add(new pickListValues ('SY','Syrian Arab Republic'));
        countryOptions.add(new pickListValues ('TW','Taiwan, Province of China'));
        countryOptions.add(new pickListValues ('TZ','Tajikistan'));
        countryOptions.add(new pickListValues ('TZ','Tanzania, United Republic of'));
        countryOptions.add(new pickListValues ('TH','Thailand'));
        //countryOptions.add(new pickListValues ('Timor-leste','Timor-leste'));
        countryOptions.add(new pickListValues ('TG','Togo'));
        countryOptions.add(new pickListValues ('TK','Tokelau'));
        countryOptions.add(new pickListValues ('TO','Tonga'));
        countryOptions.add(new pickListValues ('TT','Trinidad and Tobago'));
        countryOptions.add(new pickListValues ('TN','Tunisia'));
        countryOptions.add(new pickListValues ('TR','Turkey'));
        countryOptions.add(new pickListValues ('TM','Turkmenistan'));
        countryOptions.add(new pickListValues ('TC','Turks and Caicos Islands'));
        countryOptions.add(new pickListValues ('TV','Tuvalu'));
        countryOptions.add(new pickListValues ('UG','Uganda'));
        countryOptions.add(new pickListValues ('UA','Ukraine'));
        countryOptions.add(new pickListValues ('AE','United Arab Emirates'));
        countryOptions.add(new pickListValues ('UM','United States Minor Outlying Islands'));
        countryOptions.add(new pickListValues ('UY','Uruguay'));
        countryOptions.add(new pickListValues ('UZ','Uzbekistan'));
        countryOptions.add(new pickListValues ('VU','Vanuatu'));
        countryOptions.add(new pickListValues ('VE','Venezuela'));
        countryOptions.add(new pickListValues ('VN','Viet Nam'));
        countryOptions.add(new pickListValues ('VG','Virgin Islands, British'));
        countryOptions.add(new pickListValues ('VI','Virgin Islands, U.S.'));
        countryOptions.add(new pickListValues ('WF','Wallis and Futuna'));
        countryOptions.add(new pickListValues ('EH','Western Sahara'));
        countryOptions.add(new pickListValues ('YE','Yemen'));
        countryOptions.add(new pickListValues ('ZM','Zambia'));
        countryOptions.add(new pickListValues ('ZW','Zimbabwe'));
        return JSON.serialize(countryOptions);
    }
    
    
    
    public class BySupplierWrapper{
        public String supplier{get;set;}
        public Map<String,Decimal> costWithCurrency{get;set;}
        public List<ByComponentWrapper> lstComponents{get; set;}
        
        public BySupplierWrapper(String supplier, List<ByComponentWrapper> lstComponents, Map<String,Decimal> costWithCurrency){
            this.lstComponents = lstComponents;
            this.supplier = supplier;
            this.costWithCurrency = costWithCurrency;
        }
    }
    public class ByComponentWrapper{
        public String component{get; set;}
        public String costingCurrency{get; set;}
        public Decimal netCostInCC{get; set;}
        public Decimal roe{get; set;}
        public Decimal netCostInSC{get; set;}
        public Decimal margin{get; set;}
        public Decimal totalMarkUpValue{get; set;}
        
        public ByComponentWrapper(String component, String costingCurrency, Decimal netCostInCC, Decimal roe, Decimal netCostInSC, Decimal margin, Decimal totalMarkUpValue){
            this.component = component;
            this.costingCurrency = costingCurrency;
            this.netCostInCC = netCostInCC;
            this.roe = roe;
            this.netCostInSC = netCostInSC;
            this.margin = margin;
            this.totalMarkUpValue = totalMarkUpValue;
        }
    }
    //**** Wrapper Class Section ****//
    public Class SupplierCostWrapper{
        public String selectedClient{get; set;}
        public Boolean required{get; set;}
        public Map<String,Client_Group__c> mapClientGroup{get; set;}
        public List<picklistValues> lstClients{get; set;}
        public List<Supplier_Cost__c> lstSupplierCost{get; set;}
        
        public SupplierCostWrapper(String OppId){
            this.selectedClient = '';
            this.mapClientGroup = new Map<String,Client_Group__c>();
            this.lstClients = new List<picklistValues>();
            this.required  = true;
            for(Client_Group__c cg : [Select Id, Name,CG_Total_Adult_Members__c,CG_Total_Child_Members__c,CG_Total_Group_Members__c,CG_Total_Infant_Members__c  from Client_Group__c where CG_Opportunity__c  = :oppId order by Name]){
                this.lstClients.add(new picklistValues(cg.Id, cg.Name));    
                this.mapClientGroup.put(cg.Id,cg);
            }
            this.lstSupplierCost = new List<Supplier_Cost__c>();
        }
    } 
    
    public class SBCostWrapperBySupplier{
        public Supplier_Cost_Payment__c scp{get; set;}
        public List<Supplier_Cost__c> lstSupplierCost{get; set;}
        public Decimal totalCost{get; set;}
        public SBCostWrapperBySupplier(){
            totalCost = 0;
            lstSupplierCost = new List<Supplier_Cost__c>();
        }
    }
    
    public Class ItineraryDescription{
        public List<picklistValues> lstOptions;
        public Map<String,String> mapDescriptions;
        public ItineraryDescription(){
            this.lstOptions = new List<picklistValues>();
            this.mapDescriptions = new Map<String,String>();
        }
    }
    
    public class picklistValues{
        String label {get; set;}
        String value {get; set;}
        String type{get; set;}
        Boolean recommend{get; set;}
        String wtg{get; set;}
        String widgetyRefId {get; set;}
        public picklistValues(String value,String label){
            this.value = value;
            this.label = label;
            recommend = false;
        }
    }
}
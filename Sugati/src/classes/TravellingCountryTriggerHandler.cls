public with sharing class TravellingCountryTriggerHandler implements ITrigger{
    
    String imageId;
    String objectName;
    String marginString;
    String  country= '';
    Decimal oppMargin;
    
    boolean isIntFlight = false;
    
    Set<String> countries = new Set<String>();
    Set<String> oppIds = new Set<String>();
    Set<String> usrIds = new Set<String>();
    Set<String> setAttIds = new Set<String>();
    List<String> oppQueryId = new List<String>();

    List<Attachment> lstAtt  = new  List<Attachment>();
    List<Travelling_Country__c> travelCountriesList = new List<Travelling_Country__c>();
    List<Opportunity> lstOpp = new List<Opportunity>();
    List<String> travellingC = new List<String>(); 
    List<Travelling_Country__c> tcList = new List<Travelling_Country__c>();
    List<Images_AI__c> img = new List<Images_AI__c>();
    List<Opportunity> Opps = new  List<Opportunity>();
    List<Supplier_Booking__c> sbList = new List<Supplier_Booking__c>();
    List<Target_Mark_Up__c> tmuList = new List<Target_Mark_Up__c>();
    List<Recordtype> rtList= new List<Recordtype>();
    List<Margin__c> marginList = new List<Margin__c>();
    List<Margin__c> mg = new List<Margin__c>();
    
   
    Map<String, String> mapParentAttachment = new Map<String, String>();
    Map<String,List<Supplier_Booking__c>> mapOppSB = new Map<String,List<Supplier_Booking__c>>();
    Map<Decimal , Target_Mark_Up__c > mapTargetMarkUP = new Map<Decimal , Target_Mark_Up__c>();
    Map<String,String> mapRecordtype = new Map<String,String>();

    public TravellingCountryTriggerHandler(){
        objectName = Utility.getNameSpacePrefix()+'Supplier_Booking__c';
    }
    
    public void bulkBefore(Schema.sObjectType soType){
        lstAtt = [Select Id, ParentId, Name from Attachment where parentid in: countries AND name LIKE '%cover%' order by createdDate];
        tcList = [SELECT Id, TC_Accommodation_Region__c,Country_Name__c,TC_Cover_Image__c,TC_DestinationMap_Image_ID__c,TC_ImageID__c,TC_Selected__c,Stage__c,TC_Country__c,TC_Opportunity__c FROM Travelling_Country__c];
        sbList = [Select Id, recordTypeId,recordType.Name,SB_Own_Arrangement__c,SB_Opportunity__c  from Supplier_Booking__c
                   where SB_Opportunity__c in : oppIds order by SB_Order__c];
        tmuList = [Select Id, TMU_APC__c, TMU_FFP__c, TMU_TOMS_APC__c, TMU_TOMS_FFP__c, TMU_Target_Margin__c from Target_Mark_Up__c ] ; 
        rtList = [Select id,name,sobjecttype  from recordtype where sobjecttype = :objectName order by name];
        
        CheckingConditionOnDelete(); 
        beforeUpdateAndInsert();
        onDelete();
    
    
    }

    public void bulkAfter(Schema.sObjectType soType){
        CheckingConditionOnDelete();
        beforeUpdateAndInsert();
        onDelete();
   }
    
    public void beforeInsert(SObject so){}
    
    public void beforeUpdate(SObject oldSo, SObject so){}
    
    public void beforeDelete(SObject so){}
    
    public void afterInsert(SObject so){}
    
    public void afterUpdate(SObject oldSo, SObject so){}
    
    public void afterDelete(SObject so){}
    
    public void CheckingConditionOnDelete(){
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
       OppQuery(oppIds);
    }
    
    
    public List<Opportunity> OppQuery(Set<String> oppIds){
          for(Opportunity opp : [select id, OwnerId ,closeDate,O_Target_Mark_Up__r.TMU_APC__c, O_Target_Mark_Up__r.TMU_FFP__c,  O_Target_Mark_Up__r.TMU_TOMS_APC__c,O_Target_Mark_Up__r.TMU_TOMS_FFP__c,O_Target_Mark_Up__r.TMU_Target_Margin__c ,(Select Id, TC_Country__c, TC_Country__r.name from Travelling_Countries__r),  O_Departure_Date__c,O_Suggested_Margin__r.M_Margin__c,O_Return_Date__c ,O_Suggested_Margin__c from Opportunity where id in: oppIds]){
            Opps.add(opp);
          }
         return Opps;
    }
    
    
    
    public void beforeUpdateAndInsert(){
        for(Attachment att : lstAtt){
            setAttIds.add(att.Id);
            mapParentAttachment.put(att.ParentId,att.Id);
         }
       
       for(Opportunity opp : Opps){
            usrIds.add(opp.OwnerId);
        }
        
        img = [Select Id,AI_Image_ID__c,AI_Count__c from Images_AI__c where AI_User__c in :usrIds and AI_Image_ID__c in :setAttIds Order by AI_Count__c];
        if(img.size()>0){
            imageId = img[0].AI_Image_ID__c;
        }
        
        for(Travelling_Country__c tc :tcList ){
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
        }
      }
     
     public void onDelete(){
        for(Supplier_Booking__c sb :sbList){
             if(!mapOppSB.containsKey(sb.SB_Opportunity__c)){
                 mapOppSB.put(sb.SB_Opportunity__c, new List<Supplier_Booking__c>());    
             }
         }
         
         for(Target_Mark_Up__c tmu : tmuList){
              mapTargetMarkUP.put(tmu.TMU_Target_Margin__c,tmu);
         }
         isIntFlight= false;
         
         for(Recordtype rt : rtList ){
             mapRecordtype.put(rt.id,rt.name);
         }
         
         for(Opportunity opp: Opps){
            if(mapOppSB.containsKey(opp.Id)){
                 for(Supplier_Booking__c sb : mapOppSB.get(opp.Id)){
                     if(sb.recordType.Name == 'Int Flight'){
                        isIntFlight = true;
                    }
                 }
            }
            for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                 travellingC.add(tc.TC_Country__c);
            }
         
            if (opp.O_Suggested_Margin__c != null) {
                 opp.O_Suggested_Margin__c = null;
            }
            marginList =[select id,M_Book_From__c,M_Book_To__c ,M_Travel_From__c,M_Travel_To__c,M_Margin__c, M_Country__r.C_EU__c from Margin__c  WHERE M_Country__c IN :travellingC order by M_Margin__c asc];
            oppMargin = opp.O_Suggested_Margin__r.M_Margin__c; 
            for(Margin__c mrg : marginList ){
                if (opp.closeDate >= mrg.M_Book_From__c && opp.closeDate <= mrg.M_Book_To__c && opp.O_Departure_Date__c >= mrg.M_Travel_From__c && opp.O_Return_Date__c <= mrg.M_Travel_To__c ){
                  if(opp.O_Suggested_Margin__c == null || oppMargin  <= mrg.M_Margin__c){
                      opp.O_Suggested_Margin__c = mrg.id;
                      oppMargin = mrg.M_Margin__c;
                      List<Margin__c> mg = [Select Id, M_Margin__c, M_Country__r.C_EU__c from Margin__c  where Id  = :Opp.O_Suggested_Margin__c]; 
                      
                      if(mapTargetMarkUP.containsKey(mrg.M_Margin__c)){
                          opp.O_Target_Mark_Up__c = mapTargetMarkUP.get(mrg.M_Margin__c).Id;
                          if(mg.size() != 0){
                                if(mg[0].M_Country__r.C_EU__c){
                                    if(isIntFlight){
                                        opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(mrg.M_Margin__c).TMU_TOMS_APC__c; 
                                    }
                                    else{
                                        opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(mrg.M_Margin__c).TMU_TOMS_FFP__c; 
                                    }
                                }
                                else{
                                    if(isIntFlight){
                                        opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(mrg.M_Margin__c).TMU_APC__c; 
                                    }
                                    else{
                                        opp.O_Target_Mark_Up_Value__c = mapTargetMarkUP.get(mrg.M_Margin__c).TMU_FFP__c; 
                                    }   
                                }
                          }
                      }
                      
                      if(mrg.M_Country__r.C_EU__c){
                            opp.O_EU__c = true;
                      }
                      else{
                            opp.O_EU__c = false;
                      }
                 }
              }    
           }  
           opp.O_Country__c = '';
           for(Travelling_Country__c tc : opp.Travelling_Countries__r){
                country += tc.TC_Country__r.name+', ';
           }
           country = country.removeEnd(', ');
           opp.O_Country__c = country; 
           lstOpp.add(opp);
        }   
     }
     
     
      public void andFinally(){
          if(!lstOpp.isEmpty()){
            update lstOpp;  
          }
      }
       
  }
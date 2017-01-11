/******************************************************
*  Controller class for Destination Map Page
*  Author - Naval Sharma
*  Date - 12/12/2015
*******************************************************/

public with sharing class DestinationMapController{

    public DestinationMapController(ApexPages.StandardController controller) {
        String oppId = controller.getId();
        if(oppId != null){
            OppRec = [select id, Name,Account.Name,O_Agent__r.id,O_Agent__r.Name, O_Departure_Date__c, O_Return_Date__c,Owner.Name,Owner.Username,
                           O_Adult__c,O_Children__c,O_Infant__c,O_Map_Type__c,O_Holiday_Type__c,Amount,O_Outstanding__c,O_Destination_Map_Image_ID__c,O_Booking_Currency__c,
                           (Select Id, name, TC_Country__r.Name,TC_DestinationMap_Image_ID__c,TC_Accommodation_Region__c from Travelling_Countries__r)
                           from Opportunity  where Id=:oppId];
            strForSettingPage = JSON.serialize(getMapTravellingCountry());
        }
    }

    public String oppId {get; set;}
    public Opportunity OppRec {get; set;}
    public String Countrieslst {get; set;}
    public String CountryListAcc {get; set;}
    public Map<String,Set<String>> mapCountryToAccom {get; set;} 
    public Map<String, Set<String>>  MapCountryToWTGList {get; set;} 
    public String strForSettingPage{get; set;}
    public String strmapCountryToAccom{get; set;}
    public String strMapCountryToWTGList{get; set;}
    public DestinationMapController(){}
    
    public Map<String,Travelling_Country__c> getMapTravellingCountry(){
        Map<String,Travelling_Country__c> mapTC = new Map<String,Travelling_Country__c>();
        try{
            MapCountryToWTGList = new Map<String, Set<String>>();
            mapCountryToAccom = new Map<String,Set<String>>();
            Countrieslst = '';
            CountryListAcc = '';
            List<String> lstCountries = new List<String>();
            for(Travelling_Country__c tc : [SELECT Name, TC_Country__c, TC_DestinationMap_Image_ID__c, TC_Accommodation_Region__c, 
                                           TC_Country__r.name, TC_Country__r.C_Notes__c FROM Travelling_Country__c WHERE 
                                           TC_Opportunity__r.Id= :oppRec.Id  ORDER BY Country_Name__c]){
                mapTC.put(tc.TC_Country__r.Name, tc);    
            }
            for(Supplier_Booking__c sb : [SELECT id, SB_What_to_do__r.WH_Country__c, SB_Supplier__c, SB_Supplier__r.Name, SB_Supplier__r.S_Type__c, SB_Supplier__r.S_Country__c, SB_Supplier__r.S_Where_to_go__r.Name, SB_Supplier__r.S_Where_to_go__r.W_Country__c, SB_Where_to_go__c,SB_Where_to_go__r.W_Country__c,SB_Where_to_go__r.W_Country__r.name,SB_Where_to_go__r.name FROM
                                          Supplier_Booking__c WHERE SB_Opportunity__c = :OppRec.id
                                          ORDER BY SB_Order__c]){
                  /** List of selected where to go for travelling country*/
                  if((sb.SB_Where_to_go__r.W_Country__r.name != null && sb.SB_Where_to_go__r.W_Country__r.name != '') && (sb.SB_Where_to_go__r.name != null && sb.SB_Where_to_go__r.name != '')){
                      if(!MapCountryToWTGList.containsKey(sb.SB_Where_to_go__r.W_Country__r.name)){
                          MapCountryToWTGList.put(sb.SB_Where_to_go__r.W_Country__r.name,new Set<String>());
                      }
                      MapCountryToWTGList.get(sb.SB_Where_to_go__r.W_Country__r.name).add(sb.SB_Where_to_go__r.name+ '##' + sb.SB_Where_to_go__r.W_Country__r.Name);
                      Countrieslst += sb.SB_Where_to_go__r.W_Country__r.name+'  ';
                  }
                   /** List of selected accommodation for travelling country*/
                  if((sb.SB_Supplier__c != null && sb.SB_Supplier__r.name != '') && (sb.SB_Supplier__r.S_Country__c != null && sb.SB_Supplier__r.S_Type__c == 'Hotel')){
                      if(!mapCountryToAccom.containsKey(sb.SB_Supplier__r.S_Country__c)){
                          mapCountryToAccom.put(sb.SB_Supplier__r.S_Country__c, new Set<String>());
                      }
                      mapCountryToAccom.get(sb.SB_Supplier__r.S_Country__c).add(sb.SB_Supplier__r.name+ '##' + sb.SB_Supplier__r.S_Where_to_go__r.Name);
                      CountryListAcc += sb.SB_Supplier__r.S_Country__c +'  ';
                  }
             }
             strmapCountryToAccom = JSON.serialize(mapCountryToAccom);
             strMapCountryToWTGList = JSON.serialize(MapCountryToWTGList);
             return mapTC;
         }
         catch(Exception e){
             return mapTC;
         }
    }
    
    public Map<Integer,String> getASCIIMap(){
        Map<Integer,String> ASCIIMap = new Map<Integer,String>(); 
        ASCIIMap.put(65,'A');
        ASCIIMap.put(66,'B');
        ASCIIMap.put(67,'C');
        ASCIIMap.put(68,'D');
        ASCIIMap.put(69,'E');
        ASCIIMap.put(70,'F');
        ASCIIMap.put(71,'G');
        ASCIIMap.put(72,'H');
        ASCIIMap.put(73,'I');
        ASCIIMap.put(74,'J');
        ASCIIMap.put(75,'K');
        ASCIIMap.put(76,'L');
        ASCIIMap.put(77,'M');
        ASCIIMap.put(78,'N');
        ASCIIMap.put(79,'O');
        ASCIIMap.put(80,'P');
        ASCIIMap.put(81,'Q');
        ASCIIMap.put(82,'R');
        ASCIIMap.put(83,'S');
        ASCIIMap.put(84,'T');
        ASCIIMap.put(85,'U');
        ASCIIMap.put(86,'V');
        ASCIIMap.put(87,'W');
        ASCIIMap.put(88,'X');
        ASCIIMap.put(89,'Y');
        ASCIIMap.put(90,'AA');
        ASCIIMap.put(91,'AB');
        ASCIIMap.put(92,'AC');
        ASCIIMap.put(93,'AD');
        ASCIIMap.put(94,'AE');
        ASCIIMap.put(95,'AF');
        ASCIIMap.put(96,'AG');
        ASCIIMap.put(97,'AH');
        ASCIIMap.put(98,'AI');
        ASCIIMap.put(99,'AJ');
        return ASCIIMap;
    }
}
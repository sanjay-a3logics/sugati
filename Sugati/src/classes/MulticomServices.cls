/*****
  Description - Class which provides helper method to communicate with multicom
  Author - Naval Sharma 
  Date - 6th, Sept, 2106
******/
public without sharing class MulticomServices{
    
    //Method which do a callout to Multicom server and returns results to the caller method
    public static String getAccommodationDataFromMutlicom(MCAccommodationSearchDetails searchDetails){
        
        List<MCAccommodation> lstMCAccommodation = new List<MCAccommodation>();
        
        String xmlRequest = MulticomServices.generateXMLRequest(searchDetails);  
        
        // Instantiate a new http object
        Http h = new Http();
    
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(MulticomSetting__c.getInstance().API_Endpoint_URL__c    );
        req.setMethod('POST');
        req.setBody(xmlRequest);
        req.setTimeout(30000);
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
        
    }
    
    
    private static String generateXMLRequest(MCAccommodationSearchDetails searchDetails){
        
        MulticomSetting__c multicomSetting = MulticomSetting__c.getInstance();
        
        String xmlRequest = '';
        xmlRequest += '<?xml version="1.0" encoding="UTF-8"?>';
        xmlRequest += '<FAB_AccomAvailRQ Target="test" Version="2002A" xmlns="http://www.xmltravel.com/fab/2002/09">';
        xmlRequest += '<SyndicatorInfo SyndicatorId="' + multicomSetting.Syndicator_Id__c + '" SyndicatorPassword="' + multicomSetting.Syndicator_Password__c + '"/>';
        xmlRequest += '<SessionInfo CreateNewSession="true"/>';
        xmlRequest += '<AccommodationSearchRequest ResponseTimeoutSecs="120" ShowDescriptions="true" ShowImages="true">';
        xmlRequest += '<ResultSetPreferences SortCode="cost" MaxItems="100"/>';
        xmlRequest += '<InitialViewInfo Offset="0" Length="50"/>';
        xmlRequest += '<FilterCode>description_required</FilterCode>';
        
        xmlRequest += '<SearchCriteria NumberOfNights="' + searchDetails.noOfNights + '" ResortName="' + searchDetails.resortName + '">';
        xmlRequest += '<StartDateRange StartDate="' + searchDetails.startDate + '" EndDate="' + searchDetails.endDate + '"/>';
        xmlRequest += '</SearchCriteria>';
        
        xmlRequest += '</AccommodationSearchRequest>';
        
        xmlRequest += '</FAB_AccomAvailRQ>';
        
        system.debug('Multicom XML request' + xmlRequest);
        
        return xmlRequest;
    }
    
    
    //Class to encapsulate Mutlicom Accommodation results
    public class MCAccommodation{
        
        String description;
    }
    
    
    //Class to encapsulate Mutlicom Accommodation search details
    public class MCAccommodationSearchDetails{
        
        String resortName;
        String noOfRooms;
        String startDate;
        String endDate;
        String noOfNights;
        String noOfAdults;
        String noOfChildren;
        String noOfInfants;
        
        //Intialize with blank values
        public MCAccommodationSearchDetails(){
            
            this.resortName = '';
            this.noOfRooms = '1';
            this.startDate = '';
            this.endDate = '';
            this.noOfNights = '1';
            this.noOfAdults = '1';
            this.noOfChildren = '0';   
            this.noOfInfants = '0';   
        }
    }
}
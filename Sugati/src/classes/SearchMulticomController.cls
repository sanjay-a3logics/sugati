/*****
  Description - Class to communicate with multicom to find accommodation 
  Author - Naval Sharma 
  Date - 6th, Sept, 2106
******/
public without sharing class SearchMulticomController{
    
    
    public Contact tempContact {get; set;}
    
    //Constructor to intialize properties with detault values
    public SearchMulticomController(){
        
        tempContact = new Contact();
    }
    
    
    
    /**** Method which return JSON representaion of MulticomServices.MCAccommodationSearchDetails object to page  ****/
    public String getMCAccSearchDetails(){
        return JSON.serialize(new MulticomServices.MCAccommodationSearchDetails());
    }
    
    
    
    /*** Method which search bed banks (Accommodation) on Mutlicom server  ***/
    @RemoteAction
    public static String searchMulticom(String searchDetailsJSON){
        
        try{    
            //Create object from the JSON 
            MulticomServices.MCAccommodationSearchDetails searchDetailsInfo = (MulticomServices.MCAccommodationSearchDetails) JSON.deserialize(searchDetailsJSON, MulticomServices.MCAccommodationSearchDetails.class);
            
            List<MulticomServices.MCAccommodation> MCSearchResults = new List<MulticomServices.MCAccommodation>();
            //API callout to search on Multicom
            return MulticomServices.getAccommodationDataFromMutlicom(searchDetailsInfo);
            
        }
        Catch(Exception e){
            
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage());
            return null;
        }
    }    
}
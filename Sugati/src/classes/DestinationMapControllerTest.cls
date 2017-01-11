/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "DestinationMapController"
* 
**/
 
@isTest
public class  DestinationMapControllerTest {

    @testSetup
    static void setupTestData(){
        
        List<Opportunity> lstOpportunities = TestServices.createOpportunityRecords(1, null);
        List<Travelling_Country__c> travellingCountries = TestServices.createTravellingCountries(lstOpportunities[0].Id);
        List<Where_to_go__c> WTGRecords = TestServices.createWTGRecords(travellingCountries[0].TC_Country__c);
        List<Supplier__c> supplierRecords = TestServices.createSupplierRecords(travellingCountries[0].TC_Country__c);
        List<Supplier_Booking__c> supplierBookingRecords = TestServices.createSupplierBookings(supplierRecords[1].Id, lstOpportunities[0].Id);
        
        supplierBookingRecords[0].SB_Where_to_go__c = WTGRecords[0].Id;
        update supplierBookingRecords[0];
    }  
    
    /** Test methods to test functionality of DestinationMapController **/
    static testMethod void testMethod1(){
        
        Opportunity opp = [SELECT id FROM Opportunity Limit 1];
        ApexPages.standardController controller = new ApexPages.standardController(opp);
        DestinationMapController dmc = new DestinationMapController(controller);
        System.assertNotEquals(dmc.OppRec.Id, Null);
        dmc.getMapTravellingCountry();
        dmc.getASCIIMap();
        DestinationMapController defaultDMC = new DestinationMapController();
    }
    
}
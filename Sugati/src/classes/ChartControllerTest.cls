/**
*  @Author         :   Naval Sharma
*  @Date           :   1-Mar-2016
*  @Description    :   Test class for "ChartController"
* 
**/
 
@isTest
public class  ChartControllerTest {

    /** Create test data for executing test cases  **/
    @testSetup
    static void createTestData(){
      
        //Insert an opportunity record
        Opportunity opp = TestServices.createOpportunityRecords(1, null)[0];
        List<Travelling_Country__c> travellingCountries = TestServices.createTravellingCountries(opp.Id);
        List<Supplier__c> supplierRecords = TestServices.createSupplierRecords(travellingCountries[0].TC_Country__c);
        List<Supplier_Booking__c> supplierBookingRecords = TestServices.createSupplierBookings(supplierRecords[1].Id, opp.Id);
        TestServices.createSupplierCostRecords(supplierRecords[0].Id, TestServices.createClientGroupRecords(2, opp.Id)[0].Id);
    }
    
    /** Test various operations of ChartController  **/
    static testMethod void testChartController1(){
        
        Opportunity opp = [SELECT id FROM Opportunity Limit 1];
        Apexpages.standardController controller = new Apexpages.standardController(opp);
        
        ChartController ccDefault = new ChartController();
        ChartController ccStandard = new ChartController(controller);
        
        /*** Static methods ****/
        System.assertNotEquals(ChartController.getChartDataStr(opp.Id), Null);
        System.assertNotEquals(ChartController.getChartDataByClient(opp.Id), Null);
    }
    
}
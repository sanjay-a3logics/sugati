/**
 *  @Author         :   Naval Sharma
 *  @Date           :   23-Feb-2016
 *  @Description    :   Test class for "Triggers"
 * 
 * */
 
@isTest
public class TriggersTest{
    
    @testSetup
    static void setupTestData() {
        //Create custom setting
        TestServices.createTriggerCustomSetting();
        TestServices.createSiteCustomSetting();
        
        //Insert an opportunity record
        Opportunity opp = TestServices.createOpportunityRecords(1, null)[0];
        
        //Insert contact records
        Account acc = [Select Id From Account Limit 1];
        System.assertNotEquals(acc, null);
        TestServices.createContactRecords(4, acc.Id);
        
        //Create Client Group records
        TestServices.createClientGroupRecords(2, opp.Id);
        
        //Create Country records
        TestServices.createCountryRecords();
        
        //Create Margin Record
        Country__c country = [Select Id from Country__c Limit 1];
        Margin__c margin = new Margin__c(
            M_Travel_From__c = opp.O_Departure_Date__c.addDays(-10), 
            M_Book_From__c = opp.CloseDate.addDays(-10), 
            M_Travel_To__c = opp.O_Return_Date__c.addDays(-10), 
            M_Book_To__c = opp.CloseDate.addDays(10),
            M_Country__c = country.Id
        );
        insert margin;
        
        //Create Target Markup
        TestServices.createTargetMarkups();
    }
    
    //Testing Group_Member__c trigger
    static testMethod void GroupMember_Test(){
        Test.startTest();
        
        List<Client_Group__c> cgList = [Select Id, CG_Opportunity__c from Client_Group__c];

        List<Group_Member__c> gmList = new List<Group_Member__c>();
        
        for(Contact con : [Select id from Contact]){
            Group_Member__c gm = new Group_Member__c(GM_Client_Group__c = cgList[0].Id, GM_Contact__c = con.Id, GM_Opportunity__c = cgList[0].CG_Opportunity__c);    
            gmList.add(gm);
        }
        insert gmList;
        
        gmList[0].GM_Lead_Passenger__c = true;
        update gmList;
        
        delete gmList[0];
        Test.stopTest();
    }
    
    //Testing Travelling_Country__c trigger
    static testMethod void TravellingCountry_Test(){
        Test.startTest();
        Opportunity opp = [Select Id FROM Opportunity Limit 1];
        System.assertNotEquals(opp.Id, null);
        
        //Update Suggested Margin of opportunity
        Margin__c margin = [Select Id from Margin__c limit 1];
        opp.O_Suggested_Margin__c = margin.Id;
        update opp;
        
        List<Travelling_Country__c> lstTravellingCountries = new List<Travelling_Country__c>();
        for(Country__c country : [Select Id from Country__c]){
            lstTravellingCountries.add( new Travelling_Country__c(TC_Country__c = country.Id, TC_Opportunity__c = opp.Id) );    
        }
        insert lstTravellingCountries;
        
        Exchange_Rate__c exRate = [Select Id from Exchange_Rate__c Limit 1];
        System.assertNotEquals(exRate.Id, null);
        
        Attachment att = new Attachment(body = Blob.valueOf('test'), Name = 'coverImage', parentId = lstTravellingCountries[1].Id);
        insert att;
        System.assertNotEquals(att.Id, null);
        
        lstTravellingCountries[1].TC_Cover_Image__c = true;
        lstTravellingCountries[1].TC_ImageID__c = att.Id;
        lstTravellingCountries[0].TC_Exchange_Rate__c = exRate.Id;
        update lstTravellingCountries;
        
        delete lstTravellingCountries[0];
        
        opp.O_Suggested_Margin__c = null;
        update opp;
        
        lstTravellingCountries = new List<Travelling_Country__c>();
        for(Country__c country : [Select Id from Country__c]){
            lstTravellingCountries.add( new Travelling_Country__c(TC_Country__c = country.Id, TC_Opportunity__c = opp.Id) );    
        }
        insert lstTravellingCountries;
        
        Test.stopTest();
    }
    
    //Testing SupplierCost/SupplierPayments trigger
    static testMethod void testPaymentTriggers(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Country__c country = [SELECT Id FROM Country__c Limit 1];
        System.assertNotEquals(country.Id, NULL);
        
        Supplier__c supplier = TestServices.createSupplierRecords(country.Id)[0];
        TestServices.createSupplierBookings(supplier.Id, opp.Id);
        TestServices.createSupplierCostPayments(supplier.Id, opp.Id);
        Client_Group__c cg = [SELECT id from Client_Group__c Limit 1];
        TestServices.createSupplierCostRecords(supplier.Id, cg.Id);
        Test.stopTest();  
    }
    
    //Testing SupplierCost/SupplierPayments trigger
    static testMethod void testHolidaySuggestionTriggers(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Country__c country = [SELECT Id FROM Country__c Limit 1];
        System.assertNotEquals(country.Id, NULL);
        
        Supplier__c supplier = TestServices.createSupplierRecords(country.Id)[0];
        TestServices.createHolidaySuggestions(supplier.Id, opp.Id);
        Test.stopTest();  
    }
}
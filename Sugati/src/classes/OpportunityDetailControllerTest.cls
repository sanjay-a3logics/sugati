/**
 *  @Author         :   Naval Sharma
 *  @Date           :   5-March-2016
 *  @Description    :   Various operations test OpportunityDetailController
 * 
 * */

@isTest
class OpportunityDetailControllerTest{
    
    static testMethod void OpportunityDetailController1(){
        List<Opportunity> oppLst = TestServices.createOpportunityRecords(1, null);
        ApexPages.currentPage().getParameters().put('id', oppLst[0].Id); 
        OpportunityDetailController odc = new OpportunityDetailController();
        System.assertEquals(odc.getOppD().Id, odc.oppId);
        
        ApexPages.currentPage().getParameters().put('id', null); 
        OpportunityDetailController odc1 = new OpportunityDetailController();
        System.assertEquals(odc1.getOppD(), null);
        System.assertEquals(odc1.logourl, null);
        System.assertEquals(odc1.opp, null);
    }
}
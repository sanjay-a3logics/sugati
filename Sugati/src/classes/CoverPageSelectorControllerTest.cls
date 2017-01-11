/**
*  @Author         :   Naval Sharma
*  @Date           :   25-Feb-2016
*  @Description    :   Test class for "CoverPageSelectorController"
* 
**/

@isTest
public with sharing class CoverPageSelectorControllerTest {
    public static testMethod Void testCoverPage(){
               
        test.startTest();
        /* Creating Records for Continet__c custom object*/
       
        List<Opportunity>opList=new List<Opportunity>();  
        Opportunity opp=new opportunity();
        opp.name='opp1';
        opp.CloseDate=system.today()+4;
        opp.stageName='Enquiry';
        opList.add(opp);
        insert opList;
        
        List<Continent__c> ConList=new List<Continent__C>();
        Continent__c Con=new Continent__c();
        Con.Name='TestCon';
        ConList.add(Con);
        insert ConList;
        
                    
        List<Country__c> countries = TestServices.createCountryRecords();
        
        List<Travelling_Country__c>tconList=new List<Travelling_Country__c>();
        Travelling_Country__c tcon = new Travelling_Country__c();
        tcon.TC_country__c = countries[0].Id;
        tcon.TC_Opportunity__c = opp.Id;
        tcon.TC_Cover_Image__c = true;
        tcon.TC_ImageID__c = 'testImage';
        tcon.TC_Selected__c = system.today()+4;
        //tcon.setSize();
        tconList.add(tcon);
        insert tconList;
        
        
        List<Where_to_go__c> wtgList = TestServices.createWTGRecords(countries[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        CoverPageSelectorController coverPage = new CoverPageSelectorController(sc);
        
        coverPage.getTravellingCountryImages();
        coverPage.getWTGImages();
        
        coverPage.displayMessage='test';
        coverPage.oppId= opList[0].Id;
        coverPage.isSuccess=true;
        coverPage.getWTGImages();
        coverPage.getTravellingCountryImages();
        
        Attachment att = [Select id from Attachment Limit 1];
        //Call save method
        System.assertNotEquals(wtgList[0].Id, null);
        String wtgId = wtgList[0].Id;
        String tcId = tconList[0].Id;
        String oppId = opList[0].Id;
        CoverPageSelectorController.saveCoverImages(coverPage.lstCountryImageWrapper, coverPage.lstWTGImageWrapper, '', wtgId, att.Id, oppId);
        CoverPageSelectorController.saveCoverImages(coverPage.lstCountryImageWrapper, coverPage.lstWTGImageWrapper, tcId, '', att.Id, oppId);
        CoverPageSelectorController.saveCoverImages(coverPage.lstCountryImageWrapper, coverPage.lstWTGImageWrapper, '', '', att.Id, oppId);
        coverPage.navigateTo();
        test.stopTest();
    }
       
}
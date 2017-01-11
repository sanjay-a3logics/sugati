@isTest
public class CalculateWeekClassTest
{
    public static testMethod void runOnceTest()
    {
        CalculateWeekClass.RunOnce();
    }
    public static testMethod void calculateBWeekTest()
    {
        Test.startTest();
        list<Opportunity> oppList=new list<Opportunity>();
        
        for(Integer i=0;i<=5;i++)
        {
            Opportunity opp= new Opportunity();
            opp.name='Test'+i;
            opp.CurrencyIsoCode='';
           if(i==0) {
                opp.CloseDate=date.newinstance(2013, 1, 1);
              opp.O_Booking_Date__c=date.newinstance(2012, 1, 1); 
               
                } else if(i==1) {
                opp.CloseDate=date.newinstance(2013, 1, 1);
                opp.O_Booking_Date__c=date.newinstance(2013, 1, 4);
               
            } else if(i==2) {
                opp.CloseDate=date.newinstance(2013, 1, 1);
                opp.O_Booking_Date__c=date.newinstance(2012, 1, 4);
                
            } else if(i==3) {
                opp.CloseDate=date.newinstance(2013, 1, 6);
                opp.O_Booking_Date__c=date.newinstance(2012, 1, 4);
               
            } else if(i==4) {
                opp.CloseDate=date.newinstance(2013, 1, 4);
                opp.O_Booking_Date__c=date.newinstance(2012, 1, 4);
                
            } else {
                opp.CloseDate=date.newinstance(2013, 1, 8);
                opp.O_Booking_Date__c=date.newinstance(2012, 1, 4);
            }
            opp.StageName='Enquiry';
            oppList.add(opp);
        }
        insert oppList;
        set<string> ids=new set<string>();
        list<Opportunity> allId=[SELECT id,name,StageName,O_Booking_Week__c,O_Booking_Date__c,O_Booking_Week_Actual__c FROM Opportunity WHERE id in:oppList];
        for(Opportunity op:allId){
           String stringId = (String) op.Id;
            ids.add(stringId);
        }
        CalculateWeekClass cwc=new calculateWeekClass();
        cwc.calculateBWeek(ids, 4.0);
        Test.stopTest();
    }
    public static testMethod void calculateEWeekTest()
    {
       Test.startTest();
       list<Opportunity> oppList1=new list<Opportunity>();
        for(Integer i=0;i<=5;i++)
        {
            Opportunity opp1= new Opportunity();
            opp1.name='Testing'+i;
            
            opp1.CurrencyIsoCode='';
            if(i==0) {
                opp1.CloseDate=date.newinstance(2017, 1, 1);
              opp1.O_Booking_Date__c=date.newinstance(2011, 1, 1); 
                
            } else if(i==1) {
                opp1.CloseDate=date.newinstance(2017, 1, 2);
                opp1.O_Booking_Date__c=date.newinstance(2011, 1, 3);
               
            } else if(i==2) {
                 opp1.CloseDate=date.newinstance(2017, 1, 3);
                opp1.O_Booking_Date__c=date.newinstance(2011, 1, 2);
                
            } else if(i==3) {
                opp1.CloseDate=date.newinstance(2017, 1, 3);
                opp1.O_Booking_Date__c=date.newinstance(2011, 1, 3);
                
            } else if(i==4) {
                opp1.CloseDate=date.newinstance(2017, 1, 4);
                opp1.O_Booking_Date__c=date.newinstance(2011, 1, 5);
                
            } else {
                opp1.CloseDate=date.newinstance(2017, 1, 5);
                opp1.O_Booking_Date__c=date.newinstance(2011, 1, 5);
                
            }
            
            opp1.StageName='Enquiry';
           
            oppList1.add(opp1);
        }
        insert oppList1; 
        set<string> ids1=new set<string>();
        list<Opportunity> allId1=[SELECT id FROM Opportunity WHERE id in:oppList1];
        for(Opportunity op1:allId1){
           String stringId1 = (String) op1.Id;
            ids1.add(stringId1);
        }
        CalculateWeekClass cwc1=new calculateWeekClass();
        cwc1.calculateEWeek(ids1, 4.0);
        Test.stopTest();
    }
    
     public static testMethod void calculateQWeekTest()
    {
        Test.startTest();
        list<Opportunity> oppList2=new list<Opportunity>();
        
        for(Integer i=0;i<=5;i++)
        {
            Opportunity opp2= new Opportunity();
            opp2.name='Test'+i;
            opp2.CurrencyIsoCode='';
           if(i==0) {
                opp2.CloseDate=date.newinstance(2013, 1, 1);
              opp2.O_Quote_Date__c=date.newinstance(2012, 1, 1); 
               
                } else if(i==1) {
                opp2.CloseDate=date.newinstance(2013, 1, 1);
                opp2.O_Quote_Date__c=date.newinstance(2013, 1, 4);
               
            } else if(i==2) {
                opp2.CloseDate=date.newinstance(2013, 1, 1);
                opp2.O_Quote_Date__c=date.newinstance(2012, 1, 5);
                
            } else if(i==3) {
                opp2.CloseDate=date.newinstance(2013, 1, 6);
                opp2.O_Quote_Date__c=date.newinstance(2012, 1, 6);
               
            } else if(i==4) {
                opp2.CloseDate=date.newinstance(2013, 1, 4);
                opp2.O_Quote_Date__c=date.newinstance(2012, 1, 7);
                
            } else {
                opp2.CloseDate=date.newinstance(2013, 1, 8);
                opp2.O_Quote_Date__c=date.newinstance(2012, 1, 3);
            }
            opp2.StageName='Enquiry';
            oppList2.add(opp2);
        }
        insert oppList2;
        set<string> ids2=new set<string>();
        list<Opportunity> allId2=[SELECT id,name,StageName,O_Booking_Week__c,O_Booking_Date__c,O_Booking_Week_Actual__c FROM Opportunity WHERE id in:oppList2];
        for(Opportunity op2:allId2){
           String stringId2 = (String) op2.Id;
            ids2.add(stringId2);
        }
        CalculateWeekClass cwc2=new calculateWeekClass();
        cwc2.calculateQWeek(ids2, 5.0);
        Test.stopTest();
    }
    
    /** Test various function of CalculateWeekClass apex class  **/
    static testMethod void testCalculateWeekClassMethods(){
        //Create custom setting
        TestServices.createTriggerCustomSetting();
        TestServices.createSiteCustomSetting();
        
        //Insert an opportunity record
        Opportunity opp = TestServices.createOpportunityRecords(1, null)[0];
        opp.O_Quote_Date__c = Date.today();
        update opp;
        //Insert contact records
        Account acc = [Select Id From Account Limit 1];
        System.assertNotEquals(acc, null);
        Test.startTest();
        
        Set<String> oppIds = new Set<String>();
        oppIds.add(opp.Id);
        CalculateWeekClass cwc = new CalculateWeekClass();
        CalculateWeekClass.RunOnce();
        System.assertEquals(CalculateWeekClass.firstRun, false);
        cwc.calculateBWeek(oppIds, 2.0);
        cwc.calculateEWeek(oppIds, 2.0);
        cwc.calculateQWeek(oppIds, 2.0);
        Test.stopTest();
    }
}
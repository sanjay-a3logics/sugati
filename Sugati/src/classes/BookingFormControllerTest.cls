/**
 *  @Author         :   Naval Sharma
 *  @Date           :   2-Feb-2016
 *  @Description    :   Test class for "BookingFormController"
 * 
 * */
 
@isTest
public Class BookingFormControllerTest{
    
    @testSetup 
    static void testSetupMethod() {
        Holiday_Type__c ht= new Holiday_Type__c(Name='testHoliday');
        insert ht ;  
        system.assert(ht.Id != null); 
        
        Account TestAcc = new Account(Name = 'Test Test1');
        insert TestAcc ;  
        system.assert(TestAcc.Id != null);  
        
        Contact cont = new Contact(Salutation='testsal',LastName='testL',FirstName='testF',email='testemail@a.com',AccountId=TestAcc.Id);
        insert cont;
        system.assert(cont.Id != null);
        Opportunity opp =  new Opportunity (AccountId = TestAcc.Id,StageName = 'Enquiry',name = 'TestOpportunity',CloseDate = Date.today(),O_Departure_Date__c = Date.today(),O_Return_Date__c = Date.today(),
                                     O_Holiday_Type__c=ht.Id, Amount=1024, CurrencyISOCode='GBP');
        insert opp;
        system.assert(opp.Id != null);
        
        List<Client_Group__c> cgList = TestServices.createClientGroupRecords(2, opp.Id);
         
        List<Group_Member__c> gmList = new List<Group_Member__c>();
        
        for(Contact con : [Select id from Contact]){
            Group_Member__c gm = new Group_Member__c(GM_Client_Group__c = cgList[0].Id, GM_Contact__c = con.Id, GM_Opportunity__c = cgList[0].CG_Opportunity__c);    
            gmList.add(gm);
        }
        insert gmList;
        
        Client_Payment__c cp = new Client_Payment__c(CP_Receipt_AmountEx__c =90,CP_Opportunity__c=opp.id);
        insert cp;
        system.assert(cp.Id != null);
        
        Continent__c cn = new Continent__c(name='testcon');
        insert cn ;
        system.assert(cn.Id != null);   
        
        Country__c c= new Country__c(name='testcoun',C_Continent__c=cn.Id);
        insert c ;
        system.assert(c.Id != null);   
        
        Travelling_Country__c tc = new Travelling_Country__c(TC_Opportunity__c=opp.Id,TC_Country__c=c.Id);      
        insert tc;
        system.assert(tc.Id != null);   
                  
    }
    
    static testmethod void testMethod1(){
        List<Opportunity> opp = [Select ID from Opportunity];
        system.assert(opp[0].id != null);   
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp[0]); 
        ApexPages.currentPage().getParameters().put('id',opp[0].id); 
        BookingFormController AIC = new BookingFormController(stdctrl );
    }
    
    static testmethod void testMethod2(){
        List<Opportunity> opp = [Select ID, AccountId from Opportunity];
        system.assert(opp[0].id != null);   
        Contact con = new Contact(AccountId = opp[0].AccountId, FirstName = 'Test', LastName = 'Test1', C_Lead_Passenger__c = true);
        insert con;
        List<Client_Group__c> cgList = [Select Id, CG_Opportunity__c from Client_Group__c];
        Group_Member__c gm = new Group_Member__c(GM_Client_Group__c = cgList[0].Id, GM_Contact__c = con.Id, GM_Opportunity__c = cgList[0].CG_Opportunity__c, GM_Lead_Passenger__c = true);    
        insert gm;
        system.assert(gm.id != null);   
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp[0]); 
        ApexPages.currentPage().getParameters().put('id',opp[0].id); 
        BookingFormController AIC = new BookingFormController(stdctrl );
    }
    
    static testmethod void testMethod3(){
        List<Opportunity> opp = [Select ID, AccountId from Opportunity];
        system.assert(opp[0].id != null);   
         
        ApexPages.StandardController stdctrl = new  ApexPages.StandardController(opp[0]); 
        ApexPages.currentPage().getParameters().put('id',opp[0].id); 
        BookingFormController AIC = new BookingFormController(stdctrl );
        AIC.getSalutaionOptions();
        AIC.getnationalityOptions();
        AIC.Confirm();
    }
}
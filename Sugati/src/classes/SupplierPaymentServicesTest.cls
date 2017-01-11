@isTest
private class SupplierPaymentServicesTest{
@testSetup
    static void testData(){
        String RecordtypeId1 = [Select id, Name from Recordtype where (name='Deposit') AND SObjectType = 'Supplier_Payment_Rule__c'].id;
        String RecordtypeId2 = [Select id, Name from Recordtype where (name='Balance') AND SObjectType = 'Supplier_Payment_Rule__c'].id;
        
        Account A = new Account(Name='Test');
        insert A;
        System.assert(A.Id != null);
        
        Supplier__c SpObj = new Supplier__c(Name='Test', S_Type__c='Flight');
        Insert SpObj;
        system.assert(SpObj.Id != null);
        
        Opportunity Opp = new Opportunity(Name='Test Op',AccountId=A.Id,StageName='Available',O_Booking_Date__c=System.Today().addDays(-20),O_Service_From_Date__c=System.Today().addDays(-18),
                                       CloseDate=System.Today().addDays(30));
        Insert Opp;
        System.assert(Opp.Id != null);
        
        Supplier_Cost_Payment__c SCP1 = new Supplier_Cost_Payment__c(SCP_Opportunity__c=Opp.Id, SCP_Supplier__c=SpObj.Id);
        Insert SCP1;
        System.assert(SCP1.Id != null);
        
        Supplier_Cost_Payment__c SCP2 = new Supplier_Cost_Payment__c(SCP_Opportunity__c=Opp.Id, SCP_Supplier__c=SpObj.Id);
        Insert SCP2;
        System.assert(SCP2.Id != null);
        
        Supplier_Booking__c SB1 = new Supplier_Booking__c(SB_Opportunity__c=Opp.Id/*, SB_Supplier_Cost_and_Payment__c=SCP1.Id,SB_Sell__c=100*/);
        insert SB1;
        System.assert(SB1.Id != null);
        
        Supplier_Booking__c SB2 = new Supplier_Booking__c(SB_Opportunity__c=Opp.Id/*, SB_Supplier_Cost_and_Payment__c=SCP2.Id,SB_Sell__c=100*/);
        insert SB2;
        System.assert(SB2.Id != null);
        
        Supplier_Payment_Rule__c spr1 = new Supplier_Payment_Rule__c(SPR_Amount__c=10,SPR_Balance_Due_Date__c=System.Today().addDays(-20),SPR_Balance_Due_Day__c=20,SPR_Confirmation_From_Date__c=System.Today().addDays(-20),
                                       SPR_Confirmation_To_Date__c=System.Today().addDays(20),SPR_Deposit_Due__c='At Confirmation',SPR_Deposit_Due_Date__c=System.Today().addDays(-10),SPR_Deposit_Due_Day__c=10,SPR_Notify_for_Balance__c=true,
                                       SPR_Notify__c=true,Percent_Value__c='value', SPR_Service_From_Date__c=System.Today().addDays(-100),SPR_Service_To_Date__c=System.Today().addDays(100),
                                       SPR_Supplier__c=SpObj.id,SPR_Supplier_Payment_Due_Type__c='At Confirmation',SPR_Active__c=true,RecordtypeId=RecordtypeId1);
        insert spr1;
        System.assert(spr1.Id != null);
        Supplier_Payment_Rule__c spr2 = new Supplier_Payment_Rule__c(SPR_Amount__c=10,SPR_Balance_Due_Date__c=System.Today().addDays(-20),SPR_Balance_Due_Day__c=20,SPR_Confirmation_From_Date__c=System.Today().addDays(-20),
                                       SPR_Confirmation_To_Date__c=System.Today().addDays(20),SPR_Deposit_Due__c='At Confirmation',SPR_Deposit_Due_Date__c=System.Today().addDays(-10),SPR_Deposit_Due_Day__c=10,SPR_Notify_for_Balance__c=true,
                                       SPR_Notify__c=true,Percent_Value__c='Percent', SPR_Service_From_Date__c=System.Today().addDays(-100),SPR_Service_To_Date__c=System.Today().addDays(100),
                                       SPR_Supplier__c=SpObj.id,SPR_Supplier_Payment_Due_Type__c='Specific Date',SPR_Active__c=true,RecordtypeId=RecordtypeId2);
        insert spr2;
        System.assert(spr2.Id != null);
        
        Supplier_Payment__c SP1 = new Supplier_Payment__c(SBP_Supplier_Cost_Currency_Value__c=SCP1.id,/*SP_Supplier__c=SpObj.id,*/P_Amount__c=100,SP_Type__c='Deposit');
        insert SP1;
        System.assert(Sp1.Id != null);
        
        Supplier_Payment__c SP2 = new Supplier_Payment__c(SBP_Supplier_Cost_Currency_Value__c=SCP1.id,/*SP_Supplier__c=SpObj.id,*/P_Amount__c=100,SP_Type__c='Balance');
        insert SP2;
        System.assert(Sp2.Id != null);
    }
    static testMethod void testisrefresh() {
        Opportunity opp = [select Id,StageName,Name,O_Booking_Date__c,O_Service_From_Date__c FROM Opportunity LIMIT 1];
        Supplier_Payment_Rule__c spr = [Select Id,SPR_Deposit_Due__c,SPR_Supplier_Payment_Due_Type__c from Supplier_Payment_Rule__c where recordtype.name='Balance' limit 1];
        List<opportunity> lstopp = [select Id FROM Opportunity LIMIT 1];
        Opportunity newOpp = new Opportunity();
        Test.StartTest();
        SupplierPaymentServices spsObj1 = new SupplierPaymentServices();
        SupplierPaymentServices.createSupplierPayments(new Set<Id>{lstopp[0].id});
        SupplierPaymentServices spsObj2 = new SupplierPaymentServices();
        SupplierPaymentServices.createSupplierPayments(new Set<Id>{lstopp[0].id});
        SupplierPaymentServices.isBookedRecently(newOpp,opp);
        SupplierPaymentServices.isBooked(newOpp);
        SupplierPaymentServices.isRefresh = true;
        SupplierPaymentServices.createSupplierPayments(new Set<Id>{lstopp[0].id});
        Test.StopTest();   
    }
}
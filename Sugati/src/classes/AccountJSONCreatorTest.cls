@isTest
public with sharing class AccountJSONCreatorTest {
    @isTest 
    public static void testGetJSON() {
        Account testAcct = new Account(name = 'Test Account');
        Transfer_Option__c testToOption = new Transfer_Option__c(name = 'Test TO Account', TO_Archive__c = false);
        
        insert testAcct;
        insert testToOption;

        AccountJSONCreator acctJSON = new AccountJSONCreator();
        /**
         * Test with valid AccName param        
         */
        apexpages.currentpage().getparameters().put('AccName' , 'Test Account');
        apexpages.currentpage().getparameters().put('TO' , null);
        
        List<AccountJSONCreator.AccountWrapper> wrp1 = new List<AccountJSONCreator.AccountWrapper>();
        wrp1.add(new AccountJSONCreator.AccountWrapper(testAcct.Name, testAcct.Id));
        
        System.assertEquals(JSON.serialize(wrp1), acctJSON.getJSON());
        
        /**
         * Test with valid TO param       
         */
        apexpages.currentpage().getparameters().put('AccName' , null);
        apexpages.currentpage().getparameters().put('TO' , 'TO Account');
        
        List<AccountJSONCreator.AccountWrapper> wrp2 = new List<AccountJSONCreator.AccountWrapper>();
        wrp2.add(new AccountJSONCreator.AccountWrapper(testToOption.Name, testToOption.Id));
        
        System.assertEquals(JSON.serialize(wrp2), acctJSON.getJSON());
         
        /**
         * Test with invalid AccName param        
         */
        List<AccountJSONCreator.AccountWrapper> wrp3 = new List<AccountJSONCreator.AccountWrapper>();
        
        apexpages.currentpage().getparameters().put('AccName' , 'Not Exist Account');
        apexpages.currentpage().getparameters().put('TO' , null);
        
        System.assertEquals(JSON.serialize(wrp3), acctJSON.getJSON());
        
        /**
         * Test with invalid TO param        
         */
        apexpages.currentpage().getparameters().put('AccName' , null);
        apexpages.currentpage().getparameters().put('TO' , 'Not Exist');
        
        System.assertEquals(JSON.serialize(wrp3), acctJSON.getJSON());
        
        /**
         * Test with blank AccName param and blank TO param
         */
        apexpages.currentpage().getparameters().put('AccName' , null);
        apexpages.currentpage().getparameters().put('TO' , null);
        
        System.assertEquals(JSON.serialize(wrp3), acctJSON.getJSON());      
    }
    
    @isTest 
    public static void testNullToBlank() {
        AccountJSONCreator acctJSON = new AccountJSONCreator();
        
        System.assertEquals('', acctJSON.nullToBlank(null));
        System.assertEquals('Test', acctJSON.nullToBlank('Test'));
    }
}
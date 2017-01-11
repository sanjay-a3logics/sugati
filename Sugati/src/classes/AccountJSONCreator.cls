public with sharing class AccountJSONCreator {

    public String getJSON()
    {
        String AccountName = Apexpages.currentPage().getParameters().get('AccName');
        String tOptions = Apexpages.currentPage().getParameters().get('TO');
        List<AccountWrapper> wrp = new List<AccountWrapper>();
        if(AccountName != null){
            for (Account a : [Select a.Id, a.Website, a.Name, a.BillingCountry, a.BillingCity
                                From Account a WHERE Name Like : '%'+AccountName+'%' ]) {
               AccountWrapper w = new AccountWrapper (a.Name, a.Id);
               wrp.add(w);
            }
        }
        else if(tOptions != null){
            for(Transfer_Option__c to : [Select Id, Name
                                From Transfer_Option__c a WHERE Name Like : '%'+tOptions+'%' and TO_Archive__c = false]) {
               AccountWrapper w = new AccountWrapper (to.Name, to.Id);
               wrp.add(w);
            }    
        }
        return JSON.serialize(wrp);
    }

    public String nullToBlank(String val)
    {
        return val == null ?'':val;
    }

    public class AccountWrapper
    {
        String label,value;

        public AccountWrapper(String aName, String i)
        {
            label = aName;
            value= i ;
        }
    }

    
}
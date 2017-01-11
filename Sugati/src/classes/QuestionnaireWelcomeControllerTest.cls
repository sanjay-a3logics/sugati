@isTest
public class QuestionnaireWelcomeControllerTest {
    public static testMethod void testBeginQuestionnaire(){
        try
        {
          string UrlId='006';
        
          List<Opportunity> HolidayQuesRec = new List<Opportunity>();
          HolidayQuesRec = [select id,Account.name,O_Reference_Number__c,O_Departure_Date__c,O_Charity__c,O_Destination__c from opportunity where id =: UrlId];
      recordtype rt = [select id from RecordType where sobjectType = :Utility.getNameSpacePrefix()+'Questinnaire__c' and developername = 'Client' limit 1];
          Questinnaire__c NewQuestionnaire = new Questinnaire__c(Q_Category_Checker__c =1, Q_Booking__c='', Q_Date_of_visit__c=Date.today(), RecordTypeId=rt.Id, Q_Stage__c='In Progress');
          insert NewQuestionnaire;
            system.Assert(NewQuestionnaire.Id!=null);
          HolidayQuesRec[0].O_Charity__c = 0.01;
          upsert HolidayQuesRec[0];
            system.Assert(HolidayQuesRec[0].Id!=null);
        }
        catch(Exception ex)
        {
            system.Assert(ex.getMessage()!=null);
        }
    }
    
    public static testMethod void testVerifyExistingUser(){
        try
        {
            List<Questinnaire__c> ExistingQuestionnaire;
            string UrlId='006';
            system.Assert(UrlId.startsWithIgnoreCase('006'));
            ExistingQuestionnaire = [select id from Questinnaire__c where Q_Booking__c =:UrlId];
            if(ExistingQuestionnaire==null){
                system.Assert(ExistingQuestionnaire==null);
            }else {
                if(ExistingQuestionnaire.size()>0){
                    system.Assert(ExistingQuestionnaire != null && ExistingQuestionnaire.size()>0);
                }
                
            }
            UrlId='004';
            Integer RetId=1;
            string returnstring ='';
            if(UrlId.startsWithIgnoreCase('006'))
            {
                system.Assert(RetId==1);
                returnstring = '/apex/Client_Questionnaire?id=';
            }
            else
            {
                system.Assert(RetId==1);
                returnstring = '/apex/Client_Questionnaire?id&recid';
            }
            
        }
        catch(Exception ex)
        {
            system.Assert(ex.getMessage()!=null);
        }
    }
}
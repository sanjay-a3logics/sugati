/************************************************
** Module Name : <Name of the Apex Class/Trigger>
** Description : <Description on the functionality of the class>
** Throws : <Any Exceptions/messages thrown by this  class/triggers>
** Calls : <Any classes/utilities called by this class | None if it does not call>
** Test Class : <Name of the test class that is used test this class>
** 
** Organization : Sugati
**
** Revision History:-
** Version    Date       Author      WO#     Description of Action
** 1.0        2-8-2016     Suraj Tripathi  NA     <NNNN>  Initial Version
************************************************/
@isTest
public class  ClientQuestionnaireControllerTest {
  Public Static Opportunity oot;
  Public Static Account aat;
  Public Static Case cct;
  Public Static Questinnaire__c qqt;
  Public Static Questionnaire_Question_Category__c qqcTe;
  Public Static Questionnaire_Question__c qqCt;
  Public Static Questionnaire_Answer__c  ops;
   public static testMethod void testRunAs() {
      // Setup test data
      // This code runs as the system user

         Profile p = [select id from profile where name='Standard User']; 
         User u = new User(alias = 'standdt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standard2133user@testorg.com');


         System.runAs(u) {
           // The following code runs as user 'u' 

          Account testAccount = new Account(name='Test Company Name');
         insert testAccount;
         
         testAccount.billingState='CA';
         update testAccount;

         // Verify that the billingState field was updated in the database.
         Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
         System.assertEquals('CA', updatedAccount.billingState);

         // CORRECT - In this case, I need to update a Product to have a productcode ='RTR2000'
         // So I create that Product2 record in my test method itself. 
         Product2 prod = new Product2(name='Router');
         insert prod;
         
         prod.productcode='RTR2000';
         update prod;

         // Verify that the productcode field was updated in the database.
         Product2 updatedProduct = [SELECT productcode FROM Product2 WHERE Id = :prod.Id];
         System.assertEquals('RTR2000', updatedProduct.productcode);


           System.debug('Current User: ' + UserInfo.getUserName());
           System.debug('Current Profile: ' + UserInfo.getProfileId()); }
           // Run some code that checks record sharing
        }


public static testMethod void saveAnswersMultipleChoice() {
  createRecords('Multiple-choice');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();
controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 4;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.progressbarRec.put(1,1);
    controller.progressbarRec.put(2,2424);
    controller.progressbarRec.put(3,322);
    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';
List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ1 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ1.QuestionObj = createQuestionnaire('Multiple-choice','Client',NULL);
    tQQ1.optionsOfAnswer = new List<SelectOption>(); 
    tQQ1.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ1.selectedAnswer = 'asdfassdfasdf';
    tQQ1.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ1.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ1.UserEnteredText = 'asdfasdff';
    tQQ1.answerVal = createQuestionnaireAnswer('Multiple-choice');
    listQuestionarWrapper.add(tQQ1);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.VerifyCompleteQuestionnarie();
    ClientQuestionnaireController.CustomIterable kk = new ClientQuestionnaireController.CustomIterable(test3);
    //controller.next();
    
    kk.hasPrevious();
    //kk.previous();
    controller.SaveAnswers();


}

public static testMethod void saveAnswersSingleChoice() {
  createRecords('Single-choice');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();
controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 1;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.progressbarRec.put(1,1);
    controller.progressbarRec.put(2,2424);
    controller.progressbarRec.put(3,322);
    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';
List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ2 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ2.QuestionObj = createQuestionnaire('Single-choice','Client',NULL);
    tQQ2.optionsOfAnswer = new List<SelectOption>(); 
    tQQ2.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ2.selectedAnswer = 'asdfassdfasdf';
    tQQ2.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ2.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ2.UserEnteredText = 'asdfasdff';
    tQQ2.answerVal = createQuestionnaireAnswer('Single-choice');
    listQuestionarWrapper.add(tQQ2);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.VerifyCompleteQuestionnarie();
    controller.next();
    //controller.previous();
    controller.SaveAnswers();

}
public static testMethod void saveAnswersSingleChoicewithOther() {
createRecords('Multiple choice with other text box');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();

controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 1;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.progressbarRec.put(1,1);
    controller.progressbarRec.put(2,2424);
    controller.progressbarRec.put(3,322);

    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';
    List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ2 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ2.QuestionObj = createQuestionnaire('Multiple choice with other text box','Client',NULL);
    tQQ2.optionsOfAnswer = new List<SelectOption>(); 
    tQQ2.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ2.selectedAnswer = 'asdfassdfasdf';
    tQQ2.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ2.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ2.UserEnteredText = 'asdfasdff';
    tQQ2.answerVal =createQuestionnaireAnswer('Multiple choice with other text box');
    listQuestionarWrapper.add(tQQ2);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.SaveAnswers();

}
public static testMethod void saveAnswerstext() {
  createRecords('Text');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();
controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 1;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';
List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ2 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ2.QuestionObj = createQuestionnaire('Text','Client',NULL);
    tQQ2.optionsOfAnswer = new List<SelectOption>(); 
    tQQ2.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ2.selectedAnswer = 'asdfassdfasdf';
    tQQ2.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ2.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ2.UserEnteredText = 'asdfasdff';
    tQQ2.answerVal = createQuestionnaireAnswer('Text');
    listQuestionarWrapper.add(tQQ2);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.SaveAnswers();

}
public static testMethod void saveAnswersSingleChoicewithText() {
  createRecords('Single choice with text Box');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();
controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 1;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';
List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ2 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ2.QuestionObj = createQuestionnaire('Single choice with text Box','Client',NULL);
    tQQ2.optionsOfAnswer = new List<SelectOption>(); 
    tQQ2.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ2.selectedAnswer = 'asdfassdfasdf';
    tQQ2.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ2.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ2.UserEnteredText = 'asdfasdff';
    tQQ2.answerVal = createQuestionnaireAnswer('Single choice with text Box');
    listQuestionarWrapper.add(tQQ2);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.SaveAnswers();

}

public static testMethod void saveAnswersSingleChoicewithotherText() {
createRecords('Single choice with other text box');
  ApexPages.currentPage().getParameters().put('id', oot.id);
       ApexPages.currentPage().getParameters().put('pnum', '1');
       ApexPages.currentPage().getParameters().put('isAtt', 'true');

ClientQuestionnaireController controller = new ClientQuestionnaireController();
controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
    controller.NoOfQuestions = 32.5;
    controller.NoOfQuestionsVisited = 32;
    controller.CurrentPageNo = 1;
    controller.progressbarRec = new Map<Integer,Integer>();
    controller.TotalQuesVisited = 32;
    controller.errorMessage = '32.5';
    controller.percentIncrement = 35.6;
    controller.CompleteQuestionnaire = TRUE;
    controller.requiredFieldchecker = TRUE;
    controller.ExistQues = TRUE;
    controller.oldQuestions = new Set<String>();
    controller.newQuestions = new Set<String>();
    controller.modifiedQuestions = new Set<String>();
    controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    controller.recordtypeName = 'H_S';



List<ClientQuestionnaireController.QuestionnaireQuesWrapper> listQuestionarWrapper = new List<ClientQuestionnaireController.QuestionnaireQuesWrapper>();
    
    ClientQuestionnaireController.QuestionnaireQuesWrapper tQQ2 = new ClientQuestionnaireController.QuestionnaireQuesWrapper();
    tQQ2.QuestionObj = createQuestionnaire('Single choice with other text box','Client',NULL);
    tQQ2.optionsOfAnswer = new List<SelectOption>(); 
    tQQ2.optionsOfAnswer.add(new SelectOption('asdf','asdf'));
    tQQ2.selectedAnswer = 'asdfassdfasdf';
    tQQ2.answerObj = new Map<String,Questionnaire_Answer_Options__c>();
    tQQ2.answerObj.put('asdfassdfasdf', new Questionnaire_Answer_Options__c());
    tQQ2.UserEnteredText = 'asdfasdff';
    tQQ2.answerVal = createQuestionnaireAnswer('Single choice with other text box');
    listQuestionarWrapper.add(tQQ2);

    List<ClientQuestionnaireController.CategoriesWrapper> test3 = new List<ClientQuestionnaireController.CategoriesWrapper>();
    test3.add(new ClientQuestionnaireController.CategoriesWrapper( qqcTe , listQuestionarWrapper ));
    controller.lstSetController = test3;
    controller.SaveAnswers();

}
public static testMethod void testMyController() {
       
       Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
            User u = new User(firstname= 'System',
            lastname='Admin',
            Alias='AdminSA2',
            email = 'dio23n@myemail.com',
            username= 'dw223ion@myemail.com', 
            profileId= p.id, 
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            timezonesidkey='America/Los_Angeles');
            insert u;

    System.runAs(u) {    
      //Create the permission set
      PermissionSet ps = new PermissionSet();
      ps.Name = 'Write_Access_To_Audit_Fields';
      ps.Label = 'Write Access To Audit Fields';

      //Provide write access to audit fields
      //ps.PermissionsCreateAuditFields = true; 
      insert ps;

      //Assign the permission set to the current user   
      PermissionSetAssignment psa = new PermissionSetAssignment();
      psa.AssigneeId = UserInfo.getUserId();
      psa.PermissionSetId = ps.Id;
      insert psa;
      
    Account a = new Account();
    a.YearStarted='1920'; 
    a.Website='www.salesforce.com'; 
    a.SLASerialNumber__c='12'; 
    a.SLAExpirationDate__c=system.today()+4; 
    a.CustomerPriority__c='test'; 
    a.AccountNumber='testAccount'; 
    a.A_What_Prompted_This_Enquiry__c='test'; 
    a.A_Update__c=true; 
    a.A_Type_of_Travel__c='test1'; 
    a.A_Supplier_Type__c='testSupplier'; 
    a.A_Salutation__c='Mr'; 
    a.A_Region__c='CA'; 
    a.A_Middle_Name__c='testname'; 
    a.A_Last_Name__c='testLastName'; 
     
    a.A_How_Heard__c='testHeard'; 
    a.A_How_Heard_Details__c='testDesc'; 
    a.A_Household_No__c=2456; 
    a.A_First_Name__c='testName'; 
    a.A_Email__c='hc@gmail.com'; 
    a.A_Campaign_Code__c=''; 
    a.A_Agree_to_receive_brochure__c=TRUE; 
    a.A_Address_Line_3__c='Noida'; 
    a.A_Address_Line_2__c='UP'; 
    a.A_Address_Line_1__c='India'; 
    a.Name='asdfasdfassdf';
    //a.CreatedDate = System.Today().AddDays(-4); 
    insert a;

    Account aa = [SELECT Name FROM Account LIMIT 1 ];
    Opportunity o = new Opportunity();
    o.Type= 'asdf' ; 
    o.TrackingNumber__c= 'asdf' ; 
    o.TotalOpportunityQuantity= 33 ; 
    o.Thank_you_note__c= System.Now() ; 
    o.Taking_deposit__c=  System.Now(); 
    o.Take_balance_payment_and_issue_receipt__c= System.Now() ; 
    o.StageName=  'Prospecting'; 
    o.Something_not_available__c=   System.Now(); 
    o.Send_recommendations__c= System.Now()  ; 
    o.Send_goodbye_email__c=  System.Now() ; 
    o.Send_confirmation_documents__c=  System.Now() ; 
    o.Seat_check_and_online_check_in__c=  System.Now() ; 
    o.Return_questionnaire__c=   System.Now(); 
    o.Name = 'Test Me323';
    o.CloseDate = System.Today();
    o.AccountID = aa.ID;
    //o.CreatedDate = System.Today().AddDays(-3); 
    insert o;
    Opportunity oo34 = [SELECT Name FROM Opportunity WHERE NAME = 'Test Me323' LIMIT 1];

     Questinnaire__c q = new Questinnaire__c();
     q.StatusNA__c='tests32';
     q.Q_Stage__c='won';
     q.Q_Date_of_visit__c=system.today()+4;
     q.Q_Completed_Date__c=system.today()+2;
     q.Q_Category_Checker__c=2;
     //q.CreatedDate = System.Today().AddDays(-2); 
     q.Q_Audit_By__c='audit';
     q.Q_Booking__c = oo34.Id;
     insert q;
     Questinnaire__c qq= [SELECT Name FROM Questinnaire__c WHERE StatusNA__c='tests32' LIMIT 1];
     Record_Type__c rt1 = new Record_Type__c();
     rt1.RT_Active__c = TRUE;
     rt1.RT_SObject_Type__c = 'Opportunity';
     rt1.Name='Client';
    //rt1.CreatedDate = System.Today().AddDays(-1); 
     insert rt1;
     Record_Type__c rt2 = new Record_Type__c();
     rt2.RT_Active__c = TRUE;
     rt2.RT_SObject_Type__c = 'Opportunity';
     rt2.Name='H_S';
     //rt2.CreatedDate = System.Today().AddDays(-1); 
     insert rt2;
     
     Record_Type__c rt3 = new Record_Type__c();
     rt3.RT_Active__c = TRUE;
     rt3.RT_SObject_Type__c = 'Opportunity';
     rt3.Name='Client';
     //rt2.CreatedDate = System.Today().AddDays(-1); 
     insert rt3;
     
     Record_Type__c rtt = [SELECT Name , RT_Active__c FROM Record_Type__c WHERE Name = 'Client' LIMIT 1];
     String QuestionType4 ='Text';
     RecordType rt90= [SELECT Name FROM RecordType WHERE Name='H&S' LIMIT 1];


    Questionnaire_Question_Category__c qqc = new Questionnaire_Question_Category__c();
    qqc.name = 'sadf32';
    qqc.QQC_Live__c = TRUE ;
    qqc.QQC_Order__c= '1';
    qqc.QQC_Introduction_Text__c= 'asdfasdfasdfasdf'+QuestionType4;
    qqc.Record_Type__c = rtt.Id;
    qqc.RecordType = rt90;
    //qqc.CreatedDate  = System.Today().AddDays(-1); 
    insert qqc;
    String introText = 'asdfasdfasdfasdf'+QuestionType4 ;
    Questionnaire_Question_Category__c qqqwt = [SELECT name,QQC_Live__c ,QQC_Order__c ,QQC_Introduction_Text__c ,
    Record_Type__r.Name FROM Questionnaire_Question_Category__c WHERE Name = 'sadf32' LIMIT 1];

    Questionnaire_Question__c qqq = new Questionnaire_Question__c();
    qqq.QQ_Live__c = TRUE;
    qqq.QQ_Order__c = 1;
    qqq.QQ_Question__c = 'Hellaasdfere?'+QuestionType4;
    String questioType =  'Hellaasdfere?'+QuestionType4;
    qqq.QQ_Required__c = TRUE;
    qqq.Q_Question_Type__c =   QuestionType4;
    qqq.QQ_Questionnaire_Question_Category__c =qqqwt.Id; 
    //qqq.CreatedDate = System.Today().AddDays(-1); 
    insert qqq;
    Questionnaire_Question__c qqqt = [SELECT QQ_Questionnaire_Question_Category__c, Name,QQ_Live__c,Q_Question_Type__c,
    QQ_Required__c, QQ_Question__c,QQ_Order__c FROM  Questionnaire_Question__c WHERE QQ_Question__c =: questioType LIMIT 1];

    createQuestionnaire(QuestionType4,'H_S',qqqt );

  //Case m = createRecords('Text');
         //Add parameters to page URL
    //createQuestionnaire('Text',NULL);
         ApexPages.currentPage().getParameters().put('id', oo34.id);
         ApexPages.currentPage().getParameters().put('pnum', '1');
         ApexPages.currentPage().getParameters().put('isAtt', 'true');
       
         //Instantiate a new controller with all parameters in the page
         ClientQuestionnaireController controller = new ClientQuestionnaireController();
         PageReference nextPage = controller.VerifyCompleteQuestionnarie();

         //Example of calling the 'setter' method for several properties. 
         //Normally these setter methods are initiated by a user interacting with the Visualforce page, 
         //but in a test method, just call the setter method directly. 
         controller.UrlId =oo34.id;  
         controller.QuestionnaireCategoryLst = new List<ClientQuestionnaireController.CategoriesWrapper>();
         controller.lstSetController = new List<ClientQuestionnaireController.CategoriesWrapper>();
         controller.NoOfQuestions = 32.5;
         controller.NoOfQuestionsVisited = 32;
         controller.CurrentPageNo = 1;
         controller.next();
         controller.progressbarRec = new Map<Integer,Integer>();
         controller.TotalQuesVisited = 32;
         controller.errorMessage = '32.5';
         controller.percentIncrement = 35.6;
         controller.CompleteQuestionnaire = TRUE;
         controller.requiredFieldchecker = TRUE;
         controller.ExistQues = TRUE;
         controller.oldQuestions = new Set<String>();
         controller.newQuestions = new Set<String>();
         controller.modifiedQuestions = new Set<String>();
         controller.newToOldQuestionMap = new Map<String, ClientQuestionnaireController.QuestionnaireQuesWrapper>();
         controller.recordtypeName = 'Client';
          

          PageReference nextPage2 = controller.RedirectThankYou();
        //>>>>>>>>>>>>>>>>>>>> nextPage = controller.save().getUrl();
  }
       //Verify that the success page displays
    //   System.assertEquals('/apex/success', nextPage);
       
   }

public static Questionnaire_Question__c createQuestionnaire(String QuestionType4 , String recortypeName, Questionnaire_Question__c oldQuestions ){
    Record_Type__c rt = new Record_Type__c();
    rt.RT_Active__c = TRUE;
    rt.RT_SObject_Type__c = 'Opportunity';
    rt.Name=recortypeName;
    insert rt;
    Record_Type__c rtt = [SELECT Name , RT_Active__c FROM Record_Type__c LIMIT 1];

    Questionnaire_Question_Category__c qqc = new Questionnaire_Question_Category__c();
    qqc.name = 'sadf';
    qqc.QQC_Live__c = TRUE ;
    qqc.QQC_Order__c= '1';
    qqc.QQC_Introduction_Text__c= 'asdfasdfasdfasdf'+QuestionType4;
    qqc.Record_Type__c = rtt.Id;
    insert qqc;
    String introText = 'asdfasdfasdfasdf'+QuestionType4 ;
        Questionnaire_Question_Category__c qqqwt = [SELECT name,QQC_Live__c ,QQC_Order__c ,QQC_Introduction_Text__c ,
        Record_Type__r.Name FROM Questionnaire_Question_Category__c  LIMIT 1];


    Questionnaire_Question__c qqq = new Questionnaire_Question__c();
    qqq.QQ_Live__c = TRUE;
    qqq.QQ_Order__c = 1;
    qqq.QQ_Question__c = 'Hell is here?'+QuestionType4;
    qqq.QQ_Required__c = TRUE;
    qqq.Q_Question_Type__c =   QuestionType4;
    qqq.QQ_Questionnaire_Question_Category__c =qqqwt.Id; 
    List<Questionnaire_Question__c> listfilterValue = [SELECT QQ_Live__c FROM Questionnaire_Question__c 
    WHERE QQ_Questionnaire_Question_Category__r.RecordType.Name='H_S' ];
    if(listfilterValue.size()!= 0)
    {
      qqq.QQ_Old_Question__c = listfilterValue[0].ID;

    }
    
    insert qqq;
    Questionnaire_Question__c qqqt = [SELECT QQ_Questionnaire_Question_Category__c, Name,QQ_Live__c,Q_Question_Type__c,
    QQ_Required__c, QQ_Question__c,QQ_Order__c FROM  Questionnaire_Question__c WHERE Q_Question_Type__c =: QuestionType4 LIMIT 1];

    return qqqt;



}

public static  Case createRecords( String questtionType5) {



  Account a = new Account();
  a.YearStarted='1920'; 
  a.Website='www.salesforce.com'; 
  a.SLASerialNumber__c='12'; 
  a.SLAExpirationDate__c=system.today()+4; 
  a.CustomerPriority__c='test'; 
  a.AccountNumber='testAccount'; 
  a.A_What_Prompted_This_Enquiry__c='test'; 
  a.A_Update__c=true; 
  a.A_Type_of_Travel__c='test1'; 
  a.A_Supplier_Type__c='testSupplier'; 
  a.A_Salutation__c='Mr'; 
  a.A_Region__c='CA'; 
  a.A_Middle_Name__c='testname'; 
  a.A_Last_Name__c='testLastName'; 
   
  a.A_How_Heard__c='testHeard'; 
  a.A_How_Heard_Details__c='testDesc'; 
  a.A_Household_No__c=2456; 
  a.A_First_Name__c='testName'; 
  a.A_Email__c='hc@gmail.com'; 
  a.A_Campaign_Code__c=''; 
  a.A_Agree_to_receive_brochure__c=TRUE; 
  a.A_Address_Line_3__c='Noida'; 
  a.A_Address_Line_2__c='UP'; 
  a.A_Address_Line_1__c='India'; 
  a.Name='asdfasdfassdf';
  insert a;

  Account aa = [SELECT Name FROM Account LIMIT 1 ];
  aat=aa;
  Case c = new Case();
  c.Type='testno';
  c.SuppliedPhone='testPhone'; 
  c.SuppliedName='testFirstName'; 
  c.SuppliedEmail='supply@gmail.com'; 
  c.SuppliedCompany='Cloud'; 
  c.Subject='Salesforce'; 
  c.Status='teststatus'; 
  c.SLAViolation__c='testsalutaion'; 
  c.Reason='testReason'; 
   
  c.Priority='high'; 
  c.PotentialLiability__c='emg'; 
  c.EngineeringReqNumber__c='eng'; 
  c.Description='testDescription';  
  c.AccountId= aa.ID;
   insert c;
  Case cc = [SELECT Reason FROM Case LIMIT 1];
  cct=c;
  Opportunity o = new Opportunity();
  o.Type= 'asdf' ; 
  o.TrackingNumber__c= 'asdf' ; 
  o.TotalOpportunityQuantity= 33 ; 
  o.Thank_you_note__c= System.Now() ; 
  o.Taking_deposit__c=  System.Now(); 
  o.Take_balance_payment_and_issue_receipt__c= System.Now() ; 
  o.StageName=  'Prospecting'; 
  o.Something_not_available__c=   System.Now(); 
  o.Send_recommendations__c= System.Now()  ; 
  o.Send_goodbye_email__c=  System.Now() ; 
  o.Send_confirmation_documents__c=  System.Now() ; 
  o.Seat_check_and_online_check_in__c=  System.Now() ; 
  o.Return_questionnaire__c=   System.Now(); 
  o.Name = 'Test Me';
  o.CloseDate = System.Today();
  o.AccountID = aa.ID;
  insert o;
  Opportunity oo = [SELECT Name FROM Opportunity LIMIT 1];
  oot = oo;
   Questinnaire__c q = new Questinnaire__c();
   q.StatusNA__c='tests';
   q.Q_Stage__c='won';
   q.Q_Date_of_visit__c=system.today()+4;
   q.Q_Completed_Date__c=system.today()+2;
   q.Q_Category_Checker__c=2;
   
   q.Q_Audit_By__c='audit';
   q.Q_Booking__c = o.Id;
  insert q;
  Questinnaire__c qq= [SELECT Name FROM Questinnaire__c LIMIT 1];
  qqt=qq;
  Record_Type__c rt = new Record_Type__c();
  rt.RT_Active__c = TRUE;
  rt.RT_SObject_Type__c = 'Opportunity';
  rt.Name='Client';
  insert rt;


  Record_Type__c rtt = [SELECT Name , RT_Active__c FROM Record_Type__c LIMIT 1];

  Questionnaire_Question_Category__c qqc = new Questionnaire_Question_Category__c();
  qqc.name = 'sadf';
  qqc.QQC_Live__c = TRUE ;
  qqc.QQC_Order__c= '1';
  qqc.QQC_Introduction_Text__c= 'asdfasdfasdfasdf';
  qqc.Record_Type__c = rtt.Id;
  insert qqc;
  Questionnaire_Question_Category__c qwe = [SELECT QQC_Order__c FROM Questionnaire_Question_Category__c LIMIT 1];
  qqcTe = qwe;
  Questionnaire_Question__c qqq = new Questionnaire_Question__c();
  qqq.QQ_Live__c = TRUE;
  qqq.QQ_Order__c = 1;
  qqq.QQ_Question__c = 'Hell is here?';
  qqq.QQ_Required__c = TRUE;
  qqq.Q_Question_Type__c =   questtionType5;
  qqq.QQ_Questionnaire_Question_Category__c =qqc.Id; 
  insert qqq;
  Questionnaire_Question__c qqqt = [SELECT QQ_Questionnaire_Question_Category__c, Name,QQ_Live__c,Q_Question_Type__c,QQ_Required__c, QQ_Question__c,QQ_Order__c FROM  Questionnaire_Question__c LIMIT 1];

  qqCt =qqqt;
  Questionnaire_Answer_Options__c QAO = new Questionnaire_Answer_Options__c();
  QAO.Name = 'This is fun?';
  QAO.QAO_Questionnaire_Question__c = qqCt.Id; 
  QAO.QAO_Order__c = 1;
  QAO.QAO_Score__c =7;

  insert QAO;


  Questionnaire_Answer__c Qaa= new Questionnaire_Answer__c();
  Qaa.H_S_Defect_Answer__c =TRUE;
  Qaa.QA_Answer__c ='asdfasdf';
  Qaa.QA_Other__c ='asdfasdfasdf';
  Qaa.QQ_Translated_Answer__c= 'asdfasddf';
  Qaa.QA_Questionnaire__c = qqt.Id ; 
  Qaa.QA_Questionnaire_Answer_Option__c = QAO.Id;
  Qaa.QA_Questionnaire_Question__c = qqCt.Id;
  insert Qaa;
  ops = Qaa;
  return c;
}

public static Questionnaire_Answer__c createQuestionnaireAnswer( String questionType){


Record_Type__c rt = new Record_Type__c();
rt.RT_Active__c = TRUE;
rt.RT_SObject_Type__c = 'Opportunity';
rt.Name='Client';
insert rt;
Record_Type__c rtt = [SELECT Name , RT_Active__c FROM Record_Type__c LIMIT 1];

Questionnaire_Question_Category__c qqc = new Questionnaire_Question_Category__c();
qqc.name = 'sadf';
qqc.QQC_Live__c = TRUE ;
qqc.QQC_Order__c= '1';
qqc.QQC_Introduction_Text__c= 'asdfasdfasdfasdf';
qqc.Record_Type__c = rtt.Id;
insert qqc;
Questionnaire_Question_Category__c qwe = [SELECT QQC_Order__c FROM Questionnaire_Question_Category__c LIMIT 1];
Questionnaire_Question__c qqq = new Questionnaire_Question__c();
qqq.QQ_Live__c = TRUE;
qqq.QQ_Order__c = 1;
qqq.QQ_Question__c = 'Hell is here?';
qqq.QQ_Required__c = TRUE;
qqq.Q_Question_Type__c =   questionType;
qqq.QQ_Questionnaire_Question_Category__c =qwe.Id; 
insert qqq;
Questionnaire_Question__c qqqt = [SELECT QQ_Questionnaire_Question_Category__c, Name,QQ_Live__c,Q_Question_Type__c,QQ_Required__c, QQ_Question__c,QQ_Order__c FROM  Questionnaire_Question__c LIMIT 1];



Account a = new Account();
a.YearStarted='1920'; 
a.Website='www.saleasdfsforce.com'; 
a.SLASerialNumber__c='12'; 
a.SLAExpirationDate__c=system.today()+4; 
a.CustomerPriority__c='test'; 
a.AccountNumber='testAccount'; 
a.A_What_Prompted_This_Enquiry__c='test'; 
a.A_Update__c=true; 
a.A_Type_of_Travel__c='test1'; 
a.A_Supplier_Type__c='testSupplier'; 
a.A_Salutation__c='Mr'; 
a.A_Region__c='CA'; 
a.A_Middle_Name__c='testname'; 
a.A_Last_Name__c='testLastName'; 
 
a.A_How_Heard__c='tesasdtHeard'; 
a.A_How_Heard_Details__c='testDesc'; 
a.A_Household_No__c=2456; 
a.A_First_Name__c='testName'; 
a.A_Email__c='hc@gmail.com'; 
a.A_Campaign_Code__c=''; 
a.A_Agree_to_receive_brochure__c=TRUE; 
a.A_Address_Line_3__c='Noasfdida'; 
a.A_Address_Line_2__c='UP'; 
a.A_Address_Line_1__c='India'; 
a.Name='asdfasSSSSSdfassdf';
insert a;

Account aa = [SELECT Name FROM Account LIMIT 1 ];

Opportunity o = new Opportunity();
o.Type= 'asdf' ; 
o.TrackingNumber__c= 'asdf' ; 
o.TotalOpportunityQuantity= 33 ; 
o.Thank_you_note__c= System.Now() ; 
o.Taking_deposit__c=  System.Now(); 
o.Take_balance_payment_and_issue_receipt__c= System.Now() ; 
o.StageName=  'Prospecting'; 
o.Something_not_available__c=   System.Now(); 
o.Send_recommendations__c= System.Now()  ; 
o.Send_goodbye_email__c=  System.Now() ; 
o.Send_confirmation_documents__c=  System.Now() ; 
o.Seat_check_and_online_check_in__c=  System.Now() ; 
o.Return_questionnaire__c=   System.Now(); 
o.Name = 'Test Me';
o.CloseDate = System.Today();
o.AccountID = aa.ID;
insert o;
Opportunity oo = [SELECT Name FROM Opportunity LIMIT 1];

 Questinnaire__c q = new Questinnaire__c();
 q.StatusNA__c='tests';
 q.Q_Stage__c='won';
 q.Q_Date_of_visit__c=system.today()+4;
 q.Q_Completed_Date__c=system.today()+2;
 q.Q_Category_Checker__c=2;
 
 q.Q_Audit_By__c='audit';
 q.Q_Booking__c = oo.Id;
insert q;
Questinnaire__c q2 = [SELECT StatusNA__c, Q_Stage__c, Q_Date_of_visit__c, Q_Completed_Date__c, Q_Category_Checker__c FROM Questinnaire__c LIMIT 1];

Questionnaire_Answer_Options__c QAO = new Questionnaire_Answer_Options__c();
QAO.Name = 'This is fun?';
QAO.QAO_Questionnaire_Question__c = qqqt.Id;
QAO.QAO_Order__c = 1;
QAO.QAO_Score__c =7;

insert QAO;

Questionnaire_Answer_Options__c qAO2 = [SELECT Name, QAO_Questionnaire_Question__c,QAO_Order__c, QAO_Score__c FROM  Questionnaire_Answer_Options__c LIMIT 1];
Questionnaire_Answer__c Qaa= new Questionnaire_Answer__c();
Qaa.H_S_Defect_Answer__c =TRUE;
Qaa.QA_Answer__c ='asdfasdf';
Qaa.QA_Other__c ='asdfasdfasdf';
Qaa.QQ_Translated_Answer__c= 'asdfasddf';
Qaa.QA_Questionnaire__c = q2.Id ; 
Qaa.QA_Questionnaire_Answer_Option__c = qAO2.Id;
Qaa.QA_Questionnaire_Question__c = qqqt.Id;
insert Qaa;
return Qaa;



}


}
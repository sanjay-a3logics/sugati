public class ClientQuestionnaireThankYouController{

    public String UrlId  {get; set;}
    Questinnaire__c NewQuestionnaire;
    public Questinnaire__c questnnaire {get;set;}
    List<Questionnaire_Answer__c> SelectedAnswerRec;
    public List<String> QuestionsCategories{get;set;}
    public List<String> QuestionsCategories1{get;set;}
    public Map<String,Decimal> CategoryAnswerPercent{get;set;}
    public List<String> QuenstionCategoryName{get;set;}
    public Map<String,Map<String, AnswerDetailWrapper>> QuesAnsLst{get;set;}
   
    String bookingId;
    String PropertQuesId;
    public String stage {get;set;}
    public String propertyName {get;set;}
    public ClientQuestionnaireThankYouController(){
        try{
            AnswerDetailWrapper ADW1 = new AnswerDetailWrapper();
            List<AnswerDetailWrapper> ADWList = new List<AnswerDetailWrapper>();
            ADWList.add(ADW1);
            CategoriesWrapper CW = new CategoriesWrapper('Test',ADWList);
            UrlId  = APexpages.currentpage().getParameters().get('id');  
            NewQuestionnaire = new Questinnaire__c();
            stage = '';
           
            if(UrlId != null){
                RecordType rt;
               
                String recordtypeName =''; 
                QuestionsCategories = new List<String>();
                QuestionsCategories1 = new List<String>();
                // check for Id param
                if(UrlId.startsWithIgnoreCase('006')){
                    NewQuestionnaire = [select id,Q_Booking__c,Q_Category_Checker__c,Q_Date_of_visit__c,RecordTypeId from Questinnaire__c where Q_Booking__c =:UrlId limit 1];    
                    bookingId = NewQuestionnaire.Q_Booking__c;
                    recordtypeName = 'Client';                
                }
               /* else{
                    PropertQuesId = APexpages.currentpage().getParameters().get('RecId');
                    propertyName = [select id, name from Property__c where id=:UrlId limit 1].name; 
                    if(PropertQuesId != null){
                        questnnaire =  [select id,Q_Booking__c,Q_Category_Checker__c, Q_Audit_By__c, Q_Completed_Date__c, Q_Date_of_visit__c,Q_Stage__c,RecordTypeId from Questinnaire__c where id =:PropertQuesId limit 1];    
                        stage = questnnaire.Q_Stage__c;
                    }
                    recordtypeName = 'H_S';   
                }*/
                
               // rt = [select id from RecordType where sobjectType = 'Questionnaire_Question_Category__c' and developername =:recordtypeName  limit 1];
                
                Map<String,String> QuestionnaireCategoryInfo = new Map<String,String>();
                QuenstionCategoryName = new List<String>();
                
                // get the questionnaire category based on record type.
                for(Questionnaire_Question_Category__c Qc :[select id,name,RecordTypeId,QQC_Live__c,QQC_Order__c,QQC_Introduction_Text__c,Record_Type__r.name
                from Questionnaire_Question_Category__c where Record_Type__r.name =: 'Client' and QQC_Live__c = true order by QQC_Order__c asc]){
                       QuestionnaireCategoryInfo.put(String.valueOf(Qc.id),Qc.name);
                       QuenstionCategoryName.add(Qc.name);
                       
                }
                if(UrlId.startsWithIgnoreCase('006')){
                
                    Double i=Math.ceil(QuestionnaireCategoryInfo.size()/2);
                    Integer k = 0;
                    
                    for(String name : QuenstionCategoryName){
                    
                       if(k<=Math.ceil(QuestionnaireCategoryInfo.size()/2)){
                            QuestionsCategories.add(name);
                        }else{
                            QuestionsCategories1.add(name);
                        }
                        k++;
                    }
                   
                   
                    Map<String,Integer> TotalQ= new Map<String,Integer>();
                    Map<String,Decimal> AnsweredQuesOfCategories = new Map<String,Decimal>();
                    Map<String,Decimal> TotalQuesOfCategories = new Map<String,Decimal>();
                    
                    //Get all answered Question score
                    for(AggregateResult Qa : [select QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c category,sum(QA_Questionnaire_Answer_Option__r.QAO_Score__c) total  
                                                         from Questionnaire_Answer__c
                                                         where QA_Questionnaire__c =:NewQuestionnaire.id and QA_Questionnaire_Answer_Option__c != null
                                                         group by QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c
                                                         ]){
                                                     
                            AnsweredQuesOfCategories.put((String)Qa.get('category'),(Decimal)Qa.get('total'));
                    } 
                    
                    //Get all Questions of Categories
                    
                    List<Questionnaire_Question__c> ClientQuestions = [select id,QQ_Live__c,QQ_Order__c,QQ_Question__c,
                                                                            QQ_Questionnaire_Question_Category__c,Q_Question_Type__c 
                                                                            from Questionnaire_Question__c 
                                                                            where QQ_Questionnaire_Question_Category__c In : QuestionnaireCategoryInfo.keyset() and QQ_Live__c =true order by QQ_Order__c asc];
                    
                    Map<String,List<Questionnaire_Question__c>> CategoryRelatedQuestion = new Map<String,List<Questionnaire_Question__c>>();
                    if(ClientQuestions != null){
                        for(Questionnaire_Question__c QQc : ClientQuestions){
                          
                            if(!CategoryRelatedQuestion.containsKey(QQc.QQ_Questionnaire_Question_Category__c)){
                                CategoryRelatedQuestion.put(QQc.QQ_Questionnaire_Question_Category__c,new List<Questionnaire_Question__c>());
                            }
                            CategoryRelatedQuestion.get(QQc.QQ_Questionnaire_Question_Category__c).add(QQc);
                        }
                            
                        //Map all Questions with highest scored option
                        
                        for(AggregateResult  QQc : [select max(QAO_Score__c) maximum,QAO_Questionnaire_Question__c Question
                                                       from Questionnaire_Answer_Options__c
                                                       where QAO_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c IN : QuestionnaireCategoryInfo.keyset()  and QAO_Questionnaire_Question__r.Q_Question_Type__c IN('Single-choice','Single choice with text Box')
                                                     group by QAO_Questionnaire_Question__c]){
                                                       
                               TotalQuesOfCategories.put((String)QQc.get('Question'),(Decimal)QQc.get('maximum'));
                        }   
                        system.debug('-----------------kkkkkkk'+TotalQuesOfCategories);
                                                  
                        Map<String,Decimal> CategoryRelatedTotalScore= new Map<String,Decimal>();
                        
                        //Map Maximum Score of each category
                        
                        for(String cr : CategoryRelatedQuestion.keyset()){
                            Decimal temp = 0.0;
                                for(Questionnaire_Question__c qc : CategoryRelatedQuestion.get(cr)){
                                    if(TotalQuesOfCategories.get(qc.id) != null){
                                        temp = temp + TotalQuesOfCategories.get(qc.id);
                                    }
                                }
                            CategoryRelatedTotalScore.put(cr,temp);
                        }
                        
                        CategoryAnswerPercent = new Map<String,Decimal>();
                        
                        for(String cm : QuestionnaireCategoryInfo.keyset()){
                            Decimal val = 0.0;
                            if(AnsweredQuesOfCategories.get(cm) != null && CategoryRelatedTotalScore.get(cm) != null){
                                val = (AnsweredQuesOfCategories.get(cm)/CategoryRelatedTotalScore.get(cm)) * 100;
                            }
                            CategoryAnswerPercent.put(QuestionnaireCategoryInfo.get(cm),val);
                                 
                        }
                        
                   }
               }/***else {
                   
                   
                   //system.assert(false,QuestionnaireList);  
                   List<Questionnaire_Answer__c> AnsweredLst = new List<Questionnaire_Answer__c>();
                   
                   Map<String,List<Questionnaire_Answer__c>> CategoryRelatedAnswers = new Map<String,List<Questionnaire_Answer__c>>();
                   
                   for(Questionnaire_Answer__c Qac : [select id,QA_Answer__c,QA_Other__c,QA_Questionnaire__c,QA_Questionnaire_Answer_Option__r.Name,
                                                       QA_Questionnaire_Question__r.QQ_Question__c,QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c,
                                                       QA_Questionnaire_Answer_Option__r.QAO_Score__c,QA_Questionnaire_Question__r.QQ_Order__c,QA_Questionnaire_Question__r.Q_Question_Type__c from Questionnaire_Answer__c where QA_Questionnaire__c =:PropertQuesId order by QA_Questionnaire_Question__r.QQ_Order__c asc]){
                                                       
                       if(!CategoryRelatedAnswers.containsKey(String.valueOf(Qac.QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c))){
                           CategoryRelatedAnswers.put(Qac.QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c,new List<Questionnaire_Answer__c>());
                       }
                       CategoryRelatedAnswers.get(Qac.QA_Questionnaire_Question__r.QQ_Questionnaire_Question_Category__c).add(Qac);
                       
                   }
                  QuesAnsLst = new Map<String,Map<String, AnswerDetailWrapper>>();
                  
                  for(String Qcc : QuestionnaireCategoryInfo.keyset()){
                     
                      QuesAnsLst.put(QuestionnaireCategoryInfo.get(Qcc),new Map<String,AnswerDetailWrapper>());
                       if(CategoryRelatedAnswers.get(Qcc) != null){
                          
                           //CategoriesWrapper cw  = new CategoriesWrapper(QuestionnaireCategoryInfo.get(Qcc),new List<AnswerDetailWrapper>());
                           //List<AnswerDetailWrapper> tempAnswerLst = new List<AnswerDetailWrapper>();
                           system.debug('Question *****   '+ CategoryRelatedAnswers.get(Qcc));
                           for(Questionnaire_Answer__c Qac: CategoryRelatedAnswers.get(Qcc)){
                               
                               AnswerDetailWrapper adw = new AnswerDetailWrapper();
                               if(Qac.QA_Questionnaire_Question__r.QQ_Question__c != null){
                                   adw.Question = Qac.QA_Questionnaire_Question__r.QQ_Question__c;
                               }
                               
                               if(Qac.QA_Questionnaire_Answer_Option__r.Name != null){
                                   adw.SelectedAnswer = Qac.QA_Questionnaire_Answer_Option__r.Name;
                               }
                               if(Qac.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple-choice'){
                                    adw.SelectedAnswer = Qac.QA_Answer__c;
                               }
                               if(Qac.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple choice with other text box'){
                                    adw.SelectedAnswer = Qac.QA_Answer__c;
                                    if(Qac.QA_Other__c != null){
                                       adw.Comment = Qac.QA_Other__c;
                                    }
                               }
                               if(Qac.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Text'){
                                    adw.SelectedAnswer = Qac.QA_Answer__c;
                                    
                               }
                               if(Qac.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with text Box'){
                                     if(Qac.QA_Answer__c != null){
                                           adw.Comment = Qac.QA_Answer__c;
                                     }
                                    
                                    
                               }
                              /* if(Qac.QA_Answer__c != null){
                                   adw.Comment = Qac.QA_Answer__c;
                               }
                               
                               if(Qac.QA_Other__c != null){
                                   adw.Comment = Qac.QA_Other__c;
                               }*/
                               
                              /* if(Qac.QA_Questionnaire_Answer_Option__r.QAO_Score__c != null){
                                   adw.Score = Qac.QA_Questionnaire_Answer_Option__r.QAO_Score__c;
                               }
                               System.debug('############ Cata'+Qcc);
                               
                               QuesAnsLst.get(QuestionnaireCategoryInfo.get(Qcc)).put(Qac.QA_Questionnaire_Question__c, adw);
                               //tempAnswerLst.add(adw);
                           }
                           
                           //QuesAnsLst.get(QuestionnaireCategoryInfo.get(Qcc)).addAll(tempAnswerLst);
                       }
                      
                   }
               }***/
            }
        }catch(Exception e){       
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' On Line Number :: '+e.getLineNumber());            
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void updateBooking(){
        if(bookingId != null){
            List<Opportunity> lstOpp = new List<Opportunity>(); 
            for(Opportunity opp : [Select Id,O_Questionnaire_Completed__c from Opportunity where Id = :bookingId]){
                opp.O_Questionnaire_Completed__c = true;
                lstOpp.add(opp);
            }
            update lstOpp;
        }
    }
    
   
    
    public class CategoriesWrapper{
        public String Category{get;set;}
        public List<AnswerDetailWrapper> QuestinnaireQues{get;set;}
        CategoriesWrapper(String Category, List<AnswerDetailWrapper> QuestinnaireQues){
            this.Category = Category;
            this.QuestinnaireQues = QuestinnaireQues;
        }
    }
    public class AnswerDetailWrapper{
        
        public String Question{get;set;}
        public String SelectedAnswer{get;set;}
        public String  Comment{get;set;}
        public Decimal Score{get;set;}
        public AnswerDetailWrapper(){
                Question = '';
                SelectedAnswer = '';
                Comment = '';
                Score = 0.0;
        }        
    }  
    
                            
}
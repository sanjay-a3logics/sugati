public class ClientQuestionnaireController{
    
    public String UrlId  {get; set;}
    public List<CategoriesWrapper> QuestionnaireCategoryLst  {get;set;}
    public List<CategoriesWrapper> lstSetController{get;set;}
    Questinnaire__c NewQuestionnaire;
    List<Questinnaire__c>  LastCreateQuestionnaire;
    CustomIterable obj;
    List<Questionnaire_Answer__c> SelectedAnswerRec;
    List<Questionnaire_Answer__c> DeleteAnswerRecLst;
    Map<Id,Questionnaire_Question__c> ClientQuestions;
    public Decimal NoOfQuestions {get;set;}
    public Integer NoOfQuestionsVisited {get;set;}
    Boolean flag;
    public Integer CurrentPageNo{get;set;}
    public Map<Integer,Integer> progressbarRec{get;set;}
    public Integer TotalQuesVisited{get;set;}
    public string errorMessage{get;set;}
    public Decimal percentIncrement{get;set;}
    public Boolean CompleteQuestionnaire;
    public Boolean requiredFieldchecker{get;set;}
    public String recordtypeName;
    Map<String, Questionnaire_Answer__c> selectedAnswers;
    public Boolean ExistQues;
    Set<Id> setQuestionsShowed;
    String RecordId;
    Boolean isAttachment= false;
    String requestPageNumber;
    public Set<String> oldQuestions;
    public Set<String> newQuestions;
    public Set<String> modifiedQuestions;
    private Map<String, String> newToOldMap;
    public Map<String, QuestionnaireQuesWrapper> newToOldQuestionMap {get;set;}
    private boolean isNewQuestionnaire;
    public ClientQuestionnaireController(){
        try{
            errorMessage = '';
            UrlId  = APexpages.currentpage().getParameters().get('id');
            requestPageNumber = APexpages.currentpage().getParameters().get('pnum');
            if(APexpages.currentpage().getParameters().get('isAtt') == 'true'){
                isAttachment = true;
            }
            isNewQuestionnaire = false;
            QuestionnaireCategoryLst  = new List<CategoriesWrapper>();
            SelectedAnswerRec = new List<Questionnaire_Answer__c>();
            LastCreateQuestionnaire = new List<Questinnaire__c>();
            setQuestionsShowed = new Set<Id>();
            flag = true;
            CurrentPageNo = 1;
            TotalQuesVisited  = 0;
            NewQuestionnaire = new Questinnaire__c();
            CompleteQuestionnaire = false;
            requiredFieldchecker = false;
            ExistQues = false;
            oldQuestions = new Set<String>();
            newQuestions = new Set<String>();
            modifiedQuestions = new Set<String>();
            selectedAnswers = new Map<String,Questionnaire_Answer__c>();
            newToOldQuestionMap = new Map<String,QuestionnaireQuesWrapper>(); 
            newToOldMap = new Map<String, String>();
            if(UrlId != null){
                RecordType rt;
                set<String> QuestionnaireCategoryIds = new set<String>();
                recordtypeName =''; 
                percentIncrement = 0.0;
                NoOfQuestions = 0;
                // check for Id param
                if(UrlId.startsWithIgnoreCase('006')){
                    NewQuestionnaire = [select id,Q_Booking__c,Q_Category_Checker__c,lastModifiedDate,Q_Stage__c,Q_Date_of_visit__c,RecordTypeId, createdDate from Questinnaire__c where Q_Booking__c =:UrlId limit 1];    
                    recordtypeName = 'Client';                
                }
                /*else{
                    RecordId = APexpages.currentpage().getParameters().get('RecId');
                    if(RecordId != null){
                        NewQuestionnaire = [select id,Q_Booking__c,lastModifiedDate,Q_Category_Checker__c,Q_Stage__c,Q_Date_of_visit__c,RecordTypeId, createdDate from Questinnaire__c where id=:RecordId limit 1];  
                        system.debug('ccccccc'+NewQuestionnaire);
                    }
                    //Verify that New Questionnaire created or existing one is opened
                    if(APexpages.currentpage().getParameters().get('flag') != null){
                           isNewQuestionnaire = true;
                           LastCreateQuestionnaire = [select id,Q_Booking__c,Q_Category_Checker__c,Q_Date_of_visit__c,RecordTypeId from Questinnaire__c where Q_Property__c=:UrlId order by createddate desc limit 2];  
                           system.debug('aaaaa'+LastCreateQuestionnaire);
                           if(LastCreateQuestionnaire.size()>1)
                               ExistQues = true;
                    } 
                    
                    recordtypeName = 'H_S';   
                }*/
                 
                // get the page number of last answered category
                if (NewQuestionnaire.Q_Category_Checker__c != null) {
                    CurrentPageNo = Integer.valueOf(NewQuestionnaire.Q_Category_Checker__c);
                }
                
                if(requestPageNumber != null)
                    CurrentPageNo = Integer.valueOf(requestPageNumber);   
                //system.assert(false, CurrentPageNo );
                // get record type based on questionnaire type
                //rt = [select id from RecordType where sobjectType = 'Questionnaire_Question_Category__c' and developername =:recordtypeName  limit 1];
              
                // get the questionnaire category based on record type.
                for(Questionnaire_Question_Category__c Qc :[select id,name,RecordTypeId,QQC_Live__c,QQC_Order__c,QQC_Introduction_Text__c,Record_Type__r.name
                from Questionnaire_Question_Category__c where Record_Type__r.name =: 'Client' and QQC_Live__c = true order by QQC_Order__c asc]){
                       QuestionnaireCategoryIds.add(Qc.id);
                       QuestionnaireCategoryLst.add(new CategoriesWrapper(Qc,new List<QuestionnaireQuesWrapper>()));
                }
                
                ClientQuestions = new Map<Id,Questionnaire_Question__c>([select id,QQ_Live__c,QQ_Order__c,QQ_Question__c,QQ_Old_Question__c,
                QQ_Questionnaire_Question_Category__c,Q_Question_Type__c,QQ_Required__c , QQ_Obsolete__c, createdDate, lastModifiedDate   
                from Questionnaire_Question__c 
                where QQ_Questionnaire_Question_Category__c In : QuestionnaireCategoryIds and QQ_Live__c =true order by QQ_Order__c asc]);
               
                if(ClientQuestions != null){
                
                //NoOfQuestions = ClientQuestions.size();
                
                    List<Questionnaire_Answer_Options__c> answerOption = [select id,Name,QAO_Questionnaire_Question__c,QAO_Order__c,lastModifiedDate 
                    from Questionnaire_Answer_Options__c 
                    where QAO_Questionnaire_Question__c in : ClientQuestions.keyset() order by QAO_Order__c asc];
                    
                    Map<String,List<Questionnaire_Answer_Options__c>> QuestinRelatedAnswers = new Map<String,List<Questionnaire_Answer_Options__c>>();
                    
                    for(Questionnaire_Answer_Options__c Ap : answerOption){
                        if(!QuestinRelatedAnswers.containsKey(Ap.QAO_Questionnaire_Question__c)){
                            QuestinRelatedAnswers.put(Ap.QAO_Questionnaire_Question__c,new List<Questionnaire_Answer_Options__c>());
                        }
                        QuestinRelatedAnswers.get(Ap.QAO_Questionnaire_Question__c).add(Ap);
                    }
                    
                    
                    Map<String,List<Questionnaire_Question__c>> CategoryRelatedQuestion = new Map<String,List<Questionnaire_Question__c>>();
                    for(Questionnaire_Question__c QQc : ClientQuestions.values()){
                        //System.debug('############# Question Created Date  '+ NewQuestionnaire.createdDate +'  *******  '+QQc.createdDate);
                        
                        // Create a map to bind replaced questions with new questions
                        if(QQc.QQ_Old_Question__c != null && recordtypeName=='H_S' && NewQuestionnaire.createdDate < QQc.createdDate )
                            newToOldMap.put( QQc.QQ_Old_Question__c, QQc.id );
                            
                        if(NewQuestionnaire.createdDate < QQc.createdDate && recordtypeName=='H_S'){
                            newQuestions.add(QQc.id);
                        }
                        if(QQc.QQ_Obsolete__c != null && Date.today() > QQc.QQ_Obsolete__c && recordtypeName=='H_S' ){
                            oldQuestions.add(QQc.id);    
                        }
                        if(QQc.lastModifiedDate > NewQuestionnaire.lastModifiedDate && recordtypeName=='H_S' && !newQuestions.contains(QQc.id) && !oldQuestions.contains(QQc.id)){
                            modifiedQuestions.add(QQc.id);
                        }
                        //system.assert(false, NewQuestionnaire.Q_Stage__c == 'In Progress');
                        if(NewQuestionnaire.Q_Stage__c == 'In Progress' ){
                            if(QQc.QQ_Obsolete__c == null || Date.today() < QQc.QQ_Obsolete__c){
                                setQuestionsShowed.add(QQc.id);  
                                //System.assert(false, NewQuestionnaire.Q_Stage__c);   
                            }
                        }
                        else{
                            setQuestionsShowed.add(QQc.id);    
                        }
                        
                    }
                    for(Questionnaire_Question__c QQc : ClientQuestions.values()){
                        //exclude old questions from map
                        if(setQuestionsShowed.contains(QQc.id) && !newToOldMap.containsKey(QQc.id)){
                            if(!CategoryRelatedQuestion.containsKey(QQc.QQ_Questionnaire_Question_Category__c)){
                                CategoryRelatedQuestion.put(QQc.QQ_Questionnaire_Question_Category__c,new List<Questionnaire_Question__c>());
                            }
                            CategoryRelatedQuestion.get(QQc.QQ_Questionnaire_Question_Category__c).add(QQc);
                        }
                    }
                    //system.assert(false, newQuestions);
                    for(String val : CategoryRelatedQuestion.keySet()){
                        List<Questionnaire_Question__c>  lstQQ = CategoryRelatedQuestion.get(val);
                        system.debug('######### Questions ####### '+ lstQQ );
                        lstQQ.sort();
                    }
                    if(ExistQues == false){
                        for(Questionnaire_Answer__c Qac : [select id,QA_Answer__c,QA_Other__c,QA_Questionnaire__c,QA_Questionnaire_Answer_Option__c,QA_Questionnaire_Question__c,QA_Questionnaire_Answer_Option__r.Name,QA_Questionnaire_Question__r.Q_Question_Type__c from Questionnaire_Answer__c where QA_Questionnaire__c=: NewQuestionnaire.id]){
                            selectedAnswers.put(Qac.QA_Questionnaire_Question__c,Qac);
                        }
                    }else{
                        for(Questionnaire_Answer__c Qac : [select id,QA_Answer__c,QA_Other__c,QA_Questionnaire__c,QA_Questionnaire_Answer_Option__c,QA_Questionnaire_Question__c,QA_Questionnaire_Answer_Option__r.Name,QA_Questionnaire_Question__r.Q_Question_Type__c from Questionnaire_Answer__c where QA_Questionnaire__c=: LastCreateQuestionnaire[1].id]){
                            selectedAnswers.put(Qac.QA_Questionnaire_Question__c,Qac);
                        }

                    }
                    
                    if(CategoryRelatedQuestion != null){
                        
                        for(CategoriesWrapper cw : QuestionnaireCategoryLst){
                        
                            List<QuestionnaireQuesWrapper> QuestinnaireQuesTemp = new List<QuestionnaireQuesWrapper>();
                            if(CategoryRelatedQuestion.get(cw.CategoryObj.id) != null){
                                for(Questionnaire_Question__c  ques: CategoryRelatedQuestion.get(cw.CategoryObj.id)){
                                
                                   if((QuestinRelatedAnswers.containsKey(ques.id) && QuestinRelatedAnswers.get(ques.id).size()>0) || (ques.Q_Question_Type__c != null && ques.Q_Question_Type__c == 'Text')){
                                    
                                        QuestionnaireQuesWrapper QuesWrapperVal = new QuestionnaireQuesWrapper();
                                        if(oldQuestions.contains(ques.id))
                                                QuesWrapperVal.isOldQuestion = true;
                                        if(ques.QQ_Old_Question__c != null && newToOldMap.containsKey(ques.QQ_Old_Question__c)){
                                            QuesWrapperVal.oldQuestoinId = ques.QQ_Old_Question__c;    
                                        }    
                                        if(newQuestions.contains(ques.id))
                                            QuesWrapperVal.isNewQuestion = true; 
                                              
                                        if(modifiedQuestions.contains(ques.id)){
                                            QuesWrapperVal.isQuestionModified = true; 
                                        }
                                        if(selectedAnswers.containsKey(ques.id)){
                                            Questionnaire_Answer__c answerTemp = new Questionnaire_Answer__c();
                                            if(ExistQues == true){
                                                answerTemp = new Questionnaire_Answer__c();
                                                answerTemp.QA_Answer__c = selectedAnswers.get(ques.id).QA_Answer__c;
                                                answerTemp.QA_Other__c = selectedAnswers.get(ques.id).QA_Other__c;
                                                answerTemp.QA_Questionnaire_Answer_Option__c = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__c;
                                                answerTemp.QA_Questionnaire_Question__c = selectedAnswers.get(ques.id).QA_Questionnaire_Question__c ;
                                                answerTemp.QA_Questionnaire__c = NewQuestionnaire.id;
                                                
                                            }else{
                                                answerTemp = selectedAnswers.get(ques.id);
                                            }
                                            
                                            
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple-choice'){
                                                
                                                if(answerTemp.QA_Answer__c != null)
                                                    QuesWrapperVal.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                                            }
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with text Box'){
                                                
                                                QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                                QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                            }
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with other text box'){
                                                
                                                QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                                QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                            }
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with other text box'){
                                                
                                                QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                                QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                            }
                                            
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single-choice'){
                                                
                                               QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                            }
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Text'){
                                                
                                                QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                            }
                                            if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple choice with other text box'){
                                                
                                                if(answerTemp.QA_Answer__c != null){
                                                    QuesWrapperVal.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                                                }
                                                else{
                                                    QuesWrapperVal.MultipleSelectOptionsAnswer = new List<String>();    
                                                }
                                                QuesWrapperVal.UserEnteredText = answerTemp.QA_Other__c;
                                            }
                                            QuesWrapperVal.answerVal = answerTemp;
                                        }
                                        
                                        QuesWrapperVal.QuestionObj = ques;
                                        if(ques.Q_Question_Type__c != 'Text'){
                                        
                                            for(Questionnaire_Answer_Options__c answerOptionsVal : QuestinRelatedAnswers.get(ques.id)){
                                              
                                               QuesWrapperVal.optionsOfAnswer.add(new SelectOption(answerOptionsVal.name,answerOptionsVal.name));
                                               
                                            }
                                            for(Questionnaire_Answer_Options__c Qac : QuestinRelatedAnswers.get(ques.id)){
                                                 QuesWrapperVal.answerObj.put(Qac.Name,Qac);
                                            }
                                            
                                        }
                                        
                                        QuestinnaireQuesTemp.add(QuesWrapperVal);
                                       
                                    }
                                }
                            }
                            
                            cw.QuestinnaireQues.addAll(QuestinnaireQuesTemp);
                                
                        }
                        system.debug('Old QUestions Map ***** ' +  newToOldMap);
                        
                        // Update related answers map for old questions 
                        Map<String,List<Questionnaire_Answer_Options__c>> OldQuestinRelatedAnswers = new Map<String,List<Questionnaire_Answer_Options__c>>();
                        List<Questionnaire_Answer_Options__c> answerOptionForOld = [select id,Name,QAO_Questionnaire_Question__c,QAO_Order__c,lastModifiedDate 
                            from Questionnaire_Answer_Options__c 
                            where QAO_Questionnaire_Question__c in : newToOldMap.keySet() order by QAO_Order__c asc];
                            for(Questionnaire_Answer_Options__c Ap : answerOptionForOld){
                                if(!OldQuestinRelatedAnswers.containsKey(Ap.QAO_Questionnaire_Question__c)){
                                    OldQuestinRelatedAnswers.put(Ap.QAO_Questionnaire_Question__c,new List<Questionnaire_Answer_Options__c>());
                                }
                                OldQuestinRelatedAnswers.get(Ap.QAO_Questionnaire_Question__c).add(Ap);
                        }
                        
                        // Create QuestionnaireWrapper objects to show these quesions on page
                        
                        for(Questionnaire_Question__c  ques: [select id,QQ_Live__c,QQ_Order__c,QQ_Question__c,QQ_Old_Question__c,
                        QQ_Questionnaire_Question_Category__c,Q_Question_Type__c,QQ_Required__c , QQ_Obsolete__c, createdDate, lastModifiedDate   
                        from Questionnaire_Question__c 
                        where id In : newToOldMap.keySet() ]){
                            
                            if((OldQuestinRelatedAnswers.containsKey(ques.id) && OldQuestinRelatedAnswers.get(ques.id).size()>0) || (ques.Q_Question_Type__c != null && ques.Q_Question_Type__c == 'Text')){
                                            
                                QuestionnaireQuesWrapper QuesWrapperVal = new QuestionnaireQuesWrapper();
                                
                                if(selectedAnswers.containsKey(ques.id)){
                                    Questionnaire_Answer__c answerTemp = new Questionnaire_Answer__c();
                                    if(ExistQues == true){
                                        answerTemp = new Questionnaire_Answer__c();
                                        answerTemp.QA_Answer__c = selectedAnswers.get(ques.id).QA_Answer__c;
                                        answerTemp.QA_Other__c = selectedAnswers.get(ques.id).QA_Other__c;
                                        answerTemp.QA_Questionnaire_Answer_Option__c = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__c;
                                        answerTemp.QA_Questionnaire_Question__c = selectedAnswers.get(ques.id).QA_Questionnaire_Question__c ;
                                        answerTemp.QA_Questionnaire__c = NewQuestionnaire.id;
                                        
                                    }else{
                                        answerTemp = selectedAnswers.get(ques.id);
                                    }
                                    
                                    
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple-choice'){
                                        
                                        if(answerTemp.QA_Answer__c != null)
                                            QuesWrapperVal.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                                    }
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with text Box'){
                                        
                                        QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                        QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                    }
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with other text box'){
                                        
                                        QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                        QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                    }
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with other text box'){
                                        
                                        QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                        QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                    }
                                    
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single-choice'){
                                        
                                       QuesWrapperVal.selectedAnswer = selectedAnswers.get(ques.id).QA_Questionnaire_Answer_Option__r.Name;
                                    }
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Text'){
                                        
                                        QuesWrapperVal.UserEnteredText = answerTemp.QA_Answer__c;
                                    }
                                    if(selectedAnswers.get(ques.id).QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple choice with other text box'){
                                        
                                        if(answerTemp.QA_Answer__c != null){
                                            QuesWrapperVal.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                                        }
                                        else{
                                            QuesWrapperVal.MultipleSelectOptionsAnswer = new List<String>();    
                                        }
                                        QuesWrapperVal.UserEnteredText = answerTemp.QA_Other__c;
                                    }
                                    QuesWrapperVal.answerVal = answerTemp;
                                }
                                
                                QuesWrapperVal.QuestionObj = ques;
                                if(ques.Q_Question_Type__c != 'Text'){
                                
                                    for(Questionnaire_Answer_Options__c answerOptionsVal : OldQuestinRelatedAnswers.get(ques.id)){
                                      
                                       QuesWrapperVal.optionsOfAnswer.add(new SelectOption(answerOptionsVal.name,answerOptionsVal.name));
                                       
                                    }
                                    for(Questionnaire_Answer_Options__c Qac : OldQuestinRelatedAnswers.get(ques.id)){
                                         QuesWrapperVal.answerObj.put(Qac.Name,Qac);
                                    }
                                    
                                }
                                
                                if(newToOldMap.containsKey(ques.id))
                                    newToOldQuestionMap.put(newToOldMap.get(ques.id), QuesWrapperVal);
                               
                            }
                        }
                        //system.assert(false, newToOldQuestionMap);
                    }
                    //system.assert(false, QuestionnaireCategoryLst);
                }
                
                // Create a map of old questoins to render on page
                
                
                //Verify Questionnaire fully completed or not.
                //system.assert(false,CurrentPageNo+'    aaa    '+Math.ceil(QuestionnaireCategoryLst.size()/2.0)+'   qqqq    '+QuestionnaireCategoryLst.size());
                
                if(CurrentPageNo>Math.ceil(QuestionnaireCategoryLst.size()/2.0) && requestPageNumber == null){
                    
                    CompleteQuestionnaire = true;
                    
                }
                
                
                //system.assert(false,CompleteQuestionnaire);
                if(CompleteQuestionnaire == false){
                    
                    progressbarRec = new Map<Integer,Integer>();
                    if(QuestionnaireCategoryLst.size() > 0) {
                        integer k =0;
                        for(Integer i = 0; i < Math.ceil(QuestionnaireCategoryLst.size()/2.0); i++){
                          
                            progressbarRec.put(i+1,QuestionnaireCategoryLst[k].QuestinnaireQues.size());
                            if(K<QuestionnaireCategoryLst.size()-1){
                                progressbarRec.put(i+1,QuestionnaireCategoryLst[k].QuestinnaireQues.size() + QuestionnaireCategoryLst[k+1].QuestinnaireQues.size());
                            
                            }  
                            // total number of questions in all cateogory 
                            NoOfQuestions = NoOfQuestions + progressbarRec.get(i+1);
                            K += 2;
                           
                        }
                        
                        obj = new CustomIterable(QuestionnaireCategoryLst); 
                        obj.setPageSize = 2;
                        if(requestPageNumber != null)
                             obj.pageNo = Integer.valueOf(requestPageNumber); 
                        else
                            obj.pageNo = Integer.valueOf(NewQuestionnaire.Q_Category_Checker__c != null ? NewQuestionnaire.Q_Category_Checker__c : 0);
                        //system.assert(false,obj);
                        next();   
                    }
                }
                else if(isAttachment){
                    lstSetController = QuestionnaireCategoryLst;
                }
                //system.assert(false,lstSetController );
                
                
            }
            //system.assert(false, lstSetController);
              
        }
        catch(Exception e){
            system.assert(false,e.getLineNumber()+'---------------Message-----'+e.getMessage());
            errorMessage  = e.getLineNumber()+'---------------Message-----'+e.getMessage();
        }
    }
    public pageReference VerifyCompleteQuestionnarie(){
        if(CompleteQuestionnaire == true){
            pageReference pr = null;
             if(UrlId.startsWithIgnoreCase('006')){
                  pr = new pageReference('/apex/Client_Questionnaire_Thank_You?id='+UrlId);
             }else {
                  pr = new pageReference('/apex/HS_Questionnaire_Thank_You?id='+UrlId+'&RecId='+RecordId);
             }
            return pr;
        }
        return null;
    }
    public pageReference RedirectThankYou(){
    
        system.debug('aaaaaaaapppp'+lstSetController);
        SaveAnswers();
        boolean isAllQuestionAnswered = true;
        Set<Id> setAnsweredQuestions = new Set<Id>();
        for(Questionnaire_Answer__c  qa : [Select id,QA_Questionnaire_Question__c, QA_Answer__c, QA_Other__c , QA_Questionnaire_Answer_Option__c from Questionnaire_Answer__c where QA_Questionnaire__c =:NewQuestionnaire.id ]) {
            if(qa.QA_Questionnaire_Answer_Option__c != null || qa.QA_Answer__c!= null || qa.QA_Other__c != null)
                setAnsweredQuestions.add(qa.QA_Questionnaire_Question__c);
        }
        system.debug('############setAnsweredQuestions' + setAnsweredQuestions);
        system.debug('@@@@@@@@@@@@@@setQuestionsShowed' + setQuestionsShowed);
        
        for(Id questionId : setQuestionsShowed){
            if(!(setAnsweredQuestions.contains(questionId) && !oldQuestions.contains(questionId)) && !newToOldMap.containsKey(questionId)){
                isAllQuestionAnswered = false;    
                break;   
            }
        }
        system.debug('#############isAllQuestionAnswered  '+ isAllQuestionAnswered );
        
        NewQuestionnaire.Q_Category_Checker__c = CurrentPageNo + 1 ;
        if(isAllQuestionAnswered) {
            NewQuestionnaire.Q_Stage__c = 'Completed';
            NewQuestionnaire.Q_Completed_Date__c = Date.today();   
        }
        else
            NewQuestionnaire.Q_Stage__c = 'Incomplete';
        upsert NewQuestionnaire;
        pageReference pr = null;
        if(UrlId.startsWithIgnoreCase('006')){
            pr = new pageReference('/apex/Client_Questionnaire_Thank_You?id='+UrlId);
        }
        else{
            pr = new pageReference('/apex/HS_Questionnaire_Thank_You?id='+UrlId+'&RecId='+RecordId);
        }
        
        return pr;
    }
    
     public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
     }
    
     public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
     }
    
     public void SaveAnswers(){
         try{
         requiredFieldchecker = false;
         
         if(lstSetController!=null){
                
                DeleteAnswerRecLst = new List<Questionnaire_Answer__c>();
                SelectedAnswerRec = new List<Questionnaire_Answer__c>();
                system.debug('--------------------VVVVVVVVVVV'+lstSetController);
                
                for(CategoriesWrapper cw: lstSetController){
                    //system.assert(false,cw.QuestinnaireQues);
                    for(QuestionnaireQuesWrapper Qqw : cw.QuestinnaireQues){
                        if(Qqw.isOldQuestion)
                            continue;
                        Boolean check = false;
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Single-choice'){
                            
                              Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                              Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                              check = true;
                              if(Qqw.selectedAnswer!= null){
                                  Qqw.answerVal.QA_Questionnaire_Answer_Option__c = Qqw.answerObj.get(Qqw.selectedAnswer).id;
                                  Qqw.verifyrequiredfield = false;
                              }
                              else{
                                if(Qqw.QuestionObj.QQ_Required__c == true){
                                //system.assert(false,Qqw);
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }   
                            }
                        }
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Multiple-choice'){
                              Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                              Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                              check = true;   
                              if(Qqw.MultipleSelectOptionsAnswer.size()>0){                               
                                  String multiValues ='';
                                  for(String s : Qqw.MultipleSelectOptionsAnswer){
                                      multiValues = multiValues +','+s;
                                  }
                                  multiValues = multiValues.SubString(1,multiValues.length());
                                  
                                  Qqw.answerVal.QA_Answer__c  = multiValues;
                                  Qqw.verifyrequiredfield = false;
                                  
                            }else{
                                if(Qqw.QuestionObj.QQ_Required__c == true){
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }
                            }
                        }
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Multiple choice with other text box'){
                             
                              Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                              Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                              check = true;
                              if(Qqw.MultipleSelectOptionsAnswer.size()>0){
                                  String multiValues ='';
                                  for(String s : Qqw.MultipleSelectOptionsAnswer){
                                      multiValues = multiValues +','+s;
                                  }
                                  multiValues = multiValues.SubString(1,multiValues.length());
                                  Qqw.answerVal.QA_Answer__c  = multiValues;
                                  
                                  if(Qqw.UserEnteredText.trim() != null)
                                      Qqw.answerVal.QA_Other__c = Qqw.UserEnteredText;
                                  else
                                      Qqw.answerVal.QA_Other__c = '';
                                  Qqw.verifyrequiredfield = false;
                                      
                            }else{
                                if(Qqw.QuestionObj.QQ_Required__c == true){
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }
                            }
                        }
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Text'){
                            Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                            Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                            check = true;
                            if(Qqw.UserEnteredText.trim() != ''){
                                Qqw.answerVal.QA_Answer__c = Qqw.UserEnteredText;
                                Qqw.verifyrequiredfield = false;
                                  
                            }else{
                                if(Qqw.QuestionObj.QQ_Required__c == true){
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }
                            }
                        }
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Single choice with text Box'){
                             Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                             Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                             check = true;
                             if(Qqw.selectedAnswer!= null){
                                  Qqw.answerVal.QA_Questionnaire_Answer_Option__c = Qqw.answerObj.get(Qqw.selectedAnswer).id;
                                  
                                  if(Qqw.UserEnteredText.trim() != '')
                                      Qqw.answerVal.QA_Answer__c = Qqw.UserEnteredText;
                                  else
                                      Qqw.answerVal.QA_Answer__c = '';
                                  Qqw.verifyrequiredfield = false;
                                      
                            }else{
                                if(Qqw.QuestionObj.QQ_Required__c == true){
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }
                            }
                        }
                        
                        if(Qqw.QuestionObj.Q_Question_Type__c == 'Single choice with other text box'){
                             Qqw.answerVal.QA_Questionnaire__c = NewQuestionnaire.id;
                             Qqw.answerVal.QA_Questionnaire_Question__c = Qqw.QuestionObj.id;
                             check = true;
                             if(Qqw.selectedAnswer!= null){
                                 system.debug(Qqw.selectedAnswer+' ----- '+Qqw.answerVal+'------ '+NewQuestionnaire);
                                 if( Qqw.selectedAnswer != 'Other' || (Qqw.selectedAnswer == 'Other' && (Qqw.UserEnteredText.trim() != null && Qqw.UserEnteredText.trim() != ''))){
                                      Qqw.answerVal.QA_Questionnaire_Answer_Option__c = Qqw.answerObj.get(Qqw.selectedAnswer).id;
                                      
                                      if(Qqw.UserEnteredText.trim() != '')
                                          Qqw.answerVal.QA_Other__c = Qqw.UserEnteredText;
                                      else
                                          Qqw.answerVal.QA_Other__c = '';
                                      Qqw.verifyrequiredfield = false;
                                  }
                                  else{
                                      if(Qqw.UserEnteredText.trim() == ''){
                                          Qqw.verifyrequiredfield = true;
                                          requiredFieldchecker = true;
                                      }
                                  }
                                      
                            }else{
                                if(Qqw.QuestionObj.QQ_Required__c == true || Qqw.selectedAnswer == 'Other'){
                                    Qqw.verifyrequiredfield = true;
                                    requiredFieldchecker = true;
                                }
                            }
                        }
                        
                        if(Qqw.answerVal.QA_Questionnaire__c !=null && check == false && Qqw.answerVal.id != null){
                               
                                DeleteAnswerRecLst.add(Qqw.answerVal);
                                Qqw.answerVal = null;
                        }
                        if(check == true)
                            SelectedAnswerRec.add(Qqw.answerVal);
                    }    
                }
                if(requiredFieldchecker == false){
                    if(DeleteAnswerRecLst.size()>0)
                        Delete DeleteAnswerRecLst;
                    
                    if(SelectedAnswerRec.size()>0)
                        upsert SelectedAnswerRec;
                   // system.assert(false,SelectedAnswerRec);
                    
                    if(recordtypeName == 'H_S'){
                        
                        List<Questionnaire_Answer__c> NARecords = new List<Questionnaire_Answer__c>();
                        NARecords = [Select id,QA_Questionnaire_Answer_Option__r.name from Questionnaire_Answer__c where QA_Questionnaire__c =:NewQuestionnaire.id  and QA_Questionnaire_Answer_Option__r.name = 'NO'];
                       
                        if(NARecords.size()>0){
                            NewQuestionnaire.StatusNA__c = 'Red';
                        }else{
                            NewQuestionnaire.StatusNA__c = 'Green';
                        }
                        upsert NewQuestionnaire;
                    }
                 } 
            }
        }
        catch(Exception e){
            system.assert(false,' -------- '+e.getstacktraceString() + '-----------'+ e.getMessage());
        }
     }
     public void next(){ 
     
        try{
            SaveAnswers();
            if(requiredFieldchecker == false){
                
                lstSetController = obj.next();
                system.debug('cacacacacaca'+lstSetController);
                if(obj.pageNo > 1 && flag == false){
                    CurrentPageNo = obj.pageNo;
                    NewQuestionnaire.Q_Category_Checker__c = obj.pageNo;
                    upsert NewQuestionnaire;
                }
                
                system.debug('tttttttttttttttttttttttttt'+TotalQuesVisited);
                TotalQuesVisited = 0;
            
                for(Integer i = 0 ; i<CurrentPageNo ; i++){
                    
                    TotalQuesVisited = TotalQuesVisited + progressbarRec.get(i+1);
                  // system.assert(false,TotalQuesVisited );
                    
                }
              
                 percentIncrement = (TotalQuesVisited / NoOfQuestions) * 100 ;
                 system.debug('ppppppppppppppppppppp'+TotalQuesVisited+'aaaa'+NoOfQuestions+'aaaa'+percentIncrement );
                
                
                flag = false;
            }
        }
        catch(Exception e){
            system.assert(false,e.getstacktraceString()+'-------Message-------'+e.getMessage());
        }
     }
    
     public void previous(){
     
        lstSetController = obj.previous(); 
        /*selectedAnswers = new Map<String,Questionnaire_Answer__c>();
        for(Questionnaire_Answer__c Qac : [select id,QA_Answer__c,QA_Other__c,QA_Questionnaire__c,QA_Questionnaire_Answer_Option__c,QA_Questionnaire_Question__c,QA_Questionnaire_Answer_Option__r.Name,QA_Questionnaire_Question__r.Q_Question_Type__c from Questionnaire_Answer__c where QA_Questionnaire__c=: NewQuestionnaire.id]){
            selectedAnswers.put(Qac.QA_Questionnaire_Question__c,Qac);
            System.debug('prepreprepre'+selectedAnswers);
        }
        
        for(CategoriesWrapper cw : lstSetController){
        
            for(QuestionnaireQuesWrapper Qqw : cw.QuestinnaireQues){
            
                if(selectedAnswers.containsKey(Qqw.QuestionObj.id)){
                
                    Questionnaire_Answer__c answerTemp = selectedAnswers.get(Qqw.QuestionObj.id);
                    
                    if(answerTemp.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple-choice'){
                        
                        Qqw.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                    }
                    if(answerTemp.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single choice with text Box'){
                        
                        Qqw.selectedAnswer = answerTemp.QA_Questionnaire_Answer_Option__r.Name;
                        Qqw.UserEnteredText = answerTemp.QA_Answer__c;
                    }
                    if(answerTemp.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Single-choice'){
                        
                       Qqw.selectedAnswer = answerTemp.QA_Questionnaire_Answer_Option__r.Name;
                    }
                    if(answerTemp.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Text'){
                        
                        Qqw.UserEnteredText = answerTemp.QA_Answer__c;
                    }
                    if(answerTemp.QA_Questionnaire_Question__r.Q_Question_Type__c == 'Multiple choice with other text box'){
                        
                        Qqw.MultipleSelectOptionsAnswer = answerTemp.QA_Answer__c.split(',');
                        Qqw.UserEnteredText = answerTemp.QA_Other__c;
                    }
                    Qqw.answerVal = answerTemp;
                    
                }
            }
        }*/
     }
    
    public class CategoriesWrapper{
        public Questionnaire_Question_Category__c CategoryObj{get;set;}
        public List<QuestionnaireQuesWrapper> QuestinnaireQues{get;set;}
        public CategoriesWrapper(Questionnaire_Question_Category__c CategoryObj, List<QuestionnaireQuesWrapper> QuestinnaireQues){
            this.CategoryObj = CategoryObj;
            this.QuestinnaireQues = QuestinnaireQues;
        }
    }
    
    public class QuestionnaireQuesWrapper{
        public Questionnaire_Question__c QuestionObj{get;set;}
        public Map<String,Questionnaire_Answer_Options__c> answerObj{get;set;}
        public List<SelectOption>  optionsOfAnswer{get;set;}
        public String selectedAnswer{get;set;}
        public String UserEnteredText{get;set;}
        public List<String> MultipleSelectOptionsAnswer{get; set;}
        public boolean isOldQuestion {get;set;}
        public boolean isNewQuestion {get;set;}
        public boolean isQuestionModified { get; set; }
        public Questionnaire_Answer__c answerVal;
        public Boolean verifyrequiredfield{get;set;}
        public String oldQuestoinId {get;set;}
        public QuestionnaireQuesWrapper(){
            QuestionObj = new Questionnaire_Question__c();
            answerObj = new Map<String,Questionnaire_Answer_Options__c>();
            optionsOfAnswer= new List<SelectOption>();
            MultipleSelectOptionsAnswer = new List<String>(); 
            answerVal = new Questionnaire_Answer__c();
            verifyrequiredfield = false;
            isOldQuestion = false;
            isNewQuestion = false;
            isQuestionModified = false; 
            oldQuestoinId = '';
        }   
        
    }
    public class  CustomIterable implements Iterator<list<CategoriesWrapper>>
    { 
       list<CategoriesWrapper> InnerList{get; set;}
       list<CategoriesWrapper> ListRequested{get; set;}
       public Integer pageNo {get;set;}
       Integer i {get; set;} 
       public Integer setPageSize {get; set;} 
    
       public CustomIterable(List<CategoriesWrapper> lstAccWr)
       {
           InnerList = new list<CategoriesWrapper>(); 
           ListRequested = new list<CategoriesWrapper>();     
           InnerList = lstAccWr;
           setPageSize = 10;
           i = 0; 
           pageNo = 1;
       }   
    
       public boolean hasNext(){ 
           if(i >= InnerList.size()) {
               return false; 
           } else {
               return true; 
           }
       } 
       
       public boolean hasPrevious(){ 
           try{
               system.debug('I am in hasPrevious' + i);
               if(i <= setPageSize) {
                   return false; 
               } else {
                   return true; 
               }
           }
           Catch(Exception e){
               System.assert(false,e.getStackTraceString());
               return null;
           }
       }   
    
       public list<CategoriesWrapper> next(){       
           system.debug('i value is ' + i);
           ListRequested = new list<CategoriesWrapper>(); 
           integer startNumber;
           integer size = InnerList.size();
           
           if(hasNext())
           {  
              
               if(pageNo > 1 && i == 0){
                   
                   startNumber = pageNo*setPageSize - setPageSize ;
                   i = pageNo*setPageSize;
                   if(i>size){
                       startNumber = (pageNo - 1) * setPageSize;
                       i=size;
                   }
                   
               }
               else if(size <= (i + setPageSize))
               {
                   startNumber = i;
                   i = size;
               }
               else
               {
                   i = (i + setPageSize);
                   startNumber = (i - setPageSize);
               }
               
               system.debug('i value is =====' + i);
               system.debug('i value is 2==== ' + (i - setPageSize));
               
               for(integer start = startNumber; start < i; start++)
               {
                   ListRequested.add(InnerList[start]);
               }
               system.debug('111111111111111111111pageNo'+pageNo+'iiiiiiiiiiiiiiiiiiiiiii'+i+'pppppppppppppppp'+setPageSize+'aaaa'+startNumber);
               if(startNumber >= pageNo*setPageSize && startNumber != 0){
                   
                   pageNo = pageNo + 1; 
               }
              system.debug('2222222222222222'+pageNo);
           } 
          
           system.debug('------------------------lst'+ListRequested);
           return ListRequested;
           
           
       } 
       
       public list<CategoriesWrapper > previous(){      
           ListRequested = new list<CategoriesWrapper >(); 
           system.debug('i value is previous before =====' + i);
           integer size = InnerList.size(); 
           if(i == size)
           {
               if(math.mod(size, setPageSize) > 0)
               {    
                   i = size - math.mod(size, setPageSize);
               }
               else
               {
                   i = (size - setPageSize);
               } 
           }
           else
           {
               i = (i - setPageSize);
           }
           
           system.debug('i value is previous =====' + i);
           system.debug('i value is 2previous ==== ' + (i - setPageSize));
           
           for(integer start = (i - setPageSize); start < i; ++start)
           {
               ListRequested.add(InnerList[start]);
           } 
           return ListRequested;
       }   
    }
}
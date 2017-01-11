trigger CreditMemoTrigger on Credit_Memo__c (before insert) {
    
    List<String> lstOpp = new List<String>();
    Map<String,Opportunity> mapOpportunity = new Map<String,Opportunity>();
    for(Credit_Memo__c cm : trigger.new){
        if(cm.CM_Account__c == null && cm.CM_Opportunity__c != null){
            lstOpp.add(cm.CM_Opportunity__c);
        }
    }
    
    for(Opportunity opp : [Select Id,AccountId from Opportunity where Id in :lstOpp]){
        mapOpportunity.put(opp.Id,opp);
    }
    
    for(Credit_Memo__c cm : trigger.new){
        if(cm.CM_Account__c == null && cm.CM_Opportunity__c != null && mapOpportunity.containsKey(cm.CM_Opportunity__c)){
            cm.CM_Account__c = mapOpportunity.get(cm.CM_Opportunity__c).AccountId;
        }
    }
}
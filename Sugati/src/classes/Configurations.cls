public with sharing class Configurations{
    
    public static Trigger_Setting__c triggerSettings {
    
        get {return Trigger_Setting__c.getInstance();}
    }
    
    public static string BASIC = 'basic';
    public static string PRO = 'pro';
    public static UserEdition__c userEditions{
    
        get {return UserEdition__c.getInstance();}
    }
    
    public static boolean isBasic {
        get {
            if(userEditions.Version__c == BASIC) {
                return true;
            }
            return false;
        }
    }
}
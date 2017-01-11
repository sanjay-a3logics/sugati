public with sharing class CreditCardDetails {
    public String creditCardNumber{get;set;}
    public String cvvNumber{get;set;}
    public String expiryDate{get;set;}
    public string nameOnCard {get;set;}
    
       
    public list<SelectOption> cardTypes{
        get{
            if(cardTypes == null){
                cardTypes = new list<SelectOption>();
                cardTypes.add(new SelectOption('none','--None--'));
                cardTypes.add(new SelectOption('Visa','Visa'));
                cardTypes.add(new SelectOption('Master','Master'));
            }
            return cardTypes;
        }
        set;
    }
}
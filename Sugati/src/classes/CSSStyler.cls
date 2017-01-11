public with sharing class CSSStyler {

    public CSSStyler(ApexPages.StandardController controller) {

    }
    
    public CSSStyler() {

    }

    public CSS_Styler__c cssObj{get; set;}
    public string pagename{get;set;}
    
    public string getCss() {
        List<CSS_Styler__c> CSSStyles = new List<CSS_Styler__c>();
        
        if(pagename != null){
            CSSStyles = [select CSS__c,Backgroundcolor__c,Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,
                        Table_Backgroundcolor__c,Table_Border_Color__c,Table_Font_Family__c,Table_Font_Size__c,Table_Font_Style__c,
                        Table_Footer_Backgroundcolor__c,Table_Footer_Text_Color__c,Table_Header_Backgroundcolor__c,Table_Header_Text_Color__c,
                        H3color__c,H4color__c,Header_Color__c,Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,
                        Is_Active__c,Typography__c
                         from CSS_Styler__c where name =:pagename and Is_Active__c = true];
        }
        else{
            CSSStyles = [select CSS__c,Backgroundcolor__c,Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,
                        Table_Backgroundcolor__c,Table_Border_Color__c,Table_Font_Family__c,Table_Font_Size__c,Table_Font_Style__c,
                        Table_Footer_Backgroundcolor__c,Table_Footer_Text_Color__c,Table_Header_Backgroundcolor__c,Table_Header_Text_Color__c,
                        H3color__c,H4color__c,Header_Color__c,Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,
                        Is_Active__c,Typography__c from CSS_Styler__c where name = 'ClientInvoice' and Is_Active__c = true];
        }
        //System.assert(false,CSSStyles);
        if(CSSStyles.size() > 0){
            cssObj = CSSStyles[0];
            return CSSStyles[0].CSS__c;
        }
        else
            return '';
    }
    
    
}
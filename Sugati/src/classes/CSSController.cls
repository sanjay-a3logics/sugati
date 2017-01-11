public with sharing class CSSController {
    public CSS_Styler__c cssstyle {get;set;} 
    public String NameSpacePrefix{get; set;}
    
    public CSSController(){
       
    }
    
    public String getCSSData(){
        String id = ApexPages.currentPage().getParameters().get('id');
        cssStyle = new CSS_Styler__c();
        cssStyle.CS_Button_JSON__c = '';
        
        ApexClass cls =[select NamespacePrefix from ApexClass where Name ='CSSController'];
        if(cls.NamespacePrefix != null){
            nameSpacePrefix = cls.NamespacePrefix+'__';
        }
        else{
            nameSpacePrefix = '';
        }
        
        if(id != null && id != ''){
            for(CSS_Styler__c cs : [Select id , Email__c,Typography__c,Table__c,Button__c,name,Email_Font_Family__c,Email_Font_Size__c,
                                    Table_Backgroundcolor__c,Table_Border_Color__c,Table_Font_Family__c,Table_Font_Size__c,
                                    Table_Font_Style__c,Table_Footer_Backgroundcolor__c,Table_Footer_Text_Color__c,
                                    Table_Header_Backgroundcolor__c,Table_Header_Text_Color__c,
                                   Email_Font_Style__c,Email_Font_Color__c, CSS__c, CS_Button_JSON__c, Button_CSS__c, Is_Active__c,
                                   Backgroundcolor__c,Font_Family__c,Font_Size__c,Font_Style__c,H1color__c,H2color__c,H3color__c,
                                   H4color__c,Header_Color__c,Header_Font_size__c,Header_Font_Style__c,Hr_Background__c,Hr_Height__c,
                                   CS_Itinerary_Page_Marker__c, CS_Travelling_Country_Marker__c, CS_Address_Marker__c from CSS_Styler__c
                                    where id = :id]){
                cssStyle = cs; 
                if(cs.Email_Font_Size__c == null) {
                    cs.Email_Font_Size__c = '12';
                }
            }
            if(cssstyle.CS_Button_JSON__c == null)
                cssStyle.CS_Button_JSON__c = '';
        }
        return JSON.serialize(cssstyle );
    }
    
    
    public String getPageNames(){
        List<ApexPage> lst = [select id,Name from Apexpage order by Name];
        Set<String> listApexpage = new Set<String>();
        for(Apexpage temp : lst)
            listApexpage.add(temp.name);
        return JSON.serialize(listApexPage);
    }
    
    //Save CSS Record
    @remoteAction
    public static CSS_Styler__c SaveCssData(String css){
        List<CSS_Styler__c > cssstylerList = new List<CSS_Styler__c>();
        CSS_Styler__c cssdata = (CSS_Styler__c)JSON.deserialize(css,CSS_Styler__c.class);
        String compileCSS = '.slds{\n';
        if(cssdata.Typography__c){
            if(cssdata.Backgroundcolor__c != null && cssdata.Backgroundcolor__c != '')
                compileCSS += 'background-color: ' + cssdata.Backgroundcolor__c + ' !important;\n';
            if(cssdata.Font_Family__c != null && cssdata.Font_Family__c != '')
                compileCSS += 'font-family: ' + cssdata.Font_Family__c + ' !important;\n';
            if(cssdata.Font_Size__c != null && cssdata.Font_Size__c != '')
                compileCSS += 'font-size: ' + cssdata.Font_Size__c + 'px !important;\n';
            if(cssdata.Font_Style__c != null && cssdata.Font_Style__c != '')
                compileCSS += 'font-style: ' + cssdata.Font_Style__c + ' !important;\n';
            
        }
        
        if(cssdata.Typography__c){
            if(cssdata.H1color__c != null && cssdata.H1color__c != '')
                compileCSS += 'h1{\n color: ' + cssdata.H1color__c + ' !important;\n}\n\n';
            if(cssdata.H2color__c != null && cssdata.H2color__c != '')
                compileCSS += 'h2{\n color: ' + cssdata.H2color__c + ' !important;\n}\n\n';
            if(cssdata.H3color__c != null && cssdata.H3color__c != '')
                compileCSS += 'h3{\n color: ' + cssdata.H3color__c + ' !important;\n}\n\n';
            if(cssdata.H4color__c != null && cssdata.H4color__c != '')
                compileCSS += 'h4{\n color: ' + cssdata.H4color__c + ' !important;\n}\n\n';
            compileCSS += 'hr{\n';
            if(cssdata.Hr_Background__c != null && cssdata.Hr_Background__c != '')
                compileCSS += 'background: ' + cssdata.Hr_Background__c + ' !important;\n';
            if(cssdata.Hr_Height__c != null && cssdata.Hr_Height__c != '')
                compileCSS += 'height: ' + cssdata.Hr_Height__c + ' !important;\n';
        }
        compileCSS += '}\n\n';
        if(cssdata.Email__c){
            compileCSS += '.emailBody{\n';
                if(cssdata.Email_Font_Family__c != null && cssdata.Email_Font_Family__c != '')
                    compileCSS += 'font-family: ' + cssdata.Email_Font_Family__c + ' !important;\n';
                if(cssdata.Email_Font_Size__c != null && cssdata.Email_Font_Size__c != '')
                    compileCSS += 'font-size: ' + cssdata.Email_Font_Size__c + 'px !important;\n';
                if(cssdata.Email_Font_Style__c != null && cssdata.Email_Font_Style__c != '')
                    compileCSS += 'font-style: ' + cssdata.Email_Font_Style__c + ' !important;\n';
                if(cssdata.Email_Font_Color__c != null && cssdata.Email_Font_Color__c != '')
                    compileCSS += 'color: ' + cssdata.Email_Font_Color__c + ' !important;\n';
            compileCSS += '}';
            
            compileCSS += '.emailBody td{\n';
                if(cssdata.Email_Font_Family__c != null && cssdata.Email_Font_Family__c != '')
                    compileCSS += 'font-family: ' + cssdata.Email_Font_Family__c + ' !important;\n';
                if(cssdata.Email_Font_Size__c != null && cssdata.Email_Font_Size__c != '')
                    compileCSS += 'font-size: ' + cssdata.Email_Font_Size__c + 'px !important;\n';
                if(cssdata.Email_Font_Style__c != null && cssdata.Email_Font_Style__c != '')
                    compileCSS += 'font-style: ' + cssdata.Email_Font_Style__c + ' !important;\n';
                if(cssdata.Email_Font_Color__c != null && cssdata.Email_Font_Color__c != '')
                    compileCSS += 'color: ' + cssdata.Email_Font_Color__c + ' !important;\n';
            compileCSS += '}';
        }
        if(cssdata.Button__c){
            cssData.CSS__c = compileCSS + cssData.Button_CSS__c;
        }
        else{
            cssData.CSS__c = compileCSS ;
        }
        cssstylerList.add(cssdata);
        
        //Inactive all other css if current one is active
        if(cssdata.Is_Active__c){
            for(CSS_Styler__c  cssRec : [select id,Is_Active__c from CSS_Styler__c where id != :cssdata.id AND Is_Active__c = true]){
                //cssRec.Is_Active__c = false;
                cssstylerList.add(cssRec);
            }
        }
        upsert cssstylerList; 
        return cssdata;
    } 
    
    @RemoteAction
    public static List<document> getDocument(String nameContains){
        String nameStr = '%'+nameContains+'%';
        //System.assert(false,[Select Id,Name,Description,IsPublic,ContentType from document where ContentType = 'image/png']);
        return [Select Id,Name,Description,IsPublic,ContentType from document where ContentType = 'image/png' and Name like :nameStr and IsPublic = true];
    }
    
    //Return Address Markup URL
    @remoteAction
    public static String getAddressMarkerURL(){
        String mapURL = '';
        for(CSS_Styler__c cs : [select CS_Address_Marker__c from CSS_Styler__c where Is_Active__c = true limit 1]){
            if(cs.CS_Address_Marker__c != null)
                mapURL = cs.CS_Address_Marker__c;
        }
        return mapURL;
    }
    
    //Return Address Markup URL
    @remoteAction
    public static String getItineraryMarkerURL(){
        String mapURL = '';
        for(CSS_Styler__c cs : [select CS_Itinerary_Page_Marker__c from CSS_Styler__c where Is_Active__c = true limit 1]){
            if(cs.CS_Itinerary_Page_Marker__c != null)
                mapURL = cs.CS_Itinerary_Page_Marker__c;
        }
        return mapURL;
    }
    
   
}
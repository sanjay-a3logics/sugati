@isTest
public with sharing class CSSStylerTest {
    @isTest public static void testGetCss() {
        
       
        /**
         * Test with valid pagename        
         */
        String pagename   = 'TestPage';
        String csscontent = 'CSS Content';
        
        // Insert test page
        CSS_Styler__c objCSS = new CSS_Styler__c(name = pagename, CSS__c = csscontent, Is_Active__c = true);
        insert objCSS;
        ApexPages.StandardController controller = new ApexPages.StandardController(objCSS);
        CSSStyler css = new CSSStyler(controller);
        
        css.pagename = pagename;
        System.assertEquals(csscontent, css.getCss());
        
        
        /**
         * Test with invalid pagename        
         */
        css.pagename = 'InvalidPage';
        System.assertEquals('', css.getCss());
        
        
        /**
         * Test with blank pagename        
         */
        css.pagename = '';
        System.assertEquals('', css.getCss());
    }
}
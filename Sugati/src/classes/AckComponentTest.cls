@isTest
public with sharing Class AckComponentTest{
    
    @testSetup
    static void setupData(){
        CSS_Styler__c css = new CSS_Styler__c(Name = 'TestPage', Email__c = true, Email_Font_Family__c = 'test', Email_Font_Size__c  = '10', Email_Font_Style__c = 'test', Email_Font_Color__c= 'test',Is_Active__c=true);
        insert css;
        System.assertNotEquals(css.Id, null);     
        css = new CSS_Styler__c(Name = 'SendEmail', Email__c = true, Email_Font_Family__c = 'test', Email_Font_Size__c  = '10', Email_Font_Style__c = 'test', Email_Font_Color__c= 'test',Is_Active__c=true);
        insert css;
        TestServices.createSiteCustomSetting();
        
    }
    
    @isTest
    public static void testGetErrorMessages(){
        Error_Message__c errmsg = new Error_Message__c(
            name = 'Test Error', 
            page_name__c = 'Test Page', 
            error_message__c = 'Test Error Message');
        insert errmsg;
        
        Map<String,String> mapErrorMessage = new Map<String,String>();
        mapErrorMessage.put('Test Error', 'Test Error Message');
        
        System.assertEquals(mapErrorMessage, AckComponent.getErrorMessages('Test Page'));
    }
    
    @isTest
    public static void testGetContact(){
    
        // BEGIN Setup
        List<Account> acctList = new List<Account> {
            new Account (Name = 'Test Account')
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name      = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                CloseDate = Date.today()
            )
        };
        insert oppList;
        
        List<Contact> contactList = new List<Contact> {
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'John',
                LastName  = 'Smith',
                Email     = 'john@domain.com'
            )
        };
        insert contactList;
        // END Setup
        
        /**
         * Test with oppId 
         */
        System.assertEquals('john@domain.com', AckComponent.getContact(oppList[0].id).get(0).value);
        System.assertEquals('John Smith (john@domain.com)', AckComponent.getContact(oppList[0].id).get(0).label);
        
        /**
         * Test without oppId 
         */
        System.assertEquals(new List<AckComponent.pickListValue>(), AckComponent.getContact(''));
        System.assertEquals(new List<AckComponent.pickListValue>(), AckComponent.getContact(null));   
    }
    
    @isTest
    public static void testGetTemplate(){
    
        // BEGIN Setup
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            Test.startTest(); 
            
            EmailTemplate emailTemp = new EmailTemplate(
                DeveloperName = 'test',
                TemplateType  = 'Custom',
                FolderId      = UserInfo.getUserId(), 
                Name          = 'Template Name',
                Body          = '',
                HtmlValue     = '<html></html>',
                isActive      = true
            );
            insert emailTemp;
            System.debug(emailTemp.id);
            
            Test.stopTest(); 
        }   
         
        List<Account> acctList = new List<Account> {
            new Account (
                Name            = 'Test Account',
                A_First_Name__c = 'John',
                A_Last_Name__c  = 'Smith'
            )
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name      = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                CloseDate = Date.today(),
                O_Follow_Up_Time__c = System.today()
            ),
            new Opportunity(
                Name      = 'Opportunity 2',
                AccountID = acctList[0].id,
                StageName = 'Test',
                CloseDate = Date.today(),
                 O_Follow_Up_Time__c = System.today()
            )
        };
        insert oppList;
        
        List<Contact> contactList = new List<Contact> {
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'John',
                LastName  = 'Smith',
                Email     = 'john@domain.com'
            ),
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'Mary',
                LastName  = 'Brown',
                Email     = 'mary@domain.com'
            )
        };
        insert contactList;
        
        List<Client_Payment__c> clientPayments = new List<Client_Payment__c>(); 
        clientPayments.add(new Client_Payment__c (CP_Opportunity__c = oppList[0].Id));
        insert clientPayments;
        
        List<Group_Member__c> gmList = new List<Group_Member__c> {
            new Group_Member__c(
                GM_Contact__c        = contactList[0].Id,
                GM_Opportunity__c    = oppList[0].Id,
                GM_Lead_Passenger__c = true
            ),
            new Group_Member__c(
                GM_Contact__c        = contactList[1].Id,
                GM_Opportunity__c    = oppList[1].Id,
                GM_Lead_Passenger__c = true
            )
        };
        insert gmList;
        
        Email_Template__c et = new Email_Template__c(
            ET_Page_Section__c  = 'Page Name',
            ET_Template_Name__c = 'Template Name',
            ET_User__c          = UserInfo.getUserId()
        );
        insert et;
        
        
        // END Setup
        
        /**
         * Test with oppId 
         */
        System.System.assert(AckComponent.getTemplate(oppList[0].id, 'Page Name', 'TestPage') != null);
        System.System.assert(AckComponent.getTemplate(oppList[1].Id, 'Page Name', 'TestPage') != null);
        
        /**
         * Test without oppId 
         */
        //System.assert(AckComponent.getTemplate(null, 'Page Name') == null);
        System.assert(AckComponent.getTemplate(oppList[0].id, '', '') == null); 
        
        AckComponent.EmailWrapper ew = new AckComponent.EmailWrapper('Email Content');
        ew.selectedTo  = new List<AckComponent.pickListValue>{new AckComponent.pickListValue('to@domain.com', 'To')};
        ew.selectedCc  = new List<AckComponent.pickListValue>{new AckComponent.pickListValue('cc@domain.com', 'CC')};
        ew.selectedBcc = new List<AckComponent.pickListValue>{new AckComponent.pickListValue('bcc@domain.com', 'BCC')};
        Attachment att = new Attachment(body=Blob.valueOf('test'), name='test', parentId=oppList[0].Id);
        insert att;
        
        System.assertEquals('Sucess', AckComponent.sendEmail(ew, 'Email Body', oppList[0].Id, '', '', new List<String>{att.Id})); 
        System.assertEquals('Sucess', AckComponent.sendEmail(ew, 'Email Body', oppList[0].Id, 'Acknowledgement', 'TestPage', new List<String>{att.Id})); 
        System.assertEquals('Sucess', AckComponent.sendEmail(ew, 'Email Body', oppList[0].Id, 'Holiday Suggestions', 'TestPage', new List<String>{att.Id}));     
        
        System.System.assert(AckComponent.getSelectedTemplate(oppList[0].id, 'Page Name', et.Id, null, null, null) != null);
        System.System.assert(AckComponent.getSelectedTemplate(oppList[0].id, 'Page Name', et.Id, null, oppList[0].id, new List<String>{oppList[0].Id}) != null);
        
        System.System.assert(AckComponent.getFolderReports('Page Name', oppList[0].id) != null);
    }
    
    @isTest
    public static void testSaveBroucheRequestContact(){
        // BEGIN Setup
        List<Account> acctList = new List<Account> {
            new Account (Name = 'Test Account')
        };
        insert acctList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(
                Name  = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                O_Departure_Date__c = Date.today(),
                CloseDate = Date.today()
            ),
            
            new Opportunity(
                Name  = 'Opportunity 1',
                AccountID = acctList[0].id,
                StageName = 'Test',
                O_Departure_Date__c = Date.today(),
                CloseDate = Date.today()
            )
        };
        insert oppList;
        
        List<Contact> contactList = new List<Contact> {
            new Contact(
                AccountID = acctList[0].id,
                FirstName = 'John',
                LastName  = 'Smith',
                Email     = 'john@domain.com'
            )
        };
        insert contactList;
       
        // END Setup
        // Set the pageRef to Quote 1
        PageReference pageRef = Page.HolidayEnquiry;
        
        // Set the current page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', oppList[0].Id);
        AckComponent ack = new AckComponent();
        ack.emailAddresses = 'test@test.com';
        ack.emailW = 'test';
        ack.emailTemp = new EmailTemplate();
        System.assertEquals(1, AckComponent.getOppRecords(oppList[0].Id).size());
        System.assertEquals(true, AckComponent.saveBroucheRequestContact(JSON.serialize(contactList[0])));   
    }
}
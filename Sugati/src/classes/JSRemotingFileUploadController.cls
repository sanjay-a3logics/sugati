global with sharing class JSRemotingFileUploadController {
    public String folderId{get; set;}
    
    public JSRemotingFileUploadController() {
        List<Folder> lstFolder = [Select Id from folder where name = 'Site Folder' limit 1];
        if(lstFolder.size() > 0){
            folderId = lstFolder[0].Id;
        }
        else{
            folderId = 'Error';
        }
    }
    
      //Fetch all the HE Page Messages
    public String getHEPageErrorMessage(){
        return JSON.serialize(ErrorMessageController.getErrorMessage('FileUpload'));
    }
    
    @RemoteAction
    public static String doUploadAttachment(String recordId, String attachmentBody, String attachmentName, String attachmentId) {
        try{
            if(recordId != null) {
                SObject acct = getRecord(recordId);
                if(acct != null) {
                    if(attachmentBody != null) {
                        Attachment att = getAttachment(attachmentId);
                        String newBody = '';
                        if(att.Body != null) {
                            newBody = EncodingUtil.base64Encode(att.Body);
                        }
                        newBody += attachmentBody;
                        att.Body = EncodingUtil.base64Decode(newBody);
                        if(attachmentId == null) {
                            att.Name = attachmentName;
                            att.parentId = recordId;
                        }
                        upsert att;
                        return att.Id + ':::' + att.Name;
                    } else {
                        return 'Attachment Body was null';
                    }
                } else {
                    return 'Record could not be found';
                }
            } else {
                return 'Record Id was null';
            }
        }
        Catch(Exception e){
            System.assert(false,e.getStackTraceString()+' : :'+e.getMessage());
            return null;
        }
    }
     
   
    @RemoteAction
    public static List<Attachment> getAttchments(String recordId){
        return [Select Id,Name from Attachment where parentId = :recordId ORDER BY CreatedDate];
    }
     
    private static SObject getRecord(String recordId) {
        list<SObject> records;
        if(recordId.startsWith('006')){
            records = [SELECT Id, Name
                                  FROM Opportunity
                                  WHERE Id =: recordId];
        }
        else if(recordId.startsWith('001')){
            records = [SELECT Id, Name
                                  FROM Account
                                  WHERE Id =: recordId];
        }
        else if(recordId.startsWith('00Q')){
            records = [SELECT Id, Name
                                  FROM Lead 
                                  WHERE Id =: recordId];
        }
        else{
            String query = 'SELECT Id, Name FROM '+JSRemotingFileUploadController.getObjectType(''+recordId)+' WHERE Id =: recordId';
            records = Database.query(query);    
        }
        if(records.isEmpty()) {
            return null;
        } else {            return records[0];
        }
    }
    
    
    private static String getObjectType(String recordId){
        String myIdPrefix = String.valueOf(recordId).substring(0,3); //get just the prefix
        Map<String, Schema.SObjectType> gd = 
        Schema.getGlobalDescribe(); 
        for(Schema.SObjectType stype : gd.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            System.debug('Prefix is ' + prefix);
            if(prefix!=null && prefix.equals(myIdPrefix))
            {
                return r.getName();
                break;
            }
        }
        return null;
    }
    
    
    @RemoteAction
    public static String doUploadDocument(String folderId, String attachmentBody, String attachmentName, String docId) {
        try{
            if(docId == null || docId  == ''){
                List<String> lstStr = attachmentName.split('-');
                String strName = '%'+lstStr[0]+'%';
                Delete [Select Id from Document where Name like :strName];
            }
            if(attachmentBody != null) {
                Document att = getDocuments(docId);
                String newBody = '';
                if(att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
                if(docId == null) {
                    att.FolderId = folderId;
                    att.Name = attachmentName;
                    att.ContentType = 'image/png';
                    att.IsPublic = true;
                }
                upsert att;
                return att.Id + ':::' + att.Name;
            } else {
                return 'Attachment Body was null';
            }
        }
        catch(Exception e){
            System.assert(false,e.getStackTraceString());
            return null;
        }
    }
    
    @RemoteAction
    public static List<document> getDocument(String nameContains){
        List<String> nameStr = nameContains.split(',');
        //System.assert(false,[Select Id,Name,Description,IsPublic,ContentType from document where ContentType = 'image/png']);
        return [Select Id,Name,Description,IsPublic,ContentType from document where ContentType = 'image/png' and Name in :nameStr and IsPublic = true];
    }
     
    private static Document getDocuments(String docId) {
        list<Document> attachments = [SELECT Id, Name, Body
                                        FROM Document
                                        WHERE Id =: docId];
        if(attachments.isEmpty()) {
            Document a = new Document();
            return a;
        } else {
            return attachments[0];
        } 
    }
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Name, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
}
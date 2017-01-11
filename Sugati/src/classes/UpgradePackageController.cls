public class UpgradePackageController{

    public PageReference UpgradeEdition() {
        return null;
    }

    public String selectedRadio { get; set; }
    public String inputText1 { get; set; }
    public String inputText2 { get; set; }
    public String pssCode{get; set;}
    public String pageMessage{get; set;}
    public Boolean validated{get; set;}
    public Pro_UE__c proEdition{get; set;}
    
    public UpgradePackageController(){
        validated = false;    
    
    }
    
    
    
    public void keyDecryption(){
        try{
            Blob cryptoKey1 = EncodingUtil.base64Decode(inputText1);
            Blob encryptedData1 = EncodingUtil.base64Decode(inputText2);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey1, encryptedData1);
            
            // Decode the decrypted data for subsequent use
             String decryptedDataString = decryptedData.toString();
             List<String> lstCode = decryptedDataString.split('##');
             if(lstCode.size() != 3 || lstCode[2] != pssCode){
                 pageMessage ='Invalid Passcode or Encrypted Key';
                 validated  = false;
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pageMessage));
             }
             else{
                 List<Pro_UE__c> proRecList = [Select Id,Group_Booking__c,Holiday_Suggestion__c,Task_Management__c,Reports__c  from Pro_UE__c limit 1];
                 
                 if(proRecList.size()==0)
                 {
                     Pro_UE__c proEdition = new Pro_UE__c();
                     insert proEdition;
                     proEdition = proEdition;
                 }
                 else{
                     proEdition = proRecList[0];
                 }
                 validated  = true;
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Validated Successfully'));
                 /*Pro_UE__c proEdition = [Select Id,Group_Booking__c,Holiday_Suggestion__c,Task_Management__c  from Pro_UE__c limit 1];
                 proEdition.Group_Booking__c =  true;
                 proEdition.Holiday_Suggestion__c =  true;
                 proEdition.Task_Management__c =  true;
                 proEdition.Reports__c =true;
                  pageMessage ='Success';
                 update proEdition; */
                 
             }
             
          }
        catch(Exception e){
                pageMessage =e.getMessage();
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pageMessage));
                //system.assert(false,e.getStackTraceString()+'######'+e.getMessage());
          }
        
    }

    public void checkSelectedValue(){        
        system.debug('Selected value is: ' + selectedRadio );        
    } 
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pro Edition','Pro Edition'));
        options.add(new SelectOption('Full Edition','Full Edition'));
        return options;

    }


}
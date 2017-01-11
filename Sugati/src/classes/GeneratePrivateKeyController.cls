public class GeneratePrivateKeyController{
    public String selectedRadio { get; set; }
    public String inputText1 { get; set; }
    public String pKey{get;set;}
    public String passcode{get;set;}
    public String enCryptedKey{get;set;}
    public String pageMessage{get; set;}
    
    public GeneratePrivateKeyController(){
         
    }
    
    
    
   

    public void generateKey(){        
        try{    
            
            Blob cryptoKey = Crypto.generateAesKey(256);
            pKey  =  EncodingUtil.base64Encode(cryptoKey);  
            Blob data = Blob.valueOf(UserInfo.getOrganizationId()+'##'+selectedRadio+'##'+passcode);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
            enCryptedKey = EncodingUtil.base64Encode(encryptedData);
            
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Success"'));   
            
        }
        catch(Exception e){
           
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Error"'));
                
        }      
    } 
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pro Edition','Pro Edition'));
        options.add(new SelectOption('Full Edition','Full Edition'));
        return options;

    }


}
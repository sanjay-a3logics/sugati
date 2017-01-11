public with sharing class PaymentGatewayController {

    public final string SAGEPAY = 'Sagepay';
    public final string RECURLY = 'Recurly';
    public final string PAYPAL = 'Paypal';
    public final string CHECKOUT = 'Checkout';
    
    public String selectedGateway { get; set; }
    
    public PageReference initiate() {
        
        if (selectedGateway == SAGEPAY ) {
            
        }
        else if (selectedGateway == RECURLY ) {
        
        }
        else if (selectedGateway == PAYPAL ) {
        
        }
        else if (selectedGateway == CHECKOUT ) {
        
        }
        return null;
    }
    
    public Pagereference doAuthorization(string url) {
        
        return new Pagereference(url);
    }
}
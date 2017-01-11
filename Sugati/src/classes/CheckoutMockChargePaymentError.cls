@isTest
public with sharing class CheckoutMockChargePaymentError implements HttpCalloutMock{
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.assertEquals('https://api2.checkout.com/v2/charges/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        res.setHeader('Content-Type', 'application/json');
        String body='{ "id": "charge_348DC9EE672G71A42CC6", "liveMode": true, "created": "2016-03-20T22:53:51Z", "value": 218514, "currency": "USD", "trackId": "a0P28000001q4uREAQ", "description": " Reference Number LF-4375 **** Customer Name Test", "email": "test@test.com", "chargeMode": 0, "transactionIndicator": 1, "customerIp": null, "responseMessage": "Approved", "responseAdvancedInfo": "Approved", "responseCode": "20000", "status": "Authorised", "authCode": "935344", "isCascaded": false, "autoCapture": "Y", "autoCapTime": 0.0 }';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}
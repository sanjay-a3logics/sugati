@isTest
public with sharing class CheckoutMockChargeAPIError implements HttpCalloutMock{
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.assertEquals('https://api2.checkout.com/v2/charges/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        res.setHeader('Content-Type', 'application/json');
        String body='{"errorCode" : "400", "message" : "failed", "errors" : ["Test", "test"]}';
        res.setBody(body);
        res.setStatusCode(201);
        return res;
    }
}
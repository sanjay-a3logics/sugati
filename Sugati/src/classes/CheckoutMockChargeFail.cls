@isTest
public with sharing class CheckoutMockChargeFail implements HttpCalloutMock{
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.assertEquals('POST', req.getMethod());
        res.setHeader('Content-Type', 'application/json');
        String body='{"errorCode" : "400", "message" : "failed", "errors" : ["Test", "test"]}';
        res.setBody(body);
        res.setStatusCode(400);
        return res;
    }
}
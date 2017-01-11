@isTest
public with sharing class TestCheckoutMock implements HttpCalloutMock{
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body='{"id":"card_tok_290047E2-F744-408D-B0F0-3AFD17E4ECEC","liveMode":true,"created":"2016-03-20T22:53:48Z","used":false,"card":{"expiryMonth":"10","expiryYear":"2016","billingDetails":{"addressLine1":"UNIT 26","addressLine2":"362 MITCHELL ROAD","postcode":"2015","country":"AU","city":"ALEXANDRIA","state":null,"phone":{}},"id":"","last4":"3592","paymentMethod":"Visa","name":null}}';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}
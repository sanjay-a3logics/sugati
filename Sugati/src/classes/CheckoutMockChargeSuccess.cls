@isTest
public with sharing class CheckoutMockChargeSuccess implements HttpCalloutMock{
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.assertEquals('https://api2.checkout.com/v2/charges/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        res.setHeader('Content-Type', 'application/json');
        String body='{"id":"charge_348DC9EE672G71A42CC6","liveMode":true,"created":"2016-03-20T22:53:51Z","value":218514,"currency":"USD","trackId":"a0P28000001q4uREAQ","description":" Reference Number LF-4375 **** Customer Name Test","email":"test@test.com","chargeMode":0,"transactionIndicator":1,"customerIp":null,"responseMessage":"Approved","responseAdvancedInfo":"Approved","responseCode":"10000","status":"Authorised","authCode":"935344","isCascaded":false,"autoCapture":"Y","autoCapTime":0.0,"card":{"customerId":"cust_1B17A0AA-D1D5-4D5D-A7BC-143511D52A93","expiryMonth":"10","expiryYear":"2016","billingDetails":{"addressLine1":"UNIT 26","addressLine2":"362 MITCHELL ROAD","postcode":"2015","country":"AU","city":"ALEXANDRIA","state":null,"phone":{}},"id":"test_45332D44-CE91-40BF-B14D-701DF21D7725","last4":"3592","paymentMethod":"Visa","fingerprint":"43B635D3458ED434F26D6ECC53783378DDFA8E1023769EE6664E1BC7CB118380","name":null,"cvvCheck":"Y","avsCheck":"G"},"riskCheck":true,"customerPaymentPlans":null,"metadata":{"oppId":"00628000002GSlJAAW"},"shippingDetails":{"addressLine1":null,"addressLine2":null,"postcode":null,"country":null,"city":null,"state":null,"phone":{}},"products":[],"udf1":null,"udf2":null,"udf3":null,"udf4":null,"udf5":null}';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}
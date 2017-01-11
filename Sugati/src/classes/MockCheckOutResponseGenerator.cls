@isTest
global class MockCheckOutResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        System.debug('00');
        System.assertEquals('https://api2.checkout.com/v2/tokens/card', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        System.debug('01');        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"1234", "created": "2016-11-24 00:00:00", "used": true, "card": {"expiryMonth":"11", "expiryYear":"20", "id":"1234", "last4":"5678", "paymentMethod":"visa", "name":"John Smith"}}');
        res.setStatusCode(200);
        return res;
    }
}
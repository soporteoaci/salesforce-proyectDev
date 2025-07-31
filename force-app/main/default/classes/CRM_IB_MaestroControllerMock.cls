@isTest
global class CRM_IB_MaestroControllerMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(201);
        
        return res;
    }
}
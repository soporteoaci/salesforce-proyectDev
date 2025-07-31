@isTest
global class CRM_IB_AltaModOppSUPERMock implements HttpCalloutMock{
	global HttpResponse respond(HTTPRequest req){
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(204);
		return res;
	}
}
@isTest
global class CRM_IB_AltaClienteSAPMock implements HttpCalloutMock{
	global HttpResponse respond(HTTPRequest req){
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
	
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('codContable', '111111');
        gen.writeEndObject();
	
		res.setBody(gen.getAsString());
		return res;
	}
}
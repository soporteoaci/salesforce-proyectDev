@isTest
global class CRM_IB_AltaClienteSUPERErrorMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req){
		HttpResponse res = new HttpResponse();
		res.setStatus('KO');
		res.setStatusCode(400);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('errorCode', '400');
        gen.writeStringField('errorDateTime', '2023-06-30T09:57:19.639Z');
        gen.writeStringField('errorMessage', 'Bad request');
        gen.writeStringField('errorDescription', 'Los campos [idpais] e [idprovincia] son obligatorios cuando la cuenta tiene código contable');
        gen.writeStringField('correlationId', 'b184044e-4a9f-4ee0-a1db-097dc6a23f59');
        gen.writeEndObject();
	
		res.setBody(gen.getAsString());
        
		return res;
	}
}
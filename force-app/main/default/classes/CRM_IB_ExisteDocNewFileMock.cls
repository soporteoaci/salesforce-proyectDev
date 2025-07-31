@isTest
global class CRM_IB_ExisteDocNewFileMock implements HttpCalloutMock{
	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
		
        if (req.getEndpoint().contains('ct=1')) {
        
        	res.setStatus('OK');
        	res.setStatusCode(200);
      
        	JSONGenerator gen = JSON.createGenerator(true);
        	gen.writeStartObject();        
        	gen.writeStringField('respuesta', 'si');
            gen.writeEndObject();
			res.setBody(gen.getAsString());   
        } else {
            res.setStatus('KO');
        	res.setStatusCode(400);
            JSONGenerator gen = JSON.createGenerator(true);
        	gen.writeStartObject();        
        	gen.writeStringField('respuesta', 'no');
            gen.writeEndObject();
			res.setBody(gen.getAsString());   
        }
                 

		return res;
	}
}
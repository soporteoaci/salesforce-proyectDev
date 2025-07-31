public class CRM_IB_ExisteDocNewFile {

	// Metodo que consulta en NewFile si estan publicados los documentos en base al operador
	// idObj: id del Objeto al que pertenece el documento
	//docs: Lista de documentos (codigos), separados por coma (',')
	// operador: (and/or) para consultar si existen todos o alguno de los documentos
    public static Boolean existeDocNewFile(Id idObj, String docs, String operador) {
        System.debug('existeDocNewFile: ' + idObj);
		Boolean existeDoc = false;
               
        //Monto endpoint
        String objType = idObj.getSObjectType().getDescribe().getName();
        String urlParams = '';
        if ('Oportunidad__c' == objType) {
            System.debug('Metodo consulta oportunidad');
			urlParams = '?ct=1&cc=' +  idObj + '&dt=' + docs + '&cp=' + operador;
           
		} else if ('Referencia_Comercial__c' == objType) {
            System.debug('Metodo consulta referencia');
			urlParams = '?ct=2&cc=' +  idObj + '&dt=' + docs + '&cp=' + operador;
          
		}
        
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        String endpoint = cs.URL_Existe_Doc_New_File__c + urlParams;
        
        Control_Integracion__c controlInt = new Control_Integracion__c();
        controlInt.Metodo__c = 'GET';
        controlInt.Interfaz__c = 'ExisteDocNewFile';
        controlInt.Servicio__c = endpoint;  
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);       

        request.setMethod('GET');
        request.setHeader('Accept' , 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        System.debug('endpoint: ' + endpoint);
        
        try {
        	System.debug('ANTES RESPONSE');
            HttpResponse response = http.send(request);
            System.debug('DESPUES RESPONSE');        
            if (response != null) {
                System.debug('Response Status: ' + response.getStatusCode());
                String responseBody = response.getBody();  
                
                if (response.getStatusCode() == 200) {
                    System.debug('Response: ' + responseBody);
                    
                    Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String respuesta = (String)responseMap.get('respuesta');
                    
                    if ('si'.equals(respuesta)) {
                        existeDoc = true;
                    }
                    
                    controlInt.Response__c = responseBody;
                    controlInt.Status_Code__c = response.getStatusCode();       
                    controlInt.Error_Code__c = '00';
                    controlInt.Error_Message__c = 'OK';
            
                } else {
                    String json = response.getBody();
                    Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(json);
                    System.debug('Response: ' + responseMap);
                    controlInt.Status_Code__c = response.getStatusCode();
                    controlInt.Response__c = responseBody;
                }
            } else {
                System.debug('Response null');
                controlInt.Error_Code__c = '99';
                controlInt.Error_Message__c = 'KO';
            }            
        } catch (CalloutException e) {
        	controlInt.Error_Code__c = '99';
            controlInt.Error_Message__c = e.getmessage();         
        }
        
        insert controlInt;
        System.debug('ExisteDoc:' + existeDoc);       
        return existeDoc;
    }
}
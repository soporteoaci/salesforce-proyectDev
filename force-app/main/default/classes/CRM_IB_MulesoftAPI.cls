/**
* @author Ayesa
* @since 24-05-2023
* @desc Creacion APEX Rest integracion CR-IB 
* Mule API
*/
@RestResource(urlMapping='/mulesoft-api/*')
global class CRM_IB_MulesoftAPI {
    @HttpPost
    global static String callApiMule(String pathEndpoint, String requestJSON, String method, Id idEntidad, String interfaz) {
        
        String result;
        System.debug('RequestJSON: ' + requestJSON);
        System.debug('Method: ' + method); 
        System.debug('pathEndpoint: ' + pathEndpoint); 

        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        
        Control_Integracion__c controlInt = new Control_Integracion__c();
        controlInt.Request__c = requestJSON;
        controlInt.Metodo__c = method;
        controlInt.Interfaz__c = interfaz;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        if(method == 'POST'){
            request.setEndpoint(pathEndpoint);
            controlInt.Servicio__c = pathEndpoint;  
            request.setBody(requestJSON);                        
        }else if(method == 'PUT'){          
            request.setEndpoint(pathEndpoint + '/' + idEntidad); 
            controlInt.Servicio__c = pathEndpoint + '/' + idEntidad;  
            request.setBody(requestJSON);            
        }else if(method == 'DELETE'){
            request.setEndpoint(pathEndpoint + '/' + idEntidad); 
            controlInt.Servicio__c = pathEndpoint + '/' + idEntidad;  
        }
                
        request.setMethod(method);
        request.setHeader('Accept' , 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('client-id', cs.client_id__c);
        request.setHeader('client-secret',cs.client_secret__c);
        
        System.debug('Request: ' + request.getBody());
        
        try {
        	HttpResponse response = http.send(request);
                    
            if(response != null){
                
                String responseBody = response.getBody(); 
                
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + responseBody);
                    controlInt.Response__c = responseBody;
                    controlInt.Status_Code__c = response.getStatusCode();       
                    controlInt.Error_Code__c = '00';
                    controlInt.Error_Message__c = 'OK';
                    result = 'OK';
                    
                    tratarResponse(interfaz, request, response);
                    
                } else if(response.getStatusCode() == 201 || response.getStatusCode() == 204){
                    System.debug('Response: ' + responseBody);
                    controlInt.Response__c = responseBody;
                    controlInt.Status_Code__c = response.getStatusCode();       
                    controlInt.Error_Code__c = '00';
                    controlInt.Error_Message__c = 'OK';
                    result = 'OK';
                }else{
                    String json = response.getBody();
                    Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(json);
                    System.debug('Response: ' + responseMap);
                    controlInt.Status_Code__c = response.getStatusCode();
                    controlInt.Response__c = responseBody;
                    controlInt.Error_Code__c = (String)responseMap.get('errorCode');
                    controlInt.Error_Message__c = (String)responseMap.get('errorMessage') + '/' + (String)responseMap.get('errorDescription');
                    result = (String)responseMap.get('errorCode') + ':' + (String)responseMap.get('errorMessage') + '/' + (String)responseMap.get('errorDescription');
                }
            }else{
                controlInt.Error_Code__c = '99';
                controlInt.Error_Message__c = 'KO';
                result = '99: No se ha recibido respuesta del servicio de SUPER.';
            }            
        } catch (CalloutException e) {
        	controlInt.Error_Code__c = '99';
            controlInt.Error_Message__c = 'KO';
            result = '99: No se ha recibido respuesta del servicio de SUPER.';           
        }
        
        insert controlInt;
        return result;
    }
    
    
    @AuraEnabled  
    public static String superPreventaComprobacion(Id idOpp){
        
       	 String mostrar_wraning;
        Opportunity opp = [SELECT id,Codigo_OC__c,StageName, GP_Super__c, CR_Super__c
                                    FROM Opportunity WHERE Id =:idOpp LIMIT 1];
        
        if(opp.GP_Super__c == '' || opp.GP_Super__c == null ||opp.CR_Super__c == '' || opp.CR_Super__c == null){
            mostrar_wraning ='true';
        }else{
            mostrar_wraning = 'false';
        }
       
        return mostrar_wraning;       
    }
    
	@AuraEnabled
	public static String superPreventa(Id idOpp){
        System.debug('Super preventa Oportunidad');
        String mode ;
        List<Opportunity> opp = [SELECT id,Codigo_OC__c,StageName,Subfase__c
                                    FROM Opportunity WHERE Id =:idOpp LIMIT 1];
        
        if(opp.get(0).Subfase__c== 'Ganada' || opp.get(0).Subfase__c== 'Perdida' || opp.get(0).Subfase__c== 'Aplazada / anulada'   || opp.get(0).Subfase__c== 'No presentada'){
           
           //opp.get(0).StageName == 'Cerrada'
            mode = '&modo=R';
        }else{
            mode = '&modo=W';
        }
        System.debug('Modo de acceso: '+ mode);
        Blob encodePreventaBlob = Blob.valueOf('goto=detalleitem&guid=' +  opp.get(0).Codigo_OC__c + mode);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        String encodePreventa =  cs.URL_Preventa__c + '?' + EncodingUtil.base64Encode(encodePreventaBlob);
        System.debug('encodePreventa: ' + encodePreventa);
        return encodePreventa;
	}
        
    @AuraEnabled
    public static String superPreventaObjetivo(Id idObj){
        System.debug('Super preventa Objetivo');
        String mode = '&modo=R';
        List<Objetivo__c> obj = [SELECT id,Codigo_Objetivo__c,Estado__c
                                 FROM Objetivo__c WHERE Id =:idObj LIMIT 1];
        if(obj.get(0).Estado__c == 'F'){
            mode = '&modo=R';
        }else{
            mode = '&modo=W';
        }
        Blob encodePreventaBlob = Blob.valueOf('goto=detalleitem&guid=' +  obj.get(0).Codigo_Objetivo__c + mode);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        String encodePreventa =  cs.URL_Preventa__c + '?' + EncodingUtil.base64Encode(encodePreventaBlob);
        System.debug('encodePreventa: ' + encodePreventa);
        return encodePreventa;
    }
    
   	@AuraEnabled
	public static String newFile(Id id) {
		String objType = id.getSObjectType().getDescribe().getName();
        System.debug('getSObjectType(): '+ objType);
		String urlParams;
        Blob encodeNewFileBlob;
        String encodeNewFile;
        System.debug('objType:'+ objType);
        if ('Opportunity' == objType) {
			List<Opportunity> lOpp = [SELECT Name FROM Opportunity WHERE Id =:id LIMIT 1];	

			if (lOpp != null && lOpp.size() > 0) {
				Opportunity opp = lOpp.get(0);
				urlParams = 'op=gc&ct=1&cc=' +  id + '&cd='+ EncodingUtil.urlEncode(opp.Name, 'UTF-8') + '&dt=0,1,2,3,4,5';
			}
		} else if ('Referencia_Comercial__c' == objType) {
			List<Referencia_Comercial__c> lrefCom = [SELECT Name FROM Referencia_Comercial__c WHERE Id =:id LIMIT 1];	

			if (lrefCom != null && lrefCom.size() > 0) {
				Referencia_Comercial__c refCom = lrefCom.get(0);
				urlParams = 'op=gc&ct=2&cc=' +  id + '&cd='+ EncodingUtil.urlEncode(refCom.Name, 'UTF-8') + '&dt=6';  
			}
		}
        System.debug('urlParams: ' + urlParams);
        encodeNewFileBlob = Blob.valueOf(urlParams);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
		encodeNewFile = cs.URL_Consulta_New_File__c + '?p=' + EncodingUtil.base64Encode(encodeNewFileBlob);
		System.debug('encodeNewFile: ' + encodeNewFile);
      
        return encodeNewFile;
	}
    
    @AuraEnabled
    public static void oportunidad_documentacion(Id id){
        
        String objType = id.getSObjectType().getDescribe().getName();
        System.debug('getSObjectType(): '+ objType);
	
        System.debug('objType:'+ objType);
        if ('Opportunity' == objType) {
			List<Opportunity> lOpp = [SELECT id, Name,Documentacion_IB__c FROM Opportunity WHERE Id =:id LIMIT 1];	
            System.debug('Actualizamos a true  opp.Documentacion_IB__c =true 1');
            if (lOpp != null && lOpp.size() > 0 ) {
                Opportunity opp = lOpp.get(0);
                if(opp.Documentacion_IB__c == false){
                    try{
                        System.debug('Actualizamos a true  opp.Documentacion_IB__c =true');
                        opp.Documentacion_IB__c =true;
                        update opp;
                        
                    }catch(DMLException e){ 
                         System.debug('Error Extensión Oportunidad: ' + e.getMessage());
                    }
                    
                }

			}
		} else if ('Referencia_Comercial__c' == objType) {
			List<Referencia_Comercial__c> lrefCom = [SELECT Name,Ficha__c FROM Referencia_Comercial__c WHERE Id =:id LIMIT 1];	

			if (lrefCom != null && lrefCom.size() > 0) {
				Referencia_Comercial__c refCom = lrefCom.get(0);
                if(refCom.Ficha__c==false){
                    try{
                         System.debug('Actualizamos a true  refCom.Ficha__c =true;');
                       // refCom.Ficha__c =true;
                        update refCom;
                        
                    }catch(DMLException e){ 
                         System.debug('Error Extensión Oportunidad: ' + e.getMessage());
                    }
				
			}
		}
        
    }
    }  
    
        
    //Metodo para tratar los body de las respuestas que apliquen
    private static void tratarResponse(String interfaz, HttpRequest request, HttpResponse response) {      
        switch on interfaz {
            when 'AltaClienteSAP' {					
                //Recupero el codContable de la respuesta y el id del cliente en la request para hacer el update
                Map<String,Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(request.getBody());
                Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String accId = (String) requestMap.get('codCta');
                System.debug('accId:' + accId);
                String codContable = (String)responseMap.get('codContable');
                System.debug('codContable:' + codContable);
                
                Account accUpdate = new Account();
                accUpdate.Id = accId;
                accUpdate.SAP_Account_IB__c = codContable;
                
                update accUpdate;               
                System.debug('Account ' + accId + ' updated');
            }
        }       
    } 
}
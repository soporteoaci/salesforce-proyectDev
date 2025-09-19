public class IntegracionAprobacionesController {
    //CLASE CREADA PARA MANEJAR APROBACIONES DESDE SALESFORCE AL PORTAFIRMAS DE APP2YOU
    
    //PRELIMINAR:
    public static String peticionCreacionAprobacionPreliminar(Id idTareaAprobacion){
        
        Tarea_aprobacion__c tarea = [SELECT id,Opportunity__c FROM Tarea_aprobacion__c WHERE Id =: idTareaAprobacion];
        Map<String,Object> params = new Map<String,Object>();
        params.put(CRM_IntegrationConstants.INTEGRATION_APR_PRELIMINAR_PARAM01,idTareaAprobacion);
        
        //Envío petición
        Map<String, Object> response = RICM.CallOutService.executeRequest(CRM_IntegrationConstants.INTEGRATION_APR_PRELIMINAR_NAME, params, null);
        
        //Tratamiento de la respuesta
        if(response != null && response.containsKey('result') && response.get('result') == 'OK'){
            System.debug('Respuesta Obtenida: '+((HttpResponse) response.get('response')).getBody() != null ? ((HttpResponse) response.get('response')).getBody() : '[]');
            return ((HttpResponse) response.get('response')).getBody() != null ? ((HttpResponse) response.get('response')).getBody() : '[]';
        } else {
            return '[]';
        }
    }
}
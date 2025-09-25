public with sharing class Aprobaciones_ApiAcelerator {
    
    public class RequestWrapper {
        @InvocableVariable(required=true)
        public Id recordId;
    }
    
    public class ResponseWrapper {
        @InvocableVariable
        public String resultado;
    }

    @InvocableMethod(
        label='Llamar a Portafirmas' 
        description='Realiza la llamada REST al portafirmas y devuelve OK/KO'
    )
    public static List<ResponseWrapper> sendToPortafirmas(List<RequestWrapper> requests) {
        List<ResponseWrapper> responses = new List<ResponseWrapper>();

        // Recolectamos todos los Ids de tareas
        Set<Id> taskIds = new Set<Id>();
        for (RequestWrapper req : requests) {
            if (req.recordId != null) {
                taskIds.add(req.recordId);
            }
        }

        // Consulta única de las tareas
        Map<Id, Tarea_aprobacion__c> tareasMap = new Map<Id, Tarea_aprobacion__c>(
            [SELECT Id, Tipo__c
             FROM Tarea_aprobacion__c 
             WHERE Id IN :taskIds]
        );

        // Mapeo de Tipo__c con la constante de integración correspondiente
        Map<String, String> tipoToIntegration = new Map<String, String>{
            'Preliminar'            => CRM_IntegrationConstants.INTEGRATION_APR_PRELIMINAR_NAME,
            'Oferta'                => CRM_IntegrationConstants.INTEGRATION_APR_OFERTA_NAME,
            'Aprobación Preventa'   => CRM_IntegrationConstants.INTEGRATION_APR_PREVENTA_NAME,
            'Oferta QA Económico'   => CRM_IntegrationConstants.INTEGRATION_APR_QAECONOMICO_NAME,
            'Oferta QA Técnico'     => CRM_IntegrationConstants.INTEGRATION_APR_QATECNICO_NAME,
            'Socios'                => CRM_IntegrationConstants.INTEGRATION_APR_SOCIOS_NAME
        };

        for (RequestWrapper req : requests) {
            ResponseWrapper res = new ResponseWrapper();
            try {
                Tarea_aprobacion__c tareaApr = tareasMap.get(req.recordId);

                if (tareaApr != null && tipoToIntegration.containsKey(tareaApr.Tipo__c)) {
                    System.debug('Procesando tarea ' + tareaApr.Id + ' de tipo ' + tareaApr.Tipo__c);

                    // Parámetros para este callout (no compartidos entre iteraciones)
                    Map<String,String> params = new Map<String,String>{
                        CRM_IntegrationConstants.INTEGRATION_APR_PARAM01 => String.valueOf(req.recordId)
                    };

                    // Callout principal según el tipo
                    Map<String, Object> response = RICM.CallOutService.executeRequest(
                        tipoToIntegration.get(tareaApr.Tipo__c),
                        params,
                        null
                    );

                    // Validación de respuesta
                    if (response != null && response.containsKey('result') && response.get('result') == 'OK') {
                        HttpResponse httpRes = (HttpResponse) response.get('response');
                        res.resultado = (httpRes != null && httpRes.getBody() != null) 
                            ? httpRes.getBody() 
                            : '[]';
                        System.debug('httpRes: '+httpRes);
                        System.debug('httpRes.getBody(): '+httpRes.getBody());
                        //TODO DEVOLVER LA RESPUESTA AL FLUJO PARA VER QUE HACER EN OK O KO.
                    } else {
                        res.resultado = 'KO';
                    }
                } else {
                    res.resultado = 'KO - Tipo no soportado o tarea no encontrada';
                }

            } catch (Exception e) {
                res.resultado = 'KO - ' + e.getMessage();
            }
            responses.add(res);
        }
		System.debug('responses: '+responses);
        return responses;
    }
}
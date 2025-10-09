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
        List<Tarea_aprobacion__c> tareasToUpdate = new List<Tarea_aprobacion__c>();

        // Recolectamos todos los Ids de tareas
        Set<Id> taskIds = new Set<Id>();
        for (RequestWrapper req : requests) {
            if (req.recordId != null) {
                taskIds.add(req.recordId);
            }
        }

        // Consulta única de las tareas
        Map<Id, Tarea_aprobacion__c> tareasMap = new Map<Id, Tarea_aprobacion__c>(
            [SELECT Id, Tipo__c FROM Tarea_aprobacion__c WHERE Id IN :taskIds]
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

                    // Parámetros para este callout
                    Map<String,String> params = new Map<String,String>{
                        CRM_IntegrationConstants.INTEGRATION_APR_PARAM01 => String.valueOf(req.recordId)
                    };

                    // Callout principal
                    Map<String, Object> response = RICM.CallOutService.executeRequest(
                        tipoToIntegration.get(tareaApr.Tipo__c),
                        params,
                        null
                    );

                    // Validación de respuesta
                    if (response != null && response.containsKey('result') && response.get('result') == 'OK') {
                        HttpResponse httpRes = (HttpResponse) response.get('response');

                        if (httpRes != null && httpRes.getBody() != null) {
                            String body = httpRes.getBody();
                            System.debug('Respuesta Portafirmas: ' + body);

                            // Intentamos parsear el JSON recibido
                            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(body);

                            if (parsed != null && parsed.containsKey('codigo_portafirmas')) {
                                String codigoPF = String.valueOf(parsed.get('codigo_portafirmas'));

                                // Actualizar la tarea con el código del portafirmas
                                tareaApr.C_digo_Portafirmas__c = codigoPF;
                                tareasToUpdate.add(tareaApr);

                                res.resultado = 'OK - Código Portafirmas: ' + codigoPF;
                            } else {
                                res.resultado = 'KO - No se encontró código_portafirmas en la respuesta';
                            }
                        } else {
                            res.resultado = 'KO - Respuesta vacía';
                        }
                    } else {
                        res.resultado = 'KO - Respuesta nula o result distinto de OK';
                    }
                } else {
                    res.resultado = 'KO - Tipo no soportado o tarea no encontrada';
                }
            } catch (Exception e) {
                res.resultado = 'KO - ' + e.getMessage();
            }
            responses.add(res);
        }

        // Realizamos actualización masiva fuera del bucle
        if (!tareasToUpdate.isEmpty()) {
            try {
                update tareasToUpdate;
                System.debug('Actualizadas tareas con código portafirmas: ' + tareasToUpdate);
            } catch (DmlException dmle) {
                System.debug('Error actualizando tareas: ' + dmle.getMessage());
            }
        }

        System.debug('responses: ' + responses);
        return responses;
    }
}
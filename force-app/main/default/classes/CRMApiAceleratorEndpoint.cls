global class CRMApiAceleratorEndpoint implements RICM.ResponseGeneratorInterface {

    global void generateResponse(Map<String, Object> param0) {
        System.debug('Callback recibido desde sistema externo: ' + JSON.serializePretty(param0));

        Boolean resultado = false;
        String informacion = '';

        try {
            // Extracción de parámetros recibidos
            String idSolicitud;
            if (param0.containsKey('id_solicitud')) {
                Object rawId = param0.get('id_solicitud');
                // Convertimos a String sin forzar tipo
                idSolicitud = String.valueOf(rawId);
            }

            List<Object> idSolicitudes = (param0.containsKey('id_solicitudes'))
                ? (List<Object>) param0.get('id_solicitudes') : new List<Object>();
            Integer idEstado = (param0.containsKey('id_estado')) 
                ? (Integer) param0.get('id_estado') : null;
            String firmante = (param0.containsKey('firmante')) 
                ? String.valueOf(param0.get('firmante')) : '';
            String motivo = (param0.containsKey('motivo')) 
                ? String.valueOf(param0.get('motivo')) : '';

            System.debug('id_solicitud: ' + idSolicitud);
            System.debug('id_estado: ' + idEstado);
            System.debug('firmante: ' + firmante);
            System.debug('motivo: ' + motivo);

            // Mapeo de estados externos → internos
            Map<Integer, String> estadoToDecision = new Map<Integer, String>{
                1 => 'En proceso',
                2 => 'En proceso',
                3 => 'Rechazado',
                4 => 'Aprobado',
                5 => 'Rechazado',
                6 => 'Aprobado',
                7 => 'Rechazado',
                8 => 'Aprobado',
                9 => 'Rechazado',
                10 => 'En proceso'
            };

            if (idSolicitud != null) {
                List<Tarea_aprobacion__c> tareas = [
                    SELECT Id, Decision__c
                    FROM Tarea_aprobacion__c
                    WHERE C_digo_Portafirmas__c = :idSolicitud
                    LIMIT 1
                ];

                if (!tareas.isEmpty()) {
                    Tarea_aprobacion__c tarea = tareas[0];
                    String nuevaDecision = estadoToDecision.containsKey(idEstado)
                        ? estadoToDecision.get(idEstado)
                        : 'En proceso';

                    tarea.Decision__c = nuevaDecision;
                    update tarea;

                    resultado = true;
                    informacion = 'Tarea de aprobación actualizada correctamente. Estado: ' + nuevaDecision;
                    System.debug('Tarea actualizada correctamente: ' + tarea.Id);
                } else {
                    resultado = false;
                    informacion = 'No se encontró ninguna Tarea_aprobacion__c con C_digo_Portafirmas__c = ' + idSolicitud;
                    System.debug(informacion);
                }

            } else if (!idSolicitudes.isEmpty()) {
                informacion = 'Recibido callback múltiple con solicitudes: ' + JSON.serialize(idSolicitudes);
                resultado = true;
                System.debug('Callback múltiple recibido.');
            } else {
                resultado = false;
                informacion = 'No se recibió ningún identificador de solicitud.';
                System.debug(informacion);
            }

        } catch (Exception e) {
            resultado = false;
            informacion = 'Error procesando callback: ' + e.getMessage();
            System.debug('Error en CRMApiAceleratorEndpoint: ' + e.getStackTraceString());
        }

        Map<String, Object> responseMap = new Map<String, Object>{
            'resultado' => resultado,
            'informacion' => informacion
        };

        // Solo se ejecuta cuando hay contexto REST (no en Developer Console)
        if (RestContext.response != null) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        }

		System.debug('Respuesta enviada al sistema externo: ' + JSON.serializePretty(responseMap));

    }
}
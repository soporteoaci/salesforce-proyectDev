public with sharing class EquipoPreventaService {
    // Campo HTML definitivo donde se guarda el resumen HTML del equipo
    private static final String HTML_FIELD = 'Equipo_Oferta__c';

    public class EquipoPreventaWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String nombre;
        @AuraEnabled public String mercantil;
        @AuraEnabled public Decimal horas;
        @AuraEnabled public String email;
        @AuraEnabled public String codigo;
        @AuraEnabled public Boolean isNew;
        @AuraEnabled public Boolean isDeleted;
        @AuraEnabled public Boolean isChanged;
        
        public EquipoPreventaWrapper() {
            // Constructor vacío requerido para deserialización desde LWC
        }
    }
    public class InitData {
        @AuraEnabled public List<EquipoPreventaWrapper> existentes;
        @AuraEnabled public List<String> mercantilPicklist;
        @AuraEnabled public String htmlActual;
        @AuraEnabled public String subfase;
        @AuraEnabled public Boolean bloqueoPorAprobacion;
        @AuraEnabled public Boolean hasKamItEquipoOfertaObjetivo;
        @AuraEnabled public Boolean canEdit;
    }
    public class EmpleadoWSWrapper {
        @AuraEnabled public String nombreCompleto;
        @AuraEnabled public String correo;
        @AuraEnabled public String codigo;
        @AuraEnabled public String sociedadCodigo;
        @AuraEnabled public String mercantilMapeado;
    }
    public class SaveResultWrapper {
        @AuraEnabled public Integer insertados;
        @AuraEnabled public Integer actualizados;
        @AuraEnabled public Integer eliminados;
        @AuraEnabled public String html;
        @AuraEnabled public List<EquipoPreventaWrapper> resultado;
    }

    @AuraEnabled(cacheable=true)
    public static InitData loadData(Id opportunityId) {
        if (opportunityId == null) throw new AuraHandledException('OpportunityId requerido');
        
        // Obtener datos de la Opportunity
        Opportunity opp = [
            SELECT Id, Subfase__c, Bloqueo_por_aprobacion__c 
            FROM Opportunity 
            WHERE Id = :opportunityId 
            LIMIT 1
        ];
        
        Map<Id, Equipo_Oferta__c> hijos = new Map<Id, Equipo_Oferta__c>(
            [SELECT Id, Mercantil__c, Horas__c, Nombre_y_apellidos__c, Objetivo__c, Opportunity__c, C_digo_de_Empleado__c 
             FROM Equipo_Oferta__c WHERE Opportunity__c = :opportunityId ORDER BY CreatedDate ASC]
        );
        
        List<EquipoPreventaWrapper> wraps = new List<EquipoPreventaWrapper>();
        for (Equipo_Oferta__c e : hijos.values()) {
            EquipoPreventaWrapper w = new EquipoPreventaWrapper();
            w.id = e.Id;
            w.nombre = e.Nombre_y_apellidos__c;
            w.mercantil = e.Mercantil__c;
            w.horas = e.Horas__c;
            w.codigo = e.C_digo_de_Empleado__c;
            w.isNew = false;
            w.isDeleted = false;
            w.isChanged = false;
            wraps.add(w);
        }
        
        // Verificar permisos personalizados
        Boolean hasKamItPermission = FeatureManagement.checkPermission('KAM_IT_Equipo_Oferta_Objetivo');
        
        // Aplicar lógica de visibilidad
        Boolean canEdit = true;
        String subfase = opp.Subfase__c;
        Boolean bloqueoPorAprobacion = opp.Bloqueo_por_aprobacion__c == true;
        
        // Condiciones que impiden la edición
        if (subfase == 'Pte ok preliminar' || 
            subfase == 'Aplazada / anulada' ||
            subfase == 'No presentada' ||
            subfase == 'Ganada' ||
            subfase == 'Perdida' ||
            bloqueoPorAprobacion ||
            hasKamItPermission) {
            canEdit = false;
        }
        
        List<String> mercantilVals = getPicklistValues(Equipo_Oferta__c.Mercantil__c.getDescribe());
        
        InitData out = new InitData();
        out.existentes = wraps;
        out.mercantilPicklist = mercantilVals;
        out.htmlActual = getHtmlValue(opportunityId);
        out.subfase = subfase;
        out.bloqueoPorAprobacion = bloqueoPorAprobacion;
        out.hasKamItEquipoOfertaObjetivo = hasKamItPermission;
        out.canEdit = canEdit;
        
        return out;
    }

    private static List<String> getPicklistValues(Schema.DescribeFieldResult dfr) {
        List<String> vals = new List<String>();
        for (Schema.PicklistEntry p : dfr.getPicklistValues()) {
            if (p.isActive()) vals.add(p.getValue());
        }
        return vals;
    }
    
    private static String mapearMercantilPorSociedad(String sociedadCodigo, List<String> mercantilPicklist) {
        if (String.isBlank(sociedadCodigo) || mercantilPicklist == null) return null;
        
        // Buscar en la picklist un valor que comience con el código de sociedad
        for (String mercantil : mercantilPicklist) {
            if (mercantil.startsWith(sociedadCodigo + ' - ')) {
                return mercantil;
            }
        }
        return null;
    }
    private static String getHtmlValue(Id oppId) {
        try {
            String soql = 'SELECT ' + HTML_FIELD + ' FROM Opportunity WHERE Id = :oppId';
            SObject opp = Database.query(soql);
            return (String)opp.get(HTML_FIELD);
        } catch (Exception ex) {
            return null;
        }
    }

    @AuraEnabled
    public static List<EmpleadoWSWrapper> searchEmpleados(String codigo, String nombre, String apellido1, String apellido2) {
        List<EmpleadoWSWrapper> res = new List<EmpleadoWSWrapper>();
        
        // Obtener la picklist de mercantil para el mapeo
        List<String> mercantilPicklist = getPicklistValues(Equipo_Oferta__c.Mercantil__c.getDescribe());
        
        try {
            // Construcción de data para el envío a ApiAcelerator (usando paquete RICM)
            WebService__c webServiceData = WebService__c.getInstance();
            String user = webServiceData.username__c;        
            String pass = webServiceData.password__c;
            
            // Construir pares "campo":"valor" solo para filtros no vacíos
            List<String> filtros = new List<String>();
            if (!String.isBlank(codigo)) filtros.add('"numeroPersonal":"' + escapeJson(codigo) + '"');
            if (!String.isBlank(nombre)) filtros.add('"nombre":"' + escapeJson(nombre) + '"');
            if (!String.isBlank(apellido1)) filtros.add('"apellido1":"' + escapeJson(apellido1) + '"');
            if (!String.isBlank(apellido2)) filtros.add('"apellido2":"' + escapeJson(apellido2) + '"');

            String buscarTexto = String.join(filtros, ',');
            
            String envio = 'username=' + user + '&password=' + pass + '&data=';   
            String data = '{"activo":"true",' + buscarTexto + '}';
            String dataFinal = envio + data;
            
            // Preparar parámetros para el CallOutService
            Map<String,String> params = new Map<String,String>();
            params.put(CRM_IntegrationConstants.INTEGRATION_RESPONSABLE_PARAM01, dataFinal);
            
            // Envío petición usando el paquete gestionado RICM
            Map<String, Object> response = RICM.CallOutService.executeRequest(
                CRM_IntegrationConstants.INTEGRATION_RESPONSABLE_NAME, 
                params, 
                null
            );
            
            // Tratamiento de la respuesta
            if (response != null && response.containsKey('result') && response.get('result') == 'OK') {
                HttpResponse httpResp = (HttpResponse) response.get('response');
                String body = httpResp != null ? httpResp.getBody() : '[]';
                
                if (String.isBlank(body) || body == '[]') {
                    return res;
                }
                
                // Parsear respuesta JSON
                Object parsed = JSON.deserializeUntyped(body);
                List<Object> lista;
                
                if (parsed instanceof List<Object>) {
                    lista = (List<Object>)parsed;
                } else if (parsed instanceof Map<String,Object>) {
                    Map<String,Object> root = (Map<String,Object>)parsed;
                    // Intentar obtener una clave estándar como 'data', 'resultado', etc.
                    Object posible = null;
                    for (String k : new List<String>{'data','resultado','empleados','items','values'}) {
                        if (root.containsKey(k)) { posible = root.get(k); break; }
                    }
                    if (posible instanceof List<Object>) {
                        lista = (List<Object>)posible;
                    } else {
                        lista = new List<Object>();
                    }
                } else {
                    lista = new List<Object>();
                }
                
                // Procesar cada empleado de la respuesta
                for (Object o : lista) {
                    if (!(o instanceof Map<String,Object>)) continue;
                    Map<String,Object> m = (Map<String,Object>)o;
                    EmpleadoWSWrapper w = new EmpleadoWSWrapper();
                    
                    // Mapeos según la estructura del JSON recibido
                    w.nombreCompleto = (String)m.get('nombreYApellidos');
                    w.correo = (String)m.get('correoElectronico');
                    w.codigo = (String)m.get('numeroPersonal');
                    w.sociedadCodigo = (String)m.get('sociedadCodigo');
                    
                    // Mapear el código de sociedad con el valor de la picklist Mercantil
                    w.mercantilMapeado = mapearMercantilPorSociedad(w.sociedadCodigo, mercantilPicklist);
                    
                    if (String.isBlank(w.nombreCompleto) && String.isBlank(w.codigo) && String.isBlank(w.correo)) {
                        continue; // ignora entradas vacías
                    }
                    res.add(w);
                }
            } else {
                // Si la respuesta no es OK, retornar lista vacía
                System.debug('Error en respuesta del servicio: ' + response);
                return new List<EmpleadoWSWrapper>();
            }
        } catch (Exception e) {
            throw new AuraHandledException('Fallo búsqueda empleados: ' + e.getMessage());
        }
        return res;
    }

    // Helper para escapar cadenas JSON simples (sin usar JSON.serialize por formato requerido en concatenación)
    private static String escapeJson(String v) {
        if (v == null) return '';
        return v.replace('"','\\"');
    }

    @AuraEnabled
    public static SaveResultWrapper save(Id opportunityId, String registrosJson) {
        if (opportunityId == null) throw new AuraHandledException('OpportunityId requerido');
        
        // VERIFICACIÓN DE PERMISOS ANTES DE CUALQUIER OPERACIÓN
        if (!canEditEquipo(opportunityId)) {
            throw new AuraHandledException('No tiene permisos para realizar esta operación. El estado de la oportunidad puede haber cambiado.');
        }
        
        List<EquipoPreventaWrapper> registros = new List<EquipoPreventaWrapper>();
        
        // Deserialización manual para evitar problemas con @AuraEnabled
        if (String.isNotBlank(registrosJson)) {
            try {
                List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(registrosJson);
                for (Object obj : jsonList) {
                    Map<String, Object> jsonMap = (Map<String, Object>)obj;
                    EquipoPreventaWrapper w = new EquipoPreventaWrapper();
                    w.id = (Id)jsonMap.get('id');
                    w.nombre = (String)jsonMap.get('nombre');
                    w.mercantil = (String)jsonMap.get('mercantil');
                    
                    // Manejar horas con diferentes tipos numéricos
                    Object horasObj = jsonMap.get('horas');
                    if (horasObj != null) {
                        if (horasObj instanceof Decimal) {
                            w.horas = (Decimal)horasObj;
                        } else if (horasObj instanceof Integer) {
                            w.horas = Decimal.valueOf((Integer)horasObj);
                        } else if (horasObj instanceof Double) {
                            w.horas = Decimal.valueOf((Double)horasObj);
                        }
                    }
                    
                    w.email = (String)jsonMap.get('email');
                    w.codigo = (String)jsonMap.get('codigo');
                    w.isNew = (Boolean)jsonMap.get('isNew');
                    w.isDeleted = (Boolean)jsonMap.get('isDeleted');
                    w.isChanged = (Boolean)jsonMap.get('isChanged');
                    registros.add(w);
                }
            } catch (Exception e) {
                System.debug('ERROR deserializando JSON: ' + e.getMessage());
                throw new AuraHandledException('Error procesando datos: ' + e.getMessage());
            }
        }

        // DEPURACIÓN: Log de datos recibidos
        System.debug('=== SAVE DEBUG ===');
        System.debug('OpportunityId: ' + opportunityId);
        System.debug('Registros recibidos: ' + registros.size());
        for (EquipoPreventaWrapper w : registros) {
            System.debug('Registro: id=' + w.id + ', nombre=' + w.nombre + ', mercantil=' + w.mercantil + 
                        ', horas=' + w.horas + ', isNew=' + w.isNew + ', isDeleted=' + w.isDeleted);
        }

        Map<Id, Equipo_Oferta__c> existentes = new Map<Id, Equipo_Oferta__c>(
            [SELECT Id, Mercantil__c, Horas__c, Nombre_y_apellidos__c, Objetivo__c, Opportunity__c, C_digo_de_Empleado__c 
             FROM Equipo_Oferta__c WHERE Opportunity__c = :opportunityId FOR UPDATE]
        );

        System.debug('Registros existentes en BD: ' + existentes.size());

        List<Equipo_Oferta__c> toInsert = new List<Equipo_Oferta__c>();
        List<Equipo_Oferta__c> toUpdate = new List<Equipo_Oferta__c>();
        List<Equipo_Oferta__c> toDelete = new List<Equipo_Oferta__c>();

        for (EquipoPreventaWrapper w : registros) {
            if (w.isDeleted == true) {
                if (w.id != null && existentes.containsKey(w.id)) {
                    toDelete.add(existentes.get(w.id));
                    System.debug('Marcado para DELETE: ' + w.id);
                }
                continue;
            }
            if (w.id == null) {
                // DEPURACIÓN DETALLADA: Verificar cada campo individualmente
                System.debug('Validando registro nuevo:');
                System.debug('  - w.nombre: "' + w.nombre + '" (isBlank: ' + String.isBlank(w.nombre) + ')');
                System.debug('  - w.mercantil: "' + w.mercantil + '" (isBlank: ' + String.isBlank(w.mercantil) + ')');
                System.debug('  - w.horas: ' + w.horas + ' (isNull: ' + (w.horas == null) + ')');
                
                // Verificar que los datos no estén vacíos
                if (String.isBlank(w.nombre) || String.isBlank(w.mercantil) || w.horas == null) {
                    String errorDetail = 'Datos faltantes: ';
                    if (String.isBlank(w.nombre)) errorDetail += 'nombre vacío; ';
                    if (String.isBlank(w.mercantil)) errorDetail += 'mercantil vacío; ';
                    if (w.horas == null) errorDetail += 'horas null; ';
                    System.debug('ERROR: ' + errorDetail);
                    throw new AuraHandledException('Faltan datos obligatorios: ' + errorDetail);
                }
                Equipo_Oferta__c nuevo = new Equipo_Oferta__c(
                    Opportunity__c = opportunityId,
                    Nombre_y_apellidos__c = w.nombre,
                    Mercantil__c = w.mercantil,
                    Horas__c = w.horas,
                    C_digo_de_Empleado__c = w.codigo
                );
                toInsert.add(nuevo);
                System.debug('Marcado para INSERT: ' + w.nombre + ' - ' + w.mercantil + ' - ' + w.horas);
            } else {
                Equipo_Oferta__c old = existentes.get(w.id);
                if (old == null) continue;
                Boolean changed = false;
                if (w.nombre != old.Nombre_y_apellidos__c) { old.Nombre_y_apellidos__c = w.nombre; changed = true; }
                if (w.mercantil != old.Mercantil__c) { old.Mercantil__c = w.mercantil; changed = true; }
                if (w.horas != old.Horas__c) { old.Horas__c = w.horas; changed = true; }
                if (w.codigo != old.C_digo_de_Empleado__c) { old.C_digo_de_Empleado__c = w.codigo; changed = true; }
                if (changed) {
                    toUpdate.add(old);
                    System.debug('Marcado para UPDATE: ' + w.id);
                }
            }
        }

        System.debug('toInsert.size(): ' + toInsert.size());
        System.debug('toUpdate.size(): ' + toUpdate.size());
        System.debug('toDelete.size(): ' + toDelete.size());

        try {
            if (!toInsert.isEmpty()) {
                System.debug('Ejecutando INSERT...');
                insert toInsert;
                System.debug('INSERT exitoso');
            }
            if (!toUpdate.isEmpty()) {
                System.debug('Ejecutando UPDATE...');
                update toUpdate;
                System.debug('UPDATE exitoso');
            }
            if (!toDelete.isEmpty()) {
                System.debug('Ejecutando DELETE...');
                delete toDelete;
                System.debug('DELETE exitoso');
            }
        } catch (DmlException e) {
            System.debug('ERROR DML: ' + e.getMessage());
            throw new AuraHandledException('Error al guardar: ' + e.getDmlMessage(0));
        }

        List<Equipo_Oferta__c> finales = [
            SELECT Id, Nombre_y_apellidos__c, Mercantil__c, Horas__c, C_digo_de_Empleado__c
            FROM Equipo_Oferta__c WHERE Opportunity__c = :opportunityId ORDER BY CreatedDate ASC
        ];
        System.debug('Registros finales consultados: ' + finales.size());
        
        String html = buildHtml(finales);
        System.debug('HTML generado: ' + html);

        try {
            // Verificar que el campo HTML existe antes de intentar actualizarlo
            if (!fieldExists(HTML_FIELD)) {
                System.debug('ADVERTENCIA: El campo ' + HTML_FIELD + ' no existe en Opportunity');
            } else {
                Opportunity o = new Opportunity(Id = opportunityId);
                o.put(HTML_FIELD, html);
                update o;
                System.debug('HTML actualizado en Opportunity');
            }
        } catch (Exception e) {
            System.debug('ERROR actualizando HTML: ' + e.getMessage());
        }

        List<EquipoPreventaWrapper> resultado = new List<EquipoPreventaWrapper>();
        for (Equipo_Oferta__c eo : finales) {
            EquipoPreventaWrapper w = new EquipoPreventaWrapper();
            w.id = eo.Id;
            w.nombre = eo.Nombre_y_apellidos__c;
            w.mercantil = eo.Mercantil__c;
            w.horas = eo.Horas__c;
            w.codigo = eo.C_digo_de_Empleado__c;
            w.isNew = false; w.isChanged = false; w.isDeleted = false;
            resultado.add(w);
        }

        SaveResultWrapper sr = new SaveResultWrapper();
        sr.insertados = toInsert.size();
        sr.actualizados = toUpdate.size();
        sr.eliminados = toDelete.size();
        sr.html = html;
        sr.resultado = resultado;
        
        System.debug('=== FIN SAVE DEBUG ===');
        return sr;
    }

    private static String buildHtml(List<Equipo_Oferta__c> registros) {
        // Formato solicitado con cabeceras específicas y atributos colspan/rowspan
        String html = '<table style="width: 100%;"><tr>'
            + '<th colspan="1" rowspan="1" style="border: 1px solid black;">Nombre y apellidos</th>'
            + '<th colspan="1" rowspan="1" style="border: 1px solid black;">Código de empleado</th>'
            + '<th colspan="1" rowspan="1" style="border: 1px solid black;">Sociedad</th>'
            + '<th colspan="1" rowspan="1" style="border: 1px solid black;">Horas estimadas</th>'
            + '</tr>';
        for (Equipo_Oferta__c r : registros) {
            html += '<tr>'
                + '<td colspan="1" rowspan="1" style="border: 1px solid black;">' + escape(r.Nombre_y_apellidos__c) + '</td>'
                + '<td colspan="1" rowspan="1" style="border: 1px solid black;">' + escape(r.C_digo_de_Empleado__c) + '</td>'
                + '<td colspan="1" rowspan="1" style="border: 1px solid black;">' + escape(r.Mercantil__c) + '</td>'
                + '<td colspan="1" rowspan="1" style="border: 1px solid black;">' + (r.Horas__c == null ? '' : String.valueOf(r.Horas__c)) + '</td>'
                + '</tr>';
        }
        html += '</table>';
        return html;
    }

    private static String escape(String s) {
        if (s == null) return '';
        return s.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;');
    }
    private static Boolean fieldExists(String apiName) {
        try {
            return Opportunity.SObjectType.getDescribe().fields.getMap().containsKey(apiName);
        } catch (Exception e) { return false; }
    }
    private static String getFirstExistingHtmlField() { return HTML_FIELD; }

    @AuraEnabled
    public static Boolean canEditEquipo(Id opportunityId) {
        if (opportunityId == null) return false;
        
        try {
            // Obtener datos actuales de la Opportunity
            Opportunity opp = [
                SELECT Id, Subfase__c, Bloqueo_por_aprobacion__c 
                FROM Opportunity 
                WHERE Id = :opportunityId 
                LIMIT 1
            ];
            
            // Verificar permisos personalizados
            Boolean hasKamItPermission = FeatureManagement.checkPermission('KAM_IT_Equipo_Oferta_Objetivo');
            
            // Aplicar lógica de visibilidad (condiciones del flexipage)
            Boolean canEdit = true;
            String subfase = opp.Subfase__c;
            Boolean bloqueoPorAprobacion = opp.Bloqueo_por_aprobacion__c == true;
            
            // Condiciones que impiden la edición
            if (subfase == 'Pte ok preliminar' || 
                subfase == 'Aplazada / anulada' || 
                subfase == 'No presentada' || 
                subfase == 'Ganada' || 
                subfase == 'Perdida' || 
                bloqueoPorAprobacion || 
                hasKamItPermission) {
                canEdit = false;
            }
            
            return canEdit;
        } catch (Exception e) {
            System.debug('Error verificando permisos: ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static Boolean verificarEmpleadoExiste(Id opportunityId, String codigoEmpleado) {
        if (opportunityId == null || String.isBlank(codigoEmpleado)) return false;
        
        // Verificar permisos antes de la operación
        if (!canEditEquipo(opportunityId)) {
            throw new AuraHandledException('No tiene permisos para realizar esta operación. El estado de la oportunidad puede haber cambiado.');
        }
        
        Integer count = [
            SELECT COUNT() 
            FROM Equipo_Oferta__c 
            WHERE Opportunity__c = :opportunityId 
            AND C_digo_de_Empleado__c = :codigoEmpleado
        ];
        return count > 0;
    }
}
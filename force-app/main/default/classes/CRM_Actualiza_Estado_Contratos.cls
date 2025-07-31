public class CRM_Actualiza_Estado_Contratos {
    
    @AuraEnabled
    public static string getInfoContrato(string objectId) {
        
        String result = '';
        string currentUserId = userInfo.getUserId();
        String emailCurrentUser = UserInfo.getUserEmail();
        
        List<PermissionSetAssignment> listaPermisos = [select id, PermissionSet.name, AssigneeId, Assignee.name from PermissionSetAssignment where AssigneeId =: currentUserId and PermissionSet.name='Gestion_Contratos_Presidencia'];
        
        system.debug(listaPermisos.size());
        
        JSONGenerator res = JSON.createGenerator(true);
        res.writeStartObject();
        
        Contrato__c myContract =[select id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,Codigo_AJI__c,Asistencia_juridica__c,Causa_resolucion__c,Causa_suspension__c,
                                 Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,Prevision_situacion_contrato__c,
                                 Costes_a_reclamar_por_resolucion__c, Costes_a_reclamar_por_suspension__c, Costes_totales_resolucion__c, Costes_a_reclamar_por_resolucion_local__c,Estimacion_costes_extra_local__c,
                                 Costes_totales_resolucion_local__c, Costes_a_reclamar_por_suspension_local__c, Costes_totales_suspension_local__c,Estimacion_coste_extra_por_retraso_local__c,
                                 Costes_totales_suspension__c, Derecho_a_reclamacion_por_suspension__c, Derecho_a_reclamacion_por_resolucion__c, Estimacion_coste_extra_por_retraso__c,
                                 Estimacion_costes_extra__c, Estimacion_meses_de_retraso__c, Negociacion_modificacion_contractual__c,Negociacion_modificacion_finalizada__c, Prevision_costes_extra__c,
                                 Costes_a_reclamar_por_retraso_local__c, Costes_aceptados_por_retraso_local__c, LastModifiedDate, OwnerId,
                                 Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c  from Contrato__c where id =: objectId limit 1];
        system.debug(myContract);
        system.debug(myContract.Documentando_incidencias__c);
        system.debug(myContract.Reqs_Contractuales_sobre_Presencialidad__c);
        
        if (myContract!=null){
            if(myContract.Asistencia_juridica__c!=null){
                res.writeBooleanField('asistenciaJuridica', myContract.Asistencia_juridica__c); 
            }
          /*  else{
                res.writeNullField('asistenciaJuridica');
            }*/
            if(myContract.Documentando_incidencias__c!=null){
                res.writeBooleanField('docIncidencias', myContract.Documentando_incidencias__c); 
            }
           /* else{
                res.writeNullField('docIncidencias');
            }*/
            if(myContract.Codigo_AJI__c!=null){
                res.writeStringField('codAji', myContract.Codigo_AJI__c); 
            }
            else{
                res.writeNullField('codAji');
            }
            if(myContract.Causa_resolucion__c!=null){
                res.writeStringField('causaResolucion',myContract.Causa_resolucion__c ); 
            }
            else{
                res.writeNullField('causaResolucion');
            }
            if(myContract.Causa_retraso__c!=null){
                res.writeStringField('causaRetraso',myContract.Causa_retraso__c );
            }
            else{
                res.writeNullField('causaRetraso');
            }
            if(myContract.Causa_suspension__c!=null){
                res.writeStringField('causaSuspension',myContract.Causa_suspension__c );
            }
            else{
                res.writeNullField('causaSuspension');
            }
            if(myContract.Reqs_Contractuales_sobre_Presencialidad__c!=null){
                res.writeStringField('reqsPresencia',myContract.Reqs_Contractuales_sobre_Presencialidad__c );
            }
            else{
                res.writeNullField('reqsPresencia');
            }
            if(myContract.Situacion_Actual_Contrato__c!=null){
                res.writeStringField('situacionActualContrato',myContract.Situacion_Actual_Contrato__c );
            }
            else{
                res.writeNullField('situacionActualContrato');
            }
            if(myContract.Derecho_a_reclamacion_por_suspension__c!=null){
                res.writeBooleanField('derechoReclamacionSuspension', myContract.Derecho_a_reclamacion_por_suspension__c);
            }
           /* else{
                res.writeNullField('derechoReclamacionSuspension');
            }*/
            if(myContract.Derecho_a_reclamacion_por_resolucion__c!=null){
                res.writeBooleanField('derechoReclamacionResolucion', myContract.Derecho_a_reclamacion_por_resolucion__c);
            }
            /*else{
                res.writeNullField('derechoReclamacionResolucion');
            }*/
            if(myContract.Negociacion_modificacion_contractual__c!=null){
                res.writeBooleanField('negociacionModificacionContrato', myContract.Negociacion_modificacion_contractual__c);
            }
           /* else{
                res.writeNullField('negociacionModificacionContrato');
            }*/
            if(myContract.Prevision_costes_extra__c!=null){
                res.writeBooleanField('previsionCostesExtra', myContract.Prevision_costes_extra__c);
            }
           /* else{
                res.writeNullField('previsionCostesExtra');
            }*/
            if(myContract.Costes_a_reclamar_por_resolucion__c!=null){
                res.writeNumberField('costesReclamarResolucion', myContract.Costes_a_reclamar_por_resolucion__c);
            }
            else{
                res.writeNullField('costesReclamarResolucion');
            }
            if(myContract.Costes_a_reclamar_por_suspension__c!=null){
                res.writeNumberField('costesReclamarSuspension', myContract.Costes_a_reclamar_por_suspension__c);
            }
            else{
                res.writeNullField('costesReclamarSuspension');
            }
            if(myContract.Costes_totales_resolucion__c!=null){
                res.writeNumberField('costesTotalesResolucion', myContract.Costes_totales_resolucion__c);
            }
            else{
                res.writeNullField('costesTotalesResolucion');
            }
            if(myContract.Costes_totales_suspension__c!=null){
                res.writeNumberField('costesTotalesSuspension', myContract.Costes_totales_suspension__c);
            }
            else{
                res.writeNullField('costesTotalesSuspension');
            }
            if(myContract.Estimacion_coste_extra_por_retraso__c!=null){
                res.writeNumberField('estimacionCosteExtraRetraso', myContract.Estimacion_coste_extra_por_retraso__c);
            }
            else{
                res.writeNullField('estimacionCosteExtraRetraso');
            }
            if(myContract.Estimacion_costes_extra__c!=null){
                res.writeNumberField('estimacionCosteExtraNormalidad', myContract.Estimacion_costes_extra__c); 
            }
            else{
                res.writeNullField('estimacionCosteExtraNormalidad');
            }
            if(myContract.Estimacion_meses_de_retraso__c!=null){
                res.writeNumberField('estimacionMesesRetraso', myContract.Estimacion_meses_de_retraso__c);
            }
            else{
                res.writeNullField('estimacionMesesRetraso');
            }
            
            
            
            if(myContract.Costes_a_reclamar_por_resolucion_local__c!=null){
                res.writeNumberField('costesReclamarResolucionLocal', myContract.Costes_a_reclamar_por_resolucion_local__c);
            }
            else{
                res.writeNullField('costesReclamarResolucionLocal');
            }
            if(myContract.Estimacion_costes_extra_local__c!=null){
                res.writeNumberField('estimacionCosteExtraNormalidadLocal', myContract.Estimacion_costes_extra_local__c);
            }
            else{
                res.writeNullField('estimacionCosteExtraNormalidadLocal');
            }
            if(myContract.Costes_totales_resolucion_local__c!=null){
                res.writeNumberField('costesTotalesResolucionLocal', myContract.Costes_totales_resolucion_local__c);
            }
            else{
                res.writeNullField('costesTotalesResolucionLocal');
            }
            if(myContract.Costes_a_reclamar_por_suspension_local__c!=null){
                res.writeNumberField('costesReclamarSuspensionLocal', myContract.Costes_a_reclamar_por_suspension_local__c);
            }
            else{
                res.writeNullField('costesReclamarSuspensionLocal');
            }
            if(myContract.Costes_totales_suspension_local__c!=null){
                res.writeNumberField('costesTotalesSuspensionLocal', myContract.Costes_totales_suspension_local__c);
            }
            else{
                res.writeNullField('costesTotalesSuspensionLocal');
            }
            if(myContract.Estimacion_coste_extra_por_retraso_local__c!=null){
                res.writeNumberField('estimacionCosteExtraRetrasoLocal', myContract.Estimacion_coste_extra_por_retraso_local__c);
            }
            else{
                res.writeNullField('estimacionCosteExtraRetrasoLocal');
            }
            
            if(myContract.Moneda__c!=null){
                res.writeStringField('moneda', myContract.Moneda__c);
            }
            else{
                res.writeNullField('moneda');
            }
            if(myContract.Estado__c!=null){
                res.writeStringField('estado', myContract.Estado__c);
            }
          /*  else{
                res.writeNullField('estado');
            }*/
            if(myContract.Negociacion_modificacion_finalizada__c!=null){
                res.writeBooleanField('negociacionModificacionFinalizada', myContract.Negociacion_modificacion_finalizada__c);
            }
          /*  else{
                res.writeNullField('negociacionModificacionFinalizada');
            }*/
            if(myContract.Negociacion_aceptada__c!=null){
                res.writeBooleanField('negociacionAceptada', myContract.Negociacion_aceptada__c);
            }
           /* else{
                res.writeNullField('negociacionAceptada');
            }*/
            if(myContract.Costes_aceptados_resolucion_local__c!=null){
                res.writeNumberField('costesAceptadosRes', myContract.Costes_aceptados_resolucion_local__c);
            }
            else{
                res.writeNullField('costesAceptadosRes');
            }
            if(myContract.Costes_aceptados_suspension_local__c!=null){
                res.writeNumberField('costesAceptadosSus', myContract.Costes_aceptados_suspension_local__c);
            }
            else{
                res.writeNullField('costesAceptadosSus');
            }
            
            if(myContract.Costes_a_reclamar_por_retraso_local__c!=null){
                res.writeNumberField('costesReclamarRetraso', myContract.Costes_a_reclamar_por_retraso_local__c);
            }
            else{
                res.writeNullField('costesReclamarRetraso');
            }
            if(myContract.Costes_aceptados_por_retraso_local__c!=null){
                res.writeNumberField('costesAceptadosRetraso', myContract.Costes_aceptados_por_retraso_local__c);
            }
            else{
                res.writeNullField('costesAceptadosRetraso');
            }
            if(myContract.Prevision_situacion_contrato__c!=null){
                res.writeStringField('previsionSituacionContrato', myContract.Prevision_situacion_contrato__c);
            }
            else{
                res.writeNullField('previsionSituacionContrato');
            }
            
            Parametros_gestion_contratos__c param = Parametros_gestion_contratos__c.getOrgDefaults(); //Número de días que se lleva sin actualizar el contrato
            Integer mydays = (integer)param.Dias_sin_actualizar__c;
            DateTime fechaLimiteUltimaActualizacion = Datetime.now().addDays(-mydays);
            system.debug(myContract.LastModifiedDate);
            system.debug(fechaLimiteUltimaActualizacion);
            
            
            if(myContract.LastModifiedDate <= fechaLimiteUltimaActualizacion ){
                res.writeBooleanField('contratoDesactualizado',true);
            }else{
                res.writeBooleanField('contratoDesactualizado',false);
            }
            
            if(myContract.OwnerId == currentUserId || emailCurrentUser=='rjimenezv@ayesa.com' ){
                res.writeBooleanField('puedeModificar',true);
            }else{
                res.writeBooleanField('puedeModificar',false);
            }
            
            res.writeEndObject();
            
        }else{
            
        }
        
        result = res.getAsString();
        
        return result;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        
    }
    
    @AuraEnabled
    public static string getMonedaOptions() {
        Map<String,string> mapaMoneda = new Map<String,string>();
        
        string json= '{"monedas":[';      
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contrato__c.Moneda__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            mapaMoneda.put(pickListVal.getValue() ,pickListVal.getLabel() );
            json = json + '{"value":"'+pickListVal.getValue()+'","label":"'+pickListVal.getLabel()+'"},';
        }
        json = json.removeEnd(',');
        json = json + ']}';
        system.debug(mapaMoneda);
        system.debug(json);
        return json;
    }
    
    @AuraEnabled
    public static string getCausaOptions() {
        Map<String,string> mapaCausa = new Map<String,string>();
        
        string json= '{"causaRetraso":[';      
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contrato__c.Causa_retraso__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            mapaCausa.put(pickListVal.getValue() ,pickListVal.getLabel() );
            json = json + '{"value":"'+pickListVal.getValue()+'","label":"'+pickListVal.getLabel()+'"},';
        }
        json = json.removeEnd(',');
        json = json + ']}';
        system.debug(mapaCausa);
        system.debug(json);
        return json;
    }
    
    //Descomentar cuando se suba la parte de documentacion 
    /*@AuraEnabled
    public static string getEvidences(string contractId) {        
        return GC_Documentacion_Tree_Apex.getDocTreeInfo(contractId);
    }*/
    
    @AuraEnabled
    public static string updateInfoContrato(string objectId, string jsonContrato) {
        system.debug(jsonContrato);
        String result = '';
        String message='';        
        Contrato__c myContract =[select id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,LastModifiedDate,Codigo_AJI__c,Asistencia_juridica__c,Causa_resolucion__c,Causa_suspension__c,
                                 Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,OwnerId,Prevision_situacion_contrato__c,
                                 Costes_a_reclamar_por_resolucion__c, Costes_a_reclamar_por_suspension__c, Costes_totales_resolucion__c,  Costes_a_reclamar_por_resolucion_local__c,Estimacion_costes_extra_local__c,
                                 Costes_totales_resolucion_local__c, Costes_a_reclamar_por_suspension_local__c, Costes_totales_suspension_local__c,Estimacion_coste_extra_por_retraso_local__c,Comentarios__c,
                                 Costes_totales_suspension__c, Derecho_a_reclamacion_por_suspension__c, Derecho_a_reclamacion_por_resolucion__c, Estimacion_coste_extra_por_retraso__c,
                                 Estimacion_costes_extra__c, Estimacion_meses_de_retraso__c, Negociacion_modificacion_contractual__c,Negociacion_modificacion_finalizada__c, Prevision_costes_extra__c,
                                 Costes_a_reclamar_por_retraso_local__c, Costes_aceptados_por_retraso_local__c,Fecha_control_correos__c,
                                 Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c  from Contrato__c where id =: objectId limit 1];  
        
        Contrato jsonParse = parseContrato(jsonContrato); 
        system.debug(jsonParse);
        // system.debug(jsonParse.costesAceptadosRetraso);
        // system.debug(jsonParse.costesReclamarRetraso);
        
        if(myContract!=null){
            if(jsonParse.asistenciaJuridica!=null){
                myContract.Asistencia_juridica__c=jsonParse.asistenciaJuridica;
            }else{
                myContract.Asistencia_juridica__c=null;
            }
            if(jsonParse.docIncidencias!=null){
                myContract.Documentando_incidencias__c=jsonParse.docIncidencias;
            }else{
                myContract.Documentando_incidencias__c=null;
            }
            if(jsonParse.codAji!=null){
                myContract.Codigo_AJI__c=jsonParse.codAji;
            }else{
                myContract.Codigo_AJI__c=null;
            }
            if(jsonParse.causaResolucion!=null){
                myContract.Causa_resolucion__c=jsonParse.causaResolucion;
            }else{
                myContract.Causa_resolucion__c=null;
            }
            if(jsonParse.causaRetraso!=null){
                myContract.Causa_retraso__c=jsonParse.causaRetraso;
            }else{
                myContract.Causa_retraso__c=null;
            }
            if(jsonParse.causaSuspension!=null){
                myContract.Causa_suspension__c=jsonParse.causaSuspension;
            }else{
                myContract.Causa_suspension__c=null;
            }
            if(jsonParse.costesReclamarResolucion!=null){
                myContract.Costes_a_reclamar_por_resolucion__c=jsonParse.costesReclamarResolucion;
            }else{
                myContract.Costes_a_reclamar_por_resolucion__c=null;
            }
            if(jsonParse.costesReclamarSuspension!=null){
                myContract.Costes_a_reclamar_por_suspension__c=jsonParse.costesReclamarSuspension;
            }else{
                myContract.Costes_a_reclamar_por_suspension__c=null;
            }
            if(jsonParse.costesTotalesResolucion!=null){
                myContract.Costes_totales_resolucion__c=jsonParse.costesTotalesResolucion;
            }else{
                myContract.Costes_totales_resolucion__c=null;
            }
            if(jsonParse.costesTotalesSuspension!=null){
                myContract.Costes_totales_suspension__c=jsonParse.costesTotalesSuspension;
            }else{
                myContract.Costes_totales_suspension__c=null;
            }
            if(jsonParse.derechoReclamacionSuspension!=null){ //BOOLEAN
                myContract.Derecho_a_reclamacion_por_suspension__c=jsonParse.derechoReclamacionSuspension;
            }else{
                myContract.Derecho_a_reclamacion_por_suspension__c=null;
            }
            if(jsonParse.derechoReclamacionResolucion!=null){//BOOLEAN
                myContract.Derecho_a_reclamacion_por_resolucion__c=jsonParse.derechoReclamacionResolucion;
            }else{
                myContract.Derecho_a_reclamacion_por_resolucion__c=null;
            }
            if(jsonParse.estimacionCosteExtraRetraso!=null){
                myContract.Estimacion_coste_extra_por_retraso__c=jsonParse.estimacionCosteExtraRetraso;
            }else{
                myContract.Estimacion_coste_extra_por_retraso__c=null;
            }
            if(jsonParse.estimacionCosteExtraNormalidad!=null){
                myContract.Estimacion_costes_extra__c=jsonParse.estimacionCosteExtraNormalidad;
            }else{
                myContract.Estimacion_costes_extra__c=null;
            }
            if(jsonParse.estimacionMesesRetraso!=null){
                myContract.Estimacion_meses_de_retraso__c=jsonParse.estimacionMesesRetraso;
            }else{
                myContract.Estimacion_meses_de_retraso__c=null;
            }
            if(jsonParse.negociacionModificacionContrato!=null){//BOOLEAN
                myContract.Negociacion_modificacion_contractual__c=jsonParse.negociacionModificacionContrato;
            }else{
                myContract.Negociacion_modificacion_contractual__c =null;
            }
            if(jsonParse.previsionCostesExtra!=null){//BOOLEAN
                myContract.Prevision_costes_extra__c=jsonParse.previsionCostesExtra;
            }else{
                myContract.Prevision_costes_extra__c=null;
            }
            if(jsonParse.reqsPresencia!=null){
                myContract.Reqs_Contractuales_sobre_Presencialidad__c=jsonParse.reqsPresencia;
            }else{
                myContract.Reqs_Contractuales_sobre_Presencialidad__c=null;
            }
            if(jsonParse.situacionActualContrato!=null){
                myContract.Situacion_Actual_Contrato__c=jsonParse.situacionActualContrato;
            }else{
                myContract.Situacion_Actual_Contrato__c=null;
            }
            
            
            
            
            if(jsonParse.costesReclamarResolucionLocal!=null){
                myContract.Costes_a_reclamar_por_resolucion_local__c=jsonParse.costesReclamarResolucionLocal;
            }else{
                myContract.Costes_a_reclamar_por_resolucion_local__c=null;
            }
            if(jsonParse.estimacionCosteExtraNormalidadLocal!=null){
                myContract.Estimacion_costes_extra_local__c=jsonParse.estimacionCosteExtraNormalidadLocal;
            }else{
                myContract.Estimacion_costes_extra_local__c=null;
            }
            if(jsonParse.costesTotalesResolucionLocal!=null){
                myContract.Costes_totales_resolucion_local__c=jsonParse.costesTotalesResolucionLocal;
            }else{
                myContract.Costes_totales_resolucion_local__c=null;
            }
            if(jsonParse.costesReclamarSuspensionLocal!=null){
                myContract.Costes_a_reclamar_por_suspension_local__c=jsonParse.costesReclamarSuspensionLocal;
            }else{
                myContract.Costes_a_reclamar_por_suspension_local__c=null;
            }
            if(jsonParse.costesTotalesSuspensionLocal!=null){
                myContract.Costes_totales_suspension_local__c=jsonParse.costesTotalesSuspensionLocal;
            }else{
                myContract.Costes_totales_suspension_local__c=null;
            }
            if(jsonParse.estimacionCosteExtraRetrasoLocal!=null){
                myContract.Estimacion_coste_extra_por_retraso_local__c=jsonParse.estimacionCosteExtraRetrasoLocal;
            }else{
                myContract.Estimacion_coste_extra_por_retraso_local__c=null;
            }
            if(!String.isBlank(jsonParse.moneda)){
                myContract.Moneda__c=jsonParse.moneda;
            } else if (jsonParse.moneda == null){
                myContract.Moneda__c=null;
            }
            if(jsonParse.negociacionModificacionFinalizada!=null){
                myContract.Negociacion_modificacion_finalizada__c=jsonParse.negociacionModificacionFinalizada;
            }else{
                myContract.Negociacion_modificacion_finalizada__c=null;
            }
            if(jsonParse.negociacionAceptada!=null){
                myContract.Negociacion_aceptada__c=jsonParse.negociacionAceptada;
            }else{
                myContract.Negociacion_aceptada__c=null;
            }
            if(jsonParse.costesAceptadosRes!=null){
                myContract.Costes_aceptados_resolucion_local__c=jsonParse.costesAceptadosRes;
            }else{
                myContract.Costes_aceptados_resolucion_local__c=null;
            }
            if(jsonParse.costesAceptadosSus!=null){
                myContract.Costes_aceptados_suspension_local__c=jsonParse.costesAceptadosSus;
            }else{
                myContract.Costes_aceptados_suspension_local__c=null;
            }
            
            if(jsonParse.costesReclamarRetraso!=null){
                myContract.Costes_a_reclamar_por_retraso_local__c=jsonParse.costesReclamarRetraso;
            }else{
                myContract.Costes_a_reclamar_por_retraso_local__c=null;
            }
            if(jsonParse.costesAceptadosRetraso!=null){
                myContract.Costes_aceptados_por_retraso_local__c=jsonParse.costesAceptadosRetraso;
            }else{
                myContract.Costes_aceptados_por_retraso_local__c=null;
            }
            if(jsonParse.previsionSituacionContrato!=null){
                myContract.Prevision_situacion_contrato__c=jsonParse.previsionSituacionContrato;
            }else{
                myContract.Prevision_situacion_contrato__c=null;
            }
            
            myContract.Fecha_control_correos__c=datetime.now();
            
            
        }else{
            
        }
        
        try {         
            result = 'OK';  
            update myContract;
            
            System.debug('updated - contrato: ' + myContract);
            
            // result = manageHistoricoDeContrato(objectId, myContract);
            
            
        } catch(System.DmlException ex){
            result = 'KO';
            message = 'DmlException: '+ ex.getMessage(); //Ha ocurrido un error al insertar los Productos de oportunidad';
            System.debug('Error: ' + ex.getMessage());         
            System.debug('Mensaje: ' + ex.getStackTraceString());
            
            System.debug(ex.getCause());
            
        }catch(System.SecurityException es){
            result = 'KO';
            message = 'SecurityException: '+es.getMessage();
            System.debug('Error: ' + es.getMessage());
            system.debug('Error: ' + es.getTypeName());
            system.debug('Error: ' + es.getCause());
            system.debug('Error: ' + es.getLineNumber());
            system.debug('Error: ' + es.getStackTraceString());
            
            
        }catch(Exception e){
            result = 'KO';
            message = 'Exception: '+e.getMessage();
            System.debug('Error: ' + e.getMessage());  
        }
        
        
        return result;
    }
    
    public static string manageHistoricoDeContrato(string objectId, Contrato__c contrato){
        
        string result='OK';
        
        //Historico_estado_contrato__c myHistorico = [select id, name, Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c from Historico_estado_contrato__c where Contrato__r.id =: objectId limit 1];
        system.debug(contrato.LastModifiedDate);
        Date lastUpdateDateContract = contrato.LastModifiedDate.date();
        
        /*Integer mes = lastUpdateDateContract.month() ;
Integer dia=lastUpdateDateContract.day() ;
Integer anho = lastUpdateDateContract.year();*/
        
        Integer mes = Datetime.now().monthGMT() ;
        Integer dia=Datetime.now().dayGMT();
        Integer anho = Datetime.now().yearGMT();
        
        /*  Integer mesn = Date.Today().month() ;
Integer dian=Date.Today().day() ;
Integer anhon = Date.Today().year();*/
        
        /*  
system.debug( 'FECHA DE HOY por DATE:   '+Date.Today()); 
system.debug('DIA por DATE: '+ dia);
system.debug('MES por DATE: '+ mes);
system.debug('AÑO por DATE: '+ anho);

system.debug('FECHA HOY POR DATETIME GMT;  '+Datetime.now()); 

system.debug('DIA POR DATETIME;  '+Datetime.now().dayGMT());
system.debug('MES POR DATETIME;  '+Datetime.now().monthGMT());
system.debug('AÑO POR DATETIME;  '+Datetime.now().yearGMT());

system.debug('FECHA HOY POR DATETIME USUARIO;  '+Datetime.now()); 

system.debug('DIA POR DATETIME USUARIO;  '+Datetime.now().day());
system.debug('MES POR DATETIME USUARIO;  '+Datetime.now().month());
system.debug('AÑO POR DATETIME USUARIO;  '+Datetime.now().year());*/
        
        
        
        system.debug(lastUpdateDateContract);
        
        List<Historico_estado_contrato__c> myHistorico = [select id, name, Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c
                                                          from Historico_estado_contrato__c where Contrato__r.id =: objectId 
                                                          and CALENDAR_MONTH(CreatedDate) =: mes
                                                          and DAY_IN_MONTH(CreatedDate)=: dia
                                                          and CALENDAR_YEAR(CreatedDate)=: anho limit 1];
        
        // system.debug(myHistorico[0]); 
        
        if(myHistorico.size()>0){
            system.debug('HAY ARCHIVOS DE HISTORICO PARA HOY');
            system.debug(myHistorico);
            Historico_estado_contrato__c myCurrentHistorico = myHistorico[0];
            myCurrentHistorico.Fecha_historico__c=string.valueOf(dia)+'/'+string.valueOf(mes)+'/'+string.valueOf(anho);
            myCurrentHistorico.Reqs_Contractuales_sobre_Presencialidad__c= contrato.Reqs_Contractuales_sobre_Presencialidad__c;
            myCurrentHistorico.Situacion_Actual_Contrato__c= contrato.Situacion_Actual_Contrato__c;
            myCurrentHistorico.Causa_resolucion__c= contrato.Causa_resolucion__c;
            myCurrentHistorico.Causa_retraso__c= contrato.Causa_retraso__c;
            myCurrentHistorico.Causa_suspension__c= contrato.Causa_suspension__c;
            myCurrentHistorico.CeBe__c= contrato.CeBe__c;
            myCurrentHistorico.Comentarios__c= contrato.Comentarios__c;
            myCurrentHistorico.Costes_a_reclamar_por_resolucion_local__c= contrato.Costes_a_reclamar_por_resolucion_local__c;
            myCurrentHistorico.Costes_a_reclamar_por_suspension_local__c= contrato.Costes_a_reclamar_por_suspension_local__c;
            myCurrentHistorico.Costes_aceptados_resolucion_local__c= contrato.Costes_aceptados_resolucion_local__c;
            myCurrentHistorico.Costes_aceptados_suspension_local__c= contrato.Costes_aceptados_suspension_local__c;
            myCurrentHistorico.Costes_totales_resolucion_local__c= contrato.Costes_totales_resolucion_local__c;
            myCurrentHistorico.Costes_totales_suspension_local__c= contrato.Costes_totales_suspension_local__c;
            myCurrentHistorico.Derecho_a_reclamacion_por_resolucion__c= contrato.Derecho_a_reclamacion_por_resolucion__c;
            myCurrentHistorico.Derecho_a_reclamacion_por_suspension__c= contrato.Derecho_a_reclamacion_por_suspension__c;
            myCurrentHistorico.Estado__c= contrato.Estado__c;
            myCurrentHistorico.Estimacion_coste_extra_por_retraso_local__c= contrato.Estimacion_coste_extra_por_retraso_local__c;
            myCurrentHistorico.Estimacion_costes_extra_local__c= contrato.Estimacion_costes_extra_local__c;
            myCurrentHistorico.Estimacion_meses_de_retraso__c= contrato.Estimacion_meses_de_retraso__c;
            myCurrentHistorico.Moneda__c= contrato.Moneda__c;
            myCurrentHistorico.Negociacion_aceptada__c= contrato.Negociacion_aceptada__c;
            myCurrentHistorico.Negociacion_modificacion_contractual__c= contrato.Negociacion_modificacion_contractual__c;
            myCurrentHistorico.Negociacion_modificacion_finalizada__c= contrato.Negociacion_modificacion_finalizada__c;
            myCurrentHistorico.Pais__c= contrato.Pais__c;
            myCurrentHistorico.Prevision_costes_extra__c= contrato.Prevision_costes_extra__c;
            myCurrentHistorico.Sub_area__c= contrato.Sub_area__c;
            myCurrentHistorico.Costes_aceptados_por_retraso_local__c= contrato.Costes_aceptados_por_retraso_local__c;
            myCurrentHistorico.Costes_a_reclamar_por_retraso_local__c= contrato.Costes_a_reclamar_por_retraso_local__c;
            myCurrentHistorico.Prevision_situacion_contrato__c=contrato.Prevision_situacion_contrato__c;
            myCurrentHistorico.Creacion_automatica__c=false;
            
            update myCurrentHistorico;
            
            
        }  else{
            Historico_estado_contrato__c myCurrentHistoricoNew = new Historico_estado_contrato__c();
            myCurrentHistoricoNew.Fecha_historico__c=string.valueOf(dia)+'/'+string.valueOf(mes)+'/'+string.valueOf(anho);
            myCurrentHistoricoNew.Reqs_Contractuales_sobre_Presencialidad__c= contrato.Reqs_Contractuales_sobre_Presencialidad__c;
            myCurrentHistoricoNew.Situacion_Actual_Contrato__c= contrato.Situacion_Actual_Contrato__c;
            myCurrentHistoricoNew.Contrato__c=contrato.Id;
            myCurrentHistoricoNew.name= contrato.Codigo_SAP__c+' - '+string.valueof(date.today());
            
            myCurrentHistoricoNew.Causa_resolucion__c= contrato.Causa_resolucion__c;
            myCurrentHistoricoNew.Causa_retraso__c= contrato.Causa_retraso__c;
            myCurrentHistoricoNew.Causa_suspension__c= contrato.Causa_suspension__c;
            myCurrentHistoricoNew.CeBe__c= contrato.CeBe__c;
            myCurrentHistoricoNew.Comentarios__c= contrato.Comentarios__c;
            myCurrentHistoricoNew.Costes_a_reclamar_por_resolucion_local__c= contrato.Costes_a_reclamar_por_resolucion_local__c;
            myCurrentHistoricoNew.Costes_a_reclamar_por_suspension_local__c= contrato.Costes_a_reclamar_por_suspension_local__c;
            myCurrentHistoricoNew.Costes_aceptados_resolucion_local__c= contrato.Costes_aceptados_resolucion_local__c;
            myCurrentHistoricoNew.Costes_aceptados_suspension_local__c= contrato.Costes_aceptados_suspension_local__c;
            myCurrentHistoricoNew.Costes_totales_resolucion_local__c= contrato.Costes_totales_resolucion_local__c;
            myCurrentHistoricoNew.Costes_totales_suspension_local__c= contrato.Costes_totales_suspension_local__c;
            myCurrentHistoricoNew.Derecho_a_reclamacion_por_resolucion__c= contrato.Derecho_a_reclamacion_por_resolucion__c;
            myCurrentHistoricoNew.Derecho_a_reclamacion_por_suspension__c= contrato.Derecho_a_reclamacion_por_suspension__c;
            myCurrentHistoricoNew.Estado__c= contrato.Estado__c;
            myCurrentHistoricoNew.Estimacion_coste_extra_por_retraso_local__c= contrato.Estimacion_coste_extra_por_retraso_local__c;
            myCurrentHistoricoNew.Estimacion_costes_extra_local__c= contrato.Estimacion_costes_extra_local__c;
            myCurrentHistoricoNew.Estimacion_meses_de_retraso__c= contrato.Estimacion_meses_de_retraso__c;
            myCurrentHistoricoNew.Moneda__c= contrato.Moneda__c;
            myCurrentHistoricoNew.Negociacion_aceptada__c= contrato.Negociacion_aceptada__c;
            myCurrentHistoricoNew.Negociacion_modificacion_contractual__c= contrato.Negociacion_modificacion_contractual__c;
            myCurrentHistoricoNew.Negociacion_modificacion_finalizada__c= contrato.Negociacion_modificacion_finalizada__c;
            myCurrentHistoricoNew.Pais__c= contrato.Pais__c;
            myCurrentHistoricoNew.Prevision_costes_extra__c= contrato.Prevision_costes_extra__c;
            myCurrentHistoricoNew.Sub_area__c= contrato.Sub_area__c;
            myCurrentHistoricoNew.OwnerId= contrato.OwnerId;
            myCurrentHistoricoNew.Costes_aceptados_por_retraso_local__c= contrato.Costes_aceptados_por_retraso_local__c;
            myCurrentHistoricoNew.Costes_a_reclamar_por_retraso_local__c= contrato.Costes_a_reclamar_por_retraso_local__c;
            myCurrentHistoricoNew.Prevision_situacion_contrato__c=contrato.Prevision_situacion_contrato__c;
            
            insert myCurrentHistoricoNew;
            
            system.debug('NO HAY ARCHIVOS DE HISTORICO PARA HOY');
            system.debug(myCurrentHistoricoNew);
        }
        
        return result;
    }
    
    public static string checkHistoricoDeContrato_fromTrigger(List<Contrato__c> myNewContratoList, List<Contrato__c> myOldContratoList){
        
        string result= '';
        List<Historico_estado_contrato__c> listToUpdate = new List<Historico_estado_contrato__c>();
        List<Historico_estado_contrato__c> listToInsert = new List<Historico_estado_contrato__c>();
        
        // Obtengo fecha actual para ver si hay Historicos en el sistema para el día de hoy
        Integer mes = Datetime.now().monthGMT() ;
        Integer dia=Datetime.now().dayGMT();
        Integer anho = Datetime.now().yearGMT();
        
        
        // 1. De la lista que me llega por el Trigger hay que separar los que ya tienen historico HOY y los que no
        Map<Id, Historico_estado_contrato__c> mapHistoricos = new Map<Id, Historico_estado_contrato__c>();
        Map<Id, Contrato__c> mapTriggerContratosNew = new Map<Id, Contrato__c>(myNewContratoList);
        Map<Id, Contrato__c> mapTriggerContratosOld = new Map<Id, Contrato__c>(myOldContratoList);
        system.debug(mapTriggerContratosNew);
        
        Set <Id> listIdContratos = new Set<Id>();
        listIdContratos = mapTriggerContratosNew.keySet();//lista de identificadores de todos los contratos
        
        system.debug(listIdContratos);
        List<Historico_estado_contrato__c> myHistoricoList = [select id, name, Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c, Fecha_historico__c, Causa_resolucion__c, Causa_retraso__c,CeBe__c,
                                                              Causa_suspension__c,Comentarios__c,Costes_a_reclamar_por_resolucion_local__c,Costes_a_reclamar_por_suspension_local__c,Costes_aceptados_resolucion_local__c,
                                                              Costes_aceptados_suspension_local__c,Costes_totales_resolucion_local__c,Costes_totales_suspension_local__c, Derecho_a_reclamacion_por_resolucion__c,Derecho_a_reclamacion_por_suspension__c,
                                                              Estado__c,Estimacion_coste_extra_por_retraso_local__c,Estimacion_costes_extra_local__c,Estimacion_meses_de_retraso__c,Moneda__c,Negociacion_aceptada__c,
                                                              Negociacion_modificacion_contractual__c, Negociacion_modificacion_finalizada__c,Pais__c,Prevision_costes_extra__c,Sub_area__c, OwnerId, Costes_aceptados_por_retraso_local__c,Costes_a_reclamar_por_retraso_local__c,
                                                              Prevision_situacion_contrato__c, Contrato__c
                                                              from Historico_estado_contrato__c where Contrato__c IN : listIdContratos 
                                                              and CALENDAR_MONTH(CreatedDate) =: mes
                                                              and DAY_IN_MONTH(CreatedDate)=: dia
                                                              and CALENDAR_YEAR(CreatedDate)=: anho limit 1];
        
        system.debug(myHistoricoList);
        //Creo mapa de los Historicos con la key del id de contrato
        for(Historico_estado_contrato__c myHist : myHistoricoList){
            mapHistoricos.put(myHist.Contrato__c,myHist);
        }
        
        //Si existe historico asociado al contrato se actualiza, si no hay, se crea.
        for(id keyContrato : mapTriggerContratosNew.keySet()){
            
            Historico_estado_contrato__c myCurrentHistorico =new Historico_estado_contrato__c();
            
            if(mapHistoricos.get(keyContrato)!=null){ //Ya hay historico HOY para este contrato. Se actualiza.
                myCurrentHistorico =mapHistoricos.get(keyContrato);
                //Solo actualizao los campos del formulario del pagelayout susceptibles de sufrir algún cambio
                //Se comprueban si han cambiado solo los dos campos accesibles por pagelayout. Así se evita que se actualice dos veces el registro al actualizar el cuestionario.
                string commentOld=(mapTriggerContratosOld.get(keyContrato)).Comentarios__c;
                string commentNew=(mapTriggerContratosNew.get(keyContrato)).Comentarios__c;
                
                String statusNew=(mapTriggerContratosNew.get(keyContrato)).Estado__c;
                String statusOld=(mapTriggerContratosOld.get(keyContrato)).Estado__c;
                    
                if(commentOld!=commentNew || statusNew!=statusOld){
                    myCurrentHistorico.Comentarios__c= (mapTriggerContratosNew.get(keyContrato)).Comentarios__c;
                    myCurrentHistorico.Estado__c=(mapTriggerContratosNew.get(keyContrato)).Estado__c;
                    listToUpdate.add(myCurrentHistorico);
                }
      
                
            }else{// NO hay historico HOY para este contrato. Se crea.
                Contrato__c myCurrentContract = mapTriggerContratosNew.get(keyContrato);
                myCurrentHistorico.Fecha_historico__c=string.valueOf(dia)+'/'+string.valueOf(mes)+'/'+string.valueOf(anho);
                myCurrentHistorico.Reqs_Contractuales_sobre_Presencialidad__c= myCurrentContract.Reqs_Contractuales_sobre_Presencialidad__c;
                myCurrentHistorico.Situacion_Actual_Contrato__c= myCurrentContract.Situacion_Actual_Contrato__c;
                myCurrentHistorico.Contrato__c=myCurrentContract.Id;
                myCurrentHistorico.name= myCurrentContract.Codigo_SAP__c+' - '+string.valueof(date.today());
                
                myCurrentHistorico.Causa_resolucion__c= myCurrentContract.Causa_resolucion__c;
                myCurrentHistorico.Causa_retraso__c= myCurrentContract.Causa_retraso__c;
                myCurrentHistorico.Causa_suspension__c= myCurrentContract.Causa_suspension__c;
                myCurrentHistorico.CeBe__c= myCurrentContract.CeBe__c;
                myCurrentHistorico.Comentarios__c= myCurrentContract.Comentarios__c;
                myCurrentHistorico.Costes_a_reclamar_por_resolucion_local__c= myCurrentContract.Costes_a_reclamar_por_resolucion_local__c;
                myCurrentHistorico.Costes_a_reclamar_por_suspension_local__c= myCurrentContract.Costes_a_reclamar_por_suspension_local__c;
                myCurrentHistorico.Costes_aceptados_resolucion_local__c= myCurrentContract.Costes_aceptados_resolucion_local__c;
                myCurrentHistorico.Costes_aceptados_suspension_local__c= myCurrentContract.Costes_aceptados_suspension_local__c;
                myCurrentHistorico.Costes_totales_resolucion_local__c= myCurrentContract.Costes_totales_resolucion_local__c;
                myCurrentHistorico.Costes_totales_suspension_local__c= myCurrentContract.Costes_totales_suspension_local__c;
                myCurrentHistorico.Derecho_a_reclamacion_por_resolucion__c= myCurrentContract.Derecho_a_reclamacion_por_resolucion__c;
                myCurrentHistorico.Derecho_a_reclamacion_por_suspension__c= myCurrentContract.Derecho_a_reclamacion_por_suspension__c;
                myCurrentHistorico.Estado__c= myCurrentContract.Estado__c;
                myCurrentHistorico.Estimacion_coste_extra_por_retraso_local__c= myCurrentContract.Estimacion_coste_extra_por_retraso_local__c;
                myCurrentHistorico.Estimacion_costes_extra_local__c= myCurrentContract.Estimacion_costes_extra_local__c;
                myCurrentHistorico.Estimacion_meses_de_retraso__c= myCurrentContract.Estimacion_meses_de_retraso__c;
                myCurrentHistorico.Moneda__c= myCurrentContract.Moneda__c;
                myCurrentHistorico.Negociacion_aceptada__c= myCurrentContract.Negociacion_aceptada__c;
                myCurrentHistorico.Negociacion_modificacion_contractual__c= myCurrentContract.Negociacion_modificacion_contractual__c;
                myCurrentHistorico.Negociacion_modificacion_finalizada__c= myCurrentContract.Negociacion_modificacion_finalizada__c;
                myCurrentHistorico.Pais__c= myCurrentContract.Pais__c;
                myCurrentHistorico.Prevision_costes_extra__c= myCurrentContract.Prevision_costes_extra__c;
                myCurrentHistorico.Sub_area__c= myCurrentContract.Sub_area__c;
                myCurrentHistorico.OwnerId= myCurrentContract.OwnerId;
                myCurrentHistorico.Costes_aceptados_por_retraso_local__c= myCurrentContract.Costes_aceptados_por_retraso_local__c;
                myCurrentHistorico.Costes_a_reclamar_por_retraso_local__c= myCurrentContract.Costes_a_reclamar_por_retraso_local__c;
                myCurrentHistorico.Prevision_situacion_contrato__c=myCurrentContract.Prevision_situacion_contrato__c;
                
                listToInsert.add(myCurrentHistorico);
            }
        }
        try{
            update listToUpdate;
            insert listToInsert;
            result='OK';
            
        } catch(System.DmlException ex){
            
            result='KO';            
            System.debug('Error: ' + ex.getMessage());         
            System.debug('Mensaje: ' + ex.getStackTraceString());
            System.debug(ex.getCause());
            
        }catch(System.SecurityException es){
            
            result='KO';    
            System.debug('Error: ' + es.getMessage());
            system.debug('Error: ' + es.getTypeName());
            system.debug('Error: ' + es.getCause());
            
        }catch(Exception e){
            result='KO';
            System.debug('Error: ' + e.getMessage());  
        }
        
        
        return result;
    }
    
    
    //Convertir el JSON de los asientos seleccionados
    public static Contrato parseContrato (String selectedContractJSON) {
        return (Contrato) System.JSON.deserialize(selectedContractJSON, Contrato.class);
    }
    
    //Asientos seleccionados para añadir al Producto de Oportunidad
    public class Contrato {
        
        public boolean asistenciaJuridica; //Cadena de caracteres con separaciones de punto y coma ;
        public string causaResolucion;
        public boolean docIncidencias;
        public string codAji;
        public string causaRetraso;
        public string causaSuspension;
        public decimal costesReclamarResolucion;
        public decimal costesReclamarSuspension;
        public decimal costesTotalesResolucion;
        public decimal costesTotalesSuspension;
        public decimal costesAceptadosSus;
        public decimal costesAceptadosRes;
        public boolean derechoReclamacionSuspension;
        public boolean derechoReclamacionResolucion;
        public decimal estimacionCosteExtraRetraso;
        public decimal estimacionCosteExtraNormalidad;
        public decimal estimacionMesesRetraso;
        public boolean negociacionModificacionContrato;
        public boolean negociacionModificacionFinalizada;
        public boolean negociacionAceptada;
        public boolean previsionCostesExtra;
        public string reqsPresencia;
        public string situacionActualContrato;
        public string previsionSituacionContrato;
        public string moneda;
        public decimal costesReclamarResolucionLocal;
        public decimal costesReclamarSuspensionLocal;
        public decimal costesTotalesResolucionLocal;
        public decimal costesTotalesSuspensionLocal;
        public decimal estimacionCosteExtraRetrasoLocal;
        public decimal estimacionCosteExtraNormalidadLocal;
        public decimal costesReclamarRetraso;
        public decimal costesAceptadosRetraso;
        public boolean contratoDesactualizado;
        //public string estado;
        
        
        
    }
    
    
    
}
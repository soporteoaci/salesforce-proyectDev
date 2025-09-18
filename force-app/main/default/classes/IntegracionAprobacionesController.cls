public class IntegracionAprobacionesController {
    //CLASE CREADA PARA MANEJAR APROBACIONES DESDE SALESFORCE AL PORTAFIRMAS DE APP2YOU
    
    //PRELIMINAR:
    public static String peticionCreacionAprobacionPreliminar(Id idTareaAprobacion){
        
        Tarea_aprobacion__c tarea = [SELECT id,Opportunity__c FROM Tarea_aprobacion__c WHERE Id =: idTareaAprobacion];
        Map<String,Object> params = new Map<String,Object>();
        params.put(CRM_IntegrationConstants.LISTA_PARAM.get(1),tarea.Owner.email);
        params.put(CRM_IntegrationConstants.LISTA_PARAM.get(2),tarea.Tipo__c +' '+tarea.Codigo_Oportunidad_Comercial__c);
        params.put(CRM_IntegrationConstants.LISTA_PARAM.get(3),tarea.Opportunity__r.Sociedad_Ayesa__c);
        params.put(CRM_IntegrationConstants.LISTA_PARAM.get(4),tarea.Pais_oportunidad__c);
        
        
        Map<String, Object> response = RICM.CallOutService.executeRequest(CRM_IntegrationConstants.INTEGRATION_APR_PRELIMINAR_NAME, params, null);
        return null;
    }
    
}
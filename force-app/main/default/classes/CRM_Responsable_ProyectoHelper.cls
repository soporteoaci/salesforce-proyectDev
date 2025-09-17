public class CRM_Responsable_ProyectoHelper {
    
    public static String buildBusquedaEmplRequestBody(String buscarTexto){
        
        WebService__c webServiceData = WebService__c.getInstance();
        String user = webServiceData.username__c;        
        String pass = webServiceData.password__c;
        
       // return String.format(CRM_IntegrationConstants.INTEGRATION_RESPONSABLE_BODY_TEMPLATE, new List<String>{user, pass, buscarTexto});
        return CRM_IntegrationConstants.INTEGRATION_RESPONSABLE_BODY_TEMPLATE;
        
    }

}
public with sharing class CRM_Responsable_ProyectoController {
    
    // obtener valores de la oportunidad
    @AuraEnabled
    public static Opportunity obtenerOportunidad(String oppId) {
        try {
            return [SELECT Id, Responsable_de_Proyecto__c, Responsable_de_Proyecto_Nombre__c, Responsable_de_Proyecto_Email__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener los datos de la oportunidad: ' + e.getMessage());
        }
    }
    
    // buscar empleados en el servicio externo
    @AuraEnabled
    public static String BusquedaEmpl(String buscarTexto) {
        //   JSONGenerator gen = JSON.createGenerator(true);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        WebService__c webServiceData = WebService__c.getInstance();
        String user = webServiceData.username__c;        
        String pass = webServiceData.password__c;
        String endpoint = webServiceData.EndPoint_Search_Empleados__c;
        
        String envio='username='+user+'&password='+pass+'&data=' ;   
        String data='{"activo":"true",'+buscarTexto+'}';
        
        request.setBody(envio+data);   
        request.setMethod('POST');
        System.debug('body 01 --> ' + envio+data);
        
        if (endpoint != null) {
            request.setEndpoint(endpoint);  
            HttpResponse response = http.send(request);
            System.debug('response'); 
            System.debug(response.getBody()); 
            return response.getBody(); 
        }
        
        return '[]';
    }
    
    // actualizar la opp con el empleado
    @AuraEnabled
    public static void actualizarOportunidad(String oppId, String responsable) {
        
        System.debug('oppId --> ' + oppId);
        System.debug('responsable --> ' + responsable);
        
        if (String.isEmpty(oppId)) {
            throw new AuraHandledException('Id de la oportunidad está vacío');
        }
        
        try {
            Opportunity opp = [SELECT Id, Responsable_de_Proyecto__c, Responsable_de_Proyecto_Nombre__c, Responsable_de_Proyecto_Email__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
            
            // separamos responsble en nombre y email
            String[] partesResponsable = responsable.split(' - ');
            
            if (partesResponsable.size() == 2) {
                String nombreEmpleado = partesResponsable[0];
                String emailEmpleado = partesResponsable[1];
                
                opp.Responsable_de_Proyecto_Nombre__c = nombreEmpleado;
                opp.Responsable_de_Proyecto_Email__c = emailEmpleado;
            } else {
                throw new AuraHandledException('Error en los datos del empleado');
            }
            
            opp.Responsable_de_Proyecto__c = responsable;
            update opp;
            System.debug('Oportunidad actualizada correctamente');
            
        } catch (Exception e) {
            System.debug('Error método actualizarOportunidad--> ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    //Realiza la misma validación que CamposObligatoriosOpp en Opportunity
    @AuraEnabled
    public static Boolean esCampoResponsableRequerido() {
        User u = [SELECT Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        Boolean esExcepcion = 
            u.Profile.Name.containsIgnoreCase('dmin') ||
            u.Email == 'rpozas@ayesa.com' ||
            u.Email == 'aat_soporteofertas@ayesa.com';
        
        return !esExcepcion;
        
    }
    
}
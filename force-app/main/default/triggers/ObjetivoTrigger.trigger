/*26/12/2024
* Quitamos:
* Borrado ojetivo
* hayCambiosObjetivo
*/
trigger ObjetivoTrigger on Objetivo__c (after insert, after update,after delete) {
    
    System.debug('Trigger Objetivos');
    
    //Get User email from logged user
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    if(emailAddress != usuario_no_trigger.Correo_usuario__c){
        System.debug('Ejecutamos trigger CRM Account');
        
        
        String integrationUser = '';
        
        //Get Current Logged User
        String loggedUser = Userinfo.getUserName();
        System.debug('Usuario logado: ' + loggedUser);
        
        CRM_Configuracion__c[] crm_configuration = [SELECT Usuario_Integracion__c FROM CRM_Configuracion__c LIMIT 1];
        
        if (crm_configuration.size() > 0) {
            integrationUser = crm_configuration[0].Usuario_Integracion__c;
        }
        System.debug('Usuario integración: ' + integrationUser);
 

        if(loggedUser != integrationUser) {
            System.debug('Ejecutando trigger Objetivo...');

        } else {
            System.debug('Usuario integración configurado. No ejecuta trigger.');
        }
        
    }else {
        System.debug('No ejecutamos trigger CRM Account');
        
    }
    
    
    
}
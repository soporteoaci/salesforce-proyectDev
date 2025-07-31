/*26/12/2024
* QUitamos:
* Referencias al antiguo BPM que ya estaban comentadas
* avisosOCP
*Trigger.isdeleted
* Trigger.isAfter
*       isUpdate envio a super si direccion operaciones IT&DS o Innovación
*BorradoOportunidad 
*hayCambiosOportunidad
*Cambio en el desglose de importes (obsoleto)

*/
trigger Mercado_AreaDivision on Oportunidad__c (before insert) {
    //before insert, before update, after update, after delete
    private static Boolean triggerExecuted = false;
    System.debug('triggerExecuted: ' + triggerExecuted);
    
    String integrationUser = '';    
    //Get Current Logged User
    String loggedUser = Userinfo.getUserName();
    System.debug('Usuario logado: ' + loggedUser);
    
    //Get User email from logged user
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    if(emailAddress != usuario_no_trigger.Correo_usuario__c){
        //Si el usuario coincide con el indicado en la custom setting no se tiene que ejecuta el trigger
        System.debug('Ejecutamos trigger oportunidad');
        CRM_Configuracion__c[] crm_configuration = [SELECT Usuario_Integracion__c FROM CRM_Configuracion__c LIMIT 1];
        
        if (crm_configuration.size() > 0) {
            integrationUser = crm_configuration[0].Usuario_Integracion__c;
        }
        System.debug('Usuario integración: ' + integrationUser);
        Id recordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id recordTypeSME = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        

        if(loggedUser != integrationUser) {
            System.debug('Ejecutando trigger...');
            
        } else {
            System.debug('Usuario integración configurado. No ejecuta trigger.');
        }
        
    }else{
        System.debug('No ejecutamos trigger oportunidad');
    } 
    
}
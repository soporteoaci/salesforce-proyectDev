global class CRM_Notific_Op_Incoherentes implements Database.Batchable<sObject>{
    global String errMsg = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Ejecución de consulta de oportunidades incoherentes...');
        
        string query='SELECT Id, Name, OwnerId, Owner.name, Owner.email FROM Oportunidad__c WHERE Existencia_de_Incoherencias__c = true and (Etapa__c != \'Cerrada\' or estado_de_cierre__c = \'Contratada\') order by OwnerId' + (Test.isRunningTest()?' LIMIT 10':'');                

        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Oportunidad__c> ownerByOppIncoherente){
        system.debug('Tamaño de lista de oportunidades con INCOHERENCIAS:  ' + ownerByOppIncoherente.size());
               
       	//Se crea lista de emails
  		List<Messaging.SingleEmailMessage> theEmails = new List<Messaging.SingleEmailMessage>(); 
        
        //Guardo los Id's de los usuarios (idioma 1.1)
        Set <Id> lista_Ids_RPS = new Set<Id>();
        for (Oportunidad__c opp : ownerByOppIncoherente){
            lista_Ids_RPS.add(opp.OwnerId);
        }
        //system.debug('Total de usuarios:  '+ lista_Ids_RPS.size());
        
        //Hago lista de usuarios con esos IDS (idioma 1.2)        
        List<User> lista_Usuarios = [SELECT id, email, LanguageLocaleKey FROM User where id IN :lista_Ids_RPS ];        
        system.debug('Tamaño de lista de Usuarios con INCOHERENCIAS: ' + lista_Usuarios.size());
        
        //Recuperamos plantilla a utilizar para el envío del correo
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CRMEmailOportunidadesIncoherentes'];
                                      
        //enviamos correo a cada usuario con oportunidades incoherentes
        Integer cont = 0;
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for (User user : lista_Usuarios){
            system.debug('Contador='+cont);
            
            allmsg.add(composeEmail(user, et));
            cont++;
            
            if (cont == 100 || cont >= lista_Usuarios.size()) {
                system.debug('Ejecutando envio...');
                
                try {
                    Messaging.sendEmail(allmsg, false);
                    system.debug('Lista de Emails enviada correctamente.');
                } catch (Exception e) {
                    system.debug('Error enviando lista de emails.');
                    System.debug(e.getMessage());
                    errMsg += 'Batch [CRM_Notific_Op_Incoherentes] Error al enviar lista de emails. ErrMsg = ' + e.getMessage() + '<br />';
                }
                
                allmsg = new List<Messaging.SingleEmailMessage>();                
            }
        }
        system.debug('Fin ejecución proceso de notificación de incoherencias.');
    }
    
    global void finish(Database.BatchableContext BC){
        if (errMsg == '') {
            System.debug('Batch [CRM_Notific_Op_Incoherentes] ha finalizado : Todas las incoherencias han sido notificadas correctamente.');
        }
        else {
            System.debug('Batch [CRM_Notific_Op_Incoherentes] ha finalizado : Existen errores. Lista de errores. <br />' + errMsg);
        }
    }      
    
    private Messaging.SingleEmailMessage composeEmail(User usuario, EmailTemplate plantilla) {        
               
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(plantilla.Id);
        mail.setTargetObjectId(usuario.Id);
        mail.setWhatId(usuario.Id);        
        mail.setToAddresses( new String[] { usuario.Email } );        
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('CRM Ayesa Support');
        
        return mail;        
    }
}
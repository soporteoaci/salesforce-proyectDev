global class CRM_Recordatorio_Actualizacion_Contrato implements Database.Batchable<sObject>{
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Parametros_gestion_contratos__c param = Parametros_gestion_contratos__c.getOrgDefaults(); //Número de días que se lleva sin actualizar el contrato
        Integer mydays = (integer)param.Dias_sin_actualizar__c;
        string days = string.valueof(mydays);
       // days = '20';
        system.debug('dias: ' + days);
        string estado = 'RECEP'; //Estado que hay que ignorar en los contartos
       // string userName= 'Usuario Pruebas RP';
        
        string query='SELECT id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,LastModifiedDate,Codigo_AJI__c,Asistencia_juridica__c,Fecha_control_correos__c,Causa_resolucion__c,Causa_suspension__c,Comentarios__c,';
        query= query + 'Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,OwnerId, Owner.Email,Owner.Name, Prevision_situacion_contrato__c ';
        query = query + 'FROM Contrato__c WHERE Estado__c != \'' +estado+ '\' and Fecha_control_correos__c != LAST_N_DAYS:'+days ;
        //query = query + 'FROM Contrato__c WHERE Estado__c != \'' +estado+ '\' and LastModifiedDate != LAST_N_DAYS:'+days ;
       // query = query + 'FROM Contrato__c WHERE Estado__c != \'' +estado+ '\' and Owner.name =\''+userName+'\' and LastModifiedDate != LAST_N_DAYS:'+days+' order by lastmodifieddate asc' ;
       
        
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contrato__c> contratos){
        system.debug('Tamaño de lista de contratos RECORDATORIO:  ' + contratos.size());
               
       //Se crea lista de emails
  		List<Messaging.SingleEmailMessage> theEmails = new List<Messaging.SingleEmailMessage>(); 
        
        //Guardo los Id's de los usuarios (idioma 1.1)
        Set <Id> lista_Ids_RPS = new Set<Id>();
        for (Contrato__c con : contratos){
            lista_Ids_RPS.add(con.OwnerId);
        }
        
        //Hago lista de usuarios con esos IDS (idioma 1.2)
        
        List<User> lista_Usuarios = [SELECT id,LanguageLocaleKey FROM User where id IN :lista_Ids_RPS ];
        
        system.debug('Tamaño de lista de RPS:  '+ lista_Ids_RPS.size());
        system.debug('Tamaño de lista de Usuarios consultados:  '+ lista_Usuarios.size());
        
        //Mapa identificador contrato --> Idioma del email(idioma 1.3)
        Map<Id, User> mapa_Usuarios = new Map<Id, User>(lista_Usuarios);
         Map<Id, String> mapa_Contrato_Idioma = new Map<Id, String>();
        
        for (Contrato__c con : contratos){
            mapa_Contrato_Idioma.put(con.Id, mapa_Usuarios.get(con.OwnerId).LanguageLocaleKey); //Ya tengo emparejado cada identificador de contrato con el idioma del email
        }
        
       
        
        //Se crea el cuerpo del email por cada contrato
        for(Contrato__c con : contratos) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string idioma=mapa_Contrato_Idioma.get(con.Id);
            system.debug('Idioma del email: '+idioma);
            string body;
            string subject;
            switch on idioma {
                when 'es' {
                   
            subject = Label.GC_Email_Recordatorio_Asunto;
 
            body = Label.GC_Email_Recordatorio00 + ' ' +  con.Owner.Name + ',\n\n';
            
            body +=  Label.GC_Email_Recordatorio01 + con.Name + Label.GC_Email_Recordatorio02 + '\n\n';
            
            body += Label.GC_Email_Recordatorio03 + '\n\n';
                }
                when 'en_US' {
                   
            subject = Label.GC_Email_Recordatorio_Asunto_Eng;
       
            body = Label.GC_Email_Recordatorio00_Eng + ' ' +  con.Owner.Name + ',\n\n';
            
            body +=  Label.GC_Email_Recordatorio01_Eng + con.Name + Label.GC_Email_Recordatorio02_Eng + '\n\n';
            
            body += Label.GC_Email_Recordatorio03_Eng + '\n\n';
                }
            }

  
            body += system.URL.getOrgDomainUrl().toExternalForm() +'/'+con.Id ;
            //system.debug(con.Owner.LanguageLocaleKey);
            email.setToAddresses(new String[] {con.Owner.Email});
            email.setSaveAsActivity(false);
            email.setTreatTargetObjectAsRecipient(false);
            email.setSubject( subject );
            // email.setTargetObjectId(con.Owner.id);
            // email.setTemplateId(emailTemplate.Id);
            email.setPlainTextBody( body );
            // email.setWhatId(con.Id);
            theEmails.add(email);
        }
		
        //Para evitar el limite de 10 envios de SingleEmail, se recorre la lista y se añaden todos sus elementos a una lista de EMAILS
        List<Messaging.Email> allMails = new List<Messaging.Email>();
        for( Integer j = 0; j < theEmails.size(); j++ ){
            allMails.add(theEmails.get(j));
        }
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        //Se mandan todos los emails
        if(!Test.isRunningTest()){
			results = Messaging.sendEmail( allMails );
        }

        //Se recogen los errores si los hubiera
       List<Messaging.SendEmailError> errors = new List<Messaging.SendEmailError>();
        system.debug('results is :: '+results);
        String emailErrorReport;
        
        for( Messaging.SendEmailResult currentResult : results ) {
            errors = currentResult.getErrors();
            if( null != errors ) {
                for( Messaging.SendEmailError currentError : errors ) {
                    emailErrorReport = emailErrorReport + '(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + 'r' ;
                    system.debug(emailErrorReport);
                }
            }
        }
      

                            
                        }
    
    global void finish(Database.BatchableContext BC){
        
    }
}
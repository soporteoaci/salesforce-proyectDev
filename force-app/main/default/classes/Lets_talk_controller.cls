public class Lets_talk_controller {
    
    //Para Lets talk Contrato
    @AuraEnabled
    public static Lets_talk__c do_init (String lets_talk_Id){
        
        Lets_talk__c email = [SELECT id,name,Contrato__r.Name,Contrato__r.Codigo_SAP__c,Destinatarios__c,Asunto__c,Cuerpo_Mensaje__c,Respuesta_Asunto__c,Respuesta_Cuerpo_mensaje__c,Fecha_respuesta_Correo__c,CC__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ email.id);
        
        return email;
        
    }
    
    @AuraEnabled
    public static String enviar_email (String lets_talk_Id){
        
        Lets_talk__c correo = [SELECT id,name,Contrato__r.Id,Contrato__r.Name,Contrato__r.Codigo_SAP__c,Destinatarios__c,Asunto__c,Cuerpo_Mensaje__c,ultimo_mensaje_enviado__c,CC__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ correo.id);
        system.debug('Contrato relacionado con lets talk '+ correo.Contrato__r.Name);
        
        
        String LetsTalk_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico Lets Talk Send Email' and sobjecttype ='Historico_estado_contrato__c'].Id;
        Historico_estado_contrato__c myNewHistoricos = new Historico_estado_contrato__c();
        
        
        System.debug('Destinatario:'+ correo.Destinatarios__c);
        System.debug('Creo histórico');
        Historico_estado_contrato__c myNewHistorico= new Historico_estado_contrato__c ();
        myNewHistorico.RecordTypeId=LetsTalk_RecordTypeID;
        myNewHistorico.Name = 'OACI envía correo - ' + Datetime.now() ;
        myNewHistorico.Lets_talk__c =correo.Id;
        myNewHistorico.Lets_Talk_Asunto__c=correo.Contrato__r.Codigo_SAP__c + '. ' + correo.Asunto__c;
        myNewHistorico.Lets_Talk_Destinatarios__c = correo.Destinatarios__c;
        myNewHistorico.Lets_talk_CC__c = correo.CC__c;
        myNewHistorico.lets_talk_cuerpo_mensaje__c= correo.Cuerpo_mensaje__c;
        myNewHistorico.lets_talk_fecha_envio_correo__c = Datetime.now();
        
        string fin = 'FIN';
        insert myNewHistorico;
        
        system.debug('Envio correo');
        
        
        //System.debug('Sender ORG Wide: '+ sender.address );
        
        //Paso 1. Creamos email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        //Paso 2. Personas a las que enviamos el email
        List<String> listaDestinatarios = correo.Destinatarios__c.split(';');
        
        message.setToAddresses( listaDestinatarios );
        if(correo.CC__c !=null){
           List<String> listaCC = correo.CC__c.split(';');
           message.setCcAddresses( listaCC); 
        }
        
        
        //Paso 3. Asignamos quien envía el email
        OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where Address =: 'oaci@ayesa.com' limit 1];
        message.setOrgWideEmailAddressId(sender.Id);
        message.setReplyTo('oaci@ayesa.com');
       // message.setSenderDisplayName('Oficina de Auditoría y Control Interno <oaci@ayesa.com>');
        
        //Paso 4. Contenido del email, asunto y mensaje
        message.setSubject(correo.Contrato__r.Codigo_SAP__c + '. '+ correo.Asunto__c);
        String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
	    body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
        body = body + correo.Cuerpo_Mensaje__c ;
        body = body + '<br></br> <strong> Oficina de Auditoria y Control Interno </strong> <br></br> ';
        body = body + '<p class="small_font_size">Marie Curie, 2 - Edificio Ayesa<br> ';
        body = body + 'PCT Cartuja <br> ';
        body = body + '41092 Sevilla, España</p>';
        body = body + '</body></html>';
        
        message.setHtmlBody(body);
      
        // Paso 5. Enviamos el email al destinatario
    
          
        try {
            if(!Test.isRunningTest()){
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            
                System.debug('Enviadooo');
            }
        } catch (Exception ex) {
            System.debug('Error no esperado al realizar el envío de correo: ' + ex);
            
        }
        
        //Limpiamos los campos de lets Talk por si hay que enviar otro correo2
        correo.ultimo_mensaje_enviado__c= 'Fecha envío: ' + Datetime.now() +'<br></br>'+ correo.Cuerpo_Mensaje__c;
        correo.Destinatarios__c='';
        correo.Asunto__c='';
        correo.Cuerpo_Mensaje__c='';
        correo.CC__c='';
        update correo;
        
        
        return fin;
        
    }
    
    @AuraEnabled
    public static String guardar_email (String lets_talk_Id){
        
        Lets_talk__c correo = [SELECT id,name,Contrato__r.Name,Respuesta_Asunto__c,Respuesta_Cuerpo_mensaje__c,Fecha_respuesta_Correo__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ correo.id);
        
        String LetsTalk_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico Lets Talk Save Email' and sobjecttype ='Historico_estado_contrato__c'].Id;
        
        
        Historico_estado_contrato__c myNewHistorico= new Historico_estado_contrato__c ();
        myNewHistorico.RecordTypeId=LetsTalk_RecordTypeID;
        myNewHistorico.Name = 'Respuesta usuario - ' + correo.Fecha_respuesta_Correo__c ;
        myNewHistorico.Lets_talk__c =correo.Id;
        myNewHistorico.Lets_Talk_Respuesta_Asunto__c = correo.Respuesta_Asunto__c;
        myNewHistorico.lets_talk_Respuesta_mensaje__c = correo.Respuesta_Cuerpo_mensaje__c;
        myNewHistorico.lets_talk_fecha_respuesta_correo__c = correo.Fecha_respuesta_Correo__c;
        insert myNewHistorico;
        
        
        
        
        //Limpiamos los campos de lets Talk por si hay que enviar otro correo
        
        correo.Respuesta_Asunto__c='';
        correo.Respuesta_Cuerpo_mensaje__c='';
        correo.Fecha_respuesta_Correo__c=null;
        update correo;
        string fin = 'FIN';
        return fin;
        
    }
    //FIN CONTRATO
    
    
    
    
    //Para Lets talk Proyecto
    @AuraEnabled
    public static Lets_talk__c do_init_proyecto (String lets_talk_Id){
        
        Lets_talk__c email = [SELECT id,name,Proyecto__r.Name,Proyecto__r.Codigo__c,Destinatarios__c,Asunto__c,Cuerpo_Mensaje__c,Respuesta_Asunto__c,Respuesta_Cuerpo_mensaje__c,Fecha_respuesta_Correo__c,CC__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ email.id);
       
        return email;
        
    }


    
    @AuraEnabled
    public static String enviar_email_proyecto (String lets_talk_Id){
        
        Lets_talk__c correo = [SELECT id,name,Proyecto__r.Id,Proyecto__r.Name,Proyecto__r.Codigo__c,Destinatarios__c,Asunto__c,Cuerpo_Mensaje__c,ultimo_mensaje_enviado__c,CC__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ correo.id);
        system.debug('Contrato relacionado con lets talk '+ correo.Proyecto__r.Name);
        
        
        String LetsTalk_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico Lets Talk Send Email' and sobjecttype ='Historico_estado_proyecto__c'].Id;
        Historico_estado_proyecto__c myNewHistoricos = new Historico_estado_proyecto__c();
        
        
        System.debug('Destinatario:'+ correo.Destinatarios__c);
        System.debug('Creo histórico');
        Historico_estado_proyecto__c myNewHistorico= new Historico_estado_proyecto__c ();
        myNewHistorico.RecordTypeId=LetsTalk_RecordTypeID;
        myNewHistorico.Name = 'OACI envía correo - ' + Datetime.now() ;
        myNewHistorico.Lets_talk__c =correo.Id;
        myNewHistorico.Lets_Talk_Asunto__c=correo.Proyecto__r.Codigo__c + '. '+ correo.Asunto__c;
        myNewHistorico.Lets_Talk_Destinatarios__c = correo.Destinatarios__c;
        myNewHistorico.Lets_talk_CC__c = correo.CC__c;
        myNewHistorico.lets_talk_cuerpo_mensaje__c= correo.Cuerpo_mensaje__c;
        myNewHistorico.lets_talk_fecha_envio_correo__c = Datetime.now();
        
        string fin = 'FIN';
        insert myNewHistorico;
        
        system.debug('Envio correo');
        
        
        //System.debug('Sender ORG Wide: '+ sender.address );
        
        //Paso 1. Creamos email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        //Paso 2. Personas a las que enviamos el email
        List<String> listaDestinatarios = correo.Destinatarios__c.split(';');
        
        message.setToAddresses( listaDestinatarios );
        if(correo.CC__c !=null){
           List<String> listaCC = correo.CC__c.split(';');
           message.setCcAddresses( listaCC); 
        }
        
        
        //Paso 3. Asignamos quien envía el email
        OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where Address =: 'oaci@ayesa.com' limit 1];
        message.setOrgWideEmailAddressId(sender.Id);
        message.setReplyTo('oaci@ayesa.com');
       // message.setSenderDisplayName('Oficina de Auditoría y Control Interno <oaci@ayesa.com>');
        
        //Paso 4. Contenido del email, asunto y mensaje
        message.setSubject(correo.Proyecto__r.Codigo__c + '. '+ correo.Asunto__c);
        String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
	    body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
        body = body + correo.Cuerpo_Mensaje__c ;
        body = body + '<br></br> <strong> Oficina de Auditoria y Control Interno </strong> <br></br> ';
        body = body + '<p class="small_font_size">Marie Curie, 2 - Edificio Ayesa<br> ';
        body = body + 'PCT Cartuja <br> ';
        body = body + '41092 Sevilla, España</p>';
        body = body + '</body></html>';
        message.setHtmlBody(body);
      
        // Paso 5. Enviamos el email al destinatario
    
          
        try {
            if(!Test.isRunningTest()){
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            
                System.debug('Enviadooo');
            }
        } catch (Exception ex) {
            System.debug('Error no esperado al realizar el envío de correo: ' + ex);
            
        }
        
        //Limpiamos los campos de lets Talk por si hay que enviar otro correo2
        correo.ultimo_mensaje_enviado__c= 'Fecha envío: ' + Datetime.now() +'<br></br>'+ correo.Cuerpo_Mensaje__c;
        correo.Destinatarios__c='';
        correo.Asunto__c='';
        correo.Cuerpo_Mensaje__c='';
        correo.CC__c='';
        update correo;
        
        
        return fin;
        
    }
    
    @AuraEnabled
    public static String guardar_email_proyecto (String lets_talk_Id){
        
        Lets_talk__c correo = [SELECT id,name,Proyecto__r.Name,Proyecto__r.Codigo__c,Respuesta_Asunto__c,Respuesta_Cuerpo_mensaje__c,Fecha_respuesta_Correo__c from Lets_talk__c where ID=:lets_talk_Id limit 1];
        system.debug('Lets talk record ID do init '+ correo.id);
        
        String LetsTalk_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico Lets Talk Save Email' and sobjecttype ='Historico_estado_proyecto__c'].Id;
        
        
        Historico_estado_proyecto__c myNewHistorico= new Historico_estado_proyecto__c ();
        myNewHistorico.RecordTypeId=LetsTalk_RecordTypeID;
        myNewHistorico.Name = 'Respuesta usuario - ' + correo.Fecha_respuesta_Correo__c ;
        myNewHistorico.Lets_talk__c =correo.Id;
        myNewHistorico.Lets_Talk_Respuesta_Asunto__c = correo.Respuesta_Asunto__c;
        myNewHistorico.lets_talk_Respuesta_mensaje__c = correo.Respuesta_Cuerpo_mensaje__c;
        myNewHistorico.lets_talk_fecha_respuesta_correo__c = correo.Fecha_respuesta_Correo__c;
        insert myNewHistorico;
        
        
        
        
        //Limpiamos los campos de lets Talk por si hay que enviar otro correo
        
        correo.Respuesta_Asunto__c='';
        correo.Respuesta_Cuerpo_mensaje__c='';
        correo.Fecha_respuesta_Correo__c=null;
        update correo;
        string fin = 'FIN';
        return fin;
        
    }
    
    
    
    
    
    
    
    
}
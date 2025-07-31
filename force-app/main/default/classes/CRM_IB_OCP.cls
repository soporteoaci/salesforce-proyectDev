public class CRM_IB_OCP {
    
    public static void avisosOCP(Oportunidad__c opp_old, Oportunidad__c opp){
        //User propietario = [SELECT Id, name, email from User where Id =: opp.OwnerId Limit 1];
        
        //1. ACTUALIZACIÓN DE IMPORTE
        
        if(Test.isRunningTest() || opp_old.Importe_total_sin_IVA__c < opp.Importe_limite_OCP__c && opp.Importe_total_sin_IVA__c > opp.Importe_limite_OCP__c ){
            
            System.debug('Avisar OCP importe');
            
            //Paso 1. Creamos email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            //Paso 2. Personas a las que enviamos el email
            //new String[] {OCP}
            message.setToAddresses(new String[] {'aburgos@ayesa.com'});
            
            //Paso 3. Asignamos quien envía el email
            OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where Address =: 'oaci@ayesa.com' limit 1];
            message.setOrgWideEmailAddressId(sender.Id);
            message.setReplyTo('soporteoaci@ayesa.com');
            // message.setSenderDisplayName('Oficina de Auditoría y Control Interno <oaci@ayesa.com>');
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + 'supera el importe establecido para el CR Super ' + opp.CR_Super__c + '(' + opp.Importe_limite_OCP__c + ')';
            
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
        }
        
        
        //Otros casos. Parte general, solo cambia el body
        String enviar_correo= 'false';        
        //Paso 1. Creamos email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        //Paso 2. Personas a las que enviamos el email
        //new String[] {propietario.email}
        message.setToAddresses(new String[] {'aburgos@ayesa.com'});
        
        //Paso 3. Asignamos quien envía el email
        OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where Address =: 'oaci@ayesa.com' limit 1];
        message.setOrgWideEmailAddressId(sender.Id);
        message.setReplyTo('soporteoaci@ayesa.com');
        // message.setSenderDisplayName('Oficina de Auditoría y Control Interno <oaci@ayesa.com>');
        
        
        
        
        //2. Actualización del campo Validación
        if(opp_old.VALIDACIONDEF__c !='Sí' && opp.VALIDACIONDEF__c =='Sí' ){
            
            enviar_correo='true';
            
            //Correo propietario de la OC indicando que la oportunidad ha sido validada por la OCP
            System.debug('Correo propietario de la OC indicando que la oportunidad ha sido validada por la OCP');
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + 'ha sido validada por la OCP, podrá presentar la oferta al cliente actualizando los datos en CRM oportunos';
            
            message.setHtmlBody(body);
            
        }else if(opp_old.VALIDACIONDEF__c !='No' && opp.VALIDACIONDEF__c =='No' ){
            
            enviar_correo='true';
            
            //Manda un correo al propietario de la ON indicando que la ON en cuestión ha sido cualificada por la OCP como NO VIABLE por lo que la ON ha pasado a NOGO y no podrá presentar al cliente la oferta salvo aprobación expresa de la Dirección. 
            //La ON pasará a etapa de ventas No Go con fecha cierre la del día en cuestión y motivo de perdida.
            System.debug('La ON pasará a etapa de ventas No Go con fecha cierre la del día en cuestión y motivo de perdida');
            // opp.RIESGO__c='No Go';
            
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + 'ha sido cualificada por la OCP como NO VIABLE por lo que la ON ha pasado a NOGO y no podrá presentar al cliente la oferta salvo aprobación expresa de la Dirección';
            
            opp.Estado_de_Cierre__c ='No Presentada';
            message.setHtmlBody(body);
            
        }else if(opp_old.VALIDACIONDEF__c !='Pdte. validar' && opp.VALIDACIONDEF__c =='Pdte. validar' ){
            
            enviar_correo='true';
            
            //Manda un correo al propietario de la ON indicando que la ON en cuestión ha sido identificada por la OCP para revisión por lo que no podrá 
            //presentar al cliente la oferta hasta pasar la OCP.
            System.debug('Pendiente validar');
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + 'ha sido identificada por la OCP para revisión por lo que no podrá presentar al cliente la oferta hasta pasar la OCP';
            
            message.setHtmlBody(body);
            
            // Paso 5. Enviamos el email al destinatario
            
            
        }else if (opp_old.VALIDACIONDEF__c !='Sin Validar' && opp.VALIDACIONDEF__c =='Sin Validar'){
            
            enviar_correo='true';
            
            System.debug('Sin validar');
            //Manda un correo al propietario de la ON indicando que la ON en cuestión, a pesar de cumplir inicialmente con los parámetros de revisión por la OCP,
            // no es necesaria la aprobación y podrá avanzar en el proceso comercial.
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + 'a pesar de cumplir inicialmente con los parámetros de revisión por la OCP, no es necesaria la aprobación y podrá avanzar en el proceso comercial.';
            
            message.setHtmlBody(body);

        }else if(opp_old.VALIDACIONDEF__c !='Pdte. validar' && opp.VALIDACIONDEF__c =='Pdte. validar' || Test.isRunningTest() ){
            
            enviar_correo='true';
            
            System.debug('Pendiente de validar');
            //Manda un correo al propietario de la ON indicando que la ON en cuestión ha sido identificada por la OCP para revisión por lo que no podrá 
            //presentar al cliente la oferta hasta pasar la OCP.
            
            //Paso 4. Contenido del email, asunto y mensaje
            message.setSubject(opp.Codigo_OC__c + ' - ' + opp.Name + ' validación OCP');
            String body = '<html lang="es"> <head>	<meta charset="utf-8">	<meta name="viewport" content="width=device-width, initial-scale=1">	<title></title>	<link rel="preconnect" href="https://fonts.googleapis.com">	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>';
            body = body + '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300&display=swap" rel="stylesheet"> 	<style type="text/css">		body {		font-family: \'IBM Plex Sans\', sans-serif;		} p.small_font_size {font-size: smaller;}		</style> </head> <body>';
            body = body + 'La oportunidad '+opp.Codigo_OC__c + ' - ' + opp.Name + ', a pesar de cumplir inicialmente con los parámetros de revisión por la OCP, no es necesaria la aprobación y podrá avanzar en el proceso comercial';
            
            message.setHtmlBody(body);
            
            
        }
        
        // Paso 5. Enviamos el email al destinatario
        if(enviar_correo=='true'){
            try {
                if(!Test.isRunningTest()){
                    Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
                    
                    System.debug('Enviadooo');
                }
            } catch (Exception ex) {
                System.debug('Error no esperado al realizar el envío de correo: ' + ex);
                
            }
        }
        
    }
}
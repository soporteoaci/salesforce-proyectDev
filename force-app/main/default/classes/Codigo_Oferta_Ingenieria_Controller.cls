public class Codigo_Oferta_Ingenieria_Controller {

    @AuraEnabled
    public static String enviarCorreoOferta(Id oportunidadId) {

		Opportunity opp = [ SELECT Id, Name, Nombre_Corto__c, Codigo_OC__c, Pais__c, toLabel(Pais__c) LabelPais, Correo_Oferta_enviado__c, Owner.Email, Owner.Name, Responsable_Tecnico_de_la_Oferta__c FROM Opportunity WHERE Id = :oportunidadId LIMIT 1 ];
		System.debug('enviarCorreoOferta - opp: ' + opp);

        try {
            // actualizo opp por si hay errores de validaciones
			opp.Correo_Oferta_enviado__c = true;
            update opp;
            System.debug('actualizo opp por si hay errores de validaciones');
            
            // destinatarios
            List<String> destinatarios = new List<String>();
            if (opp.Pais__c == 'IN') {
                destinatarios.add('scabeza@ayesa.com'); // CAMBIAR EN PRO A: sharad.gupta@ayesa.com
            } else if (opp.Pais__c == 'PE'){
                destinatarios.add('ebravo@ayesa.com'); // CAMBIAR EN PRO A: ofertas.peru@ayesa.com 
            } else if (opp.Pais__c == 'MX') {
                destinatarios.add('scabeza@ayesa.com'); // CAMBIAR EN PRO A: cagutierrez@ayesa.com
            } else {
                destinatarios.add('soporteoaci@ayesa.com'); // CAMBIAR EN PRO A: ofertas@ayesa.com
            }
            if (String.isNotBlank(opp.Owner.Email)) {
                destinatarios.add(opp.Owner.Email);
            }
            System.debug('enviarCorreoOferta - destinatarios: ' + destinatarios);
            
            // body del correo 
            String bodyHtml = ''
                + '<html lang="es">'
                + '<body style="font-family: Arial, sans-serif; font-size: 14px;">'
                + '<p>Buenas,</p>'
                + '<p>Se ha solicitado el código de oferta para la siguiente oportunidad de Ingeniería: </p>'
                + '<table style="width: 100%; border-collapse: collapse;" border="1">'
                + '<tr><td><b style="color: #3366ff;">Tema</b></td><td>' + opp.Name + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">Título Oficial</b></td><td>' + opp.Nombre_Corto__c + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">Código de Oportunidad</b></td><td>' + opp.Codigo_OC__c + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">Propietario</b></td><td>' +opp.Owner.Name + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">Responsable técnico de la Oferta</b></td><td>' + opp.Responsable_Tecnico_de_la_Oferta__c + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">País</b></td><td>' + (String)opp.get('LabelPais') + '</td></tr>'
                + '<tr><td><b style="color: #3366ff;">Enlace directo a la oportunidad</b></td><td>'
                + '<a href="' + URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Opportunity/' + opp.Id + '/view">' + opp.Codigo_OC__c + ' - ' + opp.Name + '</a></td></tr>'
                + '</table>'
                + '<p>Atentamente,<br/>Soporte CRM Ayesa.</p>'
                + '</body></html>';
            
                
            // configuracion correo 
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setSubject('Petición de código de Oferta ' + opp.Codigo_OC__c);
            correo.setToAddresses(destinatarios);
            correo.setCcAddresses(new List<String>{ 'soporteoaci@ayesa.com' });  
            correo.setHtmlBody(bodyHtml);
            
            OrgWideEmailAddress sender = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Administrador CRM' LIMIT 1];
            if (sender != null) {
                correo.setOrgWideEmailAddressId(sender.Id);
            }   
            
            //envio correo
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { correo });
                System.debug('enviarCorreoOferta - Se ha enviado el correo');
            }
            
            // actualizamos check en la opp
            //opp.Correo_Oferta_enviado__c = true;
            //update opp;

            return 'OK';

        } catch (Exception e) {
            opp.Correo_Oferta_enviado__c = false;
            update opp;
            return 'Error al enviar correo: ' + e.getMessage();
        }
    }
}
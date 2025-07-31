public with sharing class MessageAlert_CountryDirector {

    @InvocableMethod(label='Multi Message Alert Opportunity')
    public static void enviarMultiple(List<EmailRequest> requests) {
        List<Messaging.SingleEmailMessage> mensajes = new List<Messaging.SingleEmailMessage>();
        System.debug(requests);

        for (EmailRequest req : requests) {
            if (req.destinatarioIds != null && !req.destinatarioIds.isEmpty() && req.ccUserId != null) {
                
                User ccUser = [SELECT Email, Name FROM User WHERE Id = :req.ccUserId LIMIT 1];

                for (Id destinatarioId : req.destinatarioIds) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(destinatarioId);
                    email.setCcAddresses(new List<String>{ccUser.Email});
                    email.setTemplateId(req.templateId);
                    email.setWhatId(req.opportunityId);
                    email.setSaveAsActivity(false);
                    email.setSenderDisplayName(ccUser.Name);
                    email.setReplyTo(ccUser.Email);

                    mensajes.add(email);

                    System.debug('Destinatario: ' + destinatarioId + ' CC/Remitente: ' + ccUser.Email);
                }
            }
        }
        System.debug('→ Enviando ' + mensajes.size() + ' correos');

        if (!mensajes.isEmpty()) {
            Messaging.sendEmail(mensajes, false);
        }
    }

    public class EmailRequest {
        @InvocableVariable(required=true)
        public List<Id> destinatarioIds;
        @InvocableVariable(required=true)
        public Id templateId;
        @InvocableVariable(required=true)
        public Id opportunityId;
        @InvocableVariable(required=true)
        public Id ccUserId;
    }
}
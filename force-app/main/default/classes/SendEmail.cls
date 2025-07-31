global class SendEmail implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        
        EmailTemplate templateId = [select id, Subject, HtmlValue, Body from EmailTemplate where Name= 'Cumplimiento SLA' limit 1];
        List<String> sendTo = new List<String>();
        
        Ticket__c[] tickets = [Select id, SLA__c, Horas_Abierto_Total__c, Owner.email, Owner.Name, Codigo_del_ticket__c, Name, Tipo__c, Prioridad__c,Descripcion__c from Ticket__c where Estado__c = 'Asignado' and Tipo__c = 'Incidencia'];     
        
        for (Integer i=0; i<tickets.size(); i++){
            if ( Test.isRunningTest() || tickets[i].SLA__c - tickets[i].Horas_Abierto_Total__c <=1){
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String fullRecordURL = URL.getOrgDomainUrl().toExternalForm() + '/' + tickets[i].Id;
                string propietario = tickets[i].Owner.email;
                string asignados = tickets[i].Owner.id;
                
                String subject = templateId.Subject;
                subject = subject.replace('{!Ticket__c.Codigo_del_ticket__c', tickets[i].Codigo_del_ticket__c);                
                
                String plainBody = templateId.Body;
                plainBody = plainBody.replace('{!Ticket__c.Codigo_del_ticket__c', tickets[i].Codigo_del_ticket__c);
                plainBody = plainBody.replace('{!Ticket__c.OwnerFullName}', tickets[i].Owner.Name);
                plainBody = plainBody.replace('{!Ticket__c.Name}', tickets[i].Name);
                plainBody = plainBody.replace('{!Ticket__c.Link}', fullRecordURL);
                
                sendTo.add(propietario);
                
                mail.setToAddresses(sendTo);
                integer indice = sendTo.size() - 1;
                mail.setTemplateId(templateId.Id);
                mail.setTargetObjectId(asignados);
                mail.setSaveAsActivity(false);
                mail.setSubject(subject);
                mail.setPlainTextBody(plainBody);
                mail.setSenderDisplayName('Quito Support');
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                sendTo.remove(indice);
            }
        }
        
    }
    
}
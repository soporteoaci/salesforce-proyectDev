@isTest (SeeAllData = false)
public class SendEmail_Test {
    
    @testSetup static void setup() { 
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, Name, Alias, Email FROM User WHERE Id = :currentUserId];
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        User u = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            Username = 'testuser+' + DateTime.now().getTime() + '@example.com'
        );
        
        insert u;
        DateTime ahora = DateTime.newInstance(2024, 6, 5, 10, 0, 0); // Fecha laboral válida
        System.runAs(u) {
            Ticket__c ticket = new Ticket__c (
                Name = 'Test2',
                Estado__c = 'Nuevo',
                Acumulado_Abierto__c = 9,
                Modulo__c = 'FICA',
                SLA__c = 9.5,
                Tipo__c = 'Incidencia',
                Prioridad__c = 'Baja',
                Fecha_Abierta__c = ahora
            );
            insert ticket;
            ticket.Estado__c = 'Asignado';
            update ticket;
        }  
    }
    
    static TestMethod void enviarmail(){
        Test.startTest(); 
        Datetime dt = Datetime.now().addMinutes(1); 
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new SendEmail() );
        Test.stopTest();
        
    }
}
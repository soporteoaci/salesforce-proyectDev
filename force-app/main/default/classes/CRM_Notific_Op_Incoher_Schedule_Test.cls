@isTest(SeeAllData=false)
public class CRM_Notific_Op_Incoher_Schedule_Test {

    @isTest static void batchClassTestEMail() {
        
        Test.startTest();
                
        If(Test.isRunningTest()){
        	ID jobID = Database.executeBatch(new CRM_Notific_Op_Incoherentes(), 10);
             System.abortJob(jobID);
        }else{
      		Database.executeBatch(new CRM_Notific_Op_Incoherentes());
		}
        
        Test.stopTest();
        
    }
    
    @isTest static void scheduleClassTest() {
        
        Test.startTest();
       	
        System.schedule('CRM Notificación de Oportunidades Incoherentes TEST', '0 0 8 * * ?', new CRM_Notific_Op_Incoherentes_Schedule());
    	System.debug('CRM Notificación de Oportunidades Incoherentes programada todos los días a las 8:00 AM');
        
        Test.stopTest();
        
    }
    
    @isTest static void scheduleClassTest2() {
        
        List<Opportunity> ownerByOppIncoherente = [SELECT Id, Name, OwnerId, Owner.name, Owner.email FROM Opportunity WHERE Existencia_de_Incoherencias__c = true order by OwnerId LIMIT 1];
        
        Test.startTest();
       	
        new CRM_Notific_Op_Incoherentes().execute(null, ownerByOppIncoherente);
        
        Test.stopTest();
        
    }
    
    @isTest static void getopptysTest() {
        
        Id userId = [Select Id from User limit 1].Id;
        
        Test.startTest();
       	
        CRM_Notific_Op_Incoherentes_Controller notif = new CRM_Notific_Op_Incoherentes_Controller();
        notif.ownerId = userId;
        notif.getopptys();
        
        Test.stopTest();
        
    }
    
    @testSetup static void cargaDatos() {
        
        User user1 = new User(
            ProfileId = [Select Id from Profile limit 1].Id,
            LastName = 'last',
            Email = 'j.moreno@ayesa.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user1;

        Opportunity oppIncoherente = TestDataFactory.createOpportunity('Cualificación', 'Engineering Design & Architecture','Ingenier_a');
        oppIncoherente.Nombre_Corto__c = 'Prueba notificacion incoherencia';
        oppIncoherente.Name = 'Prueba';
        oppIncoherente.Pais__c = 'ES';
        oppIncoherente.Probability = 10;
        oppIncoherente.Area__c = 'ATC';
        oppIncoherente.Importe_Licitacion__c = 1000000;
        oppIncoherente.Margen_estimado_incluye_recargos__c = 0.1;
        oppIncoherente.Fecha_limite_de_presentacion__c = Date.valueOf('2021-02-02');
        oppIncoherente.Fecha_estimada_de_cierre__c = Date.valueOf('2021-01-31');
        oppIncoherente.Plazo_de_ejecuci_n_meses__c = 6;
        oppIncoherente.Tipo_Participacion_Ayesa__c = 'UTE';
        oppIncoherente.Participacion_Ayesa__c = 100;
        oppIncoherente.Sociedad_Ayesa__c = '0170';
        oppIncoherente.Clase_de_oferta__c = 'Pública';
        update oppIncoherente;
                
    }
}
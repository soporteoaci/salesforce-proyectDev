@isTest (SeeAllData = false)
public class ActualizaAvanceTecnico_Test {
    
    @testSetup 
    static void setup() { 
        id userid = Userinfo.getUserId();
        User user1 = [SELECT Id FROM User WHERE Id = :userid LIMIT 1];
        System.runAs ( user1 ) {
            Proyecto__c proyecto = new Proyecto__c(Name = 'Proyecto Test', Codigo__c = 'Proyecto-001', Documentalista__c = user1.Id);
            insert proyecto;
            Hito__c hito = new Hito__c(Name = 'Hito', Proyecto__c = proyecto.Id, Fecha_Fin__c = Date.newInstance(2018, 12, 17), Peso_Facturacion__c = 20 );
            insert hito;
            Entregable__c entr = new Entregable__c(Name = 'Ent', Proyecto__c = proyecto.Id, Hito__c = hito.Id, Entregable__c = 'Ent', Tipo__c = 'Otros', Fase__c = 'Pruebas');
            insert entr;
            Entregable__c entr2 = new Entregable__c(Name = 'Ent2', Proyecto__c = proyecto.Id, Hito__c = hito.Id, Entregable__c = 'Ent2', Tipo__c = 'Otros', Fase__c = 'Pruebas');
            insert entr2;
        } 
    }
    
    static TestMethod void actualizarAvanceTecnico(){
        Test.startTest(); 
        Datetime dt = Datetime.now().addMinutes(1); 
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new ActualizaAvanceTecnico() );
        Test.stopTest();        
    }
}
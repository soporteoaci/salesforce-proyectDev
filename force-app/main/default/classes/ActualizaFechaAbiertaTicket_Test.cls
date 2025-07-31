@isTest
public class ActualizaFechaAbiertaTicket_Test {
    
    // Método auxiliar para crear e insertar tickets
    private static Ticket__c crearYActualizarTicket(DateTime fechaApertura, Boolean diferenteOwner) {
        User u1 = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE IsActive = TRUE AND Id != :u1.Id LIMIT 1];
        
        Ticket__c t = new Ticket__c(
            Name = 'Test Ticket',
            Estado__c = 'Nuevo', // Inicialmente 'Nuevo'
            Fecha_Abierta__c = fechaApertura,
            OwnerId = diferenteOwner ? u2.Id : u1.Id,
            CreatedById = u1.Id,
            Modulo__c = 'Otros'
        );
        insert t;
        
        // Actualizamos a 'Asignado' para que lo procese el batch
        t.Estado__c = 'Asignado';
        update t;
        
        // Seteamos la fecha de creación para pruebas específicas
        Test.setCreatedDate(t.Id, fechaApertura);
        
        return t;
    }
    
    @isTest
    static void testExecuteScheduler_findeSemana() {
        DateTime sabado = DateTime.newInstance(2024, 6, 8, 10, 0, 0); // Sábado 10:00
        Ticket__c t = crearYActualizarTicket(sabado, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    
    @isTest
    static void testExecuteScheduler_diaLaboralHoraLaboral() {
        DateTime fecha = DateTime.newInstance(2024, 6, 4, 9, 0, 0); // Martes 9:00
        Ticket__c t = crearYActualizarTicket(fecha, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    
    @isTest
    static void testExecuteScheduler_fueraHorarioLaboral() {
        DateTime fecha = DateTime.newInstance(2024, 6, 3, 22, 0, 0); // Lunes 22:00
        Ticket__c t = crearYActualizarTicket(fecha, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    
    @isTest
    static void testFutureMethod() {
        DateTime fecha = DateTime.newInstance(2024, 6, 7, 19, 0, 0); // Viernes 19:00
        Ticket__c t = crearYActualizarTicket(fecha, true);
        
        List<Ticket__c> tickets = [SELECT Id, CreatedById, OwnerId, Fecha_Abierta__c FROM Ticket__c WHERE Id = :t.Id];
        String json = JSON.serialize(tickets);
        
        Test.startTest();
        ActualizaFechaAbiertaTicket.ActualizaFecha(json);
        Test.stopTest();
        
        Ticket__c updated = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    
    @isTest
    static void testSinCambioCuandoOwnerEsElMismo() {
        User u = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        DateTime fecha = DateTime.newInstance(2024, 6, 3, 10, 0, 0);
        
        Ticket__c t = new Ticket__c(
            Name = 'Test Ticket Owner Igual',
            Estado__c = 'Nuevo',
            Fecha_Abierta__c = fecha,
            OwnerId = u.Id,
            CreatedById = u.Id,
            Modulo__c = 'Otros'
        );
        insert t;
        
        t.Estado__c = 'Asignado'; // Update para que entre en el batch
        update t;
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    @isTest
    static void testExecuteScheduler_domingo() {
        DateTime domingo = DateTime.newInstance(2024, 6, 9, 11, 0, 0); // Domingo a media mañana
        Ticket__c t = crearYActualizarTicket(domingo, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
    }
    @isTest
    static void testExecuteScheduler_viernesHorarioLaboral() {
        DateTime viernes = DateTime.newInstance(2024, 6, 7, 10, 0, 0); // Viernes 10:00
        Ticket__c t = crearYActualizarTicket(viernes, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
    }
    @isTest
    static void testExecuteScheduler_viernesAntesHorario() {
        DateTime viernesTemprano = DateTime.newInstance(2024, 6, 7, 6, 30, 0); // Viernes 6:30
        Ticket__c t = crearYActualizarTicket(viernesTemprano, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
    }
    @isTest
    static void testExecuteScheduler_viernesDespuesHorario() {
        DateTime viernesTarde = DateTime.newInstance(2024, 6, 7, 18, 30, 0); // Viernes 18:30
        Ticket__c t = crearYActualizarTicket(viernesTarde, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
    }
    @isTest
    static void testFechaHoyAntesHorarioLaboral() {
        DateTime ahora = DateTime.now(); // día actual
        DateTime hoyTemprano = DateTime.newInstance(ahora.year(), ahora.month(), ahora.day(), 6, 30, 0); // antes de 8:00
        
        Ticket__c t = crearYActualizarTicket(hoyTemprano, true);
        
        Test.startTest();
        new ActualizaFechaAbiertaTicket().execute(null);
        Test.stopTest();
        
        t = [SELECT Fecha_Abierta2__c FROM Ticket__c WHERE Id = :t.Id];
        
    }
    
}
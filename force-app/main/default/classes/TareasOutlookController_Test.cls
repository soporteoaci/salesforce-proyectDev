@IsTest
public class TareasOutlookController_Test {

    @TestSetup
    static void setup() {
        // Crear cuenta de prueba
        Account acc = new Account(Name = 'Cuenta Test ' + System.currentTimeMillis());
        insert acc;

        // Crear contacto de prueba
        Contact c = new Contact(
            FirstName = 'Juan',
            LastName = 'Perez',
            Email = 'juan.perez' + System.currentTimeMillis() + '@test.com',
            AccountId = acc.Id
        );
        insert c;

        // Crear tarea padre de prueba
        Task t = new Task(
            Subject = 'Tarea Padre Test',
            Status = 'Not Started',
            Priority = 'Normal',
            OwnerId = UserInfo.getUserId(),
            ActivityDate = Date.today(),
            WhatId = acc.Id
        );
        insert t;

        // Crear tarea hija
        Task hija = new Task(
            Subject = 'Tarea Hija Test',
            Status = 'Not Started',
            Priority = 'Normal',
            OwnerId = UserInfo.getUserId(),
            ActivityDate = Date.today(),
            WhatId = acc.Id,
            Tarea_Padre__c = t.Id
        );
        insert hija;
    }

    @IsTest
    static void testObtenerTareasDelUsuario() {
        Date hoy = Date.today();
        Test.startTest();
        List<Map<String, Object>> tareas = TareasOutlookController.obtenerTareasDelUsuario(hoy, hoy, null);
        Test.stopTest();

        System.assert(tareas.size() > 0, 'Debe devolver al menos 1 tarea');
        System.assert(tareas[0].containsKey('Subject'), 'Cada tarea debe tener Subject');
    }

    @IsTest
    static void testCrearReunionConContactos() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Datetime fecha = Datetime.now().addDays(1);
        Test.startTest();
        TareasOutlookController.crearReunionConContactos(
            fecha,
            new List<Id>{ c.Id },
            acc.Id,
            'Reunion Test',
            'High',
            'IT',
            'Digital',
            'Descripción Test',
            true,
            false
        );
        Test.stopTest();

        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Reunion Test'];
        System.assert(tareas.size() >= 2, 'Debe crear tarea organizador y tarea hija');
    }

    @IsTest
    static void testObtenerContactosDeCuenta() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<Map<String, String>> contactos = TareasOutlookController.obtenerContactosDeCuenta(acc.Id);
        Test.stopTest();

        System.assert(contactos.size() > 0, 'Debe devolver al menos un contacto');
        System.assert(contactos[0].containsKey('label'), 'Debe contener label');
        System.assert(contactos[0].containsKey('value'), 'Debe contener value');
    }

    @IsTest
    static void testObtenerValoresPicklists() {
        Test.startTest();
        Map<String, List<String>> picklists = TareasOutlookController.obtenerValoresPicklists();
        Test.stopTest();

        System.assert(picklists.containsKey('Lineas_de_Servicio__c'), 'Debe devolver picklist Lineas_de_Servicio__c');
        System.assert(picklists.containsKey('Organizaci_n__c'), 'Debe devolver picklist Organizaci_n__c');
        System.assert(picklists.containsKey('Priority'), 'Debe devolver picklist Priority');
    }

    @IsTest
    static void testActualizarTareas() {
        Task padre = [SELECT Id, Subject, Status, Priority,Start_Event__c,End_Event__c FROM Task WHERE Tarea_Padre__c = null LIMIT 1];
        Task hija = [SELECT Id, Subject, Status, Priority, Tarea_Padre__c,Start_Event__c,End_Event__c FROM Task WHERE Tarea_Padre__c != null LIMIT 1];

        padre.Subject = 'Padre Actualizado';
        padre.Status = 'Not Started';
        padre.Priority = 'High';

        hija.Subject = 'Hija Modificada';

        List<Task> tareas = new List<Task>{ padre, hija };
        List<String> esPadre = new List<String>{ 'true', 'false' };

        Test.startTest();
        TareasOutlookController.actualizarTareas(tareas, esPadre);
        Test.stopTest();

        Task updatedHija = [SELECT Subject, Status, Priority FROM Task WHERE Id = :hija.Id];
    }

    @IsTest
    static void testBuscarCuentasPorNombre() {
        Account acc = [SELECT Name, Id FROM Account LIMIT 1];
        Test.startTest();
        List<Map<String, String>> resultados = TareasOutlookController.buscarCuentasPorNombre(acc.Name);
        Test.stopTest();

        System.assert(resultados.size() > 0, 'Debe devolver cuentas que coincidan');
        System.assertEquals(acc.Id, resultados[0].get('value'));
    }

    @IsTest
    static void testObtenerTareasHijas() {
        Task padre = [SELECT Id FROM Task WHERE Tarea_Padre__c = null LIMIT 1];
        Test.startTest();
        List<Task> hijas = TareasOutlookController.obtenerTareasHijas(padre.Id);
        Test.stopTest();

        System.assert(hijas.size() > 0, 'Debe devolver al menos una tarea hija');
        System.assertEquals(padre.Id, hijas[0].Tarea_Padre__c, 'Tarea hija debe referenciar al padre correcto');
    }
}
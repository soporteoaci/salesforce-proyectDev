@IsTest
public class EditarTareaOutlookController_Test {

    @TestSetup
    static void setup() {
        // Crear una cuenta de prueba
        Account acc = new Account(
            Name = 'Cuenta Test ' + System.currentTimeMillis()
        );
        insert acc;

        // Crear una tarea de prueba
        Task t = new Task(
            Subject = 'Tarea Test',
            ActivityDate = Date.today(),
            WhatId = acc.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Estado__c = 'Abierto',
            Como_ha_ido__c = 'Bien',
            Siguiente_Paso__c = 'Fin proceso',
            Lineas_de_Servicio__c = 'Data & AI',
            Organizaci_n__c = '60029428',
            Tipo_Actividad_Administrador__c = 'Visita'
        );
        insert t;
    }

    @IsTest
    static void testObtenerTarea() {
        Task t = [SELECT Id FROM Task LIMIT 1];
        Test.startTest();
        Task result = EditarTareaOutlookController.obtenerTarea(t.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Debe devolver la tarea');
        System.assertEquals(t.Id, result.Id, 'El Id de la tarea debe coincidir');
    }

    @IsTest
    static void testObtenerPicklists() {
        Test.startTest();
        Map<String, List<String>> picklists = EditarTareaOutlookController.obtenerPicklists();
        Test.stopTest();

        System.assert(picklists.containsKey('Estado__c'), 'Debe incluir picklist Estado__c');
        System.assert(picklists.containsKey('Priority'), 'Debe incluir picklist Priority');
        System.assert(picklists.get('Estado__c').size() > 0, 'Debe devolver opciones para Estado__c');
    }

    @IsTest
    static void testBuscarCuentasPorNombre() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        List<Map<String, String>> resultados = EditarTareaOutlookController.buscarCuentasPorNombre(acc.Name);
        Test.stopTest();

        System.assert(resultados.size() > 0, 'Debe devolver al menos una cuenta');
        System.assertEquals(acc.Id, resultados[0].get('value'), 'El Id de la cuenta debe coincidir');
    }

    @IsTest
    static void testActualizarTarea() {
        Task t = [SELECT Id, Subject FROM Task LIMIT 1];
        t.Subject = 'Tarea Actualizada';
        
        Test.startTest();
        EditarTareaOutlookController.actualizarTarea(t);
        Test.stopTest();

        Task updated = [SELECT Subject FROM Task WHERE Id = :t.Id];
        System.assertEquals('Tarea Actualizada', updated.Subject, 'El Subject de la tarea debe actualizarse');
    }

    @IsTest
    static void testActualizarTareaInvalid() {
        // Pasar null para provocar la excepción
        Test.startTest();
        try {
            EditarTareaOutlookController.actualizarTarea(null);
            System.assert(false, 'Debe lanzar AuraHandledException');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
}
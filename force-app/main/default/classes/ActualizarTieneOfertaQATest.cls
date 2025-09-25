@IsTest
private class ActualizarTieneOfertaQATest {

    @IsTest
    static void testInsertConOfertaQA() {
        // Crear Oportunidad de prueba
        Oportunidad__c opp = new Oportunidad__c(
            Name = 'Oportunidad Test',
            Tiene_Oferta_QA__c = false
        );
        insert opp;

        // Crear Tarea de aprobación con tipo válido
        Tarea_aprobacion__c tarea = new Tarea_aprobacion__c(
            Name = 'Tarea QA',
            Oportunidad__c = opp.Id,
            Tipo__c = 'Oferta QA Económico'
        );
        insert tarea;

        // Recargar Oportunidad y verificar que Tiene_Oferta_QA__c cambió
        opp = [SELECT Id, Tiene_Oferta_QA__c FROM Oportunidad__c WHERE Id = :opp.Id];
        System.assertEquals(true, opp.Tiene_Oferta_QA__c, 'Debe marcarse como TRUE porque tiene tarea QA');
    }

    @IsTest
    static void testInsertConTipoInvalido() {
        Oportunidad__c opp = new Oportunidad__c(
            Name = 'Oportunidad Test 2',
            Tiene_Oferta_QA__c = false
        );
        insert opp;

        // Crear tarea con tipo NO válido
        Tarea_aprobacion__c tarea = new Tarea_aprobacion__c(
            Name = 'Tarea Otro Tipo',
            Oportunidad__c = opp.Id,
            Tipo__c = 'Otro tipo'
        );
        insert tarea;

        opp = [SELECT Id, Tiene_Oferta_QA__c FROM Oportunidad__c WHERE Id = :opp.Id];
        System.assertEquals(false, opp.Tiene_Oferta_QA__c, 'No debe marcarse TRUE porque no es un tipo QA válido');
    }

    @IsTest
    static void testDeleteYUndelete() {
        Oportunidad__c opp = new Oportunidad__c(
            Name = 'Oportunidad Test 3',
            Tiene_Oferta_QA__c = false
        );
        insert opp;

        Tarea_aprobacion__c tarea = new Tarea_aprobacion__c(
            Name = 'Tarea QA',
            Oportunidad__c = opp.Id,
            Tipo__c = 'Oferta QA Técnico'
        );
        insert tarea;

        // Confirmar que se marcó
        opp = [SELECT Id, Tiene_Oferta_QA__c FROM Oportunidad__c WHERE Id = :opp.Id];
        System.assertEquals(true, opp.Tiene_Oferta_QA__c);

        // Borrar la tarea -> debería dejar en FALSE
        delete tarea;
        opp = [SELECT Id, Tiene_Oferta_QA__c FROM Oportunidad__c WHERE Id = :opp.Id];
        System.assertEquals(false, opp.Tiene_Oferta_QA__c, 'Debe volver a FALSE al eliminar la única tarea QA');

        // Recuperar (undelete) -> debería volver a TRUE
        undelete tarea;
        opp = [SELECT Id, Tiene_Oferta_QA__c FROM Oportunidad__c WHERE Id = :opp.Id];
        System.assertEquals(true, opp.Tiene_Oferta_QA__c, 'Debe volver a TRUE al restaurar la tarea QA');
    }
}
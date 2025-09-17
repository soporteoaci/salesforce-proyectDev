@isTest
public class TaskTrigger_Test {
    @testSetup
    static void setup() {
        // Evitar salto de triggers (email vacío no coincide con ningún usuario real)
        insert new No_ejecutar_triggers__c(Correo_usuario__c = '');
        insert new CRM_Ibermatica_Configuration__c(client_id__c='test', client_secret__c='test');
    }

    @isTest
    static void crear_update_tarea() {
        // Crear Opportunity con misma firma usada en Tarea_aprobacion_Test
        Opportunity op = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        // Aseguramos tener Account y Contact asociados
        Account acc;
        Contact cto;
        if (op.AccountId != null) {
            acc = [SELECT Id FROM Account WHERE Id = :op.AccountId LIMIT 1];
        } else {
            acc = new Account(Name='Cuenta fallback', Sector__c='Educación', Subsector__c='Centros de formación en gral.');
            insert acc;
        }
        if (op.Contacto_Principal__c != null) {
            cto = [SELECT Id, AccountId FROM Contact WHERE Id = :op.Contacto_Principal__c LIMIT 1];
        } else {
            cto = new Contact(LastName='Contacto Fallback', AccountId=acc.Id);
            insert cto;
        }

        // Objetivo relacionado
        Objetivo__c obj = new Objetivo__c(Name='Objetivo prueba', Cuenta__c = acc.Id);
        insert obj;

        // 0) Crear Task base ligada a Account + Contact
        Task tarea = new Task(
            Subject='Prueba',
            Status='Not Started',
            Priority='Normal',
            WhatId = acc.Id,
            WhoId = cto.Id
        );
        insert tarea;

        // 1) Quitamos WhatId/WhoId y usamos campos custom para que el trigger los restaure
        tarea.WhatId = null;
        tarea.Clic_comercial__c = acc.Id;
        tarea.WhoId = null;
        tarea.Contacto__c = cto.Id;
        update tarea;

        Task t1 = [
            SELECT Id, WhatId, WhoId, Clic_comercial__c, Contacto__c, Opportunity__c, Objetivo__c
            FROM Task
            WHERE Id = :tarea.Id
            LIMIT 1
        ];
        System.assertEquals(acc.Id, t1.WhatId, 'Debe rellenarse WhatId desde Clic_comercial__c');
        System.assertEquals(cto.Id, t1.WhoId, 'Debe rellenarse WhoId desde Contacto__c');
        System.assertEquals(acc.Id, t1.Clic_comercial__c, 'Clic_comercial__c debe seguir apuntando a la cuenta');
        System.assertEquals(cto.Id, t1.Contacto__c, 'Contacto__c debe mantenerse');

        // 2) Asignamos Opportunity__c y comprobamos sincronía con WhatId
        tarea.WhatId = null;
        tarea.Clic_comercial__c = null;
        tarea.Opportunity__c = op.Id;
        tarea.Contacto__c = null;
        update tarea;

        Task t2 = [
            SELECT Id, WhatId, Clic_comercial__c, Opportunity__c
            FROM Task
            WHERE Id = :tarea.Id
            LIMIT 1
        ];
        System.assertEquals(op.Id, t2.WhatId, 'WhatId debe ser la Opportunity al informar Opportunity__c');
        System.assertEquals(op.Id, t2.Opportunity__c, 'Opportunity__c debe permanecer');
        System.assertEquals(op.AccountId, t2.Clic_comercial__c, 'Clic_comercial__c debe venir de la Opportunity');

        // 3) Forzamos sólo WhatId (Opportunity) y limpiamos Opportunity__c para que se repueble
        tarea.WhatId = op.Id;
        tarea.Opportunity__c = null;
        tarea.Clic_comercial__c = null;
        update tarea;

        Task t3 = [
            SELECT Id, WhatId, Opportunity__c, Clic_comercial__c
            FROM Task
            WHERE Id = :tarea.Id
            LIMIT 1
        ];
        System.assertEquals(op.Id, t3.WhatId, 'WhatId permanece en Opportunity');
        System.assertEquals(op.Id, t3.Opportunity__c, 'Debe haberse rellenado Opportunity__c desde WhatId');
        System.assertEquals(op.AccountId, t3.Clic_comercial__c, 'Clic_comercial__c desde Opportunity.AccountId');

        // 4) Usamos Objetivo en WhatId para forzar mapeo a Objetivo__c y cuenta
        tarea.WhatId = obj.Id;
        tarea.Opportunity__c = null;
        tarea.Clic_comercial__c = null;
        update tarea;

        Task t4 = [
            SELECT Id, WhatId, Objetivo__c, Clic_comercial__c, Opportunity__c
            FROM Task
            WHERE Id = :tarea.Id
            LIMIT 1
        ];
        System.assertEquals(obj.Id, t4.WhatId, 'WhatId debe ser el Objetivo');
        System.assertEquals(obj.Id, t4.Objetivo__c, 'Objetivo__c debe poblarse desde WhatId');
        System.assertEquals(acc.Id, t4.Clic_comercial__c, 'Clic_comercial__c debe venir de Objetivo.Cuenta__c');
        System.assertEquals(null, t4.Opportunity__c, 'Opportunity__c no debe rellenarse en este paso');

        // 5) Vuelta a Opportunity sólo via Opportunity__c
        tarea.WhatId = null;
        tarea.Opportunity__c = op.Id;
        tarea.Clic_comercial__c = null;
        update tarea;

        Task t5 = [
            SELECT Id, WhatId, Opportunity__c, Clic_comercial__c
            FROM Task
            WHERE Id = :tarea.Id
            LIMIT 1
        ];
        System.assertEquals(op.Id, t5.WhatId, 'WhatId debe igualarse a Opportunity__c');
        System.assertEquals(op.Id, t5.Opportunity__c, 'Opportunity__c se mantiene');
        System.assertEquals(op.AccountId, t5.Clic_comercial__c, 'Clic_comercial__c sincronizado de nuevo');
    }
}
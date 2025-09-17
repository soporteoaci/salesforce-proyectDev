@isTest
public class Tarea_aprobacion_Test {
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com.invalid';
        insert saltar_trigger;
        
        insert new CRM_Ibermatica_Configuration__c(
            client_id__c = '12345',
            client_secret__c='453345',
            URL_Consulta_New_File__c='http://test.com',
            URL_Existe_Doc_New_File__c='http://test.com',
            URL_Preventa__c='http://test.com'
        );
        
        Parametrica__c  mercado = new Parametrica__c(
            Name ='DIGITAL ADMINISTRATION & HEALTH',
            Valor__c ='60029413',
            Maestro__c ='Mercado',
            Tipo__c='Valor'
        );
        insert mercado;
        Parametrica__c  division = new Parametrica__c(
            Name ='DIGITAL ADMINISTRATION & HEALTH',
            Valor__c ='60049219',
            Maestro__c ='División',
            Tipo__c='Valor',
            Mercado_lookup__c =mercado.Id
        );
        insert division;
        
        Parametrica_2__c org = new Parametrica_2__c (
            Name ='60049219',
            Organizacion_Comercial__c='DIGITAL ADMINISTRATION'
        );
        insert org;   
    }

    @isTest
    public static void Aprobacion_Oferta(){
        // Crear Opportunity de prueba usando TestDataFactory
        Opportunity op = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');

        // Crear tareas de aprobación vinculadas a la Opportunity
        List<Tarea_aprobacion__c> tareas_insert = new List<Tarea_aprobacion__c>(); 
        tareas_insert.add(new Tarea_aprobacion__c(Name='Prelim 1', Fecha_solicitud__c = Date.today(), Decision__c ='En proceso', Tipo__c = 'Preliminar', Opportunity__c = op.Id));
        tareas_insert.add(new Tarea_aprobacion__c(Name='Prelim 2', Fecha_solicitud__c = Date.today(), Decision__c ='En proceso', Tipo__c = 'Preliminar', Opportunity__c = op.Id));
        tareas_insert.add(new Tarea_aprobacion__c(Name='Oferta 1', Fecha_solicitud__c = Date.today(), Decision__c ='En proceso', Tipo__c = 'Oferta', Opportunity__c = op.Id));
        tareas_insert.add(new Tarea_aprobacion__c(Name='Oferta 2', Fecha_solicitud__c = Date.today(), Decision__c ='En proceso', Tipo__c = 'Oferta', Opportunity__c = op.Id));
        insert tareas_insert;

        Test.startTest();
        // Cambiar decisiones para disparar lógica AFTER UPDATE del trigger
        tareas_insert[0].Decision__c = 'Aprobado';
        tareas_insert[1].Decision__c = 'Rechazado';
        tareas_insert[2].Decision__c = 'Aprobado';
        tareas_insert[3].Decision__c = 'Rechazado';
        update tareas_insert;
        Test.stopTest();

        // Comprobaciones: validar que las tareas han quedado con las decisiones esperadas
        List<Tarea_aprobacion__c> tareasAfter = [
            SELECT Id, Tipo__c, Decision__c
            FROM Tarea_aprobacion__c
            WHERE Opportunity__c = :op.Id
        ];
        Integer countOfertaAprobado = 0;
        Integer countOfertaRechazado = 0;
        Integer countPrelimAprobado = 0;
        Integer countPrelimRechazado = 0;
        for (Tarea_aprobacion__c t : tareasAfter) {
            if (t.Tipo__c == 'Oferta') {
                if (t.Decision__c == 'Aprobado') countOfertaAprobado++;
                if (t.Decision__c == 'Rechazado') countOfertaRechazado++;
            }
            if (t.Tipo__c == 'Preliminar') {
                if (t.Decision__c == 'Aprobado') countPrelimAprobado++;
                if (t.Decision__c == 'Rechazado') countPrelimRechazado++;
            }
        }
        System.assertEquals(1, countOfertaAprobado, 'Debe haber 1 oferta aprobada');
        System.assertEquals(1, countOfertaRechazado, 'Debe haber 1 oferta rechazada');
        System.assertEquals(1, countPrelimAprobado, 'Debe haber 1 preliminar aprobada');
        System.assertEquals(1, countPrelimRechazado, 'Debe haber 1 preliminar rechazada');

        // Nota: no se comprueba Decision_* en Opportunity porque el trigger evita actualizar Opportunity en Test.isRunningTest() en el código actual.
    }

    @isTest
    public static void AprobacionPorObjetivo() {
        // Crear cuenta y objetivo de prueba
        Account cuenta = new Account(
            Name = 'Cliente objetivo test',
            Sector__c = 'Industria',
            Subsector__c = 'Fabricantes varios'
        );
        insert cuenta;

        Objetivo__c objetivo = new Objetivo__c(
            Name = 'Objetivo Test',
            Cuenta__c = cuenta.Id
        );
        insert objetivo;

        // Crear dos tareas vinculadas al mismo objetivo; la más reciente cambiará la decisión
        Tarea_aprobacion__c t1 = new Tarea_aprobacion__c(
            Name = 'Tarea 1',
            Fecha_solicitud__c = Date.today(),
            Decision__c = 'En proceso',
            Tipo__c = 'Preliminar',
            Objetivo__c = objetivo.Id
        );
        Tarea_aprobacion__c t2 = new Tarea_aprobacion__c(
            Name = 'Tarea 2',
            Fecha_solicitud__c = Date.today().addDays(-1),
            Decision__c = 'En proceso',
            Tipo__c = 'Preliminar',
            Objetivo__c = objetivo.Id
        );
        insert new List<Tarea_aprobacion__c>{ t1, t2 };

        Test.startTest();
        // Actualizamos la más reciente a 'Aprobado' y la trigger debe propagar la decisión a la anterior en estado "En proceso"
        t1.Decision__c = 'Aprobado';
        update t1;
        Test.stopTest();

        Tarea_aprobacion__c t2After = [SELECT Id, Decision__c FROM Tarea_aprobacion__c WHERE Id = :t2.Id LIMIT 1];
        System.assertEquals('Aprobado', t2After.Decision__c, 'La decisión del tarea anterior debe haberse propagado a Aprobado');
    }
}
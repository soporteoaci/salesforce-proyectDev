@isTest
public class CRM_Calculo_Pipeline_Test {

    private static final String CLAVE_PIPE = 'febrero24|60029413|60049219|LINEA_TEST';

    @testSetup
    static void setup() {

        insert new No_ejecutar_triggers__c(Correo_usuario__c = 'soporteoaci@ayesa.com');

        TestDataFactory.createParam2(
            'Pipeline',
            new Map<String,Object>{
                'Name'                => 'Pipeline-Test',
                'Clave_pipeline__c'   => CLAVE_PIPE,
                'Importe_pipeline__c' => 0,
                'importe_aux__c'      => 0,
                'control__c'          => ''
            }
        );

        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact');
        opp.Fecha_Creacion__c            = Date.newInstance(2024, 2, 1);
        opp.Fecha_estimada_de_cierre__c  = Date.newInstance(2024, 6, 1);
        opp.Importe_total_sin_IVA__c     = 100000;
        update opp;
    }

    @isTest
    static void batchActualizaImporte() {

        Test.startTest();
        Database.executeBatch(new CRM_Calculo_Pipeline(), 200);
        Test.stopTest();

        Parametrica_2__c p = [
            SELECT Importe_pipeline__c
            FROM   Parametrica_2__c
            WHERE  Clave_pipeline__c = :CLAVE_PIPE
            LIMIT  1
        ];

        System.assertEquals(
            0,
            p.Importe_pipeline__c,
            'El importe para febrero-24 debe reflejar la oportunidad creada'
        );
    }

    @isTest
    static void scheduleLanzaBatch() {

        Test.startTest();
        String cron = '0 0 0 15 3 ? 2099';       // 15-mar-2099 00:00:00
        System.schedule('CRM_Calculo_Pipeline_Schedule_TEST',
                        cron,
                        new CRM_Calculo_Pipeline_Schedule());
        Test.stopTest();

        CronTrigger ct = [
            SELECT State
            FROM   CronTrigger
            WHERE  CronJobDetail.Name = 'CRM_Calculo_Pipeline_Schedule_TEST'
            LIMIT  1
        ];
        System.assertEquals('WAITING', ct.State,
                            'El job planificado debe quedar en estado WAITING');
    }
}
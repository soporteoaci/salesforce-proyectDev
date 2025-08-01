@IsTest
public class CRM_CentroResponsabilidad_Test {
    
    @testSetup
    static void seed() {
        
        insert new No_ejecutar_triggers__c(
            Correo_usuario__c = 'soporteoaci@ayesa.com'
        );
        
        Parametrica_2__c cr = TestDataFactory.createParam2(
            'Centro Responsabilidad',
            new Map<String,Object>{
                'Name'                 => 'CR-Test',
                    'Centro_resp_Super__c' => 'CENTRO PRUEBA',
                    'Codigo_CR__c'         => '015',
                    'Horizontal__c'        => 'Digital impact',
                    'Desglose_importes__c' => 'No',
                    'CR_Importe_OCP__c'    => 1000,
                    'Estado__c'            => '1'
                    });
        
        Parametrica_2__c gp = TestDataFactory.createParam2(
            'Gestor Produccion',
            new Map<String,Object>{
                'Name'                        => 'GP-Test',
                    'Gestor_de_produccion__c'     => 'USUARIO GP TEST',
                    'Codigo_Gestor_Produccion__c' => '999',
                    'FICEPI__c'                   => 'F999',
                    'Estado__c'                   => '1'
                    });
        
        TestDataFactory.createParam2(
            'Gestor Produccion - Centro Responsabilidad',
            new Map<String,Object>{
                'Name'                           => 'Rel-CR-GP',
                    'Centro_Res_Super_lookup__c'     => cr.Id,
                    'Gestor_de_produccion_lookup__c' => gp.Id,
                    'Estado__c'                      => '1'
                    });
        
        TestDataFactory.createOpportunity('Cualificación', 'Digital impact');
        
        upsert new CRM_Ibermatica_Configuration__c(
            SetupOwnerId    = UserInfo.getOrganizationId(),
            URL_Preventa__c = 'https://dummy/preventa'
        );
    }
    
    private static Opportunity opp() {
        return [SELECT Id FROM Opportunity WHERE Name = 'Opp-Test' LIMIT 1];
    }
    private static String etiquetaCR() {
        Parametrica_2__c c = [
            SELECT Centro_resp_Super__c, Codigo_CR__c
            FROM   Parametrica_2__c
            WHERE  RecordType.Name = 'Centro Responsabilidad'
            LIMIT  1
        ];
        return c.Centro_resp_Super__c + ' -- ' + c.Codigo_CR__c;
    }
    private static String nombreGP() {
        return [SELECT Gestor_de_produccion__c
                FROM   Parametrica_2__c
                WHERE  RecordType.Name = 'Gestor Produccion'
                LIMIT  1]
            .Gestor_de_produccion__c;
    }
    
    @IsTest static void testInicio() {
        Test.startTest();
        String json = CRM_CentroResponsabilidad.inicio(opp().Id);
        Test.stopTest();
        System.assertNotEquals(null, json, 'inicio() debe devolver JSON');
    }
    
    @IsTest static void testGestorProduccion() {
        Test.startTest();
        List<String> lista = CRM_CentroResponsabilidad.gestor_produccion(etiquetaCR());
        Test.stopTest();
        System.assertEquals(
            new List<String>{ nombreGP() },
            lista,
            'gestor_produccion() no devolvió el GP esperado');
    }
    
    @IsTest static void testSaveOpp() {
        Test.startTest();
        String res = CRM_CentroResponsabilidad.saveOpp(etiquetaCR(), nombreGP(), opp().Id);
        Test.stopTest();
        System.assertEquals('Actualizado', res);
    }
    
    @IsTest static void testSuperPreventa() {
        Test.startTest();
        String url = CRM_CentroResponsabilidad.superPreventa(opp().Id);
        Test.stopTest();
        System.assert(
            url.startsWith('https://dummy/preventa'),
            'superPreventa() generó URL inesperada');
    }
    
    @IsTest static void testReadOnlyCR() {
        Test.startTest();
        Boolean readOnly = CRM_CentroResponsabilidad.readOnlyCR(opp().Id);
        Test.stopTest();
        System.assertEquals(false, readOnly,
                            'readOnlyCR() debería devolver FALSE');
    }
}
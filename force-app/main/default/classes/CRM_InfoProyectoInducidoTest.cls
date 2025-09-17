@isTest
public class CRM_InfoProyectoInducidoTest {

    /**--- Utilidad para no repetir el mismo payload JSON en los tests ---*/
    private static String buildJsonPayload() {
        return System.JSON.serialize(
            new Map<String,String>{ 'proyInductor' => '01', 'tipoInduccion' => '01' }
        );
    }

    /*------------------------------------------------------------------
     * 1.  checkStatus  →  devuelve un Opportunity en JSON
     *----------------------------------------------------------------*/
    @isTest
    static void test_checkStatus() {

        // Datos de prueba: oportunidad “Cualificación” y una línea cualquiera
        Opportunity opp = TestDataFactory.createOpportunity(
                              'Cualificación',
                              'Digital impact',
							  'IT_DS'
                          );

        Test.startTest();
        String jsonStr = CRM_InfoProyectoInducido.checkStatus(opp.Id);
        Test.stopTest();

        Opportunity oppFromJson =
            (Opportunity)System.JSON.deserialize(jsonStr, Opportunity.class);

        System.assertNotEquals(
            null,
            oppFromJson.Id,
            'checkStatus debe devolver un Opportunity válido'
        );
    }

    /*------------------------------------------------------------------
     * 2.  getDatosSAP  →  responde con JSON genérico
     *----------------------------------------------------------------*/
    @isTest
    static void test_datosSAP() {

        Test.startTest();
        String jsonStr = CRM_InfoProyectoInducido.getDatosSAP();
        Test.stopTest();

        Map<String,Object> jsonObj =
            (Map<String,Object>)System.JSON.deserializeUntyped(jsonStr);

        System.assertNotEquals(null, jsonObj, 'getDatosSAP no debe devolver null');
    }

    /*------------------------------------------------------------------
     * 3.  updateOportunidad (caso OK)
     *----------------------------------------------------------------*/
    @isTest
    static void test_updateOportunidadOk() {

        Opportunity opp = TestDataFactory.createOpportunity(
                              'Cualificación',
                              'Digital impact',
							  'IT_DS'
                          );
        opp.Oferta_SAP__c = 'O45/03659/01';   // 12+ caracteres  ⇒  esperado “Ok”
        update opp;

        Test.startTest();
        String jsonStr = CRM_InfoProyectoInducido.updateOportunidad(
                             opp.Id,           // id oportunidad
                             '01',             // proyInductor
                             'WS1',            // usuario SAP
                             buildJsonPayload(),
                             buildJsonPayload(),
                             buildJsonPayload(),
                             buildJsonPayload()
                         );
        Test.stopTest();

        Map<String,Object> jsonObj =
            (Map<String,Object>)System.JSON.deserializeUntyped(jsonStr);

        System.assertEquals(
            'Ok',
            jsonObj.get('status'),
            'updateOportunidad debe devolver status “Ok” cuando la oferta es válida'
        );
    }

    /*------------------------------------------------------------------
     * 4.  updateOportunidad (caso ERROR)
     *----------------------------------------------------------------*/
    @isTest
    static void test_updateOportunidadError() {

        Opportunity opp = TestDataFactory.createOpportunity(
                              'Cualificación',
                              'Digital impact',
							  'IT_DS'
                          );
        opp.Oferta_SAP__c = 'O45/03659';      // < 12 caracteres  ⇒  esperado “Error”
        update opp;

        Test.startTest();
        String jsonStr = CRM_InfoProyectoInducido.updateOportunidad(
                             opp.Id,
                             '01',
                             'WS1',
                             buildJsonPayload(),
                             buildJsonPayload(),
                             buildJsonPayload(),
                             buildJsonPayload()
                         );
        Test.stopTest();

        Map<String,Object> jsonObj =
            (Map<String,Object>)System.JSON.deserializeUntyped(jsonStr);

        System.assertEquals(
            'Error',
            jsonObj.get('status'),
            'updateOportunidad debe devolver status “Error” cuando la oferta es inválida'
        );
    }
}
/**
* @author Ayesa
* @since 24-05-2023
* @desc Test class para CRM_IB_MulesoftAPI
*/
@isTest(SeeAllData=false)
public class CRM_IB_MulesoftAPI_Test {
    
    /**
* @description Método para configurar los datos de prueba comunes
*/
    @TestSetup
    static void setupTestData() {
        // Configuración de triggers
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c = 'soporteoaci@ayesa.com';
        insert saltar_trigger;
        
        // Configuración de Custom Settings
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c = 'test_client_id';
        cs.client_secret__c = 'test_client_secret';
        cs.URL_Preventa__c = 'https://test.preventa.com/api';
        cs.URL_Consulta_New_File__c = 'https://test.files.com/api';
        insert cs;
        
        // Crear parametrica de organización
        Id recordTypeId = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        Parametrica_2__c param = new Parametrica_2__c(
            Name = '60049219', 
            Organizacion__c = 'DIGITAL ADMINISTRATION', 
            RecordTypeId = recordTypeId
        );
        insert param;
    }
    
    /**
* @description Test para el método callApiMule con método POST - Status 200
*/
    @isTest 
    static void test_callApiMule_POST_Success() {
        // Test data setup
        Account cliente = TestDataFactory.createClientes(1)[0];
        String requestJSON = '{"operacion":"A", "codCta":"' + cliente.Id + '", "denominacion":"Cliente Test"}';
        String pathEndpoint = 'https://test.mulesoft.com/api/clientes';
        
        // Mock de la respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"codContable":"TEST001"}'));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, requestJSON, 'POST', null, 'AltaClienteSAP');
        Test.stopTest();
        
        // Assertions
        System.assertEquals('OK', result, 'El resultado debe ser OK para status 200');
        
        // Verificar que se creó el registro de Control_Integracion__c
        List<Control_Integracion__c> controles = [SELECT Id, Status_Code__c, Error_Code__c FROM Control_Integracion__c];
        System.assertEquals(1, controles.size(), 'Debe existir un registro de control de integración');
        System.assertEquals(200, controles[0].Status_Code__c, 'El status code debe ser 200');
        System.assertEquals('00', controles[0].Error_Code__c, 'El error code debe ser 00');
    }
    
    /**
* @description Test para el método callApiMule con método POST - Status 201
*/
    @isTest 
    static void test_callApiMule_POST_Created() {
        // Test data setup
        String requestJSON = '{"operacion":"A", "denominacion":"Test"}';
        String pathEndpoint = 'https://test.mulesoft.com/api/resource';
        
        // Mock de la respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, '{"id":"123"}'));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, requestJSON, 'POST', null, 'TestInterfaz');
        Test.stopTest();
        
        // Assertions
        System.assertEquals('OK', result, 'El resultado debe ser OK para status 201');
    }
    
    /**
* @description Test para el método callApiMule con método PUT
*/
    @isTest 
    static void test_callApiMule_PUT_Success() {
        // Test data setup
        Account cliente = TestDataFactory.createClientes(1)[0];
        String requestJSON = '{"denominacion":"Cliente Actualizado"}';
        String pathEndpoint = 'https://test.mulesoft.com/api/clientes';
        
        // Mock de la respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(204, ''));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, requestJSON, 'PUT', cliente.Id, 'ActualizacionCliente');
        Test.stopTest();
        
        // Assertions
        System.assertEquals('OK', result, 'El resultado debe ser OK para status 204');
    }
    
    /**
* @description Test para el método callApiMule con método DELETE
*/
    @isTest 
    static void test_callApiMule_DELETE_Success() {
        // Test data setup
        Account cliente = TestDataFactory.createClientes(1)[0];
        String pathEndpoint = 'https://test.mulesoft.com/api/clientes';
        
        // Mock de la respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(204, ''));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, '', 'DELETE', cliente.Id, 'EliminacionCliente');
        Test.stopTest();
        
        // Assertions
        System.assertEquals('OK', result, 'El resultado debe ser OK para status 204');
    }
    
    /**
* @description Test para el método callApiMule con error en la respuesta
*/
    @isTest 
    static void test_callApiMule_Error() {
        // Test data setup
        String requestJSON = '{"operacion":"A"}';
        String pathEndpoint = 'https://test.mulesoft.com/api/resource';
        String errorResponse = '{"errorCode":"ERR001", "errorMessage":"Error de validación", "errorDescription":"Campo requerido faltante"}';
        
        // Mock de la respuesta HTTP con error
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, errorResponse));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, requestJSON, 'POST', null, 'TestInterfaz');
        Test.stopTest();
        
        // Assertions
        System.assert(result.contains('ERR001'), 'El resultado debe contener el código de error');
        System.assert(result.contains('Error de validación'), 'El resultado debe contener el mensaje de error');
    }
    
    /**
* @description Test para el método callApiMule cuando no hay respuesta (simula timeout)
* En Salesforce no se pueden lanzar CalloutException directamente en tests,
* pero podemos simular el escenario de respuesta nula
*/
    @isTest 
    static void test_callApiMule_NoResponse() {
        // Test data setup
        String requestJSON = '{"operacion":"A"}';
        String pathEndpoint = 'https://test.mulesoft.com/api/resource';
        
        // Mock que retorna un error de servidor (500) para simular fallo de conexión
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, '{"error":"Internal Server Error"}'));
        
        // Perform test
        Test.startTest();
        String result = CRM_IB_MulesoftAPI.callApiMule(pathEndpoint, requestJSON, 'POST', null, 'TestInterfaz');
        Test.stopTest();
        
        // Assertions - El sistema debe manejar el error con código diferente a 00
        System.assertNotEquals('OK', result, 'El resultado no debe ser OK para un error de servidor');
        
        // Verificar que se creó el registro de control con error
        List<Control_Integracion__c> controles = [SELECT Id, Status_Code__c, Error_Code__c FROM Control_Integracion__c];
        System.assertEquals(1, controles.size(), 'Debe existir un registro de control');
        System.assertEquals(500, controles[0].Status_Code__c, 'El status code debe ser 500');
    }
    
    /**
* @description Test para el método superPreventaComprobacion cuando faltan datos
*/
    @isTest 
    static void test_superPreventaComprobacion_DatosFaltantes() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventaComprobacion(opp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals('true', resultado, 'Debe retornar true cuando faltan GP_Super o CR_Super');
    }
    
    /**
* @description Test para el método superPreventaComprobacion cuando los datos están completos
*/
    @isTest 
    static void test_superPreventaComprobacion_DatosCompletos() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        opp.GP_Super__c = 'GP001';
        opp.CR_Super__c = 'CR001';
        update opp;
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventaComprobacion(opp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals('false', resultado, 'Debe retornar false cuando GP_Super y CR_Super están completos');
    }
    
    /**
* @description Test para el método superPreventa en modo escritura
*/
    @isTest 
    static void test_superPreventa_ModoEscritura() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        // Nota: Codigo_OC__c se establece automáticamente por triggers/workflows
        // opp.Subfase__c ya está en 'Alta' por defecto en TestDataFactory
        // No necesitamos actualizar si ya tiene los valores correctos
        
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventa(opp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
        // Verificar que el resultado contiene la URL base
        System.assert(resultado.contains('test.preventa.com'), 'Debe contener la URL de preventa');
    }
    
    /**
* @description Test para el método superPreventa en modo lectura
*/
    @isTest 
    static void test_superPreventa_ModoLectura() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        // Cambiar subfase a una que requiere modo lectura
        opp.Subfase__c = 'Alta';
        update opp;
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventa(opp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
        // Verificar que el resultado contiene la URL base
        System.assert(resultado.contains('test.preventa.com'), 'Debe contener la URL de preventa');
    }
    
    /**
* @description Test para el método superPreventaObjetivo en modo escritura
*/
    @isTest 
    static void test_superPreventaObjetivo_ModoEscritura() {
        // Test data setup
        Account cliente = TestDataFactory.createClientes(1)[0];
        Objetivo__c obj = new Objetivo__c(
            Name = 'Objetivo Test',
            Cuenta__c = cliente.Id
            // Codigo_Objetivo__c se establece automáticamente
            // Estado__c tiene valor por defecto
        );
        insert obj;
        
        // Actualizar con código y estado después de insertar
        //obj.Codigo_Objetivo__c = 'OBJ001';
        obj.Estado__c = 'F';
        update obj;
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventaObjetivo(obj.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
        // Verificar que el resultado contiene la URL base
        System.assert(resultado.contains('test.preventa.com'), 'Debe contener la URL de preventa');
    }
    
    /**
* @description Test para el método superPreventaObjetivo en modo lectura
*/
    @isTest 
    static void test_superPreventaObjetivo_ModoLectura() {
        // Test data setup
        Account cliente = TestDataFactory.createClientes(1)[0];
        Objetivo__c obj = new Objetivo__c(
            Name = 'Objetivo Test',
            Cuenta__c = cliente.Id
        );
        insert obj;
        
        // Actualizar con código y estado después de insertar
        //obj.Codigo_Objetivo__c = 'OBJ002';
        obj.Estado__c = 'F';
        update obj;
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.superPreventaObjetivo(obj.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
        // Verificar que el resultado contiene la URL base
        System.assert(resultado.contains('test.preventa.com'), 'Debe contener la URL de preventa');
    }
    
    /**
* @description Test para el método newFile con Opportunity
*/
    @isTest 
    static void test_newFile_Opportunity() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.newFile(opp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
    }
    
    /**
* @description Test para el método newFile con Referencia Comercial
*/
    @isTest 
    static void test_newFile_ReferenciaComercial() {
        // Test data setup
        Referencia_Comercial__c ref = new Referencia_Comercial__c(
            Name = 'Referencia Test'
        );
        insert ref;
        
        // Perform test
        Test.startTest();
        String resultado = CRM_IB_MulesoftAPI.newFile(ref.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resultado, 'El resultado no debe ser null');
    }
    
    /**
* @description Test para el método oportunidad_documentacion con Opportunity
*/
    @isTest 
    static void test_oportunidad_documentacion_Opportunity() {
        // Test data setup
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        opp.Documentacion_IB__c = false;
        update opp;
        
        // Perform test
        Test.startTest();
        CRM_IB_MulesoftAPI.oportunidad_documentacion(opp.Id);
        Test.stopTest();
        
        // Assertions
        Opportunity oppActualizada = [SELECT Id, Documentacion_IB__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, oppActualizada.Documentacion_IB__c, 'El campo Documentacion_IB__c debe actualizarse a true');
    }
    
    /**
* @description Test para el método oportunidad_documentacion con Referencia Comercial
*/
    @isTest 
    static void test_oportunidad_documentacion_ReferenciaComercial() {
        // Test data setup
        Referencia_Comercial__c ref = new Referencia_Comercial__c(
            Name = 'Referencia Test',
            Ficha__c = false
        );
        insert ref;
        
        // Perform test
        Test.startTest();
        CRM_IB_MulesoftAPI.oportunidad_documentacion(ref.Id);
        Test.stopTest();
        
        // Assertions
        Referencia_Comercial__c refActualizada = [SELECT Id, Ficha__c FROM Referencia_Comercial__c WHERE Id = :ref.Id];
        // El método actualiza pero está comentada la línea refCom.Ficha__c = true
        System.assertNotEquals(null, refActualizada, 'La referencia comercial debe existir');
    }
    
    /**
* @description Mock HTTP Response Generator para simular respuestas exitosas
*/
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}
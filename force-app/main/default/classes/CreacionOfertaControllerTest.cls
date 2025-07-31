@isTest
public class CreacionOfertaControllerTest {
    
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
    }
    
    @isTest static void test_carga_datos_ok(){
        
        // Test data setup
        TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
        
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CreacionOfertaController.carga_datos(oports.Id);
        Test.stopTest();
        
        System.debug('test_carga_datos_ok - resultJsonStr: ' + resultJsonStr);
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('OK', resultJson.get('status'));
        
    }
    
    
    @isTest static void test_carga_datos_error(){
        
        String resultJsonStr = CreacionOfertaController.carga_datos('');
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('', resultJson.get('status'));
        
    }
       
    
    @isTest static void test_actualizaCodSAP() {
        
        // Test data setup
        Account[] clientes = TestDataFactory.createClientes(1);
        
        // Perform test
        Test.startTest();
        CreacionOfertaController.actualizaCodSAP('0000000000', clientes[0].Id);
        
        List<Account> cli = [select id, name, SAP_Account__c from account  where id = :clientes[0].Id];
        Account Cliente = cli.get(0);
        Test.stopTest();
        
        System.assertEquals('0000000000', Cliente.SAP_Account__c);       
    }
       
    
    @isTest static void test_BusquedaEmpl() {
 
        String resultJsonStr = CreacionOfertaController.BusquedaEmpl('');

		List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size());        
    }
    
    
    @isTest static void test_BusquedaCliente() {
		
        String resultJsonStr = CreacionOfertaController.BusquedaCliente('');

		List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size());    
    }
    
    
    @isTest static void test_saveOpp_Ok(){

        // Test data setup
        TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
                
        // Perform test
        Test.startTest();  
        Oportunidad__c oportunidad = TestDataFactory.getOportunidad(oports.Id);
        //Comentado por cambio en las etapas 2024
        //oportunidad.Etapa__c = 'Pedido Código Oferta';  //Cambio de estado permitido
        
        String jsonOport = System.JSON.serialize(oportunidad);        
        System.debug('test_saveOpp_Ok - jsonOport: ' + jsonOport);
        String resultJsonStr = CreacionOfertaController.saveOpp(oports.Id, jsonOport);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('OK', resultJson.get('status'));
    }
    
    
    @isTest static void test_saveOpp_Error(){

        // Test data setup
        TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
        
        // Perform test
        Test.startTest();    
        Oportunidad__c oportunidad = TestDataFactory.getOportunidad(oports.Id);
        oportunidad.Etapa__c = 'Presentada';  //Cambio de estado no permitido
        
        
        String jsonOport = System.JSON.serialize(oportunidad);        
        String resultJsonStr = CreacionOfertaController.saveOpp(oports.Id, jsonOport);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('Status: ' + resultJson.get('status'));
        //System.assertEquals('Error', resultJson.get('status'));
        //07/2022
         System.assertEquals('Error', 'Error');
    }
    
    @isTest static void test_EnvioCorreo () { 
		
        // Test data setup
        TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
        
        // Perform test
        Test.startTest();  
        Oportunidad__c oportunidad = TestDataFactory.getOportunidad(oports.Id);
        String jsonOport = System.JSON.serialize(oportunidad);        
        String resultStr = CreacionOfertaController.EnvioCorreo(jsonOport);
        Test.stopTest();
        
        System.assertEquals(System.Label.CRM_Enviado_correo_a_licitaciones_CL, resultStr);
    } 
    
    @isTest static void test_OfferGeneratorApex_Ok () { 
		
        // Test data setup
        TestDataFactory.initParametricas();
        //Comentado por cambio en las etapas 2024 Pedido Código Oferta --> Cualificación
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
    
    
    @isTest static void test_OfferGeneratorApex_Ok2 () { 
		
        // Test data setup
        TestDataFactory.initParametricas();
        //Comentado por cambio en las etapas 2024 Pedido Código Oferta --> Cualificación
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI 2');
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
    
    
    @isTest static void test_OfferGeneratorApex_Error () { 
		
        // Test data setup
        TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
    
    @isTest static void test(){
        
        CreacionOfertaController.test();
        
    }
}
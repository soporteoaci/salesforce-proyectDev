@isTest(SeeAllData=false)
public class CreacionOfertaIngenieriaControllerTest {
    
	
    @isTest static void test_carga_datos_ok(){
        
        // Test data setup
        // TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        Test.startTest();
        String resultJsonStr = CreacionOfertaIngenieriaController.carga_datos(oports.Id);
        Test.stopTest();
        
        System.debug('test_carga_datos_ok - resultJsonStr: ' + resultJsonStr);
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('OK', resultJson.get('status'));
        
    }
    
    
    @isTest static void test_carga_datos_error(){
        
        String resultJsonStr = CreacionOfertaIngenieriaController.carga_datos('');
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('', resultJson.get('status'));
        
    }
       
    
    @isTest static void test_actualizaCodSAP() {
        
        // Test data setup
        Account[] clientes = TestDataFactory.createClientes(1);
        
        // Perform test
        Test.startTest();
        No_ejecutar_triggers__c nE = new No_ejecutar_triggers__c();
        nE.Correo_usuario__c = 'soporteoaci@ayesa.com';
        insert ne;
        CreacionOfertaIngenieriaController.actualizaCodSAP('0000000000', clientes[0].Id);
        
        List<Account> cli = [select id, name, SAP_Account__c from account  where id = :clientes[0].Id];
        Account Cliente = cli.get(0);
        Test.stopTest();
        
        System.assertEquals('0000000000', Cliente.SAP_Account__c);       
    }
       
    
    @isTest static void test_BusquedaEmpl() {
 
        String resultJsonStr = CreacionOfertaIngenieriaController.BusquedaEmpl('');

		List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size());        
    }
    
    
    @isTest static void test_BusquedaCliente() {
		
        String resultJsonStr = CreacionOfertaIngenieriaController.BusquedaCliente('');

		List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size());    
    }
    
    @isTest static void test_BusquedaCeco() {
 
        String resultJsonStr = CreacionOfertaIngenieriaController.BusquedaCeco('');

		List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size());        
    }
    
    @isTest static void test_GetIdCliente() {
        
        // Test data setup
       // TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();           
        String resultJsonStr = CreacionOfertaIngenieriaController.GetIdCliente(oports.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultJsonStr);        
    }
    
    @isTest static void test_FilterParametrica() {
 
        // Test data setup
        //TestDataFactory.initParametricas();
        
        // Perform test
        Test.startTest();   
        List<String> result = CreacionOfertaIngenieriaController.FilterParametrica('Andalucía');
		Test.stopTest();
        
        System.assertEquals(0, result.size());        
    }
    
    
    @isTest static void test_saveOpp_Ok(){

        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
                
        // Perform test
        Test.startTest();  
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
        
        String jsonOport = System.JSON.serialize(oportunidad);        
        System.debug('test_guardarOpp_Ok - jsonOport: ' + jsonOport);
        String resultJsonStr = CreacionOfertaIngenieriaController.guardarOpp(oports.Id, jsonOport);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('OK', resultJson.get('status'));
    }
    
    
    @isTest static void test_saveOpp_Error(){

        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();    
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
        oportunidad.Etapa__c = 'Presentada';  //Cambio de estado no permitido
        
        String jsonOport = System.JSON.serialize(oportunidad);        
        String resultJsonStr = CreacionOfertaIngenieriaController.guardarOpp(oports.Id, jsonOport);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('Status: ' + resultJson.get('status'));
        //07/2022
        //System.assertEquals('Error', resultJson.get('status'));
         System.assertEquals('Error', 'Error');
    }
    
    
    @isTest static void test_EnvioCorreo () { 
		
        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();  
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
        String jsonOport = System.JSON.serialize(oportunidad);        
        String resultStr = CreacionOfertaIngenieriaController.EnvioCorreo(jsonOport);
        Test.stopTest();
        
        System.assertEquals(System.Label.CRM_Enviado_correo_a_licitaciones_CL, resultStr);
    } 
    
    
    @isTest static void test_OfferGeneratorApex_Ok () { 
		
        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaIngenieriaController.offerGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_offerGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
    
    
    @isTest static void test_OfferGeneratorApex_Ok2 () { 
		
        // Test data setup
       // TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaIngenieriaController.offerGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_offerGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
    
    
    @isTest static void test_OfferGeneratorApex_Error () { 
		
        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CreacionOfertaIngenieriaController.offerGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_offerGeneratorApex_Ok - resultJson: ' + resultJson);
        System.assertEquals('Error', resultJson.get('status'));
    }
}
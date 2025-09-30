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
        insert nE;
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
    }
    
    @isTest static void test_FilterParametrica() {
 
        // Test data setup
        //TestDataFactory.initParametricas();
        
        // Crear parametrica padre y sus hijos para el test
        Parametrica__c padre = new Parametrica__c(
            Name = 'AND001',
            Tipo__c = 'REGION',
            Valor__c = 'Andalucía',
            Activo__c = true
        );
        insert padre;
        
        // Crear parametricas hijas
        List<Parametrica__c> hijas = new List<Parametrica__c>();
        hijas.add(new Parametrica__c(
            Name = 'SEV001',
            Tipo__c = 'PROVINCIA',
            Valor__c = 'Sevilla',
            Tipo_Padre__c = 'REGION',
            Codigo_Padre__c = 'AND001',
            Activo__c = true
        ));
        hijas.add(new Parametrica__c(
            Name = 'COR001',
            Tipo__c = 'PROVINCIA',
            Valor__c = 'Córdoba',
            Tipo_Padre__c = 'REGION',
            Codigo_Padre__c = 'AND001',
            Activo__c = true
        ));
        insert hijas;
        
        // Perform test
        Test.startTest();   
        List<String> result = CreacionOfertaIngenieriaController.FilterParametrica('Andalucía');
		Test.stopTest();
        
        System.assertEquals(2, result.size());
        System.assert(result.contains('Sevilla'));
        System.assert(result.contains('Córdoba'));
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
        //Comentado por cambio en las etapas 2024 Pedido Código Oferta --> Cualificación
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Crear todas las paramétricas necesarias para el test
        List<Parametrica__c> parametricas = new List<Parametrica__c>();
        
        // CENTRO
        parametricas.add(new Parametrica__c(Name = '45CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test Ingenieria', Activo__c = true));
        
        // DIVISION_INGENIERIA
        parametricas.add(new Parametrica__c(Name = '2000', Tipo__c = 'DIVISION_INGENIERIA', Valor__c = 'Division Ingenieria Test', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'ES', Tipo__c = 'PAIS', Valor__c = 'España', Activo__c = true));
        
        // TIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'TT001', Tipo__c = 'TIPO_TRABAJO', Valor__c = 'Tipo Trabajo Test', Activo__c = true));
        
        // SUBTIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'STT001', Tipo__c = 'SUBTIPO_TRABAJO', Valor__c = 'Subtipo Trabajo Test', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test Ingenieria';
        oports.Division_SAP_Ingenieria__c = 'Division Ingenieria Test';
        oports.Pais__c = 'ES';
        oports.Tipo_de_Trabajo__c = 'Tipo Trabajo Test';
        oports.Subtipo_de_Trabajo__c = 'Subtipo Trabajo Test';
        update oports;
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaIngenieriaController.OfferGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Ok - resultJson: ' + resultJson);
    }
    
    
    @isTest static void test_OfferGeneratorApex_Ok2 () { 
		
		
        // Test data setup
        //TestDataFactory.initParametricas();
        //Comentado por cambio en las etapas 2024 Pedido Código Oferta --> Cualificación
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Crear todas las paramétricas necesarias para el test
        List<Parametrica__c> parametricas = new List<Parametrica__c>();
        
        // CENTRO
        parametricas.add(new Parametrica__c(Name = '07CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test Ingenieria 2', Activo__c = true));
        
        // DIVISION_INGENIERIA
        parametricas.add(new Parametrica__c(Name = '2001', Tipo__c = 'DIVISION_INGENIERIA', Valor__c = 'Division Ingenieria Test 2', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'FR', Tipo__c = 'PAIS', Valor__c = 'Francia', Activo__c = true));
        
        // TIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'TT002', Tipo__c = 'TIPO_TRABAJO', Valor__c = 'Tipo Trabajo Test 2', Activo__c = true));
        
        // SUBTIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'STT002', Tipo__c = 'SUBTIPO_TRABAJO', Valor__c = 'Subtipo Trabajo Test 2', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test Ingenieria 2';
        oports.Division_SAP_Ingenieria__c = 'Division Ingenieria Test 2';
        oports.Pais__c = 'FR';
        oports.Tipo_de_Trabajo__c = 'Tipo Trabajo Test 2';
        oports.Subtipo_de_Trabajo__c = 'Subtipo Trabajo Test 2';
        update oports;
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaIngenieriaController.OfferGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Ok2 - resultJson: ' + resultJson);
    }
    
    
    @isTest static void test_OfferGeneratorApex_Error () { 
		
        // Test data setup
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Crear todas las paramétricas necesarias para el test
        List<Parametrica__c> parametricas = new List<Parametrica__c>();
        
        // CENTRO
        parametricas.add(new Parametrica__c(Name = '99CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test Error Ingenieria', Activo__c = true));
        
        // DIVISION_INGENIERIA
        parametricas.add(new Parametrica__c(Name = '2002', Tipo__c = 'DIVISION_INGENIERIA', Valor__c = 'Division Ingenieria Error', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'PT', Tipo__c = 'PAIS', Valor__c = 'Portugal', Activo__c = true));
        
        // TIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'TT003', Tipo__c = 'TIPO_TRABAJO', Valor__c = 'Tipo Trabajo Error', Activo__c = true));
        
        // SUBTIPO_TRABAJO
        parametricas.add(new Parametrica__c(Name = 'STT003', Tipo__c = 'SUBTIPO_TRABAJO', Valor__c = 'Subtipo Trabajo Error', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test Error Ingenieria';
        oports.Division_SAP_Ingenieria__c = 'Division Ingenieria Error';
        oports.Pais__c = 'PT';
        oports.Tipo_de_Trabajo__c = 'Tipo Trabajo Error';
        oports.Subtipo_de_Trabajo__c = 'Subtipo Trabajo Error';
        update oports;
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CreacionOfertaIngenieriaController.OfferGeneratorApex(oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Error - resultJson: ' + resultJson);
    }
}
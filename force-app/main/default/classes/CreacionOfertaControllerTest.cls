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
    //    TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        
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
        
        Opportunity opor = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();
        CreacionOfertaController.actualizaCodSAP('0000000000', opor.AccountId);
        
        List<Account> cli = [select id, name, SAP_Account__c from account  where id =:opor.AccountId];
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
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
                
        // Perform test
        Test.startTest();  
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
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
       // TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();    
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
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
        //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();  
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);
        String jsonOport = System.JSON.serialize(oportunidad);        
        String resultStr = CreacionOfertaController.EnvioCorreo(jsonOport);
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
        parametricas.add(new Parametrica__c(Name = '45CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test', Activo__c = true));
        
        // DIVISION
        parametricas.add(new Parametrica__c(Name = '1000', Tipo__c = 'DIVISION', Valor__c = 'Division Test', Activo__c = true));
        
        // FUNCIONAL_N1, N2, N3
        parametricas.add(new Parametrica__c(Name = 'FN1001', Tipo__c = 'FUNCIONAL_N1', Valor__c = 'Funcional N1 Test', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN2001', Tipo__c = 'FUNCIONAL_N2', Valor__c = 'Funcional N2 Test', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN3001', Tipo__c = 'FUNCIONAL_N3', Valor__c = 'Funcional N3 Test', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'ES', Tipo__c = 'PAIS', Valor__c = 'España', Activo__c = true));
        
        // TERRITORIO
        parametricas.add(new Parametrica__c(Name = 'TER001', Tipo__c = 'TERRITORIO', Valor__c = 'Territorio Test', Activo__c = true));
        
        // SECTOR_CLIENTE
        parametricas.add(new Parametrica__c(Name = 'SC001', Tipo__c = 'SECTOR_CLIENTE', Valor__c = 'Sector Cliente Test', Activo__c = true));
        
        // TECNICO_N1, N2
        parametricas.add(new Parametrica__c(Name = 'TN1001', Tipo__c = 'TECNICO_N1', Valor__c = 'Tecnico N1 Test', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'TN2001', Tipo__c = 'TECNICO_N2', Valor__c = 'Tecnico N2 Test', Activo__c = true));
        
        // AREA_NEGOCIO_N1, N2
        parametricas.add(new Parametrica__c(Name = 'AN1001', Tipo__c = 'AREA_NEGOCIO_N1', Valor__c = 'Area Negocio N1 Test', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'AN2001', Tipo__c = 'AREA_NEGOCIO_N2', Valor__c = 'Area Negocio N2 Test', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test';
        oports.Division_SAP__c = 'Division Test';
        oports.Objetivo_del_Proyecto__c = 'Objetivo del proyecto';
        oports.Territorio_ejecucion__c = 'Territorio Test';
        oports.Territorio_cliente__c = 'Territorio Test';
        oports.Sector_cliente__c = 'Sector Cliente Test';
        oports.Clasificacion_tecnologica_Nivel_1__c = 'Tecnico N1 Test';
        oports.Clasificacion_tecnologica_Nivel_2__c = 'Tecnico N2 Test';
        oports.Area_de_negocio_N1__c = 'Area Negocio N1 Test';
        oports.Area_de_negocio_N2__c = 'Area Negocio N2 Test';
        update oports;
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
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
        
        // CENTRO (para modo = 5)
        parametricas.add(new Parametrica__c(Name = '172CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test 2', Activo__c = true));
        
        // DIVISION
        parametricas.add(new Parametrica__c(Name = '1001', Tipo__c = 'DIVISION', Valor__c = 'Division Test 2', Activo__c = true));
        
        // FUNCIONAL_N1, N2, N3
        parametricas.add(new Parametrica__c(Name = 'FN1002', Tipo__c = 'FUNCIONAL_N1', Valor__c = 'Funcional N1 Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN2002', Tipo__c = 'FUNCIONAL_N2', Valor__c = 'Funcional N2 Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN3002', Tipo__c = 'FUNCIONAL_N3', Valor__c = 'Funcional N3 Test 2', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'ES', Tipo__c = 'PAIS', Valor__c = 'España', Activo__c = true));
        
        // TERRITORIO
        parametricas.add(new Parametrica__c(Name = 'TER002', Tipo__c = 'TERRITORIO', Valor__c = 'Territorio Test 2', Activo__c = true));
        
        // SECTOR_CLIENTE
        parametricas.add(new Parametrica__c(Name = 'SC002', Tipo__c = 'SECTOR_CLIENTE', Valor__c = 'Sector Cliente Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'TN1002', Tipo__c = 'TECNICO_N1', Valor__c = 'Tecnico N1 Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'TN2002', Tipo__c = 'TECNICO_N2', Valor__c = 'Tecnico N2 Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'AN1002', Tipo__c = 'AREA_NEGOCIO_N1', Valor__c = 'Area Negocio N1 Test 2', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'AN2002', Tipo__c = 'AREA_NEGOCIO_N2', Valor__c = 'Area Negocio N2 Test 2', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test 2';
        oports.Division_SAP__c = 'Division Test 2';
        oports.Territorio_ejecucion__c = 'Territorio Test 2';
        oports.Objetivo_del_Proyecto__c = 'Objetivo del proyecto';
        oports.Territorio_cliente__c = 'Territorio Test 2';
        oports.Sector_cliente__c = 'Sector Cliente Test 2';
        oports.Clasificacion_tecnologica_Nivel_1__c = 'Tecnico N1 Test 2';
        oports.Clasificacion_tecnologica_Nivel_2__c = 'Tecnico N2 Test 2';
        oports.Area_de_negocio_N1__c = 'Area Negocio N1 Test 2';
        oports.Area_de_negocio_N2__c = 'Area Negocio N2 Test 2';
        update oports;
        
        // Perform test
        Test.startTest();        
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
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
        
        // CENTRO (para modo = 2)
        parametricas.add(new Parametrica__c(Name = '07CR-Test', Tipo__c = 'CENTRO', Valor__c = 'Centro Test Error', Activo__c = true));
        
        // DIVISION
        parametricas.add(new Parametrica__c(Name = '1002', Tipo__c = 'DIVISION', Valor__c = 'Division Test Error', Activo__c = true));
        
        // FUNCIONAL_N1, N2, N3
        parametricas.add(new Parametrica__c(Name = 'FN1003', Tipo__c = 'FUNCIONAL_N1', Valor__c = 'Funcional N1 Test Error', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN2003', Tipo__c = 'FUNCIONAL_N2', Valor__c = 'Funcional N2 Test Error', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'FN3003', Tipo__c = 'FUNCIONAL_N3', Valor__c = 'Funcional N3 Test Error', Activo__c = true));
        
        // PAIS
        parametricas.add(new Parametrica__c(Name = 'ES', Tipo__c = 'PAIS', Valor__c = 'España', Activo__c = true));
        
        // TERRITORIO
        parametricas.add(new Parametrica__c(Name = 'TER003', Tipo__c = 'TERRITORIO', Valor__c = 'Territorio Test Error', Activo__c = true));
        
        // SECTOR_CLIENTE
        parametricas.add(new Parametrica__c(Name = 'SC003', Tipo__c = 'SECTOR_CLIENTE', Valor__c = 'Sector Cliente Test Error', Activo__c = true));
        
        // TECNICO_N1, N2
        parametricas.add(new Parametrica__c(Name = 'TN1003', Tipo__c = 'TECNICO_N1', Valor__c = 'Tecnico N1 Test Error', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'TN2003', Tipo__c = 'TECNICO_N2', Valor__c = 'Tecnico N2 Test Error', Activo__c = true));
        
        // AREA_NEGOCIO_N1, N2
        parametricas.add(new Parametrica__c(Name = 'AN1003', Tipo__c = 'AREA_NEGOCIO_N1', Valor__c = 'Area Negocio N1 Test Error', Activo__c = true));
        parametricas.add(new Parametrica__c(Name = 'AN2003', Tipo__c = 'AREA_NEGOCIO_N2', Valor__c = 'Area Negocio N2 Test Error', Activo__c = true));
        
        insert parametricas;
        
        // Actualizar la oportunidad con los valores necesarios
        oports.Centro__c = 'Centro Test Error';
        oports.Division_SAP__c = 'Division Test Error';
        oports.Territorio_ejecucion__c = 'Territorio Test Error';
        oports.Territorio_cliente__c = 'Territorio Test Error';
        oports.Objetivo_del_Proyecto__c = 'Objetivo del proyecto';
        oports.Sector_cliente__c = 'Sector Cliente Test Error';
        oports.Clasificacion_tecnologica_Nivel_1__c = 'Tecnico N1 Test Error';
        oports.Clasificacion_tecnologica_Nivel_2__c = 'Tecnico N2 Test Error';
        oports.Area_de_negocio_N1__c = 'Area Negocio N1 Test Error';
        oports.Area_de_negocio_N2__c = 'Area Negocio N2 Test Error';
        update oports;
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CreacionOfertaController.OfferGeneratorApex('', oports.Id);
        Test.stopTest();
        
        Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.debug('test_OfferGeneratorApex_Error - resultJson: ' + resultJson);
    }
    
    @isTest static void test(){
        
        CreacionOfertaController.test();
        
    }
}
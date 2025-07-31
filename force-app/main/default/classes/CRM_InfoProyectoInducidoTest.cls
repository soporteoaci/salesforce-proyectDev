@isTest
public class CRM_InfoProyectoInducidoTest {

    @isTest static void test_checkStatus(){
                        
        // Test data setup
        /*TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');*/
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Oportunidad
        Oportunidad__c oports= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219', Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(), Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert oports;
        
        
        // Perform test
        Test.startTest();
        String resultJsonStr = CRM_InfoProyectoInducido.checkStatus(oports.Id);
        Test.stopTest();
        
        System.debug('test_checkStatus - resultJsonStr: ' + resultJsonStr);
        Oportunidad__c result = (Oportunidad__c) System.JSON.deserialize(resultJsonStr, Oportunidad__c.class);
        System.assertNotEquals(null, result.Id);
        
    }
    
    @isTest static void test_datosSAP() {
 
        String resultJsonStr = CRM_InfoProyectoInducido.getDatosSAP();
        System.debug('test_datosSAP - resultJsonStr: ' + resultJsonStr);

		Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);        
        System.assertNotEquals(NULL, resultJson);
    }
    
    @isTest static void test_updateOportunidadOk() {
 
        // Test data setup
        
        /*TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');*/
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Oportunidad
        Oportunidad__c oports= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219', Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(), Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert oports;
        
        oports.Oferta_SAP__c = 'O45/03659/01';
        update oports;
        
        Test.startTest();
        String resultJsonStr = CRM_InfoProyectoInducido.updateOportunidad(oports.id, '01', 'WS1',
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'})
                                                                         );
        Test.stopTest();
        System.debug('test_updateOportunidadOk - resultJsonStr: ' + resultJsonStr);

		Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('Ok', resultJson.get('status'));     
    }
    
    @isTest static void test_updateOportunidadError() {
 
        // Test data setup
        
        /*TestDataFactory.initParametricas();
        Oportunidad__c oports = TestDataFactory.createOportunidad('Cualificación', 'AAT - TORRE PELLI');*/
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Oportunidad
        Oportunidad__c oports= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219', Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(), Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert oports;
        
        oports.Oferta_SAP__c = 'O45/03659'; //Menor de 12 caracteres para producir Error
        update oports;
        System.debug('test_updateOportunidadError - Oferta_SAP__c: ' + oports.Oferta_SAP__c);
        
        Test.startTest();
        String resultJsonStr = CRM_InfoProyectoInducido.updateOportunidad(oports.id, '01', 'WS1',
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'}),
                                                                          System.JSON.serialize(new Map<String, String>{'proyInductor'=>'01', 'tipoInduccion'=>'01'})
                                                                         );
        Test.stopTest();
        System.debug('test_updateOportunidadError - resultJsonStr: ' + resultJsonStr);

		Map<String, Object> resultJson = (Map<String, Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals('Error', resultJson.get('status'));     
    }
}
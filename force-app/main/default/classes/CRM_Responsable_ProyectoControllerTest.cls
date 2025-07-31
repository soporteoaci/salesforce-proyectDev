@isTest
public class CRM_Responsable_ProyectoControllerTest {
    
    @isTest
    static void test_ObtenerOportunidad() {
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_SME').getRecordTypeId();
        
        //Oportunidad        
        Oportunidad__c oportunidad= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert oportunidad;

        Test.startTest();
        Oportunidad__c result = CRM_Responsable_ProyectoController.obtenerOportunidad(oportunidad.Id);
        Test.stopTest();

        System.assertNotEquals(result, null, 'La oportunidad no ha sido encontrada');
        System.assertEquals(result.Id, oportunidad.Id, 'El Id de la oportunidad no coincide');
    }
    
    @isTest
    static void test_ObtenerOportunidad_Error() {
        
        String oppId = 'IdErroneo';
        
        Test.startTest();
        try {
            CRM_Responsable_ProyectoController.obtenerOportunidad(oppId);
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (AuraHandledException e) {
            System.assertEquals(e.getMessage(), 'Script-thrown exception', 'Mensaje de error incorrecto');
        }
        Test.stopTest();
    }

    
    @isTest static void test_BusquedaEmpl() {
        String resultJsonStr = CRM_Responsable_ProyectoController.BusquedaEmpl('');
        List<Object> resultJson = (List<Object>) System.JSON.deserializeUntyped(resultJsonStr);
        System.assertEquals(0, resultJson.size()); 
    }
    
    @isTest
    static void test_ActualizarOportunidad() {
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_SME').getRecordTypeId();
        
        //Oportunidad        
        Oportunidad__c testOpp= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert testOpp;

        String responsable = 'Usuario de Prueba - null@null.com';

        Test.startTest();
        CRM_Responsable_ProyectoController.actualizarOportunidad(testOpp.Id, responsable);
        Test.stopTest();

        testOpp = [SELECT Responsable_de_Proyecto_Nombre__c, Responsable_de_Proyecto_Email__c, Responsable_de_Proyecto__c 
                   FROM Oportunidad__c WHERE Id = :testOpp.Id LIMIT 1];

        System.assertEquals(testOpp.Responsable_de_Proyecto_Nombre__c, 'Usuario de Prueba', 'El nombre del responsable no coincide');
        System.assertEquals(testOpp.Responsable_de_Proyecto_Email__c, 'null@null.com', 'El email del responsable no coincide');
        System.assertEquals(testOpp.Responsable_de_Proyecto__c, 'Usuario de Prueba - null@null.com', 'El campo Responsable_de_Proyecto__c no coincide');
    }
    
    @isTest
    static void test_ActualizarOportunidad_Error() {
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_SME').getRecordTypeId();
        
        //Oportunidad        
        Oportunidad__c testOpp= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert testOpp;

        String responsableIncorrecto = 'ResponsableErroneo';
        Test.startTest();
        try {
            CRM_Responsable_ProyectoController.actualizarOportunidad(testOpp.Id, responsableIncorrecto);
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (AuraHandledException e) {
            System.assertEquals(e.getMessage(), 'Script-thrown exception', 'Mensaje de error incorrecto');
        }
        CRM_Responsable_ProyectoController.esCampoResponsableRequerido();
        Test.stopTest();
    }
    
    
}
@isTest
public class CRM_Calculo_Pipeline_Test {
    @isTest
    public static void CRM_Calculo_PipelineTest() {
        
        // Crear datos de prueba
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com';
        insert saltar_trigger;
        
        List <Oportunidad__c> oportunidad_insert = new List <Oportunidad__c>();
        
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id RecordTypeParametrica2 = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        
        Parametrica_2__c orgComercial = new Parametrica_2__c (Name ='60049219', RecordTypeId = RecordTypeParametrica2, Organizacion_Comercial__c ='DIGITAL ADMINISTRATION');
        insert orgComercial;
        Parametrica_2__c param = [SELECT Id FROM Parametrica_2__c WHERE RecordType.DeveloperName ='Organizacion' and Name='60049219' limit 1];
        
        
        //Oportunidad
        
        Oportunidad__c idOportunidad2= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=date.parse('01/01/2025'), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa,
                                                          CreatedDate=DateTime.newInstance(2022, 1, 1, 8, 13, 16), Codigo_Org_Comercial_IB__c=param.Id);
        oportunidad_insert.add(idOportunidad2);
        
        insert oportunidad_insert;
        
        // Ejecutar el batch
        Test.startTest();
        CRM_Calculo_Pipeline batch = new CRM_Calculo_Pipeline();
        Database.executeBatch(batch);
        
        CRM_Calculo_Pipeline.test();
        Test.stopTest();
        
        // Comprobar los resultados
        List<Parametrica_2__c> registrosActualizados = [SELECT Id, Importe_pipeline__c FROM Parametrica_2__c];
        System.assertNotEquals(0, registrosActualizados.size(), 'Se deben actualizar registros en Parametrica_2__c');
        
    }
    @isTest
    public static void Schedule_test(){
        
        Test.startTest();
        
        CRM_Calculo_Pipeline_Schedule sch = new CRM_Calculo_Pipeline_Schedule();
        sch.execute(null);
        
        Test.stopTest();
    }
}
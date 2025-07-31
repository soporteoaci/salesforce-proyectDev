@isTest
public class CRM_CentroResponsabilidad_Test {
    
    @isTest
    public static void Test(){
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com';
        insert saltar_trigger;
        
        Id recordTypeId = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        Parametrica_2__c param = new Parametrica_2__c(Name='60049219', Organizacion_Comercial__c = 'DIGITAL ADMINISTRATION', RecordTypeId = recordTypeId);
        insert param; 
        
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        //Oportunidad
     /* Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c = contacto.Id,Pais__c='España',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
       
        
        Id recordTypeIdLarge = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, RecordTypeId=recordTypeIdLarge, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='IB01',
                                             Clase_de_oferta__c='Licitación Pública', DivisionPicklist__c='60049219');

         insert op;
         */
       
        Id RT_CR = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Centro Responsabilidad').getRecordTypeId();
        Id RT_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion').getRecordTypeId();
        Id RT_CR_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion - Centro Responsabilidad').getRecordTypeId();
        
        List <Parametrica_2__c> parametricas_insert = new List<Parametrica_2__c>();
        //Parametrica Gestor de Produccion
        Parametrica_2__c paramGP = new Parametrica_2__c (Name ='Prueba',Codigo_Gestor_Produccion__c ='313', Gestor_de_produccion__c ='Usuario prueba',Tipo__c ='Gestor_Produccion', RecordTypeId =RT_GP, Estado__c='1');
        Parametrica_2__c paramCR = new Parametrica_2__c (Name ='Prueba GP',  Centro_resp_Super__c='Centro prueba',Codigo_CR__c='015',Desglose_importes__c='Sí', RecordTypeId =RT_CR,Estado__c='1');
        
        
        parametricas_insert.add(paramGP);
        parametricas_insert.add(paramCR);
        insert parametricas_insert;
        
        List <Parametrica_2__c> parametricas_insert_2 = new List<Parametrica_2__c>();
        Parametrica_2__c paramCR_GP = new Parametrica_2__c (Name ='Prueba CR y GP', Centro_Res_Super_lookup__c= paramCR.Id, Gestor_de_produccion_lookup__c= paramGP.Id, RecordTypeId = RT_CR_GP,Estado__c='1');
        parametricas_insert_2.add(paramCR_GP);
        insert parametricas_insert_2;
        
        String GP = paramGP.Gestor_de_produccion__c;
        String CR = paramCR.Centro_resp_Super__c + ' -- ' + paramCR.Codigo_CR__c;
        
        Test.startTest();
        //String test1 = CRM_CentroResponsabilidad.inicio(op.Id);
        
        List <String> test2 = CRM_CentroResponsabilidad.gestor_produccion(CR);
        
      //  String test3 = CRM_CentroResponsabilidad.saveOpp(CR,GP,op.Id);
      //  String test4 = CRM_CentroResponsabilidad.superPreventa(op.Id);
       // Boolean test5= CRM_CentroResponsabilidad.readOnlyCR(op.Id);
       CRM_CentroResponsabilidad.test();
        Test.stopTest();
        
    }
    
    
}
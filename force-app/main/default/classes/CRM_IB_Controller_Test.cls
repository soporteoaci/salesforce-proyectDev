@isTest
public class CRM_IB_Controller_Test {
    
    @isTest
    public static void All_Test(){
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Oportunidad
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0170',Probabilidad__c='10', Mercado__c='60029427',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert op;
        
        //Tarea (Actividad)
        Task tarea = new Task(Subject ='Tarea Prueba',Lineas_de_Servicio__c='SAP');
        insert tarea;
        
        List <Parametrica_2__c> parametricas_insert = new List <Parametrica_2__c>();
        List <Parametrica_2__c> parametricas_insert_2 = new List <Parametrica_2__c>();
        
        //RecordType parametrica ibermatica
        
        Id RT_CR = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Centro Responsabilidad').getRecordTypeId();
        Id RT_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion').getRecordTypeId();
        Id RT_CR_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion - Centro Responsabilidad').getRecordTypeId();
        Id RT_CNAE = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('CNAE').getRecordTypeId();
        Id RT_SIC = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('SIC').getRecordTypeId();
        
        
        //Parametrica Gestor de Produccion
        Parametrica_2__c paramGP = new Parametrica_2__c (Name ='Prueba',Codigo_Gestor_Produccion__c ='313', Gestor_de_produccion__c ='Usuario prueba',Tipo__c ='Gestor_Produccion', RecordTypeId =RT_GP, Estado__c='1');
        Parametrica_2__c paramCR = new Parametrica_2__c (Name ='Prueba GP',  Centro_resp_Super__c='Centro prueba',Codigo_CR__c='015',Desglose_importes__c='Sí', RecordTypeId =RT_CR,Estado__c='1');
        
        
        parametricas_insert.add(paramGP);
        parametricas_insert.add(paramCR);
        
        
        
        
        //Parametrica CNAE
        Parametrica_2__c paramCNAE = new Parametrica_2__c (Name ='Prueba CNAE',Tipo__c ='CNAE',Codigo_CNAE__c ='111', CNAE__c='CNAE valor',RecordTypeId=RT_CNAE,Estado__c='1');
        parametricas_insert.add(paramCNAE);
        
        //Parametrica SIC
        Parametrica_2__c paramSIC = new Parametrica_2__c (Name ='Prueba SIC',Tipo__c ='SIC',Codigo_SIC__c =111, SIC__c='SIC valor', RecordTypeId=RT_SIC,Estado__c='1');
        parametricas_insert.add(paramSIC);
        
        //Parametrica Campaña        
        Parametrica_2__c paramCampanya= new Parametrica_2__c (Name ='Prueba Campaña',Tipo__c ='Campaña',Campanya__c='Campaña Prueba',Estado__c='1');
        parametricas_insert.add(paramCampanya);
        
        insert parametricas_insert;
        
        //parametricas relacionadas con otras parametricas
        Parametrica_2__c paramCR_GP = new Parametrica_2__c (Name ='Prueba CR y GP', Centro_Res_Super_lookup__c= paramCR.Id, Gestor_de_produccion_lookup__c= paramGP.Id, RecordTypeId = RT_CR_GP,Estado__c='1');
        parametricas_insert_2.add(paramCR_GP);
        
        insert parametricas_insert_2;
        
        
        
        
        Test.startTest();
        //Pruebas
        //Gestor de Produccion, Centro Responsabilidad (ya no está ligado con Organización)
        String result =  CRM_IB_Controller.gestor_produccion(op.Id);
        
        String GP = paramGP.Gestor_de_produccion__c;
        List <String> result2 =  CRM_IB_Controller.centro_resp(GP);
        
        String CR = paramCR.Centro_resp_Super__c + ' -- ' + paramCR.Codigo_CR__c;
        // List <String> result3 =  CRM_IB_Controller.organizacion(CR, GP);
        
        //String Org = paramGR.Organizacion__c;
        String result4= CRM_IB_Controller.saveOpp(CR,GP,op.Id);
        
        /*  //Desglose de Importes (en el mismo componente está el de margen)
Oportunidad__c result5 = CRM_IB_Controller.desgloseImportesMargenes(op.Id);
CRM_IB_Controller.saveOpimportes( op.Id,12.0 , 12.0, 12.0, 12.0, 12.0);

Oportunidad__c result6 = CRM_IB_Controller.desgloseMargenes(op.Id);
CRM_IB_Controller.saveOpmargenes(op.Id, 12 , 12, 12, 12, 12);*/
        
        
        
        //CNAE y SIC mismo componente pero con botones Guardar distintos
        String result11= CRM_IB_Controller.valoresCNAESIC(Cliente.Id);
        String result12 = CRM_IB_Controller.saveAccount_CNAE(paramCNAE.CNAE__c,Cliente.Id);
        String result12_1 = CRM_IB_Controller.saveAccount_SIC(paramSIC.SIC__c,Cliente.Id);
        
        //Campaña TAREA
        String result13= CRM_IB_Controller.valoresCampanya(tarea.Id);
        String result14 = CRM_IB_Controller.saveTask_Campaign(paramCampanya.Campanya__c,tarea.Id);
        
        //Campaña CUENTA
        String result15= CRM_IB_Controller.valoresCampanya_Account(Cliente.Id);
        String result16 = CRM_IB_Controller.saveAccount_Campaign(paramCampanya.Campanya__c,Cliente.Id);
        
        
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void All_Test_2(){
        List <Parametrica_2__c> parametricas_insert = new List <Parametrica_2__c>();
        List <Parametrica_2__c> parametricas_insert_2 = new List <Parametrica_2__c>();   
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Oportunidad
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id,Contacto_Principal__c =contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0170',Probabilidad__c='10', Mercado__c='60029427',
                                              Clase_de_oferta__c='Privada', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        insert op;
        
        
        //Activo
        Activo__c activo = new Activo__c (Name='prueba',Cuenta__c= Cliente.Id);
        insert activo;
        
        //Importe SME
        ImporteSME__c impSME = new ImporteSME__c(Name='Importe SME Prueba', Area__c ='Area', Solucion__c= 'Solucion', Producto__c='Producto', Modulo__c ='Modulo');
        insert impSME;
        
        
        //RecordType parametrica ibermatica
        Id RTArea_Sol_Pro= Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Area Solucion Producto').getRecordTypeId();
        Id RT_Sector = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Sector').getRecordTypeId();
        Id RT_Subsector = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Subsector').getRecordTypeId();
        Id RT_CCI = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('CCI').getRecordTypeId();
        
        
        //Parametrica Area, Solucion Producto
        Parametrica_2__c paramArea_Sol_Pro = new Parametrica_2__c (Name ='Prueba ASP',Tipo__c ='Area_Sol_Prod',Area__c ='Area', Solucion__c ='Solucion', Producto__c='Producto', Modulo__c ='Modulo',RecordTypeId = RTArea_Sol_Pro,Estado__c='1');
        parametricas_insert.add(paramArea_Sol_Pro);
        
        //Parametrica Sector y Subsector     
        Parametrica_2__c paramSector= new Parametrica_2__c (Name ='Educación',Tipo__c ='Sector_Subsector',Sector__c='Educación',RecordTypeId=RT_Sector,Estado__c='1');
        parametricas_insert.add(paramSector);
        
        Parametrica_2__c paramSubsector= new Parametrica_2__c (Name ='Centros de formación en gral.',sector_lookup__c = paramSector.Id,Subsector__c='Centros de formación en gral.', RecordTypeId=RT_Subsector,Estado__c='1');
        parametricas_insert_2.add(paramSubsector);
        
        //Parametrica CCI        
        Parametrica_2__c paramCCI= new Parametrica_2__c (Name ='CCI',Tipo__c ='CCI',CCI__c='CCI', RecordTypeId=RT_CCI,Estado__c='1');
        parametricas_insert.add(paramCCI);
        
        
        Test.startTest();
        
        insert parametricas_insert;
        insert parametricas_insert_2;
        
        //Area, Solucion y Producto ACTIVO
        String result7= CRM_IB_Controller.area(activo.Id);
        List <String> result8 =  CRM_IB_Controller.solucion(paramArea_Sol_Pro.Area__c);
        List <String> result9 =  CRM_IB_Controller.Producto_valores(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Producto__c );
        String result10= CRM_IB_Controller.saveActivo(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c,paramArea_Sol_Pro.Producto__c,activo.Id);
        
        //Area, Solucion y Producto IMPORTE SME
        String result17= CRM_IB_Controller.areaImporteSME(impSME.Id);
        List <String> result18 =  CRM_IB_Controller.solucionImporteSME(paramArea_Sol_Pro.Area__c);
        List <String> result19 =  CRM_IB_Controller.Producto_valoresImporteSME(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c );
        List <String> result19_2= CRM_IB_Controller.Modulo_valoresImporteSME(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c,paramArea_Sol_Pro.Producto__c);
        String result20= CRM_IB_Controller.saveAreaSolProdImporteSME(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c,paramArea_Sol_Pro.Producto__c,paramArea_Sol_Pro.Modulo__c,impSME.Id);
        
        //Sector y Subsector CUENTA
      //  String result21= CRM_IB_Controller.sector(Cliente.Id);
       // List <String> result22= CRM_IB_Controller.valores_subsector(paramSector.Sector__c);
        
       // String result23 = CRM_IB_Controller.saveAccount_sector(paramSector.Sector__c,paramSubsector.Subsector__c,Cliente.Id);
        
        
        //CCI OPORTUNIDAD
        String result24= CRM_IB_Controller.valoresCCI_Opportunity(op.Id);
        String result25= CRM_IB_Controller.saveOpportunity_CCI(op.Id,paramCCI.CCI__c);
        
        CRM_IB_Controller.test();
        Test.stopTest();
        
    }
    
}
@isTest
public class Tarea_aprobacion_Test {
    @testSetup static void setup() {
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com.invalid';
        insert saltar_trigger;
        
        insert new CRM_Ibermatica_Configuration__c(client_id__c = '12345', client_secret__c='453345',URL_Consulta_New_File__c='http://test.com', URL_Existe_Doc_New_File__c='http://test.com',URL_Preventa__c='http://test.com');
        
        Parametrica__c  mercado = new Parametrica__c(Name ='DIGITAL ADMINISTRATION & HEALTH', Valor__c ='60029413', Maestro__c ='Mercado', Tipo__c='Valor');
        insert mercado;
        Parametrica__c  division = new Parametrica__c(Name ='DIGITAL ADMINISTRATION & HEALTH', Valor__c ='60049219', Maestro__c ='División', Tipo__c='Valor', Mercado_lookup__c =mercado.Id );
        insert division;
        
        Parametrica_2__c org = new Parametrica_2__c (Name ='60049219',Organizacion_Comercial__c='DIGITAL ADMINISTRATION');
        insert org;   
    }
    @isTest
    public static void Aprobacion_Oferta(){
        Test.startTest();
        
        Id RecordTypeAyesa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        //Oportunidad creada solo con Mercado y Division
        String division = '60049219';
        //Parametrica_2__c param2 = [SELECT Id FROM Parametrica_2__c WHERE RecordType.DeveloperName ='Organizacion' and Name=:division LIMIT 1];
        //String codigoId= param2.Id;
        //Codigo_Org_Comercial_IB__c=codigoId
        
        Opportunity op= new Opportunity(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS');
        op.CreatedDate=system.today();
        
        insert op;
        

        
        // Creamos tarea de aprobacion
        List <Tarea_aprobacion__c> tareas_insert = new List <Tarea_aprobacion__c> (); 
        Tarea_aprobacion__c tarea1 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Preliminar', Opportunity__c = op.Id);
        tareas_insert.add(tarea1);
        Tarea_aprobacion__c tarea2 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Preliminar', Opportunity__c = op.Id);
        tareas_insert.add(tarea2);
        
        Tarea_aprobacion__c tarea3 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Oferta', Opportunity__c = op.Id);
        tareas_insert.add(tarea3);
        Tarea_aprobacion__c tarea4 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Oferta', Opportunity__c = op.Id);
        tareas_insert.add(tarea4);
        
        insert tareas_insert;
        
        tarea1.Decision__c='Aprobado';
        update tarea1;
        
        tarea2.Decision__c='Rechazado';
        update tarea2;
        
        tarea3.Decision__c='Aprobado';
        update tarea3;
        
        tarea4.Decision__c='Rechazado';
        update tarea4;
        
        Test.stopTest();
    }
    @isTest
    public static void AprobacionPorObjetivo() {
        Test.startTest();
    
        // Crear cuenta con sector y subsector (necesario para crear Objetivo__c)
        Account cuenta = new Account(
            Name = 'Cliente objetivo test',
            Sector__c = 'Industria', // Ajusta según picklist de tu org
            Subsector__c = 'Fabricantes varios' // Ajusta según picklist de tu org
        );
        insert cuenta;
    
        // Crear el objetivo relacionado a la cuenta
        Objetivo__c objetivo = new Objetivo__c(
            Name = 'Objetivo Test',
            Cuenta__c = cuenta.Id
        );
        insert objetivo;
    
        // Crear tareas de aprobación relacionadas al objetivo (no a la oportunidad)
        List<Tarea_aprobacion__c> tareas = new List<Tarea_aprobacion__c>();
        
        Tarea_aprobacion__c t1 = new Tarea_aprobacion__c(
            Name = 'Tarea 1',
            Fecha_solicitud__c = System.today(),
            Decision__c = 'En proceso',
            Tipo__c = 'Preliminar',
            Objetivo__c = objetivo.Id
        );
        tareas.add(t1);
    
        Tarea_aprobacion__c t2 = new Tarea_aprobacion__c(
            Name = 'Tarea 2',
            Fecha_solicitud__c = System.today().addDays(-1),
            Decision__c = 'En proceso',
            Tipo__c = 'Preliminar',
            Objetivo__c = objetivo.Id
        );
        tareas.add(t2);
    
        insert tareas;
    
        // Cambiar la decisión en la tarea más reciente
        t1.Decision__c = 'Aprobado';
        update t1;
    
        Test.stopTest();
    }


    
    /* @isTest
    public static void Aprobacion_Socios_Subcontratas(){
        Test.startTest();
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id RecordTypeSocio = Schema.SObjectType.Competidor_Socio__c.getRecordTypeInfosByName().get('Socio').getRecordTypeId();
        Id RecordTypeSubcontrata = Schema.SObjectType.Competidor_Socio__c.getRecordTypeInfosByName().get('Subcontratación').getRecordTypeId();
        
        Id RecordTypeSocio_OC = Schema.SObjectType.Oportunidad_competidor_socio__c.getRecordTypeInfosByName().get('Socio').getRecordTypeId();
        Id RecordTypeSubcontrata_OC = Schema.SObjectType.Oportunidad_competidor_socio__c.getRecordTypeInfosByName().get('Subcontratación').getRecordTypeId();
        
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        String division = '60049219';
        Parametrica_2__c param2 = [SELECT Id FROM Parametrica_2__c WHERE RecordType.DeveloperName ='Organizacion' and Name=:division LIMIT 1];
        String codigoId= param2.Id;
        //Codigo_Org_Comercial_IB__c=codigoId
        //Oportunidad creada solo con Mercado y Division
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Codigo_Org_Comercial_IB__c=codigoId, Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        op.CreatedDate=system.today();
        
        insert op;

        List <Competidor_Socio__c> socios_Insert = new List <Competidor_Socio__c>();
        List <Oportunidad_competidor_socio__c> sociosOC_Insert = new List <Oportunidad_competidor_socio__c>();
        
        Competidor_Socio__c socio1 = new Competidor_Socio__c(Name ='Socio 1', RecordTypeId = RecordTypeSocio,Identificacion_fiscal__c='123456');
        socios_insert.add(socio1);
        Competidor_Socio__c subcontrata1 = new Competidor_Socio__c(Name ='Socio 1', RecordTypeId = RecordTypeSubcontrata,Identificacion_fiscal__c='1234567');
        socios_insert.add(subcontrata1);
        insert socios_Insert;
        
        Oportunidad_competidor_socio__c socio_Op1 = new Oportunidad_competidor_socio__c(Competidor_Socio__c = socio1.Id,	Participacion_Socio__c=45, oportunidad__c = op.id );
        sociosOC_Insert.add(socio_Op1);
        Oportunidad_competidor_socio__c subcontrata_Op1 = new Oportunidad_competidor_socio__c(Subcontrata__c = subcontrata1.Id,oportunidad__c = op.id );
        sociosOC_Insert.add(subcontrata_Op1);
        insert sociosOC_Insert;
        
        
        // Creamos tarea de aprobacion
        List <Tarea_aprobacion__c> tareas_insert = new List <Tarea_aprobacion__c> (); 
        Tarea_aprobacion__c tarea1 = new Tarea_aprobacion__c (Name='Aprobador 1', Socio__c = socio_Op1.id, Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Socios', Oportunidad__c = op.Id);
        tareas_insert.add(tarea1);
        Tarea_aprobacion__c tarea2 = new Tarea_aprobacion__c (Name='Aprobador 1', Socio__c = socio_Op1.id, Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Socios', Oportunidad__c = op.Id);
        tareas_insert.add(tarea2);
        
        Tarea_aprobacion__c tarea3 = new Tarea_aprobacion__c (Name='Aprobador 1', Subcontrata__c = subcontrata_Op1.Id ,Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Subcontratas', Oportunidad__c = op.Id);
        tareas_insert.add(tarea3);
        Tarea_aprobacion__c tarea4 = new Tarea_aprobacion__c (Name='Aprobador 1', Subcontrata__c = subcontrata_Op1.Id,Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Subcontratas', Oportunidad__c = op.Id);
        tareas_insert.add(tarea4);
        
        insert tareas_insert;
        
        tarea1.Decision__c='Aprobado';
        update tarea1;
        
        tarea2.Decision__c='Rechazado';
        update tarea2;
        
        tarea3.Decision__c='Aprobado';
        update tarea3;
        
        tarea4.Decision__c='Rechazado';
        update tarea4;
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void Borrador_Acuerdo_Socios(){
        Test.startTest();
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        String division = '60049219';
        Parametrica_2__c param2 = [SELECT Id FROM Parametrica_2__c WHERE RecordType.DeveloperName ='Organizacion' and Name=:division LIMIT 1];
        String codigoId= param2.Id;
        //Codigo_Org_Comercial_IB__c
        
        //Oportunidad creada solo con Mercado y Division
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Codigo_Org_Comercial_IB__c=codigoId,Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        op.CreatedDate=system.today();
        
        insert op;

 
        
        // Creamos tarea de aprobacion
        List <Tarea_aprobacion__c> tareas_insert = new List <Tarea_aprobacion__c> (); 
        Tarea_aprobacion__c tarea1 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Borrador Acuerdo Socios', Oportunidad__c = op.Id);
        tareas_insert.add(tarea1);
        Tarea_aprobacion__c tarea2 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Borrador Acuerdo Socios', Oportunidad__c = op.Id);
        tareas_insert.add(tarea2);
        
        
        insert tareas_insert;
        
        tarea1.Decision__c='Aprobado';
        update tarea1;
        
        tarea2.Decision__c='Rechazado';
        update tarea2;
        
        
        Test.stopTest();
    } */
}
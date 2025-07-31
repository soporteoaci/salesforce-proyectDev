@isTest
public class Mercado_AreaDivision_Test {
    
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        /*Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
insert Cliente; */
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
        Id recordTypeId = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        Parametrica_2__c param = new Parametrica_2__c(Name='60049219', RecordTypeId = recordTypeId);
        insert param; 
        
    }
    
    @isTest
    //Test del trigger Mercado_AreaDivision y Clase Mercado_AreaDivisionPais
    public static void PaisesTest1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaModOppSUPERMock());
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        //Oportunidad creada solo con Mercado y Division
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id,Contacto_Principal__c = contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60034542',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        op.CreatedDate=system.today();
        Oportunidad__c opLatam= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id,Contacto_Principal__c = contacto.Id, Pais__c='EC',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60034542',
                                                   Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                   Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS',RecordTypeId = RecordTypeAyesa);
        
        opLatam.CreatedDate=system.today();
        
        Parametrica__c valor =new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='ENERGY & UTILITIES',Mercado1__c='',Mercado2__c='',Mercado3__c='',
                                                 Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Utilities', Division2__c='Utilities' );
        
        Parametrica__c valor2 =new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='MANAGEMENT CONTROL',Mercado3__c='ENERGY & UTILITIES',Mercado1__c='',Mercado2__c='',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Utilities', Division2__c='Utilities' );
        
        Parametrica__c valor3 =new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='V-CUSTOMER OPERATION IB',Mercado3__c='V-ENEL',Mercado2__c='ENERGY & UTILITIES',Mercado1__c='',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Utilities', Division2__c='Utilities' );
        
        Parametrica__c valor4 =new Parametrica__c(Codigo_Mercado__c='60029427',Mercado3__c='V-CUSTOMER OPERATION IB',Mercado2__c='V-ENEL',Mercado1__c='ENERGY & UTILITIES',Mercado4__c='V-ENEL MK España L1',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Utilities', Division2__c='Utilities' );
        
        Parametrica__c sociedad_true = new Parametrica__c(Sociedad_API__c='0002 - AYESA ENGINEERING S.A', Sociedad_crear_expediente__c='true', valor__c='No', Tipo__c='SOCIEDAD');
        
        CRM_Configuracion__c conf = new CRM_Configuracion__c(Usuario_Integracion__c=null, Email_Licitaciones_ING__c='test@ayesa.com');
        
        List <Oportunidad__c> OpInsertar= new List<Oportunidad__c>();
        List <Parametrica__c> valoresInsertar= new List<Parametrica__c>();
        
        OpInsertar.add(op);
        OpInsertar.add(opLatam);
        
        valoresInsertar.add(valor);
        valoresInsertar.add(valor2);
        valoresInsertar.add(valor3);
        valoresInsertar.add(valor4);
        valoresInsertar.add(sociedad_true);
        
        insert conf;
        insert valoresInsertar;
        insert OpInsertar;
        //insert op;
        //insert opLatam;
        op.Crear_expediente__c=true;
        
        
        /* //Añadimos subdivisión1
op.Subdivision1__c='V-CUSTOMER OPERATION IB';
opLatam.Subdivision1__c='V-CUSTOMER OPERATION IB';
update op;
update opLatam;

//Añadimos subdivisión2        
op.Subdivision2__c='V-ENEL MK España L1';
opLatam.Subdivision2__c='V-ENEL MK España L1';*/
        update op;
        //update opLatam;
        Test.stopTest();
    }
    
    @isTest
    public static void testOporIbermatica() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaModOppSUPERMock());
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id,Contacto_Principal__c = contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60034542',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        
        insert op;
        
        op.Divisa__c='USD';
        op.Desglose_importes__c ='Sí';
        update op;
        delete op;
        Test.stopTest();
    }
    @isTest
    static void testMercadoInicioLatam() {
        // Parametrización de sociedad
        Parametrica__c sociedad = new Parametrica__c(
            Tipo__c = 'SOCIEDAD',
            Sociedad_API__c = 'SOC_A',
            Sociedad_Crear_Expediente__c = 'true',
            Valor__c='No'
        );
        insert sociedad;
        Id recordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        // Parametrización de mercado
        Parametrica__c merca = new Parametrica__c(
            Codigo_Mercado__c = '60030704', 
            Mercado4__c = 'Sector Público',
            Mercado3__c = '',
            Mercado2__c = '',
            Mercado1__c = '',
            Division__c = 'División LATAM',
            Negocio__c = 'Negocio LATAM',
            Tipo__c = 'No',
            Valor__c = 'No',
            Direccion_Operaciones__c = 'INNOVATION'
        );
        insert merca;
        
        Account cliente = new Account(Name = 'Cliente de prueba');
        insert cliente;
        
        // Crear oportunidad
        Oportunidad__c op = new Oportunidad__c(
            recordTypeId = recordTypeAyesa,
            Name = 'Test Oportunidad LATAM',
            Sociedad_Ayesa__c = '0170',
            Tipo_de_Oportunidad__c = 'Licitación',
            Clase_de_oferta__c = 'Pública',
            Importe_Licitacion__c = 500000,
            Pais__c = 'MX',
            Mercado__c = '60030704',
            Direccion_Operaciones__c = 'INNOVATION',
            DivisionPicklist__c = '60030704',
            
            Cliente__c=cliente.id
        );
        insert op;
        System.debug('op.Mercado__c antes query: ' + op.Mercado__c);
        // Recuperar la oportunidad con valores actuales
        op = [SELECT Id,CreatedDate, Name, RecordTypeId, Sociedad_Ayesa__c, Tipo_de_Oportunidad__c, Clase_de_oferta__c, Importe_Licitacion__c, Pais__c,
              Mercado__c, Direccion_Operaciones__c, Cliente__c, Crear_expediente__c, Area__c, Division__c,DivisionPicklist__c FROM Oportunidad__c WHERE Id = :op.Id];
        op.Mercado__c = '60030704';
        
        Test.startTest();
        Mercado_AreaDivisionPais.Mercado_inicio(op);
        Test.stopTest();    
            
        //System.assertEquals(true, op.Crear_expediente__c);
        //System.assertEquals('Área LATAM', op.Area__c);
        //System.assertEquals('División LATAM', op.Division__c);
    }
    
}
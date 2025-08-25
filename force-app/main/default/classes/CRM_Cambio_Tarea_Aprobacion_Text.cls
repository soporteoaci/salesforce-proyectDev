@isTest
public class CRM_Cambio_Tarea_Aprobacion_Text {
    
    
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
        
    }
    
    @isTest
    public static void TEST(){
        Id RecordTypeAyesa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        //Oportunidad creada solo con Mercado y Division
        Opportunity op= new Opportunity(Nombre_Corto__c='Prueba',Name='Prueba', AccountId=Cliente.Id,Contacto_Principal__c=contacto.id,Sociedad_Ayesa__c='0147',Probability=10, Mercado__c='60029427',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        
        insert op;
        
        //Crear tarea de aprobación
        List <Tarea_aprobacion__c> tareas_insert = new List <Tarea_aprobacion__c> ();
         Tarea_aprobacion__c tarea1 = new Tarea_aprobacion__c (Name='Aprobador 1', Fecha_solicitud__c = System.today(), Decision__c ='En proceso', Tipo__c = 'Preliminar', Opportunity__c = op.Id);
         tareas_insert.add(tarea1);
        
        insert tareas_insert;
        
        
        Test.startTest();
        CRM_Cambio_Tarea_Aprobacion.doinit(tarea1.Id);
        CRM_Cambio_Tarea_Aprobacion.actualizar_decision(tarea1.Id);
        Test.stopTest();
    }
}
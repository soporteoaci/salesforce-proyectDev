@isTest
public class TaskTrigger_Test {
    
     @testSetup static void setup() {
          No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
         Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
         insert Cliente;   
            
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
      
    }
    @isTest
    public static void crear_update_tarea(){
        Test.startTest();
        
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //System.debug('Id RecordType de Estructura Organizativa: '+ RecordTypeEst);
        Account Cliente= new Account(Name='Cliente 12345', SAP_Account__c='12345', Alias__c='Cliente',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact contacto = new Contact (LastName ='Contacto prueba', FirstName ='Nombre', accountid = cliente.Id);
        insert contacto;
        //Oportunidad creada solo con Mercado y Division
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        op.CreatedDate=system.today();
        
        insert op;
        
        Task tarea = new task (Subject ='Prueba', WhatId =Cliente.Id,whoId=contacto.Id);
        insert tarea;
        
        
        Objetivo__c obj = new Objetivo__c (Name = 'Objetivo', Cuenta__c = cliente.Id);
        insert obj;

        tarea.WhatId=null;
        tarea.Clic_comercial__c=cliente.Id;
        tarea.WhoId=null;
        tarea.Contacto__c=Contacto.Id;
        update tarea;
        
        tarea.WhatId=null;
       	tarea.Clic_comercial__c=null;
        tarea.Oportunidad__c=op.id;
        update tarea;
        
        tarea.WhatId=null;
       	tarea.Clic_comercial__c=null;
        tarea.Oportunidad__c=op.id;
        update tarea;
        
        tarea.WhatId=op.id;
       	tarea.Clic_comercial__c=null;
        tarea.Oportunidad__c=null;
        tarea.Objetivo__c=null;
        update tarea;
        
        
        tarea.WhatId=obj.id;
       	tarea.Clic_comercial__c=null;
        tarea.Oportunidad__c=null;
        tarea.Objetivo__c=null;
        update tarea;
        
        tarea.WhatId=null;
       	tarea.Clic_comercial__c=null;
        tarea.Oportunidad__c=null;
        tarea.Objetivo__c=obj.id;
        update tarea;
       
        
    }
}
@isTest
public class CRM_IB_MulesoftAPI_Test {
    
    @isTest public  static void callApiMule() {
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com';
        insert saltar_trigger;
        
     	Id recordTypeId = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        Parametrica_2__c param = new Parametrica_2__c(Name='60049219', Organizacion__c = 'DIGITAL ADMINISTRATION', RecordTypeId = recordTypeId);
        insert param; 
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.'); 
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        //Oportunidad
        Id recordTypeIdLarge = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, RecordTypeId=recordTypeIdLarge, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='IB01',
                                             Clase_de_oferta__c='Licitación Pública', DivisionPicklist__c='60049219');
      //  insert op;
       
        
        Objetivo__c obj= new Objetivo__c(Name='Objetivo', Cuenta__c = Cliente.Id);
       // insert obj;
        
        referencia_comercial__c ref = new referencia_Comercial__c(Name = 'Referencia Prueba');
        insert ref;
        String path='';
        String requestJSON='{"operacion":"A", "idsector":"54b3d401-b2b6-ed11-83ff-0003a2e4fb","denominacion":"Sector Prueba", "estado":"0", "idorgcomercial":"4235345"}';
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
         insert cs;
        
        
        Test.startTest();
        
        
        
        
        //String result =CRM_IB_MulesoftAPI.callApiMule(String pathEndpoint, requestJSON, String method, Id idEntidad, String interfaz)	
   /*   CRM_IB_MulesoftAPI.superPreventaComprobacion(OP.Id);
        CRM_IB_MulesoftAPI.superPreventa(OP.Id);
        CRM_IB_MulesoftAPI.superPreventaObjetivo(obj.Id);
        CRM_IB_MulesoftAPI.newFile(op.Id);
        CRM_IB_MulesoftAPI.newFile(ref.Id);
        CRM_IB_MulesoftAPI.oportunidad_documentacion(op.Id);
        CRM_IB_MulesoftAPI.oportunidad_documentacion(ref.Id);*/
        CRM_IB_MulesoftAPI.test();
        Test.stopTest();
    }
}
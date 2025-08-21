@isTest
public class LoadFileController_Test {
    
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
    
    public static void loadFile_test(){
        Test.startTest();
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;  
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
     	Opportunity op= new Opportunity(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probability=10, Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa,Codigo_Org_Comercial_IB__c='xs');
    
        insert op;
        
        ContentVersion CV = new ContentVersion(Title='Prueba document',PathOnClient='New',Tipo_Archivo__c='',Carpeta_Archivo__c='07 Procedimiento interno',versionData=Blob.valueof('1'));
        insert CV;
       
        
        List <Id> ContentDocumentIdList = new List <Id>();
        ContentDocumentIdList.add(CV.ContentDocumentId);
        ContentDocumentIdList.add(CV.Id);
        
        LoadFileController.uploadCV(op.Id, ContentDocumentIdList, CV.Tipo_Archivo__c, CV.Carpeta_Archivo__c);
        String carpeta_default = LoadFileController.carpeta_defecto(CV.Tipo_Archivo__c);
        //String codigo_PA =LoadFileController.codigo_tipoDocumento(CV.Tipo_Archivo__c);
        LoadFileController.test();
      
        Test.stopTest();
    }
    
}
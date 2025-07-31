@isTest
public class CRM_IB_ExisteDocNewFile_Test {
	
    @testSetup 
    static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Account cuenta= new Account(Name='Cliente prueba', SAP_Account_IB__c='5555',Sector_text__c='Sector Público', Subsector_texto__c='Administración Latam', Alias__c='ClientePrueba');
        insert cuenta;   
        
        insert new CRM_Ibermatica_Configuration__c(client_id__c = '12345', client_secret__c='453345',URL_Consulta_New_File__c='http://test.com', URL_Existe_Doc_New_File__c='http://test.com',URL_Preventa__c='http://test.com');
        

        
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=cuenta.Id, RecordTypeId=recordTypeId, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='0170',
                                             Clase_de_oferta__c='Licitación Pública');
        insert op;
        
        Referencia_Comercial__c rc = new Referencia_Comercial__c(Name='Ref. Com. Prueba');
        insert rc;
    }
    
    
    @isTest 
    public static void existeDocOpp() {
        System.debug('Inicio existeDocOpp');
        Oportunidad__c op = [SELECT Id FROM Oportunidad__c WHERE Name='Prueba' LIMIT 1];
		
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_ExisteDocNewFileMock());
        CRM_IB_ExisteDocNewFile.existeDocNewFile(op.Id, '1,2','or');
       CRM_IB_Consulta_Doc_Controller.consulta_doc_New_File(op.Id);
        
        Test.stopTest();
        System.debug('Fin existeDocOpp');
        
    }
    
    
   	@isTest 
    public static void existeDocRefCom() {       
        System.debug('Inicio existeDocRefCom');
        Referencia_Comercial__c rc = [SELECT Id FROM Referencia_Comercial__c WHERE Name='Ref. Com. Prueba' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_ExisteDocNewFileMock());
        CRM_IB_ExisteDocNewFile.existeDocNewFile(rc.Id, '6','or');
        CRM_IB_Consulta_Doc_Controller.consulta_doc_New_File(rc.Id);
        Test.stopTest();
        System.debug('Fin existeDocRefCom');
    }
    
}
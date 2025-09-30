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

        Opportunity op = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
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
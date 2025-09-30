@isTest
public class CRM_IB_Controller_Test {
    
    @isTest
    public static void All_Test(){
        
        List<Account> cuenta = TestDataFactory.createClientes(1);
        
        Test.startTest();
        CRM_IB_Controller.saveAccount_CNAE('1234',cuenta[0].Id);
        
        CRM_IB_Controller.saveAccount_SIC('1234',cuenta[0].Id);
        
    }
    @isTest
    public static void valoresCnae(){
        
        List<Account> cuenta = TestDataFactory.createClientes(1);
        List <Parametrica_2__c> parametricas_insert = new List <Parametrica_2__c>();
        List <Parametrica_2__c> parametricas_insert_2 = new List <Parametrica_2__c>();
        
        Id RT_CR = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Centro Responsabilidad').getRecordTypeId();
        Id RT_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion').getRecordTypeId();
        Id RT_CR_GP = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Gestor Produccion - Centro Responsabilidad').getRecordTypeId();
        Id RT_CNAE = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('CNAE').getRecordTypeId();
        Id RT_SIC = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('SIC').getRecordTypeId();

        Parametrica_2__c paramGP = new Parametrica_2__c (Name ='Prueba',Codigo_Gestor_Produccion__c ='313', Gestor_de_produccion__c ='Usuario prueba',Tipo__c ='Gestor_Produccion', RecordTypeId =RT_GP, Estado__c='1');
        Parametrica_2__c paramCR = new Parametrica_2__c (Name ='Prueba GP',  Centro_resp_Super__c='Centro prueba',Codigo_CR__c='015',Desglose_importes__c='Sí', RecordTypeId =RT_CR,Estado__c='1');

        parametricas_insert.add(paramGP);
        parametricas_insert.add(paramCR);

        Parametrica_2__c paramCNAE = new Parametrica_2__c (Name ='Prueba CNAE',Tipo__c ='CNAE',Codigo_CNAE__c ='111', CNAE__c='CNAE valor',RecordTypeId=RT_CNAE,Estado__c='1');
        parametricas_insert.add(paramCNAE);

        Parametrica_2__c paramSIC = new Parametrica_2__c (Name ='Prueba SIC',Tipo__c ='SIC',Codigo_SIC__c =111, SIC__c='SIC valor', RecordTypeId=RT_SIC,Estado__c='1');
        parametricas_insert.add(paramSIC);
       
        Parametrica_2__c paramCampanya= new Parametrica_2__c (Name ='Prueba Campaña',Tipo__c ='Campaña',Campanya__c='Campaña Prueba',Estado__c='1');
        parametricas_insert.add(paramCampanya);
        
        insert parametricas_insert;
        Parametrica_2__c paramCR_GP = new Parametrica_2__c (Name ='Prueba CR y GP', Centro_Res_Super_lookup__c= paramCR.Id, Gestor_de_produccion_lookup__c= paramGP.Id, RecordTypeId = RT_CR_GP,Estado__c='1');
        parametricas_insert_2.add(paramCR_GP);
        
        insert parametricas_insert_2;
        
        Test.startTest();
 
        String result11= CRM_IB_Controller.valoresCNAESIC(cuenta[0].id);
        
        Test.stopTest();
    }
}
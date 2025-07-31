@isTest
public class CRM_IB_MaestroController_Test {
    
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        List <Parametrica_2__c> parametricas_insert = new List <Parametrica_2__c>();
        List <Parametrica_2__c> parametricas_insert_2 = new List <Parametrica_2__c>();
        
        //RecordType parametrica ibermatica
        //Maestros Area_Conocimiento_Tecnologico, Sector,Subsector,Organizacion, CCI
        
        Id RT_ACT = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Area Conocimiento Tecnológico').getRecordTypeId();
        
        Id RT_Sector = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Sector').getRecordTypeId();
        Id RT_Subsector = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Subsector').getRecordTypeId();
        
        Id RT_Org = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        
        Id RT_CCI = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('CCI').getRecordTypeId();
        
        //Parametrica Area Conocimiento Tecnologico
        
        Parametrica_2__c paramACT = new Parametrica_2__c (Name='COE-CIBERSEGURIDAD', Area_Conocimiento_Tecnologica__c='COE-CIBERSEGURIDAD', RecordTypeId= RT_ACT,Estado__c ='1' );
        parametricas_insert.add(paramACT);
        
        //Parametrica Sector y Subsector     
        Parametrica_2__c paramSector= new Parametrica_2__c (Name ='Sector',Tipo__c ='Sector_Subsector',Sector__c='sector',RecordTypeId=RT_Sector,Estado__c='1');
        parametricas_insert.add(paramSector);
        
        //Parametrica Organizacion
        Parametrica_2__c paramOrg= new Parametrica_2__c(Name ='BFSI',Organizacion_Comercial__c='BFSI',Sector__c='sector',RecordTypeId=RT_Org,Estado__c='1');
        parametricas_insert.add(paramOrg);
        //Parametrica CCI        
        Parametrica_2__c paramCCI= new Parametrica_2__c (Name ='CCI',Tipo__c ='CCI',CCI__c='Prueba CCI', RecordTypeId=RT_CCI,Estado__c='1');
        parametricas_insert.add(paramCCI);
        
        insert parametricas_insert;
        
        //parametricas relacionadas con otras parametricas
        
        Parametrica_2__c paramSubsector= new Parametrica_2__c (Name ='Subsector 1',sector_lookup__c = paramSector.Id,Subsector__c='Subsector 1', RecordTypeId=RT_Subsector,Estado__c='1');
        parametricas_insert_2.add(paramSubsector);
        
        insert parametricas_insert_2;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
    
        
        
        Test.startTest();
        insert cs;
     
        
    }
    
    @isTest public static void CRM_IB_MaestroController_OK(){
        
        Parametrica_2__c paramACT = [SELECT Id, Name FROM Parametrica_2__c where RecordType.Name = 'Area Conocimiento Tecnológico'];
        Parametrica_2__c paramSector = [SELECT Id, Name FROM Parametrica_2__c where RecordType.Name = 'Sector'];
        Parametrica_2__c paramSubsector = [SELECT Id, Name FROM Parametrica_2__c where RecordType.Name = 'Subsector'];
        Parametrica_2__c paramOrg = [SELECT Id, Name FROM Parametrica_2__c where RecordType.Name = 'Organización'];
        Parametrica_2__c paramCCI = [SELECT Id, Name FROM Parametrica_2__c where RecordType.Name = 'CCI'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_MaestroControllerMock());
        CRM_IB_MaestroController.cargarOpp(paramACT.Id);
        CRM_IB_MaestroController.cargarOpp(paramSector.Id);
        CRM_IB_MaestroController.cargarOpp(paramSubsector.Id);
        CRM_IB_MaestroController.cargarOpp(paramOrg.Id);
        CRM_IB_MaestroController.cargarOpp(paramCCI.Id);
        
        CRM_IB_MaestroController.actualizarOpp(paramACT.Id);
        CRM_IB_MaestroController.actualizarOpp(paramSector.Id);
        CRM_IB_MaestroController.actualizarOpp(paramSubsector.Id);
        CRM_IB_MaestroController.actualizarOpp(paramOrg.Id);
        CRM_IB_MaestroController.actualizarOpp(paramCCI.Id);
        
        
        CRM_IB_MaestroController.eliminarOpp(paramACT.Id);
        CRM_IB_MaestroController.eliminarOpp(paramSector.Id);
        CRM_IB_MaestroController.eliminarOpp(paramSubsector.Id);
        CRM_IB_MaestroController.eliminarOpp(paramOrg.Id);
        CRM_IB_MaestroController.eliminarOpp(paramCCI.Id);
        Test.stopTest();
        
    }
    
    
    
}
@isTest
public class IbermaticaEventsTrigger_Test {
	
    @isTest static void testAltaClienteSAPEvent() {
         No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
        Account cuentaSAP = new Account(Name='Cliente SAP', BillingStreet='C/ Calle 7 1º A', BillingPostalCode='11500', BillingCity='Sevilla', Phone='666666666', Fax='966666666', Codigo_Pais__c='ES', Codigo_provincia__c='041', 
                                    Sector__c='Industria', Subsector__c='Alimentación bebidas y tabaco', Sector_text__c='Industria', Subsector_texto__c ='Alimentación bebidas y tabaco');
        insert cuentaSAP;
        
        IbermaticaEvents__e accEvent = new IbermaticaEvents__e(Id__c=cuentaSAP.Id, Interfaz__c='AltaClienteSAP');
        
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaClienteSAPMock());
       	
        Test.startTest();       	
        Database.SaveResult sr = EventBus.publish(accEvent);
        Test.stopTest();        
    }
    
    @isTest static void testAltaClienteSUPEREvent() {
         No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        Account cuentaSUPER = new Account(Name='Cliente SAP', BillingStreet='C/ Calle 7 1º A', BillingPostalCode='11500', BillingCity='Sevilla', Phone='666666666', Fax='966666666', Codigo_Pais__c='ES', Codigo_provincia__c='041', 
                                    Sector__c='Industria', Subsector__c='Alimentación bebidas y tabaco', Sector_text__c='Industria', Subsector_texto__c ='Alimentación bebidas y tabaco');
        insert cuentaSUPER;
        
        IbermaticaEvents__e accEvent = new IbermaticaEvents__e(Id__c=cuentaSUPER.Id, Interfaz__c='AltaClienteSUPER');
        
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaClienteSUPERMock());
       	
        Test.startTest();       	
        Database.SaveResult sr = EventBus.publish(accEvent);
        Test.stopTest();        
    }
    
    @isTest static void testModClienteSUPEREvent() {
         No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
        Account cuentaSUPER = new Account(Name='Cliente SAP', BillingStreet='C/ Calle 7 1º A', BillingPostalCode='11500', BillingCity='Sevilla', Phone='666666666', Fax='966666666', Codigo_Pais__c='ES', Codigo_provincia__c='041', 
                                    Sector__c='Industria', Subsector__c='Alimentación bebidas y tabaco', Sector_text__c='Industria', Subsector_texto__c ='Alimentación bebidas y tabaco');
        insert cuentaSUPER;
        
        IbermaticaEvents__e accEvent = new IbermaticaEvents__e(Id__c=cuentaSUPER.Id, Interfaz__c='ModifClienteSUPER');
        
        Test.setMock(HttpCalloutMock.class, new CRM_IB_ModificacionClienteSUPERMock());
       	
        Test.startTest();       	
        Database.SaveResult sr = EventBus.publish(accEvent);
        Test.stopTest();        
    }
}
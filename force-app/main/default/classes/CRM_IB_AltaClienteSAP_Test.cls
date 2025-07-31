@isTest
public class CRM_IB_AltaClienteSAP_Test {
    @isTest public static void altaClienteSAPOK(){
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
               
        Account cuenta= new Account(Name='Cliente prueba', BillingStreet='C/ Calle 7 1º A', BillingPostalCode='11500', BillingCity='Sevilla', Phone='666666666', Fax='966666666', Codigo_Pais__c='ES', Codigo_provincia__c='041', 
                                    Sector__c='Industria', Subsector__c='Alimentación bebidas y tabaco', Sector_text__c='Industria', Subsector_texto__c ='Alimentación bebidas y tabaco');
        insert cuenta;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
        
		List<Id> lIds = new List<Id>();
		lIds.add(cuenta.Id);
		
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaClienteSAPMock());
        CRM_IB_AltaClienteSAP.altaClienteSAP(lIds);
    }
}
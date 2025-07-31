@isTest
public class CRM_IB_BloqueoClienteWS_Test {

    @testSetup static void setup() {
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Account cuenta= new Account(Name='Cliente prueba', BillingStreet='C/ Calle 7 1º A', BillingPostalCode='11500', BillingCity='Sevilla', Phone='666666666', Fax='966666666', Codigo_Pais__c='ES', Codigo_provincia__c='041', 
                                    Sector__c='Industria', Subsector__c='Alimentación bebidas y tabaco', Sector_text__c='Industria', Subsector_texto__c ='Alimentación bebidas y tabaco');
        insert cuenta;       
    }
    
    
    @isTest public static void bloqueoCuentaOK() {

		Account cuenta = [SELECT Id FROM Account WHERE Name='Cliente prueba' LIMIT 1];
        
        if (cuenta != null) {
            CRM_IB_BloqueoClienteWS.bloqueoCliente(cuenta.Id, 'Motivo');
        }
    }
    
    
   	@isTest public static void bloqueoCuentaKO() {

            String idNoExiste = '234';
        	CRM_IB_BloqueoClienteWS.bloqueoCliente(idNoExiste, 'Motivo'); 
    }
    
}
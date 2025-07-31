@isTest
public class CRM_IB_AltaModOppSUPER_Test {
	
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Account cuenta= new Account(Name='Cliente prueba', SAP_Account_IB__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam', Alias__c='ClientePrueba');
        insert cuenta;   
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        insert cs;
        
        Id recordTypeId = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Organización').getRecordTypeId();
        Parametrica_2__c param = new Parametrica_2__c(Name='60049219', RecordTypeId = recordTypeId);
        insert param;    
    }
    
    @isTest public static void altaModOportunidadOK(){

        Account cuenta = [SELECT Id FROM Account WHERE Name='Cliente prueba' LIMIT 1];
        
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=cuenta.Id, RecordTypeId=recordTypeId, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='0170',
                                             Clase_de_oferta__c='Licitación Pública');
        insert op;
        
    	List<Id> lIds = new List<Id>();
		lIds.add(op.Id);
		
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaModOppSUPERMock());
        CRM_IB_AltaModOppSUPER.altaModOppSUPER(lIds);
    }
    
   	@isTest public static void altaModExtensionOK(){
			
        //TODO    
    } 
    
    
    @isTest public static void altaModObjetivoOK(){

		Account cuenta = [SELECT Id FROM Account WHERE Name='Cliente prueba' LIMIT 1];
        
		Objetivo__c obj = new Objetivo__c(Name='Objetivo Prueba', CurrencyIsoCode='EUR', Cuenta__c=cuenta.Id, Desc_objetivo__c='Prueba', Fecha_ini__c= date.newInstance(2017, 11, 11), 
                                          Fecha_max__c=date.newInstance(2018,11,11), Estado__c='V', Tipo_de_Negocio__c='Nuevo Cliente',Oferta__c='BPS');
        
        insert obj;
        
    	List<Id> lIds = new List<Id>();
		lIds.add(obj.Id);
		
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaModOppSUPERMock());
        CRM_IB_AltaModOppSUPER.altaModOppSUPER(lIds);
    }
}
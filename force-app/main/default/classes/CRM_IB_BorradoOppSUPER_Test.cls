@isTest
public class CRM_IB_BorradoOppSUPER_Test {
    @isTest public static void borradoOppSUPEROK() {
         No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account_IB__c='5555',Sector_text__c='Sector Público', Subsector_texto__c='Administración Latam', Alias__c='ClientePrueba');
        insert Cliente;
        //Oportunidad creada solo con Mercado y Division
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Pais__c='ES',Sociedad_Ayesa__c='0147',Probabilidad__c='10', Mercado__c='60029427',
                                              Clase_de_oferta__c='Pública',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS');
        insert op;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        
        insert cs;
        
       
        
        List<Id> lIds = new List<Id>();
		lIds.add(op.Id);
		
        Test.setMock(HttpCalloutMock.class, new CRM_IB_BorradoOppSUPERMock());
        CRM_IB_BorradoOppSUPER.borradoOppSUPER(lIds);       
    }
}
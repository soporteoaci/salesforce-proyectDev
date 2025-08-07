@isTest(SeeAllData=true)
public class CloneOppControllerTest {
    @isTest public static void testCloneOpp() {
        
        
        List <Opportunity> oportunidad_insert = new List <Opportunity>();
        
        
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        Id RecordTypeAyesa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Ibermatica_SME').getRecordTypeId();
        //Oportunidad
        
        Opportunity idOportunidad2= new Opportunity(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                                          Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                                          Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        oportunidad_insert.add(idOportunidad2);
       // Oportunidad__c idOportunidad= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, RecordTypeId=recordTypeId, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='IB01',
        //                                                 Clase_de_oferta__c='Privada', Desglose_importes__c ='No');
        //oportunidad_insert.add(idOportunidad);
        //Oportunidad__c idOportunidad = [SELECT id, Cliente__c,Etapa__c,Subfase__c, fecha_limite_de_presentacion__c, Fecha_estimada_de_Cierre__c FROM Oportunidad__c where Record_Type_Name__c like '%Ibermatica %' LIMIT 1 ];
        // Oportunidad__c idOportunidad2 = [SELECT id, Cliente__c,Etapa__c,Subfase__c, fecha_limite_de_presentacion__c, Fecha_estimada_de_Cierre__c FROM Oportunidad__c where Record_Type_Name__c like '%Ayesa%' LIMIT 1 ];
        
        insert oportunidad_insert;
        
        
        
        
        
       
      //  CloneOppController.clonarOportunidad(idOportunidad.id, 'Test',null,null,null,null,null);
    //    CloneOppController.getTypeOpp(idOportunidad.id);
        
        
        CloneOppController.clonarOportunidad(idOportunidad2.id, 'Test',null,null,null,null,null);
        CloneOppController.getTypeOpp(idOportunidad2.id);
        
        
    }
    
}
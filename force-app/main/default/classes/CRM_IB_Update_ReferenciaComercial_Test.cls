@isTest
public class CRM_IB_Update_ReferenciaComercial_Test {
    
    @isTest
    
    public static void actualizar_referencia_test(){
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        Id RT_IbermaticaLargeAccount= Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica Large Account').getRecordTypeId();
        Id RecordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        //Contacto
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        
        //Referencia Comercial
        
        Referencia_comercial__c referencia = new Referencia_comercial__c (Name ='Prueba', clic_comercial__c =cliente.id);
        insert referencia;
        
        //CPV
        Parametrica_2__c param1 = new Parametrica_2__c(
            Name = 'CPV',
            CPV__c = '30000000-1',
            Descripcion_CPV__c = 'CPV prueba 1',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CPV' LIMIT 1].Id
        );
        insert param1;
        system.debug('param1: '+param1);
        
        //Oportunidad
        List <Oportunidad__c> ops_insert = new List <Oportunidad__c>();
        List <Oportunidad__c> ops_update = new List <Oportunidad__c>();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Contacto_Principal__c=contacto.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(),CPV_Varios__c ='30000000-1', Area_Tecnologia__c ='DIGITAL IMPACT - Mobile ecosystem', Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS', RecordTypeId = RecordTypeAyesa);
        ops_insert.add(op);
        /* Oportunidad__c op2= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Pais__c='España',Mercado__c='60029427',DivisionPickList__c='V-ENEL', Sociedad_Ayesa__c = 'IB01',
Clase_de_oferta__c='Licitación Pública',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
Fecha_estimada_de_cierre__c=date.newInstance(2001, 3, 21), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS',
recordTypeId =RT_IbermaticaLargeAccount, Importe_total_sin_IVA__c =30000, CR_Super__c ='CR prueba', GP_Super__c ='GP super', Tecnologia__c='SOL-ERP' );

ops_insert.add(op2);*/
        insert ops_insert;
        
        op.etapa__c ='Cerrada';
        op.Estado_de_Cierre__c='Contratada';
        op.Referencia_Comercial_lookup__c= referencia.Id;
        ops_update.add(op);
        /*op2.etapa__c ='Cerrada';
op2.Estado_de_Cierre__c='Contratada';
op2.Referencia_Comercial_lookup__c= referencia.Id;
ops_update.add(op2);*/
        update ops_update;
        
        String result1 = CRM_IB_Update_ReferenciaComercial.update_referencia_comercial(referencia.Id);
        List <string> ref_id = new List<String>();
        ref_id.add(referencia.Id);
        CRM_IB_Update_ReferenciaComercial.update_referencia_comercial_flujo(ref_id);  
    }   
    
    
}
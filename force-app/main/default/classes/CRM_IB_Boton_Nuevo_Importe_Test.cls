@isTest
public class CRM_IB_Boton_Nuevo_Importe_Test {
    @isTest
    public static void creacionimportes(){
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName();
        Id ayesaRecordTypeId = recordTypes.get('Ayesa').getRecordTypeId();
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert Cliente;
        
        Contact Contacto = new Contact (FirstName='Prueba',LastName ='Prueba', AccountId= Cliente.Id);
        insert contacto;
        //Oportunidad
        Oportunidad__c op= new Oportunidad__c(RecordTypeId=ayesaRecordTypeId,Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, COntacto_Principal__c =contacto.Id,Pais__c='ES',Sociedad_Ayesa__c='0170',Probabilidad__c='10', Mercado__c='60029427',
                                              Clase_de_oferta__c='Privada',Importe_Licitacion__c=300000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='IT&DS');
        insert op;
        
        //Parametrica Area, Solucion Producto
        Parametrica_2__c paramArea_Sol_Pro = new Parametrica_2__c (Name ='Prueba ASP',Tipo__c ='Area_Sol_Prod',Area__c ='Area', Solucion__c ='Solucion', Producto__c='Producto',Modulo__c='Modulo');
        insert  paramArea_Sol_Pro;
        
         //Area, Solucion y Producto IMPORTE SME
         
       String result1= CRM_IB_Boton_Nuevo_Importe.areaImporteSME(op.Id);
        List <String> result2 =  CRM_IB_Boton_Nuevo_Importe.solucionImporteSME(paramArea_Sol_Pro.Area__c);
        List <String> result3 =  CRM_IB_Boton_Nuevo_Importe.Producto_valoresImporteSME(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c );
        List <String> result4 = CRM_IB_Boton_Nuevo_Importe.Modulo_valoresImporteSME(paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c,paramArea_Sol_Pro.Producto__c );
       String result5= CRM_IB_Boton_Nuevo_Importe.saveInfoImportes(op.Id, 'Name', 'HARD', 3000.0,0.0,2, 10.0,'',0.0, '','','', paramArea_Sol_Pro.Area__c,paramArea_Sol_Pro.Solucion__c,paramArea_Sol_Pro.Producto__c,  paramArea_Sol_Pro.Modulo__c);
      
    }

}
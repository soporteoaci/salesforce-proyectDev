@isTest
public class CRM_IB_ImportesSME_Test {
    @IsTest
    public static void importes_Test(){
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='soporteoaci@ayesa.com';
        insert saltar_trigger;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        insert cs;
        //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam', Alias__c='ClientePrueba',Sector_text__c='Admón. Pública', Subsector_texto__c='Administración Latam');
        insert Cliente;
        
        
        
        List <Parametrica_2__c> parametricas_insert = new List <Parametrica_2__c>();
        //Parametrica Gestor de Produccion
        Parametrica_2__c paramGR = new Parametrica_2__c (Name ='Prueba',Codigo_Gestor_Produccion__c ='313', Gestor_de_produccion__c ='Usuario prueba',Tipo__c ='Gestor_Produccion', Centro_resp_Super__c='Centro prueba',Codigo_CR__c='015',Organizacion__c='BFSI',Desglose_importes__c='Sí',CR_Importe_OCP__c=99999);
        parametricas_insert.add(paramGR);
        
        
        //recuperar Record Type 
        String RecordTypeID_SME = [SELECT id FROM RecordType WHERE name = 'Ibermatica SME' and sobjecttype ='Oportunidad__c'].Id;
        
        //Oportunidad
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Pais__c='ES',Sociedad_Ayesa__c='0170', Organizacion_Ibermatica__c ='SMART FACTORIES',
                                              Clase_de_oferta__c='Privada',Tipo_de_Oportunidad__c='Licitación',Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', Participacion_Ayesa__c=100, 
                                              Direccion_Operaciones__c='IT&DS',RecordTypeId = RecordTypeID_SME,Importe_total_sin_IVA__c =0,Margen_Previsto_Euros__c=0,
                                              CR_Super__c ='prueba', GP_Super__c ='prueba', Desglose_importes__c ='Sí',
                                              importe_productoHard__c=0, Margen_productoHard__c=0,Rentabilidad_HW__c =0,
                                              importe_mtoHard__c=0, margen_mtoHard__c=0, Rentabilidad_Mtto_HW__c=0,
                                              importe_productoSoft__c=0, Margen_productoSoft__c=0,Rentabilidad_SW__c =0,
                                              importe_mtoSoft__c=0, margen_mtoSoft__c=0, Rentabilidad_Mtto_SW__c=0,
                                              importe_servicio__c=0, margen_servicio__c=0, Rentabilidad_Serv__c=0);
        insert op;
        
        
        
        
        //Importes oportunidad
        
        List <ImporteSME__c> importes = new List <ImporteSME__c>();
        Test.startTest();
        //Insert
        ImporteSME__c item_Hard = new ImporteSME__c(Name ='Hard', Seccion__c ='Hard',Descuento__c =0, Importe_bruto__c =15000, Coste__c =5000, Cantidad__c = 2, Observaciones__c ='observaciones',Oportunidad__c= op.Id);
        insert item_Hard;
        /*ImporteSME__c item_Hard_2= new ImporteSME__c(Name ='Hard', Seccion__c ='Hard', Importe_bruto__c =150000, Coste__c =5000, Cantidad__c = 2, Observaciones__c ='observaciones',Oportunidad__c= op.Id);
insert item_Hard_2;*/
        //importes.add(item_Hard);
        ImporteSME__c item_MTTOHard = new ImporteSME__c(Name ='MTTO_HARD', Seccion__c ='MTTO.HARD',Descuento__c =0, Importe_bruto__c =15000, Coste__c =5000, Cantidad__c = 2, Observaciones__c ='observaciones',Oportunidad__c= op.Id);
        insert item_MTTOHard;
        //importes.add(item_MTTOHard);
        ImporteSME__c item_Soft = new ImporteSME__c(Name ='SOFT', Seccion__c ='SOFT', Importe_bruto__c =15000,Descuento__c =0, Coste__c =5000, Cantidad__c = 2, Observaciones__c ='observaciones',Oportunidad__c= op.Id);
        insert item_Soft;
        //importes.add(item_Soft);
        ImporteSME__c item_MTTOSoft = new ImporteSME__c(Name ='MTTO.SOFT', Seccion__c ='MTTO.SOFT', Descuento__c =0,Importe_bruto__c =15000, Coste__c =5000, Cantidad__c = 2, Observaciones__c ='observaciones',Oportunidad__c= op.Id);
        insert item_MTTOSoft;
        //importes.add(item_MTTOSoft);
        ImporteSME__c item_SRV = new ImporteSME__c(Name ='SRV', Seccion__c ='SRV', Descuento__c =0,Importe_bruto__c =15000, Coste_horas__c ='27', Coste__c =0,Horas__c=10, Cantidad__c = 2, Observaciones__c ='observaciones',Area__c ='ERP',Oportunidad__c= op.Id);
        insert item_SRV;
        //importes.add(item_SRV);
        
        Oportunidad__c op1 = CRM_IB_ImportesSME.insertImportes(item_Hard,  op);
        op1 = CRM_IB_ImportesSME.insertImportes(item_Soft,  op);
        op1 = CRM_IB_ImportesSME.insertImportes(item_MTTOHard,  op);
        op1 = CRM_IB_ImportesSME.insertImportes(item_MTTOSoft,  op);
        op1 = CRM_IB_ImportesSME.insertImportes(item_SRV,  op);
        
        //UPDATE
        ImporteSme__c item_Hard_2 = item_Hard;
        item_Hard_2.Name ='Change';
        update item_Hard;
        Oportunidad__c op2 =CRM_IB_ImportesSME.updateImportes( item_Hard_2, op, item_Hard);
        
        
        
        ImporteSme__c item_MTTOHard_2 = item_MTTOHard;
        item_MTTOHard_2.Importe_Bruto__c=15;
        update item_MTTOHard;
         op2 =CRM_IB_ImportesSME.updateImportes( item_MTTOHard_2, op, item_MTTOHard);
        
        ImporteSme__c item_Soft_2 = item_Soft;
        item_Soft_2.Importe_Bruto__c=15;
        update item_Soft;
        op2 =CRM_IB_ImportesSME.updateImportes( item_Soft_2, op, item_Soft);
        
        ImporteSme__c item_MTTOSoft_2 = item_MTTOSoft;
        item_MTTOSoft_2.Importe_Bruto__c=15;
        update item_MTTOSoft;
         op2 =CRM_IB_ImportesSME.updateImportes( item_MTTOSoft_2, op, item_MTTOSoft);
        
        ImporteSme__c item_SRV_2 = item_SRV;
        item_SRV_2.Cantidad__c =3;
        update item_SRV;
        op2 =CRM_IB_ImportesSME.updateImportes( item_SRV_2, op, item_SRV);    
        
        //Delete
       Oportunidad__c op3= CRM_IB_ImportesSME.deleteImportes(item_Hard, op);
        op3= CRM_IB_ImportesSME.deleteImportes(item_MTTOHard, op);
        op3= CRM_IB_ImportesSME.deleteImportes(item_Soft, op);
        op3= CRM_IB_ImportesSME.deleteImportes(item_MTTOSoft, op);
        op3= CRM_IB_ImportesSME.deleteImportes(item_SRV, op);
        delete item_Hard;
        delete item_MTTOHard;
        delete item_Soft;
        delete item_MTTOSoft;
        delete item_SRV;
       CRM_IB_ImportesSME.test();
        Test.stopTest();
        
        
    }
    
}
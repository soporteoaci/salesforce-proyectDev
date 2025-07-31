@isTest
public class CRM_IB_OCP_Test {

    @isTest
    public static void correos_OCP(){
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
         //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam', Alias__c='ClientePrueba',Sector_text__c='Admón. Pública', Subsector_texto__c='Administración Latam');
        insert Cliente;
        
        //Oportunidad
        Id recordTypeSME = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        List<Oportunidad__c> listaOps = new List<Oportunidad__c>();
        Oportunidad__c op= new Oportunidad__c(Name='Prueba', Cliente__c=Cliente.Id, Fecha_SP__c = System.TODAY(), Tipo_de_Negocio__c='New contract',VALIDACIONDEF__c='No',
                                              RecordTypeId= recordTypeSME, Importe_limite_OCP__c=500, Desglose_importes__c ='No',Importe_total_sin_IVA__c=1, Modificar_importes__c=true );
        
        Oportunidad__c op2= new Oportunidad__c(Name='Prueba2', Cliente__c=Cliente.Id, Fecha_SP__c = System.TODAY(), Tipo_de_Negocio__c='New contract',VALIDACIONDEF__c='Sí',
                                              RecordTypeId= recordTypeSME, Importe_limite_OCP__c=500, Desglose_importes__c ='No',Importe_total_sin_IVA__c=1, Modificar_importes__c=true );
        listaOps.add(op);
        listaOps.add(op2);
        
        insert listaOps;

        CRM_IB_OCP.avisosOCP(op,op2);
        
        op.VALIDACIONDEF__c='Sí';
        op2.VALIDACIONDEF__c='No';
        update listaOps;
        CRM_IB_OCP.avisosOCP(op,op2);

        op.VALIDACIONDEF__c='Sí';
        op2.VALIDACIONDEF__c='Pdte. validar';
        update listaOps;
        CRM_IB_OCP.avisosOCP(op,op2);
        
        op.VALIDACIONDEF__c='Sí';
        op2.VALIDACIONDEF__c='Sin Validar';
        update listaOps;
        CRM_IB_OCP.avisosOCP(op,op2);
       
    }
}
@isTest
public class CRM_ImportesSME_Utils_Test {
    
    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;

        Account cuenta= new Account(Name='Cliente prueba', SAP_Account_IB__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam', Alias__c='ClientePrueba', Sector_text__c='Admón. Pública', Subsector_texto__c='Administración Latam');
        insert cuenta;   
        
        Id recordTypeId = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Oportunidad__c op= new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=cuenta.Id, RecordTypeId=recordTypeId, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='0170',
                                             Clase_de_oferta__c='Licitación Pública', Desglose_importes__c = 'Sí');
        insert op;
        
        List<ImporteSME__c> lImportes = new List<ImporteSME__c>();
        
        ImporteSME__c importeHW = new ImporteSME__c(Name='Importe1', Importe_Bruto__c=100, Coste__c=50,Oportunidad__c=op.Id,Seccion__c='HARD');
        ImporteSME__c importeMtoHW = new ImporteSME__c(Name='Importe2', Importe_Bruto__c=200, Coste__c=40,Oportunidad__c=op.Id,Seccion__c='MTTO.HARD');
        ImporteSME__c importeSW = new ImporteSME__c(Name='Importe3', Importe_Bruto__c=300, Coste__c=20,Oportunidad__c=op.Id,Seccion__c='SOFT');
        ImporteSME__c importeMtoSW = new ImporteSME__c(Name='Importe4', Importe_Bruto__c=400, Coste__c=30,Oportunidad__c=op.Id,Seccion__c='MTTO.SOFT');
        ImporteSME__c importeSRV = new ImporteSME__c(Name='Importe5', Importe_Bruto__c=500, Coste__c=25,Oportunidad__c=op.Id,Seccion__c='SRV');
        lImportes.add(importeHW);
        lImportes.add(importeMtoHW);
        lImportes.add(importeSW);
        lImportes.add(importeMtoSW);
        lImportes.add(importeSRV);
        insert lImportes;
    }
    
    @isTest   
    public static void test1() {
        
        Oportunidad__c opp = [SELECT Id FROM Oportunidad__c WHERE Name='Prueba' LIMIT 1 ]; 
        
        CRM_ImportesSME_Utils.recalcularImportesOportunidad(opp.Id, true);
        
    }
}
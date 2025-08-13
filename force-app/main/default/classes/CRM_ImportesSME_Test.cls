@isTest
public class CRM_ImportesSME_Test {

    @testSetup static void setup() {
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;

        Account cuenta= new Account(Name='Cliente prueba', SAP_Account_IB__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam', Alias__c='ClientePrueba', Sector_text__c='Admón. Pública', Subsector_texto__c='Administración Latam');
        insert cuenta;   
        
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Ibermatica_Large_Account').getRecordTypeId();
        Opportunity op= new Opportunity(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=cuenta.Id, RecordTypeId=recordTypeId, Tipo_Participacion_Ayesa__c='Contratista Principal', Sociedad_Ayesa__c='0170',
                                             Clase_de_oferta__c='Licitación Pública', Desglose_importes__c = 'Sí');
        insert op;
    }
     
    @isTest   
    public static void test1() {
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Prueba' LIMIT 1 ]; 
        
        ImporteSME__c importe = new ImporteSME__c(Name='Importe1', Importe_Bruto__c=100, Coste__c=50,Oportunidad__c=opp.Id,Seccion__c='HARD');
        insert importe;
        
        //Actualizo el importe
        importe.Importe_Bruto__c = 200;
        update importe;
        
        //Elimino el importe
        delete importe;
        
    }
    
}
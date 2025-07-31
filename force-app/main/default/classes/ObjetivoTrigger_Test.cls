@isTest
public class ObjetivoTrigger_Test {
    
    @testSetup static void setup() {
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        Account cuenta= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        insert cuenta;
        insert new CRM_Ibermatica_Configuration__c(client_id__c = '12345', client_secret__c='453345',URL_Consulta_New_File__c='http://test.com', URL_Existe_Doc_New_File__c='http://test.com',URL_Preventa__c='http://test.com');
    }
        
    @isTest
    public static void testObjetivoIbermatica() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CRM_IB_AltaModOppSUPERMock());
        Account cuenta = [SELECT Id FROM Account WHERE Name='Cliente prueba' LIMIT 1];
        
        Objetivo__c obj = new Objetivo__c(Name='Prueba', Cuenta__c=cuenta.Id, Desc_objetivo__c='Desc Objetivo', Fecha_ini__c=Date.newInstance(2023, 1, 1), Fecha_max__c=Date.newInstance(2024, 1, 1), Divisa__c = 'USD');
        insert obj;
        
        obj.Divisa__c = 'EUR';
        update obj;
        delete obj;
        Test.stopTest();
    } 
}
//'Oferta__c',
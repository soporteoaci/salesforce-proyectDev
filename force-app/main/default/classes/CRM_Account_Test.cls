@isTest
public class CRM_Account_Test {
    
    @isTest
    
    public static void trigger_account(){
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555', Alias__c='ClientePrueba',Sector__c= 'Educación', Subsector__c ='Centros de formación en gral.');
        
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        
        
        Test.startTest();
        insert saltar_trigger;
        insert Cliente;
        Cliente.CIF_NIF__c='77788899J';
        Cliente.Pais__c='ES';        
        update Cliente;            
        Test.stopTest();
        
        
        
        
    }

}
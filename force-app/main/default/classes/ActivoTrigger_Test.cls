@isTest
public class ActivoTrigger_Test {
    @isTest
    public static void activo_test(){
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
        
        CRM_Ibermatica_Configuration__c cs = new CRM_Ibermatica_Configuration__c();
        cs.client_id__c='test';
        cs.client_secret__c='test';
        insert cs;
        //Cuenta
        Account cliente = new Account(
            Name = 'Cliente prueba ' + String.valueOf(Math.random()).replace('0.', ''),
            SAP_Account__c = String.valueOf(Math.random()).substring(2, 6),
            Sector__c = 'Admón. Pública',
            Subsector__c = 'Administración Latam',
            Alias__c = 'ClientePrueba',
            Sector_text__c = 'Sector Público',
            Subsector_texto__c = 'Administración Latam',
            CIF_NIF__c = '11111111X'
        );
        insert cliente;
        
        Activo__c activo = new Activo__c(Name='prueba', Estado_Activo__c='Activo', Estado__c='Activo', Cuenta__c= cliente.Id, partner__c= cliente.Id, Observaciones__c='Prueba');
        insert activo;
        
        activo.Name='SAP';

        update activo;
        
        delete activo;
        
    }
    
    
}
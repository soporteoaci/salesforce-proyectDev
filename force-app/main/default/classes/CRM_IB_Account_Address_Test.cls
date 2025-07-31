@isTest
public class CRM_IB_Account_Address_Test {
    @isTest
    public static void allTest(){
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;
    //Cuenta
        Account Cliente= new Account(Name='Cliente prueba', SAP_Account__c='5555',Sector__c='Admón. Pública', Subsector__c='Administración Latam',Sector_text__c='Admón. Pública', Subsector_texto__c='Administración Latam', Alias__c='ClientePrueba');
        insert Cliente;
     //Pais
         Id RT_Pais = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Paises').getRecordTypeId();
        Id RT_Provincia = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Provincias').getRecordTypeId();
        
        Parametrica_2__c Pais = new Parametrica_2__c (Name ='Pais', Denominacion__c ='España', Codigo_Externo__c ='ES', RecordTypeId=RT_Pais);
        insert Pais;
        Parametrica_2__c Provincia = new Parametrica_2__c (Name ='Provincia', Denominacion__c ='Sevilla', Codigo_Externo__c ='01', Pais__c=Pais.Id,RecordTypeId=RT_Provincia);
        insert Provincia;
        String test1 = CRM_IB_Account_Address_controller.countryProvinceMap(Cliente.Id);
        
        List <String> test2 = CRM_IB_Account_Address_controller.provinceOptions('España');
            
        String test3 = CRM_IB_Account_Address_controller.saveAccountCountry('España', 'Sevilla', 'Sevilla', 'Calle Sierpes', '41018', Cliente.Id);
        
    }

}
/**
* @author Ayesa
* @since 12-06-2023
* @desc Creacion APEX Alta Cliente en SAP 
* Alta SAP Ibermatica
*/
public class CRM_IB_AltaClienteSAP {
    @InvocableMethod 
    public static void altaClienteSAP(List<Id> recordIds){
        System.debug('CRM_IB_AltaClienteSAP: ' + recordIds);
        //Llamar a la API de clientes SAP
        futureAltaClienteSAP(recordIds.get(0));              
    }
    
    @future(callout=true)
    public static void futureAltaClienteSAP(Id recordId){
        System.debug('futureAltaClienteSAP: ' + recordId);
        
        //Llamar a la API de clientes SAP Alta
        List<Account> lAccounts = [SELECT Id, CIF_NIF__c, Name, Parent.CIF_NIF__c, BillingStreet, BillingPostalCode, BillingCity, Phone, Fax,
                                   Codigo_Pais__c, Codigo_provincia__c
                                   FROM Account WHERE Id =:recordId LIMIT 1];
        
        if (!lAccounts.isEmpty()) {
        	
            Account account = lAccounts.get(0);
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('codCta', account.Id);
            gen.writeStringField('nif', (account.CIF_NIF__c != null) ? account.CIF_NIF__c : '');
            gen.writeStringField('nombre', (account.Name != null) ? account.Name : '');
            gen.writeStringField('nifMatriz', (account.Parent.CIF_NIF__c != null) ? account.Parent.CIF_NIF__c : '');            
            gen.writeStringField('direccion', (account.BillingStreet != null) ? account.BillingStreet : '');
            gen.writeStringField('codPos', (account.BillingPostalCode != null) ? account.BillingPostalCode : ''); 
            gen.writeStringField('poblacion', (account.BillingCity != null) ? account.BillingCity : ''); 
            gen.writeStringField('codProvincia', (account.Codigo_provincia__c != null) ? account.Codigo_provincia__c : '');
            gen.writeStringField('pais', (account.Codigo_Pais__c != null) ? account.Codigo_Pais__c : '');
            gen.writeStringField('telefono', (account.Phone != null) ? account.Phone : ''); 
            gen.writeStringField('fax', (account.Fax != null) ? account.Fax : '');             
            gen.writeEndObject();
            
            String request = gen.getAsString();
            String endpoint = 'callout:MULE_API_Clientes/sap/clientes';
            
            CRM_IB_MulesoftAPI.callApiMule(endpoint, request,'POST',null, 'AltaClienteSAP'); 
            
            System.debug('fin futureAltaClienteSAP: ' + recordId);
        } else {
           System.debug('Account no encontrado: ' + recordId); 
        }                    
    }   
}
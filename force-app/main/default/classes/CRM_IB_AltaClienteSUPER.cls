/**
* @author Ayesa
* @since 12-06-2023
* @desc Creacion APEX Alta Cliente en SUPER 
* Alta SUPER Ibermatica
*/
public with sharing class CRM_IB_AltaClienteSUPER {
    @InvocableMethod
    public static void altaClienteSUPER(List<Id> recordIds){
        System.debug('CRM_IB_AltaClienteSUPER: ' + recordIds);
        futureAltaClienteSUPER(recordIds.get(0));
    }    
    @future(callout=true)
    public static void futureAltaClienteSUPER(Id recordId){
        System.debug('futureAltaClienteSUPER: ' + recordId);
        
        //Llamar a la API de clientes SUPER Alta
        List<Account> lAccounts = [SELECT Id, Name, Razon_Social__c, ParentId, SAP_Account_IB__c, CIF_NIF__c, BillingStreet, BillingCity, CreatedDate, 
                                   Description, CreatedBy.Name, BillingPostalCode, Phone, Fax, Website, Perfil_MKT__c, Codigo_Pais__c, 
                                   Codigo_provincia__c, Codigo_Subsector_texto__c, Codigo_Organizacion__c
                                   FROM Account WHERE Id =:recordId LIMIT 1];
        
        if (!lAccounts.isEmpty()) {
       	
            Account account = lAccounts.get(0);
            String direccion = account.BillingStreet;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('id', account.Id);
            gen.writeStringField('nombre', (account.Razon_Social__c != null) ? account.Razon_Social__c : account.Name);
            gen.writeStringField('nombreComercial', (account.Name != null) ? account.Name : '');
            gen.writeStringField('idSegmento', (account.Codigo_Subsector_texto__c != null) ? account.Codigo_Subsector_texto__c : '');            
            gen.writeStringField('idClienteMatriz', (account.ParentId != null) ? (String)account.ParentId : '');
            gen.writeStringField('codContable', (account.SAP_Account_IB__c != null) ? account.SAP_Account_IB__c : '');
            gen.writeStringField('idPais', (account.Codigo_Pais__c != null) ? account.Codigo_Pais__c : '');
            gen.writeStringField('idProvincia', (account.Codigo_provincia__c != null) ? account.Codigo_provincia__c : '');
            gen.writeStringField('cif', (account.CIF_NIF__c != null) ? account.CIF_NIF__c : '');
            gen.writeStringField('origen', 'CRM');
            gen.writeStringField('direccion', (account.BillingStreet != null) ? direccion.substring(0, Math.min(100, direccion.length())) : '');
            gen.writeStringField('poblacion', (account.BillingCity != null) ? account.BillingCity : ''); 
            gen.writeStringField('descripcion', (account.Description != null) ? account.Description : ''); 
            gen.writeStringField('creadoPor', (account.CreatedBy.Name != null) ? account.CreatedBy.Name : ''); 
            gen.writeStringField('fechaCreacion', (account.CreatedDate != null) ? account.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') : ''); 
            gen.writeStringField('actDetallada', (account.Description != null) ? account.Description : ''); 
            gen.writeStringField('codPostal', (account.BillingPostalCode != null) ? account.BillingPostalCode : ''); 
            gen.writeStringField('telefono', (account.Phone != null) ? account.Phone : ''); 
            gen.writeStringField('fax', (account.Fax != null) ? account.Fax : ''); 
            gen.writeStringField('url', (account.Codigo_Organizacion__c != null) ? account.Codigo_Organizacion__c : ''); 
            gen.writeStringField('idOrgComercial', (account.Codigo_Organizacion__c != null) ? account.Codigo_Organizacion__c : ''); 
            gen.writeStringField('perfilMKT', (account.Perfil_MKT__c != null) ? account.Perfil_MKT__c : ''); 
            gen.writeEndObject();
            
            String request = gen.getAsString();
            String endpoint = 'callout:MULE_API_Clientes/super/clientes';
            
            if(!Test.isRunningTest()){
            CRM_IB_MulesoftAPI.callApiMule(endpoint, request,'POST',null, 'AltaClienteSUPER'); 
            }
        } else {
           System.debug('Account no encontrado: ' + recordId); 
        }                    
    }   
}
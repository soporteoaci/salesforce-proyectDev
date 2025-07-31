/**
* @author Ayesa
* @since 24-05-2023
* @desc Creacion APEX Rest integracion CR-IB 
* Bloque de Clientes
*/
@RestResource(urlMapping='/BloqueoCliente/*')
global with sharing class CRM_IB_BloqueoClienteWS {
    
    global class Response{
        webservice String errorCode;
        webservice String errorMessage;
        webservice String accountId;
    }
    @HttpPut
    global static Response bloqueoCliente(String clienteId, String motivoBloqueo){
        
        System.debug('CRM_IB_BloqueoClienteWS clienteId: ' + clienteId);
        
        Response res = new Response();
        List<Account> acc = [SELECT id,name,BLoqueada__c,Motivo_bloqueo__c 
                             FROM Account WHERE Id=:clienteId LIMIT 1];
        
        Control_Integracion__c controlInt = new Control_Integracion__c();
        controlInt.Request__c = clienteId;
        controlInt.Metodo__c = 'PATCH';
        controlInt.Interfaz__c = 'BloqueoCliente';
        controlInt.Servicio__c = '/BloqueoCliente/*';  
        
        System.debug('CRM_IB_BloqueoClienteWS acc: ' + acc);
        
        if(!acc.isEmpty()){
            acc.get(0).BLoqueada__c = true;
            acc.get(0).Motivo_bloqueo__c = motivoBloqueo;
            controlInt.Status_Code__c = 201;  
            controlInt.Error_Code__c = '00';
            controlInt.Error_Message__c = 'OK.';
            
            res.errorCode = '00';
            res.errorMessage = 'Bloqueo OK.';
            res.accountId = clienteId;           
            try{
                update acc;
                insert controlInt;               
            }catch(DMLException ex){
                controlInt.Status_Code__c = 400;  
                controlInt.Error_Code__c = '98';
                controlInt.Error_Message__c = 'KO. ' + ex.getMessage();
            }            
        }else{
            res.errorCode = '99';
            res.errorMessage = 'KO. No existe el Cliente';
            res.accountId = clienteId;
            
            controlInt.Status_Code__c = 400; 
            controlInt.Error_Code__c = '99';
            controlInt.Error_Message__c = 'Cambio de estado KO.No existe la Oportunidad';            
        }
                
        return res;
    }
}
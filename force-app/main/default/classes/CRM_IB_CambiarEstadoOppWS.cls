/**
* @author Ayesa
* @since 24-05-2023
* @desc Creacion APEX Rest integracion CR-IB 
* Cambiar el estado de la Oportunidad
*/
@RestResource(urlMapping='/CambiarEstadoOportunidad/*')
global with sharing class CRM_IB_CambiarEstadoOppWS {
    
    global class Response{
        webservice String errorCode;
        webservice String errorMessage;
        webservice String oportunidadId;
    }
    @HttpPut
    global static Response cambiarEstadoOpp(String oportunidadId){
        
        System.debug('CRM_IB_CambiarEstadoOppWS oportunidadId: ' + oportunidadId);
        
        List<Oportunidad__c> opp = [SELECT id,name,RecordType.Developername,Etapa__c 
                                    FROM Oportunidad__c WHERE Id=:oportunidadId LIMIT 1];
        
        Control_Integracion__c controlInt = new Control_Integracion__c();
        controlInt.Request__c = oportunidadId;
        controlInt.Metodo__c = 'PATCH';
        controlInt.Interfaz__c = 'ElaborarOferta';
        controlInt.Servicio__c = '/CambiarEstadoOportunidad/*';  
        
        Response res = new Response();  
        
        
        System.debug('CRM_IB_CambiarEstadoOppWS opp: ' + opp);
        
        if(!opp.isEmpty()){
            if(opp.get(0).RecordType.Developername == 'Ibermatica_SME'){
                System.debug('CRM_IB_CambiarEstadoOppWS opp: ' + opp.get(0).RecordType.Developername);
                opp.get(0).Etapa__c = 'Oferta';
                opp.get(0).Etapa_Fase__c = 'Oferta';
            }else{
                System.debug('CRM_IB_CambiarEstadoOppWS opp: ' + opp.get(0).RecordType.Developername);
                opp.get(0).Etapa__c = 'Presentada';
            }
            res.errorCode = '00';
            res.errorMessage = 'Cambio de estado OK.';
            res.oportunidadId = oportunidadId;
            
            controlInt.Status_Code__c = 201;  
            controlInt.Error_Code__c = '00';
            controlInt.Error_Message__c = 'OK';
            try{
                update opp;
                insert controlInt;
            }catch(DMLException ex){
                controlInt.Status_Code__c = 400;  
                controlInt.Error_Code__c = '98';
                controlInt.Error_Message__c = 'KO. ' + ex.getMessage();
            }
            
        }else{           
            res.errorCode = '99';
            res.errorMessage = 'KO.No existe la Oportunidad';
            res.oportunidadId = oportunidadId;
            
            controlInt.Status_Code__c = 400; 
            controlInt.Error_Code__c = '99';
            controlInt.Error_Message__c = 'Cambio de estado KO.No existe la Oportunidad';
            insert controlInt;         
        }
        
        return res;
    }
}
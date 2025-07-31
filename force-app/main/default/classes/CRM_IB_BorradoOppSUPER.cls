/**
* @author Ayesa
* @since 14-06-2023
* @desc Creacion APEX Borrado Logico Opp en SUPER
* Borrado Opp SUPER Ibermatica
*/
public class CRM_IB_BorradoOppSUPER {
    @InvocableMethod 
    public static void borradoOppSUPER(List<Id> recordIds){
        System.debug('CRM_IB_BorradoOppSUPER: ' + recordIds);
        futureborradoOppSUPER(recordIds.get(0));           
    }
    
    @future(callout=true)
    public static void futureborradoOppSUPER(Id recordId){
        System.debug('futureborradoOppSUPER: ' + recordId);
        
        //Llamar a la API de Borrado Logico Opp SUPER 
       
        String endpoint = 'callout:MULE_API_Oportunidades/super/oportunidades';
        CRM_IB_MulesoftAPI.callApiMule(endpoint, null, 'DELETE', recordId, 'BorradoOpp');            

    }
}
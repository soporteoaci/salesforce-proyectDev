/**
* @author Ayesa
* @since 21-06-2023
* @desc Creacion APEX Baja Cliente en SUPER 
* Baja SUPER Ibermatica
*/
public class CRM_IB_BajaClienteSUPER {
	@InvocableMethod 
    public static void bajaClienteSUPER(List<Id> recordIds){
        System.debug('CRM_IB_BajaClienteSUPER: ' + recordIds);
        futureBajaClienteSUPER(recordIds.get(0));           
    }
    
    @future(callout=true)
    public static void futureBajaClienteSUPER(Id recordId){
        System.debug('futureBajaClienteSUPER: ' + recordId);
       
		String endpoint = 'callout:MULE_API_Clientes/super/clientes';
        CRM_IB_MulesoftAPI.callApiMule(endpoint, null, 'DELETE',recordId, 'BajaClienteSUPER');       
    }
}
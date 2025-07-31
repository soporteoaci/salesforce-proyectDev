public class SSC_ActionsController {
@AuraEnabled
    
    public static List<Action__c> getActions(String status) {
        List <Action__c> listActions= new List<Action__c> ();
        String idUser =UserInfo.getUserId();
        
        if(status == 'Cerrada') {
            listActions = [SELECT Id, Name, EndDate__c, Status__c, DaysToEndDate__c FROM Action__c WHERE Status__c ='Cerrada' AND Responsable__c=:idUser ORDER BY EndDate__c ASC NULLS LAST];
        } else {
            listActions = [SELECT Id, Name, EndDate__c, Status__c, DaysToEndDate__c FROM Action__c WHERE Responsable__c=:idUser AND Status__c !='Cerrada' AND Status__c !='Validada' AND Status__c !='Cancelada' ORDER BY EndDate__c ASC NULLS LAST];
        }        
        System.debug('Value is =' + status);
        return listActions;
    }
}
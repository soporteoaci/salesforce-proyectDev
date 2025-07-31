public class Ayesa_TimeTracker {

    @AuraEnabled
    public static List<Entregable__c> getMyEntregables(){
       // return  [SELECT Name, Descripcion__c  from Entregable__c where OwnerId = :UserInfo.getUserId() ];   
       return null;
    }
}
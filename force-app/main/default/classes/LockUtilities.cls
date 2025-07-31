public class LockUtilities {
    @InvocableMethod 
    public static void unlockRecord(List<Id> recordIds){
        User user = [select id, Puede_Desbloquear__c  from user where id =: System.UserInfo.getUserId()];
        if( user.Puede_Desbloquear__c ){
            Approval.UnlockResult[] result =  Approval.unlock(recordIds);         
        }
    }
}
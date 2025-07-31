@isTest
public class LockUtilitiesTest {

    @isTest
    public static void testUnlock(){
        Proyecto__c proyecto = new Proyecto__c(Name = 'TEST PROJECT', Pais__c = 'EC', Codigo__c = 'TEST');
        insert proyecto;
        
        Case caso  = new Case(Modulo__c ='Otros', proyecto__c = proyecto.Id);
        insert caso;
        
        Approval.lock(caso.Id);
        List<Id> casosToUnlock = new List<Id>();
        casosToUnlock.add(caso.Id);
        LockUtilities.unlockRecord(casosToUnlock);
    }
}
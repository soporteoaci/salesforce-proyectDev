@isTest(SeeAllData=true)
public class ExtensionOppControllerTest {
    @isTest public static void testCloneOpp() {
        Id recordTypeAyesa = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
       
        Oportunidad__c idOportunidad2 = [SELECT id FROM Oportunidad__c where RecordTypeId =: recordTypeAyesa and origen__c='Soft'  LIMIT 1 ];
        ExtensionOppController.extenderOportunidad_fields(idOportunidad2.id, 'Test',null,null,null,null,null,null,null,'Extensión Desglose',null,null);
        ExtensionOppController.getTypeOpp(idOportunidad2.id);
        ExtensionOppController.extenderOportunidad_fields(idOportunidad2.id, 'Test',null,null,null,null,null,null,null,'Extensión Rectificativa',null,null);
        ExtensionOppController.getTypeOpp(idOportunidad2.id);
        
        ExtensionOppController.test();
        
    }
    
}
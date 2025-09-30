@isTest(SeeAllData=true)
public class ExtensionOppControllerTest {
    @isTest public static void testCloneOpp() {
                //TestDataFactory.initParametricas();
        Opportunity oports = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        // Perform test
        Test.startTest();    
        Opportunity oportunidad = TestDataFactory.getOpportunity(oports.Id);

        ExtensionOppController.extenderOportunidad_fields(oportunidad.id, 'Test',null,null,null,null,null,'6',null,'Extensión Desglose',null,null);
        ExtensionOppController.getTypeOpp(oportunidad.id);
        ExtensionOppController.extenderOportunidad_fields(oportunidad.id, 'Test',null,null,null,null,null,'6',null,'Extensión Rectificativa',null,null);
        ExtensionOppController.getTypeOpp(oportunidad.id);
        oportunidad.Origen__c = 'Soft';
        update oportunidad;
        ExtensionOppController.extenderOportunidad_fields(oportunidad.id, 'Test',null,null,null,null,null,'6',null,'Extensión Desglose',null,'Soft');
        ExtensionOppController.getTypeOpp(oportunidad.id);
        
    }
    
}
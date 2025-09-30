@isTest(SeeAllData=true)
public class CloneOppControllerTest {
    @isTest public static void testCloneOpp() {

        Opportunity idOportunidad = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        
        CloneOppController.clonarOportunidad(idOportunidad.id, 'Test',null,null,null,null,null);
        CloneOppController.getTypeOpp(idOportunidad.id);
        
        
    }
    
}
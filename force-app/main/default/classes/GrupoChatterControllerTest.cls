@isTest
public class GrupoChatterControllerTest {

    @isTest
    static void testObtenerIdGrupo(){
        
        CollaborationGroup grupoPrueba = new CollaborationGroup(
        name = 'Prueba',
        CollaborationType = 'Public'
        );
        
        insert grupoPrueba;
        
        Test.startTest();
        Id res = GrupoChatterController.obtenerIdGrupo('Prueba');
        Test.stopTest();
        
        System.assertEquals(grupoPrueba.Id, res, 'El Id del grupo no es el esperado.');
    }
}
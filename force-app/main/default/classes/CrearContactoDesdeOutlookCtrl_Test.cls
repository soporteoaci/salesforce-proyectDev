@isTest
public class CrearContactoDesdeOutlookCtrl_Test {

    @testSetup
    static void setup() {
        // Creamos datos base
        Opportunity opp = TestDataFactory.createOpportunity(
            'Cualificación',
            'Digital impact',
            'IT_DS'
        );
        // Esto crea automáticamente cliente + contacto
    }

    @isTest
    static void testGuardarContacto_OK() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String, Object> contacto = new Map<String, Object>{
            'tratamiento'   => 'Sras.',
            'nombre'        => 'Juanas',
            'apellidos'     => 'Pérezas',
            'email' => 'juan.perezas' + System.currentTimeMillis() + '@test.com',
            'cargo'         => 'Manageras',
            'cuenta'        => acc.Id,
            'perfil'        => 'Perfilas A',
            'nivel'         => 'Nivelas 1',
            'subnivel'      => 'Subnivelas X',
            'claveNegocio'  => true
        };

        Test.startTest();
        CrearContactoDesdeOutlookCtrl.guardarContacto(contacto);
        Test.stopTest();
    }

    @isTest
    static void testBuscarCuentasPorNombre() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        List<Map<String, String>> resultados = CrearContactoDesdeOutlookCtrl.buscarCuentasPorNombre(acc.Name);
        Test.stopTest();

        System.assertNotEquals(0, resultados.size(), 'Debe devolver al menos 1 cuenta');
        System.assertEquals(acc.Id, resultados[0].get('value'));
    }

    @isTest
    static void testObtenerValoresPicklist() {
        Test.startTest();
        List<Map<String, String>> opciones = CrearContactoDesdeOutlookCtrl.obtenerValoresPicklist('Contact', 'Salutation');
        Test.stopTest();

        System.assert(opciones.size() > 0, 'Debe devolver opciones del picklist Salutation');
        System.assert(opciones[0].containsKey('label'));
        System.assert(opciones[0].containsKey('value'));
    }
}
@IsTest
public class TestDataFactory_Test {

    @TestSetup
    static void setup() {

    }

    @IsTest
    static void testCreateClientes() {
        List<Account> clientes = TestDataFactory.createClientes(2);
        System.assertEquals(2, clientes.size(), 'Debe crear 2 clientes');
        for (Account a : clientes) {
            System.assertNotEquals(null, a.Id, 'El cliente debe tener Id tras insert');
            System.assert(a.Name.startsWith('TestCliente'), 'Nombre de cliente esperado');
        }
    }

    @IsTest
    static void testCreateOpportunity() {
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        System.assertNotEquals(null, opp.Id, 'Opportunity debe tener Id tras insert');
        System.assertEquals('Opp-Test', opp.Name, 'El nombre de la Opportunity debe ser Opp-Test');
        System.assertNotEquals(null, opp.AccountId, 'Debe tener AccountId asignado');
        System.assertNotEquals(null, opp.Contacto_Principal__c, 'Debe tener Contacto_Principal__c asignado');
    }

    @IsTest
    static void testCreateParam() {
        Parametrica__c valor =new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='ENERGY & UTILITIES',Mercado1__c='',Mercado2__c='',Mercado3__c='',
                                                 Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Utilities', Division2__c='Utilities' );
        Parametrica__c cr = TestDataFactory.createParam(
            new Map<String,Object>{
                'Name' => 'CR-Test',
                    'Codigo_Mercado__c' => '60029427',
                    'Mercado4__c' => 'ENERGY & UTILITIES',
                    'Tipo__c' => 'No',
                    'Valor__c' => 'No',
                    'Area__c' => 'ATC',
                    'Division__c' => 'Utilities',
                    'Division2__c' => 'Utilities'
                    });

    }

    @IsTest
    static void testCreateParam2() {
        Parametrica_2__c cr = TestDataFactory.createParam2(
            'Centro Responsabilidad',
            new Map<String,Object>{
                					'Name' => 'CR-Test',
                    'Centro_resp_Super__c' => 'CENTRO PRUEBA',
                    'Codigo_CR__c'         => '015',
                    'Horizontal__c'        => 'Digital impact',
                    'Desglose_importes__c' => 'No',
                    'CR_Importe_OCP__c'    => 1000,
                    'Estado__c'            => '1'
                    });
    }

    @IsTest
    static void testGetOpportunity() {
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact', 'IT_DS');
        Opportunity fetchedOpp = TestDataFactory.getOpportunity(opp.Id);
        System.assertNotEquals(null, fetchedOpp, 'Debe devolver la Opportunity por Id');
        System.assertEquals(opp.Id, fetchedOpp.Id, 'Ids deben coincidir');
    }
}
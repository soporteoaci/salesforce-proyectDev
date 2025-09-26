@IsTest
private class OpportunityTriggerTest {
    @TestSetup
    static void testSetup(){
        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
    }

    @IsTest
    static void testBeforeInsert() {

        // Verificar que se haya rellenado la Dirección de Operaciones
        Opportunity opp = [SELECT Id, Direccion_Operaciones__c FROM Opportunity][0];
        System.assertNotEquals(null, opp.Direccion_Operaciones__c,
                               'Debe rellenar el campo Direccion_Operaciones__c en before insert');
    }

    @IsTest
    static void testBeforeUpdate() {
        // Verificar que se haya rellenado la Dirección de Operaciones
        Opportunity opp = [SELECT Id, Direccion_Operaciones__c FROM Opportunity][0];

        // Cambiar StageName para disparar lógica de probabilidad
        opp.StageName = 'Closed Won';

        Test.startTest();
        update opp;
        opp.StageName = 'Presentada (negociación y cierre)';
        update opp;
        Test.stopTest();
        opp = [SELECT Id, Probability FROM Opportunity WHERE Id = :opp.Id];
    }

   // @IsTest
   // static void testAfterInsert() {
   //     // Verificar que se haya rellenado la Dirección de Operaciones
   //     Opportunity opp = [SELECT Id, Direccion_Operaciones__c FROM Opportunity][0];
//
    //    Test.startTest();
    //    insert opp;
    //    Test.stopTest();

    //    opp = [SELECT Id, Probability FROM Opportunity WHERE Id = :opp.Id];
     //   System.assertNotEquals(null, opp.Probability,
     //       'Debe restaurar probabilidad en after insert si estaba vacía');
    //}

}
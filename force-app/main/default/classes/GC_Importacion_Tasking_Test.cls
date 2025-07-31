@isTest(SeeAllData = true)
public class GC_Importacion_Tasking_Test {

    @isTest(SeeAllData = true)
    public static void test() {
		Contrato__c myContract = new Contrato__c();
        List<Contrato__c> contratos = [SELECT id, Codigo_SAP__c, Proyecto__r.Codigo__c, Id_Tasking__c, Id_tasking_Elemento_SAP_Contrato__c
                                       FROM Contrato__c
                                       WHERE Codigo_SAP__c != null AND Proyecto__r.Codigo__c != null
                                       LIMIT 1
                                      ];
        
        if (!contratos.isEmpty()) {
            myContract = contratos[0];
        } else {
            myContract.Codigo_SAP__c = 'SAP_TEST_001';
            myContract.Id_Tasking__c = 'TASK123';
            myContract.Id_tasking_Elemento_SAP_Contrato__c = 'TASK_SAP';
            myContract.Estado__c='ENMA';
            myContract.DivisionPicklist__c='V-AERONAUTICS';
            myContract.Mercado__c='60029505';
            
            // Simulamos también el campo relacionado Proyecto__r.Codigo__c, si es accedido por métodos
            Proyecto__c proyectoFake = new Proyecto__c(Codigo__c = 'PRJ001');
            insert proyectoFake;
            myContract.Proyecto__r = proyectoFake;
            insert myContract;
        }
        GC_Importacion_Tasking.contractInfo(myContract.Id);
        GC_Importacion_Tasking.test();

    }
}
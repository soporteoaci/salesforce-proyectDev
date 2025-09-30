@IsTest
public class CRM_IB_CPVControllerTest {

    @IsTest
    static void testValoresCPV() {
        
        //datos de pruebas
        Parametrica_2__c param1 = new Parametrica_2__c(
            Name = 'CPV',
            CPV__c = '30000000-1',
            Descripcion_CPV__c = 'CPV prueba 1',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CPV' LIMIT 1].Id
        );
        insert param1;
        system.debug('param1: '+param1);

        Parametrica_2__c param2 = new Parametrica_2__c(
            Name = 'CPV',
            CPV__c = '30000000-2',
            Descripcion_CPV__c = 'CPV prueba 2',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CPV' LIMIT 1].Id
        );
        insert param2;
        system.debug('param2: '+param2);
        
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;

        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Digital impact','IT_DS');
        opp.CPV_varios__c = '30000000-3 (CPV prueba 3);30000000-4 (CPV prueba 4)';
        update opp;
        

        // llamada al método valoresCPV
        Test.startTest();
        Map<String, Object> result = CRM_IB_CPVController.valoresCPV(opp.Id);
        Test.stopTest();

        // validación de datos
        List<String> opciones = (List<String>) result.get('opciones');
        List<String> valoresSeleccionados = (List<String>) result.get('valoresSeleccionados');

        System.assertEquals(2, opciones.size(), 'Debe haber 2 opciones disponibles.');
        System.assert(opciones.contains('30000000-1 (CPV prueba 1)'), 'La opción "30000000-1 (CPV prueba 1)" debería estar disponible.');
        System.assert(opciones.contains('30000000-2 (CPV prueba 2)'), 'La opción "30000000-2 (CPV prueba 2)" debería estar disponible.');

        System.assertEquals(2, valoresSeleccionados.size(), 'Debe haber 2 valores seleccionados.');
        System.assert(valoresSeleccionados.contains('30000000-3 (CPV prueba 3)'), 'El valor "30000000-3 (CPV prueba 3)" debería estar seleccionado.');
        System.assert(valoresSeleccionados.contains('30000000-4 (CPV prueba 4)'), 'El valor "30000000-4 (CPV prueba 4)" debería estar seleccionado.');
    }

    @IsTest
    static void testSaveOportunidadCPV() {
        
        //datos de prueba
        Parametrica_2__c param1 = new Parametrica_2__c(
            Name = 'CPV',
            CPV__c = '30000000-1',
            Descripcion_CPV__c = 'CPV prueba 1',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CPV' LIMIT 1].Id
        );
        insert param1;
        system.debug('param1: '+param1);
       
        No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
        saltar_trigger.Correo_usuario__c='';
        insert saltar_trigger;

        Opportunity opp = TestDataFactory.createOpportunity('Cualificación', 'Engineering Design & Architecture','Ingenier_a');
        opp.CPV_varios__c = '';
        opp.Bloqueo_por_aprobacion__c = True;
        update opp;

        // nueva selección de CPV
        String nuevaSeleccion = '30000000-2 (CPV prueba 2)';

        // llamada al método saveOportunidad_CPV
        Test.startTest();
        CRM_IB_CPVController.saveOportunidad_CPV(opp.Id, nuevaSeleccion);
        CRM_IB_CPVController.oportunidadBloqueada(opp.Id);
        Test.stopTest();

        // comprobción de datos
        Opportunity oppActualizada = [SELECT CPV_varios__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(nuevaSeleccion, oppActualizada.CPV_varios__c, 'El campo CPV_varios__c debería haberse actualizado con la nueva selección.');
    }
}
@IsTest
public class CRM_IB_Listado_Entornos_TecnologicosTest {

    @IsTest
    static void testGetEntornosTecnologicos() {
        
        // registro de Referencia_Comercial__c de prueba
        Referencia_Comercial__c refComercial = new Referencia_Comercial__c(
            Name = 'RefComercial Test',
            Entornos_tecnologicos__c = '.NET;.NET FRAMEWORK'
        );
        insert refComercial;

        // llamada método getEntornosTecnologicos
        Map<String, Object> result = CRM_IB_Listado_Entornos_Tecnologicos.getEntornosTecnologicos(refComercial.Id);

        // validación de datos
        List<String> opciones = (List<String>)result.get('opciones');
        List<String> valoresSeleccionados = (List<String>)result.get('valoresSeleccionados');

        System.assertEquals(2, valoresSeleccionados.size(), 'Debe haber 2 entornos tecnológicos seleccionados.');
        System.assert(!opciones.contains('.NET'), 'La opción ".NET" no debe estar disponible.');
        System.assert(!opciones.contains('.NET FRAMEWORK'), 'La opción ".NET FRAMEWORK" no debe estar disponible.');
        System.assert(valoresSeleccionados.contains('.NET'), 'El entorno ".NET" debe estar seleccionado.');
        System.assert(valoresSeleccionados.contains('.NET FRAMEWORK'), 'El entorno ".NET FRAMEWORK" debe estar seleccionado.');
    }

    @IsTest
    static void testSaveEntornosTecnologicos() {
        
        // registro de Referencia_Comercial__c de prueba
        Referencia_Comercial__c refComercial = new Referencia_Comercial__c(
            Name = 'RefComercial Test',
            Entornos_tecnologicos__c = ''
        );
        insert refComercial;

        // selección de un nuevo valor de entornos tecnológicos
        String nuevaSeleccion = '.NET FRAMEWORK';

        // llamada método saveEntornosTecnologicos
        CRM_IB_Listado_Entornos_Tecnologicos.saveEntornosTecnologicos(refComercial.Id, nuevaSeleccion);

        // validación de datos
        Referencia_Comercial__c refComercialActualizada = [SELECT Entornos_tecnologicos__c FROM Referencia_Comercial__c WHERE Id = :refComercial.Id LIMIT 1];

        System.assertEquals(nuevaSeleccion, refComercialActualizada.Entornos_tecnologicos__c, 'El campo Entornos_tecnologicos__c debe haberse actualizado con la nueva selección.');
    	// llamada método saveEntornosTecnologicos
        CRM_IB_Listado_Entornos_Tecnologicos.saveEntornosTecnologicos(refComercial.Id, '');
    }
}
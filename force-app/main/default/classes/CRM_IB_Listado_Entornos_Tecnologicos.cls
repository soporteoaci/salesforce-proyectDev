public class CRM_IB_Listado_Entornos_Tecnologicos {
   
    @AuraEnabled
    public static Map<String, Object> getEntornosTecnologicos(Id recordId) {

        System.debug('getEntornosTecnologicos...');
        
        Map<String, Object> result = new Map<String, Object>(); // mapa para almacenar las opciones disponibles y los valores seleccionados
		
        // obtenemos los entornos tecnológicos activos
        List<Parametrica_2__c> parametrica = [SELECT Name 
                                              FROM Parametrica_2__c 
                                              WHERE RecordType.Name = 'Entorno tecnológico' 
                                              AND Estado__c = '1' 
                                              ORDER BY Name];
        System.debug('entornos tecnológicos activos encontrados en la paramétrica: ' + parametrica.size());

        // los añadimos en una lista para el dualListbox
        List<String> opciones = new List<String>();
        for (Parametrica_2__c param : parametrica) {
            if (!opciones.contains(param.Name) && param.Name != null) {
                opciones.add(param.Name);
            }
        }
        result.put('opciones', opciones);

        // obtenermos los valores seleccionados previamente en el registro de referencia comercial
        if (recordId != null) {
            Referencia_Comercial__c refComercial = [SELECT Entornos_tecnologicos__c FROM Referencia_Comercial__c WHERE Id = :recordId LIMIT 1];
            if (refComercial.Entornos_tecnologicos__c != null) {
                List<String> valoresSeleccionados = refComercial.Entornos_tecnologicos__c.split(';');
                result.put('valoresSeleccionados', valoresSeleccionados);
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static void saveEntornosTecnologicos(Id recordId, String seleccionEntornoTecnologico) {
        System.debug('saveEntornosTecnologicos... Entornos Tecnológicos seleccionados: ' + seleccionEntornoTecnologico);
        
        if (String.isNotBlank(seleccionEntornoTecnologico)) {
            // obtenemos la referencia comercial
            Referencia_Comercial__c refComercial = [SELECT Id, Entornos_tecnologicos__c FROM Referencia_Comercial__c WHERE Id = :recordId LIMIT 1];
            // actualizamos el campo Entornos_tecnologicos__c con la selección
            try {
                refComercial.Entornos_tecnologicos__c = seleccionEntornoTecnologico;
                update refComercial;
                System.debug('Se ha actualizado la Referencia Comercial: ' + refComercial.Id);
            } catch(Exception e) { 
                System.debug('Error al actualizar la Referencia Comercial: ' + e.getMessage());
            }
        } else if (String.isBlank(seleccionEntornoTecnologico)) {
            try {
                // obtenemos la referencia comercial
                Referencia_Comercial__c refComercial = [SELECT Id, Entornos_tecnologicos__c FROM Referencia_Comercial__c WHERE Id = :recordId LIMIT 1];
                // actualizamos el campo Entornos_tecnologicos__c con valor nulo (no hay nada seleccionado)
                refComercial.Entornos_tecnologicos__c = seleccionEntornoTecnologico;
                update refComercial;
                System.debug('Se ha actualizado la Referencia Comercial: ' + refComercial.Id);
            } catch(Exception e) { 
                System.debug('Error al actualizar la Referencia Comercial: ' + e.getMessage());
            }
        }
    }
}
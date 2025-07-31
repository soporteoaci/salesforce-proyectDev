public class CRM_IB_CPVController {
   
    //Componente CPV
    @AuraEnabled
    public static Map<String, Object> valoresCPV(String Id_oportunidad){
        System.debug('CRM_IB_CPVController valoresCPV...');
        
        Map<String, Object> result = new Map<String, Object>(); // mapa para almacenar las opciones disponibles y los valores seleccionados
		
        // obtenemos los valores CPV de la parametrica
        List<Parametrica_2__c> valores_CPV = [SELECT Id, Name, CPV__c, Descripcion_CPV__c, RecordType.Name
                                               from Parametrica_2__c 
                                               where RecordType.Name = 'CPV' order by CPV__c];
        System.debug('valores CPV encontrados en la paramétrica: ' + valores_CPV.size());
        
        // los añadimos en una lista para el dualListbox
        List<String> opciones = new List<String>();
        for (Parametrica_2__c param : valores_CPV) {
            if (!opciones.contains(param.Name) && param.Name != null) {
                opciones.add(param.CPV__c + ' (' + param.Descripcion_CPV__c + ')');
            }
        }
        result.put('opciones', opciones);
        
        // obtenermos los valores seleccionados previamente en el registro de oportunidad
        if (Id_oportunidad != null) {
            Oportunidad__c opp = [SELECT Id, Name, CPV_varios__c FROM Oportunidad__c where Id =: Id_oportunidad];
            System.debug('Oportunidad recuperada "'+ opp.Name + '" y su/s valor/es CPV: ' + opp.CPV_varios__c  );
            if (opp.CPV_varios__c != null) {
                List<String> valoresSeleccionados = opp.CPV_varios__c.split(';');
                result.put('valoresSeleccionados', valoresSeleccionados);
            }
        }
        System.debug('valoresCPV result: ' + result);
        return result;
    }

    @AuraEnabled
    public static void saveOportunidad_CPV(Id Id_oportunidad, String seleccionCPV){
        
        System.debug('saveOportunidad_CPV... CPV seleccionados: ' + seleccionCPV);
        
        Oportunidad__c opp = [SELECT Id, Name, CPV_varios__c FROM Oportunidad__c where Id =: Id_oportunidad LIMIT 1];
        
        if (String.isNotBlank(seleccionCPV)) {
            try{
                opp.CPV_varios__c = seleccionCPV;
                update opp;
                system.debug('Actualizado');
            } catch(DMLException e){ 
                System.debug('Error CPV Oportunidad: ' + e.getMessage());            
            }	
        } else if (String.isBlank(seleccionCPV)) {
            try {
                opp.CPV_varios__c = seleccionCPV;
                update opp;
                system.debug('Actualizado');
            } catch(Exception e) { 
                System.debug('Error CPV Oportunidad: ' + e.getMessage());  
            }
        }
    }

}
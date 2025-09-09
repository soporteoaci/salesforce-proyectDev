public with sharing class CrearContactoDesdeOutlookCtrl {
    
    @AuraEnabled
    public static void guardarContacto(Map<String, Object> contacto) {
        System.debug('Contacto Ariel: ' + contacto);
        
        // Extraemos los valores del mapa
        String tratamiento = (String)(contacto.get('tratamiento') != null ? contacto.get('tratamiento') : '');
        String nombre = (String)(contacto.get('nombre') != null ? contacto.get('nombre') : '');
        String apellidos = (String)(contacto.get('apellidos') != null ? contacto.get('apellidos') : '');
        String email = (String)(contacto.get('email') != null ? contacto.get('email') : '');
        String cargo = (String)(contacto.get('cargo') != null ? contacto.get('cargo') : '');
        String cuenta = (String)(contacto.get('cuenta') != null ? contacto.get('cuenta') : '');
        String perfil = (String)(contacto.get('perfil') != null ? contacto.get('perfil') : '');
        String nivel = (String)(contacto.get('nivel') != null ? contacto.get('nivel') : '');
        String subnivel = (String)(contacto.get('subnivel') != null ? contacto.get('subnivel') : '');
        Boolean claveNegocio = (contacto.get('claveNegocio') != null ? (Boolean) contacto.get('claveNegocio') : false);
        
        // Creamos el contacto
        Contact nuevoContact = new Contact();
        nuevoContact.FirstName = nombre;
        nuevoContact.Salutation = tratamiento;
        nuevoContact.LastName = apellidos;
        nuevoContact.AccountId = cuenta;
        nuevoContact.Email = email;
        nuevoContact.Title = cargo;
        nuevoContact.PERFIL__c = perfil;
        nuevoContact.NIVEL__c = nivel;
        nuevoContact.SUBNIVEL__c = subnivel;
        nuevoContact.CLAVENEGOCIO__c = claveNegocio;
        
        // Intentamos guardar
        try {
            insert nuevoContact;
        } catch (DmlException e) {
            if (e.getDmlType(0) == StatusCode.DUPLICATES_DETECTED) {
                throw new AuraHandledException('Ya existe un contacto con este correo registrado en la cuenta.');
            } else {
                throw new AuraHandledException('Error al guardar el contacto: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static List<Map<String, String>> buscarCuentasPorNombre(String texto) {
        List<Account> cuentas = [
            SELECT Id, Name
            FROM Account
            WHERE Name LIKE :('%' + texto + '%')
            ORDER BY Name
            LIMIT 10
        ];
        
        List<Map<String, String>> resultados = new List<Map<String, String>>();
        for (Account acc : cuentas) {
            resultados.add(new Map<String, String>{
                'label' => acc.Name,
                    'value' => acc.Id
                    });
        }
        
        return resultados;
    }
    @AuraEnabled
    public static List<Map<String, String>> obtenerValoresPicklist(String objectName, String fieldName) {
        List<Map<String, String>> opciones = new List<Map<String, String>>();
        
        try {
            // Obtener el describe del objeto y luego del campo
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
            
            if (fieldDescribe != null && fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    Map<String, String> opcion = new Map<String, String>();
                    opcion.put('label', entry.getLabel());
                    opcion.put('value', entry.getValue());
                    opciones.add(opcion);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener valores de picklist: ' + e.getMessage());
        }
        
        return opciones;
    }
    
}
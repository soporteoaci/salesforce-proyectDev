public with sharing class EditarTareaOutlookController {
    
    @AuraEnabled
    public static Task obtenerTarea(Id tareaId) {
        return [SELECT Id, ActivityDate, Subject, Description, Start_Event__c, End_Event__c, Status,
                Estado__c, Como_ha_ido__c, Siguiente_Paso__c,
                Lineas_de_Servicio__c, Priority, Organizaci_n__c, 
                Tipo_Actividad_Administrador__c, WhatId, What.Name, WhoId, Who.Name,
                Enviada_Agenda__c, Enviado_Acuerdos__c
                FROM Task
                WHERE Id = :tareaId];
    }
    
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> obtenerPicklists() {
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        Schema.DescribeSObjectResult describeResult = Task.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
        
        for (String campo : new List<String>{
            'Estado__c','Status','Como_ha_ido__c','Siguiente_Paso__c','Lineas_de_Servicio__c',
                'Priority','Organizaci_n__c','Tipo_Actividad_Administrador__c'}) {
                    
                    List<Map<String, String>> opciones = new List<Map<String, String>>();
                    Schema.DescribeFieldResult fieldResult = fields.get(campo).getDescribe();
                    for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                        if (entry.isActive()) {
                            // Devolver tanto el label (para mostrar) como el value (para guardar)
                            opciones.add(new Map<String, String>{
                                'label' => entry.getLabel(),
                                'value' => entry.getValue()
                            });
                        }
                    }
                    result.put(campo, opciones);
                }
        
        return result;
    }
    
    /**
    * @description Obtiene las líneas de servicio separadas entre disponibles y seleccionadas
    * @param tareaId ID de la tarea
    * @return Map con dos listas: 'disponibles' y 'seleccionadas'
    */
    @AuraEnabled
    public static Map<String, List<Map<String, Object>>> obtenerLineasServicioPorTarea(Id tareaId) {
        // Obtener la tarea con las líneas de servicio guardadas
        Task tarea = [SELECT Id, Lineas_de_Servicio__c 
                     FROM Task 
                     WHERE Id = :tareaId 
                     LIMIT 1];
        
        // Obtener todas las opciones disponibles del picklist
        Schema.DescribeFieldResult fieldResult = Task.Lineas_de_Servicio__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        // Convertir las líneas seleccionadas en un Set para búsqueda rápida
        Set<String> lineasSeleccionadasSet = new Set<String>();
        if (String.isNotBlank(tarea.Lineas_de_Servicio__c)) {
            // Las líneas de servicio están separadas por punto y coma
            for (String linea : tarea.Lineas_de_Servicio__c.split(';')) {
                lineasSeleccionadasSet.add(linea.trim());
            }
        }
        
        // Separar en disponibles y seleccionadas
        List<Map<String, Object>> disponibles = new List<Map<String, Object>>();
        List<Map<String, Object>> seleccionadas = new List<Map<String, Object>>();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                Map<String, Object> opcion = new Map<String, Object>{
                    'label' => entry.getLabel(),
                    'value' => entry.getValue(),
                    'marked' => false
                };
                
                // Si está en el set de seleccionadas, agregarla a seleccionadas
                if (lineasSeleccionadasSet.contains(entry.getValue()) || 
                    lineasSeleccionadasSet.contains(entry.getLabel())) {
                    seleccionadas.add(opcion);
                } else {
                    disponibles.add(opcion);
                }
            }
        }
        
        return new Map<String, List<Map<String, Object>>>{
            'disponibles' => disponibles,
            'seleccionadas' => seleccionadas
        };
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
    public static void actualizarTarea(Task t) {
        if (t == null || t.Id == null) {
            throw new AuraHandledException('Tarea no válida o sin ID.');
        }
        
        try {
            update t;
        } catch (DmlException e) {
            System.debug('Error al actualizar la tarea: ' + e.getMessage());
            throw new AuraHandledException('No se pudo actualizar la tarea: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Map<String, String>> buscarContactosPorCuenta(Id cuentaId, String texto) {
        if (cuentaId == null) {
            return new List<Map<String, String>>();
        }
        
        String query = 'SELECT Id, Name FROM Contact WHERE AccountId = :cuentaId';
        
        if (String.isNotBlank(texto)) {
            query += ' AND Name LIKE :texto';
            texto = '%' + texto + '%';
        }
        
        query += ' ORDER BY Name LIMIT 10';
        
        List<Contact> contactos = Database.query(query);
        
        List<Map<String, String>> resultados = new List<Map<String, String>>();
        for (Contact c : contactos) {
            resultados.add(new Map<String, String>{
                'label' => c.Name,
                'value' => c.Id
            });
        }
        return resultados;
    }

    @AuraEnabled
    public static String obtenerNombreContacto(Id contactoId) {
        if (contactoId == null) return '';
        Contact c = [SELECT Name FROM Contact WHERE Id = :contactoId LIMIT 1];
        return c != null ? c.Name : '';
    }

}
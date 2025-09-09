public with sharing class EditarTareaOutlookController {
    
    @AuraEnabled
    public static Task obtenerTarea(Id tareaId) {
        return [SELECT Id, ActivityDate, Subject, Description, Start_Event__c, End_Event__c, Status,
                Estado__c, Como_ha_ido__c, Siguiente_Paso__c,
                Lineas_de_Servicio__c, Priority, Organizaci_n__c, 
                Tipo_Actividad_Administrador__c, WhatId, What.Name,
                Enviada_Agenda__c, Enviado_Acuerdos__c
                FROM Task
                WHERE Id = :tareaId];
    }
    
    @AuraEnabled
    public static Map<String, List<String>> obtenerPicklists() {
        Map<String, List<String>> result = new Map<String, List<String>>();
        Schema.DescribeSObjectResult describeResult = Task.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
        
        for (String campo : new List<String>{
            'Estado__c','Status','Como_ha_ido__c','Siguiente_Paso__c','Lineas_de_Servicio__c',
                'Priority','Organizaci_n__c','Tipo_Actividad_Administrador__c'}) {
                    
                    List<String> opciones = new List<String>();
                    Schema.DescribeFieldResult fieldResult = fields.get(campo).getDescribe();
                    for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                        if (entry.isActive()) {
                            opciones.add(entry.getLabel());
                        }
                    }
                    result.put(campo, opciones);
                }
        
        return result;
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
    
}
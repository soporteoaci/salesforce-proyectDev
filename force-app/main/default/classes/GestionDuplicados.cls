public with sharing class GestionDuplicados {

    public class InputWrapper {
        @InvocableVariable(label = 'Id del registro a conservar')
        public Id idConservar;

        @InvocableVariable(label = 'Id del registro duplicado')
        public Id idDuplicado;

        @InvocableVariable(label = 'API Name del Objeto')
        public String objeto;
    }

    public class ResultadoFusion {
        @InvocableVariable
        public Boolean exito;

        @InvocableVariable
        public String mensaje;

        @InvocableVariable
        public List<String> errores = new List<String>();
    }

    @InvocableMethod(label='Fusionar Registros Duplicados')
    public static List<ResultadoFusion> fusionarRegistros(List<InputWrapper> inputs) {
        
        System.debug('fusionarRegistros - INPUTS: ' + inputs);
        List<ResultadoFusion> resultados = new List<ResultadoFusion>();

        for (InputWrapper input : inputs) {
            ResultadoFusion resultado = new ResultadoFusion();
            resultado.exito = true;
            List<String> errores = new List<String>();

            try {
                String objetoApi = input.objeto;
                Id idConservar = input.idConservar;
                Id idDuplicado = input.idDuplicado;

                Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objetoApi);
                if (sObjectType == null) {
                    resultado.exito = false;
                    resultado.mensaje = 'Objeto no válido: ' + objetoApi;
                    resultados.add(resultado);
                    continue;
                }

                // método que informa los campos vacíos del registro a conservar
                informarCamposVacios(objetoApi, idConservar, idDuplicado, errores);
                
                // método que reasigna los relacionados del registro duplicado al que se va a conservar
                reasignarRelacionados(objetoApi, idConservar, idDuplicado, errores);

                resultado.exito = errores.isEmpty();
                resultado.errores = errores;
                resultado.mensaje = resultado.exito ? 'Fusión completada sin errores' : 'Fusión completada con errores: ' + String.join(errores, ' | ');

            } catch (Exception e) {
                resultado.exito = false;
                resultado.mensaje = 'Error general durante la fusión: ' + e.getMessage();
                resultado.errores.add(e.getMessage());
                System.debug('SCM - Error general en fusionarRegistros: ' + e.getMessage());
            }

            resultados.add(resultado);
        }

        return resultados;
    }
    
    
    
    // método que informa los campos vacíos del registro a conservar
    private static void informarCamposVacios(String objetoApi, Id idConservar, Id idDuplicado, List<String> errores) {
        System.debug('informarCamposVacios - inicio');
        
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objetoApi);
            Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();

            List<String> fieldNames = new List<String>();
            for (String field : fieldsMap.keySet()) {
                if (field != 'Id' && !field.endsWith('__r')) {
                    fieldNames.add(field);
                }
            }
            System.debug('informarCamposVacios - campos ' + String.join(fieldNames, ','));

            String fieldList = 'Id,' + String.join(fieldNames, ',');
            String soql = 'SELECT ' + fieldList + ' FROM ' + objetoApi + ' WHERE Id =: idConservar';
            String soqlDup = 'SELECT ' + fieldList + ' FROM ' + objetoApi + ' WHERE Id =: idDuplicado';

            SObject conservar = Database.query(soql);
            SObject duplicado = Database.query(soqlDup);

            for (String campo : fieldNames) {
                Schema.SObjectField sfield = fieldsMap.get(campo);
                Schema.DescribeFieldResult fieldDescribe = sfield.getDescribe();
                
                // Añadir debugs para el campo Description
                if(campo == 'Description') {
                    System.debug('SCM - Description encontrado');
                    System.debug('SCM - Es actualizable?: ' + fieldDescribe.isUpdateable());
                    System.debug('SCM - Valor original: ' + conservar.get(campo));
                    System.debug('SCM - Valor duplicado: ' + duplicado.get(campo));
                }

                if (!fieldDescribe.isUpdateable()) {
                    System.debug('SCM - Campo no editable, se omite: ' + campo);
                    continue;
                }

                Object valorOriginal = conservar.get(campo);
                Object valorDuplicado = duplicado.get(campo);

                // Lógica especial para Sector__c y Subsector__c
                if (fieldsMap.containsKey('Subsector__c') && fieldsMap.containsKey('Sector__c') && (campo == 'Sector__c' || campo == 'Subsector__c')) {
                    Object subsectorConservar = conservar.get('Subsector__c');
                    Object sectorConservar = conservar.get('Sector__c');
                    Object subsectorDuplicado = duplicado.get('Subsector__c');
                    Object sectorDuplicado = duplicado.get('Sector__c');
                    Boolean subsectorConservarVacio = (subsectorConservar == null || String.valueOf(subsectorConservar).trim() == '');
                    Boolean sectorConservarVacio = (sectorConservar == null || String.valueOf(sectorConservar).trim() == '');
                    Boolean subsectorDuplicadoLleno = (subsectorDuplicado != null && String.valueOf(subsectorDuplicado).trim() != '');
                    Boolean sectorDuplicadoLleno = (sectorDuplicado != null && String.valueOf(sectorDuplicado).trim() != '');

                    // Si ambos están vacíos, copia ambos (solo cuando campo == 'Sector__c')
                    if (campo == 'Sector__c' && sectorConservarVacio && subsectorConservarVacio && sectorDuplicadoLleno && subsectorDuplicadoLleno) {
                        try {
                            conservar.put('Sector__c', sectorDuplicado);
                            conservar.put('Subsector__c', subsectorDuplicado);
                            System.debug('SCM - Sector__c y Subsector__c actualizados por lógica especial: ' + sectorDuplicado + ', ' + subsectorDuplicado);
                        } catch (Exception e) {
                            String msg = 'Error en campos Sector__c/Subsector__c (lógica especial): ' + e.getMessage();
                            errores.add(msg);
                            System.debug('SCM - Mensaje de error: ' + msg);
                        }
                        continue; // Ya tratados ambos campos
                    }
                    // Si solo Subsector__c está vacío, pero Sector__c coincide (solo cuando campo == 'Subsector__c')
                    else if (campo == 'Subsector__c' && subsectorConservarVacio && !sectorConservarVacio && sectorDuplicadoLleno && subsectorDuplicadoLleno
                        && String.valueOf(sectorConservar).trim().toLowerCase() == String.valueOf(sectorDuplicado).trim().toLowerCase()) {
                        try {
                            conservar.put('Subsector__c', subsectorDuplicado);
                            System.debug('SCM - Subsector__c actualizado por lógica especial: ' + subsectorDuplicado);
                        } catch (Exception e) {
                            String msg = 'Error en campo Subsector__c (lógica especial): ' + e.getMessage();
                            errores.add(msg);
                            System.debug('SCM - Mensaje de error: ' + msg);
                        }
                        continue; // Ya tratado
                    }
                    continue; // Evita el tratamiento estándar para estos campos
                }

                // Tratamiento estándar para el resto de campos
                if ((valorOriginal == null || String.valueOf(valorOriginal).trim() == '') && valorDuplicado != null) {
                    try {
                        conservar.put(campo, valorDuplicado);
                        System.debug('SCM - Campo actualizado: ' + campo + ' -> ' + valorDuplicado);
                    } catch (Exception e) {
                        String msg = 'Error en campo ' + campo + ': ' + e.getMessage();
                        errores.add(msg);
                        System.debug('SCM - Mensaje de error: ' + msg);
                    }
                }
            }

            update conservar;
            
        } catch (Exception e) {
            errores.add('Error al informar campos: ' + e.getMessage());
            System.debug('SCM - Error al informar campos: ' + e.getMessage());
        }
        
        System.debug('informarCamposVacios - fin');
    }
    
    
    
    // método que reasigna los relacionados del registro duplicado al que se va a conservar
    private static void reasignarRelacionados(String objetoApi, Id idConservar, Id idDuplicado, List<String> errores) {
        System.debug('reasignarRelacionados - inicio');
        
        try {
            Map<String, Set<String>> permitidos = new Map<String, Set<String>>{
                'Contact' => new Set<String>{ 'Account', 'Oportunidad__c', 'Contactos_Campanyas__c', 'Task' },
                'Account' => new Set<String>{ 'Account', 'Contact', 'Oportunidad__c', 'Objetivo__c', 'Task', 'Referencia_Comercial__c', 'Activo__c' }
            };
    
            Set<String> relacionadosValidos = permitidos.get(objetoApi);
    
            Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objetoApi).getDescribe();

            for (Schema.ChildRelationship relacion : describe.getChildRelationships()) {
            
                try {
                    if (relacion.getField() == null || relacion.getRelationshipName() == null || relacion.isCascadeDelete()) {
                        continue;
                    }
    
                    String objetoHijo = relacion.getChildSObject().getDescribe().getName();
                    System.debug('SCM - objetoHijo detectado: ' + objetoHijo);
                    
                    if (!relacionadosValidos.contains(objetoHijo)) {
                        continue;
                    }
    
                    String campoRelacion = relacion.getField().getDescribe().getName();
                    String soql = 'SELECT Id FROM ' + objetoHijo + ' WHERE ' + campoRelacion + ' = :idDuplicado';
                    System.debug('SCM - Ejecutando SOQL: ' + soql);
    
                    List<SObject> relacionados = Database.query(soql);
    
                    if (relacionados.isEmpty()) {
                        System.debug('SCM - No hay registros relacionados en ' + objetoHijo + ' con ' + campoRelacion + ' = ' + idDuplicado);
                        continue;
                    }
    
                    for (SObject rel : relacionados) {
                        rel.put(campoRelacion, idConservar);
                    }
    
                    update relacionados;
                    System.debug('SCM - Reasignados ' + relacionados.size() + ' registros de ' + objetoHijo + ' al registro a conservar');
    
                } catch (Exception e) {
                    String msg = 'Error en relación con ' + relacion.getChildSObject() + ': ' + e.getMessage();
                    errores.add(msg);
                    System.debug('SCM - Mensaje de error: ' + msg);
                }
            }
            
            // SCM - si es un account, que me reasigne los contactos también, que no me aparecen en getChildRelationships
            if (objetoApi == 'Account') {
                try {
                    List<Contact> contactos = [SELECT Id FROM Contact WHERE AccountId = :idDuplicado];
                    for (Contact c : contactos) {
                        c.AccountId = idConservar;
                    }
                    if (!contactos.isEmpty()) {
                        update contactos;
                    }
                    System.debug('SCM - Reasignados ' + contactos.size() + ' contactos de forma independiente');
                } catch (Exception e) {
                    errores.add('Error reasignando contactos: ' + e.getMessage());
                    System.debug('SCM - Error reasignando contactos de forma independiente: ' + e.getMessage());
                }
            }
            
            // SCM - que me reasigne Task también, que no me aparece en getChildRelationships
            if (objetoApi == 'Account' || objetoApi == 'Contact') {
                List <Task> tareas = new List<Task>();
                try {
                    if (objetoApi == 'Account') {
                        tareas = [SELECT Id FROM Task WHERE WhatId =:idDuplicado OR Clic_comercial__c =:idDuplicado];
                        for (Task t : tareas) {
                            t.WhatId = idConservar;
                            t.Clic_comercial__c = idConservar;
                        }
                    } else if ( objetoApi == 'Contact' ) {
                        tareas = [SELECT Id FROM Task WHERE WhoId = :idDuplicado OR Contacto__c =:idDuplicado];
                        for (Task t : tareas) {
                            t.WhoId = idConservar;
                            t.Contacto__c = idConservar;
                        }
                    }
                    
                    if (!tareas.isEmpty()) {
                        update tareas;
                    }
                    System.debug('SCM - Reasignados ' + tareas.size() + ' tareas de forma independiente');
                } catch (Exception e) {
                    errores.add('Error reasignando tareas: ' + e.getMessage());
                    System.debug('SCM - Error reasignando tareas de forma independiente: ' + e.getMessage());
                }                
                
            }

            
            
        } catch (Exception e) {
            errores.add('Error al reasignar los relacionados: ' + e.getMessage());
            System.debug('SCM - Error general en reasignarRelacionados:' + e.getMessage());
        }
        
        System.debug('reasignarRelacionados - fin');
    }
    
}
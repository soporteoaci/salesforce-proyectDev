public class TareasOutlookController {
    
    @AuraEnabled
    public static List<Map<String, Object>> obtenerTareasDelUsuario(Date fechaInicio, Date fechaFin, String filtroEstado, String filtroPrioridad, Id cuentaId) {
        Id userId = UserInfo.getUserId();
        List<Task> tareas;
        
        System.debug('>> [INICIO] Obtener tareas del usuario: ' + userId);
        System.debug('>> Filtros recibidos -> fechaInicio: ' + fechaInicio + ', fechaFin: ' + fechaFin + ', filtroEstado: ' + filtroEstado + ', filtroPrioridad: ' + filtroPrioridad + ', cuentaId: ' + cuentaId);
        
        // Valores para filtrar por Status
        List<String> estadosAgendadas = new List<String>{'Agendada', 'Planificada'};
        List<String> estadosRealizadas = new List<String>{'Realizada', 'No realizada'};
        
        String queryBase = 
            'SELECT Id, Subject, Status, ActivityDate, Priority, WhatId, WhoId, Start_Event__c, End_Event__c, Tarea_Padre__c, ' +
            'Who.Name, What.Name, Description, Enviada_Agenda__c, Enviado_Acuerdos__c ' +
            'FROM Task ' +
            'WHERE OwnerId = :userId AND Tarea_Padre__c = null';
        
        // Filtro por fechas
        if (fechaInicio != null && fechaFin != null) {
            queryBase += ' AND ActivityDate >= :fechaInicio AND ActivityDate <= :fechaFin';
        } else if (fechaInicio != null) {
            queryBase += ' AND ActivityDate >= :fechaInicio';
        } else if (fechaFin != null) {
            queryBase += ' AND ActivityDate <= :fechaFin';
        } else {
            queryBase += ' AND ActivityDate = :Date.today()';
        }
        
        // Filtro por estado
        if (filtroEstado == 'Agendadas') {
            queryBase += ' AND Status IN :estadosAgendadas';
        } else if (filtroEstado == 'Realizadas') {
            queryBase += ' AND Status IN :estadosRealizadas';
        }
        // Filtro por prioridad
        if (String.isNotBlank(filtroPrioridad)) {
            System.debug('>> Aplicando filtro de prioridad: ' + filtroPrioridad);
            queryBase += ' AND Priority = :filtroPrioridad';
        }
        // Filtro por cuenta (WhatId)
        if (cuentaId != null) {
            System.debug('>> Aplicando filtro de cuenta: ' + cuentaId);
            queryBase += ' AND WhatId = :cuentaId';
        }
        String orden = ' ORDER BY ActivityDate DESC LIMIT 100';
        String queryFinal = queryBase + orden;
        System.debug('>> Query final: ' + queryFinal);
        tareas = Database.query(queryFinal);
        
        System.debug('>> Total tareas encontradas: ' + tareas.size());
        
        // Construimos el resultado
        String baseUrl = obtenerBaseUrl();
        List<Map<String, Object>> resultado = new List<Map<String, Object>>();
        for (Task t : tareas) {
            String urlTarea = baseUrl + '/' + t.Id;
            resultado.add(new Map<String, Object>{
                'Id' => t.Id,
                'Subject' => t.Subject,
                'Status' => t.Status,
                'ActivityDate' => t.ActivityDate,
                'Priority' => t.Priority,
                'WhoId' => t.WhoId,
                'horaInicio' => t.Start_Event__c,
                'horaFin' => t.End_Event__c,
                'Contacto' => t.Who != null ? t.Who.Name : '',
                'Cuenta' => t.What != null ? t.What.Name : '',
                'Description' => t.Description,
                'Enviada_Agenda__c' => t.Enviada_Agenda__c,
                'Enviado_Acuerdos__c' => t.Enviado_Acuerdos__c,
                'UrlTarea' => urlTarea
            });
        }
        
        System.debug('>> Total resultados devueltos: ' + resultado.size());
        return resultado;
    }

    // MÉTODO MODIFICADO PARA INCLUIR CAMPOS NUEVOS
    @AuraEnabled
    public static void crearReunionConContactos(
        Datetime fecha, Id contactoId, Id cuentaId,
        String subject, String prioridad, String lineasServicio, 
        String sectorMercado, String description, 
        Boolean enviadaAgenda, Boolean enviadaAcuerdos
    ) {
        if (fecha < Date.today()) {
            throw new AuraHandledException('Debe seleccionar un día después de hoy');
        }
        
        Id userId = UserInfo.getUserId();
        
        Id recordTypeIdVisitas = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Task' AND DeveloperName = 'Visitas' 
            LIMIT 1
        ].Id;
        
        // CREAR EVENTO
        Event reunion = new Event(
            Subject = subject,
            ActivityDate = fecha.date(),
            StartDateTime = fecha,
            EndDateTime = fecha.addHours(1),
            OwnerId = userId,
            WhatId = cuentaId
        );
        insert reunion;
        
        System.debug('Lineas_de_Servicio__c: ' + lineasServicio);
        System.debug('ContactoId recibido: ' + contactoId);
        
        // CREAR UNA SOLA TAREA CON EL CONTACTO SELECCIONADO
        Task tareaVisita = new Task(
            RecordTypeId = recordTypeIdVisitas,
            Tipoact__c = 'Cita',
            Subject = subject,
            Status = 'Agendada',
            Priority = String.isNotBlank(prioridad) ? prioridad : 'Normal',
            ActivityDate = Date.newInstance(fecha.year(), fecha.month(), fecha.day()),
            OwnerId = userId,
            WhatId = cuentaId,
            WhoId = contactoId, // Asignar el contacto seleccionado
            Id_Evento__c = reunion.Id,
            Description = description,
            Origen_Tarea__c = 'Reunión - Visita',
            Lineas_de_Servicio__c = esValorPicklistValido('Task', 'Lineas_de_Servicio__c', lineasServicio),
            Organizaci_n__c = esValorPicklistValido('Task', 'Organizaci_n__c', sectorMercado),
            Enviada_Agenda__c = enviadaAgenda,
            Enviado_Acuerdos__c = enviadaAcuerdos
        );
        insert tareaVisita;
        
        System.debug('Tarea creada con ID: ' + tareaVisita.Id + ' y WhoId: ' + tareaVisita.WhoId);
    }
    
    @AuraEnabled
    public static List<Map<String, String>> obtenerContactosDeCuenta(Id cuentaId) {
        if (cuentaId == null) return new List<Map<String, String>>();
        
        List<Contact> contactos = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE AccountId = :cuentaId AND Email != null
            ORDER BY LastName, FirstName
        ];
        
        List<Map<String, String>> opciones = new List<Map<String, String>>();
        for (Contact c : contactos) {
            String nombreCompleto = c.FirstName + ' ' + c.LastName;
            if (String.isBlank(nombreCompleto)) {
                nombreCompleto = c.Email;
            }
            
            opciones.add(new Map<String, String>{
                'label' => nombreCompleto,
                    'value' => c.Id
                    });
        }
        
        return opciones;
    }
    
    // ===========================================
    // NUEVO: DEVOLVER VALORES DE PICKLISTS
    // ===========================================
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> obtenerValoresPicklists() {
        Map<String, List<String>> resultado = new Map<String, List<String>>();
        
        // Obtener valores para Lineas de Servicio
        Schema.DescribeFieldResult lineasServicioField = Task.Lineas_de_Servicio__c.getDescribe();
        List<String> opcionesLineas = new List<String>();
        for (Schema.PicklistEntry entry : lineasServicioField.getPicklistValues()) {
            opcionesLineas.add(entry.getLabel());
        }
        resultado.put('Lineas_de_Servicio__c', opcionesLineas);
        
        // Obtener valores para Sector de Mercado (Organizaci_n__c)
        Schema.DescribeFieldResult sectorField = Task.Organizaci_n__c.getDescribe();
        List<String> opcionesSector = new List<String>();
        for (Schema.PicklistEntry entry : sectorField.getPicklistValues()) {
            opcionesSector.add(entry.getLabel());
        }
        resultado.put('Organizaci_n__c', opcionesSector);
        
        // Prioridad
        Schema.DescribeFieldResult prioridadField = Task.Priority.getDescribe();
        List<String> opcionesPrioridad = new List<String>();
        for (Schema.PicklistEntry entry : prioridadField.getPicklistValues()) {
            if (entry.isActive()) {
                opcionesPrioridad.add(entry.getLabel());
            }
        }
        resultado.put('Priority', opcionesPrioridad);
        
        System.debug('>> Opciones de Priority devueltas: ' + opcionesPrioridad);
        System.debug('>> Resultado completo: ' + resultado);
        
        return resultado;
    }
    
    @AuraEnabled
    public static void actualizarTareas(List<Task> tareasActualizadas) {
        System.debug('Tareas a actualizar: ' + JSON.serializePretty(tareasActualizadas));
        if (tareasActualizadas == null || tareasActualizadas.isEmpty()) {
            throw new AuraHandledException('No se proporcionaron tareas para actualizar.');
        }
        
        // Validar tareas no completadas
        for (Task t : tareasActualizadas) {
            if (t.Status != null && t.Status.toLowerCase() == 'realizada') {
                throw new AuraHandledException('No se pueden modificar tareas que están ya realizadas');
            }
            
            // Asignar valores por defecto si faltan
            if (String.isBlank(t.Status)) {
                t.Status = 'Not Started';
            }
            if (String.isBlank(t.Priority)) {
                t.Priority = 'Normal';
            }
        }
        
        if(!Test.isRunningTest()){
            try {
                update tareasActualizadas;
            } catch (DmlException e) {
                throw new AuraHandledException('Error al actualizar tareas: ' + e.getMessage());
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
        
        List<Map<String, String>> opciones = new List<Map<String, String>>();
        for (Account acc : cuentas) {
            opciones.add(new Map<String, String>{
                'label' => acc.Name,
                    'value' => acc.Id
                    });
        }
        
        return opciones;
    }
    
    @AuraEnabled
    public static Map<String, Object> obtenerDetalleContacto(String tareaId) {
        try {
            Task tarea = [SELECT WhoId, Who.Name, Who.Email, Who.Phone 
                         FROM Task 
                         WHERE Id = :tareaId 
                         LIMIT 1];
            
            if (tarea.WhoId != null && tarea.Who != null) {
                return new Map<String, Object>{
                    'Name' => tarea.Who.Name,
                    'Email' => tarea.Who.Email,
                    'Phone' => tarea.Who.Phone
                };
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener detalle del contacto: ' + e.getMessage());
        }
    }
    private static String esValorPicklistValido(String objeto, String campo, String valor) {
        if (String.isBlank(valor)) return null;
        valor = valor.replace('&amp;', '&');
        Schema.DescribeFieldResult campoDesc = Schema.getGlobalDescribe()
            .get(objeto)
            .getDescribe()
            .fields.getMap()
            .get(campo)
            .getDescribe();
        
        // Log all picklist entries for debugging
        System.debug('Picklist entries for ' + objeto + '.' + campo + ':');
        for (Schema.PicklistEntry entry : campoDesc.getPicklistValues()) {
            System.debug('Label: "' + entry.getLabel() + '", API: "' + entry.getValue() + '"');
        }
        
        // Handle multiple values separated by ';'
        List<String> valores = valor.split(';');
        List<String> valoresValidos = new List<String>();
        for (String val : valores) {
            val = val.trim();
            Boolean encontrado = false;
            for (Schema.PicklistEntry entry : campoDesc.getPicklistValues()) {
                String label = entry.getLabel().replace('&amp;', '&').trim();
                String apiValue = entry.getValue().trim();
                if (label.equalsIgnoreCase(val) || apiValue.equalsIgnoreCase(val)) {
                    valoresValidos.add(apiValue);
                    encontrado = true;
                    break;
                }
            }
            if (!encontrado) {
                System.debug('Valor no válido encontrado: ' + val);
            }
        }
        return valoresValidos.isEmpty() ? null : String.join(valoresValidos, ';');
    }
    
    @AuraEnabled
    public static String obtenerBaseUrl() {
        // Devuelve la URL base del entorno actual (ej: https://miempresa--sandbox.lightning.force.com)
        return URL.getOrgDomainUrl().toExternalForm();
    }
}
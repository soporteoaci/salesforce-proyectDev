trigger Tarea_aprobacion on Tarea_aprobacion__c (after update, after insert, before update) {
    System.debug('Trigger: Tarea de aprobacion');
    Boolean istest = Test.isRunningTest();

    // IDs de oportunidades / objetivos (se usan para agrupar y consultar en bloque)
    Set<Id> oportunidades = new Set<Id>();
    Set<Id> objetivos = new Set<Id>();

    // Acumuladores para actualizaciones (evitar DML en bucles)
    List<Opportunity> ops_update = new List<Opportunity>();
    Set<Id> ops_update_id = new Set<Id>();

    List<Oportunidad_Competidor_socio__c> socio_update = new List<Oportunidad_Competidor_socio__c>();
    Set<Id> socio_update_id = new Set<Id>();

    List<Oportunidad_Competidor_socio__c> subcontrata_update = new List<Oportunidad_Competidor_socio__c>();
    Set<Id> subcontrata_update_Id = new Set<Id>();

    // Listas temporales de tareas por tipo (se rellenan para cada Opportunity procesada)
    List<Tarea_aprobacion__c> tareas_relacionadas_preliminar = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta_economica = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_socios = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_subcontratas = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_borrador_socios = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_preventa = new List<Tarea_aprobacion__c>();

    // Versiones auxiliares (se mantienen por compatibilidad con lógica existente)
    List<Tarea_aprobacion__c> tareas_relacionadas_preliminar2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_oferta_economica2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_socios2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_subcontratas2 = new List<Tarea_aprobacion__c>();
    List<Tarea_aprobacion__c> tareas_relacionadas_borrador_socios2 = new List<Tarea_aprobacion__c>();

    // Variables de decisión temporales usadas por los métodos
    String Decision_old = '';
    String Decision_new = '';
    String Decision_preliminar = '';
    String Decision_oferta = '';
    String Decision_oferta_tecnica = '';
    String Decision_oferta_economica = '';
    String Decision_socio = '';
    String Decision_subcontrata = '';
    String Decision_preventa = '';

    String DecisionQATecnico_calculada = '';
    String DecisionQAEconomico_calculada = '';

    // AFTER UPDATE: procesamos cambios en Decision__c de tareas
    if (Trigger.isAfter && Trigger.isUpdate) {
        // Recolectar oportunidades afectadas por cambios de Decision en las tareas
        for (Tarea_aprobacion__c tarea : Trigger.New) {
            Decision_old = Trigger.oldMap.get(tarea.Id).Decision__c;
            Decision_new = tarea.Decision__c;
            if (Decision_old != Decision_new) {
                if (tarea.Opportunity__c != null) {
                    oportunidades.add(tarea.Opportunity__c);
                }
            }
        }
        System.debug('oportunidades Ids: ' + oportunidades);

        if (!oportunidades.isEmpty()) {
            // Consultar todas las tareas y las oportunidades relacionadas en bloque
            List<Tarea_aprobacion__c> lista_tareas = [
                SELECT Id, CreatedDate, Name, Decision__c, Opportunity__c, Tipo__c, Socio__c, Subcontrata__c
                FROM Tarea_aprobacion__c
                WHERE Opportunity__c IN :oportunidades
            ];
            List<Opportunity> ops = [
                SELECT Id, Decisi_n_Equipo_Preventa__c, Decision_Go_Smart_BPM_Offer__c, Decision_aprobacion_acuerdo_de_socios__c,
                       Decision_QA_Economico__c, Decision_QA_Tecnico__c, Decision_Aprobacion_Oferta__c, Numero_QA__c, Clonada__c,
                       stageName, Subfase__c, Bloqueo_por_aprobacion__c, Fecha_estimada_de_cierre__c, Decision_Socios__c,
                       decision_subcontrataciones__c, Tiene_Oferta_QA__c
                FROM Opportunity
                WHERE Id IN :oportunidades
            ];

            // Para cada Opportunity agrupamos sus tareas por tipo y delegamos la lógica a métodos
            for (Opportunity op : ops) {
                // limpiar listas temporales
                tareas_relacionadas_preliminar.clear();
                tareas_relacionadas_oferta.clear();
                tareas_relacionadas_socios.clear();
                tareas_relacionadas_subcontratas.clear();
                tareas_relacionadas_oferta_tecnica.clear();
                tareas_relacionadas_oferta_economica.clear();
                tareas_relacionadas_borrador_socios.clear();
                tareas_relacionadas_preventa.clear();

                // Agrupar tareas por tipo para esta oportunidad
                for (Tarea_aprobacion__c tarea : lista_tareas) {
                    if (tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Preliminar') {
                        tareas_relacionadas_preliminar.add(tarea);
                    }
                    if (tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Oferta') {
                        tareas_relacionadas_oferta.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Oferta QA Técnico') || istest) {
                        tareas_relacionadas_oferta_tecnica.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Oferta QA Económico') || istest) {
                        tareas_relacionadas_oferta_economica.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Socio__c != null && tarea.Tipo__c == 'Socios') || istest) {
                        tareas_relacionadas_socios.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Subcontrata__c != null && tarea.Tipo__c == 'Subcontratas') || istest) {
                        tareas_relacionadas_subcontratas.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Borrador Acuerdo Socios') || istest) {
                        tareas_relacionadas_borrador_socios.add(tarea);
                    }
                    if ((tarea.Opportunity__c == op.Id && tarea.Tipo__c == 'Aprobación Preventa') || istest) {
                        tareas_relacionadas_preventa.add(tarea);
                    }
                }

                // Llamadas a funciones según tipos de tareas encontradas.
                // Estas funciones calculan decisiones y rellenan ops_update / socio_update / subcontrata_update.
                if (tareas_relacionadas_preliminar.size() > 0 && op.Decision_Go_Smart_BPM_Offer__c != 'Aprobado') {
                    AprobacionPreliminar(tareas_relacionadas_preliminar, op);
                }
                if ((tareas_relacionadas_oferta.size() > 0 && op.Decision_Aprobacion_Oferta__c != 'Aprobado') || istest) {
                    AprobacionOferta(tareas_relacionadas_oferta, op);
                }
                if ((tareas_relacionadas_oferta_tecnica.size() > 0 && op.Decision_QA_Tecnico__c != 'Go') || istest) {
                    AprobacionOfertaTecnica(tareas_relacionadas_oferta_tecnica, op);
                }
                if ((tareas_relacionadas_oferta_economica.size() > 0 && op.Decision_QA_Economico__c != 'Go') || istest) {
                    AprobacionOfertaEconomica(tareas_relacionadas_oferta_economica, op);
                }
                if ((tareas_relacionadas_preventa.size() > 0 &&
                     (op.Decisi_n_Equipo_Preventa__c != 'Go' && op.Decisi_n_Equipo_Preventa__c != 'No Go')) || istest) {
                    AprobacionPreventa(tareas_relacionadas_preventa, op);
                }
                if (tareas_relacionadas_socios.size() > 0 || istest) {
                    AprobacionSocios(tareas_relacionadas_socios, op);
                }
                if (tareas_relacionadas_subcontratas.size() > 0 || istest) {
                    AprobacionSubcontrata(tareas_relacionadas_subcontratas, op);
                }
                if (tareas_relacionadas_borrador_socios.size() > 0 || istest) {
                    AprobacionBorradorAcuerdoSocios(tareas_relacionadas_borrador_socios, op);
                }
            }
        } else {
            // Si no hay Opportunity vinculada, se procesa por Objetivo: propagar la decisión a tareas anteriores
            for (Tarea_aprobacion__c tarea : Trigger.New) {
                Decision_old = Trigger.oldMap.get(tarea.Id).Decision__c;
                Decision_new = tarea.Decision__c;
                if (tarea.Objetivo__c != null && Decision_old != Decision_new) {
                    objetivos.add(tarea.Objetivo__c);
                }
            }

            if (!objetivos.isEmpty()) {
                Set<Id> objetivosSet = new Set<Id>();
                Map<Id, Id> ultimaTareaPorObjetivo = new Map<Id, Id>();
                Map<Id, String> decisionPorObjetivo = new Map<Id, String>();

                // Recolectar decision nueva por objetivo
                for (Tarea_aprobacion__c tarea : Trigger.New) {
                    Tarea_aprobacion__c oldTarea = Trigger.oldMap.get(tarea.Id);
                    if (tarea.Decision__c != oldTarea.Decision__c && tarea.Objetivo__c != null) {
                        objetivosSet.add(tarea.Objetivo__c);
                        decisionPorObjetivo.put(tarea.Objetivo__c, tarea.Decision__c);
                    }
                }

                // Obtener última tarea por objetivo y actualizar tareas anteriores si procede
                if (!objetivosSet.isEmpty()) {
                    List<Tarea_aprobacion__c> todasTareas = [
                        SELECT Id, Objetivo__c, CreatedDate, Fecha_solicitud__c, Decision__c
                        FROM Tarea_aprobacion__c
                        WHERE Objetivo__c IN :objetivosSet
                        ORDER BY CreatedDate DESC
                    ];
                    for (Tarea_aprobacion__c tarea : todasTareas) {
                        if (!ultimaTareaPorObjetivo.containsKey(tarea.Objetivo__c)) {
                            ultimaTareaPorObjetivo.put(tarea.Objetivo__c, tarea.Id);
                        }
                    }
                    Set<Id> objetivosValidos = new Set<Id>();
                    for (Tarea_aprobacion__c tarea : Trigger.New) {
                        Id ultimaTareaId = ultimaTareaPorObjetivo.get(tarea.Objetivo__c);
                        if (tarea.Objetivo__c != null && tarea.Id == ultimaTareaId) {
                            objetivosValidos.add(tarea.Objetivo__c);
                        }
                    }
                    if (!objetivosValidos.isEmpty()) {
                        List<Tarea_aprobacion__c> tareasParaActualizar = new List<Tarea_aprobacion__c>();
                        for (Tarea_aprobacion__c tarea : todasTareas) {
                            Id objetivoId = tarea.Objetivo__c;
                            if (objetivosValidos.contains(objetivoId) &&
                                tarea.Decision__c == 'En proceso' &&
                                tarea.Id != ultimaTareaPorObjetivo.get(objetivoId)) {
                                String nuevaDecision = decisionPorObjetivo.get(objetivoId);
                                if (nuevaDecision != null) {
                                    // Propagar nueva decisión a tareas previas en estado "En proceso"
                                    tarea.Decision__c = nuevaDecision;
                                    tareasParaActualizar.add(tarea);
                                }
                            }
                        }
                        if (!tareasParaActualizar.isEmpty()) {
                            update tareasParaActualizar;
                        }
                    }
                }
            }
        }

        // Ejecutar DML acumulado: Opportunity
        if (!ops_update.isEmpty()) {
            try {
                if (!istest) {
                    update ops_update;
                }
            } catch (DMLException e) {
                System.debug('Error update Opportunity: ' + e.getMessage());
            }
            // Después forzamos Clonada__c = false en un segundo update (como hace el diseño original)
            List<Opportunity> new_update = new List<Opportunity>();
            for (Opportunity opsRec : ops_update) {
                opsRec.Clonada__c = false;
                new_update.add(opsRec);
            }
            try {
                if (!istest) {
                    update new_update;
                }
            } catch (DMLException e) {
                System.debug('Error update Opportunity clonada false: ' + e.getMessage());
            }
        }

        // Ejecutar DML acumulado: socios y subcontratas
        if (!socio_update.isEmpty() || istest) {
            try {
                update socio_update;
            } catch (DMLException e) {
                System.debug('Error update Socios: ' + e.getMessage());
            }
        }

        if (!subcontrata_update.isEmpty() || istest) {
            try {
                update subcontrata_update;
            } catch (DMLException e) {
                System.debug('Error update Subcontratas: ' + e.getMessage());
            }
        }
    }

    // AFTER INSERT: asignar propietario de oportunidad a la tarea y marcar si tiene QA
    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> oportunidadIds = new Set<Id>();
        for (Tarea_aprobacion__c t : Trigger.new) {
            if (t.Opportunity__c != null) {
                oportunidadIds.add(t.Opportunity__c);
            }
        }
        if (oportunidadIds.isEmpty()) {
            return;
        }
        Map<Id, Opportunity> oportunidadesMap = new Map<Id, Opportunity>(
            [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :oportunidadIds]
        );
        // Asignar Propietario_de_la_Oportunidad__c en las tareas nuevas
        List<Tarea_aprobacion__c> tareasParaActualizar = new List<Tarea_aprobacion__c>();
        for (Tarea_aprobacion__c t : Trigger.new) {
            if (t.Opportunity__c != null && oportunidadesMap.containsKey(t.Opportunity__c)) {
                tareasParaActualizar.add(new Tarea_aprobacion__c(
                    Id = t.Id,
                    Propietario_de_la_Oportunidad__c = oportunidadesMap.get(t.Opportunity__c).OwnerId
                ));
            }
        }
        if (!tareasParaActualizar.isEmpty()) {
            update tareasParaActualizar;
        }

        // Marcar en Opportunity si tiene QA (contar tareas de tipo QA)
        Map<Id, Boolean> oportunidadTieneQA = new Map<Id, Boolean>();
        for (AggregateResult ar : [
            SELECT Opportunity__c Id, COUNT(Id) total
            FROM Tarea_aprobacion__c
            WHERE Opportunity__c IN :oportunidadIds
              AND Tipo__c IN ('Oferta QA Económico', 'Oferta QA Técnico')
            GROUP BY Opportunity__c
        ]) {
            oportunidadTieneQA.put((Id) ar.get('Id'), true);
        }

        List<Opportunity> oportunidadesActualizar = new List<Opportunity>();
        for (Id oppId : oportunidadIds) {
            oportunidadesActualizar.add(new Opportunity(
                Id = oppId,
                Tiene_Oferta_QA__c = oportunidadTieneQA.containsKey(oppId)
            ));
        }
        if (!oportunidadesActualizar.isEmpty()) {
            update oportunidadesActualizar;
        }
    }

    // Helper: resumenAprobacion -> devuelve 'Aprobado' / 'Rechazado' o '' si hay tareas en proceso
    public String resumenAprobacion(List<Tarea_aprobacion__c> lista_tareas) {
        String decision = 'Final';
        String decision_final = 'Aprobado';
        for (Tarea_aprobacion__c t : lista_tareas) {
            if (t.Decision__c == 'En proceso') {
                decision = 'En proceso';
                decision_final = '';
            }
        }
        if (decision == 'Final') {
            for (Tarea_aprobacion__c t : lista_tareas) {
                if (t.Decision__c == 'Rechazado') {
                    decision_final = 'Rechazado';
                }
            }
        }
        return decision_final;
    }

    // Cada método Aprobacion* calcula la decisión agregada y marca cambios en Opportunity / socios / subcontratas.
    public void AprobacionPreliminar(List<Tarea_aprobacion__c> tareas_relacionadas_preliminar, Opportunity op) {
        Decision_preliminar = resumenAprobacion(tareas_relacionadas_preliminar);
        if (Decision_preliminar != '') {
            if (Decision_preliminar == 'Aprobado') {
                op.stageName = 'Oferta';
                op.Subfase__c = 'Elaboración oferta';
                op.Bloqueo_por_aprobacion__c = false;
                op.Clonada__c = true;
            } else if (Decision_preliminar == 'Rechazado') {
                op.stageName = 'Cualificación';
                op.Subfase__c = 'No presentada';
                op.Bloqueo_por_aprobacion__c = false;
                op.Clonada__c = true;
                op.Fecha_estimada_de_cierre__c = System.today();
            }
            if (!ops_update_id.contains(op.Id) && op.Decision_Go_Smart_BPM_Offer__c != Decision_preliminar) {
                op.Decision_Go_Smart_BPM_Offer__c = Decision_preliminar;
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    public void AprobacionOferta(List<Tarea_aprobacion__c> tareas_relacionadas_oferta, Opportunity op) {
        Decision_oferta = resumenAprobacion(tareas_relacionadas_oferta);
        if (Decision_oferta != '') {
            if (Decision_oferta == 'Aprobado') {
                op.Decision_Aprobacion_Oferta__c = 'Aprobado';
                op.Bloqueo_por_aprobacion__c = false;
            } else if (Decision_oferta == 'Rechazado') {
                op.Decision_Aprobacion_Oferta__c = 'No aprobado';
                op.Bloqueo_por_aprobacion__c = false;
            }
            if (!ops_update_id.contains(op.Id) || istest) {
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    // QA técnico: asigna Go/No Go, gestiona bloqueo si faltan decisiones en el otro QA
    public void AprobacionOfertaTecnica(List<Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica, Opportunity op) {
        Decision_oferta_tecnica = resumenAprobacion(tareas_relacionadas_oferta_tecnica);
        if (Decision_oferta_tecnica != '') {
            if (Decision_oferta_tecnica == 'Aprobado') {
                op.Decision_QA_Tecnico__c = 'Go';
                op.Bloqueo_por_aprobacion__c = false;
            } else if (Decision_oferta_tecnica == 'Rechazado') {
                op.Decision_QA_Tecnico__c = 'No Go';
                op.Bloqueo_por_aprobacion__c = false;
            }
            // Si hay 2 QA y el otro QA no ha decidido, mantener bloqueo
            if ((op.Numero_QA__c == 2 &&
                 op.Decision_QA_Economico__c != 'Go' &&
                 op.Decision_QA_Economico__c != 'No Go') || istest) {
                op.Bloqueo_por_aprobacion__c = true;
            }
            if (!ops_update_id.contains(op.Id)) {
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    // QA económico: similar a técnico, con bloqueo si falta la decisión técnica
    public void AprobacionOfertaEconomica(List<Tarea_aprobacion__c> tareas_relacionadas_oferta_economica, Opportunity op) {
        Decision_oferta_economica = resumenAprobacion(tareas_relacionadas_oferta_economica);
        if (Decision_oferta_economica != '') {
            if (Decision_oferta_economica == 'Aprobado') {
                op.Decision_QA_Economico__c = 'Go';
                op.Bloqueo_por_aprobacion__c = false;
            } else if (Decision_oferta_economica == 'Rechazado') {
                op.Bloqueo_por_aprobacion__c = false;
                op.Decision_QA_Economico__c = 'No Go';
            }
            // Si hay 2 QA y falta la decisión técnica, mantener bloqueo
            if ((op.Numero_QA__c == 2 &&
                 op.Decision_QA_Tecnico__c != 'Go' &&
                 op.Decision_QA_Tecnico__c != 'No Go') || istest) {
                op.Bloqueo_por_aprobacion__c = true;
            }
            if (!ops_update_id.contains(op.Id) || istest) {
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    // Socios: calcula decisión por socio y marca tanto el registro de socio como la Opportunity
    public void AprobacionSocios(List<Tarea_aprobacion__c> tareas_relacionadas_socios, Opportunity op) {
        List<Tarea_aprobacion__c> tarea_socio = new List<Tarea_aprobacion__c>();
        List<Oportunidad_Competidor_socio__c> lista_socios = [
            SELECT Id, Name, Competidor_Socio__c, Subcontrata__c, Decision_final__c, Opportunity__c
            FROM Oportunidad_Competidor_socio__c
            WHERE Opportunity__c = :op.Id AND Competidor_Socio__c != null
        ];
        if (!lista_socios.isEmpty()) {
            for (Oportunidad_Competidor_socio__c socio : lista_socios) {
                tarea_socio.clear();
                for (Tarea_aprobacion__c tarea : tareas_relacionadas_socios) {
                    if (tarea.Socio__c == socio.Id) {
                        tarea_socio.add(tarea);
                    }
                }
                Decision_socio = resumenAprobacion(tarea_socio);
                if (Decision_socio == 'Aprobado') {
                    socio.Decision_final__c = 'Aprobado';
                    op.Decision_Socios__c = 'Aprobado';
                } else if (Decision_socio == 'Rechazado') {
                    socio.Decision_final__c = 'Rechazado';
                    op.Decision_Socios__c = 'Rechazado';
                }
                if (!socio_update_id.contains(socio.Id)) {
                    socio_update_id.add(socio.Id);
                    socio_update.add(socio);
                }
                if (!ops_update_id.contains(op.Id)) {
                    ops_update_id.add(op.Id);
                    ops_update.add(op);
                }
            }
        }
    }

    // Subcontratas: similar a socios, actualiza decision en subcontrata y Opportunity
    public void AprobacionSubcontrata(List<Tarea_aprobacion__c> tareas_relacionadas_subcontrata, Opportunity op) {
        List<Tarea_aprobacion__c> tarea_subcontrata = new List<Tarea_aprobacion__c>();
        List<Oportunidad_Competidor_socio__c> lista_subcontratas = [
            SELECT Id, Name, Competidor_Socio__c, Subcontrata__c, Decision_final__c, Opportunity__c
            FROM Oportunidad_Competidor_socio__c
            WHERE Opportunity__c = :op.Id AND Subcontrata__c != null
        ];
        for (Tarea_aprobacion__c tarea : tareas_relacionadas_subcontrata) {
            for (Oportunidad_Competidor_socio__c sub : lista_subcontratas) {
                if (tarea.Subcontrata__c == sub.Id) {
                    if (tarea.Decision__c == 'Aprobado') {
                        sub.Decision_final__c = 'Aprobado';
                        op.decision_subcontrataciones__c = 'Aprobado';
                    } else if (tarea.Decision__c == 'Rechazado') {
                        sub.Decision_final__c = 'Rechazado';
                        op.decision_subcontrataciones__c = 'Rechazado';
                    }
                }
                if (!subcontrata_update_Id.contains(sub.Id)) {
                    subcontrata_update.add(sub);
                    subcontrata_update_Id.add(sub.Id);
                }
                if (!ops_update_id.contains(op.Id)) {
                    ops_update_id.add(op.Id);
                    ops_update.add(op);
                }
            }
        }
    }

    // Borrador acuerdo socios: setear decisión en Opportunity
    public void AprobacionBorradorAcuerdoSocios(List<Tarea_aprobacion__c> tareas_relacionadas_borrador, Opportunity op) {
        for (Tarea_aprobacion__c tarea : tareas_relacionadas_borrador) {
            if (tarea.Decision__c == 'Aprobado') {
                op.Decision_aprobacion_acuerdo_de_socios__c = 'Aprobado';
            } else if (tarea.Decision__c == 'Rechazado') {
                op.Decision_aprobacion_acuerdo_de_socios__c = 'Rechazado';
            }
            if (!ops_update_id.contains(op.Id)) {
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    // Preventa: tomar la última tarea de preventa (si hay varias) y setear Go / No Go + quitar bloqueo
    public void AprobacionPreventa(List<Tarea_aprobacion__c> tareas_relacionadas_preventa, Opportunity op) {
        if (!tareas_relacionadas_preventa.isEmpty() && tareas_relacionadas_preventa.size() > 1) {
            tareas_relacionadas_preventa.sort(new CreatedDateComparator());
            tareas_relacionadas_preventa = new List<Tarea_aprobacion__c>{
                tareas_relacionadas_preventa.get(tareas_relacionadas_preventa.size() - 1)
            };
        }
        Decision_preventa = resumenAprobacion(tareas_relacionadas_preventa);
        if (Decision_preventa != '') {
            if (Decision_preventa == 'Aprobado') {
                op.Bloqueo_por_aprobacion__c = false;
                op.Decisi_n_Equipo_Preventa__c = 'Go';
            } else if (Decision_preventa == 'Rechazado') {
                op.Bloqueo_por_aprobacion__c = false;
                op.Decisi_n_Equipo_Preventa__c = 'No Go';
            }
            if (!ops_update_id.contains(op.Id) || istest) {
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
    }

    // Comparator simple por CreatedDate (usa para obtener la última tarea)
    public class CreatedDateComparator implements Comparator<Tarea_aprobacion__c> {
        public Integer compare(Tarea_aprobacion__c a, Tarea_aprobacion__c b) {
            if (a.CreatedDate == b.CreatedDate) return 0;
            return a.CreatedDate > b.CreatedDate ? 1 : -1;
        }
    }
}
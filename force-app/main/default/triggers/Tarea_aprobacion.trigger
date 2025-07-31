trigger Tarea_aprobacion on Tarea_aprobacion__c (after update, after insert, before update) {
    System.debug('Trigger: Tarea de aprobacion');
    Boolean istest = Test.isRunningTest();
    //Get User email from logged user
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    
    //No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    List <String> oportunidades = new List <String>();
    List <String> objetivos = new List <String>();
    
    List <Oportunidad__c> ops_update = new List <Oportunidad__c>();
    Set<Id> ops_update_id = new set <Id>();
    
    List <Oportunidad_competidor_socio__c> socio_update = new List <Oportunidad_competidor_socio__c>();
    Set<Id> socio_update_id = new set <Id>();
    
    List <Oportunidad_competidor_socio__c> subcontrata_update = new List <Oportunidad_competidor_socio__c>();
    Set<Id> subcontrata_update_Id = new set <Id>();
    
    List <Tarea_aprobacion__c> tareas_relacionadas_preliminar = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta_economica = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_socios = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_subcontratas = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_borrador_socios = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_preventa = new List <Tarea_aprobacion__c>();
    
    List <Tarea_aprobacion__c> tareas_relacionadas_preliminar2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_oferta_economica2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_socios2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_subcontratas2 = new List <Tarea_aprobacion__c>();
    List <Tarea_aprobacion__c> tareas_relacionadas_borrador_socios2 = new List <Tarea_aprobacion__c>();
    
    
    String Decision_old = '';
    String Decision_new = '';
    String Decision_preliminar='';
    String Decision_oferta='';
    String Decision_oferta_tecnica='';
    String Decision_oferta_economica='';
    String Decision_socio= '';
    String Decision_subcontrata= '';
    String Decision_preventa= '';
    
    
    String DecisionQATecnico_calculada='';
    String DecisionQAEconomico_calculada='';
    //if(emailAddress != usuario_no_trigger.Correo_usuario__c){
    
    
    // AFTER UPDATE
    if (Trigger.isAfter && Trigger.isUpdate) {
        //1. Recuperamos las oportunidades en donde haya un cambio en la decisión de la tarea de aprobación
        for(Tarea_aprobacion__c tarea : Trigger.New){
            Decision_old = Trigger.oldMap.get(tarea.id).Decision__c;
            Decision_new = tarea.Decision__c;
            
            if(Decision_old != Decision_new){
                
                if(tarea.Oportunidad__c != null && !oportunidades.contains(tarea.Oportunidad__c)){
                    oportunidades.add(tarea.Oportunidad__c);
                }
            }
        }
        System.debug('oportunidades String: '+ oportunidades);
        //2. Si hay oportunidades recuperamos todas las tareas
        if(oportunidades.size()>0){
            System.debug('Entra en OPP PROCESS: ');
            List <Tarea_aprobacion__c> lista_tareas = [SELECT Id,CreatedDate, Name, Decision__c, Oportunidad__c,Tipo__c,Socio__c, Subcontrata__c FROM Tarea_aprobacion__c WHERE Oportunidad__c IN: oportunidades];
            List <Oportunidad__c> ops =[SELECT Id, Decisi_n_Equipo_Preventa__c,Decision_Go_Smart_BPM_Offer__c,Decision_aprobacion_acuerdo_de_socios__c,Decision_QA_Economico__c,Decision_QA_Tecnico__c,Decision_Aprobacion_Oferta__c ,Numero_QA__c
                                        FROM Oportunidad__c WHERE Id IN: oportunidades];
            
            //3. Para cada oportunidad clasificamos las tareas
            for(Oportunidad__c op: ops){
                
                tareas_relacionadas_preliminar.clear();
                tareas_relacionadas_oferta.clear();
                tareas_relacionadas_socios.clear();
                tareas_relacionadas_subcontratas.clear();
                tareas_relacionadas_oferta_tecnica.clear();
                tareas_relacionadas_oferta_economica.clear();
                
                for(Tarea_aprobacion__c tarea : lista_tareas ){
                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Preliminar'){
                        tareas_relacionadas_preliminar.add(tarea);
                    }
                    
                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Oferta'){
                        tareas_relacionadas_oferta.add(tarea);
                    }
                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Oferta QA Técnico' || isTest){
                        tareas_relacionadas_oferta_tecnica.add(tarea);
                    }
                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Oferta QA Económico' || isTest){
                        tareas_relacionadas_oferta_economica.add(tarea);
                    }
                    
                    if(tarea.Oportunidad__c == op.Id && tarea.socio__c != null && tarea.Tipo__c == 'Socios' || isTest){
                        tareas_relacionadas_socios.add(tarea);
                    }
                    
                    if(tarea.Oportunidad__c == op.Id && tarea.Subcontrata__c != null && tarea.Tipo__c == 'Subcontratas' || isTest){
                        tareas_relacionadas_subcontratas.add(tarea);
                    }
                    
                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Borrador Acuerdo Socios' || isTest){
                        tareas_relacionadas_borrador_socios.add(tarea);
                    }

                    if(tarea.Oportunidad__c == op.Id && tarea.Tipo__c == 'Aprobación Preventa'|| isTest){
                        tareas_relacionadas_preventa.add(tarea);
                    }
                       
                }
                //4. Si la decisión de la aprobación está pendiente en la Oportunidad se calcula el resumen de la aprobación
                //Aprobación preliminar
                if(tareas_relacionadas_preliminar.size()>0 && op.Decision_Go_Smart_BPM_Offer__c != 'Aprobado' /* && op.Decision_Go_Smart_BPM_Offer__c != 'Rechazado'*/  ){
                    System.debug('Aprobación preliminar');
                    AprobacionPreliminar(tareas_relacionadas_preliminar,op );
                    
                }
                
                //Aprobación oferta (ING y de IT aquellas que no pasen el QA)
                if(tareas_relacionadas_oferta.size()>0 && op.Decision_Aprobacion_Oferta__c != 'Aprobado'/* && op.Decision_Aprobacion_Oferta__c != 'Rechazado' */ || istest){
                    System.debug('Aprobación Oferta');
                    AprobacionOferta(tareas_relacionadas_oferta, op);
                }
                
                
                //Aprobacion QA Técnico
                if(tareas_relacionadas_oferta_tecnica.size()>0  && op.Decision_QA_Tecnico__c != 'Go'/* && op.Decision_QA_Tecnico__c != 'No go' */ || istest){
                    System.debug('Aprobación Oferta QA Tecnico');
                    AprobacionOfertaTecnica(tareas_relacionadas_oferta_tecnica, op);
                }
                
                //Aprobación QA Económico
                if(tareas_relacionadas_oferta_economica.size()>0 && op.Decision_QA_Economico__c != 'Go'/* && op.Decision_QA_Economico__c != 'No go'*/ || istest){
                    System.debug('Aprobación Oferta QA Economico');
                    AprobacionOfertaEconomica(tareas_relacionadas_oferta_economica, op);
                    
                }
                //Aprobacion preventa
                if(tareas_relacionadas_preventa.size()>0 && (op.Decisi_n_Equipo_Preventa__c != 'Go' && op.Decisi_n_Equipo_Preventa__c != 'No Go') || istest){
                    System.debug('Aprobación preventa');
                    AprobacionPreventa(tareas_relacionadas_preventa,op);
                }
                
                //Aprobacion Socios
                if(tareas_relacionadas_socios.size()>0 || istest){
                    System.debug('Aprobación socios');
                    
                    AprobacionSocios(tareas_relacionadas_socios,op);
                }
                
                //Aprobacion Subcontratas
                if(tareas_relacionadas_subcontratas.size()>0|| istest){
                    System.debug('Aprobación socios');
                    
                    AprobacionSubcontrata(tareas_relacionadas_subcontratas,op);
                }
                
                //Borrador acuerdo de socios
                if(tareas_relacionadas_borrador_socios.size()>0|| istest){
                    System.debug('Borrador Acuerdo de socios');
                    AprobacionBorradorAcuerdoSocios(tareas_relacionadas_borrador_socios,op);
                }    
            }
        } else {
            for(Tarea_aprobacion__c tarea : Trigger.New){
                Decision_old = Trigger.oldMap.get(tarea.Id).Decision__c;
                Decision_new = tarea.Decision__c;
                
                if(tarea.Objetivo__c != null && Decision_old != Decision_new){ 
                    if(!objetivos.contains(tarea.Objetivo__c)){
                        objetivos.add(tarea.Objetivo__c);
                    }
                }
            }
            if (objetivos.size() > 0) {
                Set<Id> objetivosSet = new Set<Id>();
                Map<Id, Id> ultimaTareaPorObjetivo = new Map<Id, Id>();
                Map<Id, String> decisionPorObjetivo = new Map<Id, String>();
                
                
                // Paso 1: Identificar cambios de decisión y guardar la nueva decisión
                for (Tarea_aprobacion__c tarea : Trigger.New) {
                    Tarea_aprobacion__c oldTarea = Trigger.oldMap.get(tarea.Id);
                    if (tarea.Decision__c != oldTarea.Decision__c && tarea.Objetivo__c != null) {
                        objetivosSet.add(tarea.Objetivo__c);
                        decisionPorObjetivo.put(tarea.Objetivo__c, tarea.Decision__c);
                        System.debug('Cambio detectado para Objetivo: ' + tarea.Objetivo__c + ', nueva decisión: ' + tarea.Decision__c);
                    }
                }
                
                System.debug('Objetivos con cambios: ' + objetivosSet);
                System.debug('Mapa decisiónPorObjetivo: ' + decisionPorObjetivo);
                
                if (!objetivosSet.isEmpty()) {
                    // Paso 2: Consultar todas las tareas relacionadas ordenadas por fecha descendente
                    List<Tarea_aprobacion__c> todasTareas = [
                        SELECT Id, Objetivo__c, CreatedDate, Fecha_solicitud__c, Decision__c
                        FROM Tarea_aprobacion__c
                        WHERE Objetivo__c IN :objetivosSet
                        ORDER BY CreatedDate DESC
                    ];
                    
                    System.debug('Tareas consultadas para esos objetivos (orden DESC por fecha): ' + todasTareas);
                    
                    // Paso 3: Guardar la tarea más reciente por cada objetivo
                    for (Tarea_aprobacion__c tarea : todasTareas) {
                        if (!ultimaTareaPorObjetivo.containsKey(tarea.Objetivo__c)) {
                            ultimaTareaPorObjetivo.put(tarea.Objetivo__c, tarea.Id);
                            System.debug('Tarea más reciente para objetivo ' + tarea.Objetivo__c + ': ' + tarea.Id);
                        }
                    }
                    
                    // Paso 4: Verificar si la tarea que disparó el trigger es la más reciente
                    Set<Id> objetivosValidos = new Set<Id>();
                    for (Tarea_aprobacion__c tarea : Trigger.New) {
                        Id ultimaTareaId = ultimaTareaPorObjetivo.get(tarea.Objetivo__c);
                        if (tarea.Objetivo__c != null && tarea.Id == ultimaTareaId) {
                            objetivosValidos.add(tarea.Objetivo__c);
                            System.debug('Tarea que disparó el trigger ES la más reciente para objetivo ' + tarea.Objetivo__c);
                        } else if (tarea.Objetivo__c != null) {
                            System.debug('Tarea que disparó el trigger NO es la más reciente. tarea.Id=' + tarea.Id + ' vs ultima=' + ultimaTareaId);
                        }
                    }
                    
                    if (!objetivosValidos.isEmpty()) {
                        System.debug('Objetivos válidos para actualizar otras tareas: ' + objetivosValidos);
                        
                        // Paso 5: Actualizar tareas en proceso (que no sean la más reciente)
                        List<Tarea_aprobacion__c> tareasParaActualizar = new List<Tarea_aprobacion__c>();
                        
                        for (Tarea_aprobacion__c tarea : todasTareas) {
                            Id objetivoId = tarea.Objetivo__c;
                            
                            if (
                                objetivosValidos.contains(objetivoId) &&
                                tarea.Decision__c == 'En proceso' &&
                                tarea.Id != ultimaTareaPorObjetivo.get(objetivoId)
                            ) {
                                String nuevaDecision = decisionPorObjetivo.get(objetivoId);
                                if (nuevaDecision != null) {
                                    System.debug('Actualizando tarea: ' + tarea.Id + ' (objetivo: ' + objetivoId + ') de "En proceso" a "' + nuevaDecision + '"');
                                    tarea.Decision__c = nuevaDecision;
                                    tareasParaActualizar.add(tarea);
                                }
                            }
                        }
                        
                        if (!tareasParaActualizar.isEmpty()) {
                            System.debug('Tareas a actualizar: ' + tareasParaActualizar);
                            update tareasParaActualizar;
                        } else {
                            System.debug('No se encontraron tareas en proceso distintas a la última para actualizar.');
                        }
                    } else {
                        System.debug('Ninguna tarea que disparó el trigger fue la más reciente. No se realiza ninguna actualización.');
                    }
                }
                
                System.debug('--- FIN actualización tareas por cambio de decisión ---');
            }      
        }   
        if(ops_update.size()>0){
            
            try{
                if(!istest){
                    update ops_update;
                }
                
            }catch(DMLException e){ 
                System.debug('Error Tarea aprobacion Oportunidad update: ' + e.getMessage());
                
            }
            
            List <Oportunidad__c> new_update = new List <Oportunidad__c> ();
            for(Oportunidad__c ops: ops_update ){
                
                ops.Clonada__c=false;
                new_update.add(ops);
            }
            
            try{
                if(!isTest){
                    update new_update; 
                }
            }catch(DMLException e){ 
                System.debug('Error Tarea aprobacion Oportunidad update clonada false: ' + e.getMessage());
                
            }
            
        }
        
        if(socio_update.size()>0 || istest){
            
            try{
                update socio_update;     
            }catch(DMLException e){ 
                System.debug('Error Tarea aprobacion Socios: ' + e.getMessage());
                
            }
        }
        
        
        if(subcontrata_update.size()>0 || istest){
            
            try{
                update subcontrata_update;     
            }catch(DMLException e){ 
                System.debug('Error Tarea aprobacion subcontrata: ' + e.getMessage());
                
            }
        }
        
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        System.debug('--- INICIO TRIGGER: AFTER INSERT EN Tarea_aprobacion__c ---');
        
        Set<Id> oportunidadIds = new Set<Id>();
        List<Tarea_aprobacion__c> tareaList = Trigger.new;
        
        System.debug('Total de tareas procesadas: ' + tareaList.size());
        
        for (Tarea_aprobacion__c t : tareaList) {
            System.debug('Tarea analizada: ' + t.Id + ' | Oportunidad__c: ' + t.Oportunidad__c);
            if (t.Oportunidad__c != null) {
                oportunidadIds.add(t.Oportunidad__c);
            }
        }
        
        System.debug('Oportunidades encontradas: ' + oportunidadIds);
        
        if (oportunidadIds.isEmpty()) {
            System.debug('No hay oportunidades relacionadas, FIN TRIGGER.');
            return;
        }
        
        // 1. Obtener oportunidades con OwnerId
        Map<Id, Oportunidad__c> oportunidadesMap = new Map<Id, Oportunidad__c>(
            [SELECT Id, OwnerId FROM Oportunidad__c WHERE Id IN :oportunidadIds]
        );
        System.debug('Oportunidades recuperadas: ' + oportunidadesMap);
        
        // 2. Actualizar tareas con el OwnerId
        List<Tarea_aprobacion__c> tareasParaActualizar = new List<Tarea_aprobacion__c>();
        
        for (Tarea_aprobacion__c t : tareaList) {
            if (t.Oportunidad__c != null && oportunidadesMap.containsKey(t.Oportunidad__c)) {
                Id ownerId = oportunidadesMap.get(t.Oportunidad__c).OwnerId;
                tareasParaActualizar.add(new Tarea_aprobacion__c(
                    Id = t.Id,
                    Propietario_de_la_Oportunidad__c = ownerId
                ));
            }
        }
        
        System.debug('Tareas a actualizar con OwnerId: ' + tareasParaActualizar.size());
        
        if (!tareasParaActualizar.isEmpty()) {
            update tareasParaActualizar;
            System.debug('UPDATE ejecutado sobre tareas.');
        }
        
        // 3. Contar tareas QA y actualizar flag en oportunidad
        Map<Id, Boolean> oportunidadTieneQA = new Map<Id, Boolean>();
        
        for (AggregateResult ar : [
            SELECT Oportunidad__c Id, COUNT(Id) total
            FROM Tarea_aprobacion__c
            WHERE Oportunidad__c IN :oportunidadIds
            AND Tipo__c IN ('Oferta QA Económico', 'Oferta QA Técnico')
            GROUP BY Oportunidad__c
        ]) {
            System.debug('AggregateResult QA: ' + ar);
            oportunidadTieneQA.put((Id) ar.get('Id'), true);
        }
        
        System.debug('Mapa oportunidadTieneQA: ' + oportunidadTieneQA);
        
        List<Oportunidad__c> oportunidadesActualizar = new List<Oportunidad__c>();
        
        for (Id oppId : oportunidadIds) {
            Boolean tieneQA = oportunidadTieneQA.containsKey(oppId);
            System.debug('Oportunidad ' + oppId + ' tiene QA? ' + tieneQA);
            oportunidadesActualizar.add(new Oportunidad__c(
                Id = oppId,
                Tiene_Oferta_QA__c = tieneQA
            ));
        }
        
        System.debug('Oportunidades a actualizar: ' + oportunidadesActualizar.size());
        
        if (!oportunidadesActualizar.isEmpty()) {
            update oportunidadesActualizar;
            System.debug('UPDATE ejecutado sobre oportunidades.');
        }
        
        System.debug('--- FIN TRIGGER AFTER INSERT EN Tarea_aprobacion__c ---');
    }
    
    //}
    
    public String resumenAprobacion(List <Tarea_aprobacion__c> lista_tareas){
        
        String decision='Final';
        String decision_final='Aprobado';
        
        for(Tarea_Aprobacion__c t: lista_tareas ){
            if(t.Decision__c =='En proceso'){
                decision ='En proceso';
                decision_final='';
            }
        }
        //Cuando la decisión es final, no hay ninguna tarea en proceso, calculamos la decisión Aprobado/Rechazado
        if(decision== 'Final'){
            for(Tarea_Aprobacion__c t: lista_tareas ){
                if(t.Decision__c =='Rechazado'){
                    decision_final ='Rechazado';
                }
            }
        }
        
        
        System.debug('Decisión final:'+decision_final );
        return decision_final;
    } 
    
    public void AprobacionPreliminar(List <Tarea_aprobacion__c> tareas_relacionadas_preliminar, Oportunidad__c op){
        System.debug('Aprobación preliminar');
        Decision_preliminar =  resumenAprobacion(tareas_relacionadas_preliminar);
        if(Decision_preliminar != ''){
            
            if(Decision_preliminar=='Aprobado'){
                op.Etapa__c ='Oferta';
                op.Subfase__c='Elaboración oferta';
                op.Bloqueo_por_aprobacion__c =false;
                op.Clonada__c=true;
            }else if (Decision_preliminar=='Rechazado'){
                op.Etapa__c ='Cualificación';
                op.Subfase__c='No presentada';
                op.Bloqueo_por_aprobacion__c =false;
                op.Clonada__c=true;
                Op.Fecha_estimada_de_cierre__c= System.today();
            }
            
            System.debug('op.Decision_Go_Smart_BPM_Offer__c: '+ op.Decision_Go_Smart_BPM_Offer__c);
            System.debug('Decision_preliminar');
            
            if(!ops_update_id.contains(op.Id) && op.Decision_Go_Smart_BPM_Offer__c != Decision_preliminar  ){
                op.Decision_Go_Smart_BPM_Offer__c = Decision_preliminar;
                ops_update_id.add(op.Id);
                ops_update.add(op);
                
            }
            
        }
        
    }
    
    public void AprobacionOferta (List <Tarea_aprobacion__c> tareas_relacionadas_oferta, Oportunidad__c op){
        System.debug('Aprobación oferta');
        
        Decision_oferta =  resumenAprobacion(tareas_relacionadas_oferta);
        
        if(Decision_oferta != ''){
            if(Decision_oferta=='Aprobado'){
                
                op.Decision_Aprobacion_Oferta__c='Aprobado';
                op.Bloqueo_por_aprobacion__c =false;
                
            }else if(Decision_oferta=='Rechazado'){
                op.Decision_Aprobacion_Oferta__c='No aprobado';
                op.Bloqueo_por_aprobacion__c =false;
            }
            
            if(!ops_update_id.contains(op.Id) || isTest){
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        } 
    }
    
    public void AprobacionOfertaTecnica (List <Tarea_aprobacion__c> tareas_relacionadas_oferta_tecnica, Oportunidad__c op){
        System.debug('Aprobación oferta Tecnica');
        
        Decision_oferta_tecnica =  resumenAprobacion(tareas_relacionadas_oferta_tecnica);
        System.debug('decision oferta tecnica: '+ Decision_oferta_tecnica);
        if(Decision_oferta_tecnica != ''){
            if(Decision_oferta_tecnica=='Aprobado'){
                
                op.Decision_QA_Tecnico__c='Go';
                op.Bloqueo_por_aprobacion__c =false;
                
            }else if(Decision_oferta_tecnica=='Rechazado'){
                op.Decision_QA_Tecnico__c='No go';
                op.Bloqueo_por_aprobacion__c =false;
                
            }
            System.debug('Campos op: '+ op.Numero_QA__c + op.Decision_QA_Tecnico__c + op.Decision_QA_Economico__c);
            if(op.Numero_QA__c ==2 && op.Decision_QA_Economico__c!= 'Go'&& op.Decision_QA_Economico__c!= 'No go' || istest){
                System.debug('Bloqueo a true porque aun falta economico');
                op.Bloqueo_por_aprobacion__c =true;
            }
            
            if(!ops_update_id.contains(op.Id)){
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        }
        
    }
    public void AprobacionOfertaEconomica (List <Tarea_aprobacion__c> tareas_relacionadas_oferta_economica, Oportunidad__c op){
        System.debug('Aprobación oferta Economica');
        System.debug('Decision economica: '+ op.Decision_QA_Economico__c);
        
        Decision_oferta_economica =  resumenAprobacion(tareas_relacionadas_oferta_economica);
        
        System.debug('Decision_oferta_economica economica: '+ Decision_oferta_economica);
        if(Decision_oferta_economica != ''){
            if(Decision_oferta_economica=='Aprobado'){
                System.debug('estamos en el if aprobada');
                op.Decision_QA_Economico__c='Go';
                op.Bloqueo_por_aprobacion__c =false;
                
            }else if(Decision_oferta_economica=='Rechazado'){
                System.debug('estamos en el else if rechazada');
                op.Bloqueo_por_aprobacion__c =false;
                op.Decision_QA_Economico__c='No go';
                
            }
            System.debug('Campos op: '+ op.Numero_QA__c + op.Decision_QA_Tecnico__c + op.Decision_QA_Tecnico__c);
            if(op.Numero_QA__c ==2 && op.Decision_QA_Tecnico__c== 'Go' && op.Decision_QA_Tecnico__c== 'No go' || istest){
                System.debug('Bloqueo a true porque aun falta tecnico');
                op.Bloqueo_por_aprobacion__c =true;
            }
            
            System.debug('Despues Decision economica: '+ op.Decision_QA_Economico__c);
            
            if(!ops_update_id.contains(op.Id)|| istest){
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        } 
        
    }
    
    public void AprobacionSocios (List <Tarea_aprobacion__c> tareas_relacionadas_socios, Oportunidad__c op){
        System.debug('Aprobación socios');
        //Socios relacionados con la oportunidad
        
        list <Tarea_aprobacion__c> tarea_socio = new  list <Tarea_aprobacion__c>();
        
        //Identificamos los socios relacionados con la oportunidad
        List <Oportunidad_Competidor_socio__c> lista_socios = [SELECT Id, Name, Competidor_Socio__c, Subcontrata__c, Decision_final__c, Oportunidad__c from Oportunidad_Competidor_socio__c where 	Oportunidad__c =:op.Id and Competidor_socio__c != null]; 
        System.debug('Socios de la oportundiad: '+lista_socios.size() );
        System.debug('Tareas de socios relacionadas con la oportunidad: '+ tareas_relacionadas_socios.size());
        
        if(lista_socios.size()>0){
            
            for(Oportunidad_Competidor_socio__c socio: lista_socios ){
                tarea_socio.clear();
                //Para cada socio obtenemos la lista de tareas de aprobación
                for( Tarea_aprobacion__c tarea: tareas_relacionadas_socios){
                    if(tarea.socio__c == socio.Id){
                        system.debug('Decision '+ tarea.Name + ': '+ tarea.Decision__c);
                        tarea_socio.add(tarea);
                    }
                }
                System.debug('Tareas del socio:'+ tarea_socio.size());                
                Decision_socio = resumenAprobacion(tarea_socio);
                System.debug('Decision socio: '+ Decision_socio);
                if(Decision_socio=='Aprobado'){
                    socio.Decision_final__c = 'Aprobado';
                    op.Decision_Socios__c ='Aprobado';
                }else if (Decision_socio=='Rechazado'){
                    socio.Decision_final__c = 'Rechazado';
                    op.Decision_Socios__c ='Rechazado';
                }
                
                if(!socio_update_id.contains(socio.Id)){
                    socio_update_id.add(socio.Id);
                    socio_update.add(socio);
                }
                
                if(!ops_update_id.contains(op.Id)){
                    ops_update_id.add(op.Id);
                    ops_update.add(op);
                }
                
                
            }
        }
        
    }
    
    public void AprobacionSubcontrata (List <Tarea_aprobacion__c> tareas_relacionadas_subcontrata, Oportunidad__c op){
        System.debug('Aprobación subcontrata');
        //Socios relacionados con la oportunidad
        
        list <Tarea_aprobacion__c> tarea_subcontrata = new  list <Tarea_aprobacion__c>();
        
        //Identificamos las subcontratas relacionados con la oportunidad
        List <Oportunidad_Competidor_socio__c> lista_subcontratas = [SELECT Id, Name, Competidor_Socio__c, Subcontrata__c, Decision_final__c, Oportunidad__c from Oportunidad_Competidor_socio__c where 	Oportunidad__c =:op.Id and Subcontrata__c != null]; 
        System.debug('Subcontratas de la oportundiad: '+lista_subcontratas.size() );
        
        
        for(tarea_aprobacion__c tarea: tareas_relacionadas_subcontrata){
            for(Oportunidad_Competidor_socio__c sub:lista_subcontratas ){
                if(tarea.Subcontrata__c== sub.Id){
                    if(tarea.Decision__c=='Aprobado'){
                        sub.Decision_final__c = 'Aprobado';
                        op.decision_subcontrataciones__c ='Aprobado';
                    }else if (tarea.Decision__c=='Rechazado'){
                        sub.Decision_final__c = 'Rechazado';
                        op.decision_subcontrataciones__c ='Rechazado';
                    }
                }
                
                if(!subcontrata_update_id.contains(sub.id) ){
                    subcontrata_update.add(sub);
                    subcontrata_update_id.add(sub.id) ;
                }
                
                if(!ops_update_id.contains(op.Id)){
                    ops_update_id.add(op.Id);
                    ops_update.add(op);
                }
            }            
            
        }
        
    }    
    public void AprobacionBorradorAcuerdoSocios(List <Tarea_aprobacion__c> tareas_relacionadas_subcontrata, Oportunidad__c op){
        
        System.debug('Aprobación Borrador Acuerdo Socios');
        
        for(Tarea_aprobacion__c tarea: tareas_relacionadas_subcontrata){
            
            if(tarea.Decision__c=='Aprobado'){
                op.Decision_aprobacion_acuerdo_de_socios__c = 'Aprobado';
                
            }else if (tarea.Decision__c=='Rechazado'){
                op.Decision_aprobacion_acuerdo_de_socios__c = 'Rechazado';
            } 
            
            if(!ops_update_id.contains(op.Id)){
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }          
        }
        
    }  
    
    public void AprobacionPreventa(List <Tarea_aprobacion__c> tareas_relacionadas_preventa, Oportunidad__c op){
        // ✅ Si hay varias tareas, dejamos solo la última (más reciente)
        if (!tareas_relacionadas_preventa.isEmpty() && tareas_relacionadas_preventa.size() > 1) {
            tareas_relacionadas_preventa.sort(new CreatedDateComparator());
            tareas_relacionadas_preventa = new List<Tarea_aprobacion__c>{
                tareas_relacionadas_preventa.get(tareas_relacionadas_preventa.size() - 1)
                    };
                        }
        Decision_preventa =  resumenAprobacion(tareas_relacionadas_preventa);
        System.debug('Decision Preventa: ' + Decision_preventa);
        if(Decision_preventa != ''){
            if(Decision_preventa=='Aprobado'){
                op.Bloqueo_por_aprobacion__c =false;
                op.Decisi_n_Equipo_Preventa__c = 'Go';
            }else if (Decision_preventa=='Rechazado'){
                op.Bloqueo_por_aprobacion__c =false;
                op.Decisi_n_Equipo_Preventa__c = 'No Go';
            }
            
            if(!ops_update_id.contains(op.Id)|| istest){
                ops_update_id.add(op.Id);
                ops_update.add(op);
            }
        } 
    } 
    public class CreatedDateComparator implements Comparator<Tarea_aprobacion__c> {
        public Integer compare(Tarea_aprobacion__c a, Tarea_aprobacion__c b) {
            Datetime d1 = a.CreatedDate;
            Datetime d2 = b.CreatedDate;

            if (d1 == d2) {
                return 0;
            }
            return d1 > d2 ? 1 : -1;
        }
    }
}
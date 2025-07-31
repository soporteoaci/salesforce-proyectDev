global class GC_Automatizacion_Historicos_Proyecto implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, Cuenta__c, Codigo__c, Pais__c, Entregable_s__c,  AvanceContractualEntregables__c,';
        query = query + 'TerminosReferencia__c, Terminos_de_Referencia_Aprobados__c, Avance_Contractual_TDRs__c, Comunicaciones__c,  FFC__c, FFP__c, FIC__c,';
        query = query + 'Estado_Datos_Economicos__c, Moneda__c, impcontrato__c, Facturacion__c, Cobrado__c, costeDirReal__c, costeDirPrev__c, MargenBrutoPrevisto__c, margenplan__c,';
        query = query + 'Abierto__c, Avance_en_Cobros__c,Fecha_Datos_Economicos__c, Mes_Datos_Economicos__c, Entregable__c,';
        query = query + 'Entregables_Firmado__c, PR__c, Coste_resto__c, Margen_Previsto__c, WIP__c, Inventario__c, Pendiente_Cobro__c, Prod_media__c, Coste_Promedio_Incurrido__c, Coste_Promedio_Resto__c, Mercado__c, WIP_ProdMedia__c, WIP_ImporteContrato__c, Cost_Promed_Inc_Cost_Promed__c, Pend_Cobro_Importe_Fact__c, ';
        query = query + 'Margen_Plan_Margen_Prev__c, CalculoDuracionReal__c, CalculoDuracionPlan__c, CalculoDuracionPrevista__c, Cambio_segun_moneda_local__c, WIP_EUR__c, Coste_Promedio_Incurrido_EUR__c, Pendiente_de_Cobro_EUR__c, Produccion_Real_EUR__c, Facturacion_EUR__c, Coste_Directo_Real_EUR__c, Cobrado_EUR__c, Importe_Contrato_EUR__c,';
        query = query + 'Produccion_Avance__c, WIP_prodAvance__c, Produccion_Avance_EUR__c, WIP_ProdAvance_EUR__c, Responsable__c,Responsable_email__c, Sub_area__c, Margen_Prev_Margen_Plan__c, impcontrato_real__c, impcontratoEUR_real__c, Fecha_limite_supervision_OACI__c, Auditado_KPI_OACI__c, Fecha_ultimo_control_KPI_OACI__c, Consideraciones_OACI_a_KPI__c, ';
        query = query + 'Calculo_WIP_Prod_Media__c, Calculo_WIP_IC__c, Calculo_Coste_Prom_Inc_Coste_Prom_Resto__c, Calculo_Pend_Cobro_Imp_Facturado__c, Calculo_Margen_Prev_Margen_Plan__c, Produccion_IC__c, Coste_Dir_Real_Coste_Dir_Prev__c, Facturacion_IC__c, Coste_Directo_Previsto_EUR__c, Porcentaje_de_producto__c, Porcentaje_de_producto_indicador__c,';
        query = query + 'Produccion_media_EUR__c, Coste_Promedio_Resto_EUR__c, Margen_Previsto_EUR__c, Margen_plan_EUR__c, Calculo_Inventario_Produccion_media__c, Inventario_Produccion_media__c, Inventario_EUR__c, Fecha_alta_SAP__c,';
        query = query + 'Cobrado_FdP_EUR__c, Coste_resto_FdP_EUR__c, costeDirPrev_FdP_EUR__c, costeDirReal_FdP_EUR__c, Facturacion_FdP_EUR__c, impcontrato_FdP_EUR__c, Inventario_FdP_EUR__c, Margen_Previsto_FdP_EUR__c, margenplan_FdP_EUR__c, Pendiente_Cobro_FdP_EUR__c, PR_FdP_EUR__c, WIP_FdP_EUR__c FROM Proyecto__c';
        
        System.debug('QUERY: '+ query);
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Proyecto__c> proyectos){
        system.debug('Tamaño de lista de proyectos:  ' + proyectos.size());
        
        /* Integer mes = Date.Today().month() ;
Integer dia=Date.Today().day() ;
Integer anho = Date.Today().year();*/
        
        
        Integer mes = Datetime.now().monthGMT() ;
        Integer dia=Datetime.now().dayGMT();
        Integer anho = Datetime.now().yearGMT();
        
        List<Proyecto__c> listaProyectosFinal = new List<Proyecto__c>();
        Map<Id, Proyecto__c> mapaTodosProyectos = new Map<Id, Proyecto__c>(proyectos);
        Set <Id> listIdProyectos= new Set<Id>();
        listIdProyectos = mapaTodosProyectos.keySet();//lista de identificadores de todos los contratos
        String Historico_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico datos proyecto' and sobjecttype ='Historico_estado_proyecto__c'].Id;
        
        List<Historico_estado_proyecto__c> myHistoricoListToday = [SELECT id, name, Proyecto__r.id FROM Historico_estado_proyecto__c 
                                                                   WHERE Proyecto__r.id IN : listIdProyectos  and RecordTypeId =: Historico_RecordTypeID
                                                                   and CALENDAR_MONTH(CreatedDate) =: mes 
                                                                   and DAY_IN_MONTH(CreatedDate)=: dia 
                                                                   and CALENDAR_YEAR(CreatedDate)=: anho ]; 
        
        Map<Id, Historico_estado_proyecto__c> mapaHistoricoToday= new Map<Id, Historico_estado_proyecto__c>();
        system.debug('Tamaño de lista de historicos hoy:  '+ myHistoricoListToday.size());
        
        for (Historico_estado_proyecto__c hist : myHistoricoListToday){
            mapaHistoricoToday.put(hist.proyecto__r.id, hist);
            
        }
        
        for (Id idProyecto : listIdProyectos){
            if(mapaHistoricoToday.containsKey(idProyecto)==false){
                listaProyectosFinal.add(mapaTodosProyectos.get(idProyecto));
            }  
        }
        
        
        system.debug('Tamaño de lista de final de Proyecto:  '+ listaProyectosFinal.size());
        
        
        
        //Recorro la lista de ID's de proyectos y busco si hay en la lista de 
        
        Date Fecha_datos_economicos =Date.newInstance(2022, 01, 01);
        List<Historico_estado_proyecto__c> myHistoricoNew = new List<Historico_estado_proyecto__c>();  
        List<Proyecto__c> myProjects_update = new List<Proyecto__c>();
     
        
        for (Proyecto__c project : listaProyectosFinal){
            Historico_estado_proyecto__c myNew = new Historico_estado_proyecto__c();
            myNew.RecordTypeId=Historico_RecordTypeID;
            myNew.Fecha_Insercion__c=Datetime.now();
            myNew.Name= project.Codigo__c+' - '+string.valueof(date.today());
            myNew.Abierto__c=project.Abierto__c;
            myNew.Auditado_KPI_OACI__c=project.Auditado_KPI_OACI__c;
            myNew.Avance_Contractual_TDRs__c=project.Avance_Contractual_TDRs__c;
            myNew.AvanceContractualEntregables__c=project.AvanceContractualEntregables__c;
            myNew.Calculo_Coste_Prom_Inc_Coste_Prom_Resto__c=project.Calculo_Coste_Prom_Inc_Coste_Prom_Resto__c;
            myNew.Calculo_Coste_Prom_Inc_Coste_Prom_Resto__c=project.Calculo_Coste_Prom_Inc_Coste_Prom_Resto__c;
            myNew.Calculo_Inventario_Produccion_media__c=project.Calculo_Inventario_Produccion_media__c;
            myNew.Calculo_Margen_Prev_Margen_Plan__c=project.Calculo_Margen_Prev_Margen_Plan__c;
            myNew.Calculo_Pend_Cobro_Imp_Facturado__c=project.Calculo_Pend_Cobro_Imp_Facturado__c;
            myNew.Calculo_WIP_IC__c=project.Calculo_WIP_IC__c;
            myNew.Calculo_WIP_Prod_Media__c=project.Calculo_WIP_Prod_Media__c;
            myNew.CalculoDuracionPlan__c=project.CalculoDuracionPlan__c;
            myNew.CalculoDuracionPrevista__c=project.CalculoDuracionPrevista__c;
            myNew.CalculoDuracionReal__c=project.CalculoDuracionReal__c;
            myNew.Cambio_segun_moneda_local__c=project.Cambio_segun_moneda_local__c;
            myNew.Cobrado__c=project.Cobrado__c;
            myNew.Cobrado_EUR__c=project.Cobrado_EUR__c;
            myNew.Codigo__c=project.Codigo__c;           
            myNew.Comunicaciones__c=project.Comunicaciones__c;
            myNew.Consideraciones_OACI_a_KPI__c=project.Consideraciones_OACI_a_KPI__c;
            myNew.Cost_Prom_Inc_Cost_Promed__c=project.Cost_Promed_Inc_Cost_Promed__c;
            myNew.Coste_Directo_Real_EUR__c=project.Coste_Directo_Real_EUR__c;
            myNew.Coste_Directo_Previsto_EUR__c=project.Coste_Directo_Previsto_EUR__c;
            myNew.Coste_Dir_Real_Coste_Dir_Prev__c=project.Coste_Dir_Real_Coste_Dir_Prev__c;
            myNew.Coste_Promedio_Incurrido__c=project.Coste_Promedio_Incurrido__c;
            myNew.Coste_Promedio_Incurrido_EUR__c=project.Coste_Promedio_Incurrido_EUR__c;
            myNew.Coste_Promedio_Resto__c=project.Coste_Promedio_Resto__c;
            myNew.Coste_Promedio_Resto_EUR__c=project.Coste_Promedio_Resto_EUR__c;
            myNew.Coste_resto__c=project.Coste_resto__c;
            myNew.costeDirPrev__c=project.costeDirPrev__c;
            myNew.costeDirReal__c=project.costeDirReal__c;
            myNew.Entregable_s__c=project.Entregable_s__c;
            myNew.Entregables_Firmado__c=project.Entregables_Firmado__c;
            myNew.Estado_Datos_Economicos__c=project.Estado_Datos_Economicos__c;
            myNew.Facturacion__c=project.Facturacion__c;
            myNew.Facturacion_EUR__c=project.Facturacion_EUR__c;
            myNew.Facturacion_IC__c=project.Facturacion_IC__c;
            myNew.Fecha_alta_SAP__c=project.Fecha_alta_SAP__c;
            myNew.Fecha_Datos_Economicos__c=project.Fecha_Datos_Economicos__c;
            myNew.Fecha_limite_supervision_OACI__c=project.Fecha_limite_supervision_OACI__c;
            myNew.Fecha_ultimo_control_KPI_OACI__c=project.Fecha_ultimo_control_KPI_OACI__c;
            myNew.FFC__c=project.FFC__c;
            myNew.FFP__c=project.FFP__c;
            myNew.FIC__c=project.FIC__c;
            myNew.impcontrato__c=project.impcontrato__c;
            myNew.impcontrato_real__c=project.impcontrato_real__c;
            myNew.impcontratoEUR_real__c=project.impcontratoEUR_real__c;
            myNew.Importe_Contrato_EUR__c=project.Importe_Contrato_EUR__c;
            myNew.Inventario__c=project.Inventario__c;
            myNew.Inventario_EUR__c=project.Inventario_EUR__c;
            myNew.Inventario_Produccion_media__c=project.Inventario_Produccion_media__c;
            myNew.Margen_plan_EUR__c=project.Margen_plan_EUR__c;
            myNew.Margen_Plan_Margen_Prev__c=project.Margen_Plan_Margen_Prev__c;
            myNew.Margen_Prev_Margen_Plan__c=project.Margen_Prev_Margen_Plan__c;
            myNew.Margen_Previsto__c=project.Margen_Previsto__c;
            myNew.Margen_Previsto_EUR__c=project.Margen_Previsto_EUR__c;
            myNew.margenplan__c=project.margenplan__c;
            myNew.Mercado__c=project.Mercado__c;
            myNew.Mes_Datos_Economicos__c=project.Mes_Datos_Economicos__c;
            myNew.Moneda__c=project.Moneda__c;
            myNew.Pais__c=project.Pais__c;
            myNew.Pend_Cobro_Importe_Fact__c=project.Pend_Cobro_Importe_Fact__c;
            myNew.Pendiente_de_Cobro__c=project.Pendiente_Cobro__c;
            myNew.Pendiente_de_Cobro_EUR__c=project.Pendiente_de_Cobro_EUR__c;
            myNew.Porcentaje_de_producto__c=project.Porcentaje_de_producto__c;
            myNew.Porcentaje_de_producto_indicador__c=project.Porcentaje_de_producto_indicador__c;
            myNew.PR__c=project.PR__c;
            myNew.Prod_media__c=project.Prod_media__c;
            myNew.Produccion_Avance_EUR__c=project.Produccion_Avance_EUR__c;            
            myNew.Produccion_IC__c=project.Produccion_IC__c;
            myNew.Produccion_media_EUR__c=project.Produccion_media_EUR__c;
            myNew.Produccion_Real_EUR__c=project.Produccion_Real_EUR__c;
            myNew.Propietario__c= project.OwnerId;
            myNew.Proyecto__c=project.Id;
            myNew.Responsable_SAP__c=project.Responsable__c;
            myNew.Responsable_SAP_email__c=project.Responsable_email__c;
            myNew.Sub_area__c=project.Sub_area__c;
            myNew.Sub_area__c=project.Sub_area__c;
            myNew.Terminos_de_Referencia_Aprobados__c=project.Terminos_de_Referencia_Aprobados__c;
            myNew.TerminosReferencia__c=project.TerminosReferencia__c;
            myNew.WIP__c=project.WIP__c;
            myNew.WIP_EUR__c=project.WIP_EUR__c;
            myNew.WIP_ImporteContrato__c=project.WIP_ImporteContrato__c;
            myNew.WIP_ProdMedia__c=project.WIP_ProdMedia__c;
            myNew.Cobrado_FdP_EUR__c=project.Cobrado_FdP_EUR__c;
            myNew.Coste_resto_FdP_EUR__c =project.Coste_resto_FdP_EUR__c;
            myNew.costeDirPrev_FdP_EUR__c =project.costeDirPrev_FdP_EUR__c;
            myNew.costeDirReal_FdP_EUR__c=project.costeDirReal_FdP_EUR__c;
            myNew.Facturacion_FdP_EUR__c=project.Facturacion_FdP_EUR__c;
            myNew.impcontrato_FdP_EUR__c =project.impcontrato_FdP_EUR__c;
            myNew.Inventario_FdP_EUR__c =project.Inventario_FdP_EUR__c;
            myNew.Margen_Previsto_FdP_EUR__c =project.Margen_Previsto_FdP_EUR__c;
            myNew.margenplan_FdP_EUR__c =project.margenplan_FdP_EUR__c;
            myNew.Pendiente_Cobro_FdP_EUR__c =project.Pendiente_Cobro_FdP_EUR__c;
            myNew.PR_FdP_EUR__c =project.PR_FdP_EUR__c;
            myNew.WIP_FdP_EUR__c =project.WIP_FdP_EUR__c;
            
            
            
            
            //Para PROYECTOS
            //Actualizamos los valores de producción/facturación hace 3 meses
            //Si el mes de los datos económicos es diciembre guardamos producción/coste real diciembre
            if(project.Fecha_Datos_Economicos__c !=null && project.Fecha_Datos_Economicos__c.month()==12){
                
                project.PR_diciembre__c= project.PR__c;
                project.PR_diciembre_EUR__c= project.Produccion_Real_EUR__c;
                project.Coste_Real_diciembre__c=project.costeDirReal__c;
                project.Coste_Real_diciembre_EUR__c=project.Coste_Directo_Real_EUR__c;                
            }
            //Guardo la fecha de los datos económicos
            if(project.Fecha_Datos_Economicos__c>Fecha_datos_economicos){
                Fecha_datos_economicos=project.Fecha_Datos_Economicos__c;
            }
            
            myProjects_update.add(project);
            myHistoricoNew.add(myNew);
            
            
        }
        
        // update myProjects_update;
        
        //Busco el histórico de hace tres meses
        Datetime Date_3_months_ago = Fecha_datos_economicos.addMonths(-3);
        Integer Date_mes = Date_3_months_ago.month();
        Integer Date_year = Date_3_months_ago.year();
        System.debug('Fecha datos economicos:'+ Fecha_datos_economicos );
        System.debug('Busco los historicos de hace 3 meses: '+ Fecha_datos_economicos.addMonths(-3));
        
        List<Historico_estado_proyecto__c> Historico3monthsago_update= new List<Historico_estado_proyecto__c>();
        
        List<Historico_estado_proyecto__c> myHistorico3monthsago = [SELECT id, name, Proyecto__r.id,PR__c,Facturacion__c,Produccion_Real_EUR__c,Facturacion_EUR__c,PR_FdP_EUR__c,Facturacion_FdP_EUR__c FROM Historico_estado_proyecto__c 
                                                                    WHERE CALENDAR_MONTH(Fecha_datos_economicos__c) =: Date_mes 
                                                                    and CALENDAR_YEAR(Fecha_datos_economicos__c) =: Date_year];
        
        
        
        
        for (Proyecto__c proyecto: myProjects_update){
            for (Historico_estado_proyecto__c hist: myHistorico3monthsago){
                if(proyecto.id == hist.Proyecto__r.Id ){
                    proyecto.PR_hace_3_meses__c= hist.PR__c;
                    if(hist.PR_FdP_EUR__c!=null){
                        proyecto.PR_hace_3_meses_EUR__c= hist.PR_FdP_EUR__c;
                    }
                    proyecto.Facturacion_hace_3_meses__c = hist.Facturacion__c;
                    if(hist.Facturacion_FdP_EUR__c!=null){
                        proyecto.Facturacion_hace_3_meses_EUR__c = hist.Facturacion_FdP_EUR__c;
                    }
                }
            }
        }
        
        System.debug('Inserto el histórico y actualizo los proyectos');
        
        insert myHistoricoNew;
        update myProjects_update;
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}
// containsKey(key) devuelve TRUE si metiendo el KEY hay algun valor, si devuelve false es que no hay
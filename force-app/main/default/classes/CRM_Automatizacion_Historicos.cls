global class CRM_Automatizacion_Historicos implements Database.Batchable<sObject>{
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query='SELECT id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,LastModifiedDate,Codigo_AJI__c,Asistencia_juridica__c,Causa_resolucion__c,Causa_suspension__c,Comentarios__c,';
        query= query + 'Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,OwnerId, Prevision_situacion_contrato__c,';
             query= query +'Costes_a_reclamar_por_resolucion__c, Costes_a_reclamar_por_suspension__c, Costes_totales_resolucion__c,  Costes_a_reclamar_por_resolucion_local__c,Estimacion_costes_extra_local__c,';
                 query= query +'Costes_totales_resolucion_local__c, Costes_a_reclamar_por_suspension_local__c, Costes_totales_suspension_local__c,Estimacion_coste_extra_por_retraso_local__c,';
                 query= query +'Costes_totales_suspension__c, Derecho_a_reclamacion_por_suspension__c, Derecho_a_reclamacion_por_resolucion__c, Estimacion_coste_extra_por_retraso__c,';
                 query= query +'Estimacion_costes_extra__c, Estimacion_meses_de_retraso__c, Negociacion_modificacion_contractual__c,Negociacion_modificacion_finalizada__c, Prevision_costes_extra__c,';
                 query= query +'Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c, Costes_a_reclamar_por_retraso_local__c, Costes_aceptados_por_retraso_local__c, Mercado__c, DivisionPicklist__c FROM Contrato__c';

            System.debug('QUERY: '+ query);
            return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contrato__c> contratos){
        system.debug('Tamaño de lista de contratos:  ' + contratos.size());
        
       /* Integer mes = Date.Today().month() ;
        Integer dia=Date.Today().day() ;
        Integer anho = Date.Today().year();*/
        
         Integer mes = Datetime.now().monthGMT() ;
        Integer dia=Datetime.now().dayGMT();
        Integer anho = Datetime.now().yearGMT();
        
        List<Contrato__c> listaContratosFinal = new List<Contrato__c>();
        Map<Id, Contrato__c> mapaTodosContratos = new Map<Id, Contrato__c>(contratos);
        Set <Id> listIdContratos = new Set<Id>();
        listIdContratos = mapaTodosContratos.keySet();//lista de identificadores de todos los contratos
        
        String Historico_RecordTypeID = [SELECT id FROM RecordType WHERE name = 'Historico estado contrato' and sobjecttype ='Historico_estado_contrato__c'].Id;
        
        List<Historico_estado_contrato__c> myHistoricoListToday = [SELECT id, name, Contrato__r.id FROM Historico_estado_contrato__c 
                                                                   WHERE Contrato__r.id IN : listIdContratos and RecordTypeId =: Historico_RecordTypeID
                                                                   and CALENDAR_MONTH(CreatedDate) =: mes
                                                                   and DAY_IN_MONTH(CreatedDate)=: dia
                                                                   and CALENDAR_YEAR(CreatedDate)=: anho ]; 
        
        Map<Id, Historico_estado_contrato__c> mapaHistoricoToday= new Map<Id, Historico_estado_contrato__c>();
         system.debug('Tamaño de lista de historicos:  '+ myHistoricoListToday.size());
        
            for (Historico_estado_contrato__c hist : myHistoricoListToday){
            mapaHistoricoToday.put(hist.Contrato__r.id, hist);
            
        }
        
        for (Id idContrato : listIdContratos){
            if(mapaHistoricoToday.containsKey(idContrato)==false){
                listaContratosFinal.add(mapaTodosContratos.get(idContrato));
            }  
        }
        
        
         system.debug('Tamaño de lista de final de contratos:  '+ listaContratosFinal.size());
        
      
        
        //Recorro la lista de ID's de contratos y busco si hay en la lista de 
      

      List<Historico_estado_contrato__c> myHistoricoNew = new List<Historico_estado_contrato__c>();  
      
        for (Contrato__c con : listaContratosFinal){
            
           Historico_estado_contrato__c myNew = new Historico_estado_contrato__c();
           
            myNew.RecordTypeId=Historico_RecordTypeID;
            myNew.Fecha_historico__c=string.valueOf(dia)+'/'+string.valueOf(mes)+'/'+string.valueOf(anho);
            
            //fecha inserción para hacer el gráfico, 20/07/21 añadido
            //Solo se ejecuta con el trabajo programado (el 28 de cada mes)
            myNew.Fecha_Insercion__c=Datetime.now();
           
            myNew.Reqs_Contractuales_sobre_Presencialidad__c= con.Reqs_Contractuales_sobre_Presencialidad__c;
            myNew.Situacion_Actual_Contrato__c= con.Situacion_Actual_Contrato__c;
            myNew.Contrato__c=con.Id;
            myNew.name= con.Codigo_SAP__c+' - '+string.valueof(date.today());
            
            myNew.Causa_resolucion__c= con.Causa_resolucion__c;
            myNew.Causa_retraso__c= con.Causa_retraso__c;
            myNew.Causa_suspension__c= con.Causa_suspension__c;
            myNew.CeBe__c= con.CeBe__c;
            myNew.Comentarios__c= con.Comentarios__c;
            myNew.Costes_a_reclamar_por_resolucion_local__c= con.Costes_a_reclamar_por_resolucion_local__c;
            myNew.Costes_a_reclamar_por_suspension_local__c= con.Costes_a_reclamar_por_suspension_local__c;
            myNew.Costes_aceptados_resolucion_local__c= con.Costes_aceptados_resolucion_local__c;
            myNew.Costes_aceptados_suspension_local__c= con.Costes_aceptados_suspension_local__c;
            myNew.Costes_totales_resolucion_local__c= con.Costes_totales_resolucion_local__c;
            myNew.Costes_totales_suspension_local__c= con.Costes_totales_suspension_local__c;
            myNew.Derecho_a_reclamacion_por_resolucion__c= con.Derecho_a_reclamacion_por_resolucion__c;
            myNew.Derecho_a_reclamacion_por_suspension__c= con.Derecho_a_reclamacion_por_suspension__c;
            myNew.Estado__c= con.Estado__c;
            myNew.Estimacion_coste_extra_por_retraso_local__c= con.Estimacion_coste_extra_por_retraso_local__c;
            myNew.Estimacion_costes_extra_local__c= con.Estimacion_costes_extra_local__c;
            myNew.Estimacion_meses_de_retraso__c= con.Estimacion_meses_de_retraso__c;
            myNew.Moneda__c= con.Moneda__c;
            myNew.Negociacion_aceptada__c= con.Negociacion_aceptada__c;
            myNew.Negociacion_modificacion_contractual__c= con.Negociacion_modificacion_contractual__c;
            myNew.Negociacion_modificacion_finalizada__c= con.Negociacion_modificacion_finalizada__c;
            myNew.Pais__c= con.Pais__c;
            myNew.Prevision_costes_extra__c= con.Prevision_costes_extra__c;
            myNew.Sub_area__c= con.Sub_area__c;
            myNew.OwnerId= con.OwnerId; 
            myNew.Costes_a_reclamar_por_retraso_local__c=con.Costes_a_reclamar_por_retraso_local__c;
            myNew.Costes_aceptados_por_retraso_local__c=con.Costes_aceptados_por_retraso_local__c;
            myNew.Creacion_automatica__c=false;
            myNew.Prevision_situacion_contrato__c= con.Prevision_situacion_contrato__c;
            myNew.Mercado__c= con.Mercado__c;
            myNew.DivisionPicklist__c=con.DivisionPicklist__c;
            
            myHistoricoNew.add(myNew);
            
        }
     
       insert myHistoricoNew;
                            
                        }
    
    global void finish(Database.BatchableContext BC){
        
    }
}
// containsKey(key) devuelve TRUE si metiendo el KEY hay algun valor, si devuelve false es que no hay
//
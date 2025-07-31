trigger GC_Auto_Historico_Proyecto_trigger on Proyecto__c (before update) {
    Integer Num_proyectos_actualizados=0;
    
    for(Integer i=0; i<Trigger.New.size();i++){
        if (trigger.Old[i].Mes_Datos_Economicos__c != null && trigger.Old[i].Mes_Datos_Economicos__c != trigger.New[i].Mes_Datos_Economicos__c){
            Num_proyectos_actualizados=Num_proyectos_actualizados+1;
        }
    }
    System.debug('Num_proyectos_actualizados: '+Num_proyectos_actualizados);
    
    if(Num_proyectos_actualizados>0){
        GC_Automatizacion_Historicos_Proyecto b = new GC_Automatizacion_Historicos_Proyecto();
        ID batchprocessid = Database.executeBatch(b);
    }
}
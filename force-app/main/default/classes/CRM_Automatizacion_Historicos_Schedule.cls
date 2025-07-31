global class CRM_Automatizacion_Historicos_Schedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        CRM_Automatizacion_Historicos b = new CRM_Automatizacion_Historicos();
        ID batchprocessid = Database.executeBatch(b);

    }

}
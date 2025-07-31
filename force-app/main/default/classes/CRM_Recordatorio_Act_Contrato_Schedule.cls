global class CRM_Recordatorio_Act_Contrato_Schedule implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        CRM_Recordatorio_Actualizacion_Contrato b = new CRM_Recordatorio_Actualizacion_Contrato();
        ID batchprocessid = Database.executeBatch(b);
        
    }
}
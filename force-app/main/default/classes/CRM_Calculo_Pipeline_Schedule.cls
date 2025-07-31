global class CRM_Calculo_Pipeline_Schedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        CRM_Calculo_Pipeline b = new CRM_Calculo_Pipeline();
        ID batchprocessid = Database.executeBatch(b);

    }

}
global class CRM_Notific_Op_Incoherentes_Schedule implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        If(Test.isRunningTest()){
        	ID jobID = Database.executeBatch(new CRM_Notific_Op_Incoherentes(), 200);
            System.abortJob(jobID);
        }else{
      		Database.executeBatch(new CRM_Notific_Op_Incoherentes());
		}
        
    }
}
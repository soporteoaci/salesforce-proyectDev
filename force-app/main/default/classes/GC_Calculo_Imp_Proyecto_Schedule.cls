global class GC_Calculo_Imp_Proyecto_Schedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
      //  GC_Calculo_Imp_Proyecto.Calculoimporte();
         GC_Calculo_Imp_Proyecto b = new GC_Calculo_Imp_Proyecto();
        ID batchprocessid = Database.executeBatch(b);
        
    }
    
}
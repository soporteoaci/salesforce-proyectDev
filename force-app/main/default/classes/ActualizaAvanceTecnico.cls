global class ActualizaAvanceTecnico implements Schedulable{    
    
    global void execute(SchedulableContext SC) {
        
        Proyecto__c[] proyectos = [select id from Proyecto__c];
        List<Id> proyIds = new List<Id>();
        for(Proyecto__c p : proyectos){
            proyIds.add(p.Id);
        } 
        Entregable__c[] grupoEntregables = [select id, AvanceTotal__c, Avance_Total_Mes__c from Entregable__c where Proyecto__c IN :proyIds];
        for(Entregable__c e : grupoEntregables){
            e.Avance_Total_Mes__c = e.AvanceTotal__c;
        }
        update grupoEntregables;
        
    }
    
}
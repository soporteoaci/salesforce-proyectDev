trigger FechaPrimeraLiberacion on Subentregable__c (before update) {
    
    
    
    for (Subentregable__c entregable: Trigger.New){
        
        DateTime old_Fecha_Primera_Liberacion = Trigger.oldMap.get(entregable.id).Fecha_Primera_Liberacion__c;
        DateTime old_Fecha_Real_de_Liberacion = Trigger.oldMap.get(entregable.id).Fecha_Real_de_Liberacion__c;
        
        
        If(old_Fecha_Primera_Liberacion== null  && old_Fecha_Real_de_Liberacion==null && entregable.Fecha_Real_de_Liberacion__c != null){
            
            entregable.Fecha_Primera_Liberacion__c=  entregable.Fecha_Real_de_Liberacion__c;
            
        }
        
    }
}
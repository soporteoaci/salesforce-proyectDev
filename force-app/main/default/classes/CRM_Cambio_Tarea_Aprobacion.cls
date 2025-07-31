public class CRM_Cambio_Tarea_Aprobacion {
    
    @AuraEnabled
    public static Boolean doinit(String idTarea){
        String user_Id = UserInfo.getUserId();
        Boolean mostrar_mensaje;
        
        Tarea_aprobacion__c tarea = [SELECT Id, Name, OwnerId FROM Tarea_aprobacion__c where Id =: idTarea Limit 1];
        System.debug('OwnerId: '+ tarea.OwnerId);
        System.debug('UserID: '+ user_Id);
        if(tarea.OwnerId == user_Id){
            mostrar_mensaje= false;
        }else{
            mostrar_mensaje= true;
        }
        System.debug('Mostrar mensaje: '+ mostrar_mensaje);
        return mostrar_mensaje;
        
    }
    
    @AuraEnabled
    public static string actualizar_decision(String idTarea){
        
       Tarea_aprobacion__c tarea = [SELECT Id, Name, Decision__c, OwnerId FROM Tarea_aprobacion__c where Id =: idTarea Limit 1]; 
       tarea.Decision__c ='Aprobado';
        
        try{
            update tarea;
            
        } catch(DMLException e){ 
            System.debug('Error actualización tarea de aprobacion: ' + e.getMessage());
            return e.getMessage();            
        }	
           
           return 'ok';
        
    }

}
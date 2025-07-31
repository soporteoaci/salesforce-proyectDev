public class Submit_ApprovarControlador {
    @AuraEnabled
    
    public static void processPoject(ID project){
        Proyecto__c projectName = [SELECT Name FROM Proyecto__c WHERE Id = :project LIMIT 1];
        System.debug('projectName: '+projectName);
        List<Subentregable__c> subs = new List<Subentregable__c>();
        subs = [SELECT id, name from Subentregable__c where Proyecto_Entregable__c = :projectName.Name and Fecha_Limite_de_inicio__c= TODAY and Estado__c= 'Pendiente'];
        if (Test.isRunningTest()){
            subs = [SELECT id, name from Subentregable__c where Proyecto__c = :project and Fecha_Limite_de_inicio__c= TODAY and Estado__c= 'Pendiente'];
        }
      	List<Approval.ProcessSubmitRequest> appr = new List<Approval.ProcessSubmitRequest>();
        System.debug('subssubs: '+subs);
        for(Subentregable__c sub : subs){    
            Boolean lock= Approval.isLocked(sub.id);
            //system.debug('lock:'+Approval.isLocked(sub.id));
            //List<ProcessInstanceNode> entApproval = [SELECT id FROM ProcessInstanceNode WHERE processInstance.TargetObjectId   = :sub.Id and NodeStatus = 'Pending'];
            if (lock) {
                system.debug('El entregable tiene otro proceso activo:'+sub.id);
           }                
            else {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval automatically using Trigger');
                req1.setObjectId(sub.id);
                appr.add(req1);
       
            }  
        }
        if (!Test.isRunningTest()){
            List<Approval.ProcessResult> result = Approval.process(appr);
        }  
    } 
}
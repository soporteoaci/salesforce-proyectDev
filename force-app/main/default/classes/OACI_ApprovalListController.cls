public class OACI_ApprovalListController {

  @AuraEnabled
  public static List<ProcessInstanceWorkitem> getProcessInstances() {
      
      Id currentUserId = UserInfo.getUserId();
      
    return [select id, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.id, ProcessInstance.ProcessDefinition.id from ProcessInstanceWorkitem where ActorId =: currentUserId and ProcessInstance.Status = 'Pending' order by CreatedDate desc ];
    
	}
  }
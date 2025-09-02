trigger OpportunityTrigger on Opportunity (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.setDireccionOperacionesOnBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OpportunityTriggerHandler.setProbabilityOnBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
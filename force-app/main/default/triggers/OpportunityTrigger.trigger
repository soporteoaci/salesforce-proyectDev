trigger OpportunityTrigger on Opportunity (before insert, before update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        OpportunityTriggerHandler.setDireccionOperacionesOnBeforeInsert(Trigger.new);
    }

}
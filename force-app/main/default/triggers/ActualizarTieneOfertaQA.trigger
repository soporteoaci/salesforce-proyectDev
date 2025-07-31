trigger ActualizarTieneOfertaQA on Tarea_aprobacion__c (after insert, after update, after delete, after undelete) {
    Set<Id> oportunidadIds = new Set<Id>();
    List<Tarea_aprobacion__c> tareaList = Trigger.isDelete ? Trigger.old : Trigger.new;

    for (Tarea_aprobacion__c t : tareaList) {
        if (t.Oportunidad__c != null) {
            oportunidadIds.add(t.Oportunidad__c);
        }
    }

    if (oportunidadIds.isEmpty()) return;

    Map<Id, Boolean> oportunidadTieneQA = new Map<Id, Boolean>();

    for (AggregateResult ar : [
        SELECT Oportunidad__c Id, COUNT(Id) total
        FROM Tarea_aprobacion__c
        WHERE Oportunidad__c IN :oportunidadIds
        AND Tipo__c IN ('Oferta QA Económico', 'Oferta QA Técnico')
        GROUP BY Oportunidad__c
    ]) {
        oportunidadTieneQA.put((Id) ar.get('Id'), true);
    }

    List<Oportunidad__c> oportunidadesActualizar = new List<Oportunidad__c>();

    for (Id oppId : oportunidadIds) {
        Boolean tieneQA = oportunidadTieneQA.containsKey(oppId);
        oportunidadesActualizar.add(new Oportunidad__c(
            Id = oppId,
            Tiene_Oferta_QA__c = tieneQA
        ));
    }

    update oportunidadesActualizar;
}
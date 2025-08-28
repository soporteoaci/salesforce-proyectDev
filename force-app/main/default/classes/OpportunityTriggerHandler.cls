public class OpportunityTriggerHandler {

    /**
     * Before-insert para Opportunity.
     * - Informa Fecha_Creacion__c (sustituye al PB antiguo).
     * - Fija StageName según el Record Type (DeveloperName):
     *     Ingenier_a, IT_DS -> 'Cualificación'
     *     Innovaci_n        -> 'Oferta'
     *   Se asume que siempre viene RecordTypeId informado.
     */
    public static void setDireccionOperacionesOnBeforeInsert(List<Opportunity> opps) {
        if (opps == null || opps.isEmpty()) return;
        Map<String, String> stageByRt = new Map<String, String>{
            'Ingenier_a' => 'Cualificación',
            'IT_DS'      => 'Cualificación',
            'Innovaci_n' => 'Oferta'
        };

        Map<Id, Schema.RecordTypeInfo> rtById =
            Schema.SObjectType.Opportunity.getRecordTypeInfosById();

        for (Opportunity opp : opps) {
            if (opp == null) continue;

            // 1) Fecha de creación (hoy)
            opp.Fecha_Creacion__c = Date.today();

            Schema.RecordTypeInfo rti = rtById.get(opp.RecordTypeId);
            if (rti == null) continue;

            // 3) Asignar Stage por RT
            String desiredStage = stageByRt.get(rti.getDeveloperName());
            if (desiredStage != null) {
                opp.StageName = desiredStage;
            }
        }
    }
}
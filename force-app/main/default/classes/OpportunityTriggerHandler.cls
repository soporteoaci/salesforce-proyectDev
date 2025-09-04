public class OpportunityTriggerHandler {
    
    // ==== Config ====
    private static final Set<String> RT_45 = new Set<String>{ 'Ingenier_a', 'IT_DS' };
        private static final String STAGE_OFERTA = 'Oferta';
    private static final Decimal PROB_45 = 45;
    private static Map<String, String> stageByRt = new Map<String, String>{
        	'Ingenier_a' => 'Cualificación',
            'IT_DS'      => 'Cualificación',
            'Innovaci_n' => 'Oferta'
            };
                private Map<Id, Schema.RecordTypeInfo> rtById =
                Schema.SObjectType.Opportunity.getRecordTypeInfosById();
    
    
    
    /**
* BEFORE INSERT:
* - Informa Fecha_Creacion__c.
* - No tocamos StageName (ya viene).
* - Forzamos 45% solo para (RT Ingenier_a/IT_DS + Stage 'Oferta').
*   (No usamos OpportunityStage; Salesforce ya puebla Probability por Stage por defecto,
*    pero aquí sobreescribimos el caso especial).
*/
    public static void setDireccionOperacionesOnBeforeInsert(List<Opportunity> opps) {
        if (opps == null || opps.isEmpty()) return;
        
        Map<Id, Schema.RecordTypeInfo> rtById =
            Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        
        for (Opportunity opp : opps) {
            if (opp == null) continue;
            
            // Fecha creación
            opp.Fecha_Creacion__c = Date.today();
            
            //Mete stage name segun mapa : stageByRt
            Schema.RecordTypeInfo rti = rtById.get(opp.RecordTypeId);
            if (rti == null) continue;
            
            String desiredStage = stageByRt.get(rti.getDeveloperName());
            if (desiredStage != null) {
                opp.StageName = desiredStage;
            }
            
            // Excepción 45% en creación
            //forceProbability(opp, rtById);
        }
    }
    
    /**
* BEFORE UPDATE:
* - Si el usuario cambió Probability manualmente, se respeta (no tocamos).
* - Si cambió StageName y el usuario NO tocó Probability, dejamos que Salesforce
*   ajuste Probability automáticamente por Stage, salvo la excepción:
*     * RT Ingenier_a/IT_DS + Stage 'Oferta' => forzar 45%.
* - Además, si cambia el RT hacia Ingenier_a/IT_DS y la Stage YA es 'Oferta'
*   (y el usuario no ha tocado Probability), forzamos 45% también.
*/
    public static void setProbabilityOnBeforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        if (newList == null || newList.isEmpty()) return;
        
        Map<Id, Schema.RecordTypeInfo> rtById =
            Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        
        for (Opportunity n : newList) {
            Opportunity o = oldMap.get(n.Id);
            if (n == null || o == null) continue;
            
            // 1) Si el usuario tocó Probability, respetar
            Boolean probChangedByUser = (n.Probability != o.Probability);
            if (probChangedByUser) continue;
            
            // 2) Detectar cambios relevantes
            Boolean stageChanged = (n.StageName != o.StageName);
            
            String newRtDev = getRtDevName(n, rtById);
            String oldRtDev = getRtDevName(o, rtById);
            Boolean rtChangedToTarget =
                (oldRtDev == null || !RT_45.contains(oldRtDev)) &&
                (newRtDev != null && RT_45.contains(newRtDev));
            
            // 3) Si la Stage cambió a 'Oferta' con RT objetivo, o el RT cambió a objetivo con Stage 'Oferta'
            if ((stageChanged && STAGE_OFERTA == n.StageName && newRtDev != null && RT_45.contains(newRtDev))
                || (rtChangedToTarget && STAGE_OFERTA == n.StageName)) {
                    // Forzar 45% (sobrescribe el auto-ajuste estándar)
                    n.Probability = PROB_45;
                }
            
            // En cualquier otro caso, no hacemos nada: dejamos el comportamiento estándar.
        }
    }
    
    private static String getRtDevName(Opportunity opp, Map<Id, Schema.RecordTypeInfo> rtById) {
        if (opp == null || opp.RecordTypeId == null) return null;
        Schema.RecordTypeInfo rti = rtById.get(opp.RecordTypeId);
        return (rti != null) ? rti.getDeveloperName() : null;
    }
    
    private static void forceProbability(Opportunity opp, Map<Id, Schema.RecordTypeInfo> rtById) {
        String devName = getRtDevName(opp, rtById);
        //Para ITDS e Ingeniería, 45% Probabilidad.
        if (devName != null && RT_45.contains(devName) && STAGE_OFERTA == opp.StageName) {
            opp.Probability = PROB_45;
        }
    }
}
public class OpportunityTriggerHandler {
    /**
     * Simplificado: sólo existen 3 Record Types con DeveloperName fijo:
     *  - Ingenier_a
     *  - IT_DS
     *  - Innovaci_n
     * Se eliminan helpers y sets de variaciones.
     */

    // === Record Types (DeveloperName fijos) ===
    private static final String RT_ING = 'Ingenier_a';
    private static final String RT_IT  = 'IT_DS';
    private static final String RT_INN = 'Innovaci_n';

    private static final String STAGE_PRESENTADA = 'Presentada (negociación y cierre)';

    // Subfases por probabilidad
    private static final Set<String> SUBFASE_0 = new Set<String>{ 'Perdida', 'Aplazada / anulada' };
    private static final Set<String> SUBFASE_30 = new Set<String>{ 'Esperando decisión con competidores NO favoritos (Pública)', 'Defendiendo con competidores NO favoritos (Privada)' };
    private static final Set<String> SUBFASE_90 = new Set<String>{ 'Defendiendo sin competidores (Privada)', 'Esperando decisión sin competidores (Pública)', 'Negociando condiciones de cierre (Privada)' };
    private static final Set<String> SUBFASE_50_70 = new Set<String>{ 'Esperando decisión con competidores favoritos (Pública)', 'Defendiendo con competidores favoritos (Privada)', 'Elegidos técnicamente: Pte sobre económico (Pública)' };
    private static final Set<String> SUBFASE_100 = new Set<String>{ 'Ganada pendiente de contrato', 'Ganada' };

    private static final Set<String> TIPO_NEGOCIO_NN_NC = new Set<String>{ 'Nuevo Negocio', 'Nuevo Cliente' };

    private Map<Id, Schema.RecordTypeInfo> rtById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();

    private static List<Decimal> pendingInsertUserProbabilities = new List<Decimal>();
    private static Boolean afterInsertRan = false;

    // ================================================
    // BEFORE INSERT
    // ================================================
    public static void setDireccionOperacionesOnBeforeInsert(List<Opportunity> opps) {
        if (opps == null || opps.isEmpty()) return;
        Map<Id, Schema.RecordTypeInfo> rtByIdLocal = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity opp : opps) {
            if (opp == null) continue;
            opp.Fecha_Creacion__c = Date.today();
            Schema.RecordTypeInfo rti = (opp.RecordTypeId != null) ? rtByIdLocal.get(opp.RecordTypeId) : null;
            String rtDev = (rti != null) ? rti.getDeveloperName() : null;
            if (rtDev == null) continue;

            Decimal userProb = opp.Probability; // puede ser null
            pendingInsertUserProbabilities.add(userProb);

            // Stage inicial
            if (rtDev == RT_ING || rtDev == RT_IT) {
                opp.StageName = 'Cualificación';
            } else if (rtDev == RT_INN) {
                opp.StageName = 'Oferta';
            }

            try {
                if (rtDev == RT_ING) {
                    opp.put('Direccion_de_Operaciones__c', 'Engineering');
                    opp.Probability = 30; // siempre 30 Ingeniería
                } else if (rtDev == RT_IT) {
                    opp.put('Direccion_de_Operaciones__c', 'IT&DS');
                    if (userProb != null) opp.Probability = userProb;
                } else if (rtDev == RT_INN) {
                    opp.put('Direccion_de_Operaciones__c', 'Innovación');
                    if (userProb != null) opp.Probability = userProb;
                }
            } catch (Exception e) {
                System.debug('Campo Direccion_de_Operaciones__c no disponible: ' + e.getMessage());
            }
        }
    }

    // ================================================
    // BEFORE UPDATE
    // ================================================
    public static void setProbabilityOnBeforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        if (newList == null || newList.isEmpty()) return;
        Map<Id, Schema.RecordTypeInfo> rtByIdLocal = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity oppNew : newList) {
            Opportunity oppOld = oldMap.get(oppNew.Id);
            if (oppNew == null || oppOld == null) continue;
            String rtDev = getRtDevName(oppNew, rtByIdLocal);
            if (rtDev == null) continue;

            Boolean stageChanged = oppNew.StageName != oppOld.StageName;

            // Ingeniería: mantener la última probabilidad definida (inicial 30 o la cambiada por el KAM) aunque cambie Stage/Subfase
            if (rtDev == RT_ING) {
                if (stageChanged) {
                    // Si el usuario intenta cambiar Stage y Probability a la vez, asumimos que quiere mantener su nueva Probability.
                    // Para permitir cambio simultáneo, sólo restauramos cuando Probability NO cambió respecto al valor anterior
                    if (oppNew.Probability == oppOld.Probability) {
                        // Stage mapping pudo sobreescribir -> restaurar el valor previo
                        System.debug(LoggingLevel.DEBUG,'[Prob] ING stage change ' + oppOld.StageName + ' -> ' + oppNew.StageName + ' restaurar ' + oppOld.Probability);
                        oppNew.Probability = oppOld.Probability;
                    } else {
                        System.debug(LoggingLevel.DEBUG,'[Prob] ING stage change con cambio manual de prob ' + oppOld.Probability + ' -> ' + oppNew.Probability + ' permitido');
                    }
                }
                // No más lógica para Ingeniería
                continue;
            }

            // IT & Innovación: mantener probabilidad manual mientras no se entre en Presentada
            if (rtDev == RT_IT || rtDev == RT_INN) {
                if (stageChanged) {
                    if (oppNew.StageName == STAGE_PRESENTADA) {
                        // Al entrar en Presentada, calcular según Subfase / Tipo de Negocio
                        Decimal nuevaProb = calcularProbabilidadPresentada(oppNew);
                        if (nuevaProb != null) {
                            System.debug(LoggingLevel.DEBUG,'[Prob] IT/INN entra Presentada Subfase=' + oppNew.get('Subfase__c') + ' -> ' + nuevaProb);
                            oppNew.Probability = nuevaProb;
                        } else {
                            System.debug(LoggingLevel.INFO,'[Prob] IT/INN Presentada sin regla Subfase=' + oppNew.get('Subfase__c'));
                        }
                    } else {
                        // Cambio de etapa distinto a Presentada: restaurar la probabilidad previa del KAM
                        System.debug(LoggingLevel.DEBUG,'[Prob] IT/INN stage change ' + oppOld.StageName + ' -> ' + oppNew.StageName + ' mantener ' + oppOld.Probability);
                        oppNew.Probability = oppOld.Probability;
                    }
                }
                // Si no cambió la etapa, no tocar la probabilidad (puede haberla modificado el usuario directamente)
            }
        }
    }

    // =============================================================
    // Helper cálculo Probabilidad (Stage Presentada)
    // =============================================================
    private static Decimal calcularProbabilidadPresentada(Opportunity opp) {
        String subfase = (String) opp.get('Subfase__c');
        String tipoNeg = (String) opp.get('Tipo_de_Negocio__c');
        if (String.isBlank(subfase)) return null;
        if (SUBFASE_0.contains(subfase))   return 0;
        if (SUBFASE_30.contains(subfase))  return 30;
        if (SUBFASE_90.contains(subfase))  return 90;
        if (SUBFASE_100.contains(subfase)) return 100;
        if (SUBFASE_50_70.contains(subfase)) {
            if (!String.isBlank(tipoNeg) && TIPO_NEGOCIO_NN_NC.contains(tipoNeg)) return 50;
            return 70;
        }
        return null;
    }

    private static String getRtDevName(Opportunity opp, Map<Id, Schema.RecordTypeInfo> rtById) {
        if (opp == null || opp.RecordTypeId == null) return null;
        Schema.RecordTypeInfo rti = rtById.get(opp.RecordTypeId);
        return (rti != null) ? rti.getDeveloperName() : null;
    }

    // AFTER INSERT: restaurar Probabilidad original usuario para IT/Innovación si fue sobrescrita por mapping estándar
    public static void restoreProbabilityOnAfterInsert(List<Opportunity> inserted) {
        if (afterInsertRan) return;
        afterInsertRan = true;
        if (inserted == null || inserted.isEmpty()) return;
        Map<Id, Schema.RecordTypeInfo> rtByIdLocal = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        List<Opportunity> toUpdate = new List<Opportunity>();
        for (Integer i = 0; i < inserted.size(); i++) {
            Opportunity opp = inserted[i];
            Decimal originalUserProb = (i < pendingInsertUserProbabilities.size()) ? pendingInsertUserProbabilities[i] : null;
            Schema.RecordTypeInfo rti = (opp.RecordTypeId != null) ? rtByIdLocal.get(opp.RecordTypeId) : null;
            String rtDev = (rti != null) ? rti.getDeveloperName() : null;
            if (rtDev == null) continue;
            Opportunity upd = new Opportunity(Id = opp.Id);
            if (rtDev == RT_ING) {
                if (opp.Probability != 30) {
                    upd.Probability = 30;
                    toUpdate.add(upd);
                }
                continue;
            }
            if (rtDev == RT_IT || rtDev == RT_INN) {
                if (originalUserProb != null && opp.Probability != originalUserProb) {
                    upd.Probability = originalUserProb;
                    toUpdate.add(upd);
                }
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        pendingInsertUserProbabilities.clear();
    }
}
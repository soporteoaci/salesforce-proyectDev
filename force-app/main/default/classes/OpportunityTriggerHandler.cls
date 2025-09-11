public class OpportunityTriggerHandler {

    // === Record Types (DeveloperName fijos) ===
    private static final String RT_ING = 'Ingenier_a';
    private static final String RT_IT  = 'IT_DS';
    private static final String RT_INN = 'Innovaci_n';

    private static final String STAGE_PRESENTADA = 'Presentada (negociación y cierre)';

    // Subfases por probabilidad (API Names)
    private static final Set<String> SUBFASE_0 = new Set<String>{ 'Perdida', 'Aplazada / anulada' };
    private static final Set<String> SUBFASE_30 = new Set<String>{ 'Esperando decisión con competidores NO favoritos', 'Defendiendo con competidores NO favoritos' };
    private static final Set<String> SUBFASE_90 = new Set<String>{ 'Defendiendo sin competidores', 'Esperando decisión sin competidores', 'Negociando condiciones de cierre' };
    private static final Set<String> SUBFASE_50_70 = new Set<String>{ 'Esperando decisión con competidores favoritos', 'Defendiendo con competidores favoritos', 'Elegidos técnicamente: Pte sobre económico' };
    private static final Set<String> SUBFASE_100 = new Set<String>{ 'Ganada pendiente contrato', 'Ganada' };

    // NOTA: 'No presentada' actualmente no altera probabilidad. Indica si debe mapearse (probable 0%) y lo añadimos.

    private static final Set<String> TIPO_NEGOCIO_NN_NC = new Set<String>{ 'Nuevo Negocio', 'Nuevo Cliente' };

    private Map<Id, Schema.RecordTypeInfo> rtById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
    private static List<Decimal> pendingInsertUserProbabilities = new List<Decimal>();
    private static Boolean afterInsertRan = false;

    // BEFORE INSERT
    public static void setDireccionOperacionesOnBeforeInsert(List<Opportunity> opps) {
        if (opps == null || opps.isEmpty()) return;
        Map<Id, Schema.RecordTypeInfo> rtByIdLocal = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity opp : opps) {
            if (opp == null) continue;
            opp.Fecha_Creacion__c = Date.today();
            Schema.RecordTypeInfo rti = (opp.RecordTypeId != null) ? rtByIdLocal.get(opp.RecordTypeId) : null;
            String rtDev = (rti != null) ? rti.getDeveloperName() : null;
            if (rtDev == null) continue;

            Decimal userProb = opp.Probability;
            pendingInsertUserProbabilities.add(userProb);

            // Stage inicial
            if (rtDev == RT_ING || rtDev == RT_IT) {
                opp.StageName = 'Cualificación';
            } else if (rtDev == RT_INN) {
                opp.StageName = 'Oferta';
            }

            // Asignación de probabilidad inicial según RT (sin tocar Direccion_de_Operaciones__c)
            if (rtDev == RT_ING) {
                opp.Probability = 30; // Ingeniería siempre arranca 30
            } else if (rtDev == RT_IT || rtDev == RT_INN) {
                if (userProb != null) opp.Probability = userProb; // respetar valor introducido
            }
        }
    }

    // BEFORE UPDATE
    public static void setProbabilityOnBeforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        if (newList == null || newList.isEmpty()) return;
        Map<Id, Schema.RecordTypeInfo> rtByIdLocal = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity oppNew : newList) {
            Opportunity oppOld = oldMap.get(oppNew.Id);
            if (oppNew == null || oppOld == null) continue;
            String rtDev = getRtDevName(oppNew, rtByIdLocal);
            if (rtDev == null) continue;

            Boolean stageChanged = oppNew.StageName != oppOld.StageName;
            Boolean subfaseChanged = oppNew.get('Subfase__c') != oppOld.get('Subfase__c');
            Boolean tipoNegChanged = oppNew.get('Tipo_de_Negocio__c') != oppOld.get('Tipo_de_Negocio__c');

            // Ingeniería
            if (rtDev == RT_ING) {
                if (stageChanged) {
                    oppNew.Probability = oppOld.Probability;
                }
                continue;
            }

            // IT & Innovación
            if (rtDev == RT_IT || rtDev == RT_INN) {
                if (oppNew.StageName == STAGE_PRESENTADA) {
                    if (stageChanged) {
                        // Entrando en Presentada: intentar calcular; si no hay regla (Subfase vacía o sin match) conservar prob previa (no dejar el mapping estándar de Stage)
                        Decimal nuevaProb = calcularProbabilidadPresentada(oppNew);
                        if (nuevaProb != null) {
                            oppNew.Probability = nuevaProb;
                        } else {
                            oppNew.Probability = oppOld.Probability;
                        }
                    } else if (subfaseChanged || tipoNegChanged) {
                        // Ya en Presentada: recalcular solo si cambia Subfase o Tipo de Negocio
                        Decimal nuevaProb = calcularProbabilidadPresentada(oppNew);
                        if (nuevaProb != null) {
                            oppNew.Probability = nuevaProb;
                        } else {
                            System.debug(LoggingLevel.INFO,'[Prob] IT/INN Presentada cambio Subfase/TipoNeg sin regla. Mantener actual ' + oppNew.Probability);
                        }
                    }
                } else if (stageChanged) {
                    // Cambio entre etapas distintas a Presentada: mantener prob previa
                    oppNew.Probability = oppOld.Probability;
                }
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

    // AFTER INSERT: sólo restaura Probabilidad original usuario para IT/Innovación si fue sobrescrita por mapping estándar
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

            // Ingeniería: sin acción (se dejó en 30% en before insert y no queremos recalcar nada aquí)
            if (rtDev == RT_ING) continue;

            // IT / Innovación: si el mapping de etapa sobreescribió la probabilidad original del usuario, restaurar
            if (rtDev == RT_IT || rtDev == RT_INN) {
                if (originalUserProb != null && opp.Probability != originalUserProb) {
                    Opportunity upd = new Opportunity(Id = opp.Id, Probability = originalUserProb);
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
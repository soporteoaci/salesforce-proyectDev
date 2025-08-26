public class OpportunityTriggerHandler {
    
    public static void setDireccionOperacionesOnBeforeInsert(List<Opportunity> opps) {
        if (opps == null || opps.isEmpty()) return;

        Map<Id, Schema.RecordTypeInfo> rtById =
            Schema.SObjectType.Opportunity.getRecordTypeInfosById();

        Id defaultRtId = null;
        for (Schema.RecordTypeInfo info : Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (info.isDefaultRecordTypeMapping()) {
                defaultRtId = info.getRecordTypeId();
                break;
            }
        }
        
        Map<String,String> mapRtNameToDireccion = new Map<String,String>{
            'IT_DS'       => 'IT&DS',
            'Innovaci_n'  => 'INNOVATION',
            'Ingenier_a'  => 'ENGINEERING'
        };
                    
        for (Opportunity opp : opps) {
            //Informa fecha de creación, suple a antiguo process builder.
            opp.Fecha_Creacion__c = Date.today();
            if (opp == null) continue;

            if (String.isNotBlank(opp.Direccion_Operaciones__c)) continue;

            Id rtId = (opp.RecordTypeId != null) ? opp.RecordTypeId : defaultRtId;
            if (rtId == null) continue;

            Schema.RecordTypeInfo rti = rtById.get(rtId);
            if (rti == null) continue;

            String direccion = mapRtNameToDireccion.get(rti.getDeveloperName());
            if (direccion != null) {
                opp.Direccion_Operaciones__c = direccion;
            }
        }
    }
}
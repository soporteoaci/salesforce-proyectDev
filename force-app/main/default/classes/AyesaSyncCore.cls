public class AyesaSyncCore {
    
    private static string sOpen = 'Pendiente', sClosed = 'Aprobado';
    //private static string ePending = 'Pendiente', eDev ='En desarrollo', eFree = 'Liberado', eClosed = 'Firmado';
   
    public static void processTDRS(List<ID> tdrIds){
        // Se sincronizan los estados de los TDR's asociados a los subentregables     +
        
        Termino_de_Referencia__c tmpTdr;
        List<Termino_de_Referencia__c> finalTdrs = new List<Termino_de_Referencia__c>();
        List<AggregateResult> openTdrs = [select terminoreferencia__c, count(subentregable__r.Id) open from TDRSubentregable__c where subentregable__r.cerrado__c = false and terminoreferencia__c in :tdrIds group by terminoreferencia__c];   
        for(AggregateResult tdr : openTdrs){
            tmpTdr = new Termino_de_Referencia__c();
            tmpTdr.Id = (Id)tdr.get('TerminoReferencia__c');
            tmpTdr.estado__c = AyesaSyncCore.sOpen;
            tdrIds.remove(tdrIds.indexOf(tmpTdr.Id));       
            finalTdrs.add(tmpTdr);
        }
        
        List<Termino_de_Referencia__c> closedTdrs = [select id from Termino_de_Referencia__c where id in (select terminoreferencia__c from TDRSubentregable__c where terminoreferencia__c in:tdrIds)];       
        for(Termino_de_Referencia__c tdr : closedTdrs){   
            tdr.estado__c = AyesaSyncCore.sClosed;
            finalTdrs.add(tdr);
        }
        
        List<Termino_de_Referencia__c> uncoveredTdrs = [select id from Termino_de_Referencia__c where id in :tdrids and id not in (select terminoreferencia__c from TDRSubentregable__c where terminoreferencia__c in:tdrIds)];       
        for(Termino_de_Referencia__c tdr : uncoveredTdrs){   
            tdr.estado__c = AyesaSyncCore.sOpen;
            finalTdrs.add(tdr);
        }
        
        Map<Id, Termino_de_Referencia__c> mapTdr = new Map<Id, Termino_de_Referencia__c>();
        mapTdr.putAll(finalTdrs);
        update mapTdr.values();
        
    }
    
    
    @AuraEnabled
    public static void processPoject(ID project){
        List<Termino_de_Referencia__c> tdrs = [SELECT id from Termino_de_Referencia__c where proyecto__c = :project];
        List<Id> ids = new List<ID>();
        for(Termino_de_Referencia__c tdr : tdrs){
            ids.add(tdr.Id);
        }
        AyesaSyncCore.processTDRS(ids);
    
    }
    
 /*   public static void processSubentregables (List<Id> lSubs){
        // Se sincroniza el estado de los entregables asociados.
        List<Entregable__c> lEnt2Update = new List<Entregable__c>();
        
        List<Subentregable__c> subsToProcess = [select id, entregable__r.cerrado__c, entregable__r.AvanceContractual__c, entregable__r.NumeroSubentregables__c, entregable__r.Subentregables_Liberados__c from Subentregable__c where entregable__c in :lSubs];
        Entregable__c tmpEnt;
        
        for(Subentregable__c sub: subsToProcess){
            tmpEnt = sub.entregable__r;
            if(!tmpEnt.cerrado__c && tmpEnt.AvanceContractual__c == 1){
                tmpEnt.estado__c = AyesaSyncCore.eClosed;
                lEnt2Update.add(tmpEnt);
            } else if (tmpEnt.NumeroSubentregables__c == tmpEnt.Subentregables_Liberados__c ){
                tmpEnt.estado__c = AyesaSyncCore.eFree;
                lEnt2Update.add(tmpEnt);
            } else if ( tmpEnt.NumeroSubentregables__c != tmpEnt.Subentregables_Liberados__c  &&  tmpEnt.AvanceContractual__c < 1){
                tmpEnt.estado__c = AyesaSyncCore.sOpen;
                lEnt2Update.add(tmpEnt);
            }
        }
        
        update lEnt2Update;
    }*/
    
    
}
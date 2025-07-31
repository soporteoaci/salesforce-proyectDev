public class GC_Avances_Contrato_Controller {

    //Listado informacion de avances / KPIs
    public class AvancesInfo {
       
        public string result; 
        public List<Avance> avance;
        
    }
    //Resultados informacion de avances / KPIs
    public class Avance {
       
        public string entidad ;
        public string seccion;
        public string info;
        
    }
    
    private static string sOpen = 'Pendiente', sClosed = 'Aprobado';
    //private static string ePending = 'Pendiente', eDev ='En desarrollo', eFree = 'Liberado', eClosed = 'Firmado';
    
    @AuraEnabled
    public static string getInfoAvances(string contractId){
        string result='';
        List<Contrato__c> myContract= [Select id, name, IC_moneda_contrato__c from Contrato__c where id=:contractId];
        Decimal importContract=0;
        List<Termino_de_Referencia__c> myCurrentTDRList = [SELECT id, name from Termino_de_Referencia__c where Contrato__c=:contractId]; //lista de actuales TDR's de mi contrato  
        List<Termino_de_Referencia__c> myCurrentAprovedTDRList = [SELECT id, name, Cerrado__c from Termino_de_Referencia__c where Contrato__c=:contractId and Cerrado__c=true]; //lista de actuales TDR's APROBADOS de mi contrato  
        List<Subentregable__c> myCurrentEntregableList = [SELECT id, name from Subentregable__c where Contrato__c=:contractId]; //lista de actuales Entregables de mi contrato
        List<Subentregable__c> myCurrentSignedList = [SELECT id, name from Subentregable__c where Contrato__c=:contractId and Cerrado__c=true]; //lista de actuales Entregables FIRMADOS de mi contrato

        Decimal avanceTDR=0;
        Decimal avanceENT=0;
        
        //Para calculo de avance Técnico
        List<Subentregable__c> myRelatedEntregableHitoList = [SELECT id, name,Avance__c, AvancePonderado__c, Peso__c, Hito__r.id from Subentregable__c where Contrato__c=:contractId and Hito__c!=null];
        List<Hito__c> myCurrentHitoList = [SELECT id, name, Importe_contractual__c,  Contrato__r.IC_moneda_contrato__c  from Hito__c where Contrato__c=:contractId];
        
        Map<String,Subentregable__c> myMapEntregablesconHito = new Map<String,Subentregable__c>();
        Map<String,Hito__c> myMapHitos = new Map<String,Hito__c>();
        
        AvancesInfo myAvancesList = new AvancesInfo();
        List<Avance> avancesList = new List<Avance>();
        Avance myTDRInfo = new Avance();
        Avance myTDRAprovedInfo = new Avance();
        Avance myTDRAvanceInfo = new Avance();
        Avance myEntInfo = new Avance();
        Avance myEntSignedInfo = new Avance();
        Avance myEntAvanceInfo = new Avance();
        Avance myHitoInfo = new Avance();
        
        myAvancesList.result='OK';
        system.debug('CONTEO - Tamaño lista TDRs: '+ myCurrentTDRList.size());
        system.debug('CONTEO - Tamaño lista TDRS aprobados: '+myCurrentAprovedTDRList.size() );
        system.debug('CONTEO - Tamaño lista Entregables: '+myCurrentEntregableList.size() );
        system.debug('CONTEO - Tamaño lista Entregables Firmados: '+myCurrentSignedList.size() );
        //system.debug('CONTEO - Tamaño lista Hitos: '+myCurrentHitoList.size() );
        //system.debug('CONTEO - Tamaño lista Relaciones: '+ (myCurrentRelacionesList.size() + myRelatedEntregableHitoList.size()) );
        
        
        if(myCurrentTDRList.size() >= 0){
           
            myTDRInfo.entidad='TDR' ;
            myTDRInfo.seccion='Total de TDRs';
            myTDRInfo.info= string.ValueOf(myCurrentTDRList.size());
                     
        }
        
        if(myCurrentAprovedTDRList.size() >= 0){
           
            myTDRAprovedInfo.entidad='TDR' ;
            myTDRAprovedInfo.seccion='Total de TDRs aprobados';
            myTDRAprovedInfo.info= string.ValueOf(myCurrentAprovedTDRList.size());
            
            avanceTDR= ((Decimal.ValueOf(myCurrentAprovedTDRList.size())/Decimal.ValueOf(myCurrentTDRList.size())) *100 ).setScale(2);
             system.debug('Avance TDR: '+avanceTDR);
            
            myTDRAvanceInfo.entidad='TDR_AVANCE' ;
            myTDRAvanceInfo.seccion='AVANCE';
            myTDRAvanceInfo.info= string.ValueOf(avanceTDR);
        }
        
        
        if(myCurrentEntregableList.size() >= 0){
            myEntInfo.entidad='ENT' ;
            myEntInfo.seccion='Total de Entregables';
            myEntInfo.info= string.ValueOf(myCurrentEntregableList.size());
        }
        
        if(myCurrentSignedList.size() >= 0){
            myEntSignedInfo.entidad='ENT' ;
            myEntSignedInfo.seccion='Total de Entregables firmados';
            myEntSignedInfo.info= string.ValueOf(myCurrentSignedList.size());
            
            avanceENT= ((Decimal.ValueOf(myCurrentSignedList.size())/Decimal.ValueOf(myCurrentEntregableList.size()))*100).setScale(2);
            
           
            system.debug('Avance ENTREGABLES double: '+avanceENT);
            
            myEntAvanceInfo.entidad='ENT_AVANCE' ;
            myEntAvanceInfo.seccion='AVANCE';
            myEntAvanceInfo.info= string.ValueOf(avanceENT);
        }
        
        if(myRelatedEntregableHitoList.size() > 0){ //Tiene Entregables relacionados con algún Hito
            
            //Relleno el mapa de entregables
            /*for(Subentregable__c ent : myRelatedEntregableHitoList){
                myMapEntregablesconHito.put(ent.Id, ent);
            }*/
            
            if(myContract.size() > 0){
                importContract=myContract[0].IC_moneda_contrato__c;
            }
            
            //Relleno el mapa de hitos
            for(Hito__c hito : myCurrentHitoList){
                myMapHitos.put(hito.Id, hito);
            }
            
            //Recorro cada Hito 
            Decimal sumTotal=0;
            Decimal porcentajeFinal=0;
            Decimal sumAux=0;
            for (String keyHito : myMapHitos.keySet()){
                 //sumAux=0;
                 for(Subentregable__c ent : myRelatedEntregableHitoList){                    
                     if(keyHito==ent.Hito__r.id){
                         sumAux=sumAux + (ent.AvancePonderado__c)*(myMapHitos.get(keyHito)).Importe_contractual__c;
                     }
                }
            }
            porcentajeFinal= (sumAux / importContract).setScale(2);
            
            myHitoInfo.entidad='HITO' ;
            myHitoInfo.seccion='Avance técnico ';
            myHitoInfo.info= string.Valueof(porcentajeFinal);
            
        }else if (myRelatedEntregableHitoList.size() == 0) {
            myHitoInfo.entidad='HITO' ;
            myHitoInfo.seccion='Avance técnico ';
            myHitoInfo.info= '0';
        }
        
        
        avancesList.add(myTDRInfo);
        avancesList.add(myTDRAprovedInfo);
        avancesList.add(myEntInfo);
        avancesList.add(myEntSignedInfo);
        avancesList.add(myHitoInfo);
        avancesList.add(myEntAvanceInfo);
        avancesList.add(myTDRAvanceInfo);
        
        
        myAvancesList.avance=avancesList;
        
        result= JSON.serialize(myAvancesList);
        
        return result;
    }
    
     
    //Método que se utiliza en los botones ACTUALIZAR TDR's
    @AuraEnabled
    public static string updateTdrStatusProcess(string contractId){
        // Se sincronizan los estados de los TDR's asociados a los subentregables
        string result ='KO';
        List<Termino_de_Referencia__c> tdrs = [SELECT id from Termino_de_Referencia__c where Contrato__c = :contractId];
        List<Id> tdrIds = new List<ID>();
        for(Termino_de_Referencia__c tdr : tdrs){
            tdrIds.add(tdr.Id);
        }
        
        Termino_de_Referencia__c tmpTdr;
        List<Termino_de_Referencia__c> finalTdrs = new List<Termino_de_Referencia__c>();
        List<AggregateResult> openTdrs = [select terminoreferencia__c, count(subentregable__r.Id) open from TDRSubentregable__c where subentregable__r.cerrado__c = false and terminoreferencia__c in :tdrIds group by terminoreferencia__c];   
        for(AggregateResult tdr : openTdrs){
            tmpTdr = new Termino_de_Referencia__c();
            tmpTdr.Id = (Id)tdr.get('TerminoReferencia__c');
            tmpTdr.estado__c = sOpen;
            tdrIds.remove(tdrIds.indexOf(tmpTdr.Id));       
            finalTdrs.add(tmpTdr);
        }
        
        List<Termino_de_Referencia__c> closedTdrs = [select id from Termino_de_Referencia__c where id in (select terminoreferencia__c from TDRSubentregable__c where terminoreferencia__c in:tdrIds)];       
        for(Termino_de_Referencia__c tdr : closedTdrs){   
            tdr.estado__c =sClosed;
            finalTdrs.add(tdr);
        }
        
        List<Termino_de_Referencia__c> uncoveredTdrs = [select id from Termino_de_Referencia__c where id in :tdrids and id not in (select terminoreferencia__c from TDRSubentregable__c where terminoreferencia__c in:tdrIds)];       
        for(Termino_de_Referencia__c tdr : uncoveredTdrs){   
            tdr.estado__c = sOpen;
            finalTdrs.add(tdr);
        }
        
        Map<Id, Termino_de_Referencia__c> mapTdr = new Map<Id, Termino_de_Referencia__c>();
        mapTdr.putAll(finalTdrs);
        
        
        try{
            update  mapTdr.values();
            result='OK';
            System.debug('CALCULO TDRS - Tamaño lista actualizada : ' + mapTdr.size());
            
        }catch(System.DmlException ex){
            result='KO';            
            System.debug('Error: ' + ex.getMessage());         
            System.debug('Mensaje: ' + ex.getStackTraceString());
            System.debug(ex.getCause());
            
        }catch(System.SecurityException es){
            result='KO';
            System.debug('Error: ' + es.getMessage());
            system.debug('Error: ' + es.getTypeName());
            system.debug('Error: ' + es.getCause());
            
        }catch(Exception e){
            result='KO';
            System.debug('Error: ' + e.getMessage());  
        }
        return result;
        
        
    }
}
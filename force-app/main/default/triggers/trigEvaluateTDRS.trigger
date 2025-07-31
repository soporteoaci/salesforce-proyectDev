trigger trigEvaluateTDRS on Subentregable__c (after update, after insert, before delete) {
    
    
    
    List<Id> lSubs = new List<Id>();
    List<Id> lTDRS = new List<Id>();
    
    Set<Id> idsSet;    
    
    if(trigger.isDelete){
        idsSet =trigger.oldMap.keySet();
        lSubs.addAll(idsSet);
        List<TDRSubentregable__c> deleteJunc = [SELECT id from  TDRSubentregable__c where subentregable__c in :lsubs];
    	delete deleteJunc;
    } else {
        idsSet =trigger.newMap.keySet();
        
        lSubs.addAll(idsSet);
        
        List<TDRSubentregable__c> listTDR = [select terminoreferencia__c from  TDRSubentregable__c where subentregable__c in:lSubs];
        for(TDRSubentregable__c tdr: listTDR){
            lTDRS.add(tdr.terminoreferencia__c);
        }
        AyesaSyncCore.processTDRS(lTDRS);
    }
}
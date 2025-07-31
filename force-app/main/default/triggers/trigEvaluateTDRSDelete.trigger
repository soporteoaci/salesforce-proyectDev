trigger trigEvaluateTDRSDelete on TDRSubentregable__c (after delete) {
    List<Id> lTDRS = new List<Id>();
    
    for(ID junct: trigger.oldMap.keySet()){
        lTDRS.add(trigger.oldMap.get(junct).terminoreferencia__c);
    }
    AyesaSyncCore.processTDRS(lTDRS);
}
trigger IbermaticaEventsTrigger on IbermaticaEvents__e (after insert) {
    System.debug('Trigger IbermaticaEvents__e');
    
    List <Id> lRecordsIds;
    String recordId;
    String interfaz;
    
    for (IbermaticaEvents__e event : Trigger.New) {
        System.debug('Interfaz: ' + event.Interfaz__c);
        System.debug('Id: ' + event.Id__c);
        recordId = event.Id__c;
        interfaz = event.Interfaz__c;        
        lRecordsIds = new List<Id>();
        lRecordsIds.add(recordId);
        
        switch on interfaz {
            when 'AltaClienteSAP' {     
                CRM_IB_AltaClienteSAP.altaClienteSAP(lRecordsIds);
                System.debug('altaClienteSAP');
            }
            when 'AltaClienteSUPER' {
                CRM_IB_AltaClienteSUPER.altaClienteSUPER(lRecordsIds);
                System.debug('altaClienteSUPER');
            }
            when 'ModifClienteSUPER' {
               CRM_IB_ModificacionClienteSUPER.modClienteSUPER(lRecordsIds);
                System.debug('modClienteSUPER');
            }
            when 'ModifOportunidadSUPER' {
                CRM_IB_AltaModOppSUPER.altaModOppSUPER(lRecordsIds);
                System.debug('altaModOppSUPER');
            }
            when 'DeleteOportunidadSUPER'{
                CRM_IB_BorradoOppSUPER.borradoOppSUPER(lRecordsIds);
                System.debug('BorradoOppSUPER');
            }
        } 
    }
}
trigger dividir_url on ArchivoExterno__c (before insert, before update) {
    for(ArchivoExterno__c  a:Trigger.new){
        if(a.URL_LONG__c!=null){
            a.url1__c=a.URL_LONG__c.left(255);
            a.url2__c=a.URL_LONG__c.mid(255,510);
            a.url3__c=a.URL_LONG__c.mid(510,765);
        }
     }
}
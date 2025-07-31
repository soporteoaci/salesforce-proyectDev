@isTest
public class dividir_urlTest {
    
        @isTest static void TestBeforeInsertOrUpdateAction() {
            Id userId = UserInfo.getUserId();
            ArchivoExterno__c  archivoext = new ArchivoExterno__c(URL__c='https://www.google.es/',URL_LONG__c='https://www.google.es/',Nombre_del_Fichero__c='TestUrlLargo', OwnerId=userId);
       		insert archivoext;
            
        }
}
@isTest
public class SSC_ActionsControllerTEST {
    
   @isTest static void getActionsTest() {
        
        date myDate = date.today();
        Id userId = UserInfo.getUserId();
        Country_Relatioship__c countryRel = new Country_Relatioship__c(Name='Colombia', Country_Code__c ='CO', Country_Manager__c = userId);
        insert countryRel;
        
        SSC__c ssc = new SSC__c(Country__c = countryRel.Id, Subject__c = 'Subject SSC Task 1', Status__c = 'Abierto');
        insert ssc;
        
        
        Action__c acc1= new Action__c(Name='Test One', EndDate__c=myDate, Status__c='Abierta', Description__c='test text', Responsable__c = userId,Task_LK__c = ssc.Id);
        Action__c acc2= new Action__c(Name='Test Two', EndDate__c=myDate, Status__c='Abierta', Description__c='test text', Responsable__c = userId,Task_LK__c = ssc.Id);
        Action__c acc3= new Action__c(Name='Test Three', EndDate__c=myDate, Status__c='Abierta', Description__c='test text', Responsable__c = userId,Task_LK__c = ssc.Id);
        Action__c acc4= new Action__c(Name='Test Four', EndDate__c=myDate, Status__c='Abierta', Description__c='test text', Responsable__c = userId,Task_LK__c = ssc.Id);
        
        
        Test.startTest();
        
        insert acc1;
        acc1.Status__c = 'Cerrada';
        Database.SaveResult resultUpdate1 = Database.update(acc1, false);
        
        insert acc2;
        acc2.Status__c = 'Cerrada';
        Database.SaveResult resultUpdate2 = Database.update(acc2, false);
        
        insert acc3;
        insert acc4;
        
        List<Action__c> testList = SSC_ActionsController.getActions('Cerrada');
        System.assertEquals(testList[0].Status__c, 'Cerrada');  
        
        testList = SSC_ActionsController.getActions('Abierta');
        System.assertEquals(testList[0].Status__c, 'Abierta');
        
        testList = SSC_ActionsController.getActions('');
        System.assertEquals(testList.size(), 2);
        
        Test.stopTest();

    }
}
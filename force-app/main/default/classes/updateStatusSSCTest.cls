@isTest
private class updateStatusSSCTest {
    
    @isTest static void TestAfterInsertOrUpdateAction() {
        // Test data setup
        // Create an action with an SCC Task, and then try to insert and update it
        Id userId = UserInfo.getUserId();
        Country_Relatioship__c countryRel = new Country_Relatioship__c(Name='Colombia', Country_Code__c ='CO', Country_Manager__c = userId);
        insert countryRel;
        
        SSC__c ssc = new SSC__c(Country__c = countryRel.Id, Subject__c = 'Subject SSC Task 1', Status__c = 'Abierto');
        insert ssc;

        Action__c acc1 = new Action__c(Name = 'Action 1', Description__c = 'Description 1', EndDate__c = Date.today(), Status__c = 'Abierta', Responsable__c = userId,Task_LK__c = ssc.Id);
        Action__c acc2 = new Action__c(Name = 'Action 2', Description__c = 'Description 2', EndDate__c = Date.today()+30, Status__c = 'Abierta', Responsable__c = userId,Task_LK__c = ssc.Id);
        Action__c acc3 = new Action__c(Name = 'Action 3', Description__c = 'Description 3', EndDate__c = Date.today()+60, Status__c = 'Abierta', Responsable__c = userId,Task_LK__c = ssc.Id);

        // Perform test
        Test.startTest();
        //insert acc1
        insert acc1;
        
        //update acc1
        acc1.Status__c = 'En proceso';
        Database.SaveResult resultUpdate1 = Database.update(acc1, false);
        
        //insert and delete acc2
        insert acc2;
        Database.DeleteResult result1 = Database.delete(acc2.Id, false);
        
        //update acc1
        acc1.Status__c = 'Cerrada';
        Database.SaveResult resultUpdate2 = Database.update(acc1, false);
        
        //insert acc3
        insert acc3;
        
        //delete acc3
        Database.DeleteResult result2 = Database.delete(acc3.Id, false);
        
        //update acc1
        acc1.Status__c = 'Validada';
        Database.SaveResult resultUpdate3 = Database.update(acc1, false);
        
        Test.stopTest();
        
        SSC__c resultSSC = [select Status__c from SSC__c where Id = :ssc.Id];
        System.assertEquals('Validado', resultSSC.Status__c);
        
    }
    
}
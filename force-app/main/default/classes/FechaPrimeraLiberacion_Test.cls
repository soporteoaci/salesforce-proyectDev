@isTest
private class FechaPrimeraLiberacion_Test {
    
    @isTest static void Entregables(){
        
        Test.startTest();
        Proyecto__c Proyecto= new Proyecto__c(NAme='Proyecto Prueba', Codigo__c='P99/0000');
        insert Proyecto;
        Subentregable__c Entregable1= new Subentregable__c(Name='Entregable1', Proyecto__c=Proyecto.Id, CodigoSubentregable__c='Prueba1');
        insert Entregable1;
        
        Subentregable__c Entregable2= new Subentregable__c(Name='Entregable2', Proyecto__c=Proyecto.Id,CodigoSubentregable__c='Prueba2');
        insert Entregable2;
        
        Entregable1.Fecha_Real_de_Liberacion__c=System.today();
        
        update Entregable1;
        Test.stopTest();
        
        
    }
    
    
    
}
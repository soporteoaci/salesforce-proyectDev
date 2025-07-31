@isTest
public with sharing class GC_Autom_Historicos_Proyecto_Test {
    
    @TestSetup
    static void makeData(){
        Test.startTest();
        List <Proyecto__c> proyectos = new List <Proyecto__c>();
        List <Historico_Estado_proyecto__c> historicos = new List <Historico_estado_proyecto__c>();
        for(Integer i=100;i<=250;i++){
            Proyecto__c p= new Proyecto__c();
            p.Name='Project Test';
            p.Codigo__c ='P99/9'+i;
            proyectos.add(p); 
            
            Historico_estado_proyecto__c myNewHistorico = new Historico_estado_proyecto__c();
            
            myNewHistorico.Fecha_Insercion__c=Datetime.now();
            myNewHistorico.Name= p.Codigo__c+' - '+string.valueof(date.today());
            myNewHistorico.Fecha_Datos_Economicos__c=Date.today().addMonths(-3);
             myNewHistorico.Proyecto__c=p.Id;
            historicos.add(myNewHistorico);
        }
        insert proyectos;
        insert historicos;
        
        Test.stopTest();
    }
    
    @isTest
    public static void test1(){
        
        Test.startTest();
        
        GC_Automatizacion_Historicos_Proyecto sch = new GC_Automatizacion_Historicos_Proyecto();
        ID batchprocessid = Database.executeBatch(sch);
        
        Test.stopTest();
    }
    
    
}
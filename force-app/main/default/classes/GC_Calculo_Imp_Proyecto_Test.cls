@isTest
public class GC_Calculo_Imp_Proyecto_Test {
    @TestSetup
    static void makeData(){
        List <Proyecto__c> proyectos = new List <Proyecto__c>();
        List <Contrato__c> contratos = new List <Contrato__c>();
        
        for(Integer i=100;i<=200;i++){
            Proyecto__c p= new Proyecto__c();
            p.Name='Project Test';
            p.Codigo__c ='P99/9'+i;
            proyectos.add(p); 
            Contrato__c c = new Contrato__c();
            c.Name = 'Test';
            c.Codigo_SAP__c='P99/9'+i+'/1';
            c.IC_moneda_contrato__c = 4200;
            c.Sub_area__c = 'A1';
            c.Mercado__c='60029505';
            c.DivisionPicklist__c='V-AERONAUTICS';
            c.Estado__c = 'ENMA';
            c.IC_real__c= 10000;
            c.Proyecto__c=p.id;
            contratos.add(c);
        }
        
        insert proyectos;
        insert  contratos;
        
    }
    @isTest
    static void Calcularimporte(){
        Test.startTest();
        GC_Calculo_Imp_Pro_Controller.Calculoimporte ();
        Test.stopTest();
    }
    
    @isTest
    static void Calcularimporte_schedule(){
        Test.startTest();
        
        GC_Calculo_Imp_Proyecto_Schedule sch = new GC_Calculo_Imp_Proyecto_Schedule();
        sch.execute(null);
        
        Test.stopTest();
    }
    
    
}
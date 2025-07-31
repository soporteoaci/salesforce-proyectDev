@isTest
public with sharing class CRM_Automatizacion_Historicos_Test {

  @TestSetup
  static void makeData(){
    Contrato__c c = new Contrato__c();
        c.Name = 'Test';
        c.IC_moneda_contrato__c = 4200;
        c.Sub_area__c = 'A1';
      	c.Mercado__c='60029505';
      	c.DivisionPicklist__c='V-AERONAUTICS';
        c.Estado__c = 'ENMA';
        insert c;
  }

  @isTest
  public static void test1(){

    Test.startTest();

    CRM_Automatizacion_Historicos_Schedule sch = new CRM_Automatizacion_Historicos_Schedule();
    sch.execute(null);

    Test.stopTest();
  }

}
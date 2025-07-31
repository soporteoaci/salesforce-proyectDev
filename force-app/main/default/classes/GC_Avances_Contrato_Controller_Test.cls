@isTest
public class GC_Avances_Contrato_Controller_Test {
    @isTest 
    public static void getInfoAvances(){
        Contrato__c c = new Contrato__c();
        c.Name = 'Test';
        c.IC_moneda_contrato__c = 4200;
        c.Sub_area__c = 'A1';
        c.Estado__c = 'ENMA';
        c.DivisionPicklist__c = 'V-AERONAUTICS';
        c.Mercado__c = '60029505';
        insert c;
        
        Proyecto__c p = new Proyecto__c();
        p.Name = 'Test';
        p.Codigo__c = 'P04/20';
        p.Documentalista__c = UserInfo.getUserId();
        insert p;
        
        Termino_de_Referencia__c tr = new Termino_de_Referencia__c();
        tr.Name = 'Test';
        tr.Nombre__c = 'Test';
        tr.Contrato__c = c.ID;
        tr.Estado__c = 'Aprobado';
        tr.Proyecto__c = p.Id;
        insert tr;
        
        Hito__c h = new Hito__c();
        h.Name = 'Test';
        h.Contrato__c = c.ID;
        h.Importe_contractual__c = 4200;
        h.Fecha_Fin__c = Date.today();
        h.Peso_Facturacion__c = 4.2;
        h.Proyecto__c = p.ID;
        insert h;
        
        Entregable__c ge = new Entregable__c();
        ge.Entregable__c = 'Test';
        ge.Proyecto__c = p.ID;
        ge.Tipo__c = 'Otros';
        ge.Fase__c = 'Preparación';
        ge.Hito__c = h.ID;
        insert ge;
        
        Subentregable__c se = new Subentregable__c();
        se.Name = 'Test';
        se.Contrato__c = c.ID;
        se.Estado__c = 'Finalizado';
        se.Avance__c = 100;
        se.Peso__c = 1;
        se.Hito__c = h.ID;
        se.Tipo__c = 'Otros';
        se.CodigoSubentregable__c = '4200';
        se.Proyecto__c = p.ID;
        //se.Entregable__c = ge.ID;
        insert se;
        
        TDRSubentregable__c tdrs = new TDRSubentregable__c();
        tdrs.Subentregable__c = se.ID;
        tdrs.TerminoReferencia__c = tr.ID;
        insert tdrs;
        
        GC_Avances_Contrato_Controller.getInfoAvances(c.ID);
        GC_Avances_Contrato_Controller.updateTdrStatusProcess(c.ID);
    }
}
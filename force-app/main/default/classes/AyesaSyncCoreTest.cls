@isTest (SeeAllData = true)
public class AyesaSyncCoreTest {

    @isTest
    public static void testSync(){
        
        Proyecto__c proyecto = new Proyecto__c(Name = 'TEST PROJECT', Pais__c = 'EC', Codigo__c = 'TEST');

        //Nuevo creacion de contrato para enlazarlo con el TDR's (04/08/2020) para eliminar el campo Proyecto__c de los TDR's        
        Contrato__c contratoRelleno = new Contrato__c();
        contratoRelleno.Asistencia_juridica__c=true;
        contratoRelleno.Causa_resolucion__c='CRES1';
        contratoRelleno.Causa_retraso__c='CR1';
        contratoRelleno.Causa_suspension__c='CSUS1';
        contratoRelleno.CeBe__c='A2D01P';
        contratoRelleno.Codigo_SAP__c='codigo sap';
        contratoRelleno.Comentarios__c='comentarios';
        contratoRelleno.Costes_a_reclamar_por_resolucion__c= 123123;
        contratoRelleno.Costes_a_reclamar_por_suspension__c= 123123;
        contratoRelleno.Costes_totales_resolucion__c= 123123;
        contratoRelleno.Costes_totales_suspension__c= 123123;
        contratoRelleno.Derecho_a_reclamacion_por_suspension__c= true;
        contratoRelleno.Derecho_a_reclamacion_por_resolucion__c= false;
        contratoRelleno.Estado__c= 'ENMA';
        contratoRelleno.Estimacion_coste_extra_por_retraso__c= 123123;
        contratoRelleno.Estimacion_costes_extra__c=123123;
        contratoRelleno.Estimacion_meses_de_retraso__c=2;
        contratoRelleno.Moneda__c='PAB';
        contratoRelleno.Name='Contrato 1';
        contratoRelleno.Negociacion_modificacion_contractual__c=true;
        contratoRelleno.Pais__c='MX';
        contratoRelleno.Prevision_costes_extra__c=true;
        contratoRelleno.Reqs_Contractuales_sobre_Presencialidad__c='R10';
        contratoRelleno.Situacion_Actual_Contrato__c='S10';
        contratoRelleno.Sub_area__c='A2';
        contratoRelleno.Costes_a_reclamar_por_resolucion_local__c=123123;
        contratoRelleno.Estimacion_costes_extra_local__c=123123;
        contratoRelleno.Costes_totales_resolucion_local__c=123123;
        contratoRelleno.Costes_a_reclamar_por_suspension_local__c=123123;
        contratoRelleno.Costes_totales_suspension_local__c=123123;
        contratoRelleno.Estimacion_coste_extra_por_retraso_local__c=123123;
        contratoRelleno.Codigo_AJI__c ='123123';
         contratoRelleno.Costes_a_reclamar_por_retraso_local__c =123123;
        contratoRelleno.Costes_aceptados_por_retraso_local__c =123123;
        contratoRelleno.Negociacion_modificacion_finalizada__c =true;
        contratoRelleno.Negociacion_aceptada__c =true;
        contratoRelleno.Documentando_incidencias__c=false;
        contratoRelleno.Prevision_situacion_contrato__c='S10';
        contratoRelleno.DivisionPicklist__c='V-AERONAUTICS';
        contratoRelleno.Mercado__c='60029505';
        Proyecto__c p= new Proyecto__c();
        p.Name='Project Test';
        p.Codigo__c ='0001';
        insert p;
        contratoRelleno.Proyecto__c = p.id;
        
        insert proyecto;
        insert contratoRelleno;
        
        //Comentado (04/08/2020) para eliminar el campo Proyecto__c de los TDR's
        //Termino_de_Referencia__c tdr = new Termino_de_Referencia__c(Name = 'test', Nombre__c ='nombre', Proyecto__c = proyecto.Id, Descripcion__c = 'Test');
        Termino_de_Referencia__c tdr = new Termino_de_Referencia__c(Proyecto__c = p.id, Name = 'test', Nombre__c ='nombre', Contrato__c = contratoRelleno.Id, Descripcion__c = 'Test');
        
        insert tdr;    
      
        /*
        Entregable__c ent = new Entregable__c();
        ent.name= 'Prueba grupo';
        ent.Entregable__c='8888';
        ent.Fase__c='Diseño';
        ent.Tipo__c='Arquitectura';
        ent.Hito__c='a0B9E000004WMIQUA4';
        ent.Proyecto__c='a029E00000NZTVKQA5';
        
        insert ent;*/

        
       // Subentregable__c sub1 = new Subentregable__c(Name ='sub1', CodigoSubentregable__c ='sub1', entregable__c = ent.Id, tipo__c = 'Pruebas', subtipo__c = 'Otros', Peso__c = 1);
       // Subentregable__c sub2 = new Subentregable__c(Name ='sub2', CodigoSubentregable__c ='sub2', entregable__c = ent.Id, tipo__c = 'Pruebas', subtipo__c = 'Otros',Peso__c = 1);
          Subentregable__c sub1 = new Subentregable__c(Proyecto__c = p.id, Name ='sub1', CodigoSubentregable__c ='sub1', Contrato__c = contratoRelleno.Id, tipo__c = 'Pruebas', subtipo__c = 'Otros', Peso__c = 1);
          Subentregable__c sub2 = new Subentregable__c(Proyecto__c = p.id,Name ='sub2', CodigoSubentregable__c ='sub2', Contrato__c = contratoRelleno.Id, tipo__c = 'Pruebas', subtipo__c = 'Otros',Peso__c = 1); 
       
        insert sub1;
        insert sub2;
        
        TDRSubentregable__c tsub1 = new TDRSubentregable__c (TerminoReferencia__c = tdr.ID, Subentregable__c = sub1.Id);
        TDRSubentregable__c tsub2 = new TDRSubentregable__c (TerminoReferencia__c = tdr.ID, Subentregable__c = sub2.Id);
        insert tsub1;
        insert tsub2;
        
        AyesaSyncCore.processPoject(proyecto.Id);
        
        sub1.estado__c = 'Firmado';
        sub1.Fecha_Real_de_Firma__c = Date.today();
        sub1.Fecha_Real_de_Liberacion__c = Date.today();
        update sub1;
        tdr = [Select id, estado__c from Termino_de_Referencia__c where id = :tdr.ID];
        System.assert(tdr.estado__c == 'Pendiente');
        
        sub2.estado__c = 'Firmado';
        sub2.Fecha_Real_de_Firma__c = Date.today();
        sub2.Fecha_Real_de_Liberacion__c = Date.today();
        update sub2;
        tdr = [Select id, estado__c from Termino_de_Referencia__c where id = :tdr.ID];
        System.assert(tdr.estado__c == 'Aprobado');
        
        sub2.estado__c = 'Pendiente';
        update sub2;
        tdr = [Select id, estado__c from Termino_de_Referencia__c where id = :tdr.ID];
        System.assert(tdr.estado__c == 'Pendiente');
        
        delete sub2;
        tdr = [Select id, estado__c from Termino_de_Referencia__c where id = :tdr.ID];
        System.assert(tdr.estado__c == 'Aprobado');
        
        delete sub1;
        tdr = [Select id, estado__c from Termino_de_Referencia__c where id = :tdr.ID];
        System.assert(tdr.estado__c == 'Pendiente');
  
    }
    
    
}
@isTest(SeeAllData=false)
public class CRM_Actualiza_Estado_Contratos_Test {
    
    @testSetup static void cargaDatos() {
        
        insert new Parametros_gestion_contratos__c(Dias_sin_actualizar__c = 1);
        
        
        
        
        
        //        User userPrueba =  new User (FirstName= 'Prueba', LastName='Prueba', email='rafaelcasalvera@gmail.com');
        //      insert userPrueba;
        Datetime myDateTime = Datetime.now();
        myDateTime = myDateTime.addDays(-2);
        
        
        User myuser = new User(
            ProfileId = [Select Id from Profile limit 1].Id,
            LastName = 'last',
            Email = 'rafaelcasalvera@gmail.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //  UserRoleId = r.Id
        );
        insert myuser;
        
        List<Contrato__c> myContratoList = new List<Contrato__c>();  
        
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
        contratoRelleno.OwnerId=myuser.id;
        contratoRelleno.Mercado__c='60029505';
        contratoRelleno.DivisionPicklist__c='V-AERONAUTICS';
        
        
        
        Contrato__c contratoRelleno2 = new Contrato__c();
        contratoRelleno2.Asistencia_juridica__c=true;
        contratoRelleno2.Causa_resolucion__c='CRES1';
        contratoRelleno2.Causa_retraso__c='CR1';
        contratoRelleno2.Causa_suspension__c='CSUS1';
        contratoRelleno2.CeBe__c='A2D01P';
        contratoRelleno2.Codigo_SAP__c='codigo sap';
        contratoRelleno2.Comentarios__c='comentarios';
        contratoRelleno2.Costes_a_reclamar_por_resolucion__c= 123123;
        contratoRelleno2.Costes_a_reclamar_por_suspension__c= 123123;
        contratoRelleno2.Costes_totales_resolucion__c= 123123;
        contratoRelleno2.Costes_totales_suspension__c= 123123;
        contratoRelleno2.Derecho_a_reclamacion_por_suspension__c= true;
        contratoRelleno2.Derecho_a_reclamacion_por_resolucion__c= false;
        contratoRelleno2.Estado__c= 'ENMA';
        contratoRelleno2.Estimacion_coste_extra_por_retraso__c= 123123;
        contratoRelleno2.Estimacion_costes_extra__c=123123;
        contratoRelleno2.Estimacion_meses_de_retraso__c=2;
        contratoRelleno2.Moneda__c='PAB';
        contratoRelleno2.Name='Contrato 2';
        contratoRelleno2.Negociacion_modificacion_contractual__c=true;
        contratoRelleno2.Pais__c='MX';
        contratoRelleno2.Prevision_costes_extra__c=true;
        contratoRelleno2.Reqs_Contractuales_sobre_Presencialidad__c='R10';
        contratoRelleno2.Situacion_Actual_Contrato__c='S10';
        contratoRelleno2.Sub_area__c='A2';
        contratoRelleno2.Costes_a_reclamar_por_resolucion_local__c=123123;
        contratoRelleno2.Estimacion_costes_extra_local__c=123123;
        contratoRelleno2.Costes_totales_resolucion_local__c=123123;
        contratoRelleno2.Costes_a_reclamar_por_suspension_local__c=123123;
        contratoRelleno2.Costes_totales_suspension_local__c=123123;
        contratoRelleno2.Estimacion_coste_extra_por_retraso_local__c=123123;
        contratoRelleno2.Codigo_AJI__c ='123123';
        contratoRelleno2.Costes_a_reclamar_por_retraso_local__c =123123;
        contratoRelleno2.Costes_aceptados_por_retraso_local__c =123123;
        contratoRelleno2.Negociacion_modificacion_finalizada__c =true;
        contratoRelleno2.Negociacion_aceptada__c =true;
        contratoRelleno2.Documentando_incidencias__c=false;
        contratoRelleno2.CreatedDate = datetime.now();
        contratoRelleno2.Prevision_situacion_contrato__c='S10';
        contratoRelleno2.OwnerId=myuser.id;
        contratoRelleno2.Mercado__c='60029505';
        contratoRelleno2.DivisionPicklist__c='V-AERONAUTICS';
        
        
        Contrato__c contratoRelleno4 = new Contrato__c();
        //contratoRelleno4.Asistencia_juridica__c=true;
        //contratoRelleno4.Causa_resolucion__c='CRES1';
        //contratoRelleno4.Causa_retraso__c='CR1';
        //contratoRelleno4.Causa_suspension__c='CSUS1';
        contratoRelleno4.CeBe__c='A2D01P';
        contratoRelleno4.Codigo_SAP__c='codigo sap';
        contratoRelleno4.Comentarios__c='comentarios';
        //contratoRelleno4.Costes_a_reclamar_por_resolucion__c= 123123;
        //contratoRelleno4.Costes_a_reclamar_por_suspension__c= 123123;
        //contratoRelleno4.Costes_totales_resolucion__c= 123123;
        //contratoRelleno4.Costes_totales_suspension__c= 123123;
        contratoRelleno4.Derecho_a_reclamacion_por_suspension__c= true;
        contratoRelleno4.Derecho_a_reclamacion_por_resolucion__c= false;
        contratoRelleno4.Estado__c= 'ENMA';
        // contratoRelleno4.Estimacion_coste_extra_por_retraso__c= 123123;
        //contratoRelleno4.Estimacion_costes_extra__c=123123;
        //contratoRelleno4.Estimacion_meses_de_retraso__c=2;
        // contratoRelleno4.Moneda__c='PAB';
        contratoRelleno4.Name='Contrato 4';
        contratoRelleno4.Negociacion_modificacion_contractual__c=true;
        // contratoRelleno4.Pais__c='MX';
        contratoRelleno4.Prevision_costes_extra__c=true;
        // contratoRelleno4.Reqs_Contractuales_sobre_Presencialidad__c='R10';
        // contratoRelleno4.Situacion_Actual_Contrato__c='S10';
        contratoRelleno4.Sub_area__c='A2';
        // contratoRelleno4.Costes_a_reclamar_por_resolucion_local__c=123123;
        //contratoRelleno4.Estimacion_costes_extra_local__c=123123;
        //contratoRelleno4.Costes_totales_resolucion_local__c=123123;
        //contratoRelleno4.Costes_a_reclamar_por_suspension_local__c=123123;
        //contratoRelleno4.Costes_totales_suspension_local__c=123123;
        //contratoRelleno4.Estimacion_coste_extra_por_retraso_local__c=123123;
        //contratoRelleno4.Codigo_AJI__c ='123123';
        // contratoRelleno4.Costes_a_reclamar_por_retraso_local__c =123123;
        //contratoRelleno4.Costes_aceptados_por_retraso_local__c =123123;
        contratoRelleno4.Negociacion_modificacion_finalizada__c =true;
        contratoRelleno4.Negociacion_aceptada__c =true;
        contratoRelleno4.Documentando_incidencias__c=false;
        contratoRelleno4.CreatedDate = datetime.now();
        contratoRelleno4.Costes_aceptados_resolucion_local__c=123;
        contratoRelleno4.Costes_aceptados_suspension_local__c=123;
        //contratoRelleno4.Prevision_situacion_contrato__c='S10';
        contratoRelleno4.OwnerId=myuser.id;
        /* UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
insert r;*/
        /* Profile p = new Profile(Name = 'My Profile');
insert p;*/
        contratoRelleno4.Mercado__c='60029505';
        contratoRelleno4.DivisionPicklist__c='V-AERONAUTICS';
        
        
        User u = new User(
            ProfileId = [Select Id from Profile limit 1].Id,
            LastName = 'last',
            Email = 'rafaelcasalvera@gmail.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //  UserRoleId = r.Id
        );
        insert u;
        
        
        Contrato__c contratoRelleno3 = new Contrato__c();
        contratoRelleno3.Asistencia_juridica__c=true;
        contratoRelleno3.Causa_resolucion__c='CRES1';
        contratoRelleno3.Causa_retraso__c='CR1';
        contratoRelleno3.Causa_suspension__c='CSUS1';
        contratoRelleno3.CeBe__c='A2D01P';
        contratoRelleno3.Codigo_SAP__c='codigo sap';
        contratoRelleno3.Comentarios__c='comentarios';
        contratoRelleno3.Costes_a_reclamar_por_resolucion__c= 123123;
        contratoRelleno3.Costes_a_reclamar_por_suspension__c= 123123;
        contratoRelleno3.Costes_totales_resolucion__c= 123123;
        contratoRelleno3.Costes_totales_suspension__c= 123123;
        contratoRelleno3.Derecho_a_reclamacion_por_suspension__c= true;
        contratoRelleno3.Derecho_a_reclamacion_por_resolucion__c= false;
        contratoRelleno3.Estado__c= 'ENMA';
        contratoRelleno3.Estimacion_coste_extra_por_retraso__c= 123123;
        contratoRelleno3.Estimacion_costes_extra__c=123123;
        contratoRelleno3.Estimacion_meses_de_retraso__c=2;
        contratoRelleno3.Moneda__c='PAB';
        contratoRelleno3.Name='Contrato 3';
        contratoRelleno3.Negociacion_modificacion_contractual__c=true;
        contratoRelleno3.Pais__c='MX';
        contratoRelleno3.Prevision_costes_extra__c=true;
        contratoRelleno3.Reqs_Contractuales_sobre_Presencialidad__c='R10';
        contratoRelleno3.Situacion_Actual_Contrato__c='S10';
        contratoRelleno3.Sub_area__c='A2';
        contratoRelleno3.Costes_a_reclamar_por_resolucion_local__c=123123;
        contratoRelleno3.Estimacion_costes_extra_local__c=123123;
        contratoRelleno3.Costes_totales_resolucion_local__c=123123;
        contratoRelleno3.Costes_a_reclamar_por_suspension_local__c=123123;
        contratoRelleno3.Costes_totales_suspension_local__c=123123;
        contratoRelleno3.Estimacion_coste_extra_por_retraso_local__c=123123;
        contratoRelleno3.Codigo_AJI__c ='123123';
        contratoRelleno3.Costes_a_reclamar_por_retraso_local__c =123123;
        contratoRelleno3.Costes_aceptados_por_retraso_local__c =123123;
        contratoRelleno3.Negociacion_modificacion_finalizada__c =true;
        contratoRelleno3.Negociacion_aceptada__c =true;
        contratoRelleno3.Documentando_incidencias__c=false;
        contratoRelleno3.Prevision_situacion_contrato__c='S10';
        contratoRelleno3.LastModifiedDate=Datetime.now().addDays(-4);
        contratoRelleno3.CreatedDate=Datetime.now().addDays(-6);
        contratoRelleno3.OwnerId=u.id;
        contratoRelleno3.Mercado__c='60029505';
        contratoRelleno3.DivisionPicklist__c='V-AERONAUTICS';
        
        myContratoList.add(contratoRelleno);
        myContratoList.add(contratoRelleno2);
        myContratoList.add(contratoRelleno3);
        myContratoList.add(contratoRelleno4);
        
        insert myContratoList;
        
        
        Historico_estado_contrato__c myCurrentHistorico = new Historico_estado_contrato__c();
        myCurrentHistorico.Reqs_Contractuales_sobre_Presencialidad__c= contratoRelleno2.Reqs_Contractuales_sobre_Presencialidad__c;
        myCurrentHistorico.Situacion_Actual_Contrato__c= contratoRelleno2.Situacion_Actual_Contrato__c;
        myCurrentHistorico.Causa_resolucion__c= contratoRelleno2.Causa_resolucion__c;
        myCurrentHistorico.Causa_retraso__c= contratoRelleno2.Causa_retraso__c;
        myCurrentHistorico.Causa_suspension__c= contratoRelleno2.Causa_suspension__c;
        myCurrentHistorico.CeBe__c= contratoRelleno2.CeBe__c;
        myCurrentHistorico.Comentarios__c= contratoRelleno2.Comentarios__c;
        myCurrentHistorico.Costes_a_reclamar_por_resolucion_local__c= contratoRelleno2.Costes_a_reclamar_por_resolucion_local__c;
        myCurrentHistorico.Costes_a_reclamar_por_suspension_local__c= contratoRelleno2.Costes_a_reclamar_por_suspension_local__c;
        myCurrentHistorico.Costes_aceptados_resolucion_local__c= contratoRelleno2.Costes_aceptados_resolucion_local__c;
        myCurrentHistorico.Costes_aceptados_suspension_local__c= contratoRelleno2.Costes_aceptados_suspension_local__c;
        myCurrentHistorico.Costes_totales_resolucion_local__c= contratoRelleno2.Costes_totales_resolucion_local__c;
        myCurrentHistorico.Costes_totales_suspension_local__c= contratoRelleno2.Costes_totales_suspension_local__c;
        myCurrentHistorico.Derecho_a_reclamacion_por_resolucion__c= contratoRelleno2.Derecho_a_reclamacion_por_resolucion__c;
        myCurrentHistorico.Derecho_a_reclamacion_por_suspension__c= contratoRelleno2.Derecho_a_reclamacion_por_suspension__c;
        myCurrentHistorico.Estado__c= contratoRelleno2.Estado__c;
        myCurrentHistorico.Estimacion_coste_extra_por_retraso_local__c= contratoRelleno2.Estimacion_coste_extra_por_retraso_local__c;
        myCurrentHistorico.Estimacion_costes_extra_local__c= contratoRelleno2.Estimacion_costes_extra_local__c;
        myCurrentHistorico.Estimacion_meses_de_retraso__c= contratoRelleno2.Estimacion_meses_de_retraso__c;
        myCurrentHistorico.Moneda__c= contratoRelleno2.Moneda__c;
        myCurrentHistorico.Negociacion_aceptada__c= contratoRelleno2.Negociacion_aceptada__c;
        myCurrentHistorico.Negociacion_modificacion_contractual__c= contratoRelleno2.Negociacion_modificacion_contractual__c;
        myCurrentHistorico.Negociacion_modificacion_finalizada__c= contratoRelleno2.Negociacion_modificacion_finalizada__c;
        myCurrentHistorico.Pais__c= contratoRelleno2.Pais__c;
        myCurrentHistorico.Prevision_costes_extra__c= contratoRelleno2.Prevision_costes_extra__c;
        myCurrentHistorico.Sub_area__c= contratoRelleno2.Sub_area__c;
        myCurrentHistorico.Costes_aceptados_por_retraso_local__c= contratoRelleno2.Costes_aceptados_por_retraso_local__c;
        myCurrentHistorico.Costes_a_reclamar_por_retraso_local__c= contratoRelleno2.Costes_a_reclamar_por_retraso_local__c;
        myCurrentHistorico.Creacion_automatica__c=false;
        myCurrentHistorico.Contrato__c=contratoRelleno2.id;
        myCurrentHistorico.Prevision_situacion_contrato__c=contratoRelleno2.Prevision_situacion_contrato__c;
        myCurrentHistorico.CreatedDate=datetime.now();
        
        insert myCurrentHistorico;
        
        
    }
    
    
    @isTest static void batchClassTest() {
        
        Test.startTest();
        CRM_Automatizacion_Historicos b = new CRM_Automatizacion_Historicos();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
        
    }
    
    @isTest static void scheduleClassTest() {
        
        Test.startTest();
        system.schedule('CRM Creación Historico Contratos TEST', '0 5 0 * * ?', new CRM_Automatizacion_Historicos_Schedule());
        System.debug('CRM Creación Historico Contratos() programada todos los días a las 00.05 AM');
        Test.stopTest();
        
    }
    
    @isTest static void batchClassTestEMail() {
        
        Test.startTest();
        CRM_Recordatorio_Actualizacion_Contrato b = new CRM_Recordatorio_Actualizacion_Contrato();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
        
    }
    
    @isTest static void scheduleClassTestEmail() {
        
        Test.startTest();
        system.schedule('CRM Recordatorio Actualizacion de contrato', '0 5 0 * * ?', new CRM_Recordatorio_Act_Contrato_Schedule());
        System.debug('CRM Recordatorio Actualizacion de contrato() programada todos los días a las 00.05 AM');
        Test.stopTest();
        
    }
    
    
    
    @isTest static void getInfoContratoTest() {
        
        string result='';
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.getInfoContrato(myContrato.id);
        
        
    }
    
    @isTest static void getInfoContrato4Test() {
        
        string result='';
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 4' limit 1];
        result = CRM_Actualiza_Estado_Contratos.getInfoContrato(myContrato.id);
        
        
    }
    
    
    @isTest static void getMonedaOptionsTest(){
        CRM_Actualiza_Estado_Contratos.getMonedaOptions();
    }
    
    @isTest static void getCausaOptionsTest(){
        CRM_Actualiza_Estado_Contratos.getCausaOptions();
    }
    
    @isTest static void updateInfoContratoTodoRellenoTest() {
        
        string result='';
        string jsonContrato='{"asistenciaJuridica" : true,"causaResolucion" : "causa","causaRetraso" : "CR6","causaSuspension" : "Causa","costesReclamarResolucion" :123123 ,"costesReclamarSuspension" :123123 ,';
        jsonContrato = jsonContrato + '"costesTotalesResolucion" :123123 ,"costesTotalesSuspension" : 123123,"derechoReclamacionSuspension" :true ,';
        jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :123123 ,"estimacionCosteExtraNormalidad" :123123 ,"estimacionMesesRetraso" :2 ,';
        jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : "R10","situacionActualContrato" : "S10","docIncidencias":true ,';
        jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :123123 ,"costesReclamarSuspensionLocal" : 123123,"costesTotalesResolucionLocal" : 123123 ,"previsionSituacionContrato":"S10",';
        jsonContrato = jsonContrato + '"codAji" :"123123" ,"costesReclamarRetraso" : 123123,"costesAceptadosRetraso" : 123123 ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
        jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :123123 ,"estimacionCosteExtraRetrasoLocal" : 123123,"estimacionCosteExtraNormalidadLocal" : 123123 ';
        
        jsonContrato = jsonContrato + '}';
        
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.updateInfoContrato(myContrato.id,jsonContrato);
        
        
    }
    
    @isTest static void updateInfoContratoTodoRelleno2Test() {
        
        string result='';
        /*  string jsonContrato='{"asistenciaJuridica" : true,"causaResolucion" : "causa","causaRetraso" : "CR6","causaSuspension" : "Causa","costesReclamarResolucion" :123123 ,"costesReclamarSuspension" :123123 ,';
jsonContrato = jsonContrato + '"costesTotalesResolucion" :123123 ,"costesTotalesSuspension" : 123123,"derechoReclamacionSuspension" :true ,';
jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :123123 ,"estimacionCosteExtraNormalidad" :123123 ,"estimacionMesesRetraso" :2 ,';
jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : "R10","situacionActualContrato" : "S10","docIncidencias":true ,';
jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :123123 ,"costesReclamarSuspensionLocal" : 123123,"costesTotalesResolucionLocal" : 123123 ,';
jsonContrato = jsonContrato + '"codAji" :"123123" ,"costesReclamarRetraso" : 123123,"costesAceptadosRetraso" : 123123 ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :123123 ,"estimacionCosteExtraRetrasoLocal" : 123123,"estimacionCosteExtraNormalidadLocal" : 123123 ';

jsonContrato = jsonContrato + '}';*/
        
        Contrato__c myContrato = [select id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,LastModifiedDate,Codigo_AJI__c,Asistencia_juridica__c,Causa_resolucion__c,Causa_suspension__c,
                                  Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,OwnerId,Comentarios__c,
                                  Costes_a_reclamar_por_resolucion__c, Costes_a_reclamar_por_suspension__c, Costes_totales_resolucion__c,  Costes_a_reclamar_por_resolucion_local__c,Estimacion_costes_extra_local__c,
                                  Costes_totales_resolucion_local__c, Costes_a_reclamar_por_suspension_local__c, Costes_totales_suspension_local__c,Estimacion_coste_extra_por_retraso_local__c,
                                  Costes_totales_suspension__c, Derecho_a_reclamacion_por_suspension__c, Derecho_a_reclamacion_por_resolucion__c, Estimacion_coste_extra_por_retraso__c,Prevision_situacion_contrato__c,
                                  Estimacion_costes_extra__c, Estimacion_meses_de_retraso__c, Negociacion_modificacion_contractual__c,Negociacion_modificacion_finalizada__c, Prevision_costes_extra__c,
                                  Costes_a_reclamar_por_retraso_local__c, Costes_aceptados_por_retraso_local__c,
                                  Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c  from Contrato__c where name=:'Contrato 2' limit 1];
        result = CRM_Actualiza_Estado_Contratos.manageHistoricoDeContrato(myContrato.id, myContrato);
        
        
    }
    
    @isTest static void updateInfoContratoTodoRelleno3Test() {
        
        string result='';
        /*  string jsonContrato='{"asistenciaJuridica" : true,"causaResolucion" : "causa","causaRetraso" : "CR6","causaSuspension" : "Causa","costesReclamarResolucion" :123123 ,"costesReclamarSuspension" :123123 ,';
jsonContrato = jsonContrato + '"costesTotalesResolucion" :123123 ,"costesTotalesSuspension" : 123123,"derechoReclamacionSuspension" :true ,';
jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :123123 ,"estimacionCosteExtraNormalidad" :123123 ,"estimacionMesesRetraso" :2 ,';
jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : "R10","situacionActualContrato" : "S10","docIncidencias":true ,';
jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :123123 ,"costesReclamarSuspensionLocal" : 123123,"costesTotalesResolucionLocal" : 123123 ,';
jsonContrato = jsonContrato + '"codAji" :"123123" ,"costesReclamarRetraso" : 123123,"costesAceptadosRetraso" : 123123 ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :123123 ,"estimacionCosteExtraRetrasoLocal" : 123123,"estimacionCosteExtraNormalidadLocal" : 123123 ';

jsonContrato = jsonContrato + '}';*/
        
        Contrato__c myContrato = [select id,Sub_area__c, CeBe__c, Codigo_SAP__c, Name, Pais__c, Estado__c,Moneda__c,LastModifiedDate,Codigo_AJI__c,Asistencia_juridica__c,Causa_resolucion__c,Causa_suspension__c,
                                  Documentando_incidencias__c, Causa_retraso__c, Negociacion_aceptada__c,Costes_aceptados_suspension_local__c,Costes_aceptados_resolucion_local__c,OwnerId,Comentarios__c,
                                  Costes_a_reclamar_por_resolucion__c, Costes_a_reclamar_por_suspension__c, Costes_totales_resolucion__c,  Costes_a_reclamar_por_resolucion_local__c,Estimacion_costes_extra_local__c,
                                  Costes_totales_resolucion_local__c, Costes_a_reclamar_por_suspension_local__c, Costes_totales_suspension_local__c,Estimacion_coste_extra_por_retraso_local__c,
                                  Costes_totales_suspension__c, Derecho_a_reclamacion_por_suspension__c, Derecho_a_reclamacion_por_resolucion__c, Estimacion_coste_extra_por_retraso__c,Prevision_situacion_contrato__c,
                                  Estimacion_costes_extra__c, Estimacion_meses_de_retraso__c, Negociacion_modificacion_contractual__c,Negociacion_modificacion_finalizada__c, Prevision_costes_extra__c,
                                  Costes_a_reclamar_por_retraso_local__c, Costes_aceptados_por_retraso_local__c,
                                  Reqs_Contractuales_sobre_Presencialidad__c, Situacion_Actual_Contrato__c  from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.manageHistoricoDeContrato(myContrato.id, myContrato);
        
        
    }
    
    
    
    @isTest static void updateInfoContratoFaltanCampos1Test() {
        
        string result='';
        string jsonContrato='{"asistenciaJuridica" : true,"causaResolucion" : "causa","causaRetraso" : "CR6","causaSuspension" : "Causa","costesReclamarResolucion" :123123 ,"costesReclamarSuspension" :123123 ,';
        jsonContrato = jsonContrato + '"costesTotalesResolucion" :123123 ,"costesTotalesSuspension" : 123123,"derechoReclamacionSuspension" :true ,';
        jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :123123 ,"estimacionCosteExtraNormalidad" :123123 ,"estimacionMesesRetraso" :2 ,';
        jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : "R10","situacionActualContrato" : "S10","docIncidencias":true ,';
        jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :123123 ,"costesReclamarSuspensionLocal" : 123123,"costesTotalesResolucionLocal" : 123123 ,"previsionSituacionContrato":"S10",';
        jsonContrato = jsonContrato + '"codAji" :"123123" ,"costesReclamarRetraso" : 123123,"costesAceptadosRetraso" : 123123 ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
        jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :123123 ,"estimacionCosteExtraRetrasoLocal" : 123123,"estimacionCosteExtraNormalidadLocal" : 123123 ';
        
        jsonContrato = jsonContrato + '}';
        
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.updateInfoContrato(myContrato.id,jsonContrato);
        
        
    }
    
    @isTest static void updateInfoContratoFaltanCampos2Test() {
        
        string result='';
        string jsonContrato='{"asistenciaJuridica" : true,"causaResolucion" :null ,"causaRetraso" : null,"causaSuspension" : null,"costesReclamarResolucion" :null ,"costesReclamarSuspension" :null ,';
        jsonContrato = jsonContrato + '"costesTotalesResolucion" :null ,"costesTotalesSuspension" : null,"derechoReclamacionSuspension" :true ,';
        jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :null ,"estimacionCosteExtraNormalidad" :null ,"estimacionMesesRetraso" :null ,';
        jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : null,"situacionActualContrato" : null,"docIncidencias":true ,';
        jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :null ,"costesReclamarSuspensionLocal" : null,"costesTotalesResolucionLocal" : null ,"previsionSituacionContrato":null,';
        jsonContrato = jsonContrato + '"codAji" :null ,"costesReclamarRetraso" : null,"costesAceptadosRetraso" : null ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
        jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :null ,"estimacionCosteExtraRetrasoLocal" : null,"estimacionCosteExtraNormalidadLocal" : null ';
        
        jsonContrato = jsonContrato + '}';
        
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.updateInfoContrato(myContrato.id,jsonContrato);
        
        
    }
    
    
    @isTest static void updateInfoContratoConFallosTest() {
        
        string result='';
        string jsonContrato='{"asistenciaJuridica" : false,"causaResolucion" : "causa","causaRetraso" : "CR6","causaSuspension" : "Causa","costesReclamarResolucion" :123123 ,"costesReclamarSuspension" :123123 ,';
        jsonContrato = jsonContrato + '"costesTotalesResolucion" :123123 ,"costesTotalesSuspension" : 123123,"derechoReclamacionSuspension" :true ,';
        jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : false,"estimacionCosteExtraRetraso" :123123 ,"estimacionCosteExtraNormalidad" :123123 ,"estimacionMesesRetraso" :2 ,';
        jsonContrato = jsonContrato + '"negociacionModificacionContrato" :true ,"previsionCostesExtra" :true ,"reqsPresencia" : "R10","situacionActualContrato" : "S10","docIncidencias":true ,';
        jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" :123123 ,"costesReclamarSuspensionLocal" : 123123,"costesTotalesResolucionLocal" : 123123 ,"previsionSituacionContrato":null,';
        jsonContrato = jsonContrato + '"codAji" :"123123" ,"costesReclamarRetraso" : 123123,"costesAceptadosRetraso" : 123123 ,"negociacionModificacionFinalizada" : true ,"negociacionAceptada" : true ,';
        jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" :123123 ,"estimacionCosteExtraRetrasoLocal" : 123123,"estimacionCosteExtraNormalidadLocal" : 123123 ';
        
        jsonContrato = jsonContrato + '}';
        
        Contrato__c myContrato = [select id, name from Contrato__c where name=:'Contrato 1' limit 1];
        result = CRM_Actualiza_Estado_Contratos.updateInfoContrato(myContrato.id,jsonContrato);
        
        
    }
    
    
    
    
    
    
}
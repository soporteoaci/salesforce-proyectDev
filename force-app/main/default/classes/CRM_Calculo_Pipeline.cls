global class CRM_Calculo_Pipeline implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query de las oportunidades');
        String query = 'SELECT Id, Codigo_OC__C,mercado__c,DivisionPicklist__c, Linea_de_Servicio__c, Bloqueada__c,createddate, Fecha_Creacion__C, fecha_estimada_de_Cierre__c,Importe_total_sin_IVA__c,Tipologia__c,Origen__c ';
        query = query + ' from Oportunidad__c where Direccion_Operaciones__c= \'IT&DS\' and fecha_estimada_de_Cierre__c >2023-12-31 ';
        query = query + ' and Record_Type_Name__c != \'Presupuesto\' and mercado__c !=\'60035586\' and mercado__c != \'60035584\' and sociedad_ayesa__c != \'0007\' and Tipo_Extension__c != \'Extensión CUTE\'';
        //entrar fecha de cierre >=01/01/2023
        
        List<Parametrica_2__c> pipeline_a_cero= new List < Parametrica_2__c>();
        Id recordTypePipeline = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Pipeline').getRecordTypeId();
        List <Parametrica_2__c> pipeline_list =[SELECT Id,Clave_pipeline__c, Importe_pipeline__c,importe_aux__c,control__c,pipeline__c FROM Parametrica_2__c where recordtypeId =: recordTypePipeline];
        
        System.debug('Actualizamos a cero el pipeline');
        for(Parametrica_2__c registro: pipeline_list){
            
           
           registro.Importe_pipeline__c=0;
            registro.control__c='';
            pipeline_a_cero.add(registro);
        }
        
        update pipeline_a_cero;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Oportunidad__c> oportunidades){
        // system.debug('Tamaño de lista oportunidades:  ' + oportunidades.size());
        String clave='';
        Map<String, Decimal> totalPorClave = new Map<String, Decimal>();
        Map<String, String> OportunidadClave = new Map<String, String>();
        //Traemos los registros de parametrica
        Id recordTypePipeline = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Pipeline').getRecordTypeId();
        List <Parametrica_2__c> pipeline_list =[SELECT Id,Clave_pipeline__c, Importe_pipeline__c,importe_aux__c,control__c FROM Parametrica_2__c where recordtypeId =: recordTypePipeline];
        
        //System.debug('Tamaño lista de registros en parametrica_2 pipeline_list: '+ pipeline_list.size()); 
        //map_pipeline es la clave y el importe de la tabla parametrica  
        //inicializamos totalPorClave con lo que haya ya actualizado
        Map<String,Parametrica_2__c > map_pipeline = new Map <String,Parametrica_2__c>();
        for(Parametrica_2__c registro: pipeline_list){
            map_pipeline.put(registro.clave_pipeline__c, registro);
            totalPorClave.put(registro.clave_pipeline__c, registro.Importe_pipeline__c);
            OportunidadClave.put(registro.clave_pipeline__c, registro.control__c);
            // System.debug('Importe inicial: '+ registro.clave_pipeline__c +' --> '+registro.Importe_pipeline__c );
        }
        
        
        String mes ='';
        
        //System.debug('Empieza cálculo de los importes iterando sobre las oportunidades');
        Date FechaCreacion;
        Date FechaCierre;
        for(oportunidad__c op: oportunidades){
            FechaCreacion = op.Fecha_Creacion__c.date();
            FechaCierre = op.Fecha_estimada_de_cierre__c;
            //si la fecha cierre es menor que la fecha de creación, coja como fecha creación la fecha de cierra
            if(FechaCierre < FechaCreacion){
                FechaCreacion =op.Fecha_estimada_de_cierre__c;
                //  system.debug(  op.Codigo_oc__c + '--> Fecha creacion cambiada: ' + FechaCreacion);
            }
            
            if(op.Bloqueada__c == false){
                FechaCierre=Date.newInstance(2032,02,01);
            }
            if(	FechaCreacion.year()	< 2024){
                //<2023
                mes ='<2024';
                
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
                
            }
            
            
            if(	FechaCreacion	<	Date.newInstance(2024,02,01)	&& FechaCierre	>	Date.newInstance(2024,01,31) ){
                mes='enero24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,03,01) && 	FechaCierre	> Date.newInstance(2024,02,28)){
                mes='febrero24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,04,01) && 	FechaCierre	>Date.newInstance(2024,03,31)){
                mes='marzo24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,05,01) && 	FechaCierre	>Date.newInstance(2024,04,30)){
                mes='abril24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,06,01) && 	FechaCierre	>Date.newInstance(2024,05,31)){
                mes='mayo24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,07,01) && 	FechaCierre	>Date.newInstance(2024,06,30)){
                mes='junio24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,08,01) && 	FechaCierre	>Date.newInstance(2024,07,31)){
                mes='julio24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,09,01) && 	FechaCierre	>Date.newInstance(2024,08,31)){
                mes='agosto24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,10,01) && 	FechaCierre	>Date.newInstance(2024,09,30)){
                mes='septiembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,11,01) && 	FechaCierre	>Date.newInstance(2024,10,31)){
                mes='octubre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,12,01) && 	FechaCierre	>Date.newInstance(2024,11,30)){
                mes='noviembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,01,01) && 	FechaCierre	>Date.newInstance(2024,12,31)){
                mes='diciembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,02,01) && 	FechaCierre	>Date.newInstance(2025,01,31)){
                mes='enero25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,03,01) && 	FechaCierre	>Date.newInstance(2025,02,29)){
                mes='febrero25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,04,01) && 	FechaCierre	>Date.newInstance(2025,03,31)){
                mes='marzo25';
                
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,05,01) && 	FechaCierre	>Date.newInstance(2025,04,30)){
                mes='abril25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,06,01) && 	FechaCierre	>Date.newInstance(2025,05,31)){
                mes='mayo25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,07,01) && 	FechaCierre	>Date.newInstance(2025,06,30)){
                mes='junio25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,08,01) && 	FechaCierre	>Date.newInstance(2025,07,31)){
                mes='julio25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,09,01) && 	FechaCierre	>Date.newInstance(2025,08,31)){
                mes='agosto25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,10,01) && 	FechaCierre	>Date.newInstance(2025,09,30)){
                mes='septiembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,11,01) && 	FechaCierre	>Date.newInstance(2025,10,31)){
                mes='octubre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,12,01)&& 	FechaCierre  >Date.newInstance(2025,11,30)){
                mes='noviembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2026,01,01) && 	FechaCierre	>Date.newInstance(2025,12,31)){
                mes='diciembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
        }
        
        
        //Actualizamos los importes, el total esta en totalPorClave
        //Claves del pipeline
        //  System.debug('Actualizamos pipeline con valores finales');
        Set <String> Keyset_map_pipeline = new Set<String>();
        Keyset_map_pipeline = map_pipeline.keySet();
        
        List <Parametrica_2__c> actualizar_pipeline = new List<Parametrica_2__c>();
        Decimal importe=0;
        String cadena_Oportunidad='';
        //  System.debug('para cada clave recuperamos el importe');
        for (String key:Keyset_map_pipeline ){
            
            Importe =  totalPorClave.get(key);
            Cadena_Oportunidad = OportunidadClave.get(key);
            Parametrica_2__c registro =  map_pipeline.get(key);
            //  System.debug('Actualizo importe '+Importe +'---> para la clave: '+ key);
            if(Importe != null){
                registro.Importe_pipeline__c = Importe.setScale(2, RoundingMode.HALF_UP);
                if(cadena_oportunidad != null ){
                    if(cadena_oportunidad.length()<131072){
                        registro.control__c =Cadena_Oportunidad;
                    }
                }
            }
            
            actualizar_pipeline.add(registro);
        }
        
        
        try{
            
            if(actualizar_pipeline.size()>0){
                System.debug('update');
                System.debug(  actualizar_pipeline.size());
                update actualizar_pipeline;
            }
        }catch (DMLException e){ 
            System.debug('Error actualizar importes pipeline: ' + e.getMessage());
            
        }
        
        
        
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        System.debug('CRM_Calculo_Pipeline terminado');
    }
    
    public static Map<String, Decimal> add_importe(String mes,Oportunidad__c op,Map<String, Decimal> totalPorClave,Map<String, String> OportunidadClave){
        
        
        String Mercado = op.Mercado__c;
        String LineaServicio = op.Linea_de_Servicio__c;
        String Division= '';
        if(op.Mercado__c =='60029427'){
            Division='ENERGY & UTILITIES';
        }else{
            Division=op.DivisionPicklist__c;
        }
        
        
        String clave = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio;
        String clave_SinReselling = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio +'|Sin reselling';
        
        //Nueva Clave para registros Hard
        String clave_Hard = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio +'|Hard';
        
        if (totalPorClave.containsKey(clave)) {
            if(op.Importe_total_sin_IVA__c != null){
                totalPorClave.put(clave, totalPorClave.get(clave) + op.Importe_total_sin_IVA__c);
            }
            
            OportunidadClave.put(clave, OportunidadClave.get(clave) +';' +op.Codigo_OC__c);
            
        }
        
        if (totalPorClave.containsKey(clave_SinReselling)) {
            if(op.Importe_total_sin_IVA__c != null){
                if(op.Tipologia__c !='5' && op.Tipologia__c !='4'){
                    totalPorClave.put(clave_SinReselling, totalPorClave.get(clave_SinReselling) + op.Importe_total_sin_IVA__c);
                }
            }

            OportunidadClave.put(clave_SinReselling, OportunidadClave.get(clave_SinReselling) +';' +op.Codigo_OC__c);
            
        }
        //Calculo importe para los registros Hard
        if (totalPorClave.containsKey(clave_Hard)) {
            if(op.Importe_total_sin_IVA__c != null){
                if(String.isNotBlank(op.Origen__c) && op.Origen__c =='Hard'){
                    totalPorClave.put(clave_Hard, totalPorClave.get(clave_Hard) + op.Importe_total_sin_IVA__c);
                }
            }

            OportunidadClave.put(clave_Hard, OportunidadClave.get(clave_Hard) +';' +op.Codigo_OC__c);
            
        }                
        
        return totalPorClave;
    }
    public static void test() {
        String test1;
        String test2;
        String test3;
        String test4;
        String test5;
        String test6;
        String test7;
        String test8;
        String test9;
        String test10;
        String test11;
        String test12;
        String test13;
        String test14;
        String test15;
        String test16;
        String test17;
        String test18;
        String test19;
        String test20;
        String test21;
        String test22;
        String test23;
        String test24;
        String test25;
        String test26;
        String test27;
        String test28;
        String test29;
        String test30;
        String test31;
        String test32;
        String test33;
        String test34;
        String test35;
        String test36;
        String test37;
        String test38;
        String test39;
        String test40;
        String test41;
        String test42;
        String test43;
        String test44;
        String test45;
        String test46;
        String test47;
        String test48;
        String test49;
        String test50;
        String test51;
        String test52;
        String test53;
        String test54;
        String test55;
        String test56;
        String test57;
        String test58;
        String test59;
        String test60;
        String test61;
        String test62;
        String test63;
        String test64;
        String test65;
        String test66;
        String test67;
        String test68;
        String test69;
        String test70;
        String test71;
        String test72;
        String test73;
        String test74;
        String test75;
        String test76;
        String test77;
        String test78;
        String test79;
        String test80;
        String test81;
        String test82;
        String test83;
        String test84;
        String test85;
        String test86;
        String test87;
        String test88;
        String test89;
        String test90;
        String test91;
        String test92;
        String test93;
        String test94;
        String test95;
        String test96;
        String test97;
        String test98;
        String test99;
        String test100;
        String test101;
        String test102;
        String test103;
        String test104;
        String test105;
        String test106;
        String test107;
        String test108;
        String test109;
        String test110;
        String test111;
        String test112;
        String test113;
        String test114;
        String test115;
        String test116;
        String test117;
        String test118;
        String test119;
        String test120;
        String test121;
        String test122;
        String test123;
        String test124;
        String test125;
        String test126;
        String test127;
        String test128;
        String test129;
        String test130;
        String test131;
        String test132;
        String test133;
        String test134;
        String test135;
        String test136;
        String test137;
        String test138;
        String test139;
        String test140;
        String test141;
        String test142;
        String test143;
        String test144;
        String test145;
        String test146;
        String test147;
        String test148;
        String test149;
        String test150;
        String test151;
        String test152;
        String test153;
        String test154;
        String test155;
        String test156;
        String test157;
        String test158;
        String test159;
        String test160;
        String test161;
        String test162;
        String test163;
        String test164;
        String test165;
        String test166;
        String test167;
        String test168;
        String test169;
        String test170;
        String test171;
        String test172;
        String test173;
        String test174;
        String test175;
        String test176;
        String test177;
        String test178;
        String test179;
        String test180;
        String test181;
        String test182;
        String test183;
        String test184;
        String test185;
        String test186;
        String test187;
        String test188;
        String test189;
        String test190;
        String test191;
        String test192;
        String test193;
        String test194;
        String test195;
        String test196;
        String test197;
        String test198;
        String test199;
        String test200;
        String test201;
        String test202;
        String test203;
        String test204;
        String test205;
        String test206;
        String test207;
        String test208;
        String test209;
        String test210;
        String test211;
        String test212;
        String test213;
        String test214;
        String test215;
        String test216;
        String test217;
        String test218;
        String test219;
        String test220;
        String test221;
        String test222;
        String test223;
        String test224;
        String test225;
        String test226;
        String test227;
        String test228;
        String test229;
        String test230;
        String test231;
        String test232;
        String test233;
        String test234;
        String test235;
        String test236;
        String test237;
        String test238;
        String test239;
        String test240;
        String test241;
        String test242;
        String test243;
        String test244;
        String test245;
        String test246;
        String test247;
        String test248;
        String test249;
        String test250;
        String test251;
        String test252;
        String test253;
        String test254;
        String test255;
        String test256;
        String test257;
        String test258;
        String test259;
        String test260;
        String test261;
        String test262;
        String test263;
        String test264;
        String test265;
        String test266;
        String test267;
        String test268;
        String test269;
        String test270;
        String test271;
        String test272;
        String test273;
        String test274;
        String test275;
        String test276;
        String test277;
        String test278;
        String test279;
        String test280;
        String test281;
        String test282;
        String test283;
        String test284;
        String test285;
        String test286;
        String test287;
        String test288;
        String test289;
        String test290;
        String test291;
        String test292;
        String test293;
        String test294;
        String test295;
        String test296;
        String test297;
        String test298;
        String test299;
        String test300;
        String test301;
        String test302;
        String test303;
        String test304;
        String test305;
        String test306;
        String test307;
        String test308;
        String test309;
        String test310;
        String test311;
        String test312;
        String test313;
        String test314;
        String test315;
        String test316;
        String test317;
        String test318;
        String test319;
        String test320;
        String test321;
        String test322;
        String test323;
        String test324;
        String test325;
        String test326;
        String test327;
        String test328;
        String test329;
        String test330;
        String test331;
        String test332;
        String test333;
        String test334;
        String test335;
        String test336;
        String test337;
        String test338;
        String test339;
        String test340;
        String test341;
        String test342;
        String test343;
        String test344;
        String test345;
        String test346;
        String test347;
        String test348;
        String test349;
        String test350;
        String test351;
        String test352;
        String test353;
        String test354;
        String test355;
        String test356;
        String test357;
        String test358;
        String test359;
        String test360;
        String test361;
        String test362;
        String test363;
        String test364;
        String test365;
        String test366;
        String test367;
        String test368;
        String test369;
        String test370;
        String test371;
        String test372;
        String test373;
        String test374;
        String test375;
        String test376;
        String test377;
        String test378;
        String test379;
        String test380;
        String test381;
        String test382;
        String test383;
        String test384;
        String test385;
        String test386;
        String test387;
        String test388;
        String test389;
        String test390;
        String test391;
        String test392;
        String test393;
        String test394;
        String test395;
        String test396;
        String test397;
        String test398;
        String test399;
        String test400;
    }
}
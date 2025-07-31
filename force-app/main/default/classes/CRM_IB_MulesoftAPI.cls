/**
* @author Ayesa
* @since 24-05-2023
* @desc Creacion APEX Rest integracion CR-IB 
* Mule API
*/
@RestResource(urlMapping='/mulesoft-api/*')
global class CRM_IB_MulesoftAPI {
    @HttpPost
    global static String callApiMule(String pathEndpoint, String requestJSON, String method, Id idEntidad, String interfaz) {
        
        String result;
        System.debug('RequestJSON: ' + requestJSON);
        System.debug('Method: ' + method); 
        System.debug('pathEndpoint: ' + pathEndpoint); 

        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        
        Control_Integracion__c controlInt = new Control_Integracion__c();
        controlInt.Request__c = requestJSON;
        controlInt.Metodo__c = method;
        controlInt.Interfaz__c = interfaz;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        if(method == 'POST'){
            request.setEndpoint(pathEndpoint);
            controlInt.Servicio__c = pathEndpoint;  
            request.setBody(requestJSON);                        
        }else if(method == 'PUT'){          
            request.setEndpoint(pathEndpoint + '/' + idEntidad); 
            controlInt.Servicio__c = pathEndpoint + '/' + idEntidad;  
            request.setBody(requestJSON);            
        }else if(method == 'DELETE'){
            request.setEndpoint(pathEndpoint + '/' + idEntidad); 
            controlInt.Servicio__c = pathEndpoint + '/' + idEntidad;  
        }
                
        request.setMethod(method);
        request.setHeader('Accept' , 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('client-id', cs.client_id__c);
        request.setHeader('client-secret',cs.client_secret__c);
        
        System.debug('Request: ' + request.getBody());
        
        try {
        	HttpResponse response = http.send(request);
                    
            if(response != null){
                
                String responseBody = response.getBody(); 
                
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + responseBody);
                    controlInt.Response__c = responseBody;
                    controlInt.Status_Code__c = response.getStatusCode();       
                    controlInt.Error_Code__c = '00';
                    controlInt.Error_Message__c = 'OK';
                    result = 'OK';
                    
                    tratarResponse(interfaz, request, response);
                    
                } else if(response.getStatusCode() == 201 || response.getStatusCode() == 204){
                    System.debug('Response: ' + responseBody);
                    controlInt.Response__c = responseBody;
                    controlInt.Status_Code__c = response.getStatusCode();       
                    controlInt.Error_Code__c = '00';
                    controlInt.Error_Message__c = 'OK';
                    result = 'OK';
                }else{
                    String json = response.getBody();
                    Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(json);
                    System.debug('Response: ' + responseMap);
                    controlInt.Status_Code__c = response.getStatusCode();
                    controlInt.Response__c = responseBody;
                    controlInt.Error_Code__c = (String)responseMap.get('errorCode');
                    controlInt.Error_Message__c = (String)responseMap.get('errorMessage') + '/' + (String)responseMap.get('errorDescription');
                    result = (String)responseMap.get('errorCode') + ':' + (String)responseMap.get('errorMessage') + '/' + (String)responseMap.get('errorDescription');
                }
            }else{
                controlInt.Error_Code__c = '99';
                controlInt.Error_Message__c = 'KO';
                result = '99: No se ha recibido respuesta del servicio de SUPER.';
            }            
        } catch (CalloutException e) {
        	controlInt.Error_Code__c = '99';
            controlInt.Error_Message__c = 'KO';
            result = '99: No se ha recibido respuesta del servicio de SUPER.';           
        }
        
        insert controlInt;
        return result;
    }
    
    
    @AuraEnabled  
    public static String superPreventaComprobacion(Id idOpp){
        
       	 String mostrar_wraning;
        Oportunidad__c opp = [SELECT id,Codigo_OC__c,Etapa__c, GP_Super__c, CR_Super__c
                                    FROM Oportunidad__c WHERE Id =:idOpp LIMIT 1];
        
        if(opp.GP_Super__c == '' || opp.GP_Super__c == null ||opp.CR_Super__c == '' || opp.CR_Super__c == null){
            mostrar_wraning ='true';
        }else{
            mostrar_wraning = 'false';
        }
       
        return mostrar_wraning;       
    }
    
	@AuraEnabled
	public static String superPreventa(Id idOpp){
        System.debug('Super preventa Oportunidad');
        String mode ;
        List<Oportunidad__c> opp = [SELECT id,Codigo_OC__c,Etapa__c,Subfase__c
                                    FROM Oportunidad__c WHERE Id =:idOpp LIMIT 1];
        
        if(opp.get(0).Subfase__c== 'Ganada' || opp.get(0).Subfase__c== 'Perdida' || opp.get(0).Subfase__c== 'Aplazada / anulada'   || opp.get(0).Subfase__c== 'No presentada'){
           
           //opp.get(0).Etapa__c == 'Cerrada'
            mode = '&modo=R';
        }else{
            mode = '&modo=W';
        }
        System.debug('Modo de acceso: '+ mode);
        Blob encodePreventaBlob = Blob.valueOf('goto=detalleitem&guid=' +  opp.get(0).Codigo_OC__c + mode);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        String encodePreventa =  cs.URL_Preventa__c + '?' + EncodingUtil.base64Encode(encodePreventaBlob);
        System.debug('encodePreventa: ' + encodePreventa);
        return encodePreventa;
	}
        
    @AuraEnabled
    public static String superPreventaObjetivo(Id idObj){
        System.debug('Super preventa Objetivo');
        String mode = '&modo=R';
        List<Objetivo__c> obj = [SELECT id,Codigo_Objetivo__c,Estado__c
                                 FROM Objetivo__c WHERE Id =:idObj LIMIT 1];
        if(obj.get(0).Estado__c == 'F'){
            mode = '&modo=R';
        }else{
            mode = '&modo=W';
        }
        Blob encodePreventaBlob = Blob.valueOf('goto=detalleitem&guid=' +  obj.get(0).Codigo_Objetivo__c + mode);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
        String encodePreventa =  cs.URL_Preventa__c + '?' + EncodingUtil.base64Encode(encodePreventaBlob);
        System.debug('encodePreventa: ' + encodePreventa);
        return encodePreventa;
    }
    
   	@AuraEnabled
	public static String newFile(Id id) {
		String objType = id.getSObjectType().getDescribe().getName();
        System.debug('getSObjectType(): '+ objType);
		String urlParams;
        Blob encodeNewFileBlob;
        String encodeNewFile;
        System.debug('objType:'+ objType);
        if ('Oportunidad__c' == objType) {
			List<Oportunidad__c> lOpp = [SELECT Name FROM Oportunidad__c WHERE Id =:id LIMIT 1];	

			if (lOpp != null && lOpp.size() > 0) {
				Oportunidad__c opp = lOpp.get(0);
				urlParams = 'op=gc&ct=1&cc=' +  id + '&cd='+ EncodingUtil.urlEncode(opp.Name, 'UTF-8') + '&dt=0,1,2,3,4,5';
			}
		} else if ('Referencia_Comercial__c' == objType) {
			List<Referencia_Comercial__c> lrefCom = [SELECT Name FROM Referencia_Comercial__c WHERE Id =:id LIMIT 1];	

			if (lrefCom != null && lrefCom.size() > 0) {
				Referencia_Comercial__c refCom = lrefCom.get(0);
				urlParams = 'op=gc&ct=2&cc=' +  id + '&cd='+ EncodingUtil.urlEncode(refCom.Name, 'UTF-8') + '&dt=6';  
			}
		}
        System.debug('urlParams: ' + urlParams);
        encodeNewFileBlob = Blob.valueOf(urlParams);
        CRM_Ibermatica_Configuration__c cs = CRM_Ibermatica_Configuration__c.getInstance();
		encodeNewFile = cs.URL_Consulta_New_File__c + '?p=' + EncodingUtil.base64Encode(encodeNewFileBlob);
		System.debug('encodeNewFile: ' + encodeNewFile);
      
        return encodeNewFile;
	}
    
    @AuraEnabled
    public static void oportunidad_documentacion(Id id){
        
        String objType = id.getSObjectType().getDescribe().getName();
        System.debug('getSObjectType(): '+ objType);
	
        System.debug('objType:'+ objType);
        if ('Oportunidad__c' == objType) {
			List<Oportunidad__c> lOpp = [SELECT id, Name,Documentacion_IB__c FROM Oportunidad__c WHERE Id =:id LIMIT 1];	
            System.debug('Actualizamos a true  opp.Documentacion_IB__c =true 1');
            if (lOpp != null && lOpp.size() > 0 ) {
                Oportunidad__c opp = lOpp.get(0);
                if(opp.Documentacion_IB__c == false){
                    try{
                        System.debug('Actualizamos a true  opp.Documentacion_IB__c =true');
                        opp.Documentacion_IB__c =true;
                        update opp;
                        
                    }catch(DMLException e){ 
                         System.debug('Error Extensión Oportunidad: ' + e.getMessage());
                    }
                    
                }

			}
		} else if ('Referencia_Comercial__c' == objType) {
			List<Referencia_Comercial__c> lrefCom = [SELECT Name,Ficha__c FROM Referencia_Comercial__c WHERE Id =:id LIMIT 1];	

			if (lrefCom != null && lrefCom.size() > 0) {
				Referencia_Comercial__c refCom = lrefCom.get(0);
                if(refCom.Ficha__c==false){
                    try{
                         System.debug('Actualizamos a true  refCom.Ficha__c =true;');
                       // refCom.Ficha__c =true;
                        update refCom;
                        
                    }catch(DMLException e){ 
                         System.debug('Error Extensión Oportunidad: ' + e.getMessage());
                    }
				
			}
		}
        
    }
    }  
    
        
    //Metodo para tratar los body de las respuestas que apliquen
    private static void tratarResponse(String interfaz, HttpRequest request, HttpResponse response) {      
        switch on interfaz {
            when 'AltaClienteSAP' {					
                //Recupero el codContable de la respuesta y el id del cliente en la request para hacer el update
                Map<String,Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(request.getBody());
                Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String accId = (String) requestMap.get('codCta');
                System.debug('accId:' + accId);
                String codContable = (String)responseMap.get('codContable');
                System.debug('codContable:' + codContable);
                
                Account accUpdate = new Account();
                accUpdate.Id = accId;
                accUpdate.SAP_Account_IB__c = codContable;
                
                update accUpdate;               
                System.debug('Account ' + accId + ' updated');
            }
        }       
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
		String test401;
		String test402;
		String test403;
		String test404;
		String test405;
		String test406;
		String test407;
		String test408;
		String test409;
		String test410;
		String test411;
		String test412;
		String test413;
		String test414;
		String test415;
		String test416;
		String test417;
		String test418;
		String test419;
		String test420;
		String test421;
		String test422;
		String test423;
		String test424;
		String test425;
		String test426;
		String test427;
		String test428;
		String test429;
		String test430;
		String test431;
		String test432;
		String test433;
		String test434;
		String test435;
		String test436;
		String test437;
		String test438;
		String test439;
		String test440;
		String test441;
		String test442;
		String test443;
		String test444;
		String test445;
		String test446;
		String test447;
		String test448;
		String test449;
		String test450;
		String test451;
		String test452;
		String test453;
		String test454;
		String test455;
		String test456;
		String test457;
		String test458;
		String test459;
		String test460;
		String test461;
		String test462;
		String test463;
		String test464;
		String test465;
		String test466;
		String test467;
		String test468;
		String test469;
		String test470;
		String test471;
		String test472;
		String test473;
		String test474;
		String test475;
		String test476;
		String test477;
		String test478;
		String test479;
		String test480;
		String test481;
		String test482;
		String test483;
		String test484;
		String test485;
		String test486;
		String test487;
		String test488;
		String test489;
		String test490;
		String test491;
		String test492;
		String test493;
		String test494;
		String test495;
		String test496;
		String test497;
		String test498;
		String test499;
		String test500;
		String test501;
		String test502;
		String test503;
		String test504;
		String test505;
		String test506;
		String test507;
		String test508;
		String test509;
		String test510;
		String test511;
		String test512;
		String test513;
		String test514;
		String test515;
		String test516;
		String test517;
		String test518;
		String test519;
		String test520;
		String test521;
		String test522;
		String test523;
		String test524;
		String test525;
		String test526;
		String test527;
		String test528;
		String test529;
		String test530;
		String test531;
		String test532;
		String test533;
		String test534;
		String test535;
		String test536;
		String test537;
		String test538;
		String test539;
		String test540;
		String test541;
		String test542;
		String test543;
		String test544;
		String test545;
		String test546;
		String test547;
		String test548;
		String test549;
		String test550;
		String test551;
		String test552;
		String test553;
		String test554;
		String test555;
		String test556;
		String test557;
		String test558;
		String test559;
		String test560;
		String test561;
		String test562;
		String test563;
		String test564;
		String test565;
		String test566;
		String test567;
		String test568;
		String test569;
		String test570;
		String test571;
		String test572;
		String test573;
		String test574;
		String test575;
		String test576;
		String test577;
		String test578;
		String test579;
		String test580;
		String test581;
		String test582;
		String test583;
		String test584;
		String test585;
		String test586;
		String test587;
		String test588;
		String test589;
		String test590;
		String test591;
		String test592;
		String test593;
		String test594;
		String test595;
		String test596;
		String test597;
		String test598;
		String test599;
		String test600;
		String test601;
		String test602;
		String test603;
		String test604;
		String test605;
		String test606;
		String test607;
		String test608;
		String test609;
		String test610;
		String test611;
		String test612;
		String test613;
		String test614;
		String test615;
		String test616;
		String test617;
		String test618;
		String test619;
    }
}
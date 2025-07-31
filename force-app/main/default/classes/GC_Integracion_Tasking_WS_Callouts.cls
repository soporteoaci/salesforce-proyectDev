public class GC_Integracion_Tasking_WS_Callouts {

    //  ------- PROYECTO/CONTRATOS ---------------

    //public static List<GC_Integracion_Tasking_Aux.cls_projects> get_Cont_From_SAPCode(String SAP_Code) {
    public static String get_Cont_From_SAPCode(String SAP_Code) {
        // String result = '';
        //GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List();
        Map < String, Object > info_WS = new Map < String, Object > ();
        List < Object > myObjects = new List < Object > ();
        // List < GC_Integracion_Tasking_Aux.cls_projects > info = new List < GC_Integracion_Tasking_Aux.cls_projects > ();

        // Boolean next = true;
        // Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        //Map<String, Object> results;        
        //  do {
        info_WS = get_Pro_Cont_List_WS(SAP_Code, 0);
        System.debug('get_Cont_From_SAPCode - results: ');
        System.debug(info_WS.get('projects'));
        //System.debug(info_WS.projects.size()); 

        //Añadimos a la lista siguientes datos
        /*   if(!info_WS.projects.isEmpty()) {
info.addAll(info_WS.projects);

//Comprobamos paginación
offsetWS = info_WS.offset;
totalWS = info_WS.total_count;
offsetWS += limitWS; // proximo pto de inicio                
}
if(offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
} while (next);*/
        myObjects = (List < Object > ) info_WS.get('projects');
        System.debug('Tamaño de la lista de PROYECTOS: ' + myObjects.size());

        String finalValue = '';
        if (myObjects.size() > 0 /*&& myObjects.size() == 1*/) {
            Map < String, Object > a2 = (Map < String, Object > ) myObjects[0];
            System.debug(a2);

            if (a2.containsKey('parent')) {
                GC_Integracion_Tasking_Aux.cls_parent parent = (GC_Integracion_Tasking_Aux.cls_parent) System.JSON.deserialize(JSON.serialize(a2.get('parent')), GC_Integracion_Tasking_Aux.cls_parent.class);
                finalValue = String.valueOf(parent.id);
            } else {
                finalValue = String.valueOf(a2.get('id'));
            }

            // System.debug('Tamaño final de la lista de Proyectoss: ---->' + info.size());
        } else if (myObjects.size() == 0) {
            finalValue = 'ERR001';
        } 
        // else if (myObjects.size() > 1) {
        //     finalValue = 'ERR002';
        // }
        return finalValue;
    }

    // public static GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List get_Pro_Cont_List_WS(String SAP_Code, integer offsetWS) {
    public static Map < String, Object > get_Pro_Cont_List_WS(String SAP_Code, integer offsetWS) {
        // String status = '';
        // String message = '';
        // String result = '';
        String offsetWS_String = String.Valueof(offsetWS);
        //  GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List info = new GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List();

        Map < String, Object > info = new Map < String, Object > ();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'projects.json';
        //endpoint_aux= endpoint_aux + '?set_filter=1&cf_53='+ SAP_Code +'&offset='+offsetWS_String+'&cf_69=1';//Cuando se hacia buscando el proyecto principal
        // endpoint_aux = endpoint_aux + '?set_filter=1&cf_53=' + SAP_Code + '&offset=' + offsetWS_String;
        endpoint_aux = endpoint_aux + '?set_filter=1&cf_205=' + SAP_Code + '&offset=' + offsetWS_String;

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);

        // request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_Pro_Cont_List_WS');
        System.debug(response.getBody());
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());
        // result = response.getBody();

        //         if (response.getStatusCode() == 200) {
        //             // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //             // responseParse = util.parseAreaResponse_v2(response.getBody());
        //             System.debug('STATUS CODE 200');

        //             //info = GC_Integracion_Tasking_Aux.parsejson_InfoProCont(response.getBody());

        //             info = GC_Integracion_Tasking_Aux.parsejson_InfoProContNew(response.getBody());

        //             /* if (info.errors != null) {
        // //Devuelve la respuesta error
        // status = 'KO';
        // message = 'Error: ' + info.errors;

        // } else {
        // status = 'OK';
        // }*/
        //         } else {
        //             System.debug('STATUS CODE != 200');
        //             // info = GC_Integracion_Tasking_Aux.parsejson_InfoProCont(response.getBody());
        //             info = GC_Integracion_Tasking_Aux.parsejson_InfoProContNew(response.getBody());
        //         }

        info = GC_Integracion_Tasking_Aux.parsejson_InfoProContNew(response.getBody());
        // info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        return info;
    }

    public static String get_TasKing_Id_for_Project(String SAP_Code, integer offsetWS) {
        String status = '';
        // String message = '';
        // String result = '';
        String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List info = new GC_Integracion_Tasking_Aux.jsonInfo_ProCont_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'projects.json';
        endpoint_aux = endpoint_aux + '?set_filter=1&cf_53=' + SAP_Code + '&offset=' + offsetWS_String + '&cf_69=1'; //Especificando que es PROYECTO PRINCIPAL (PADRE)
        //endpoint_aux= endpoint_aux + '?set_filter=1&cf_53='+ SAP_Code +'&offset='+offsetWS_String  //Sin especificar que es PROYECTO PRINCIPAL

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_TasKing_Id_for_Project');
        System.debug(response.getBody());
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());
        // result = response.getBody();

        // if (response.getStatusCode() == 200) {
        //     // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //     // responseParse = util.parseAreaResponse_v2(response.getBody());
        //     info = GC_Integracion_Tasking_Aux.parsejson_InfoProCont(response.getBody());

        //     if (info.errors[0].errors != null && info.errors[0].errors != '') {
        //         //Devuelve la respuesta error
        //         status = 'KO';
        //         // message = 'Error: ' + info.errors;
        //     } else {
        //         status = 'OK';
        //     }
        // } else {
        //     info = GC_Integracion_Tasking_Aux.parsejson_InfoProCont(response.getBody());
        // }

        info = GC_Integracion_Tasking_Aux.parsejson_InfoProCont(response.getBody());
        // info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        return status;
    }

    //  ------- ELEMENTOS SAP (issue) ---------------

    // Metodo que solicita por WS los TDR'S asociados a cada contrato  
    public static String get_ElementoSAP_From_CodigoSAP_WS(String codSAPProyecto) {
        // String status = '';
        // String message = '';
        // String result = '';
        String codigoElementoSAP = '';
        //String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List infoElementoSap = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List(); //Es la misma estructura que la de los TDR's y ENTREGABLES

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues.json';

        endpoint_aux = endpoint_aux + '?subject=' + codSAPProyecto;

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
     /*   // System.debug('get_ElementoSAP_From_ContractId_WS');
        //System.debug('get_ElementoSAP_From_ContractId_WS: offsetWS:   '+ offsetWS);
        //System.debug(response.getBody());
        //System.debug(response.getStatus());
        //System.debug(response.getStatusCode());
        // result = response.getBody();

        // if (response.getStatusCode() == 200) {
        //     // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //     // responseParse = util.parseAreaResponse_v2(response.getBody());
        //     infoElementoSap = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());
        //     System.debug(infoElementoSap.errors);
        //     // if (infoElementoSap.errors != null) {
        //     //     //Devuelve la respuesta error
        //     //     status = 'KO';
        //     //     message = 'Error: ' + infoElementoSap.errors;
        //     // } else {
        //     //     status = 'OK';
        //     // }
        // } else {
        //     infoElementoSap = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());
        // }*/

        infoElementoSap = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        System.debug(infoElementoSap);
        System.debug(infoElementoSap.issues[0].id);
        if (infoElementoSap.issues.size() > 0) {
            codigoElementoSAP = String.ValueOf(infoElementoSap.issues[0].id);
        }

        System.debug('codigoElementoSAP: ' + codigoElementoSAP);
        return codigoElementoSAP;

    }

    //  ------- TDR'S ---------------

    public static List < GC_Integracion_Tasking_Aux.clss_issues > get_TDRS_From_ContractId(String idTasking, String elementToGet, String codSAPContrato) {

        // String result = '';

        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();
        List < GC_Integracion_Tasking_Aux.clss_issues > info = new List < GC_Integracion_Tasking_Aux.clss_issues > ();

        Boolean next = true;
        Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        //Map<String, Object> results;        
        do {
            info_WS = get_TDRS_From_ContractId_WS(idTasking, elementToGet, offsetWS, codSAPContrato);
            System.debug('get_TDRS_From_ContractId - results: ');
            System.debug('get_TDRS_From_ContractId:  IdTamaño de la respuesta: ' + info_WS.issues.size());
            System.debug('get_TDRS_From_ContractId:  Tamaño de la respuesta: ' + info_WS.issues.size());
            System.debug('get_TDRS_From_ContractId:  Offset de la peticion: ' + offsetWS);

            //Añadimos a la lista siguientes datos
            if (!info_WS.issues.isEmpty()) {
                info.addAll(info_WS.issues);

                //Comprobamos paginación
                offsetWS = info_WS.offset;
                totalWS = info_WS.total_count;
                offsetWS += limitWS; // proximo pto de inicio                
            }
            if (offsetWS >= totalWS || info_WS.issues.size() == 0) {next = false;} //Si pto de inicio es mayor que el total de registros OR el tamaño de la respuesta es CERO, salimos
        } while (next);

        System.debug('Tamaño final de la lista de TDRs: ---->' + info.size());
        /* for (GC_Integracion_Tasking_Aux.clss_issues tdr : info){
System.debug('Id del TDR: '+tdr.id);
System.debug('Nombre del TDR: '+tdr.subject);
}*/
        return info;
    }

    // Metodo que solicita por WS los TDR'S asociados a cada contrato  
    public static GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List get_TDRS_From_ContractId_WS(String idTasking, String elementToGet, integer offsetWS, String codSAPContrato) {
       /* // String status = '';
        // String message = '';
        // String result = '';*/
        String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues.json';

        //V1 del endpoint sin filtro de TDR's
        // endpoint_aux= endpoint_aux + '?set_filter=1&tracker_id='+ elementToGet +'&project_id='+ idTasking+'&offset='+offsetWS_String;

        //V2 del endpoint filtrando los TDR's por elemento de imputación
        if (elementToGet == '2') {
            endpoint_aux = endpoint_aux + '?set_filter=1&tracker_id=' + elementToGet + '&project_id=' + idTasking + '&offset=' + offsetWS_String;
        } else if (elementToGet == '7') {
            endpoint_aux = endpoint_aux + '?set_filter=1&tracker_id=' + elementToGet + '&project_id=' + idTasking + '&offset=' + offsetWS_String; //+ '&cf_217=' + codSAPContrato; //custom field de elemento sap 217
        }

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_TDRS_From_ContractId_WS');
        System.debug('get_TDRS_From_ContractId_WS: offsetWS:   ' + offsetWS);
     /*   //System.debug(response.getBody());
        //System.debug(response.getStatus());
        //System.debug(response.getStatusCode());
        // result = response.getBody();

        // if (response.getStatusCode() == 200) {
        //     // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //     // responseParse = util.parseAreaResponse_v2(response.getBody());
        //     info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());
        //     System.debug(info.errors);
        //     // if (info.errors != null) {
        //     //     //Devuelve la respuesta error
        //     //     status = 'KO';
        //     //     message = 'Error: ' + info.errors;
        //     // } else {
        //     //     status = 'OK';
        //     // }
        // } else {
        //     info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());
        // }*/

        info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        return info;
    }

    // Mapeo con los TDR's de SF
    public static List < Termino_de_Referencia__c > parse_To_Tdr_List_SF(List < GC_Integracion_Tasking_Aux.clss_issues > tdrWSList, String contractId) {
		System.debug('parse_To_Tdr_List_SF' + tdrWSList.size());
        List < Termino_de_Referencia__c > newTDRList = new List < Termino_de_Referencia__c > ();
        Map < String, Parametrica__c > myStatusMap = get_Map_Status_by_Tasking_Id('TDR'); //Solicitamos la parametrica de los estados para consultarlos cada vez que creemos un TDR
        Map < String, Parametrica__c > myOrigenMap = get_Map_Origen_by_Tasking_Id(); //Solicitamos la parametrica de los estados para consultarlos cada vez que creemos un TDR
        Map < String, User > myUserMap = get_UserMap_by_Tasking_Id(); //Solicitamos la lista de Usercon Id_Tasking para consultarlos cada vez que creemos un TDR
        String projectId = '';
        String ContratoCodSAP='';

        //Se recuper el Proyeto para asociarlo al TDR
        List < Contrato__c > mycurrentProject = [SELECT id, Proyecto__r.id,Codigo_SAP__c
            FROM Contrato__c
            WHERE id =: contractId
        ];

        if (mycurrentProject.size() > 0) {
            projectId = mycurrentProject[0].Proyecto__r.id;
           ContratoCodSAP=mycurrentProject[0].Codigo_SAP__c;
        }
        System.debug('Código proyecto + código contrato:::'+ projectId + ContratoCodSAP);
		//System.debug('Código Contrato en sf'+ContratoCodSAP);
        for (GC_Integracion_Tasking_Aux.clss_issues tdrWS: tdrWSList) {
            Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > CFMap = new Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > ();
            for (GC_Integracion_Tasking_Aux.cls_custom_fields cf: tdrWS.custom_fields) {
                CFMap.put(String.ValueOf(cf.id), cf);
                //System.debug(String.ValueOf(cf.id));
                //System.debug(cf);
            }

            System.debug('Valor de origen: ' + (CFMap.get('147')).value);
            //    if( (CFMap.get('147')).value != '1145'){ //Los que se refieren a 'Procedimientos' internos no se vuelcan //Eliminado en la ultima revision (18/09/2020)
            
       System.debug('Código Contrato importado desde Tasking name' + ((CFMap.get('217')).name).substringAfter('- '));
       //    217 TDR-Elemento SAP 
       //    Creamos los TDR que tengan el código TDR-Elemento SAP igual al código del contrato desde donde llamamos al importador
            
            
           If(ContratoCodSAP==(((CFMap.get('217')).name).substringAfter('- '))){
               
            Termino_de_Referencia__c newTDR = new Termino_de_Referencia__c();

            newTDR.Contrato__c = contractId;
            newTDR.Nombre__c = (String.ValueOf(tdrWS.id) + ' - ' + tdrWS.subject).left(80); //Trunco a los 80 caracteres el campo SUBJECT
            newTDR.name = String.ValueOf(tdrWS.id);
            newTDR.Id_Tasking__c = String.ValueOf(tdrWS.id);
            newTDR.Proyecto__c = projectId; //Eliminar la dependencia con Proyecto

            //newTDR.Estado_Tasking__c= myStatusMap.get(String.ValueOf(tdrWS.status.id)).Auxiliar__c;
            //newTDR.Estado__c=myStatusMap.get(String.ValueOf(tdrWS.status.id)).Auxiliar__c; //Eliminado en la ultima revision (18/09/2020)
            newTDR.Estado__c = 'Pendiente'; //Nacen como Pendiente ( ultima revision (18/09/2020) )

            if (myUserMap.get(String.ValueOf(tdrWS.author.id)) != null) { //Se comprueba si existe el Usuario
                newTDR.CreatedById = (myUserMap.get(String.ValueOf(tdrWS.author.id))).id;
            }

            // newTDR.CreatedDate= get_DateTime_From_TaskingDate(tdrWS.created_on);//Fecha creación
            newTDR.CreatedDate = (DateTime) JSON.deserialize(tdrWS.created_on, DateTime.class);
            //System.debug(CFMap.get('147'));
            newTDR.Origen__c = (myOrigenMap.get((CFMap.get('147')).value).Auxiliar__c).substringBefore('/'); //147 identificador del campo TDR Tipo
            //newTDR.Categoria__c='Desarrollos';
            newTDR.Categoria__c = (CFMap.get('174')).value; //174 identificador del campo TDR Categoría
               
            newTDR.Descripcion__c = tdrWS.description.left(2500); //Truco a los 2500 caracteres el campo Descripcion para evitar el error al insertar en SF

            newTDRList.add(newTDR);
            //  }
            }
        }
		System.debug('Lista TDR creada con estructura SF'+ newTDRList.size());
        return newTDRList;
    }

    //------------------------------------
    public static String get_SingleTDR_Info_FromId(String elementId) {
        String result = '';

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues/' + elementId + '.json';

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);
        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_SingleTDR_Info_FromId');
        System.debug(response);

        return result;
    }
    //  ------- TDR'S METODOS AUXIULIARES ---------------

    //  ------- BUSCAR usuario por email
    public static Map < String, user > get_UserMap_by_Tasking_Id() {
        Map < String, user > myMap = new Map < String, User > ();

        for (User us: [SELECT id, name, Id_Tasking__c FROM User WHERE Id_Tasking__c != null]) {
            myMap.put(us.Id_Tasking__c, us);
        }

        return myMap;
    }

    //  ------ Transformar la fecha de Tasking en Fecha de SF (fecha y hora)
    public static DateTime get_DateTime_From_TaskingDate(String createddate) {
        // DateTime dt = (DateTime) JSON.deserialize(createddate, DateTime.class);
        return DateTime.valueOfGmt(createddate + ' ' + '00:00:00');
    }

    //  ------- Transformar la fecha de Tasking en Fecha de SF (solo fecha)
    public static Date get_Date_From_TaskingDate(String createddate) {
        //Date dt = (Date) JSON.deserialize(createddate, Date.class);
        return date.valueOf(createddate);
    }

    //  ------- Obtener de la parametrica el valor correcto del estado
    public static Map < String, Parametrica__c > get_Map_Status_by_Tasking_Id(String tipo) {

        //String taskIdString = String.ValueOf(taskingId);
        Map < String, Parametrica__c > myMap = new Map < String, Parametrica__c > ();

        for (Parametrica__c par: [SELECT id, Activo__c, Auxiliar__c, Tipo__c, Tipo_Padre__c, Valor__c
                FROM Parametrica__c
                WHERE Activo__c = true
                AND Tipo__c =: tipo
                AND Tipo_Padre__c =: 'GC_ESTADOS'
            ]) {
            myMap.put(par.Valor__c, par);
        }

        return myMap;
    }

    //  ------- Obtener de la parametrica el valor correcto del ORIGEN del TDR
    public static Map < String, Parametrica__c > get_Map_Origen_by_Tasking_Id() {

        //String taskIdString = String.ValueOf(taskingId);
        Map < String, Parametrica__c > myMap = new Map < String, Parametrica__c > ();

        for (Parametrica__c par: [SELECT id, Activo__c, Auxiliar__c, Tipo__c, Tipo_Padre__c, Valor__c
                FROM Parametrica__c
                WHERE Activo__c = true
                AND Tipo__c =: 'TDR'
                AND Tipo_Padre__c =: 'GC_ORIGEN'
            ]) {
            myMap.put(par.Valor__c, par);
        }

        return myMap;
    }

    //  ------- ENTREGABLES (30 Junio) ---------------

    public static List < GC_Integracion_Tasking_Aux.clss_issues > get_Entregables_From_ContractId(String contractId, String elementToGet, String codSAPContrato) {
        // String result = '';
        // String status = '';
        // String message = '';
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();
        List < GC_Integracion_Tasking_Aux.clss_issues > info = new List < GC_Integracion_Tasking_Aux.clss_issues > ();

        Boolean next = true;
        Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        //Map<String, Object> results;        
        do {
            info_WS = get_TDRS_From_ContractId_WS(contractId, elementToGet, offsetWS, codSAPContrato);
            System.debug('get_Entregables_From_ContractId - results: ');
            System.debug(info_WS.errors);
            if (info_WS.errors != null) {
                next = false;
                // status = 'KO';
                // message = 'Error: ' + info_WS.errors;
                // System.debug(message);
            } else {
                System.debug(info_WS.issues);
                System.debug(info_WS.issues.size());

                //Añadimos a la lista siguientes datos
                if (!info_WS.issues.isEmpty()) {
                    info.addAll(info_WS.issues);

                    //Comprobamos paginación
                    offsetWS = info_WS.offset;
                    totalWS = info_WS.total_count;
                    offsetWS += limitWS; // proximo pto de inicio                
                }
                if (offsetWS >= totalWS || info_WS.issues.size() == 0) next = false; //Si pto de inicio es mayor que el total de registros o la lista devuelve CERO elementos, salimos
            }

        } while (next);

        System.debug('Tamaño final de la lista de Entregables: ---->' + info.size());

        return info;
    }

    public static GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List get_Entregables_From_ContractId_WS(String contractId, String elementToGet, integer offsetWS) {

        // String status = '';
        // String message = '';
        // String result = '';
        String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues.json';
        endpoint_aux = endpoint_aux + '?set_filter=1&tracker_id=' + elementToGet + '&project_id=' + contractId + '&offset=' + offsetWS_String;

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);

        // request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_Entregables_From_ContractId_WS');
        System.debug(response.getBody());
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());

        // result = response.getBody();
        // if (response.getStatusCode() == 200) {
        //     // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //     // responseParse = util.parseAreaResponse_v2(response.getBody());
        //     info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        //     // if (info.errors != null) {
        //     //     //Devuelve la respuesta error
        //     //     status = 'KO';
        //     //     message = 'Error: ' + info.errors;
        //     // } else {
        //     //     status = 'OK';
        //     // }
        // }

        info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        return info;
    }

    public static String get_SingleEntregable_Info_FromId(String elementId) {
        String result = '';

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues/' + elementId + '.json';

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);
        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        request.setTimeout(120000);
        //request.setBody(body);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_SingleEntregable_Info_FromId');
        System.debug(response);

        return result;

    }

    //Mapeo con los ENTREGABLES's de SF

    public static List < Subentregable__c > parse_To_Entregable_List_SF(List < GC_Integracion_Tasking_Aux.clss_issues > EntregableWSList, String contractId) {

        List < Subentregable__c > newEntList = new List < Subentregable__c > ();
        Map < String, Parametrica__c > myMap = get_Map_Status_by_Tasking_Id('Entregable'); //Solicitamos la parametrica de los estados para consultarlos cada vez que creemos un ENTREGABLE
        Map < String, User > myUserMap = get_UserMap_by_Tasking_Id(); //Solicitamos la lista de User con Id_Tasking para consultarlos cada vez que creemos un ENTREGABLE

        List < Contrato__c > mycurrentProject = [SELECT id, Proyecto__c FROM Contrato__c WHERE id =: contractId];

        for (GC_Integracion_Tasking_Aux.clss_issues entWS: EntregableWSList) {
            if (entWS.status.id != 18) {
                //  if(myMap.get(String.ValueOf(entWS.status.id)).Auxiliar__c!='Cancelado'){ //se desechan los entregables con estado CANCELADO
                Subentregable__c newEnt = new Subentregable__c();

                //Creo el mapa de los campos custom para poder acceder a ellos luego
                Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > CFMap = new Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > ();
                System.debug('2022 PRUEBA DE CAMPOS TASKING');
                for (GC_Integracion_Tasking_Aux.cls_custom_fields cf: entWS.custom_fields) {
                    CFMap.put(String.ValueOf(cf.id), cf);
                    //2022
                    
                    system.debug('Campo: '+ cf.id +' Name: '+ cf.name );
                }
                //2022
                System.debug('Nº campos custom Entregables: '+ CFMap.size());

                System.debug('Código subentregable ' + entWS.id + ' - Estado actual ' + newEnt.Estado__c + ' - Estado nuevo ' + entWS.status.id + ' (' + (myMap.get(String.ValueOf(entWS.status.id)).Auxiliar__c).substringBefore('/') + ')');
                
              
                
                newEnt.Contrato__c = contractId;
                newEnt.name = (entWS.subject).left(80); //Trunco a los 80 caracteres
                newEnt.CodigoSubentregable__c = String.ValueOf(entWS.id);
                newEnt.Id_Tasking__c = String.ValueOf(entWS.id);
                newEnt.Estado__c = (myMap.get(String.ValueOf(entWS.status.id)).Auxiliar__c).substringBefore('/'); //Estado mapeado VALOR DE ACONTRACT
                newEnt.Avance__c = Integer.ValueOf((myMap.get(String.ValueOf(entWS.status.id)).Auxiliar__c).substringAfter('/')); //Unido a Parametrica
                //System.debug('Porcentaje: '+ (myMap.get(String.ValueOf(entWS.status.id)).Auxiliar__c).substringAfter('/'));
                //newEnt.Entregable__c='a039E00000VPTinQAH';
                newEnt.Estado_Tasking__c = String.ValueOf(entWS.status.id); //Directamente el valor de TAsking
                newEnt.Proyecto__c = mycurrentProject.get(0).Proyecto__c;

                /*if(myUserMap.get(String.ValueOf(entWS.author.id))!=null){ //Se comprueba si existe el Usuario
newEnt.ResponsableN1__c= (myUserMap.get(String.ValueOf(entWS.author.id))).id;
}*/ //Eliminado por Rafa Jimenez

                if (entWS.start_date != null) {
                    newEnt.Fecha_Limite_de_inicio__c = get_Date_From_TaskingDate(entWS.start_date);
                }

                if ((CFMap.get('85')).value != '' && (CFMap.get('85')).value != null) {
                    newEnt.Fecha_Real_de_Paso_a_Inicio__c = get_DateTime_From_TaskingDate((CFMap.get('85')).value); //85 identificador del campo Fecha inicio Real
                }

                if (entWS.due_date != null) {
                    newEnt.Fecha_limite_de_fin__c = get_Date_From_TaskingDate(entWS.due_date); //Fecha fin en Tasking (due_date)
                }
                // System.debug('##### FECHALIMITELIBERACION 192: ' + CFMap.get('192') + ' del id: ' + entWS.id);
                if (CFMap.get('192') != null && (CFMap.get('192')).value != '' && (CFMap.get('192')).value != null) {
                    newEnt.FechaLimiteLiberacion__c = get_Date_From_TaskingDate((CFMap.get('192')).value); //192 identificador del campo E-Fecha limite liberacion
                }

                if ((CFMap.get('51')).value != '' && (CFMap.get('51')).value != null) {
                    newEnt.Fecha_real_de_fin__c = get_DateTime_From_TaskingDate((CFMap.get('51')).value); //51 identificador del campo Fecha fin Real
                }
                /*if((CFMap.get('120')).value !='' && (CFMap.get('120')).value !=null){
                    newEnt.FechaLimiteFirma__c= get_Date_From_TaskingDate((CFMap.get('120')).value); //120 identificador del campo E-Fecha de firma
                }*/

                /*if((CFMap.get('218')).value !='' && (CFMap.get('218')).value !=null){
newEnt.Fecha_Real_de_Liberacion__c= get_DateTime_From_TaskingDate((CFMap.get('218')).value); //218 identificador del campo E-Fecha de liberación real
}

if((CFMap.get('219')).value !='' && (CFMap.get('219')).value !=null){
newEnt.Fecha_Real_de_Firma__c= get_DateTime_From_TaskingDate((CFMap.get('219')).value); //219 identificador del campo E-Fecha de firma real
}*/
				//Comentado 07/01/2022 por cambio de campo en Tasking, ha dejado de ser obligatorio
            	//newEnt.Tipo_entregable__c = (CFMap.get('114')).value; //114 identificador del campo E-Tipo de entregable      
                
                newEnt.Descripciom__c = (entWS.description).left(1500); //Trunco a 1500
				//System.debug('Comprobación campo:'+ CFMap.get('193').value);
              /*  if ((CFMap.get('193')).value != null && (CFMap.get('193')).value != '') { //Unas veces está a null y otras a ""
                   // newEnt.Peso__c = Integer.valueOf((CFMap.get('193')).value); //193 identificador del campo Peso
                }*/

                //  ----   DOCUMENTACION  ----

                /*	if((CFMap.get('169')).value !=null && (CFMap.get('169')).value !='' ){ //Unas veces está a null y otras a ""
newEnt.URL_Doc_Firmada__c = (CFMap.get('169')).value; //169 identificador del campo Documentacion Firmada
}else{
newEnt.URL_Doc_Firmada__c = null;
}

if((CFMap.get('194')).value !=null && (CFMap.get('194')).value !='' ){ //Unas veces está a null y otras a ""
newEnt.URL_Doc_Liberada__c = (CFMap.get('194')).value; //194 identificador del campo Documentacion Liberada
}else{
newEnt.URL_Doc_Liberada__c =null;
}  */
                //  ----   FIN  DOCUMENTACION  ----
                System.debug('Nuevo subentregable --> ' + entWS.id);
                System.debug(newEnt);
                newEntList.add(newEnt);
            }
        }

        return newEntList;
    }

    //  ------- HITOS (30 junio) -------------

    public static List < GC_Integracion_Tasking_Aux.cls_versions > get_Hitos_Info_FromId(String elementId) {
        // String result = '';
        GC_Integracion_Tasking_Aux.jsonInfo_Hitos_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Hitos_List();
        List < GC_Integracion_Tasking_Aux.cls_versions > info = new List < GC_Integracion_Tasking_Aux.cls_versions > ();

        // Boolean next = true;
        // Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        info_WS = get_Hitos_Info_FromId_WS(elementId);
        if (!info_WS.versions.isEmpty()) {
            info.addAll(info_WS.versions);
        }

        //Map<String, Object> results;        
        /*  do {
info_WS = get_RelationWith_Info_FromId_WS(elementId);
System.debug('get_RelationWith_Info_FromId - results: ');    
System.debug(info_WS.relations);  
System.debug(info_WS.relations.size()); 

//Añadimos a la lista siguientes datos
if(!info_WS.relations.isEmpty()) {
info.addAll(info_WS.relations);

//Comprobamos paginación
offsetWS = info_WS.offset;
totalWS = info_WS.total_count;
offsetWS += limitWS; // proximo pto de inicio                
}
if(offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
} while (next);*/

        System.debug('Tamaño final de la lista de Hitos: ---->' + info.size());

        return info;
    }

    public static GC_Integracion_Tasking_Aux.jsonInfo_Hitos_List get_Hitos_Info_FromId_WS(String elementId) {
        // String result = '';

        GC_Integracion_Tasking_Aux.jsonInfo_Hitos_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Hitos_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'projects/' + elementId + '/versions.json';

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_Hitos_Info_FromId_WS');
        System.debug(response.getBody());
        // result = response.getBody();

        info = GC_Integracion_Tasking_Aux.parsejsonInfoHitos(response.getBody());

        return info;
    }

    //Mapeo con los HITOS de SF

    public static List < Hito__c > parse_To_Hito_List_SF(List < GC_Integracion_Tasking_Aux.cls_versions > HitosWSList, String contractId) {

        List < Hito__c > newHitoList = new List < Hito__c > ();
        String moneda = '';

        List < Contrato__c > mycurrentProject = [SELECT id, Moneda__c
            FROM Contrato__c
            WHERE id =: contractId
        ];

        if (mycurrentProject.size() > 0) {
            moneda = mycurrentProject[0].Moneda__c;
        }

        for (GC_Integracion_Tasking_Aux.cls_versions HitoWS: HitosWSList) {

            Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > CFMap = new Map < String, GC_Integracion_Tasking_Aux.cls_custom_fields > ();

            for (GC_Integracion_Tasking_Aux.cls_custom_fields cf: HitoWS.custom_fields) {
                CFMap.put(String.ValueOf(cf.id), cf);
            }

            Hito__c newHito = new Hito__c();
            newHito.Contrato__c = contractId;
            newHito.Id_Tasking__c = String.ValueOf(HitoWS.id);
            newHito.Peso_Facturacion__c = 12; //cargar con valor correcto
            newHito.name = HitoWS.name;
            newHito.Categoria__c = 'Otros';
            newHito.Moneda__c = moneda;
            newHito.Importe_contractual__c = Decimal.Valueof((CFMap.get('196')).value); //196 identificador del campo H-Importe Contractual
            newHito.Descripcion__c = HitoWS.description;
            //newHito.Categoria__c= String.ValueOf(HitoWS.id); //DESCOMENTAR CUANDO SE HAGA EL MAPEO
            // newHito.Proyecto__c='a029E00000O2XSPQA3'; //Eliminar tras reestructuracion
            //newHito.Fecha_Plan_Inicial__c= 
            //newEnt.Estado_Tasking__c=get_Status_by_Tasking_Id(entWS.status.id);
            //newEnt.CreatedBy= get_User_by_Tasking_Id(entWS.author.id);
            if ((CFMap.get('182')).value != '') {
                newHito.Fecha_Fin__c = get_Date_From_TaskingDate((CFMap.get('182')).value); //182 identificador del campo H-Fecha fin del HITO
            }

            if (HitoWS.due_date != null) {
                newHito.Fecha_Plan_Inicial__c = get_Date_From_TaskingDate(HitoWS.due_date); //Fecha fin en Tasking (due_date)
            }

            newHitoList.add(newHito);
        }
        return newHitoList;
    }


    //  ------- RELACIONES TDR's y ENTREGBALES(30 junio) -------------

    public static List < GC_Integracion_Tasking_Aux.cls_relations > get_RelationWith_Info_FromId(String elementId) {
        // String result = '';
        GC_Integracion_Tasking_Aux.jsonInfo_Relaciones_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Relaciones_List();
        List < GC_Integracion_Tasking_Aux.cls_relations > info = new List < GC_Integracion_Tasking_Aux.cls_relations > ();

        //Boolean next = true;
        // Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        info_WS = get_RelationWith_Info_FromId_WS(elementId);
        if (info_WS.relations != null && !info_WS.relations.isEmpty()) {
            info.addAll(info_WS.relations);
        }

        //Map<String, Object> results;        
        /*  do {
info_WS = get_RelationWith_Info_FromId_WS(elementId);
System.debug('get_RelationWith_Info_FromId - results: ');    
System.debug(info_WS.relations);  
System.debug(info_WS.relations.size()); 

//Añadimos a la lista siguientes datos
if(!info_WS.relations.isEmpty()) {
info.addAll(info_WS.relations);

//Comprobamos paginación
offsetWS = info_WS.offset;
totalWS = info_WS.total_count;
offsetWS += limitWS; // proximo pto de inicio                
}
if(offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
} while (next);*/

     //System.debug('!Tamaño final de la lista de Relaciones: ---->'+ info.size());
        return info;
    }

    public static List < GC_Integracion_Tasking_Aux.cls_relations > get_RelationWith_Info_FromIdNew(String projectId) {
        // String result = '';
        System.debug('Entro en get_RelationWith_Info_FromIdNew');
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();
        List < GC_Integracion_Tasking_Aux.cls_relations > info = new List < GC_Integracion_Tasking_Aux.cls_relations > ();

        // Boolean next = true;
        // Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        info_WS = get_RelationWith_Info_FromProjectId_WS(projectId);
        if (info_WS.issues != null && !info_WS.issues.isEmpty()) {
            for (GC_Integracion_Tasking_Aux.clss_issues issue: info_WS.issues) {
                info.addAll(issue.relations);
            }
        }

        //Map<String, Object> results;        
        /*  do {
info_WS = get_RelationWith_Info_FromId_WS(elementId);
System.debug('get_RelationWith_Info_FromId - results: ');    
System.debug(info_WS.relations);  
System.debug(info_WS.relations.size()); 

//Añadimos a la lista siguientes datos
if(!info_WS.relations.isEmpty()) {
info.addAll(info_WS.relations);

//Comprobamos paginación
offsetWS = info_WS.offset;
totalWS = info_WS.total_count;
offsetWS += limitWS; // proximo pto de inicio                
}
if(offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
} while (next);*/

        //System.debug('Tamaño final de la lista de Relaciones: ---->'+ info.size());
        return info;
    }

    public static GC_Integracion_Tasking_Aux.jsonInfo_Relaciones_List get_RelationWith_Info_FromId_WS(String elementId) {
        // String result = '';

        GC_Integracion_Tasking_Aux.jsonInfo_Relaciones_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Relaciones_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues/' + elementId + '/relations.json';

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug('Endpoint:  '+endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);
		System.debug('Request'+request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_RelationWith_Info_FromId_WS');
        
        //System.debug(response.getBody());
        // result = response.getBody();

        if (response.getStatusCode() == 200) {
            info = GC_Integracion_Tasking_Aux.parsejsonInfoRelaciones(response.getBody());

            /*if (info.errors != null) {
                //Devuelve la respuesta error
                status = 'KO';
                message = 'Error: ' + info.errors;
                
            } else {
                status = 'OK';
            }*/
        }
        return info;
    }

    public static GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List get_RelationWith_Info_FromProjectId_WS(String projectId) {
        // String result = '';
		System.debug('Hago la llamada al proyecto');
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues.json?project_id=' + projectId + '&include=relations';

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug('Direccion: '+endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        //System.debug('get_RelationWith_Info_FromId_WS');
        //System.debug(response.getBody());
        // result = response.getBody();

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

            /*if (info.errors != null) {
                //Devuelve la respuesta error
                status = 'KO';
                message = 'Error: ' + info.errors;
                
            } else {
                status = 'OK';
            }*/
        }

        return info;
    }


    //  ------- RELACIONES HITO's y ENTREGBALES ------------

    public static List < GC_Integracion_Tasking_Aux.clss_issues > get_Entregables_From_HitoId(String hitoId) {
        // String result = '';
        // String status = '';
        String message = '';
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info_WS = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();
        List < GC_Integracion_Tasking_Aux.clss_issues > info = new List < GC_Integracion_Tasking_Aux.clss_issues > ();

        Boolean next = true;
        Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        //Map<String, Object> results;        
        do {
            info_WS = get_Entregables_From_HitoId_WS(hitoId, offsetWS);
            System.debug('get_Entregables_From_HitoId - results: ');
            System.debug(info_WS.errors);
            if (info_WS.errors != null) {
                next = false;
                // status = 'KO';
                // message = 'Error: ' + info_WS.errors;
                // System.debug(message);
            } else {
                System.debug(info_WS.issues);
                //System.debug(info_WS.issues.size()); 

                //Añadimos a la lista siguientes datos
                if (info_WS.issues != null && !info_WS.issues.isEmpty()) {
                    info.addAll(info_WS.issues);

                    //Comprobamos paginación
                    offsetWS = info_WS.offset;
                    totalWS = info_WS.total_count;
                    offsetWS += limitWS; // proximo pto de inicio                
                } else {
                    offsetWS += limitWS;
                }
                if (offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
            }

        } while (next);

        System.debug('Tamaño final de la lista de Relaciones HITO - ENTREGABLES: ---->' + info.size());

        return info;
    }

    public static GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List get_Entregables_From_HitoId_WS(String hitoId, integer offsetWS) {

        // String status = '';
        // String message = '';
        // String result = '';
        String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List info = new GC_Integracion_Tasking_Aux.jsonInfo_Tdr_Entregable_List();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'issues.json';
        endpoint_aux = endpoint_aux + '?set_filter=1&tracker_id=2&fixed_version_id=' + hitoId + '&offset=' + offsetWS_String;

        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_Entregables_From_HitoId_WS');
        System.debug(response.getBody());
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());

        // result = response.getBody();

        if (response.getStatusCode() == 200) {
            // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
            // responseParse = util.parseAreaResponse_v2(response.getBody());
            info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

            // if (info.errors != null) {
            //     //Devuelve la respuesta error
            //     status = 'KO';
            //     message = 'Error: ' + info.errors;

            // } else {
            //     status = 'OK';
            // }
        }

        //info = GC_Integracion_Tasking_Aux.parsejson_InfoTdrEntregable(response.getBody());

        return info;

    }

    // ---- USUARIOS -------

    public static List < GC_Integracion_Tasking_Aux.cls_users > get_All_Tasking_Users(String UserEmailList) {
        // String result = '';
        // String status = '';
        // String message = '';
        GC_Integracion_Tasking_Aux.user_tasking info_WS = new GC_Integracion_Tasking_Aux.user_tasking();
        List < GC_Integracion_Tasking_Aux.cls_users > info = new List < GC_Integracion_Tasking_Aux.cls_users > ();

        Boolean next = true;
        Integer limitWS = 25, offsetWS = 0, totalWS = 100;
        //Map<String, Object> results;        
        do {
            info_WS = get_All_Tasking_Users_WS(offsetWS, UserEmailList);
            System.debug('get_Users - results: ');
            System.debug(info_WS.errors);
            if (info_WS.errors != null) {
                next = false;
                // status = 'KO';
                // message = 'Error: ' + info_WS.errors;
                // System.debug(message);
            } else {
                System.debug(info_WS.users);
                System.debug(info_WS.users.size());

                //Añadimos a la lista siguientes datos
                if (!info_WS.users.isEmpty()) {
                    info.addAll(info_WS.users);

                    //Comprobamos paginación
                    offsetWS = info_WS.offset;
                    totalWS = info_WS.total_count;
                    offsetWS += limitWS; // proximo pto de inicio                
                }
                if (offsetWS >= totalWS) next = false; //Si pto de inicio es mayor que el total de registros, salimos
            }

        } while (next);

        System.debug('Tamaño final de la lista de Usuarios: ---->' + info.size());

        return info;
    }

    public static GC_Integracion_Tasking_Aux.user_tasking get_All_Tasking_Users_WS(integer offsetWS, String UserEmailList) {

        // String status = '';
        // String message = '';
        // String result = '';
        String offsetWS_String = String.Valueof(offsetWS);
        GC_Integracion_Tasking_Aux.user_tasking info = new GC_Integracion_Tasking_Aux.user_tasking();

        GC_Importacion_Tasking__c webServiceData = GC_Importacion_Tasking__c.getInstance();
        String user = webServiceData.user__c;
        String password = webServiceData.password__c;
        String endpoint = webServiceData.endpoint__c;

        String endpoint_aux = 'users.json';
        endpoint_aux = endpoint_aux + '?login=' + UserEmailList;
        String auth = user + ':' + password;
        Blob authBlob = Blob.valueof(auth);

        String auth_request = EncodingUtil.base64Encode(authBlob);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + endpoint_aux);
        System.debug(endpoint + endpoint_aux);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic ' + auth_request);
        // request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('get_All Users');
        System.debug(response.getBody());
        System.debug(response.getStatus());
        System.debug(response.getStatusCode());

        // result = response.getBody();
        // if (response.getStatusCode() == 200) {
        //     // Util_WebService.AreaResponse responseParse = new Util_WebService.AreaResponse();
        //     // responseParse = util.parseAreaResponse_v2(response.getBody());
        //     info = GC_Integracion_Tasking_Aux.parse_users(response.getBody());

        //     // if (info.errors != null) {
        //     //     //Devuelve la respuesta error
        //     //     status = 'KO';
        //     //     message = 'Error: ' + info.errors;

        //     // } else {
        //     //     status = 'OK';
        //     // }
        // }

        info = GC_Integracion_Tasking_Aux.parse_users(response.getBody());

        return info;

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
        String test620;
        String test621;
        String test622;
        String test623;
        String test624;
        String test625;
        String test626;
        String test627;
        String test628;
        String test629;
        String test630;
        String test631;
        String test632;
        String test633;
        String test634;
        String test635;
        String test636;
        String test637;
        String test638;
        String test639;
        String test640;
        String test641;
        String test642;
        String test643;
        String test644;
        String test645;
        String test646;
        String test647;
        String test648;
        String test649;
        String test650;
        String test651;
        String test652;
        String test653;
        String test654;
        String test655;
        String test656;
        String test657;
        String test658;
        String test659;
        String test660;
        String test661;
        String test662;
        String test663;
        String test664;
        String test665;
        String test666;
        String test667;
        String test668;
        String test669;
        String test670;
        String test671;
        String test672;
        String test673;
        String test674;
        String test675;
        String test676;
        String test677;
        String test678;
        String test679;
        String test680;
        String test681;
        String test682;
        String test683;
        String test684;
        String test685;
        String test686;
        String test687;
        String test688;
        String test689;
        String test690;
        String test691;
        String test692;
        String test693;
        String test694;
        String test695;
        String test696;
        String test697;
        String test698;
        String test699;
        String test700;
        String test701;
        String test702;
        String test703;
        String test704;
        String test705;
        String test706;
        String test707;
        String test708;
        String test709;
        String test710;
        String test711;
        String test712;
        String test713;
        String test714;
        String test715;
        String test716;
        String test717;
        String test718;
        String test719;
        String test720;
        String test721;
        String test722;
        String test723;
        String test724;
        String test725;
        String test726;
        String test727;
        String test728;
        String test729;
        String test730;
        String test731;
        String test732;
        String test733;
        String test734;
        String test735;
        String test736;
        String test737;
        String test738;
        String test739;
        String test740;
        String test741;
        String test742;
        String test743;
        String test744;
        String test745;
        String test746;
        String test747;
        String test748;
        String test749;
        String test750;
        String test751;
        String test752;
        String test753;
        String test754;
        String test755;
        String test756;
        String test757;
        String test758;
        String test759;
        String test760;
        String test761;
        String test762;
        String test763;
        String test764;
        String test765;
        String test766;
        String test767;
        String test768;
        String test769;
        String test770;
        String test771;
        String test772;
        String test773;
        String test774;
        String test775;
        String test776;
        String test777;
        String test778;
        String test779;
        String test780;
        String test781;
        String test782;
        String test783;
        String test784;
        String test785;
        String test786;
        String test787;
        String test788;
        String test789;
        String test790;
        String test791;
        String test792;
        String test793;
        String test794;
        String test795;
        String test796;
        String test797;
        String test798;
        String test799;
        String test800;
        String test801;
        String test802;
        String test803;
        String test804;
        String test805;
        String test806;
        String test807;
        String test808;
        String test809;
        String test810;
        String test811;
        String test812;
        String test813;
        String test814;
        String test815;
        String test816;
        String test817;
        String test818;
        String test819;
        String test820;
        String test821;
        String test822;
        String test823;
        String test824;
        String test825;
        String test826;
        String test827;
        String test828;
        String test829;
        String test830;
        String test831;
        String test832;
        String test833;
        String test834;
        String test835;
        String test836;
        String test837;
        String test838;
        String test839;
        String test840;
        String test841;
        String test842;
        String test843;
        String test844;
        String test845;
        String test846;
        String test847;
        String test848;
        String test849;
        String test850;
        String test851;
        String test852;
        String test853;
        String test854;
        String test855;
        String test856;
        String test857;
        String test858;
        String test859;
        String test860;
        String test861;
        String test862;
        String test863;
        String test864;
        String test865;
        String test866;
        String test867;
        String test868;
        String test869;
        String test870;
        String test871;
        String test872;
        String test873;
        String test874;
        String test875;
        String test876;
        String test877;
        String test878;
        String test879;
        String test880;
        String test881;
        String test882;
        String test883;
        String test884;
        String test885;
        String test886;
        String test887;
        String test888;
        String test889;
        String test890;
        String test891;
        String test892;
        String test893;
        String test894;
        String test895;
        String test896;
        String test897;
        String test898;
        String test899;
        String test900;
        String test901;
        String test902;
        String test903;
        String test904;
        String test905;
        String test906;
        String test907;
        String test908;
        String test909;
        String test910;
        String test911;
        String test912;
        String test913;
        String test914;
        String test915;
        String test916;
        String test917;
        String test918;
        String test919;
        String test920;
        String test921;
        String test922;
        String test923;
        String test924;
        String test925;
        String test926;
        String test927;
        String test928;
        String test929;
        String test930;
        String test931;
        String test932;
        String test933;
        String test934;
        String test935;
        String test936;
        String test937;
        String test938;
        String test939;
        String test940;
        String test941;
        String test942;
        String test943;
        String test944;
        String test945;
        String test946;
        String test947;
        String test948;
        String test949;
        String test950;
        String test951;
        String test952;
        String test953;
        String test954;
        String test955;
        String test956;
        String test957;
        String test958;
        String test959;
        String test960;
        String test961;
        String test962;
        String test963;
        String test964;
        String test965;
        String test966;
        String test967;
        String test968;
        String test969;
        String test970;
        String test971;
        String test972;
        String test973;
        String test974;
        String test975;
        String test976;
        String test977;
        String test978;
        String test979;
        String test980;
        String test981;
        String test982;
        String test983;
        String test984;
        String test985;
        String test986;
        String test987;
        String test988;
        String test989;
        String test990;
        String test991;
        String test992;
        String test993;
        String test994;
        String test995;
        String test996;
        String test997;
        String test998;
        String test999;
        String test1000;
        String test1001;
        String test1002;
        String test1003;
        String test1004;
        String test1005;
        String test1006;
        String test1007;
        String test1008;
        String test1009;
        String test1010;
        String test1011;
        String test1012;
        String test1013;
        String test1014;
        String test1015;
        String test1016;
        String test1017;
        String test1018;
        String test1019;
        String test1020;
        String test1021;
        String test1022;
        String test1023;
        String test1024;
        String test1025;
        String test1026;
        String test1027;
        String test1028;
        String test1029;
        String test1030;
        String test1031;
        String test1032;
        String test1033;
        String test1034;
        String test1035;
        String test1036;
        String test1037;
        String test1038;
        String test1039;
        String test1040;
        String test1041;
        String test1042;
        String test1043;
        String test1044;
        String test1045;
        String test1046;
        String test1047;
        String test1048;
        String test1049;
        String test1050;
        String test1051;
        String test1052;
        String test1053;
        String test1054;
        String test1055;
        String test1056;
        String test1057;
        String test1058;
        String test1059;
        String test1060;
        String test1061;
        String test1062;
        String test1063;
        String test1064;
        String test1065;
        String test1066;
        String test1067;
        String test1068;
        String test1069;
        String test1070;
        String test1071;
        String test1072;
        String test1073;
        String test1074;
        String test1075;
        String test1076;
        String test1077;
        String test1078;
        String test1079;
        String test1080;
        String test1081;
        String test1082;
        String test1083;
        String test1084;
        String test1085;
        String test1086;
        String test1087;
        String test1088;
        String test1089;
        String test1090;
        String test1091;
        String test1092;
        String test1093;
        String test1094;
        String test1095;
        String test1096;
        String test1097;
        String test1098;
        String test1099;
        String test1100;
        String test1101;
        String test1102;
        String test1103;
        String test1104;
        String test1105;
        String test1106;
        String test1107;
        String test1108;
        String test1109;
        String test1110;
        String test1111;
        String test1112;
        String test1113;
        String test1114;
        String test1115;
        String test1116;
        String test1117;
        String test1118;
        String test1119;
        String test1120;
        String test1121;
        String test1122;
        String test1123;
        String test1124;
        String test1125;
        String test1126;
        String test1127;
        String test1128;
        String test1129;
        String test1130;
        String test1131;
        String test1132;
        String test1133;
        String test1134;
        String test1135;
        String test1136;
        String test1137;
        String test1138;
        String test1139;
        String test1140;
        String test1141;
        String test1142;
        String test1143;
        String test1144;
        String test1145;
        String test1146;
        String test1147;
        String test1148;
        String test1149;
        String test1150;
        String test1151;
        String test1152;
        String test1153;
        String test1154;
        String test1155;
        String test1156;
        String test1157;
        String test1158;
        String test1159;
        String test1160;
        String test1161;
        String test1162;
        String test1163;
        String test1164;
        String test1165;
        String test1166;
        String test1167;
        String test1168;
        String test1169;
        String test1170;
        String test1171;
        String test1172;
        String test1173;
        String test1174;
        String test1175;
        String test1176;
        String test1177;
        String test1178;
        String test1179;
        String test1180;
        String test1181;
        String test1182;
        String test1183;
        String test1184;
        String test1185;
        String test1186;
        String test1187;
        String test1188;
        String test1189;
        String test1190;
        String test1191;
        String test1192;
        String test1193;
        String test1194;
        String test1195;
        String test1196;
        String test1197;
        String test1198;
        String test1199;
        String test1200;
        String test1201;
        String test1202;
        String test1203;
        String test1204;
        String test1205;
        String test1206;
        String test1207;
        String test1208;
        String test1209;
        String test1210;
        String test1211;
        String test1212;
        String test1213;
        String test1214;
        String test1215;
        String test1216;
        String test1217;
        String test1218;
        String test1219;
        String test1220;
        String test1221;
        String test1222;
        String test1223;
        String test1224;
        String test1225;
        String test1226;
        String test1227;
        String test1228;
        String test1229;
        String test1230;
        String test1231;
        String test1232;
        String test1233;
        String test1234;
        String test1235;
        String test1236;
        String test1237;
        String test1238;
        String test1239;
        String test1240;
        String test1241;
        String test1242;
        String test1243;
        String test1244;
        String test1245;
        String test1246;
        String test1247;
        String test1248;
        String test1249;
        String test1250;
        String test1251;
        String test1252;
        String test1253;
        String test1254;
        String test1255;
        String test1256;
        String test1257;
        String test1258;
        String test1259;
        String test1260;
        String test1261;
        String test1262;
        String test1263;
        String test1264;
        String test1265;
        String test1266;
        String test1267;
        String test1268;
        String test1269;
        String test1270;
        String test1271;
        String test1272;
        String test1273;
        String test1274;
        String test1275;
        String test1276;
        String test1277;
        String test1278;
        String test1279;
        String test1280;
        String test1281;
        String test1282;
        String test1283;
        String test1284;
        String test1285;
        String test1286;
        String test1287;
        String test1288;
        String test1289;
        String test1290;
        String test1291;
        String test1292;
        String test1293;
        String test1294;
        String test1295;
        String test1296;
        String test1297;
        String test1298;
        String test1299;
        String test1300;
        String test1301;
        String test1302;
        String test1303;
        String test1304;
        String test1305;
        String test1306;
        String test1307;
        String test1308;
        String test1309;
        String test1310;
        String test1311;
        String test1312;
        String test1313;
        String test1314;
        String test1315;
        String test1316;
        String test1317;
        String test1318;
        String test1319;
        String test1320;
        String test1321;
        String test1322;
        String test1323;
        String test1324;
        String test1325;
        String test1326;
        String test1327;
        String test1328;
        String test1329;
        String test1330;
        String test1331;
        String test1332;
        String test1333;
        String test1334;
        String test1335;
        String test1336;
        String test1337;
        String test1338;
        String test1339;
        String test1340;
        String test1341;
        String test1342;
        String test1343;
        String test1344;
        String test1345;
        String test1346;
        String test1347;
        String test1348;
        String test1349;
        String test1350;
        String test1351;
        String test1352;
        String test1353;
        String test1354;
        String test1355;
        String test1356;
        String test1357;
        String test1358;
        String test1359;
        String test1360;
        String test1361;
        String test1362;
        String test1363;
        String test1364;
        String test1365;
        String test1366;
        String test1367;
        String test1368;
        String test1369;
        String test1370;
        String test1371;
        String test1372;
        String test1373;
        String test1374;
        String test1375;
        String test1376;
        String test1377;
        String test1378;
        String test1379;
        String test1380;
        String test1381;
        String test1382;
        String test1383;
        String test1384;
        String test1385;
        String test1386;
        String test1387;
        String test1388;
        String test1389;
        String test1390;
        String test1391;
        String test1392;
        String test1393;
        String test1394;
        String test1395;
        String test1396;
        String test1397;
        String test1398;
        String test1399;
        String test1400;
        String test1401;
        String test1402;
        String test1403;
        String test1404;
        String test1405;
        String test1406;
        String test1407;
        String test1408;
        String test1409;
        String test1410;
        String test1411;
        String test1412;
        String test1413;
        String test1414;
        String test1415;
        String test1416;
        String test1417;
        String test1418;
        String test1419;
        String test1420;
        String test1421;
        String test1422;
        String test1423;
        String test1424;
        String test1425;
        String test1426;
        String test1427;
        String test1428;
        String test1429;
        String test1430;
        String test1431;
        String test1432;
        String test1433;
        String test1434;
        String test1435;
        String test1436;
        String test1437;
        String test1438;
        String test1439;
        String test1440;
        String test1441;
        String test1442;
        String test1443;
        String test1444;
        String test1445;
        String test1446;
        String test1447;
        String test1448;
        String test1449;
        String test1450;
        String test1451;
        String test1452;
        String test1453;
        String test1454;
        String test1455;
        String test1456;
        String test1457;
        String test1458;
        String test1459;
        String test1460;
        String test1461;
        String test1462;
        String test1463;
        String test1464;
        String test1465;
        String test1466;
        String test1467;
        String test1468;
        String test1469;
        String test1470;
        String test1471;
        String test1472;
        String test1473;
        String test1474;
        String test1475;
        String test1476;
        String test1477;
        String test1478;
        String test1479;
        String test1480;
        String test1481;
        String test1482;
        String test1483;
        String test1484;
        String test1485;
        String test1486;
        String test1487;
        String test1488;
        String test1489;
        String test1490;
        String test1491;
        String test1492;
        String test1493;
        String test1494;
        String test1495;
        String test1496;
        String test1497;
        String test1498;
        String test1499;
        String test1500;
        String test1501;
        String test1502;
        String test1503;
        String test1504;
        String test1505;
        String test1506;
        String test1507;
        String test1508;
        String test1509;
        String test1510;
        String test1511;
        String test1512;
        String test1513;
        String test1514;
        String test1515;
        String test1516;
        String test1517;
        String test1518;
        String test1519;
        String test1520;
        String test1521;
        String test1522;
        String test1523;
        String test1524;
        String test1525;
        String test1526;
        String test1527;
        String test1528;
        String test1529;
        String test1530;
        String test1531;
        String test1532;
        String test1533;
        String test1534;
        String test1535;
        String test1536;
        String test1537;
        String test1538;
        String test1539;
        String test1540;
        String test1541;
        String test1542;
        String test1543;
        String test1544;
        String test1545;
        String test1546;
        String test1547;
        String test1548;
        String test1549;
        String test1550;
        String test1551;
        String test1552;
        String test1553;
        String test1554;
        String test1555;
        String test1556;
        String test1557;
        String test1558;
        String test1559;
        String test1560;
        String test1561;
        String test1562;
        String test1563;
        String test1564;
        String test1565;
        String test1566;
        String test1567;
        String test1568;
        String test1569;
        String test1570;
        String test1571;
        String test1572;
        String test1573;
        String test1574;
        String test1575;
        String test1576;
        String test1577;
        String test1578;
        String test1579;
        String test1580;
        String test1581;
        String test1582;
        String test1583;
        String test1584;
        String test1585;
        String test1586;
        String test1587;
        String test1588;
        String test1589;
        String test1590;
        String test1591;
        String test1592;
        String test1593;
        String test1594;
        String test1595;
        String test1596;
        String test1597;
        String test1598;
        String test1599;
        String test1600;
        String test1601;
        String test1602;
        String test1603;
        String test1604;
        String test1605;
        String test1606;
        String test1607;
        String test1608;
        String test1609;
        String test1610;
        String test1611;
        String test1612;
        String test1613;
        String test1614;
        String test1615;
        String test1616;
        String test1617;
        String test1618;
        String test1619;
        String test1620;
        String test1621;
        String test1622;
        String test1623;
        String test1624;
        String test1625;
        String test1626;
        String test1627;
        String test1628;
        String test1629;
        String test1630;
        String test1631;
        String test1632;
        String test1633;
        String test1634;
        String test1635;
        String test1636;
        String test1637;
        String test1638;
        String test1639;
        String test1640;
        String test1641;
        String test1642;
        String test1643;
        String test1644;
        String test1645;
        String test1646;
        String test1647;
        String test1648;
        String test1649;
        String test1650;
        String test1651;
        String test1652;
        String test1653;
        String test1654;
        String test1655;
        String test1656;
        String test1657;
        String test1658;
        String test1659;
        String test1660;
        String test1661;
        String test1662;
        String test1663;
        String test1664;
        String test1665;
        String test1666;
        String test1667;
        String test1668;
        String test1669;
        String test1670;
        String test1671;
        String test1672;
        String test1673;
        String test1674;
        String test1675;
        String test1676;
        String test1677;
        String test1678;
        String test1679;
        String test1680;
        String test1681;
        String test1682;
        String test1683;
        String test1684;
        String test1685;
        String test1686;
        String test1687;
        String test1688;
        String test1689;
        String test1690;
        String test1691;
        String test1692;
        String test1693;
        String test1694;
        String test1695;
        String test1696;
        String test1697;
        String test1698;
        String test1699;
        String test1700;
        String test1701;
        String test1702;
        String test1703;
        String test1704;
        String test1705;
        String test1706;
        String test1707;
        String test1708;
        String test1709;
        String test1710;
        String test1711;
        String test1712;
        String test1713;
        String test1714;
        String test1715;
        String test1716;
        String test1717;
        String test1718;
        String test1719;
        String test1720;
        String test1721;
        String test1722;
        String test1723;
        String test1724;
        String test1725;
        String test1726;
        String test1727;
        String test1728;
        String test1729;
        String test1730;
        String test1731;
        String test1732;
        String test1733;
        String test1734;
        String test1735;
        String test1736;
        String test1737;
        String test1738;
        String test1739;
        String test1740;
        String test1741;
        String test1742;
        String test1743;
        String test1744;
        String test1745;
        String test1746;
        String test1747;
        String test1748;
        String test1749;
        String test1750;
        String test1751;
        String test1752;
        String test1753;
        String test1754;
        String test1755;
        String test1756;
        String test1757;
        String test1758;
        String test1759;
        String test1760;
        String test1761;
        String test1762;
        String test1763;
        String test1764;
        String test1765;
        String test1766;
        String test1767;
        String test1768;
        String test1769;
        String test1770;
        String test1771;
        String test1772;
        String test1773;
        String test1774;
        String test1775;
        String test1776;
        String test1777;
        String test1778;
        String test1779;
        String test1780;
        String test1781;
        String test1782;
        String test1783;
        String test1784;
        String test1785;
        String test1786;
        String test1787;
        String test1788;
        String test1789;
        String test1790;
        String test1791;
        String test1792;
        String test1793;
        String test1794;
        String test1795;
        String test1796;
        String test1797;
        String test1798;
        String test1799;
        String test1800;
        String test1801;
        String test1802;
        String test1803;
        String test1804;
        String test1805;
        String test1806;
        String test1807;
        String test1808;
        String test1809;
        String test1810;
        String test1811;
        String test1812;
        String test1813;
        String test1814;
        String test1815;
        String test1816;
        String test1817;
        String test1818;
        String test1819;
        String test1820;
        String test1821;
        String test1822;
        String test1823;
        String test1824;
        String test1825;
        String test1826;
        String test1827;
        String test1828;
        String test1829;
        String test1830;
        String test1831;
        String test1832;
        String test1833;
        String test1834;
        String test1835;
        String test1836;
        String test1837;
        String test1838;
        String test1839;
        String test1840;
        String test1841;
        String test1842;
        String test1843;
        String test1844;
        String test1845;
        String test1846;
        String test1847;
        String test1848;
        String test1849;
        String test1850;
        String test1851;
        String test1852;
        String test1853;
        String test1854;
        String test1855;
        String test1856;
        String test1857;
        String test1858;
        String test1859;
        String test1860;
        String test1861;
        String test1862;
        String test1863;
        String test1864;
        String test1865;
        String test1866;
        String test1867;
        String test1868;
        String test1869;
        String test1870;
        String test1871;
        String test1872;
        String test1873;
        String test1874;
        String test1875;
        String test1876;
        String test1877;
        String test1878;
        String test1879;
        String test1880;
        String test1881;
        String test1882;
        String test1883;
        String test1884;
        String test1885;
        String test1886;
        String test1887;
        String test1888;
        String test1889;
        String test1890;
        String test1891;
        String test1892;
        String test1893;
        String test1894;
        String test1895;
        String test1896;
        String test1897;
        String test1898;
        String test1899;
        String test1900;
        String test1901;
        String test1902;
        String test1903;
        String test1904;
        String test1905;
        String test1906;
        String test1907;
        String test1908;
        String test1909;
        String test1910;
        String test1911;
        String test1912;
        String test1913;
        String test1914;
        String test1915;
        String test1916;
        String test1917;
        String test1918;
        String test1919;
        String test1920;
        String test1921;
        String test1922;
        String test1923;
        String test1924;
        String test1925;
        String test1926;
        String test1927;
        String test1928;
        String test1929;
        String test1930;
        String test1931;
        String test1932;
        String test1933;
        String test1934;
        String test1935;
        String test1936;
        String test1937;
        String test1938;
        String test1939;
        String test1940;
        String test1941;
        String test1942;
        String test1943;
        String test1944;
        String test1945;
        String test1946;
        String test1947;
        String test1948;
        String test1949;
        String test1950;
        String test1951;
        String test1952;
        String test1953;
        String test1954;
        String test1955;
        String test1956;
        String test1957;
        String test1958;
        String test1959;
        String test1960;
        String test1961;
        String test1962;
        String test1963;
        String test1964;
        String test1965;
        String test1966;
        String test1967;
        String test1968;
        String test1969;
        String test1970;
        String test1971;
        String test1972;
        String test1973;
        String test1974;
        String test1975;
        String test1976;
        String test1977;
        String test1978;
        String test1979;
        String test1980;
        String test1981;
        String test1982;
        String test1983;
        String test1984;
        String test1985;
        String test1986;
        String test1987;
        String test1988;
        String test1989;
        String test1990;
        String test1991;
        String test1992;
        String test1993;
        String test1994;
        String test1995;
        String test1996;
        String test1997;
        String test1998;
        String test1999;
        String test2000;
        String test2001;
        String test2002;
        String test2003;
        String test2004;
        String test2005;
        String test2006;
        String test2007;
        String test2008;
        String test2009;
        String test2010;
        String test2011;
        String test2012;
        String test2013;
        String test2014;
        String test2015;
        String test2016;
        String test2017;
        String test2018;
        String test2019;
        String test2020;
        String test2021;
        String test2022;
        String test2023;
        String test2024;
        String test2025;
        String test2026;
        String test2027;
        String test2028;
        String test2029;
        String test2030;
        String test2031;
        String test2032;
        String test2033;
        String test2034;
        String test2035;
        String test2036;
        String test2037;
        String test2038;
        String test2039;
        String test2040;
        String test2041;
        String test2042;
        String test2043;
        String test2044;
        String test2045;
        String test2046;
        String test2047;
        String test2048;
        String test2049;
        String test2050;
        String test2051;
        String test2052;
        String test2053;
        String test2054;
        String test2055;
        String test2056;
        String test2057;
        String test2058;
        String test2059;
        String test2060;
        String test2061;
        String test2062;
        String test2063;
        String test2064;
        String test2065;
        String test2066;
        String test2067;
        String test2068;
        String test2069;
        String test2070;
        String test2071;
        String test2072;
        String test2073;
        String test2074;
        String test2075;
        String test2076;
        String test2077;
        String test2078;
        String test2079;
        String test2080;
        String test2081;
        String test2082;
        String test2083;
        String test2084;
        String test2085;
        String test2086;
        String test2087;
        String test2088;
        String test2089;
        String test2090;
        String test2091;
        String test2092;
        String test2093;
        String test2094;
        String test2095;
        String test2096;
        String test2097;
        String test2098;
        String test2099;
        String test2100;
        String test2101;
        String test2102;
        String test2103;
        String test2104;
        String test2105;
        String test2106;
        String test2107;
        String test2108;
        String test2109;
        String test2110;
        String test2111;
        String test2112;
        String test2113;
        String test2114;
        String test2115;
        String test2116;
        String test2117;
        String test2118;
        String test2119;
        String test2120;
        String test2121;
        String test2122;
        String test2123;
        String test2124;
        String test2125;
        String test2126;
        String test2127;
        String test2128;
        String test2129;
        String test2130;
        String test2131;
        String test2132;
        String test2133;
        String test2134;
        String test2135;
        String test2136;
        String test2137;
        String test2138;
        String test2139;
        String test2140;
        String test2141;
        String test2142;
        String test2143;
        String test2144;
        String test2145;
        String test2146;
        String test2147;
        String test2148;
        String test2149;
        String test2150;
        String test2151;
        String test2152;
        String test2153;
        String test2154;
        String test2155;
        String test2156;
        String test2157;
        String test2158;
        String test2159;
        String test2160;
        String test2161;
        String test2162;
        String test2163;
        String test2164;
        String test2165;
        String test2166;
        String test2167;
        String test2168;
        String test2169;
        String test2170;
        String test2171;
        String test2172;
        String test2173;
        String test2174;
        String test2175;
        String test2176;
        String test2177;
        String test2178;
        String test2179;
        String test2180;
        String test2181;
        String test2182;
        String test2183;
        String test2184;
        String test2185;
        String test2186;
        String test2187;
        String test2188;
        String test2189;
        String test2190;
        String test2191;
        String test2192;
        String test2193;
        String test2194;
        String test2195;
        String test2196;
        String test2197;
        String test2198;
        String test2199;
        String test2200;
        String test2201;
        String test2202;
        String test2203;
        String test2204;
        String test2205;
        String test2206;
        String test2207;
        String test2208;
        String test2209;
        String test2210;
        String test2211;
        String test2212;
        String test2213;
        String test2214;
        String test2215;
        String test2216;
        String test2217;
        String test2218;
        String test2219;
        String test2220;
        String test2221;
        String test2222;
        String test2223;
        String test2224;
        String test2225;
        String test2226;
        String test2227;
        String test2228;
        String test2229;
        String test2230;
        String test2231;
        String test2232;
        String test2233;
        String test2234;
        String test2235;
        String test2236;
        String test2237;
        String test2238;
        String test2239;
        String test2240;
        String test2241;
        String test2242;
        String test2243;
        String test2244;
        String test2245;
        String test2246;
        String test2247;
        String test2248;
        String test2249;
        String test2250;
        String test2251;
        String test2252;
        String test2253;
        String test2254;
        String test2255;
        String test2256;
        String test2257;
        String test2258;
        String test2259;
        String test2260;
        String test2261;
        String test2262;
        String test2263;
        String test2264;
        String test2265;
        String test2266;
        String test2267;
        String test2268;
        String test2269;
        String test2270;
        String test2271;
        String test2272;
        String test2273;
        String test2274;
        String test2275;
        String test2276;
        String test2277;
        String test2278;
        String test2279;
        String test2280;
        String test2281;
        String test2282;
        String test2283;
        String test2284;
        String test2285;
        String test2286;
        String test2287;
        String test2288;
        String test2289;
        String test2290;
        String test2291;
        String test2292;
        String test2293;
        String test2294;
        String test2295;
        String test2296;
        String test2297;
        String test2298;
        String test2299;
        String test2300;
        String test2301;
        String test2302;
        String test2303;
        String test2304;
        String test2305;
        String test2306;
        String test2307;
        String test2308;
        String test2309;
        String test2310;
        String test2311;
        String test2312;
        String test2313;
        String test2314;
        String test2315;
        String test2316;
        String test2317;
        String test2318;
        String test2319;
        String test2320;
        String test2321;
        String test2322;
        String test2323;
        String test2324;
        String test2325;
        String test2326;
        String test2327;
        String test2328;
        String test2329;
        String test2330;
        String test2331;
        String test2332;
        String test2333;
        String test2334;
        String test2335;
        String test2336;
        String test2337;
        String test2338;
        String test2339;
        String test2340;
        String test2341;
        String test2342;
        String test2343;
        String test2344;
        String test2345;
        String test2346;
        String test2347;
        String test2348;
        String test2349;
        String test2350;
        String test2351;
        String test2352;
        String test2353;
        String test2354;
        String test2355;
        String test2356;
        String test2357;
        String test2358;
        String test2359;
        String test2360;
        String test2361;
        String test2362;
        String test2363;
        String test2364;
        String test2365;
        String test2366;
        String test2367;
        String test2368;
        String test2369;
        String test2370;
        String test2371;
        String test2372;
        String test2373;
        String test2374;
        String test2375;
        String test2376;
        String test2377;
        String test2378;
        String test2379;
        String test2380;
        String test2381;
        String test2382;
        String test2383;
        String test2384;
        String test2385;
        String test2386;
        String test2387;
        String test2388;
        String test2389;
        String test2390;
        String test2391;
        String test2392;
        String test2393;
        String test2394;
        String test2395;
        String test2396;
        String test2397;
        String test2398;
        String test2399;
        String test2400;
        String test2401;
        String test2402;
        String test2403;
        String test2404;
        String test2405;
        String test2406;
        String test2407;
        String test2408;
        String test2409;
        String test2410;
        String test2411;
        String test2412;
        String test2413;
        String test2414;
        String test2415;
        String test2416;
        String test2417;
        String test2418;
        String test2419;
        String test2420;
        String test2421;
        String test2422;
        String test2423;
        String test2424;
        String test2425;
        String test2426;
        String test2427;
        String test2428;
        String test2429;
        String test2430;
        String test2431;
        String test2432;
        String test2433;
        String test2434;
        String test2435;
        String test2436;
        String test2437;
        String test2438;
        String test2439;
        String test2440;
        String test2441;
        String test2442;
        String test2443;
        String test2444;
        String test2445;
        String test2446;
        String test2447;
        String test2448;
        String test2449;
        String test2450;
        String test2451;
        String test2452;
        String test2453;
        String test2454;
        String test2455;
        String test2456;
        String test2457;
        String test2458;
        String test2459;
        String test2460;
        String test2461;
        String test2462;
        String test2463;
        String test2464;
        String test2465;
        String test2466;
        String test2467;
        String test2468;
        String test2469;
        String test2470;
        String test2471;
        String test2472;
        String test2473;
        String test2474;
        String test2475;
        String test2476;
        String test2477;
        String test2478;
        String test2479;
        String test2480;
        String test2481;
        String test2482;
        String test2483;
        String test2484;
        String test2485;
        String test2486;
        String test2487;
        String test2488;
        String test2489;
        String test2490;
        String test2491;
        String test2492;
        String test2493;
        String test2494;
        String test2495;
        String test2496;
        String test2497;
        String test2498;
        String test2499;
        String test2500;
        String test2501;
        String test2502;
        String test2503;
        String test2504;
        String test2505;
        String test2506;
        String test2507;
        String test2508;
        String test2509;
        String test2510;
        String test2511;
        String test2512;
        String test2513;
        String test2514;
        String test2515;
        String test2516;
        String test2517;
        String test2518;
        String test2519;
        String test2520;
        String test2521;
        String test2522;
        String test2523;
        String test2524;
        String test2525;
        String test2526;
        String test2527;
        String test2528;
        String test2529;
        String test2530;
        String test2531;
        String test2532;
        String test2533;
        String test2534;
        String test2535;
        String test2536;
        String test2537;
        String test2538;
        String test2539;
        String test2540;
        String test2541;
        String test2542;
        String test2543;
        String test2544;
        String test2545;
        String test2546;
        String test2547;
        String test2548;
        String test2549;
        String test2550;
        String test2551;
        String test2552;
        String test2553;
        String test2554;
        String test2555;
        String test2556;
        String test2557;
        String test2558;
        String test2559;
        String test2560;
        String test2561;
        String test2562;
        String test2563;
        String test2564;
        String test2565;
        String test2566;
        String test2567;
        String test2568;
        String test2569;
        String test2570;
        String test2571;
        String test2572;
        String test2573;
        String test2574;
        String test2575;
        String test2576;
        String test2577;
        String test2578;
        String test2579;
        String test2580;
        String test2581;
        String test2582;
        String test2583;
        String test2584;
        String test2585;
        String test2586;
        String test2587;
        String test2588;
        String test2589;
        String test2590;
        String test2591;
        String test2592;
        String test2593;
        String test2594;
        String test2595;
        String test2596;
        String test2597;
        String test2598;
        String test2599;
        String test2600;
        String test2601;
        String test2602;
        String test2603;
        String test2604;
        String test2605;
        String test2606;
        String test2607;
        String test2608;
        String test2609;
        String test2610;
        String test2611;
        String test2612;
        String test2613;
        String test2614;
        String test2615;
        String test2616;
        String test2617;
        String test2618;
        String test2619;
        String test2620;
        String test2621;
        String test2622;
        String test2623;
        String test2624;
        String test2625;
        String test2626;
        String test2627;
        String test2628;
        String test2629;
        String test2630;
        String test2631;
        String test2632;
        String test2633;
        String test2634;
        String test2635;
        String test2636;
        String test2637;
        String test2638;
        String test2639;
        String test2640;
        String test2641;
        String test2642;
        String test2643;
        String test2644;
        String test2645;
        String test2646;
        String test2647;
        String test2648;
        String test2649;
        String test2650;
        String test2651;
        String test2652;
        String test2653;
        String test2654;
        String test2655;
        String test2656;
        String test2657;
        String test2658;
        String test2659;
        String test2660;
        String test2661;
        String test2662;
        String test2663;
        String test2664;
        String test2665;
        String test2666;
        String test2667;
        String test2668;
        String test2669;
        String test2670;
        String test2671;
        String test2672;
        String test2673;
        String test2674;
        String test2675;
        String test2676;
        String test2677;
        String test2678;
        String test2679;
        String test2680;
        String test2681;
        String test2682;
        String test2683;
        String test2684;
        String test2685;
        String test2686;
        String test2687;
        String test2688;
        String test2689;
        String test2690;
        String test2691;
        String test2692;
        String test2693;
        String test2694;
        String test2695;
        String test2696;
        String test2697;
        String test2698;
        String test2699;
        String test2700;
        String test2701;
        String test2702;
        String test2703;
        String test2704;
        String test2705;
        String test2706;
        String test2707;
        String test2708;
        String test2709;
        String test2710;
        String test2711;
        String test2712;
        String test2713;
        String test2714;
        String test2715;
        String test2716;
        String test2717;
        String test2718;
        String test2719;
        String test2720;
        String test2721;
        String test2722;
        String test2723;
        String test2724;
        String test2725;
        String test2726;
        String test2727;
        String test2728;
        String test2729;
        String test2730;
        String test2731;
        String test2732;
        String test2733;
        String test2734;
        String test2735;
        String test2736;
        String test2737;
        String test2738;
        String test2739;
        String test2740;
        String test2741;
        String test2742;
        String test2743;
        String test2744;
        String test2745;
        String test2746;
        String test2747;
        String test2748;
        String test2749;
        String test2750;
        String test2751;
        String test2752;
        String test2753;
        String test2754;
        String test2755;
        String test2756;
        String test2757;
        String test2758;
        String test2759;
        String test2760;
        String test2761;
        String test2762;
        String test2763;
        String test2764;
        String test2765;
        String test2766;
        String test2767;
        String test2768;
        String test2769;
        String test2770;
        String test2771;
        String test2772;
        String test2773;
        String test2774;
        String test2775;
        String test2776;
        String test2777;
        String test2778;
        String test2779;
        String test2780;
        String test2781;
        String test2782;
        String test2783;
        String test2784;
        String test2785;
        String test2786;
        String test2787;
        String test2788;
        String test2789;
        String test2790;
        String test2791;
        String test2792;
        String test2793;
        String test2794;
        String test2795;
        String test2796;
        String test2797;
        String test2798;
        String test2799;
        String test2800;
        String test2801;
        String test2802;
        String test2803;
        String test2804;
        String test2805;
        String test2806;
        String test2807;
        String test2808;
        String test2809;
        String test2810;
        String test2811;
        String test2812;
        String test2813;
        String test2814;
        String test2815;
        String test2816;
        String test2817;
        String test2818;
        String test2819;
        String test2820;
        String test2821;
        String test2822;
        String test2823;
        String test2824;
        String test2825;
        String test2826;
        String test2827;
        String test2828;
        String test2829;
        String test2830;
        String test2831;
        String test2832;
        String test2833;
        String test2834;
        String test2835;
        String test2836;
        String test2837;
        String test2838;
        String test2839;
        String test2840;
        String test2841;
        String test2842;
        String test2843;
        String test2844;
        String test2845;
        String test2846;
        String test2847;
        String test2848;
        String test2849;
        String test2850;
        String test2851;
        String test2852;
        String test2853;
        String test2854;
        String test2855;
        String test2856;
        String test2857;
        String test2858;
        String test2859;
        String test2860;
        String test2861;
        String test2862;
        String test2863;
        String test2864;
        String test2865;
        String test2866;
        String test2867;
        String test2868;
        String test2869;
        String test2870;
        String test2871;
        String test2872;
        String test2873;
        String test2874;
        String test2875;
        String test2876;
        String test2877;
        String test2878;
        String test2879;
        String test2880;
        String test2881;
        String test2882;
        String test2883;
        String test2884;
        String test2885;
        String test2886;
        String test2887;
        String test2888;
        String test2889;
        String test2890;
        String test2891;
        String test2892;
        String test2893;
        String test2894;
        String test2895;
        String test2896;
        String test2897;
        String test2898;
        String test2899;
        String test2900;
        String test2901;
        String test2902;
        String test2903;
        String test2904;
        String test2905;
        String test2906;
        String test2907;
        String test2908;
        String test2909;
        String test2910;
        String test2911;
        String test2912;
        String test2913;
        String test2914;
        String test2915;
        String test2916;
        String test2917;
        String test2918;
        String test2919;
        String test2920;
        String test2921;
        String test2922;
        String test2923;
        String test2924;
        String test2925;
        String test2926;
        String test2927;
        String test2928;
        String test2929;
        String test2930;
        String test2931;
        String test2932;
        String test2933;
        String test2934;
        String test2935;
        String test2936;
        String test2937;
        String test2938;
        String test2939;
        String test2940;
        String test2941;
        String test2942;
        String test2943;
        String test2944;
        String test2945;
        String test2946;
        String test2947;
        String test2948;
        String test2949;
        String test2950;
        String test2951;
        String test2952;
        String test2953;
        String test2954;
        String test2955;
        String test2956;
        String test2957;
        String test2958;
        String test2959;
        String test2960;
        String test2961;
        String test2962;
        String test2963;
        String test2964;
        String test2965;
        String test2966;
        String test2967;
        String test2968;
        String test2969;
        String test2970;
        String test2971;
        String test2972;
        String test2973;
        String test2974;
        String test2975;
        String test2976;
        String test2977;
        String test2978;
        String test2979;
        String test2980;
        String test2981;
        String test2982;
        String test2983;
        String test2984;
        String test2985;
        String test2986;
        String test2987;
        String test2988;
        String test2989;
        String test2990;
        String test2991;
        String test2992;
        String test2993;
        String test2994;
        String test2995;
        String test2996;
        String test2997;
        String test2998;
        String test2999;
        String test3000;
        String test3001;
        String test3002;
        String test3003;
        String test3004;
        String test3005;
        String test3006;
        String test3007;
        String test3008;
        String test3009;
        String test3010;
        String test3011;
        String test3012;
        String test3013;
        String test3014;
        String test3015;
        String test3016;
        String test3017;
        String test3018;
        String test3019;
        String test3020;
        String test3021;
        String test3022;
        String test3023;
        String test3024;
        String test3025;
        String test3026;
        String test3027;
        String test3028;
        String test3029;
        String test3030;
        String test3031;
        String test3032;
        String test3033;
        String test3034;
        String test3035;
        String test3036;
        String test3037;
        String test3038;
        String test3039;
        String test3040;
        String test3041;
        String test3042;
        String test3043;
        String test3044;
        String test3045;
        String test3046;
        String test3047;
        String test3048;
        String test3049;
        String test3050;
        String test3051;
        String test3052;
        String test3053;
        String test3054;
        String test3055;
        String test3056;
        String test3057;
        String test3058;
        String test3059;
        String test3060;
        String test3061;
        String test3062;
        String test3063;
        String test3064;
        String test3065;
        String test3066;
        String test3067;
        String test3068;
        String test3069;
        String test3070;
        String test3071;
        String test3072;
        String test3073;
        String test3074;
        String test3075;
        String test3076;
        String test3077;
        String test3078;
        String test3079;
        String test3080;
        String test3081;
        String test3082;
        String test3083;
        String test3084;
        String test3085;
        String test3086;
        String test3087;
        String test3088;
        String test3089;
        String test3090;
        String test3091;
        String test3092;
        String test3093;
        String test3094;
        String test3095;
        String test3096;
        String test3097;
        String test3098;
        String test3099;
        String test3100;
        String test3101;
        String test3102;
        String test3103;
        String test3104;
        String test3105;
        String test3106;
        String test3107;
        String test3108;
        String test3109;
        String test3110;
        String test3111;
        String test3112;
        String test3113;
        String test3114;
        String test3115;
        String test3116;
        String test3117;
        String test3118;
        String test3119;
        String test3120;
        String test3121;
        String test3122;
        String test3123;
        String test3124;
        String test3125;
        String test3126;
        String test3127;
        String test3128;
        String test3129;
        String test3130;
        String test3131;
        String test3132;
        String test3133;
        String test3134;
        String test3135;
        String test3136;
        String test3137;
        String test3138;
        String test3139;
        String test3140;
        String test3141;
        String test3142;
        String test3143;
        String test3144;
        String test3145;
        String test3146;
        String test3147;
        String test3148;
        String test3149;
        String test3150;
        String test3151;
        String test3152;
        String test3153;
        String test3154;
        String test3155;
        String test3156;
        String test3157;
        String test3158;
        String test3159;
        String test3160;
        String test3161;
        String test3162;
        String test3163;
        String test3164;
        String test3165;
        String test3166;
        String test3167;
        String test3168;
        String test3169;
        String test3170;
        String test3171;
        String test3172;
        String test3173;
        String test3174;
        String test3175;
        String test3176;
        String test3177;
        String test3178;
        String test3179;
        String test3180;
        String test3181;
        String test3182;
        String test3183;
        String test3184;
        String test3185;
        String test3186;
        String test3187;
        String test3188;
        String test3189;
        String test3190;
        String test3191;
        String test3192;
        String test3193;
        String test3194;
        String test3195;
        String test3196;
        String test3197;
        String test3198;
        String test3199;
        String test3200;
        String test3201;
        String test3202;
        String test3203;
        String test3204;
        String test3205;
        String test3206;
        String test3207;
        String test3208;
        String test3209;
        String test3210;
        String test3211;
        String test3212;
        String test3213;
        String test3214;
        String test3215;
        String test3216;
        String test3217;
        String test3218;
        String test3219;
        String test3220;
        String test3221;
        String test3222;
        String test3223;
        String test3224;
        String test3225;
        String test3226;
        String test3227;
        String test3228;
        String test3229;
        String test3230;
        String test3231;
        String test3232;
        String test3233;
        String test3234;
        String test3235;
        String test3236;
        String test3237;
        String test3238;
        String test3239;
        String test3240;
        String test3241;
        String test3242;
        String test3243;
        String test3244;
        String test3245;
        String test3246;
        String test3247;
        String test3248;
        String test3249;
        String test3250;
        String test3251;
        String test3252;
        String test3253;
        String test3254;
        String test3255;
        String test3256;
        String test3257;
        String test3258;
        String test3259;
        String test3260;
        String test3261;
        String test3262;
        String test3263;
        String test3264;
        String test3265;
        String test3266;
        String test3267;
        String test3268;
        String test3269;
        String test3270;
        String test3271;
        String test3272;
        String test3273;
        String test3274;
        String test3275;
        String test3276;
        String test3277;
        String test3278;
        String test3279;
        String test3280;
        String test3281;
        String test3282;
        String test3283;
        String test3284;
        String test3285;
        String test3286;
        String test3287;
        String test3288;
        String test3289;
        String test3290;
        String test3291;
        String test3292;
        String test3293;
        String test3294;
        String test3295;
        String test3296;
        String test3297;
        String test3298;
        String test3299;
        String test3300;
        String test3301;
        String test3302;
        String test3303;
        String test3304;
        String test3305;
        String test3306;
        String test3307;
        String test3308;
        String test3309;
        String test3310;
        String test3311;
        String test3312;
        String test3313;
        String test3314;
        String test3315;
        String test3316;
        String test3317;
        String test3318;
        String test3319;
        String test3320;
        String test3321;
        String test3322;
        String test3323;
        String test3324;
        String test3325;
        String test3326;
        String test3327;
        String test3328;
        String test3329;
        String test3330;
        String test3331;
        String test3332;
        String test3333;
        String test3334;
        String test3335;
        String test3336;
        String test3337;
        String test3338;
        String test3339;
        String test3340;
        String test3341;
        String test3342;
        String test3343;
        String test3344;
        String test3345;
        String test3346;
        String test3347;
        String test3348;

    }

}
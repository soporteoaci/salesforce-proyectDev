public class CreacionOfertaIngenieriaController {
    
    @AuraEnabled
    public static String carga_datos(String idOpportunity){
        
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        String status = '';
        String message = '';
        string NombreOferta ='';
        
        // Recuperamos perfil del usuario
        Profile userProfile = [select id, Name FROM Profile Where id =: userInfo.getProfileId()];
        gen.writeObjectField('userProfile', userProfile.Name);
        System.debug('Usuario: ' + userInfo.getProfileId());
        System.debug('Profile: ' + userProfile.Name);
        
        if (!Schema.sObjectType.Opportunity.isAccessible()){
            return null;
        }
        
        // Recuperamos datos de la oportunidad
        List<Opportunity> opps = [select id, Name ,Falta_definicion_del_objeto__c,
                                     //No_existe_Limitacion__c,
                                     //Se_incluye_lucro__c,
                                     //Posibilidad_de_resoluci_n_unilateral__c,
                                     //Resoluci_n_por_conveniencia__c,
                                     //Causas_no_tasadas_y_ambiguas__c,
                                     Codigo_OC__c,
                                     //Codigo_OC2__c,
                                     Objetivo_del_proyecto__c,
                                     //Titulo_corto_SAP__c,
                                     Cliente__c,
                                     Cliente__r.Name,
                                     Fecha_limite_de_presentacion__c,
                                     Fecha_estimada_de_cierre__c,
                                     Importe_total_sin_IVA__c,
                                     Importe_Licitacion__c,
                                     Pais__c,
                                     Centro__c,
                                     Tipo_de_Trabajo__c,
                                     Subtipo_de_Trabajo__c,
                                     Actualizar_Estado__c,
                                     Cliente__r.SAP_Account__c,
                                     Oferta_SAP__c,
                                     //CECO__c,
                                     RUP__c,
                                     GP__c,
                                     //Responsable__c,
                                     //Proyecto_Especial__c,
                                     Fecha_Apertura__c,
                                     Tipo_de_Oportunidad__c,
                                     Etapa__c,/* Nacional__c,*/ Margen_Previsto_Euros__c, /*Emplazamiento__c,*/ Division_SAP__c, Sociedad_Ayesa__c, Division_SAP_Ingenieria__c
                                     //ETC__c
                                     from Opportunity  where id = :idOpportunity];
        
        Opportunity opportunity = null;
        
        if (opps.size() > 0) {
            status = 'OK';
            opportunity = opps.get(0);
            
            //10/2022
            //Si el objetivo del proyecto (nombre oferta) está vacío cogemos Tema (40)
            //Si el objetivo del proyecto está informado recortamos a 40
            //Recortar a 40 limitación de SAP
            
            if (opportunity.Objetivo_del_proyecto__c == null){
                
                if(opportunity.Name.length() > 40){
                    NombreOferta= opportunity.Name.substring(0, 40);                    
                }else {
                    NombreOferta= opportunity.Name;
                }
                
            }else{
                if(opportunity.Objetivo_del_proyecto__c.length() > 40){
                    NombreOferta= opportunity.Objetivo_del_proyecto__c.substring(0, 40);                    
                }else {
                    NombreOferta= opportunity.Objetivo_del_proyecto__c;
                }
            }
            opportunity.Objetivo_del_proyecto__c= NombreOferta;
            
           // system.debug('Titulo_corto_SAP__c: '+opportunity.Titulo_corto_SAP__c);
            gen.writeObjectField('oportunidad', opportunity);
        }
        
        //Opportunity opportunity = opps.get(0);
        
        // Recuperamos datos de parametricas
        List<Parametrica__c> params = [select Id, Name, Valor__c, Tipo__c, Tipo_Padre__c, Codigo_Padre__c, Activo__c, Permanente__c, Auxiliar__c 
                                       from Parametrica__c 
                                       where Activo__c =true order by Valor__c asc];
        
        //Metodo alternativo mediante el que definimos las listas de valores que es lo que nos interesa
        
        List<String> valoresPais = new List<String>();
        List<String> valoresEmp = new List<String>();        
        List<String> valoresTer = new List<String>();
        List<String> valoresTipoTr = new List<String>();
        List<String> valoresSubT = new List<String>();
        List<String> valoresDivSAP = new List<String>();
        List<String> valoresCentro = new List<String>();
        
        for(Parametrica__c param: params){
            if(param.Tipo__c == 'PAIS' && !valoresPais.contains(param.Valor__c)){
                valoresPais.add(param.Valor__c);
            }else if(param.Tipo__c == 'EMPLAZAMIENTO' && !valoresEmp.contains(param.Valor__c)){
                valoresEmp.add(param.Valor__c);
            }else if(param.Tipo__c == 'TIPO_TRABAJO' && !valoresTipoTr.contains(param.Valor__c)){
                valoresTipoTr.add(param.Valor__c);
            }else if(param.Tipo__c == 'SUBTIPO_TRABAJO' && !valoresSubT.contains(param.Valor__c)){
                valoresSubT.add(param.Valor__c);
            }else if(param.Tipo__c == 'DIVISION_INGENIERIA' && !valoresDivSAP.contains(param.Valor__c)){
                valoresDivSAP.add(param.Valor__c);
            }else if(param.Tipo__c == 'CENTRO' && !valoresCentro.contains(param.Valor__c) && opportunity != null && (opportunity.Sociedad_Ayesa__c.substring(0,4) == param.Codigo_Padre__c.leftPad(4, '0') || param.Codigo_Padre__c == null)){
                valoresCentro.add(param.Valor__c);
            }
        }
        
        Map<String,List<String>> mapa_Parametrica = new Map<String,List<String>>();
        
        mapa_Parametrica.put('PAIS', valoresPais);
        mapa_Parametrica.put('EMPLAZAMIENTO', valoresEmp);
        mapa_Parametrica.put('TIPO_TRABAJO', valoresTipoTr);
        mapa_Parametrica.put('SUBTIPO_TRABAJO', valoresSubT);
        mapa_Parametrica.put('DIVISION_INGENIERIA', valoresDivSAP);
        mapa_Parametrica.put('CENTRO', valoresCentro);
        
        gen.writeObjectField('tipos', mapa_Parametrica);
        
        //Deberiamos tener una estructura para los valores, quizas una equivalencia entre NombreCampo, Tipo parametrica, valor almacenado, traduccion del valor
        
        gen.writeStringField('status', status);
        gen.writeStringField('message', message);
        
        gen.writeEndObject();
        
        result = gen.getAsString();            
        
        return result;
    }
    
    @AuraEnabled
    public static String busquedaCliente(String buscarTexto) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        WebService__c webServiceData = WebService__c.getInstance();
        String user = webServiceData.username__c;        
        String pass = webServiceData.password__c;
        String endpoint = webServiceData.EndPoint_Search_Clientes__c;
        
        String data='username='+user+'&password='+pass+'&data={'+buscarTexto+'}' ;  
        
        request.setBody(data);
        request.setMethod('POST');
        if(!Test.isRunningTest()){
            request.setEndpoint(endpoint); 
            HttpResponse response = http.send(request);
            
            return response.getBody(); 
        }
        
        return '[]';
    }
    
    @AuraEnabled
    public static String busquedaEmpl(String buscarTexto) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        WebService__c webServiceData = WebService__c.getInstance();
        String user = webServiceData.username__c;        
        String pass = webServiceData.password__c;
        String endpoint = webServiceData.EndPoint_Search_Empleados__c;
        
        String envio='username='+user+'&password='+pass+'&data=' ;   
        String data='{"activo":"true",'+buscarTexto+'}';
        
        request.setBody(envio+data);   
        request.setMethod('POST');
        
        if (endpoint != null) {
            request.setEndpoint(endpoint);  
            HttpResponse response = http.send(request);
            
            return response.getBody(); 
        }
        
        return '[]';
    }
    
    @AuraEnabled
    public static String busquedaCeco(String buscarTexto) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        WebService__c webServiceData = WebService__c.getInstance();
        String user = webServiceData.username__c;        
        String pass = webServiceData.password__c;
        String endpoint = webServiceData.EndPoint_Search_CECO__c;
        
        String data='username='+user+'&password='+pass+'&data={'+buscarTexto+'}';  
        
        request.setBody(data);
        request.setMethod('POST');
        if(!Test.isRunningTest()){
            request.setEndpoint(endpoint); 
            HttpResponse response = http.send(request);
            
            return response.getBody(); 
        }
        
        return '[]';
    }
    
    @AuraEnabled
    public static String getIdCliente(String idOpp){
        if (!Schema.sObjectType.Opportunity.isAccessible()){
            return null;
        }
        Opportunity oportunidad = [SELECT Cliente__c FROM Opportunity WHERE id =:idOpp limit 1];
        return oportunidad.Cliente__c;
    }
    
    @AuraEnabled
    public static void actualizaCodSAP(String empleadoSAP, String idCliente) {
        
        List<Account> cli = [select id,name,SAP_Account__c from account  where id = :idCliente];
        Account cliente = cli.get(0);
        
        cliente.SAP_Account__c=empleadoSAP;
        
        update cliente;
        
        
    }
    
    @AuraEnabled
    public static String guardarOpp (String idOpportunity, String Oport){
        
        String response = '';
        
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();
                
        Opportunity oppAux = (Opportunity)System.JSON.deserialize(Oport, Opportunity.class);
        Opportunity opportunity = [select id from Opportunity where id = :idOpportunity];
        
        opportunity=oppAux;
        
        try {
            update opportunity;
            gen.writeStringField('status', 'OK'); 
            gen.writeStringField('message', 'La oferta se ha guardado de forma correcta'); 
            
        } catch (Exception e) {
            gen.writeStringField('status', 'Error'); 
            gen.writeStringField('message', 'No se ha podido guardar la oferta. ' + e.getMessage()); 
        }  
        
        gen.writeEndObject();
        response = gen.getAsString();
        
        return response;
    }
    
    @AuraEnabled
    public static String envioCorreo (String opp) { 
        
        CRM_Configuracion__c configuracion = CRM_Configuracion__c.getInstance();
        String email_licitaciones_str = configuracion.Email_Licitaciones_ING__c;
        String[] email_licitaciones = email_licitaciones_str!=null ? configuracion.Email_Licitaciones_ING__c.split(';') : new String[]{};
        System.debug('email_licitaciones: ' + email_licitaciones);
        
        String Mensaje= System.Label.CRM_Enviado_correo_a_licitaciones_CL; //Mensaje de confirmacion de envio de correo - Etiqueta personalizada
        Opportunity oppAux = (Opportunity)System.JSON.deserialize(opp, Opportunity.class);
        
        
        
        //Tomar valor de configuracion del report
        //  ApexPages.PageReference report = new ApexPages.PageReference('https://ayesaoaci--crmdev.cs83.my.salesforce.com/00O4E000000XiaDUAS/view&export=1&enc=UTF-8&xf=xls');
        //https://cs81.salesforce.com/00O26000000ZPGp?pv0=00626000008a78k&export=1&enc=UTF-8&xf=pdf
        //  Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        // attachment.setFileName('Oferta.xls');
        //  attachment.setBody(report.getContent());
        // attachment.setContentType('text/xls');
        system.debug('Envio correo');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //   message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        
        message.setSubject('Petición de código de Oferta ');
        
        //TEXTO PLANO 
        // message.setPlainTextBody('Hola\n Se ha enviado la solicitud de oferta: '+ oppAux.Name +'\n   para su revisión y avance, puede consultarla pulsando en el siguiente enlace '+ ''+' \n');
        message.setToAddresses( email_licitaciones );
        
        
        // message.setTemplateId('00X4E000000Va4h');
        // message.setTargetObjectId('0014E00000p0kyTQAQ');//setTargetObjectId(targetObjectId)
        // message.setWhatId('a004E00000J93DV');
        //mail.setTargetObjectId(contactid);
        //mail.setWhatId(customobj.id)
        
        
        Domain Dominio= [select  Domain  from Domain LIMIT 1];
        
        String URL = system.Url.getOrgDomainUrl().toExternalForm() + '\\'+ oppAux.id; 
        
        Date f1= oppAux.Fecha_limite_de_presentacion__c;
        String f1s=f1.format();
        
        
        String body = '<html lang="es"><body>'+ 
            'Buenas, '+
            '<br></br>'+'Solicitud enviada el '+  DateTime.now().format('dd/MM/yyyy') + ' a las ' + DateTime.now().format('HH:mm') +  ' por el usuario <b> '+ userinfo.getName() +' </b>'+', puede acceder con el siguiente enlace a la oportunidad '+'<b>'+' <a href='+URL+'> Pulse aquí </a>'+'</b>' +
            '<br></br>'+'Oferta para :'+ '<b> '+oppAux.Name+' </b>'
            + ' <br></br>'+ 
            
            '<table style="height: 400px; width: 1000px; float: left;" border="1"><tbody><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">C&oacute;digo de OC</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Codigo_OC__c  
           // +oppAux.Codigo_OC2__c  
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Objetivos del proyecto</span>&nbsp;</td><td style="width: 360px; height: 18px;" colspan="3">'
            +oppAux.Objetivo_del_proyecto__c 
            //10/2022 
            //+oppAux.Titulo_corto_SAP__c
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Cliente</span></td><td style="width: 356px; height: 18px;" colspan="5">&nbsp; '
            + oppAux.Cliente__r.Name 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Responsable</span></td><td style="width: 356px; height: 18px;">'
           // + oppAux.Responsable__c
            +'</td><td style="width: 200px; height: 36px;"><span style="color: #3366ff;">Fecha limite presentaci&oacute;n</span></td><td style="width: 360px; height: 36px;" colspan="3">&nbsp;'
            + (oppAux.Fecha_limite_de_presentacion__c).format()
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Fecha inicio PEP</span></td><td style="width: 356px; height: 18px;">&nbsp;'
            + (oppAux.Fecha_estimada_de_cierre__c).format()
            +'</td></tr><tr style="height: 36px;"><td style="width: 137px; height: 36px;"><span style="color: #3366ff;">Importe Licitaci&oacute;n</span></td><td style="width: 356px; height: 36px;">&nbsp;'
            +((oppAux.Importe_total_sin_IVA__c != null) ? (oppAux.Importe_total_sin_IVA__c).format() : '')
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Pais Cliente</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.Pais__c
            +'<tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Centro</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Centro__c 
            +'</td><td style="width: 200px; height: 18px;">&nbsp;</td><td style="width: 10px; height: 18px;" colspan="3">&nbsp;</td></tr>'
            
            +'</td></tr></tbody></table>'+
            
            '<br></br>'+'Atentamente' +'</body></html>';
        message.setSenderDisplayName('CRM Ayesa Support');
        message.setHtmlBody(body);
        
        try {
            if(!Test.isRunningTest()){
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            }
            
            Opportunity opportunity = [select id from Opportunity where id = :oppAux.id];
            
            opportunity.Fecha_sol_cod__c = date.today();
            opportunity.Actualizar_Estado__c=true;

            update opportunity;
        } catch (Exception ex) {
            System.debug('Error no esperado al realizar el envío de correo: ' + ex);
            Mensaje = 'Se ha producido un error al realizar en envío de la solicitud.</br>' + ex.getMessage();             
        }
        
        return Mensaje;
    }
    
    @AuraEnabled
    public static List<String> filterParametrica(String valorPadre){
        
        Parametrica__c padre = [select Tipo__c, Name from Parametrica__c where Valor__c =: valorPadre limit 1];
        
        List<Parametrica__c> valores_Param = [select Id, Name, Valor__c, Tipo__c, Tipo_Padre__c, Codigo_Padre__c, Activo__c, Permanente__c, Auxiliar__c 
                                               from Parametrica__c 
                                               where Activo__c = true and Codigo_Padre__c =: padre.Name and Tipo_Padre__c =: padre.Tipo__c];
        List<String> res = new List<String>();
        for(Parametrica__c param: valores_Param){
            res.add(param.Valor__c);
        }
        return res;
    }
    
    @AuraEnabled
    public static String offerGeneratorApex (string idOpportunity) {
        
        system.debug('Ha entrado');
        
        string info = 'Oferta creada correctamente';
        
        if (!Schema.sObjectType.Opportunity.isAccessible()){
            return null;
        }
        
        // Recuperamos datos de la oportunidad
        List<Opportunity> opps = [select id, Name ,Falta_definicion_del_objeto__c,
                                    // No_existe_Limitacion__c,
                                    // Se_incluye_lucro__c,
                                    // Posibilidad_de_resoluci_n_unilateral__c,
                                    // Resoluci_n_por_conveniencia__c,
                                    // Causas_no_tasadas_y_ambiguas__c,
                                     Codigo_OC__c,
                                     //Codigo_OC2__c,
                                     Objetivo_del_proyecto__c,
                                     //Titulo_corto_SAP__c,
                                     Cliente__c,
                                     Cliente__r.Name,
                                     Fecha_limite_de_presentacion__c,
                                     Fecha_estimada_de_cierre__c,
                                     Importe_total_sin_IVA__c,
                                     Pais__c,
                                     Centro__c,
                                     Tipo_de_Trabajo__c,
                                     Subtipo_de_Trabajo__c,
                                     Actualizar_Estado__c,
                                     Cliente__r.SAP_Account__c,
                                     Oferta_SAP__c,
                                     //CECO__c,
                                     RUP__c,
                                     GP__c,
                                     //Responsable__c,
                                     Tipo_de_Oportunidad__c,
                                     Fecha_Apertura__c,
                                    // Proyecto_Especial__c,
                                     Etapa__c, /*Nacional__c,*/ Margen_Previsto_Euros__c, /*Emplazamiento__c,*/ Division_SAP__c, Sociedad_Ayesa__c, Division_SAP_Ingenieria__c, Margen_estimado_incluye_recargos__c,
                                     Programa_Inductor__c,
                                     Proyecto_Inductor_1__c,
                                     Tipo_Induccion_1__c,
                                     Proyecto_Inductor_2__c,
                                     Tipo_Induccion_2__c,
                                     Proyecto_Inductor_3__c,
                                     Tipo_Induccion_3__c,
                                     Proyecto_Inductor_4__c,
                                     Tipo_Induccion_4__c
                                     //07/07/2022
                                    // ETC__c
                                     from Opportunity  where id = :idOpportunity];
        
        Opportunity opportunity = new Opportunity();
        
        if (opps.size() > 0) {
            opportunity = opps.get(0);
        }
        
        //Solicitud de datos de PARAMETRICA
        List<Parametrica__c > Valores_Param = [select Id, Name, Valor__c, Tipo__c, Tipo_Padre__c, Codigo_Padre__c, Activo__c, Permanente__c, Auxiliar__c 
                                               from Parametrica__c 
                                               where Activo__c =true order by Valor__c asc];
        
        Map<String,List<Parametrica__c>> Mapa_Parametrica = new Map<String,List<Parametrica__c>>();
        for (Parametrica__c param : Valores_Param) {
            String tipo = param.Tipo__c;
            
            List<Parametrica__c> ParamList = new List<Parametrica__c>();
            if (Mapa_Parametrica.containsKey(tipo)) {
                ParamList = Mapa_Parametrica.get(tipo);
            }
            
            ParamList.add(param);
            Mapa_Parametrica.put(tipo, ParamList);
        }
        
        // ------ RELLENO de información en estructura  --------  // 
        String /*nOferta = '',*/ responsable = '', ceco = '', objProyecto = '', tituloCortoSAP = '', codOfComercial = '';
       	String codSAPCli = '', GP = '', RUP = '', centroCod = '';
        String fechaInicio = '', fechaFin = '', fechaApOrden = '', importe = '';
        String margen = '', cebe_division = '', emplazamientoCod = '', tipoTrCod = '', subtipoTrCod = '', paisCod = '', nacional = '', proyEspecial = '';
        Integer modo = 5;
        
        DateTime dt = opportunity.Fecha_limite_de_presentacion__c;
        fechaInicio = dt.format('yyyy-MM-dd');
        dt = opportunity.Fecha_estimada_de_cierre__c;
        fechaFin = dt.format('yyyy-MM-dd');
        if(opportunity.Fecha_apertura__c == null){
            dt = system.today();
        }else{
            dt = opportunity.Fecha_apertura__c;
        }
       
        fechaApOrden = dt.format('yyyy-MM-dd');
        
        codOfComercial = opportunity.Codigo_OC__c;
        //codOfComercial = opportunity.Codigo_OC2__c;
        //ceco = opportunity.CECO__c;
        //responsable = (opportunity.Responsable__c != null) ? opportunity.Responsable__c.substringAfterLast('- ') : null;
        objProyecto = (opportunity.Objetivo_del_proyecto__c != null && opportunity.Objetivo_del_proyecto__c.length() > 40) ? opportunity.Objetivo_del_proyecto__c.substring(0, 40) : opportunity.Objetivo_del_proyecto__c; //Limitamos a 40 caracteres
        //tituloCortoSAP = opportunity.Titulo_corto_SAP__c;
        if(opportunity.GP__c != null && opportunity.GP__c != '')
        	GP = opportunity.GP__c.substringAfterLast('- ');
        if(opportunity.RUP__c != null && opportunity.RUP__c != '')
        	RUP = opportunity.RUP__c.substringAfterLast('- ');
        codSAPCli = opportunity.Cliente__r.SAP_Account__c != null ? opportunity.Cliente__r.SAP_Account__c.leftPad(10, '0') : null; //completamos con 0 hasta 10 caracteres        
        importe = String.valueOf(opportunity.Importe_total_sin_IVA__c);
        
        //margen = String.valueOf(opportunity.Margen_Previsto_Euros__c);
        margen = String.valueOf(opportunity.Margen_estimado_incluye_recargos__c);
        
        //nOferta = opportunity.Oferta_SAP__c;
      /*  if(opportunity.Nacional__c == True){
            nacional = 'N';
        }else{
            nacional = 'I';
        }
        if(opportunity.Proyecto_Especial__c == True){
            proyEspecial = 'X';
        }else{
            proyEspecial = '';
        }
        //07/2022
        String ETC='';
        if (Opportunity.ETC__c !=null){
            ETC= opportunity.ETC__c;
        }*/
        
        //Control de MODO con respecto al código del Centro    
        List<Parametrica__c> centro = Mapa_Parametrica.get('CENTRO');    
        System.debug('Mapa_Parametrica.centro: ' + centro);
        for (integer i=0; i<centro.size(); i++ ){
            if (centro[i].Valor__c == opportunity.Centro__c){
                centroCod = centro[i].Name;                
                /*if((centro[i].Name).startsWith('45')){
                    modo = 0;*/
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION_INGENIERIA');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP Ingenieria: ' + opportunity.Division_SAP_Ingenieria__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP_Ingenieria__c){
                            //cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                            cebe_division = (!String.isEmpty(division[j].Name)) ? division[j].Name : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                /*}
                else if((centro[i].Name).startsWith('07')){
                    modo = 2;
                }*/
            }            
        }
        
        //Control de PAIS
        List<Parametrica__c> paises = Mapa_Parametrica.get('PAIS');    
        for (integer i=0; i<paises.size(); i++ ){
            if (paises[i].Valor__c == opportunity.Pais__c){
                paisCod = paises[i].Name;
            }         
        }
        system.debug('Codigo de pais ejecucion: ' + paisCod);
        
        //Control de EMPLAZAMIENTO 
      /*  List<Parametrica__c> territorios = Mapa_Parametrica.get('EMPLAZAMIENTO');    
        for (integer i=0; i<territorios.size(); i++ ){
            if (territorios[i].Valor__c == opportunity.Emplazamiento__c){
                emplazamientoCod = territorios[i].Name;
            }          
        }
        system.debug('Codigo de emplazamiento Opp.: ' + opportunity.Emplazamiento__c);
        system.debug('Codigo de emplazamiento: ' + emplazamientoCod);*/

        //Control de TIPO TRABAJO para el valor seleccionado    
        List<Parametrica__c> tipoTrs = Mapa_Parametrica.get('TIPO_TRABAJO');    
        for (integer i=0; i<tipoTrs.size(); i++ ){
            if (tipoTrs[i].Valor__c == opportunity.Tipo_de_Trabajo__c){
                tipoTrCod = tipoTrs[i].Name;
            }        
        }
        system.debug('Codigo de tipo trabajo: ' + tipoTrCod);
        
        //Control de SUBTIPO TRABAJO para el valor seleccionado    
        List<Parametrica__c> subtipoTrs = Mapa_Parametrica.get('SUBTIPO_TRABAJO');    
        for (integer i=0; i<subtipoTrs.size(); i++ ){
            if (subtipoTrs[i].Valor__c == opportunity.Subtipo_de_Trabajo__c){
                subtipoTrCod = subtipoTrs[i].Name;
            }        
        }
        system.debug('Codigo de subtipo de trabajo: ' + subtipoTrCod);
        
                
        
        // ---------- DECLARACION DE TABLA T_RETURN (SE MANDA VACIA) ----------------//
        CRM_SAP_WS_Controller_OfIngen.TABLE_OF_BAPIRET2 RETURN_Table = new CRM_SAP_WS_Controller_OfIngen.TABLE_OF_BAPIRET2();
        CRM_SAP_WS_Controller_OfIngen.BAPIRET2 BAPIRET2_element = new CRM_SAP_WS_Controller_OfIngen.BAPIRET2();
        RETURN_Table.item = new CRM_SAP_WS_Controller_OfIngen.BAPIRET2[1];
        RETURN_Table.item[0] = BAPIRET2_element;
        
        
        // ----------- Declaracion de la estructura de respuesta -------------- //
        CRM_SAP_WS_Controller_OfIngen.YPS_OFERTA_CRM_SALESFORCEResponse_element response_x;
        
        /*nOferta, responsable, ceco, objProyecto
		cliente, codSAPCli, GP, RUP, centroCod, 
		,fechaInicio, fechaFin, fechaApOrden, importe
		,margen, cebe_division, emplazamientoCod, tipoTrCod, subtipoTrCod, paisCod, nacional, proyEspecial*/

        // ----------- Invocacion del servicio SAP -------------- //
        List<String> infoList = new List<String>();
        String result = '';
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();
        
        CRM_SAP_WS_Controller_OfIngen.YWS_PS_OFERTA_CRM_SALESFORCE soapFunction = new CRM_SAP_WS_Controller_OfIngen.YWS_PS_OFERTA_CRM_SALESFORCE();
        
        
      /*  try {
            
            //10/2022
            System.debug('Objetivo proyecto envio: ' + objProyecto);
            response_x = soapFunction.YPS_OFERTA_CRM_SALESFORCE(ceco, centroCod, codSAPCli, objProyecto, cebe_division, emplazamientoCod, fechaApOrden, fechaFin, fechaInicio, GP, nacional, codOfComercial, paisCod, proyEspecial, responsable, RUP, subtipoTrCod, tipoTrCod, 
                                                                importe, margen, opportunity.Proyecto_Inductor_1__c, opportunity.Proyecto_Inductor_2__c, opportunity.Proyecto_Inductor_3__c, opportunity.Proyecto_Inductor_4__c, opportunity.Programa_Inductor__c, opportunity.Tipo_Induccion_1__c, opportunity.Tipo_Induccion_2__c, opportunity.Tipo_Induccion_3__c,
                                                                opportunity.Tipo_Induccion_4__c, RETURN_Table, opportunity.ETC__c);
            System.debug('Respuesta Completa SAP: ' + response_x);       
            
            CRM_SAP_WS_Controller_OfIngen.TABLE_OF_BAPIRET2 BAPIRET2_Error_Table = response_x.T_RETURN;
            if (BAPIRET2_Error_Table!=null && (BAPIRET2_Error_Table.item).size() > 0) { 
              
                
                for (integer k=0; k < (BAPIRET2_Error_Table.item).size(); k++) {
                    if (BAPIRET2_Error_Table.item[k].TYPE_x != null) {
                        if (BAPIRET2_Error_Table.item[k].TYPE_x == 'E' || BAPIRET2_Error_Table.item[k].TYPE_x == 'W') { 
                            System.debug('Info SAP: ' + BAPIRET2_Error_Table.item[k].MESSAGE);
                            infoList.add(BAPIRET2_Error_Table.item[k].MESSAGE);
                        }
                    }
                }
            }
            
            if (response_x.P_OK == 'X') { // Bien
                // Actualizamos datos de la oportunidad
                Boolean isOk = updateOportunidad(opportunity);
                
                if(isOk) {
                    gen.writeStringField('status', 'Success');                     
                    gen.writeStringField('message', 'Oferta ' + response_x.T_ZOFERTA.item[0].PSPID + ' creada correctamente.');                     
                    gen.writeObjectField('warnings', infoList);
                    gen.writeStringField('ofertaSAP', response_x.T_ZOFERTA.item[0].PSPID); 
                    System.debug('MESNSAJE: '+ response_x.T_RETURN.item[0].MESSAGE);
                } else {
                    gen.writeStringField('status', 'Error'); 
                    gen.writeStringField('message', 'Se ha producido un problema al actualizar datos de la oportunidad.');                 
                    System.debug('MESNSAJE: '+ response_x.T_RETURN.item[0].MESSAGE);
                }
            } else {                
                gen.writeStringField('status', 'Error'); 
                gen.writeStringField('message', 'Se ha producido un problema al generar oferta en SAP.');                 
                gen.writeObjectField('warnings', infoList);
                gen.writeStringField('ofertaSAP', ''); 
            }
            
        } catch (Exception ex) {
            System.debug('Error no esperado al invocar SAP Service YPS_OFERTA_CRM_SALESFORCE: ' + ex);
            gen.writeStringField('status', 'Error'); 
            gen.writeStringField('message', 'Se ha producido un error al invocar la generación de oferta en SAP.</br>' + ex.getMessage());             
        }*/
        
        gen.writeEndObject();
        result = gen.getAsString();
        System.debug('OfferGeneratorApex - result: ' + result);
        
        return result;
        
    }
    
    public static Boolean updateOportunidad (Opportunity opp) { 
        
        opp.Tipo_de_Oportunidad__c = 'Licitación';
        
        try {
        	update opp;            
            return true;
        } catch (Exception ex) {
            System.debug('Error no esperado al actualizar información de la oportunidad: ' + ex);
            
        }
        
        return false;
    }
    
}
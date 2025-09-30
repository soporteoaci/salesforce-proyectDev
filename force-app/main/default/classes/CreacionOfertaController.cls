public class CreacionOfertaController {
    
    @AuraEnabled
    public static String carga_datos(String idOpportunity){
        
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        String status = '';
        String message = '';
        String NombreOferta='';
                
        // Recuperamos perfil del usuario
        Profile userProfile = [select id, Name FROM Profile Where id =: userInfo.getProfileId()];
        gen.writeObjectField('userProfile', userProfile.Name);
        System.debug('Usuario: ' + userInfo.getProfileId());
        System.debug('Profile: ' + userProfile.Name);
        
        // Recuperamos datos de la oportunidad
        List<Opportunity> opps = [select id, Name ,Falta_definicion_del_objeto__c,
                                    // No_existe_Limitacion__c,
                                    // Se_incluye_lucro__c,
                                   //  Posibilidad_de_resoluci_n_unilateral__c,
                                   //  Resoluci_n_por_conveniencia__c,
                                   //  Causas_no_tasadas_y_ambiguas__c,
                                     AccountId,
                                  	 Account.Name,
                                  	 Account.SAP_Account__c,
                                     Codigo_OC__c,
                                     //Codigo_OC2__c,
                                     Objetivo_del_proyecto__c,
                                     Cliente__c,
                                     Division_SAP__c,
                                     Fecha_limite_de_presentacion__c,
                                     Fecha_estimada_de_cierre__c,
                                     Plazo_de_ejecuci_n_meses__c,//Fecha_Fin_PEP_cal__c,
                                    // Importe_euros__c,
                                     Importe_total_sin_IVA__c,
                                     Jefe_de_Proyecto__c,
                                     GP__c,
                                     RUP__c,
                                    // Probabilidad_CRM_SAP__c,
                                     Area_de_negocio__c,
                                     Area_de_negocio_N1__c,
                                     Area_de_negocio_N2__c,
                                     Fecha_estimada_de_cierre_calc__c,
                                     AETIC__c,
                                     Sector_cliente__c,
                                     Pais_ejecucion__c,
                                     Pais_cliente__c,
                                     Territorio_ejecucion__c,
                                     Territorio_cliente__c,
                                     Centro__c,
                                   //  Grupo__c,
                                   //  Subgrupo__c,
                                     Probabilidad__c,
                                     Clasificacion_funcional_Nivel_1__c,
                                     Clasificacion_funcional_Nivel_2__c,
                                     Clasificacion_funcional_Nivel_3__c,
                                     Clasificacion_tecnologica_Nivel_1__c,
                                     Clasificacion_tecnologica_Nivel_2__c,
                                     Actualizar_Estado__c,
                                     Cliente__r.Name,
                                     Cliente__r.SAP_Account__c,
                                     Oferta_SAP__c,
                                     Etapa__c
                                     from Opportunity  where id = :idOpportunity];
        
        System.debug('Opp size:'+ opps.size());
        
        if (opps.size() > 0) {
            status = 'OK';
            Opportunity opportunity = opps.get(0);
            //system.debug(opportunity.cliente__r.name);
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
            
            gen.writeObjectField('oportunidad', opportunity);
        }
        
        // Recuperamos datos de parametricas
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
		System.debug('Valores parametrica: '+ Mapa_Parametrica);      
        gen.writeObjectField('tipos', Mapa_Parametrica);
        
        
        //Deberiamos tener una estructura para los valores, quizas una equivalencia entre NombreCampo, Tipo parametrica, valor almacenado, traduccion del valor
        
        
        
        gen.writeStringField('status', status);
        gen.writeStringField('message', message);
        
        gen.writeEndObject();
        
        result = gen.getAsString();
        
        return result;
    }
    
    
    
    @AuraEnabled
    public static void actualizaCodSAP(String EmpleadoSAP, String idCliente) {
        
        List<Account> cli = [select id,name,SAP_Account__c from account  where id = :idCliente];
        Account Cliente = cli.get(0);
        
        Cliente.SAP_Account__c=EmpleadoSAP;
        
        update Cliente;
        
        
    }
    
    
    
    @AuraEnabled
    public static String BusquedaEmpl(String buscarTexto) {
        /*
La búsqueda de empleados puede hacerse por:
•	NumeroPersonal: string
•	Nombre: string
•	Apellido1: string
•	Apellido2: string
•	UsuarioRed: string
•	CorreoElectronico: string
•	SociedadCodigo: string
•	CeBe: string
•	Area: string
•	Responsable: string
•	UnidadOrganizativa: string
•	NumeroPersonalSecretaria: string
•	Expatriado: bool
•	NumeroPersonalExpatriado: string
•	Proyecto: string
•	Externo: bool
•	AreaNominas: string
•	DivisionPersonal: string
•	SubdivisionPersonal: string
•	GrupoPersonal: string
•	AreaPersonal: string
•	Activo: bool
*/
        //   JSONGenerator gen = JSON.createGenerator(true);
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
    public static String BusquedaCliente(String buscarTexto) {
        /*
La búsqueda de clientes puede hacerse por:
•	Codigo: string
•	Nombre: string
•	IdAlternativo: string
•	Poblacion: string
•	CodigoPostal: string
•	Telefono: string
•	IdentificacionFiscal: string
•	SociedadCodigo: string
•	PaisCodigo: string

*/
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
    public static String saveOpp (String idOpportunity, String Oport){
        
        String response = '';
        
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();
        
        Opportunity oppAux = (Opportunity)System.JSON.deserialize(Oport, Opportunity.class);
        Opportunity opportunity = [select id from Opportunity where id = :idOpportunity];
        
        System.debug('oppAux.Division_SAP__c: ' + oppAux.Division_SAP__c);
        System.debug('opportunity: ' + opportunity);
        
        opportunity=oppAux;
        System.debug('opportunity.Division_SAP__c: ' + opportunity.Division_SAP__c);
        
        try {
            update opportunity;
            gen.writeStringField('status', 'OK'); 
            gen.writeStringField('message', 'Se ha guardado la oferta de forma correcta'); 
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            gen.writeStringField('status', 'Error'); 
            gen.writeStringField('message', 'No se ha podido guardar la oferta. ' + e.getMessage()); 
        }  
        
        gen.writeEndObject();
        response = gen.getAsString();
        
        return response;
        
    }
    
    @AuraEnabled
    public static String EnvioCorreo (String Oport) { 
        
        CRM_Configuracion__c configuracion = CRM_Configuracion__c.getInstance();
        String email_licitaciones = configuracion.Email_Licitaciones__c;
        System.debug('email_licitaciones: ' + email_licitaciones);
        
        String Mensaje= System.Label.CRM_Enviado_correo_a_licitaciones_CL; //Mensaje de confirmacion de envio de correo - Etiqueta personalizada
        Opportunity oppAux = (Opportunity)System.JSON.deserialize(Oport, Opportunity.class);

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
        
        message.setToAddresses( new String[] { email_licitaciones } ); 
        //09/01/2025 Asignamos quien envía el email
        OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where displayName =: 'Administrador CRM' limit 1];
        message.setOrgWideEmailAddressId(sender.Id);
        
        //Cogemos al propietario de la opp para ponerlo en el correo como CC
        System.debug('oppAux ->' +oppAux);
        Opportunity opOwner = [select id, OwnerId from Opportunity where id = :oppAux.id];
        System.debug('opOwner ->' +opOwner);
        User owner = [SELECT Name, Email FROM User WHERE Id= :opOwner.OwnerId];
        System.debug('owner ->' +owner); 
        if (owner.Email != null) {
           //09/01/2024 message.setCcAddresses(new string[] {owner.Email});
            System.debug('Se incluye al propietario como CC en el correo ->' + owner.Email);
        }
        
        // message.setTemplateId('00X4E000000Va4h');
        // message.setTargetObjectId('0014E00000p0kyTQAQ');//setTargetObjectId(targetObjectId)
        // message.setWhatId('a004E00000J93DV');
        //mail.setTargetObjectId(contactid);
        //mail.setWhatId(customobj.id)
        
        
        Domain Dominio= [select  Domain  from Domain LIMIT 1];
        
		//Corregida la URL - SCM 
        String URL = system.Url.getOrgDomainUrl().toExternalForm() + '/' + oppAux.id; 
        System.debug('oppAux.id ->' + oppAux.id);
        System.debug('La URL del correo -> ' + URL);
        
        Date f1= oppAux.Fecha_limite_de_presentacion__c;
        String f1s=f1.format();
        
        
        String body = '<html lang="es"><body>'+ 
            'Buenas, '+
            '<br></br>'+'Solicitud enviada el '+  DateTime.now().format('dd/MM/yyyy') + ' a las ' + DateTime.now().format('HH:mm') +  ' por el usuario <b> '+ userinfo.getName() +' </b>'+', puede acceder con el siguiente enlace a la oportunidad '+'<b>'+' <a href='+URL+'> Pulse aquí </a>'+'</b>' +
            '<br></br>'+'Oferta para :'+ '<b> '+oppAux.Name+' </b>'
            + ' <br></br>'+
            
            '<table style="height: 400px; width: 1000px; float: left;" border="1"><tbody><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">C&oacute;digo de OC</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Codigo_OC__c  
            //+oppAux.Codigo_OC2__c  
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Objetivos del proyecto</span>&nbsp;</td><td style="width: 360px; height: 18px;" colspan="3">'
            +oppAux.Objetivo_del_proyecto__c 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Cliente</span></td><td style="width: 356px; height: 18px;" colspan="5">&nbsp; '
            + oppAux.Account.Name 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">JP</span></td><td style="width: 356px; height: 18px;">'
            + oppAux.Jefe_de_Proyecto__c
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">GP</span></td><td style="width: 360px; height: 18px;" colspan="3">'
            + oppAux.GP__c
            +'</td></tr><tr style="height: 36px;"><td style="width: 137px; height: 36px;"><span style="color: #3366ff;">RUP</span></td><td style="width: 356px; height: 36px;">'
            + oppAux.RUP__c
            +'</td><td style="width: 200px; height: 36px;"><span style="color: #3366ff;">Fecha limite presentaci&oacute;n</span></td><td style="width: 360px; height: 36px;" colspan="3">&nbsp;'
            + (oppAux.Fecha_limite_de_presentacion__c).format()
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Fecha inicio PEP</span></td><td style="width: 356px; height: 18px;">&nbsp;'
            + (oppAux.Fecha_estimada_de_cierre_calc__c).format()
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Fecha fin PEP</span></td><td style="width: 360px; height: 18px;" colspan="3">&nbsp;'
           // + (oppAux.Fecha_Fin_PEP_cal__c).format()
            +'</td></tr><tr style="height: 12px;"><td style="width: 137px; height: 12px;"><span style="color: #3366ff;">Probabilidad</span></td><td style="width: 356px; height: 12px;">&nbsp;'
            +oppAux.Probabilidad__c 
            +'</td><td style="width: 200px; height: 12px;"><span style="color: #3366ff;">Plazo en meses</span></td><td style="width: 10px; height: 12px;" colspan="3">&nbsp; &nbsp;'
            +(oppAux.Plazo_de_ejecuci_n_meses__c).format()
            +'</td></tr><tr style="height: 36px;"><td style="width: 137px; height: 36px;"><span style="color: #3366ff;">Importe Licitaci&oacute;n</span></td><td style="width: 356px; height: 36px;">&nbsp;'
            +(oppAux.Importe_total_sin_IVA__c).format()
            +'</td><td style="width: 200px; height: 36px;"><span style="color: #3366ff;">&Aacute;rea Negocio</span></td><td style="width: 10px; height: 36px;" colspan="3">&nbsp; ' 
            +oppAux.Area_de_negocio__c
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Nivel 1</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Area_de_negocio_N1__c
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Nivel 2</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.Area_de_negocio_N2__c 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Divisi&oacute;n SAP</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Division_SAP__c
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">L&iacute;nea de actividad AETIC</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.AETIC__c 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Sector Cliente</span></td><td style="width: 356px; height: 18px;">'
            + oppAux.Sector_cliente__c 
            +'</td><td style="width: 200px; height: 18px;">&nbsp;</td><td style="width: 10px; height: 18px;" colspan="3">&nbsp;</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Pais Ejecuci&oacute;n</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Pais_ejecucion__c 
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Pais Cliente</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.Pais_cliente__c 
            +'</td></tr><tr style="height: 36px;"><td style="width: 137px; height: 36px;"><span style="color: #3366ff;">Territorio Ejecuci&oacute;n</span></td><td style="width: 356px; height: 36px;">'
            +oppAux.Territorio_ejecucion__c 
            +'</td><td style="width: 200px; height: 36px;"><span style="color: #3366ff;">Territorio Cliente</span></td><td style="width: 10px; height: 36px;" colspan="3">'
            +oppAux.Territorio_cliente__c             
            +'</td></tr>'
             
            /*<tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Centro</span></td><td style="width: 356px; height: 18px;">'
            + oppAux.Centro__c
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Grupo</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.Grupo__c 
            +'</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Subgrupo</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Subgrupo__c 
            +'</td><td style="width: 200px; height: 18px;">&nbsp;</td><td style="width: 10px; height: 18px;" colspan="3">&nbsp;</td></tr>'*/
            +'<tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Centro</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Centro__c 
            +'</td><td style="width: 200px; height: 18px;">&nbsp;</td><td style="width: 10px; height: 18px;" colspan="3">&nbsp;</td></tr>'

			+'<tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Clasificacion Funcional N1</span></td><td style="width: 356px; height: 18px;">'
            +oppAux.Clasificacion_funcional_Nivel_1__c 
            +'</td><td style="width: 200px; height: 18px;"><span style="color: #3366ff;">Claisifcaci&oacute;n Funcional N2</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            + oppAux.Clasificacion_funcional_Nivel_2__c 
            +'</td></tr><tr style="height: 36px;"><td style="width: 137px; height: 36px;"><span style="color: #3366ff;">Clasificaci&oacute;n Funcional N3</span></td><td style="width: 434px; height: 36px;">'
            + oppAux.Clasificacion_funcional_Nivel_3__c 
            +'</td><td style="width: 434px; height: 36px;">&nbsp;</td><td style="width: 10px; height: 36px;" colspan="3">&nbsp;</td></tr><tr style="height: 18px;"><td style="width: 137px; height: 18px;"><span style="color: #3366ff;">Clasificaci&oacute;n Tecnol&oacute;gica N1</span></td><td style="width: 434px; height: 18px;">'
            + oppAux.Clasificacion_tecnologica_Nivel_1__c
            +'</td><td style="width: 434px; height: 18px;"><span style="color: #3366ff;">Clasificaci&oacute;n Tecnol&oacute;gica N2</span></td><td style="width: 10px; height: 18px;" colspan="3">'
            +oppAux.Clasificacion_tecnologica_Nivel_2__c
            +'</td></tr></tbody></table>'+
            
            '<br></br>'+'Atentamente' +'</body></html>';
        //09/1/2025 message.setSenderDisplayName('CRM Ayesa Support');
        message.setHtmlBody(body);
        
        if(!Test.isRunningTest()){
            System.debug('Se va a enviar el email');
        	Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            System.debug('Se ha enviado el email');
        }
        
        Opportunity opportunity = [select id from Opportunity where id = :oppAux.id];
            
        opportunity.Fecha_sol_cod__c = date.today();
        opportunity.Actualizar_Estado__c=true;
        
        update opportunity;
        
        return Mensaje;
    } 
    
    @AuraEnabled
    public static String OfferGeneratorApex (string infoParametrica, string idOpportunity) { 
        system.debug (infoParametrica);
        // List<Object> param = (List<Object>)JSON.deserializeUntyped(infoParametrica);
        //system.debug(param);
        string info = 'Oferta creada correctamente';
        /*  Map<String, Object> param2 =(Map<String, Object>)JSON.deserializeUntyped(infoParametrica);
system.debug(param2);
List<Object> AETIC=(List<Object>)param2.get('AETIC');
List<Object> AREA_NEGOCIO=(List<Object>)param2.get('AREA_NEGOCIO');
List<Object> AREA_NEGOCIO_N1=(List<Object>)param2.get('AREA_NEGOCIO_N1');
List<Object> AREA_NEGOCIO_N2=(List<Object>)param2.get('AREA_NEGOCIO_N2');
List<Object> CENTRO=(List<Object>)param2.get('CENTRO');
List<Object> EMPLAZAMIENTO=(List<Object>)param2.get('EMPLAZAMIENTO');
List<Object> FUNCIONAL_N1=(List<Object>)param2.get('FUNCIONAL_N1');
List<Object> FUNCIONAL_N2=(List<Object>)param2.get('FUNCIONAL_N2');
List<Object> FUNCIONAL_N3=(List<Object>)param2.get('FUNCIONAL_N3');
system.debug(CENTRO.size());
system.debug(CENTRO[0]);*/
        
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
        
        //system.debug(Mapa_Parametrica);
        
        //Obtención de datos de la oportunidad
        List<Opportunity> opps = [select id, Name ,Falta_definicion_del_objeto__c,
                                    // No_existe_Limitacion__c,
                                    // Se_incluye_lucro__c,
                                    // Posibilidad_de_resoluci_n_unilateral__c, Resoluci_n_por_conveniencia__c,
                                    // Causas_no_tasadas_y_ambiguas__c, 
                                     AccountId,
                                     Account.name,
                                  	 Account.SAP_Account__c,
                                     Codigo_OC__c, 
                                     //Codigo_OC2__c,
                                     Objetivo_del_proyecto__c, Cliente__c,
                                     Division_SAP__c, Fecha_limite_de_presentacion__c,
                                     Fecha_estimada_de_cierre__c, Plazo_de_ejecuci_n_meses__c,//Fecha_Fin_PEP_cal__c,
                                     //Importe_euros__c, 
                                     Importe_total_sin_IVA__c,
                                     Jefe_de_Proyecto__c, GP__c,
                                     RUP__c,// Probabilidad_CRM_SAP__c,
                                     Area_de_negocio__c, Area_de_negocio_N1__c,
                                     Area_de_negocio_N2__c,
                                     Fecha_estimada_de_cierre_calc__c,
                                     AETIC__c,
                                     Sector_cliente__c,
                                     Pais_ejecucion__c,
                                     Pais_cliente__c,
                                     Territorio_ejecucion__c,
                                     Territorio_cliente__c,
                                     Centro__c,
                                    // Grupo__c,
                                    // Subgrupo__c,
                                     Probabilidad__c,
                                     Clasificacion_funcional_Nivel_1__c,
                                     Clasificacion_funcional_Nivel_2__c,
                                     Clasificacion_funcional_Nivel_3__c,
                                     Clasificacion_tecnologica_Nivel_1__c,
                                     Clasificacion_tecnologica_Nivel_2__c,
                                     Actualizar_Estado__c,
                                     Cliente__r.Name,
                                     Cliente__r.SAP_Account__c,
                                     Programa_Inductor__c,
                                     Proyecto_Inductor_1__c,
                                     Tipo_Induccion_1__c,
                                     Proyecto_Inductor_2__c,
                                     Tipo_Induccion_2__c,
                                     Proyecto_Inductor_3__c,
                                     Tipo_Induccion_3__c,
                                     Proyecto_Inductor_4__c,
                                     Tipo_Induccion_4__c
                                     //07/2022
                                     //ETC__c
                                     from Opportunity  where id = :idOpportunity];
        
        Opportunity opportunity = new Opportunity();
        if (opps.size() > 0) {
            opportunity = opps.get(0);
            //system.debug(opportunity.cliente__r.name); 
        }
        
        
        

        // ------ RELLENO de información en estructura  --------  //    
        String centroCod = '', paisEjecucionCod = '', paisClienteCod = '';  
        String territorioEjecucionCod = '', territorioClienteCod = '', grupoCod = '', subGrupoCod = '';
        String fechaInicio = '', fechaFin = '', fechaPresentacion = '', sectorClienteCod = '', agrupadorSectorClienteCod = '';
        String funcionalN1Cod = '', funcionalN2Cod = '', funcionalN3Cod = '', areanegocioN2Cod = '';
        String tecnologicaN1Cod = '', tecnologicaN2Cod = '', cebe_division = '', clienteSAPCod = '';
        Integer modo = 5;
        string emplazamientoCod = '0010'; //Al no usarase se deja este valor por defecto
        //07/2022
        String ETC='';
        DateTime dt = opportunity.Fecha_estimada_de_cierre_calc__c;
        fechaInicio = dt.format('yyyy-MM-dd');
       // dt = opportunity.Fecha_Fin_PEP_cal__c;
        fechaFin = dt.format('yyyy-MM-dd');	
        dt = opportunity.Fecha_limite_de_presentacion__c;
        fechaPresentacion = dt.format('yyyy-MM-dd');	
        
        clienteSAPCod = opportunity.Account.SAP_Account__c.leftPad(10, '0'); //completamos con 0 hasta 10 caracteres
        //07/2022
      //  if(opportunity.ETC__c != null){
      //  ETC = opportunity.ETC__c;
      //  }
        //Control de MODO con respecto al código del Centro    
        List<Parametrica__c> centro = Mapa_Parametrica.get('CENTRO');    
        System.debug('Mapa_Parametrica.centro: ' + centro);
        for (integer i=0; i<centro.size(); i++ ){
            if (centro[i].Valor__c == opportunity.Centro__c){
                
                centroCod = centro[i].Name; 
                
                if((centro[i].Name).startsWith('45')){
                    modo = 0;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }
                else if((centro[i].Name).startsWith('07')){
                    modo = 2;
                } //08/03/2023 M2C Parametrica
                else if((centro[i].Name).startsWith('99')){
                    modo = 9;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }
                else if((centro[i].Name).startsWith('47')){
                    modo = 1;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('170')){
                    modo = 3;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('171')){
                    modo = 4;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('172')){
                    modo = 5;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('175')){
                    modo = 6;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('180')){
                    modo = 7;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('181')){
                    modo = 8;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('185')){
                    modo = 10;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }else if((centro[i].Name).startsWith('145')){
                    modo = 11;
                    List<Parametrica__c> division = Mapa_Parametrica.get('DIVISION');    
                    system.debug('Mapa_Parametrica.division: ' + division);
                    system.debug('Division SAP: ' + opportunity.Division_SAP__c);
                    for (integer j=0; j<division.size(); j++ ){
                        if (division[j].Valor__c == opportunity.Division_SAP__c){
                            cebe_division = (!String.isEmpty(division[j].Auxiliar__c)) ? division[j].Auxiliar__c : '';
                        }
                    }
                    system.debug('CEBE asociado a la Division: ' + cebe_division);
                }
                
                
            }            
        }
        system.debug('Codigo de Centro: ' + centroCod);
        System.debug('Modo: ' + modo);
        
        //Control de CLASIFICACION FUNCIONAL N1 para el valor seleccionado    
        List<Parametrica__c> funcionalN1 = Mapa_Parametrica.get('FUNCIONAL_N1');    
        for (integer i=0; i<funcionalN1.size(); i++ ){
            if (funcionalN1[i].Valor__c == opportunity.Clasificacion_funcional_Nivel_1__c){
                funcionalN1Cod = funcionalN1[i].Name;
            }            
        }
        system.debug('Codigo de Clasificacion Funcional N1: ' + funcionalN1Cod);
        
        //Control de CLASIF. FUNCIONAL N2 para el valor seleccionado    
        List<Parametrica__c> funcionalN2 = Mapa_Parametrica.get('FUNCIONAL_N2');    
        for (integer i=0; i<funcionalN2.size(); i++ ){
            if (funcionalN2[i].Valor__c == opportunity.Clasificacion_funcional_Nivel_2__c){
                funcionalN2Cod = funcionalN2[i].Name;
            }
        }
        system.debug('Codigo de Nivel Funcional N2: ' + funcionalN2Cod);
        
        //Control de CLASIF. FUNCIONAL N3 para el valor seleccionado    
        List<Parametrica__c> funcionalN3 = Mapa_Parametrica.get('FUNCIONAL_N3');    
        for (integer i=0; i<funcionalN3.size(); i++ ){
            if (funcionalN3[i].Valor__c == opportunity.Clasificacion_funcional_Nivel_3__c){
                funcionalN3Cod = funcionalN3[i].Name;
            }
        }
        system.debug('Codigo de Nivel Funcional N3: ' + funcionalN3Cod);
        
        //Control de PAIS EJECUCION, PAIS CLIENTE para el valor seleccionado    
        List<Parametrica__c> paises = Mapa_Parametrica.get('PAIS');    
        for (integer i=0; i<paises.size(); i++ ){
            if (paises[i].Valor__c == opportunity.Pais_ejecucion__c){
                paisEjecucionCod = paises[i].Name;
            }
			if (paises[i].Valor__c == opportunity.Pais_cliente__c){
                paisClienteCod = paises[i].Name;
            }            
        }
        system.debug('Codigo de pais ejecucion: ' + paisEjecucionCod);
        system.debug('Codigo de pais cliente: ' + paisClienteCod);
        
        //Control de TERRITORIO EJECUCION, TERRITORIO CLIENTE para el valor seleccionado    
        List<Parametrica__c> territorios = Mapa_Parametrica.get('TERRITORIO');    
        for (integer i=0; i<territorios.size(); i++ ){
            if (territorios[i].Valor__c == opportunity.Territorio_ejecucion__c){
                territorioEjecucionCod = territorios[i].Name;
            }
			if (territorios[i].Valor__c == opportunity.Territorio_cliente__c){
                territorioClienteCod = territorios[i].Name;
            }            
        }
        system.debug('Codigo de territorio de ejecucion: ' + paisEjecucionCod);
        system.debug('Codigo de territorio de cliente: ' + paisClienteCod);
        
        //Control de GRUPO para el valor seleccionado    
     //   List<Parametrica__c> grupos = Mapa_Parametrica.get('GRUPO');    
     //   for (integer i=0; i<grupos.size(); i++ ){
     //       if (grupos[i].Valor__c == opportunity.Grupo__c){
     //           grupoCod = grupos[i].Name;
     //       }        
     //   }
     //   system.debug('Codigo de Grupo: ' + grupoCod);
        
        //Control de SUBGRUPO para el valor seleccionado    
    //    List<Parametrica__c> subgrupos = Mapa_Parametrica.get('SUBGRUPO');    
    //    for (integer i=0; i<subgrupos.size(); i++ ){
    //        if (subgrupos[i].Valor__c == opportunity.Subgrupo__c){
    //            subGrupoCod = subgrupos[i].Name;
    //        }        
    //    }
   //    system.debug('Codigo de Subgrupo: ' + subGrupoCod);
        
        //Control de SECTOR CLIENTE para el valor seleccionado    
        List<Parametrica__c> sectorcliente = Mapa_Parametrica.get('SECTOR_CLIENTE');    
        for (integer i=0; i<sectorcliente.size(); i++ ){
            if (sectorcliente[i].Valor__c == opportunity.Sector_cliente__c){
                sectorClienteCod = sectorcliente[i].Name;
            }        
        }
        system.debug('Codigo de Sector Cliente: ' + sectorClienteCod);
        
        //Control de AGRUPACION SECTOR CLIENTE para el valor seleccionado
        agrupadorSectorClienteCod = sectorClienteCod.left(2);
        system.debug('Codigo de Agrupador Sector Cliente: ' + agrupadorSectorClienteCod);
        
        //Control de CLASIF. TECNOLOGICA N1 para el valor seleccionado    
        List<Parametrica__c> tecnologicaN1 = Mapa_Parametrica.get('TECNICO_N1');    
        for (integer i=0; i<tecnologicaN1.size(); i++ ){
            if (tecnologicaN1[i].Valor__c == opportunity.Clasificacion_tecnologica_Nivel_1__c){
                tecnologicaN1Cod = tecnologicaN1[i].Name;
            }
        }
        system.debug('Codigo de Nivel Tecnologico N1: ' + tecnologicaN1Cod);
        
        //Control de CLASIF. TECNOLOGICA N2 para el valor seleccionado    
        List<Parametrica__c> tecnologicaN2 = Mapa_Parametrica.get('TECNICO_N2');    
        for (integer i=0; i<tecnologicaN2.size(); i++ ){
            if (tecnologicaN2[i].Valor__c == opportunity.Clasificacion_tecnologica_Nivel_2__c){
                tecnologicaN2Cod = tecnologicaN2[i].Name;
            }
        }
        system.debug('Codigo de Nivel Tecnologico N2: ' + tecnologicaN2Cod);
        
        //Control de AREA NEGOCIO N2 para el valor seleccionado    
        List<Parametrica__c> areanegocioN2 = Mapa_Parametrica.get('AREA_NEGOCIO_N2');    
        for (integer i=0; i<areanegocioN2.size(); i++ ){
            if (areanegocioN2[i].Valor__c == opportunity.Area_de_negocio_N2__c){
                areanegocioN2Cod = areanegocioN2[i].Name;
            }
        }

        if(String.isBlank(areanegocioN2Cod)) {
            system.debug('Codigo de Area Negocio N2 vacío, se inicializa con Area Negocio N1...');
            List<Parametrica__c> areanegocioN1 = Mapa_Parametrica.get('AREA_NEGOCIO_N1');    
            for (integer i=0; i<areanegocioN1.size(); i++ ){
                if (areanegocioN1[i].Valor__c == opportunity.Area_de_negocio_N1__c){
                    areanegocioN2Cod = areanegocioN1[i].Name;
                }
            }            
        }
        system.debug('Codigo de Area Negocio N2: ' + areanegocioN2Cod);  
        
        
        
        
        
        // ------ RELLENO DE TABLA  T_TLINE  --------  //  
        CRM_SAP_WS_Controller.TABLE_OF_ABAPTEXT TLINE_Table = new CRM_SAP_WS_Controller.TABLE_OF_ABAPTEXT();        
        CRM_SAP_WS_Controller.ABAPTEXT ABAPTEXT_element = new CRM_SAP_WS_Controller.ABAPTEXT();
        //ABAPTEXT_element.LINE=opportunity.Objetivo_del_Proyecto__c.left(72);		//Campo objetivo de proyecto (72 primeros caracteres)
        ABAPTEXT_element.LINE='';	
        TLINE_Table.item = new CRM_SAP_WS_Controller.ABAPTEXT[1];
        TLINE_Table.item[0] = ABAPTEXT_element;
        
        
        // ---------- RELLENO DE TABLA T_IHPA --------- //
        CRM_SAP_WS_Controller.TABLE_OF_IHPA IHPA_Table = new CRM_SAP_WS_Controller.TABLE_OF_IHPA();               
        CRM_SAP_WS_Controller.IHPA IHPA_element1 = new CRM_SAP_WS_Controller.IHPA(); //Código de SAP(1)
        IHPA_element1.PARVW='20';
		system.debug('Codigo de Cliente SAP: ' + clienteSAPCod);        
        IHPA_element1.PARNR=clienteSAPCod;                
        system.debug('IHPA_element1.PARNR Codigo de SAP: ' + clienteSAPCod);                
        
	    CRM_SAP_WS_Controller.IHPA IHPA_element2 = new CRM_SAP_WS_Controller.IHPA(); //Código de SAP(2)
        IHPA_element2.PARVW='SP';
        IHPA_element2.PARNR=clienteSAPCod;        
        system.debug('IHPA_element2.PARNR Codigo de SAP: ' + clienteSAPCod);                
        
        CRM_SAP_WS_Controller.IHPA IHPA_element3 = new CRM_SAP_WS_Controller.IHPA(); //Numero personal de RP (¿JEFE DE PROYECTO?)
        IHPA_element3.PARVW='10';
        //String[] jpSplit = opportunity.Jefe_de_Proyecto__c.split('-');        
        //IHPA_element3.PARNR=jpSplit[1].trim();
        IHPA_element3.PARNR = (opportunity.Jefe_de_Proyecto__c != null) ? opportunity.Jefe_de_Proyecto__c.substringAfterLast('- ').trim() : null;
		system.debug('IHPA_element3.PARNR Numero personal de RP: ' + IHPA_element3.PARNR);                
        
        CRM_SAP_WS_Controller.IHPA IHPA_element4 = new CRM_SAP_WS_Controller.IHPA(); //Numero personal de GP
        IHPA_element4.PARVW='11';
        //String[] gpSplit = opportunity.GP__c.split('-');
        //IHPA_element4.PARNR=gpSplit[1].trim();        
        IHPA_element4.PARNR = (opportunity.GP__c != null) ? opportunity.GP__c.substringAfterLast('- ').trim() : null;
        system.debug('IHPA_element4.PARNR Numero personal de GP: ' + IHPA_element4.PARNR);                
        
        CRM_SAP_WS_Controller.IHPA IHPA_element5 = new CRM_SAP_WS_Controller.IHPA(); //Numero personal de RUP
        IHPA_element5.PARVW='12';
        //String[] rupSplit = opportunity.RUP__c.split('-');
        //IHPA_element5.PARNR=rupSplit[1].trim();      
        IHPA_element5.PARNR = (opportunity.RUP__c != null) ? opportunity.RUP__c.substringAfterLast('- ').trim() : null;
        system.debug('IHPA_element5.PARNR Numero personal de RUP: ' + IHPA_element5.PARNR);                
        
        CRM_SAP_WS_Controller.IHPA IHPA_element6 = new CRM_SAP_WS_Controller.IHPA(); //Codigo nivel 2 (o nivel 1 si el nivel 2 no hay)
        IHPA_element6.PARVW='14';
        IHPA_element6.PARNR=areanegocioN2Cod;  
        system.debug('IHPA_element6.PARNR Codigo Area Negocio N2: ' + areanegocioN2Cod);                

        IHPA_Table.item = new CRM_SAP_WS_Controller.IHPA[6];
        IHPA_Table.item[0] = IHPA_element1;
        IHPA_Table.item[1] = IHPA_element2;
        IHPA_Table.item[2] = IHPA_element3;
        IHPA_Table.item[3] = IHPA_element4;
        IHPA_Table.item[4] = IHPA_element5;
        IHPA_Table.item[5] = IHPA_element6;
        
        
        // ------------- RELLENO DE TABLA T_PROJ ---------------//
        CRM_SAP_WS_Controller.TABLE_OF_PROJ PROJ_Table = new CRM_SAP_WS_Controller.TABLE_OF_PROJ();
        CRM_SAP_WS_Controller.PROJ PROJ_element = new CRM_SAP_WS_Controller.PROJ();
        PROJ_element.POST1=opportunity.Objetivo_del_Proyecto__c.left(40);	//Texto del objetivo del proyecto (Objetivo_del_Proyecto__c)
        PROJ_element.PLFAZ=fechaInicio;										//Fecha de Inicio en formato yyyy-MM-dd (Fecha_estimada_de_cierre_calc__c)
       	PROJ_element.PLSEZ=fechaFin;										//Fecha de fin en formato yyyy-MM-dd (Fecha_fin_PEP_calc__c)
        PROJ_element.WERKS=centroCod;										//codigo del centro (Centro__c)
        PROJ_element.KALID='0';												//Calendario de fábrica del Centro seleccionado (¿?)
        System.debug('RELLENO DE TABLA T_PROJ: '+ PROJ_element);
        if(modo == 2){
            PROJ_element.STORT=emplazamientoCod;							//codigo de emplazamiento
            PROJ_element.PROFL='ACT0001';									//
            system.debug('PROJ_element.PROFL codigo de emplazamiento: ACT0001');                
        }else if(modo == 0){
            PROJ_element.PROFL='SAD0001';									//
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);                
        }else if(modo == 1){
            PROJ_element.PROFL='ATE0001';									//
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==9){
            //08/03/2023 Incluir M2C Parametrica
            PROJ_element.PROFL='Y000099';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==3){
            PROJ_element.PROFL='Y000170';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }        else if (modo==4){
            PROJ_element.PROFL='Y000171';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==5){
            PROJ_element.PROFL='Y000172';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==6){
            PROJ_element.PROFL='Y000175';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==7){
            PROJ_element.PROFL='Y000180';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==8){
            PROJ_element.PROFL='Y000181';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==10){
            PROJ_element.PROFL='Y000185';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }else if (modo==11){
            PROJ_element.PROFL='Y000145';
            PROJ_element.PRCTR=cebe_division;								//Cebe de la división seleccionada 
            system.debug('PROJ_element.PRCTR Cebe de la división: ' + cebe_division);  
        }
              	
        PROJ_Table.item = new CRM_SAP_WS_Controller.PROJ[1];
        PROJ_Table.item[0] = PROJ_element;
        
        
        // ---------- RELLENO DE TABLA T_PRPS (3 ELEMENTOS) ----------------//        
        CRM_SAP_WS_Controller.TABLE_OF_PRPS PRPS_Table = new CRM_SAP_WS_Controller.TABLE_OF_PRPS();         
        CRM_SAP_WS_Controller.PRPS PRPS_element1 = new CRM_SAP_WS_Controller.PRPS(); //ELEMENTO 1
        PRPS_element1.STUFE=1;												//
        PRPS_element1.POST1=opportunity.Objetivo_del_Proyecto__c.left(40);	//Texto del objetivo del proyecto(Objetivo_del_Proyecto__c)
        system.debug('PRPS_element1.POST1 Texto objetivo: ' + opportunity.Objetivo_del_Proyecto__c.left(40));                
        PRPS_element1.PLAKZ='X';											//
        PRPS_element1.WERKS=centroCod;										//código del centro (Centro__c)
        system.debug('PRPS_element1.WERKS codigo del centro: ' + centroCod);                
        if(modo==2){            
            PRPS_element1.ZZCLIENTE=clienteSAPCod;	//Código del cliente (Codigo del Cliente SAP)
            system.debug('PRPS_element1.ZZCLIENTE codigo del cliente: ' + clienteSAPCod);                            
            PRPS_element1.YYCOUNTRY='ES';									//
            PRPS_element1.YYCOUNTRY2='ES';									//
        }       
        
        CRM_SAP_WS_Controller.PRPS PRPS_element2 = new CRM_SAP_WS_Controller.PRPS(); //ELEMENTO 2
        PRPS_element2.STUFE=2;
        PRPS_element2.POST1=opportunity.Objetivo_del_Proyecto__c.left(40);				//Texto del objetivo del proyecto(Objetivo_del_Proyecto__c)
        system.debug('PRPS_element2.POST1 Texto objetivo: ' + opportunity.Objetivo_del_Proyecto__c.left(40));                
        PRPS_element2.YYCODOC=opportunity.Codigo_OC__c;									//código de la oportunidad Salesforce (Codigo_OC__c)
        system.debug('PRPS_element2.YYCODOC código de la oportunidad Salesforce: ' + opportunity.Codigo_OC__c);
        //PRPS_element2.YYCODOC=opportunity.Codigo_OC2__c;									//código de la oportunidad Salesforce (Codigo_OC2__c)
        //system.debug('PRPS_element2.YYCODOC código de la oportunidad Salesforce: ' + opportunity.Codigo_OC2__c);                
        PRPS_element2.WERKS=centroCod; 													//código del centro (Centro__c)
        system.debug('PRPS_element2.WERKS código del centro: ' + centroCod);                
        PRPS_element2.YYSECCLI=agrupadorSectorClienteCod;								//Agrupador de sector de cliente seleccionado 
        system.debug('PRPS_element2.YYSECCLI Agrupador de sector de cliente: ' + agrupadorSectorClienteCod);                
        PRPS_element2.YYSECCLIP=sectorClienteCod;										//Codigo de sector de cliente
        system.debug('PRPS_element2.YYSECCLIP Codigo de sector de cliente: ' + sectorClienteCod);                
        PRPS_element2.YYTEREJE=territorioEjecucionCod;									//código del territorio de ejecución 
        system.debug('PRPS_element2.YYSECCLIP Codigo de territorio de ejecucion: ' + territorioEjecucionCod);                
        PRPS_element2.YYCOUNTRY=paisEjecucionCod;										//código del país de ejecución 
        system.debug('PRPS_element2.YYCOUNTRY Codigo de pais de ejecucion: ' + paisEjecucionCod);                
        PRPS_element2.YYTERCLI=territorioClienteCod;									//código del territorio de cliente 
        system.debug('PRPS_element2.YYTERCLI Codigo del territorio de cliente: ' + territorioClienteCod);                
        PRPS_element2.YYCOUNTRY2=paisClienteCod;										//código del país de ejecución ¿CLIENTE?
        system.debug('PRPS_element2.YYCOUNTRY2 Codigo del pais de cliente: ' + paisClienteCod);                
        PRPS_element2.YYCLFUPR='X';														//
        PRPS_element2.YYCATEPR=tecnologicaN2Cod;										//Código de la clasificación tecnológica de Nivel 2
        system.debug('PRPS_element2.YYCATEPR Codigo de la clasificación tecnológica de Nivel 2: ' + tecnologicaN2Cod);                
        //PRPS_element2.ZZCLAVECON='Exp-01';											//nº de expediente 
        //PRPS_element2.ZZFECHAAP='2018-12-17';											//
        PRPS_element2.ZZPLAZO=String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c);	//Plazo
        system.debug('PRPS_element2.ZZPLAZO Plazo: ' + String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c));                
        PRPS_element2.ZZUNIDT='MON';													//
        PRPS_element2.PRART='99';														//
        PRPS_element2.PLAKZ='X';														//
        PRPS_element2.FAKKZ='X';														//
        //PRPS_element2.YYTPT='1400'; //??												//Código del tipo (si no lo ha marcado como no necesario)
        //PRPS_element2.YYSTP='1499'; //??												//Código del subtipo (si no lo ha marcado como no necesario)
        PRPS_element2.YYGRP=grupoCod;													//Código del grupo (si no lo ha marcado como no necesario) (Grupo__c)
        system.debug('PRPS_element2.YYGRP Codigo del grupo: ' + grupoCod);                
        PRPS_element2.YYSGR=subGrupoCod;         										//Código del subgrupo (si no lo ha marcado como no necesario) (Subgrupo__c)
        system.debug('PRPS_element2.YYSGR Codigo del subgrupo: ' + subGrupoCod);                
        if(opportunity.Probabilidad__c=='0' || opportunity.Probabilidad__c=='10' || opportunity.Probabilidad__c==null ){
            PRPS_element2.PSPRI='0';													//Si la probabilidad = 0% o vacia 
            system.debug('PRPS_element2.PSPRI probabilidad: 0');                
        }else if(opportunity.Probabilidad__c=='25'){
            PRPS_element2.PSPRI='1';													//Si la probabilidad = 25%
            system.debug('PRPS_element2.PSPRI probabilidad: 1');                
        }else if(opportunity.Probabilidad__c=='50'){
            PRPS_element2.PSPRI='2';													//Si la probabilidad = 50%
            system.debug('PRPS_element2.PSPRI probabilidad: 2');                
        }else if(opportunity.Probabilidad__c=='70'){
            PRPS_element2.PSPRI='3';													//Si la probabilidad = 70%
            system.debug('PRPS_element2.PSPRI probabilidad: 3');                
        }else if(opportunity.Probabilidad__c=='90'){
            PRPS_element2.PSPRI='4';													//Si la probabilidad = 90%
            system.debug('PRPS_element2.PSPRI probabilidad: 4');                
        }else if(opportunity.Probabilidad__c=='100'){
            PRPS_element2.PSPRI='5';													//Si la probabilidad = 100%
            system.debug('PRPS_element2.PSPRI probabilidad: 5');                
        }
        if(modo==2){
            PRPS_element2.ZZCLIENTE=clienteSAPCod;				//Código del cliente SAP    
            system.debug('PRPS_element2.ZZCLIENTE Codigo de cliente: ' + clienteSAPCod);                
            PRPS_element2.STORT=emplazamientoCod;										//código del emplazamiento
            system.debug('PRPS_element2.STORT Codigo de emplazamiento: ' + emplazamientoCod);                
        }
                
        CRM_SAP_WS_Controller.PRPS PRPS_element3 = new CRM_SAP_WS_Controller.PRPS(); //ELEMENTO 3       
        PRPS_element3.STUFE=3;
        PRPS_element3.PRART='99';												//
        PRPS_element3.POST1=opportunity.Objetivo_del_Proyecto__c.left(40);		//Texto del objetivo del proyecto (Objetivo_del_Proyecto__c)
        system.debug('PRPS_element3.POST1 Texto del objetivo del proyecto: ' + opportunity.Objetivo_del_Proyecto__c.left(40));                
        PRPS_element3.PLAKZ='X';												//
        PRPS_element3.WERKS=centroCod;        									//código del centro (Centro__c)
        system.debug('PRPS_element3.WERKS codigo del centro: ' + centroCod);                
        //PRPS_element3.YYTPT='1400';											//
        //PRPS_element3.YYSTP='1405';											//
        PRPS_element3.YYGRP=grupoCod;											//Código del grupo (si no lo ha marcado como no necesario) (Grupo__c)
        system.debug('PRPS_element3.YYGRP codigo del grupo: ' + grupoCod);                
        PRPS_element3.YYSGR=subGrupoCod;										//Código del subgrupo (si no lo ha marcado como no necesario) (Subgrupo__c)
        system.debug('PRPS_element3.YYSGR codigo del subgrupo: ' + subGrupoCod);                
        if (modo==2){
            PRPS_element3.ZZCLIENTE=clienteSAPCod;		//Código del cliente SAP
            system.debug('PRPS_element3.ZZCLIENTE codigo del cliente SAP: ' + clienteSAPCod);                
            PRPS_element3.YYCOUNTRY='ES';
            PRPS_element3.YYCOUNTRY2='ES';
            PRPS_element3.STORT=emplazamientoCod;								//código del emplazamiento 
            system.debug('PRPS_element3.STORT codigo del emplazamiento: ' + emplazamientoCod);                
        }
        //01/2025 Número de expediente
        
        PRPS_element3.ZZCLAVECON ='';
        //07/2022
    //    if(opportunity.ETC__c != null){
    //    PRPS_element3.YYSERVICIO=ETC;
    //    system.debug('PRPS_element3.YYSERVICIO: ' + ETC );
    //    }

        PRPS_Table.item = new CRM_SAP_WS_Controller.PRPS[3];
        PRPS_Table.item[0] = PRPS_element1;
        PRPS_Table.item[1] = PRPS_element2;
        PRPS_Table.item[2] = PRPS_element3;
        
        
        // ---------- RELLENO DE TABLA T_PRTE ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_PRTE PRTE_Table = new CRM_SAP_WS_Controller.TABLE_OF_PRTE();
        CRM_SAP_WS_Controller.PRTE PRTE_element = new CRM_SAP_WS_Controller.PRTE();
        PRTE_element.PSTRT=fechaInicio;								//Fecha de Inicio en formato yyyy-MM-dd (Fecha_estimada_de_cierre_calc__c)
        system.debug('PRTE_element.PSTRT Fecha de Inicio: ' + fechaInicio);                
        PRTE_element.PENDE=fechaFin;								//Fecha de Fin en formato yyyy-MM-dd (Fecha_fin_PEP_calc__c)
        system.debug('PRTE_element.PENDE Fecha de Fin: ' + fechaFin);                

       	PRTE_Table.item = new CRM_SAP_WS_Controller.PRTE[1];
        PRTE_Table.item[0] = PRTE_element;
        
        
        // ---------- RELLENO DE TABLA T_YPS100 ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_YPS100 YPS100_Table = new CRM_SAP_WS_Controller.TABLE_OF_YPS100();
        CRM_SAP_WS_Controller.YPS100 YPS100_element = new CRM_SAP_WS_Controller.YPS100();
        YPS100_element.YTITUL=opportunity.Objetivo_del_Proyecto__c.left(40);				//Texto del objetivo del proyecto
        system.debug('YPS100_element.YTITUL Texto del objetivo del proyecto: ' + opportunity.Objetivo_del_Proyecto__c.left(40));                
        YPS100_element.YYCLNUEVO=''; //?? - preguntar										//“X” si está marcado cliente nuevo
        YPS100_element.YYCONREC=''; //?? - preguntar										//“X” si está marcado contrato recurrente
        YPS100_element.YPLAZO=String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c);		//Plazo
        system.debug('YPS100_element.YPLAZO Plazo: ' + String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c));                
        YPS100_element.WAERS='EUR';															//
        YPS100_element.YIMPORTE=String.valueOf(opportunity.Importe_total_sin_IVA__c);		//Importe de licitación
        system.debug('YPS100_element.YIMPORTE Importe de Licitacion: ' + String.valueOf(opportunity.Importe_total_sin_IVA__c));                
        //YPS100_element.YFEC_APE='2018-12-31'; //??											//Fecha de apertura de plicas en formato yyyy-MM-dd 
        YPS100_element.YFEC_PRS=fechaPresentacion;											//Fecha de presentación en formato yyyy-MM-dd 
        system.debug('YPS100_element.YFEC_PRS Fecha de presentación: ' + fechaPresentacion);                

       	YPS100_Table.item = new CRM_SAP_WS_Controller.YPS100[1];
        YPS100_Table.item[0] = YPS100_element;
        
        
        // ---------- RELLENO DE TABLA T_YPS103 ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_YPS013 YPS013_Table = new CRM_SAP_WS_Controller.TABLE_OF_YPS013();
        CRM_SAP_WS_Controller.YPS013 YPS013_element = new CRM_SAP_WS_Controller.YPS013();
        YPS013_element.YTITUL=opportunity.Objetivo_del_Proyecto__c.left(40);			//Texto del objetivo del proyecto 
        system.debug('YPS103_element.YTITUL Texto del objetivo del proyecto : ' + opportunity.Objetivo_del_Proyecto__c.left(40));                
        YPS013_element.YYCLNUEVO=''; //?? - preguntar									//“X” si está marcado cliente nuevo
        YPS013_element.YYCONREC=''; //?? - preguntar									//“X” si está marcado contrato recurrente
        //YPS013_element.YFEC_APE='2018-12-31'; //??										//Fecha de apertura de plicas en formato yyyy-MM-dd
        YPS013_element.YFEC_PRS=fechaPresentacion;										//Fecha de presentación en formato yyyy-MM-dd 
        system.debug('YPS103_element.YFEC_PRS Fecha de presentación: ' + fechaPresentacion);                
        YPS013_element.YPLAZO=String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c);	//Plazo 
        system.debug('YPS103_element.YPLAZO Plazo: ' + String.valueOf(opportunity.Plazo_de_ejecuci_n_meses__c));                
        YPS013_element.WAERS='EUR';														//
        YPS013_element.YIMPORTE=String.valueOf(opportunity.Importe_total_sin_IVA__c);	//Importe de licitación
		system.debug('YPS103_element.YIMPORTE Importe de licitacion: ' + String.valueOf(opportunity.Importe_total_sin_IVA__c));                
       	
       	YPS013_Table.item = new CRM_SAP_WS_Controller.YPS013[1];
        YPS013_Table.item[0] = YPS013_element;
        
        
        // ---------- RELLENO DE TABLA T_YPS066 ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_YPS066 YPS066_Table = new CRM_SAP_WS_Controller.TABLE_OF_YPS066();
        CRM_SAP_WS_Controller.YPS066 YPS066_element = new CRM_SAP_WS_Controller.YPS066();
        YPS066_element.YYCLTE1=tecnologicaN1Cod;								//código de la clasificación tecnológica de nivel 1 (Clasificacion_tecnologica_Nivel_1_c)
        system.debug('YPS066_element.YYCLTE1 Codigo de la clasificación tecnológica de nivel 1: ' + tecnologicaN1Cod);                
        YPS066_element.YYCLTE2=tecnologicaN2Cod;								//código de la clasificación tecnológica de nivel 2 (Clasificacion_tecnologica_Nivel_2_c)
        system.debug('YPS066_element.YYCLTE2 Codigo de la clasificación tecnológica de nivel 2: ' + tecnologicaN2Cod);                
        YPS066_element.YYCLTEPR='X';											//

       	YPS066_Table.item = new CRM_SAP_WS_Controller.YPS066[1];
        YPS066_Table.item[0] = YPS066_element;
        
        
        // ---------- RELLENO DE TABLA T_YPS068 ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_YPS068 YPS068_Table = new CRM_SAP_WS_Controller.TABLE_OF_YPS068();
        CRM_SAP_WS_Controller.YPS068 YPS068_element = new CRM_SAP_WS_Controller.YPS068();
        YPS068_element.YYCLFU1=funcionalN1Cod;									//código de la clasificación funcional de nivel 1 (Clasificacion_funcional_Nivel_1_c)
        system.debug('YPS068_element.YYCLFU1 Codigo de la clasificación funcional de nivel 1: ' + funcionalN1Cod);                
        YPS068_element.YYCLFU2=funcionalN2Cod;									//código de la clasificación funcional de nivel 2 (Clasificacion_funcional_Nivel_2_c)
        system.debug('YPS068_element.YYCLFU2 Codigo de la clasificación funcional de nivel 2: ' + funcionalN2Cod);                
        YPS068_element.YYCLFU3=funcionalN3Cod;									//código de la clasificación funcional de nivel 3 (Clasificacion_funcional_Nivel_3_c)
        system.debug('YPS068_element.YYCLFU3 Codigo de la clasificación funcional de nivel 3: ' + funcionalN3Cod);                
        YPS068_element.YYCLFUPR='X';											//

       	YPS068_Table.item = new CRM_SAP_WS_Controller.YPS068[1];
        YPS068_Table.item[0] = YPS068_element;
        
        
        // ---------- DECLARACION DE TABLA T_RETURN (SE MANDA VACIA) ----------------//
        CRM_SAP_WS_Controller.TABLE_OF_BAPIRET2 RETURN_Table = new CRM_SAP_WS_Controller.TABLE_OF_BAPIRET2();
        CRM_SAP_WS_Controller.BAPIRET2 BAPIRET2_element = new CRM_SAP_WS_Controller.BAPIRET2();
        RETURN_Table.item = new CRM_SAP_WS_Controller.BAPIRET2[1];
        RETURN_Table.item[0] = BAPIRET2_element;
        
        
        // ----------- Declaracion de la estructura de respuesta -------------- //
        CRM_SAP_WS_Controller.YPS_CREAR_OFERTA_CRM_RFCResponse_element response_x;
        
        
        
     	// ----------- Invocacion del servicio SAP -------------- //
        List<String> infoList = new List<String>();
        String result = '';
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();
        
        CRM_SAP_WS_Controller.YWS_CREAR_OFERTA_CRM_RFC soapFunction = new CRM_SAP_WS_Controller.YWS_CREAR_OFERTA_CRM_RFC();
        
        //07/2022 añado a response el campo YYSERVICIO que es ETC
     /*   try {   
            response_x= soapFunction.YPS_CREAR_OFERTA_CRM_RFC('L01', opportunity.Proyecto_Inductor_1__c, opportunity.Proyecto_Inductor_2__c, opportunity.Proyecto_Inductor_3__c, opportunity.Proyecto_Inductor_4__c, opportunity.Programa_Inductor__c, 
                                                              '', IHPA_Table, PROJ_Table, PRPS_Table, PRTE_Table, RETURN_Table, TLINE_Table, YPS013_Table, YPS066_Table, YPS068_Table, YPS100_Table, opportunity.Tipo_Induccion_1__c, opportunity.Tipo_Induccion_2__c, opportunity.Tipo_Induccion_3__c, opportunity.Tipo_Induccion_4__c,opportunity.ETC__c);
            System.debug('Respuesta Completa SAP: ' + response_x);       
                
            CRM_SAP_WS_Controller.TABLE_OF_BAPIRET2 BAPIRET2_Error_Table = response_x.T_RETURN;
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
            
            if (response_x.T_PRPS==null || response_x.T_PRPS.item[1].POSKI == '') { // no se ha generado codigo de oferta
                gen.writeStringField('status', 'Error'); 
                gen.writeStringField('message', 'Se ha producido un problema al generar oferta en SAP.');                 
                gen.writeObjectField('warnings', infoList);
                gen.writeStringField('ofertaSAP', ''); 
            } else {                
                // Actualizamos datos de la oportunidad
                Boolean isOk = updateOportunidad(opportunity);
                
                if(isOk) {
                    gen.writeStringField('status', 'Success'); 
                    gen.writeStringField('message', 'Oferta ' + response_x.T_PRPS.item[1].POSKI + ' creada correctamente.'); 
                    gen.writeObjectField('warnings', infoList);
                    gen.writeStringField('ofertaSAP', response_x.T_PRPS.item[1].POSKI); 
                } else {
                    gen.writeStringField('status', 'Error'); 
                    gen.writeStringField('message', 'Se ha producido un problema al actualizar datos de la oportunidad.');                 
                }
            }
            
        } catch (Exception ex) {
            System.debug('Error no esperado al invocar SAP Service YPS_CREAR_OFERTA_CRM_RFC: ' + ex);
            gen.writeStringField('status', 'Error'); 
            gen.writeStringField('message', 'Se ha producido un error al invocar la generación de oferta en SAP.');             
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
    }
    
    /*
public class Empleados {

public Integer id;
public String lang;
public String numeroPersonal;
public String nombre;
public String apellido1;
public String apellido2;
public String usuarioRed;
public String correoElectronico;
public String sociedadCodigo;
public String ceBe;
public String area;
public String responsable;
public String unidadOrganizativa;
public String numeroPersonalSecretaria;
public Boolean expatriado;
public String numeroPersonalExpatriado;
public String proyecto;
public Boolean externo;
public String areaNominas;
public String divisionPersonal;
public String subdivisionPersonal;
public String grupoPersonal;
public String areaPersonal;
public Boolean activo;
public String nombreYApellidos;

}
public static List<Empleados> parse(String json) {
return (List<Empleados>) System.JSON.deserialize(json, List<Empleados>.class);
}*/
}
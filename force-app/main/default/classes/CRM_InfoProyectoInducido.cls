public class CRM_InfoProyectoInducido {

    @AuraEnabled
    public static String checkStatus(String idOpp){
        JSONGenerator results = JSON.createGenerator(true);
        
        System.debug('idOpp: ' + idOpp);
        
        Opportunity opportunity = [select id, Programa_Inductor__c, Innovation_Work_Stream__c, /* SCM - Nuevo campo Innovation_Work_Stream__c */ 
                                      Proyecto_Inductor_1__c, Proyecto_Inductor_2__c, Proyecto_Inductor_3__c, Proyecto_Inductor_4__c,
                                      	Tipo_Induccion_1__c, Tipo_Induccion_2__c, Tipo_Induccion_3__c, Tipo_Induccion_4__c from Opportunity where id = :idOpp];
        
        results.writeStartObject();
        results.writeObjectField('mOpp', opportunity);
        results.writeEndObject();
        
        return results.getAsString();
    }
            
    @AuraEnabled
    public static String getDatosSAP(){
        JSONGenerator results = JSON.createGenerator(true);
        results.writeStartObject();
        
        // ----------- Declaracion de la estructura de respuesta -------------- //
        CRM_ProyInd_SAP_WS_Controller.YPS_SALESFORCE_DATOSResponse_element response_x;
        
        // ----------- Invocacion del servicio SAP -------------- //     
        CRM_ProyInd_SAP_WS_Controller.YWS_SALESFORCE_DATOS soapFunction = new CRM_ProyInd_SAP_WS_Controller.YWS_SALESFORCE_DATOS();        
        
        // ----------- Tratamiento de respuesta --------------- //
        try {   
            response_x= soapFunction.YPS_SALESFORCE_DATOS(new CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_PEPINDUCTOR(), new CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_PRODIGIT_RFC(), new CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_TIPOIDIT_RFC());
            System.debug('Respuesta Completa SAP: ' + response_x);       
                
            CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_PEPINDUCTOR T_PEPINDUCTOR = response_x.T_PEPINDUCTOR;
        	CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_PRODIGIT_RFC T_PROGIDIT = response_x.T_PROGIDIT;
        	CRM_ProyInd_SAP_WS_Controller.TABLE_OF_YPS_TIPOIDIT_RFC T_TIPOIDIT = response_x.T_TIPOIDIT;
            
            // ------------ Recuperacion de Proyectos Inductores --------------------- //
            List<Map<String,String>> proyInductorList = new List<Map<String, String>>();
            proyInductorList.add(new Map<String, String>{'value'=>'', 'label'=>''});
            if (T_PEPINDUCTOR!=null && (T_PEPINDUCTOR.item).size() > 0) { 
                for (integer k=0; k < (T_PEPINDUCTOR.item).size(); k++) {
                    if (T_PEPINDUCTOR.item[k].POSID != null) {
                        proyInductorList.add(new Map<String, String>{'value'=>T_PEPINDUCTOR.item[k].POSID, 'label'=>T_PEPINDUCTOR.item[k].POST1});
                    }
                }
            }     
            System.debug('mProyInductores: ' + proyInductorList); 
            results.writeObjectField('mProyInductores', proyInductorList);
            
            // ------------ Recuperacion de Tipos Inducción --------------------- //
            List<Map<String,String>> tipoInductorList = new List<Map<String, String>>();
            tipoInductorList.add(new Map<String, String>{'value'=>'', 'label'=>''});
            if (T_TIPOIDIT!=null && (T_TIPOIDIT.item).size() > 0) { 
                for (integer k=0; k < (T_TIPOIDIT.item).size(); k++) {
                    if (T_TIPOIDIT.item[k].YTIPOIDI != null && T_TIPOIDIT.item[k].YTIPOIDI != '') {
                        tipoInductorList.add(new Map<String, String>{'value'=>T_TIPOIDIT.item[k].YTIPOIDI, 'label'=>T_TIPOIDIT.item[k].DESCRIPCION, 'lang'=>T_TIPOIDIT.item[k].LANGU});
                    }
                }
            }       
            System.debug('mTiposInduccion: ' + tipoInductorList); 
            results.writeObjectField('mTiposInduccion', tipoInductorList);
            
            // ------------ Recuperacion de Programas --------------------- //
            List<Map<String,String>> progInductorList = new List<Map<String, String>>();
            progInductorList.add(new Map<String, String>{'value'=>'', 'label'=>''});
            if (T_PROGIDIT!=null && (T_PROGIDIT.item).size() > 0) { 
                for (integer k=0; k < (T_PROGIDIT.item).size(); k++) {
                    if (T_PROGIDIT.item[k].YPROGIDI != null && T_PROGIDIT.item[k].YPROGIDI != '') {
                        progInductorList.add(new Map<String, String>{'value'=>T_PROGIDIT.item[k].YPROGIDI, 'label'=>T_PROGIDIT.item[k].DESCRIPCION, 'lang'=>T_PROGIDIT.item[k].LANGU});
                    }
                }
            }   
            System.debug('mProgramas: ' + progInductorList); 
            results.writeObjectField('mProgramas', progInductorList);   
            
            results.writeStringField('status', 'Ok');
            
        } catch (Exception ex) {
            System.debug('Error no esperado al invocar SAP Service YPS_SALESFORCE_DATOS: ' + ex);
            results.writeStringField('status', 'Error'); 
            results.writeStringField('message', 'Se ha producido un error al invocar la recuperación de datos de SAP.');             
        }
        
        results.writeEndObject();
             
        System.debug('getDatosSAP - result: ' + results.getAsString());
        return results.getAsString();
    }
    
    @AuraEnabled
    public static String updateOportunidad(Id idOpp, String programa, String innovationWS, /* SCM - Nuevo campo Innovation_Work_Stream__c */ 
                                           String proyInductor1Str, String proyInductor2Str, String proyInductor3Str, String proyInductor4Str) {
        
        System.debug('idOpp: ' + idOpp);        
        System.debug('programa: ' + programa);
        System.debug('innovationWS: ' + innovationWS);
        System.debug('proyInductor1Str: ' + proyInductor1Str);
        System.debug('proyInductor2Str: ' + proyInductor2Str);
        System.debug('proyInductor3Str: ' + proyInductor3Str);
        System.debug('proyInductor4Str: ' + proyInductor4Str);
        
        Map<String, Object> proyInductor1 = (Map<String, Object>)System.JSON.deserializeUntyped(proyInductor1Str);
        Map<String, Object> proyInductor2 = (Map<String, Object>)System.JSON.deserializeUntyped(proyInductor2Str);
        Map<String, Object> proyInductor3 = (Map<String, Object>)System.JSON.deserializeUntyped(proyInductor3Str);
        Map<String, Object> proyInductor4 = (Map<String, Object>)System.JSON.deserializeUntyped(proyInductor4Str);
        
        
        //Recuperamos datos de la oportunidad
        Opportunity opportunity = [select id, Oferta_SAP__c, Programa_Inductor__c, Proyecto_Inductor_1__c, Proyecto_Inductor_2__c, Proyecto_Inductor_3__c, Proyecto_Inductor_4__c,
                                      	Tipo_Induccion_1__c, Tipo_Induccion_2__c, Tipo_Induccion_3__c, Tipo_Induccion_4__c from Opportunity where id = :idOpp];
        System.debug('Oferta_SAP__c: ' + opportunity.Oferta_SAP__c);
        
        //Si ya existe código de oferta SAP, actualizamos datos en SAP
        boolean isOkUpdSAP = true;
        Map<String, Object> resultMap;
        if(!String.isBlank(opportunity.Oferta_SAP__c)) {
            String result = updateInfoProyIndSAP(opportunity.Oferta_SAP__c, programa, proyInductor1, proyInductor2, proyInductor3, proyInductor4);
            
            resultMap = (Map<String, Object>)System.JSON.deserializeUntyped(result);
            isOkUpdSAP = (String)resultMap.get('status') == 'Ok';
            System.debug('Resultado de la actualización de información de proyectos inductores en SAP: ' + isOkUpdSAP);
        }
        
        JSONGenerator result = JSON.createGenerator(true); 
        result.writeStartObject();
        if(!isOkUpdSAP) {
            result.writeStringField('status', 'Error'); 
            result.writeStringField('message', 'No se ha podido actualizar la información de proyectos inductores en SAP.');
            result.writeObjectField('warnings', (List<Object>)resultMap.get('warnings'));
        } else {                                           
            opportunity.Programa_Inductor__c = programa;
            opportunity.Proyecto_Inductor_1__c = (String)proyInductor1.get('proyInductor');
            opportunity.Tipo_Induccion_1__c = (String)proyInductor1.get('tipoInduccion');
            opportunity.Proyecto_Inductor_2__c = (String)proyInductor2.get('proyInductor');
            opportunity.Tipo_Induccion_2__c = (String)proyInductor2.get('tipoInduccion');
            opportunity.Proyecto_Inductor_3__c = (String)proyInductor3.get('proyInductor');
            opportunity.Tipo_Induccion_3__c = (String)proyInductor3.get('tipoInduccion');
            opportunity.Proyecto_Inductor_4__c = (String)proyInductor4.get('proyInductor');
            opportunity.Tipo_Induccion_4__c = (String)proyInductor4.get('tipoInduccion');            
            
            try {
                opportunity.Innovation_Work_Stream__c = innovationWS;  /* SCM - El nuevo campo Innovation_Work_Stream__c no viaja a SAP*/ 
                update opportunity;
                System.debug('Oportunidad actualizada correctamente.');
                               
                result.writeStringField('status', 'Ok'); 
                result.writeStringField('message', 'Información de proyectos inductores actualizada correctamente.');
                result.writeObjectField('opportunity', opportunity);
            } catch (DMLException ex) {
                System.debug('Error al actualizar la información de proyectos inductores: ' + ex.getMessage());
                
                List<String> infoList = new List<String>();
                infoList.add(ex.getMessage());
                
                result.writeStringField('status', 'Error'); 
                result.writeStringField('message', 'No se ha podido actualizar la información de proyectos inductores. ' + ex.getMessage()); 
                result.writeObjectField('warnings', infoList);
            }  
        }
        
        result.writeEndObject();
        return result.getAsString();
    }
    
    private static String updateInfoProyIndSAP(String codOfertaSAP, String programa, Map<String, Object> proyInductor1, Map<String, Object> proyInductor2, Map<String, Object> proyInductor3, Map<String, Object> proyInductor4) {
		        
        // ----------- Declaracion de la estructura de respuesta -------------- //
        CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element response_x;
        
        // ----------- Invocacion del servicio SAP -------------- //     
        CRM_ProyIndUpd_SAP_WS_Controller.YWS_SALESFORCE_MODIF soapFunction = new CRM_ProyIndUpd_SAP_WS_Controller.YWS_SALESFORCE_MODIF();        
        
        // ----------- Tratamiento de respuesta --------------- //
        List<String> infoList = new List<String>();
        JSONGenerator result = JSON.createGenerator(true); 
        result.writeStartObject();
        try {   
            response_x= soapFunction.YPS_SALESFORCE_MODIF(codOfertaSAP, (String)proyInductor1.get('proyInductor'), (String)proyInductor2.get('proyInductor'), (String)proyInductor3.get('proyInductor'), (String)proyInductor4.get('proyInductor'),
                                                          programa, (String)proyInductor1.get('tipoInduccion'), (String)proyInductor2.get('tipoInduccion'), (String)proyInductor3.get('tipoInduccion'), (String)proyInductor4.get('tipoInduccion'),
                                                          new CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2());
            System.debug('Respuesta Completa SAP: ' + response_x);  
            			            
            if(String.isBlank(response_x.P_OK)) {                
                CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2 BAPIRET2_Error_Table = response_x.T_RETURN;
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
                
                result.writeStringField('status', 'Error'); 
                result.writeStringField('message', 'Se ha producido un problema al actualizar la información de proyectos inductores en SAP.');                 
                result.writeObjectField('warnings', infoList); 
                
            } else {
                result.writeStringField('status', 'Ok'); 
                result.writeStringField('message', 'Información de proyectos inductores actualizada correctamente.'); 
            }
                        
        } catch (Exception ex) {
            System.debug('Error no esperado al invocar SAP Service YPS_SALESFORCE_MODIF: ' + ex); 
            infoList.add(ex.getMessage());
            result.writeStringField('status', 'Error'); 
            result.writeStringField('message', 'Se ha producido un problema no controlado al actualizar la información de proyectos inductores en SAP.');                 
            result.writeObjectField('warnings', infoList);
        }
        
        result.writeEndObject();
        return result.getAsString();
    }
}
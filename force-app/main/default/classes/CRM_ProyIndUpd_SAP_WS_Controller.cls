//Generated by wsdl2apex

public class CRM_ProyIndUpd_SAP_WS_Controller {
    public class YPS_SALESFORCE_MODIF_element {
        public String OFERTA_MOD;
        public String POSID_IND1;
        public String POSID_IND2;
        public String POSID_IND3;
        public String POSID_IND4;
        public String PROGRAMA;
        public CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2 T_RETURN;
        public String YTIPOIDI1;
        public String YTIPOIDI2;
        public String YTIPOIDI3;
        public String YTIPOIDI4;
        private String[] OFERTA_MOD_type_info = new String[]{'OFERTA_MOD','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] POSID_IND1_type_info = new String[]{'POSID_IND1','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] POSID_IND2_type_info = new String[]{'POSID_IND2','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] POSID_IND3_type_info = new String[]{'POSID_IND3','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] POSID_IND4_type_info = new String[]{'POSID_IND4','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] PROGRAMA_type_info = new String[]{'PROGRAMA','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] T_RETURN_type_info = new String[]{'T_RETURN','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] YTIPOIDI1_type_info = new String[]{'YTIPOIDI1','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] YTIPOIDI2_type_info = new String[]{'YTIPOIDI2','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] YTIPOIDI3_type_info = new String[]{'YTIPOIDI3','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] YTIPOIDI4_type_info = new String[]{'YTIPOIDI4','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'OFERTA_MOD','POSID_IND1','POSID_IND2','POSID_IND3','POSID_IND4','PROGRAMA','T_RETURN','YTIPOIDI1','YTIPOIDI2','YTIPOIDI3','YTIPOIDI4'};
    }
    public class BAPIRET2 {
        public String TYPE_x;
        public String ID;
        public String NUMBER_x;
        public String MESSAGE;
        public String LOG_NO;
        public String LOG_MSG_NO;
        public String MESSAGE_V1;
        public String MESSAGE_V2;
        public String MESSAGE_V3;
        public String MESSAGE_V4;
        public String PARAMETER;
        public Integer ROW;
        public String FIELD;
        public String SYSTEM_x;
        private String[] TYPE_x_type_info = new String[]{'TYPE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ID_type_info = new String[]{'ID','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NUMBER_x_type_info = new String[]{'NUMBER','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_type_info = new String[]{'MESSAGE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LOG_NO_type_info = new String[]{'LOG_NO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LOG_MSG_NO_type_info = new String[]{'LOG_MSG_NO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V1_type_info = new String[]{'MESSAGE_V1','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V2_type_info = new String[]{'MESSAGE_V2','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V3_type_info = new String[]{'MESSAGE_V3','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V4_type_info = new String[]{'MESSAGE_V4','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PARAMETER_type_info = new String[]{'PARAMETER','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ROW_type_info = new String[]{'ROW','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] FIELD_type_info = new String[]{'FIELD','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SYSTEM_x_type_info = new String[]{'SYSTEM','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'TYPE_x','ID','NUMBER_x','MESSAGE','LOG_NO','LOG_MSG_NO','MESSAGE_V1','MESSAGE_V2','MESSAGE_V3','MESSAGE_V4','PARAMETER','ROW','FIELD','SYSTEM_x'};
    }
    public class YPS_SALESFORCE_MODIFResponse_element {
        public String P_OK;
        public CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2 T_RETURN;
        private String[] P_OK_type_info = new String[]{'P_OK','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] T_RETURN_type_info = new String[]{'T_RETURN','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'P_OK','T_RETURN'};
    }
    public class TABLE_OF_BAPIRET2 {
        public CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class YWS_SALESFORCE_MODIF {
        //public String endpoint_x = 'http://VMERPDES00.ayesa.es:1080/sap/bc/srt/rfc/sap/yws_salesforce_modif/300/yws_salesforce_modif/yws_salesforce_modif';
        public String endpoint_x = 'callout:SAP_Credentials/sap/bc/srt/rfc/sap/yws_salesforce_modif/300/yws_salesforce_modif/yws_salesforce_modif';
        
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions', 'CRM_ProyIndUpd_SAP_WS_Controller'};
        
        public CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element YPS_SALESFORCE_MODIF(String OFERTA_MOD,String POSID_IND1,String POSID_IND2,String POSID_IND3,String POSID_IND4,String PROGRAMA,String YTIPOIDI1,String YTIPOIDI2,String YTIPOIDI3,String YTIPOIDI4,CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2 T_RETURN) {
            CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIF_element request_x = new CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIF_element();
            request_x.OFERTA_MOD = OFERTA_MOD;
            request_x.POSID_IND1 = POSID_IND1;
            request_x.POSID_IND2 = POSID_IND2;
            request_x.POSID_IND3 = POSID_IND3;
            request_x.POSID_IND4 = POSID_IND4;
            request_x.PROGRAMA = PROGRAMA;
            request_x.T_RETURN = T_RETURN;
            request_x.YTIPOIDI1 = YTIPOIDI1;
            request_x.YTIPOIDI2 = YTIPOIDI2;
            request_x.YTIPOIDI3 = YTIPOIDI3;
            request_x.YTIPOIDI4 = YTIPOIDI4;
            CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element response_x;
            Map<String, CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element> response_map_x = new Map<String, CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element>();
            response_map_x.put('response_x', response_x);
            
            System.debug('endpoint_x: ' + endpoint_x);
            if(!Test.isRunningTest()){
                try {
                    WebServiceCallout.invoke(
                      this,
                      request_x,
                      response_map_x,
                      new String[]{endpoint_x,
                      'urn:sap-com:document:sap:rfc:functions:YWS_SALESFORCE_MODIF:YPS_SALESFORCE_MODIFRequest',
                      'urn:sap-com:document:sap:rfc:functions',
                      'YPS_SALESFORCE_MODIF',
                      'urn:sap-com:document:sap:rfc:functions',
                      'YPS_SALESFORCE_MODIFResponse',
                      'CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element'}
                    );
                	response_x = response_map_x.get('response_x');
                } catch (Exception ex) {
                    System.debug('Error no esperado al invocar SAP Service YPS_SALESFORCE_MODIF: ' + ex);                       
                }
            } else {
                System.debug('Respuesta dummy para test...');
                response_x = new CRM_ProyIndUpd_SAP_WS_Controller.YPS_SALESFORCE_MODIFResponse_element(); //para TEST
                response_x.T_RETURN = new CRM_ProyIndUpd_SAP_WS_Controller.TABLE_OF_BAPIRET2();
                response_x.T_RETURN.item = new List<CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2>();
                response_x.T_RETURN.item.add(new CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2());
                
                
                if(OFERTA_MOD.length() == 12) response_x.P_OK = 'OK';
                /*response_x.T_RETURN.item = new List<CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2>();
                CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2 BAPIRET2 = new CRM_ProyIndUpd_SAP_WS_Controller.BAPIRET2();
                BAPIRET2.TYPE_x = 
                response_x.T_RETURN.item.add(BAPIRET2);*/
            }           
            
            System.debug('Respuesta de SAP Service YPS_SALESFORCE_MODIF...');
            System.debug('  response_map_x: ' + response_map_x);
            System.debug('  response_x: ' + response_x);
            
            return response_x;
        }
    }
}
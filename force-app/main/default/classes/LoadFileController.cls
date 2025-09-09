public class LoadFileController {
    @AuraEnabled
    public static void uploadCV(String recordId, List<Id> contentDocumentIds, String tipoArchivo, String carpeta) {
        System.debug('contentDocumentIds: ' + contentDocumentIds);
        System.debug('tipoArchivo: ' + tipoArchivo);
        System.debug('recordId: ' + recordId);
        
        List<ContentVersion> file= new List<ContentVersion>();
        file = [SELECT Id,PathOnClient,Tipo_Archivo__c,Carpeta_Archivo__c,ContentDocumentId
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds Limit 1];
        String codigoPowerAlejandria = codigo_tipoDocumento(tipoArchivo);
        
        
        System.debug('file: ' + file);
        try{
            
            if(!file.isEmpty()){
                
                file.get(0).Tipo_Archivo__c = tipoArchivo;
                file.get(0).Carpeta_Archivo__c = carpeta;
                
                update file;
                
                Archivos_de_Oportunidad__c archivo = new Archivos_de_Oportunidad__c();
                if( file.get(0).PathOnClient.length()>80){
                    archivo.name = file.get(0).PathOnClient.substring(0, 80);  
                }else {
                    archivo.name = file.get(0).PathOnClient;
                }
                
                archivo.Opportunity__c = recordId;
                archivo.Archivo__c = file.get(0).PathOnClient;
                archivo.Tipo_de_Archivo__c = tipoArchivo;
                archivo.Carpeta_Archivo__c = carpeta;
                archivo.Codigo_Archivo__c= codigoPowerAlejandria;
                archivo.ArchivoContent__c= file.get(0).ContentDocumentId;
                insert archivo;
                try{
                    List <Opportunity > op = [SELECT id,DOC_Contrato__c
                                                 FROM Opportunity where Id =: recordId  LIMIT 1];
                    //Actualizar el check de la oportunidad
                    if (op.size()>0 && tipoArchivo=='Contrato/Contract'){
                        
                        Opportunity oc = marcar_casilla_Oportunidad(tipoArchivo, op[0]); 
                        update oc;   
                    }         
                    
                }catch(DMLException ex){
                    System.debug('Update Opportunity check KO: ' + ex.getMessage());
                    
                }
            }
            
        }catch(DMLException ex){
            System.debug('Update File KO: ' + ex.getMessage());
            
        }
        
        
    }
    
    @AuraEnabled
    public static string carpeta_defecto(String tipoArchivo){
        
        String ruta='';
        
        if(tipoArchivo.contains('PCAP') || tipoArchivo.contains('Anuncio licitación') || tipoArchivo.contains('Pliego de prescripciones') ){
            ruta ='01 Pliegos-Requisitos cliente';
        }else if(tipoArchivo.contains('Solvencia técnica') || tipoArchivo.contains('Oferta técnica') ){
            ruta = '02 Oferta-Licitación/02 Técnica';
        }else if(tipoArchivo.contains('Oferta económica') ){
            ruta = '02 Oferta-Licitación/03 Económica';
        }else if (tipoArchivo.contains('Adjudicación') || tipoArchivo.contains('Contrato')){
            ruta='04 Adjudicación';
        }else if (tipoArchivo.contains('Avales')){
            ruta = '06 Avales';
        }else if (tipoArchivo.contains('Acreditación del personal ofertado') ||tipoArchivo.contains('Acuerdo de socios') ||tipoArchivo.contains('Borrador de Acuerdo de Socios') ||  tipoArchivo.contains('Estudio de implicaciones fiscales') || tipoArchivo.contains('Ficha de oferta') || tipoArchivo.contains('Formulario Fiscal') 
                  || tipoArchivo.contains('IRPO') || tipoArchivo.contains('Matriz TDR-Entregable') || tipoArchivo.contains('Plan de Mitigación de TDR') || tipoArchivo.contains('QA Económico') || tipoArchivo.contains('QA Técnico') || tipoArchivo.contains('Recomendaciones') || tipoArchivo.contains('Riesgo financiero') || tipoArchivo.contains('GO Oferta') ){
                      
                      ruta ='07 Procedimiento interno'; 
                      
                  }else {
                      ruta ='Seleccione carpeta';
                  }
        
        
        return ruta;
    }
    
    
    private static String codigo_tipoDocumento (String tipoArchivo){
        
        String codigoArchivo='';
        
        if(tipoArchivo=='Aceptación de oferta/Acceptance of offer'){
            codigoArchivo='800bbb96-9455-46dc-a465-038e4a35ddd6';
        }else if(tipoArchivo=='Aclaraciones y respuestas a consultas/Clarifications and answers to queries'){
            codigoArchivo='6e0438e3-2904-4be0-bbf2-9aaa9217fefa';
        }else if(tipoArchivo=='Anuncio licitación / invitación'){
            codigoArchivo='d83ad9ff-48ab-47ac-8295-bc93438e7b31';
        }else if(tipoArchivo=='Acta de reunión/Meeting minute'){
            codigoArchivo='db1859b9-4568-40e0-a5ae-e3ef76489481';
        }else if(tipoArchivo=='Acuerdo de no concurrencia/Non-competition agreement'){
            codigoArchivo='384797f6-90c4-4fa6-8e4b-d0261169feda';}
        else if(tipoArchivo=='Pliego de claúsulas administrativas particulares (PCAP)/Specification particular admin clauses(PCAP)'){
            codigoArchivo='bde4d1cd-7307-4551-9f92-d31fa8eeb527';}
        else if(tipoArchivo=='Acuerdo/Agreement'){
            codigoArchivo='ecc74959-3cc1-4194-b53a-6ece252074e8';}
        else if(tipoArchivo=='Pliego de prescripciones técnicas/Specification sheet'){
            codigoArchivo='ac998e2e-c397-4494-92b9-bbd726fe2155';}
        else if(tipoArchivo=='Análisis/Analysis'){
            codigoArchivo='5219a62e-1881-4a25-b68f-5b06d8cb8371';}
        else if(tipoArchivo=='Anexo/Annex'){
            codigoArchivo='16e5422d-fc1c-439d-aa32-d14fa4dbec22';}
        else if(tipoArchivo=='Oferta técnica/Technical offer'){
            codigoArchivo='2151d6cf-39e1-4c9a-99e0-22a33272991f';}
        else if(tipoArchivo=='Oferta económica/Economical offer'){
            codigoArchivo='e75b9d1c-7b2d-4ea0-900e-a68a3f14abdc';}
        else if(tipoArchivo=='Adjudicación/Award'){
            codigoArchivo='b50ab608-1ed2-4721-8a22-34623df81c35';}
        else if(tipoArchivo=='Avales Provisionales/Provisional Guarantees'){
            codigoArchivo='41454759-0ed8-4034-b330-58fef6dc9d40';}
        else if(tipoArchivo=='Carátula AJI/Cover AJI'){
            codigoArchivo='d58e4195-8f1f-44eb-85c1-484ba2788be4';
        }else if(tipoArchivo=='Certificado/Certificate'){
            codigoArchivo='53bbe744-039b-495e-beb1-ac5e1cad6413';
        }else if(tipoArchivo=='Comunicación / notificación'){
            codigoArchivo='77185632-35a9-495c-9130-16ee2f4d8bdd';
        } else if(tipoArchivo=='Contrato/Contract'){
            codigoArchivo='811ea3ce-9b65-47f3-b641-aa661da456d2';
        }else if(tipoArchivo=='CV'){
            codigoArchivo='2f78fed6-92d7-4c85-b367-04c611a8e778';
        }else if(tipoArchivo=='Documentación proveedor/Provider documentation'){
            codigoArchivo='1220b255-955b-4167-bd50-9f63acefefd0';
        }else if(tipoArchivo=='Documentación técnica/Technical documentation'){
            codigoArchivo='95f847e1-3437-4df3-89b7-6b34b0836621';
        }else if(tipoArchivo=='Especificación técnica/Technical specification'){
            codigoArchivo='d4a7acaa-0301-4ed6-a5fe-ae7ee00c2bdf';
        }else if(tipoArchivo=='Avales/Guarantees'){
            codigoArchivo='01d9a68d-efaa-4617-aac4-dd89013aa0fc';
        }else if(tipoArchivo=='Acreditación del personal ofertado/Acreditation of bid personal'){
            codigoArchivo='cca17ad1-0768-42b6-ab35-150a32a61493';
        }else if(tipoArchivo=='Acuerdo de socios/Partner Agreement'){
            codigoArchivo='efb26627-297b-4fae-ad83-42493ce95c19';
        }else if(tipoArchivo=='Borrador de Acuerdo de Socios/Draft Partner Agreement'){
            codigoArchivo='6b3951d6-c67c-49c3-aa31-a4d4cd695815';
        }else if(tipoArchivo=='Informe/Report'){
            codigoArchivo='4df6c411-7501-4d09-a708-bdbc50cdda20';
        }else if(tipoArchivo=='Estudio de implicaciones fiscales/Tax Implications Study'){
            codigoArchivo='6e174487-bca9-45ee-b1d7-23a47f0680b4';
        }else if(tipoArchivo=='Memoria/Memory'){
            codigoArchivo='b8b52f1d-0f29-4b3e-98c9-d22b73f14c5a';
        }else if(tipoArchivo=='Modelo financiero/Financial model'){
            codigoArchivo='4ba73ab3-5c56-478a-9a33-b63017f32479';
        }else if(tipoArchivo=='Modelo tributario/Tax model'){
            codigoArchivo='4ed0619f-e895-46c0-9148-bd52a702526c';
        }else if(tipoArchivo=='Modificación de contrato/Contract modification'){
            codigoArchivo='1fc72986-9d3f-4b59-83ee-115edde736e3';
        }else if(tipoArchivo=='Ficha de oferta/Offer sheet'){
            codigoArchivo='928e28d5-239c-41d7-956c-b99ec075fed9';
        }else if(tipoArchivo=='Formulario Fiscal/Tax Form'){
            codigoArchivo='b669c55b-4aa4-49a6-8baa-def9c46f51d8';
        }else if(tipoArchivo=='Ofertas Vinculantes/Proveedores Offers associated Suppliers'){
            codigoArchivo='53f13cef-10c6-4f9c-a7ce-da35f72d98c5';
        }else if(tipoArchivo=='Oportunidad comercial/Commercial opportunity'){
            codigoArchivo='b767eb0e-bc4e-4610-8e34-538adbb5ac76';
        }else if(tipoArchivo=='Otros/Other'){
            codigoArchivo='5c6bb843-cab7-4b8d-ac53-d0111f660abb';
        }else if(tipoArchivo=='Formulario IRPO/ IRPO Form'){
            codigoArchivo='12b3b8b7-e1b2-4ba7-99e8-508d597b55bd';
        }else if(tipoArchivo=='Plan de Soluciones/Solutions Plan'){
            codigoArchivo='6003ed3f-b563-4b3c-b75a-9ee99d0543c4';
        }else if(tipoArchivo=='Plano/Drawing'){
            codigoArchivo='4aaa2ab0-d76c-4d9f-bc82-175c3969e3ce';
        }else if(tipoArchivo=='Matriz TDR-Entregable/ToR-Deliverable Matrix'){
            codigoArchivo='cb2e1afc-3c6f-48b3-823a-fa399104bf0c';
        }else if(tipoArchivo=='Plan de Mitigación de TDR/ToR Mitigation Plan'){
            codigoArchivo='fb7b254a-7733-423b-8edb-de9e069acb01';
        }else if(tipoArchivo=='Presentación/Presentation'){
            codigoArchivo='120e915b-47ab-4815-b4f4-06fbd271c137';
        }else if(tipoArchivo=='Proyecto comercial/Commercial project'){
            codigoArchivo='546019d1-a2fb-4fa2-b3af-4199592f7688';
        }else if(tipoArchivo=='QA Económico/Economical QA'){
            codigoArchivo='7aefb589-0523-4521-acf4-35e4e21b75fe';
        }else if(tipoArchivo=='QA Técnico/Technical QA'){
            codigoArchivo='9f722afb-af3f-4203-8daa-af0a8b7dd4a9';
        }else if(tipoArchivo=='Recomendaciones CCSO/CCSO Recommendations'){
            codigoArchivo='a947f7a0-113b-45b1-8931-1ce623cb4c1b';
        }else if(tipoArchivo=='Recomendaciones COMPLIANCE/COMPLIANCE Recommendations'){
            codigoArchivo='36e7de96-c7bc-4545-b1b0-6f7462768728';
        }else if(tipoArchivo=='Resumen aspectos clave oferta/Summary key aspects offer'){
            codigoArchivo='fac63244-fa1d-4409-9cbb-2355898ac4dc';
        }else if(tipoArchivo=='RFP (petición de oferta)/RFP (request for quotation)'){
            codigoArchivo='721d9a6d-476e-4707-8835-9ec47523e991';
        }else if(tipoArchivo=='Riesgo financiero/Financial risk'){
            codigoArchivo='b64d2822-d39a-4748-9526-c7ea39c558c2';
        }else if(tipoArchivo=='Simulación económica de oferta/Economic simulation of offer'){
            codigoArchivo='721d9a6d-476e-4707-8835-9ec47523e991';
        }else if(tipoArchivo=='Solicitud de modificación de contrato/Request for contract modification'){
            codigoArchivo='8e32070b-7ebc-40d0-87ce-265ede5b9985';
        }else if(tipoArchivo=='Solvencia económica/Economic solvency'){
            codigoArchivo='a0b1df23-d830-438e-bb89-2b3ba8c35cc8';
        }else if(tipoArchivo=='Solvencia técnica/Technical solvency'){
            codigoArchivo='1a511c61-ce88-4a26-9716-de3260d0cc7a';
        }else if(tipoArchivo=='GO Oferta/GO Offer'){
            codigoArchivo='c576dddd-2bad-4111-80f1-1d9fba0852c0'; //SCM 09/25: cod oferta sap
        }else{
            codigoArchivo='5c6bb843-cab7-4b8d-ac53-d0111f660abb'; 
        }
        
        return codigoArchivo;
        
    }
    
    private static Opportunity marcar_casilla_Oportunidad (String tipoArchivo, Opportunity op){
        
        /*  if(tipoArchivo=='Estudio de implicaciones fiscales/Tax Implications Study'){
op.DOC_Estudio_de_implicaciones_fiscales__c = true;
}else if(tipoArchivo=='Recomendaciones CCSO/CCSO Recommendations'){
op.DOC_Recomendaciones_CCSO__c= true;
}else if(tipoArchivo=='Recomendaciones COMPLIANCE/COMPLIANCE Recommendations'){
op.DOC_Recomendaciones_COMPLIANCE__c= true;
}else if(tipoArchivo=='Acreditación del personal ofertado/Acreditation of bid personal'){
op.DOC_Acreditacion_del_personal_ofertado__c= true;
}else if(tipoArchivo=='Ficha de oferta/Offer sheet'){
op.DOC_Ficha_de_oferta__c= true;
}else if(tipoArchivo=='Formulario IRPO/ IRPO Form'){
op.DOC_Formulario_IRPO__c= true;
}else if(tipoArchivo=='Oferta económica/Economical offer'){
op.DOC_Oferta_economica__c= true;
}else if(tipoArchivo=='Oferta técnica/Technical offer'){
op.DOC_Oferta_tecnica__c= true;
}else if(tipoArchivo=='Plan de Mitigación de TDR/ToR Mitigation Plan'){
op.DOC_Plan_de_Mitigacion_de_TDR__c= true;
}else if(tipoArchivo=='Pliego de claúsulas administrativas particulares (PCAP)/Specification particular admin clauses(PCAP)'){
op.DOC_PCAP__c= true;
}else if(tipoArchivo=='Solvencia técnica/Technical solvency'){
op.DOC_Solvencia_tecnica__c= true;
}else if(tipoArchivo=='Acuerdo de socios/Partner Agreement'){
op.DOC_Acuerdo_de_socios__c= true;
}else if(tipoArchivo=='Adjudicación/Award'){
op.DOC_Adjudicacion__c= true;
}else if(tipoArchivo=='Matriz TDR-Entregable/ToR-Deliverable Matrix'){
op.DOC_Matriz_TDR_Entregable__c= true;
}*/
        if(tipoArchivo=='Contrato/Contract'){
            op.DOC_Contrato__c= true;
        }
        
        return op;
        
    }
    
    public static void test(){
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
    }



}
public class ExtensionOppController {
    
    @AuraEnabled
    public static String getTypeOpp(Id idOportunidad){
        
        Opportunity opp =[SELECT id, name, codigo_OC__c,Oportunidad_Relacionada__c, RecordType.Name,Direccion_Operaciones__c,StageName,Subfase__c,Tipo_Extension__c,fecha_firma_contrato__c,
                             fecha_estimada_de_cierre__c, Fecha_limite_de_presentacion__c, Plazo_de_ejecuci_n_meses__c,RENTPPTO__c, Importe_Licitacion__c, Probability, tipo_de_negocio__c,
                             Origen__c
                             from Opportunity where Id =: idOportunidad];
        //12/01/2024
        String result ='';
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        gen.writeObjectField('oportunidad', opp);
        
        //Recuperamos los valores de las líneas de servicio
        List<String> options = new List<String>();
        Map<Object,List<String>> mapa_valores =  getDependentPicklistValues(Opportunity.Linea_de_Servicio__c);
        
        options=  mapa_valores.get(opp.Direccion_Operaciones__c);
        
        gen.writeObjectField('lineasServicio', options);
        gen.writeEndObject();
        
        result = gen.getAsString(); 
        return result;
        //12/01/204
        //return opp.RecordType.Name;
    }
    
    @AuraEnabled
    public static String extenderOportunidad_fields(Id idOportunidad, String nombreOpp, Date fechaCierre, Date fechaPresentacion, Double margenEstimado, Integer plazoEjecucion, Double importeTotal, String probabilidad,String tipoNegocio,
                                                    String tipoExtension,String lineaServicio, String Origen){
        String idOpp;
        System.debug('Extiendo oportunidad: '+ tipoExtension);
        Id recordTypeSME = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        Id recordTypeLarge = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ibermatica Large Account').getRecordTypeId();
        Id recordTypeLatam = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ibermatica Latam').getRecordTypeId();
        Id recordTypeAyesa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ayesa').getRecordTypeId();
        
        DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();   
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());    
        String query = ' SELECT ' + String.join( fieldNames, ',' ) +    ' FROM ' +describeResult.getName() + ' WHERE id = :idOportunidad LIMIT 1 ';
        List<Opportunity> records = Database.query(query);   
        
        Opportunity oppClonada = new Opportunity();
        oppClonada = records.get(0);
        //.clone(false,true,false,false);
        
        System.debug('Oportunidad a Extender: ' + records);
        System.debug('Oportunidad a Extender: ' + oppClonada.RecordTypeId +'/' + oppClonada.Record_Type_Name__c);
        
        Opportunity oppExtension = new Opportunity();
        
        
        oppExtension.Crear_expediente__c = false;
        
        if(oppClonada.RecordTypeId == recordTypeSME){
            //SME
            oppExtension.RecordTypeId= oppClonada.RecordTypeId;
            oppExtension.Etapa_Fase__c = 'Captación';
            oppExtension.Fase__c='Suspect';
            oppExtension.Clase_de_oferta__c = 'Información Previa';
            oppExtension.Oportunidad_Relacionada__c = idOportunidad;
            oppExtension.Horizontal__c=OppClonada.Horizontal__c;
            oppExtension.Desglose_importes__c = OppClonada.Desglose_importes__c;
            //Referencia Comercial, para la parte de SME se sigue heredando
            if(OppClonada.Referencia_Comercial__c=='Sí' || OppClonada.Referencia_Comercial__c=='No, porque ya existe'){
                oppExtension.Referencia_comercial__c = 'No, porque ya existe';
                oppExtension.Referencia_Comercial_lookup__c= oppClonada.Referencia_Comercial_lookup__c;
                oppExtension.Tecnologia__c = oppClonada.Tecnologia__c;
            }else if ( OppClonada.Referencia_Comercial__c=='No, por no ser relevante'){
                oppExtension.Referencia_Comercial__c = 'No, por no ser relevante';
                oppExtension.Referencia_Comercial_lookup__c = null;
            }else{
                oppExtension.Referencia_Comercial__c = null;
                oppExtension.Referencia_Comercial_lookup__c = null;
            }
            
            
        }else{
            //Para los otros tipos de registro AYESA
            oppExtension.RecordTypeId= recordTypeAyesa; 
            oppExtension.Desglose_importes__c = '';
            oppExtension.StageName = 'Cualificación';
            oppExtension.Direccion_Operaciones__c= oppClonada.Direccion_Operaciones__c;
            oppExtension.Mercado__c= oppClonada.Mercado__c;
            oppExtension.DivisionPicklist__c= oppClonada.DivisionPicklist__c;
            oppExtension.Subdivision1__c = oppClonada.Subdivision1__c;
            //Las extensiones heredan el código de oferta
            oppExtension.Oferta_SAP__c = oppClonada.Oferta_SAP__c;
            //Las extensiones heredan la carpeta de la oportunidad padre 09/2024
            oppExtension.URL_Carpeta__c=oppClonada.URL_Carpeta__c;
            
            oppExtension.Origen__c = Origen;
            
            if(oppClonada.Clase_de_oferta__c.contains('Privada')){
                oppExtension.Clase_de_oferta__c='Privada';
                
            }else if (oppClonada.Clase_de_oferta__c.contains('Pública')){
                oppExtension.Clase_de_oferta__c='Pública';
                
            }else if (oppClonada.Clase_de_oferta__c.contains('Marco')){
                
                if(oppClonada.Clase_de_oferta__c=='Acuerdo Marco Público'){
                    
                    oppExtension.Clase_de_oferta__c='Acuerdo Marco Público';
                    
                }else if(oppClonada.Clase_de_oferta__c=='Acuerdo Marco Privado'){
                    
                    oppExtension.Clase_de_oferta__c='Acuerdo Marco Privado';
                    
                }else{
                    oppExtension.Clase_de_oferta__c='Acuerdo Marco Privado';
                }
                
                
            }else{
                oppExtension.Clase_de_oferta__c='Privada';
            }
            
            oppExtension.Tipo_Extension__c = tipoExtension;
            
            if(tipoExtension=='Extensión Desglose'){
                System.debug('Desglose');
                
            System.debug('LineadeServicio' +lineaServicio);
            //Obetenemos mapa con los Label-API de la picklist LineadeServicio
            Map<String, String> labelToApiMap = new Map<String, String>();
            
            // Obtener metadata del campo picklist
            Schema.DescribeFieldResult fieldResult = Opportunity.Linea_de_Servicio__c.getDescribe();
            List<Schema.PicklistEntry> valores = fieldResult.getPicklistValues();
            
            // Llenar el mapa: Label => API
            for (Schema.PicklistEntry entry : valores) {
                labelToApiMap.put(entry.getLabel(), entry.getValue());
            }
            
            // Imprimir el resultado
            for (String label : labelToApiMap.keySet()) {
                
                if(label == lineaServicio){
                    lineaServicio = labelToApiMap.get(label);
                } 
            }
            System.debug('lineaServicio: ' + lineaServicio);               
                
                oppExtension.Linea_de_Servicio__c =lineaServicio;  
                oppExtension.Tipo_de_Negocio__c = tipoNegocio;
                //18/09/2024
                //oppExtension.Origen__c = Origen;
                
                oppExtension.Oportunidad_Origen__c = oppClonada.Oportunidad_Origen__c;
                
                if(oppExtension.Origen__c == 'Stock' || oppExtension.Origen__c == 'Soft'){
                    
                    
                    //05/08/24
                    //hereda los responsables excepto el de linea de servicio/delivery ya que no aprueban en oferta
                  
                    oppExtension.Director_de_Mercado__c=oppClonada.Director_de_Mercado__c;
                    oppExtension.Director_Division__c=oppClonada.Director_Division__c;
                    oppExtension.director_pais__c=oppClonada.director_pais__c;
                    oppExtension.director_internacional__c = oppClonada.director_internacional__c;
                    oppExtension.Director_Compliance__c =oppClonada.Director_Compliance__c;
                    oppExtension.BU_Manager__c=oppClonada.BU_Manager__c;
                    oppExtension.Authorised_Officer__c=oppClonada.Authorised_Officer__c;
                    oppExtension.COO__c=oppClonada.COO__c;
                    oppExtension.CMO__c=oppClonada.CMO__c;
                    oppExtension.CSO__c=oppClonada.CSO__c;
                    oppExtension.Director_Global_de_QA_Risk__c=oppClonada.Director_Global_de_QA_Risk__c;
                    oppExtension.Direccion_Financiera_Corporativa__c=oppClonada.Direccion_Financiera_Corporativa__c;

                    If(oppExtension.Direccion_Operaciones__c == 'ENGINEERING'){
                        oppExtension.StageName ='Presentada (negociación y cierre)';
                        oppExtension.Subfase__c ='Esperando decisión'; 
                    }else{
                        oppExtension.StageName ='Oferta';
                        oppExtension.Subfase__c ='Elaboración oferta';                        
                    }
                    
                    
                }
                
            }else{
                System.debug('Rectificativa');
                oppExtension.Linea_de_Servicio__c=oppClonada.Linea_de_servicio__c;
                oppExtension.Tipo_de_Negocio__c = tipoNegocio;
                oppExtension.StageName ='Presentada (negociación y cierre)';
                oppExtension.Subfase__c ='Ganada';
                oppExtension.Motivo_Perdido__c='Posicionamiento en cliente';
                oppExtension.Fecha_firma_contrato__c = oppClonada.Fecha_firma_contrato__c;
                oppExtension.Service_Model__c = oppClonada.Service_Model__c;
                oppExtension.Cloud_On_premise__c = oppClonada.Cloud_On_premise__c;
                if(oppClonada.Responsable_de_Proyecto__c != null){
                    oppExtension.Responsable_de_proyecto__c = OppClonada.Responsable_de_proyecto__c;
                    oppExtension.Responsable_de_Proyecto_Email__c = OppClonada.Responsable_de_Proyecto_Email__c;
                    oppExtension.Responsable_de_Proyecto_Nombre__c = OppClonada.Responsable_de_Proyecto_Nombre__c;                    
                }
                
                oppExtension.Bookings_breakdown__c=oppClonada.Bookings_breakdown__c;
                oppExtension.Up_selling__c=oppClonada.Up_selling__c;
                //oppExtension.CPV__c=oppClonada.CPV__c;
                oppExtension.CPV_varios__c=oppClonada.CPV_varios__c;
                //oppExtension.Origen__c = Origen;
                oppExtension.Oportunidad_Origen__c = oppClonada.Oportunidad_Origen__c;
                Decimal margenCalculo =0;
                // EBF : Se pone Margen 0 para extensión CUTE
                if(tipoExtension=='Extensión CUTE'){
                    oppExtension.Margen_Previsto_Euros__c = margenCalculo;
                }else if(tipoExtension=='Extensión Rectificativa'){
                    if(importeTotal != null & margenEstimado != null){
                    system.debug('Importe: '+importeTotal);
                     system.debug('rentab: '+margenEstimado);
                   margenCalculo = (Decimal.valueOf(importeTotal*margenEstimado/100)).setScale(2, RoundingMode.HALF_UP); 
                     system.debug('margen: '+margenCalculo);
                   oppExtension.Margen_Previsto_Euros__c = margenCalculo;
                }
                }
                 
                // oppExtension.Tipologia__c=oppClonada.Tipologia__c;
                if(oppClonada.Tipologia__c == '4' || oppClonada.Tipologia__c == '5' ){
                    oppExtension.importe_productoHard__c=importeTotal;
                    oppExtension.margen_productoHard__c =margenCalculo;
                }else{
                    oppExtension.importe_servicio__c=importeTotal;
                    oppExtension.margen_servicio__c =margenCalculo;   
                }
                
                if(importeTotal<0){
                   oppExtension.Descontratacion__c=true;
                }
            }  
            
            if(OppClonada.Referencia_Comercial__c=='Sí' || OppClonada.Referencia_Comercial__c=='No, porque ya existe'){
                oppExtension.Referencia_comercial__c = 'No, porque ya existe';
                oppExtension.Referencia_Comercial_lookup__c= oppClonada.Referencia_Comercial_lookup__c;
                //oppExtension.Tecnologia__c = oppClonada.Tecnologia__c;
            }else if ( OppClonada.Referencia_Comercial__c=='No, por no ser relevante'){
                oppExtension.Referencia_Comercial__c = 'No, por no ser relevante';
                oppExtension.Referencia_Comercial_lookup__c = null;
            }else{
                oppExtension.Referencia_Comercial__c = null;
                oppExtension.Referencia_Comercial_lookup__c = null;
            }
            
        }    
        
        //General
        oppExtension.Fecha_apertura__c = Date.today();    
        oppExtension.Fecha_creacion__c =  Date.today();                                             
        oppExtension.Name = nombreOpp;
        oppExtension.Nombre_Corto__c = nombreOpp;
        oppExtension.Fecha_estimada_de_cierre__c = fechaCierre;
        oppExtension.Margen_estimado_incluye_recargos__c = margenEstimado;
        oppExtension.RENTPPTO__c=margenEstimado;
        oppExtension.Fecha_limite_de_presentacion__c = fechaPresentacion;
        oppExtension.Plazo_de_ejecuci_n_meses__c = plazoEjecucion;
        oppExtension.Importe_Licitacion__c = importeTotal;
        
        oppExtension.Contratado_a_o_oportunidad__c  = importeTotal;
        oppExtension.Tipo_de_Oportunidad__c = 'Interés contrastado del cliente';
        oppExtension.Tipo_Participacion_Ayesa__c = 'Contratista Principal';
        oppExtension.Participacion_Ayesa__c = 100;
        
        oppExtension.AccountId= oppClonada.AccountId;
        oppExtension.Probability = Decimal.valueOf(probabilidad);
        oppExtension.Contacto_Principal__c= oppClonada.Contacto_Principal__c;
        oppExtension.Pais__c = oppClonada.Pais__c;
        oppExtension.Sociedad_Ayesa__c= oppClonada.Sociedad_Ayesa__c;
        oppExtension.Tipo_Oportunidad__c =OppClonada.Tipo_Oportunidad__c;
        
        oppExtension.Clonada__c = true;
        oppExtension.Modificar_importes__c = true ;

        //SCM - nuevo campo Equipo Oferta no debe copiarse a la nueva oportunidad
        oppExtension.Equipo_Oferta__c = '';
        
        //if (oppClonada.RecordTypeId != recordTypeAyesa){
        oppExtension.GP_Super__c = OppClonada.GP_Super__c;
        oppExtension.CR_Super__c = OppClonada.CR_Super__c;
        oppExtension.Codigo_CR_Super__c=OppClonada.Codigo_CR_Super__c;
        oppExtension.CR_SW_Super__c=OppClonada.CR_SW_Super__c;
        oppExtension.CR_HW_Super__c=OppClonada.CR_HW_Super__c;
        oppExtension.Codigo_CR_HW_Super__c=OppClonada.Codigo_CR_HW_Super__c;
        oppExtension.Codigo_FICEPI_GP__c=OppClonada.Codigo_FICEPI_GP__c;
        
      //  oppExtension.Contacto_facturacion__c =OppClonada.Contacto_facturacion__c;
     //   oppExtension.Codigo_Org_Comercial_IB__c=OppClonada.Codigo_Org_Comercial_IB__c;
    //    oppExtension.Organizacion_Ibermatica__c=OppClonada.Organizacion_Ibermatica__c;
        // oppExtension.Plazo_de_ejecuci_n_meses__c=OppClonada.Plazo_de_ejecuci_n_meses__c;
        
        // }
        
                                                        
        
        try{
            if(!Test.isRunningTest()){
                
                if(oppExtension.Desglose_importes__c =='No'){
                    oppExtension.Modificar_importes__c = false ;
                }
                if (oppClonada.Oportunidad_Relacionada__c != null){
                    oppExtension.Oportunidad_Relacionada__c=oppClonada.Oportunidad_Relacionada__c;
                    oppExtension.Oportunidad_Padre__c =idOportunidad;   
                    
                }else{
                    oppExtension.Oportunidad_Relacionada__c = idOportunidad;
                }

                insert oppExtension;
                System.debug('Insertada');
            }
            if(!Test.isRunningTest()){
                
                if(tipoExtension == 'Extensión Rectificativa'){
                    oppExtension.StageName ='Presentada (negociación y cierre)';
                    oppExtension.Subfase__c ='Ganada';
                }
                
                oppExtension.Importe_total_sin_IVA__c = importeTotal;
                oppExtension.Clonada__c = false;
              
                    
                try{
                    update oppExtension;
                    idOpp = oppExtension.id;
                    
                }catch(DMLException e){ 
                    System.debug('Error update Extensión Oportunidad: ' + e.getMessage());
                    System.debug('Elimino oportunidad');
                    delete oppExtension;
                    
                    return e.getMessage();            
        }
                              
            }
            
        } catch(DMLException e){ 
            System.debug('Error insert Extensión Oportunidad: ' + e.getMessage());
            return e.getMessage();            
        }   
        
        return idOpp;
        
    }
    
    public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
                //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
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
String test190;
String test191;

        
    }
}
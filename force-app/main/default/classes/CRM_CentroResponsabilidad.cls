public class CRM_CentroResponsabilidad {
    //Componente Centro de responsabilidad
    //Se elige Centro Responsabilidad, Gestor de Producción
    @AuraEnabled
    public static String inicio(String oppId){
        
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        //Recuperamos valores iniciales de la OC
        Opportunity opp = [SELECT Id, Name, Codigo_OC__c,GP_Super__c, CR_Super__c, Organizacion_Ibermatica__c,Desglose_importes__c,RecordType.Name, RecordType.DeveloperName, Etapa_Fase__c,Linea_de_Servicio__c
                              FROM Opportunity
                              WHERE Id =: oppId LIMIT 1 ];
        
        //Recuperamos valores de gestor de produccion
        List <Parametrica_2__c> parametrica = [SELECT Id, Name,Codigo_CR__c, Centro_resp_Super__c,Tipo__c,RecordType.name,Horizontal__c
                                               FROM Parametrica_2__c 
                                               WHERE RecordType.name = 'Centro Responsabilidad' 
                                               and Horizontal__c =: opp.Linea_de_Servicio__c
                                               order by Centro_resp_Super__c];
        List <String> valoresGP = new List<String>();
        
        List<Parametrica_2__c> gp_parametrica = new List<Parametrica_2__c> ();
        List <String> valoresCR = new List<String>();
        
        for (Parametrica_2__c param: parametrica){
            if(param.RecordType.name == 'Centro Responsabilidad' && !valoresCR.contains(param.Centro_resp_Super__c + ' -- ' + param.Codigo_CR__c)){
                valoresCR.add(param.Centro_resp_Super__c + ' -- ' + param.Codigo_CR__c);
            }
        }
        gen.writeObjectField('Centro_Responsabilidad', valoresCR);
        system.debug('valores_centroResponsabilidad: ' + valoresCR);       
        
        if(opp.RecordType.Name == 'Ibermatica Latam' &&  opp.GP_Super__c ==null && opp.CR_Super__c ==null ){
            opp.GP_Super__c='GIOVANNI CAMPO VERDE';
            opp.CR_Super__c='TECNET -- 131';
            opp.Horizontal__c='Digital-Latam';
            try{
                String resultSave = saveOpp('TECNET -- 131', 'GIOVANNI CAMPO VERDE',opp.Id);
            } catch(DMLException e){ 
                System.debug('Error update Oportunidad LATAM GP y CR: ' + e.getMessage());
                return e.getMessage();            
            }	
            
        }
        gen.writeObjectField('oportunidad', opp);
        
        if(opp.CR_Super__c != null){
            String Codigo_CR = opp.CR_Super__c.substringAfter(' -- ');
            
            gp_parametrica= [SELECT Id, Name, Tipo__c,RecordType.name, Gestor_de_produccion_lookup__r.Codigo_Gestor_Produccion__c, Gestor_de_produccion_lookup__r.Gestor_de_produccion__c
                             FROM Parametrica_2__c
                             WHERE RecordType.name = 'Gestor Produccion - Centro Responsabilidad'  and Centro_Res_Super_lookup__r.Codigo_CR__c =: Codigo_CR order by Gestor_de_produccion_lookup__r.Gestor_de_produccion__c ];
            
            for (Parametrica_2__c param: gp_parametrica){
                if(param.RecordType.name == 'Gestor Produccion - Centro Responsabilidad' && !valoresGP.contains(param.Gestor_de_produccion_lookup__r.Gestor_de_produccion__c)){
                    valoresGP.add(param.Gestor_de_produccion_lookup__r.Gestor_de_produccion__c );
                }
            }
        }
        System.debug('Gestor_produccion ABR: '+valoresGP);
        gen.writeObjectField('Gestor_produccion', valoresGP);
        
        gen.writeEndObject();
        
        result = gen.getAsString();
        // return valoresGP;
        return result;
    }
    
    @AuraEnabled
    public static List <String> gestor_produccion(String CR){
        System.debug('Código CR para filtrar: '+ CR );
        String Codigo_CR = CR.substringAfter(' -- ');
        System.debug('Código CR para filtrar: '+ Codigo_CR );
        
        List <Parametrica_2__c> parametrica = [SELECT Id, Name, Tipo__c,RecordType.name, Gestor_de_produccion_lookup__r.Codigo_Gestor_Produccion__c, Gestor_de_produccion_lookup__r.Gestor_de_produccion__c
                                               FROM Parametrica_2__c
                                               WHERE RecordType.name = 'Gestor Produccion - Centro Responsabilidad'  and Centro_Res_Super_lookup__r.Codigo_CR__c =: Codigo_CR order by  Gestor_de_produccion_lookup__r.Gestor_de_produccion__c ];
        
        List <String> valoresGP = new List<String>();
        for (Parametrica_2__c param: parametrica){
            if(param.RecordType.name == 'Gestor Produccion - Centro Responsabilidad' && !valoresGP.contains(param.Gestor_de_produccion_lookup__r.Gestor_de_produccion__c)){
                valoresGP.add(param.Gestor_de_produccion_lookup__r.Gestor_de_produccion__c);
            }
        }
        
        system.debug('valores_GestorProduccion: ' + valoresGP);
        
        
        return valoresGP;
    }
    
    @AuraEnabled
    
    public static String saveOpp(String CR, String GP,String oppId){
        
        System.debug('Id oportunidad: ' + oppId);
        String resultado='Actualizado';
        Opportunity opp = [Select Id, Name, Codigo_OC__c, GP_Super__c, CR_Super__c, Organizacion_Ibermatica__c,Desglose_importes__c,Horizontal__c,Importe_limite_OCP__c From Opportunity where id =: oppId Limit 1];
        
        //29/05/2024
        if( opp.GP_Super__c== GP && opp.CR_Super__c== CR){
            return  'No se actualiza';
        }else{
            //
            String Codigo_CR = CR.substringAfter(' -- ');
            // String Codigo_GP = GP.substringAfter(' - ');
            
            System.debug('Código CR: '+ Codigo_CR);
            System.debug('GP: ' + GP);
            
            Parametrica_2__c desglose_imp_CR = [SELECT Id, Centro_Res_Super_lookup__r.Desglose_importes__c,Centro_Res_Super_lookup__r.Codigo_CR__c,Centro_Res_Super_lookup__r.CR_Importe_OCP__c,
                                                Centro_Res_Super_lookup__r.Codigo_CR_HW_Super__c,  Centro_Res_Super_lookup__r.CR_HW_Super__c, Centro_Res_Super_lookup__r.Codigo_CR_SW_Super__c,Centro_Res_Super_lookup__r.CR_SW_Super__c
                                                ,Centro_Res_Super_lookup__r.Horizontal__c,Gestor_de_produccion_lookup__r.FICEPI__c
                                                FROM Parametrica_2__c 
                                                WHERE Centro_Res_Super_lookup__r.Codigo_CR__c =: Codigo_CR and Gestor_de_produccion_lookup__r.Gestor_de_produccion__c =:GP and  RecordType.name = 'Gestor Produccion - Centro Responsabilidad' Limit 1];
            
            opp.GP_Super__c= GP;
            opp.CR_Super__c= CR;
            // opp.Organizacion_Ibermatica__c= Org;
            opp.Desglose_importes__c=desglose_imp_CR.Centro_Res_Super_lookup__r.Desglose_importes__c;
            if(desglose_imp_CR.Centro_Res_Super_lookup__r.Desglose_importes__c == 'No'){
                opp.Modificar_importes__c= true;
            }else{
                opp.Modificar_importes__c=false;
            }
            opp.Importe_limite_OCP__c=desglose_imp_CR.Centro_Res_Super_lookup__r.CR_Importe_OCP__c;
            opp.Linea_de_Servicio__c = desglose_imp_CR.Centro_Res_Super_lookup__r.Horizontal__c;
            opp.Codigo_FICEPI_GP__c=desglose_imp_CR.Gestor_de_produccion_lookup__r.FICEPI__c;
            opp.Codigo_CR_Super__c = Codigo_CR;
            System.debug('Horizontal por CR '+ desglose_imp_CR.Centro_Res_Super_lookup__r.Horizontal__c);
            //  
            
            // if(CR.contains('NAV CSC') || CR.contains('NAV G y C') || CR.contains('NAVISION OPERATIONS')){
            if(desglose_imp_CR.Centro_Res_Super_lookup__r.CR_HW_Super__c <>'' || desglose_imp_CR.Centro_Res_Super_lookup__r.CR_SW_Super__c <>'' ){
                opp.CR_HW_Super__c =desglose_imp_CR.Centro_Res_Super_lookup__r.CR_HW_Super__c + ' - ' + desglose_imp_CR.Centro_Res_Super_lookup__r.Codigo_CR_HW_Super__c;
                opp.CR_SW_Super__c =desglose_imp_CR.Centro_Res_Super_lookup__r.CR_SW_Super__c + ' - ' + desglose_imp_CR.Centro_Res_Super_lookup__r.Codigo_CR_SW_Super__c;
                opp.Codigo_CR_HW_Super__c = desglose_imp_CR.Centro_Res_Super_lookup__r.Codigo_CR_HW_Super__c;
                opp.Codigo_CR_SW_Super__c = desglose_imp_CR.Centro_Res_Super_lookup__r.Codigo_CR_SW_Super__c;
                
                
            }else{
                opp.CR_HW_Super__c ='';
                opp.CR_SW_Super__c ='';
            }
            
            try{
                opp.Clonada__c = true;
                update opp;
                
                opp.Clonada__c = false;
                update opp;
                
            } catch(DMLException e){ 
                System.debug('Error update Oportunidad: ' + e.getMessage());
                resultado = e.getMessage();
                return resultado;            
            }	
            system.debug('Actualizado');
            return resultado;
        }
        
    }
    
    
    @AuraEnabled
    public static String superPreventa(Id idOpp){
        System.debug('Super preventa Oportunidad');
        String mode ;
        List<Opportunity> opp = [SELECT id,Codigo_OC__c,StageName,Subfase__c
                                    FROM Opportunity WHERE Id =:idOpp LIMIT 1];
        
        if(opp.get(0).Subfase__c== 'Ganada' || opp.get(0).Subfase__c== 'Perdida' || opp.get(0).Subfase__c== 'Aplazada / anulada'   || opp.get(0).Subfase__c== 'No presentada'){
            
            //opp.get(0).StageName == 'Cerrada'
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
    public static Boolean readOnlyCR(String oppId){        
        System.debug('Id oportunidad: ' + oppId);
        Boolean read = true;
        Opportunity opp = [Select Id, Name, StageName,Subfase__c
                              From Opportunity where id =: oppId Limit 1];
        if(opp.StageName == 'Cualificación'){
            if(opp.Subfase__c == 'Alta' || opp.Subfase__c == 'Cualificacion con autoprovision' || opp.Subfase__c == 'Cualificación con preventa'){
                read = false;
            }          
        }
        System.debug('read: ' + read);
        return read;
    }
    
}
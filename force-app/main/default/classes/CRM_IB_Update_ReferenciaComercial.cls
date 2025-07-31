public class CRM_IB_Update_ReferenciaComercial {
    
    //Componente
    @AuraEnabled
    public static string update_referencia_comercial(String Id_ref){
        //1. Recuperamos Referencia
        Referencia_Comercial__c ref_comercial = [Select Id,Importe_acumulado__c,Fecha__c,Area_Tecnologia__c,CPV_varios__c FROM Referencia_comercial__c where id =: Id_ref limit 1];
        //2. Recuperamos oportunidades relacionadas
        List <Oportunidad__c> ops_relacionadas = [SELECT Id, Importe_total_sin_IVA__c, fecha_estimada_de_cierre__c,Tecnologia__c,CPV_varios__c,Area_Tecnologia__c FROM Oportunidad__c where Referencia_comercial_lookup__c =: Id_ref];
        System.debug('Lista de oportunidades tamaño: '+ ops_relacionadas.size());
        //3. Bucle suma de importes y máxima fecha de cierre
        Decimal suma_importe=0;
        Date max_fecha_cierre ;
        String Tecnologia_concat = '';
        String CPV_concat = '';
        
        List <String> lista_tecnologia = new List <String>();
        List <String> lista_cpv = new List <String>();
        
        for(Oportunidad__c op : ops_relacionadas){
            //1. Importes
            if(op.Importe_total_sin_IVA__c !=  null){
                suma_importe += op.Importe_total_sin_IVA__c;
            }
            System.debug('Importe acumulado: '+ suma_importe);
            
            //2.Fecha última de cierre
            if(max_fecha_cierre==null){
                max_fecha_cierre = op.Fecha_estimada_de_cierre__c;
            }
            if(max_fecha_cierre < op.Fecha_estimada_de_cierre__c){
                max_fecha_cierre = op.Fecha_estimada_de_cierre__c;
            }
            
            //3. Tecnología
            if(op.Area_Tecnologia__c != null){
                if(op.Area_Tecnologia__c.contains(';')){
                    lista_tecnologia =  op.Area_Tecnologia__c.split(';');
                }else{
                    lista_tecnologia.add(op.Area_Tecnologia__c);
                }
            }
            
            //3.5 CPV
            if(op.CPV_varios__c != null){
                if(op.CPV_varios__c.contains(';')){
                    lista_cpv =  op.CPV_varios__c.split(';');
                }else{
                    lista_cpv.add(op.CPV_varios__c);
                }
            }
            
            
        }
        
        for(String valor : lista_tecnologia){
            if(!tecnologia_concat.contains(valor)){
                tecnologia_concat = tecnologia_concat + ';' + valor;
            }
        }
        System.debug('Tecnologia :' + tecnologia_concat);
        
        for(String valor : lista_cpv){
            if(!cpv_concat.contains(valor)){
                if(cpv_concat.length()>0){
                    cpv_concat = cpv_concat + ';' + valor;
                }else{
                    cpv_concat = valor;
                }
                
            }
        }
        System.debug('CPV :' + cpv_concat);
        //4. Actualizar referencia comercial
        try{
            ref_comercial.Importe_acumulado__c = suma_importe;  
            ref_comercial.Fecha__c=  max_fecha_cierre;
            ref_comercial.Area_Tecnologia__c=tecnologia_concat;
            ref_comercial.Buscador_Area_Conocimiento_Tecnologica__c=tecnologia_concat;
            ref_comercial.CPV_varios__c=cpv_concat;
            update ref_comercial;
        }catch (DMLException e){ 
            System.debug('Error actualizar referencia comercial: ' + e.getMessage());
            // respuesta = e.getMessage(); 
            return e.getMessage(); 
            
        }
        
        return 'ok';
        
    }
    
    
    //Flujo
    @InvocableMethod 
    public static void update_referencia_comercial_flujo(List<String> Id_ref){
        
        //1. Recuperamos Referencia
        //  String Id_ref = Id_ref_list[0];
        Referencia_Comercial__c ref_comercial = [Select Id,Importe_acumulado__c,Fecha__c,Area_conocimiento_tecno__c,CPV_varios__c FROM Referencia_comercial__c where id =: Id_ref limit 1];
        //2. Recuperamos oportunidades relacionadas
        List <Oportunidad__c> ops_relacionadas = [SELECT Id, Importe_total_sin_IVA__c, fecha_estimada_de_cierre__c,Tecnologia__c,CPV_varios__c,Area_Tecnologia__c FROM Oportunidad__c where Referencia_comercial_lookup__c =: Id_ref];
        System.debug('Lista de oportunidades tamaño: '+ ops_relacionadas.size());
        //3. Bucle suma de importes y máxima fecha de cierre
        Decimal suma_importe=0;
        Date max_fecha_cierre ;
        String tecnologia_concat = '';
        String cpv_concat = '';
        
        List <String> lista_tecnologia = new List <String>();
        List <String> lista_cpv = new List <String>();
        
        for(Oportunidad__c op : ops_relacionadas){
            //1. Importes
            if(op.Importe_total_sin_IVA__c !=  null){
                suma_importe += op.Importe_total_sin_IVA__c;
            }
            System.debug('Importe acumulado: '+ suma_importe);
            
            //2.Fecha última de cierre
            if(max_fecha_cierre==null){
                max_fecha_cierre = op.Fecha_estimada_de_cierre__c;
            }
            if(max_fecha_cierre < op.Fecha_estimada_de_cierre__c){
                max_fecha_cierre = op.Fecha_estimada_de_cierre__c;
            }
            
            //3. Tecnología
            if(op.Area_Tecnologia__c != null){
                if(op.Area_Tecnologia__c.contains(';')){
                    lista_tecnologia =  op.Area_Tecnologia__c.split(';');
                }else{
                    lista_tecnologia.add(op.Area_Tecnologia__c);
                }
            }
            
            //3.5 CPV
            if(op.CPV_varios__c != null){
                if(op.CPV_varios__c.contains(';')){
                    lista_cpv =  op.CPV_varios__c.split(';');
                }else{
                    lista_cpv.add(op.CPV_varios__c);
                }
                
            }
            
        }
        
        for(String valor : lista_tecnologia){
            if(!tecnologia_concat.contains(valor)){
                tecnologia_concat = tecnologia_concat + ';' + valor;
            }
        }
        
        for(String valor : lista_cpv){
            if(!cpv_concat.contains(valor)){
                if(cpv_concat.length()>0){
                    cpv_concat = cpv_concat + ';' + valor;
                }else{
                    cpv_concat = valor;
                }
                
            }
        }
        System.debug('CPV :' + cpv_concat);
        System.debug('Tecnologia :' + tecnologia_concat);
        //4. Actualizar referencia comercial
        try{
            ref_comercial.Importe_acumulado__c = suma_importe;  
            ref_comercial.Fecha__c=  max_fecha_cierre;
            ref_comercial.Area_Tecnologia__c=tecnologia_concat;
            ref_comercial.Buscador_Area_Conocimiento_Tecnologica__c=tecnologia_concat;
            ref_comercial.CPV_varios__c=cpv_concat;
            update ref_comercial;
        }catch (DMLException e){ 
            System.debug('Error actualizar referencia comercial: ' + e.getMessage());
            // respuesta = e.getMessage(); 
            //  return e.getMessage(); 
            
        }
        
        //return 'ok';
        
    }
    
}
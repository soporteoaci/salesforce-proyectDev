global class CRM_Calculo_Pipeline implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query de las oportunidades');
        String query = 'SELECT Id,Codigo_OC__C,mercado__c,DivisionPicklist__c, Linea_de_Servicio__c, Bloqueada__c,createddate, Fecha_Creacion__C, fecha_estimada_de_Cierre__c,Importe_total_sin_IVA__c,Tipologia__c,Origen__c ';
        query = query + ' from Opportunity where Direccion_Operaciones__c= \'IT&DS\' and fecha_estimada_de_Cierre__c >2023-12-31 ';
        query = query + ' and RecordType.Name != \'Presupuesto\' and mercado__c !=\'60035586\' and mercado__c != \'60035584\' and sociedad_ayesa__c != \'0007\' and Tipo_Extension__c != \'Extensión CUTE\'';
        //entrar fecha de cierre >=01/01/2023
        
        List<Parametrica_2__c> pipeline_a_cero= new List < Parametrica_2__c>();
        Id recordTypePipeline = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Pipeline').getRecordTypeId();
        List <Parametrica_2__c> pipeline_list =[SELECT Id,Clave_pipeline__c, Importe_pipeline__c,importe_aux__c,control__c,pipeline__c FROM Parametrica_2__c where recordtypeId =: recordTypePipeline];
        
        System.debug('Actualizamos a cero el pipeline');
        for(Parametrica_2__c registro: pipeline_list){
            
           
           registro.Importe_pipeline__c=0;
            registro.control__c='';
            pipeline_a_cero.add(registro);
        }
        
        update pipeline_a_cero;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oportunidades){
        // system.debug('Tamaño de lista oportunidades:  ' + oportunidades.size());
        String clave='';
        Map<String, Decimal> totalPorClave = new Map<String, Decimal>();
        Map<String, String> OportunidadClave = new Map<String, String>();
        //Traemos los registros de parametrica
        Id recordTypePipeline = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Pipeline').getRecordTypeId();
        List <Parametrica_2__c> pipeline_list =[SELECT Id,Clave_pipeline__c, Importe_pipeline__c,importe_aux__c,control__c FROM Parametrica_2__c where recordtypeId =: recordTypePipeline];
        
        //System.debug('Tamaño lista de registros en parametrica_2 pipeline_list: '+ pipeline_list.size()); 
        //map_pipeline es la clave y el importe de la tabla parametrica  
        //inicializamos totalPorClave con lo que haya ya actualizado
        Map<String,Parametrica_2__c > map_pipeline = new Map <String,Parametrica_2__c>();
        for(Parametrica_2__c registro: pipeline_list){
            map_pipeline.put(registro.clave_pipeline__c, registro);
            totalPorClave.put(registro.clave_pipeline__c, registro.Importe_pipeline__c);
            OportunidadClave.put(registro.clave_pipeline__c, registro.control__c);
            // System.debug('Importe inicial: '+ registro.clave_pipeline__c +' --> '+registro.Importe_pipeline__c );
        }
        
        
        String mes ='';
        
        //System.debug('Empieza cálculo de los importes iterando sobre las oportunidades');
        Date FechaCreacion;
        Date FechaCierre;
        for(Opportunity op: oportunidades){
            FechaCreacion = op.Fecha_Creacion__c.date();
            FechaCierre = op.Fecha_estimada_de_cierre__c;
            //si la fecha cierre es menor que la fecha de creación, coja como fecha creación la fecha de cierra
            if(FechaCierre < FechaCreacion){
                FechaCreacion =op.Fecha_estimada_de_cierre__c;
                //  system.debug(  op.Codigo_oc__c + '--> Fecha creacion cambiada: ' + FechaCreacion);
            }
            
            if(op.Bloqueada__c == false){
                FechaCierre=Date.newInstance(2032,02,01);
            }
            if(	FechaCreacion.year()	< 2024){
                //<2023
                mes ='<2024';
                
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
                
            }
            
            
            if(	FechaCreacion	<	Date.newInstance(2024,02,01)	&& FechaCierre	>	Date.newInstance(2024,01,31) ){
                mes='enero24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,03,01) && 	FechaCierre	> Date.newInstance(2024,02,28)){
                mes='febrero24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,04,01) && 	FechaCierre	>Date.newInstance(2024,03,31)){
                mes='marzo24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,05,01) && 	FechaCierre	>Date.newInstance(2024,04,30)){
                mes='abril24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,06,01) && 	FechaCierre	>Date.newInstance(2024,05,31)){
                mes='mayo24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,07,01) && 	FechaCierre	>Date.newInstance(2024,06,30)){
                mes='junio24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,08,01) && 	FechaCierre	>Date.newInstance(2024,07,31)){
                mes='julio24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,09,01) && 	FechaCierre	>Date.newInstance(2024,08,31)){
                mes='agosto24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,10,01) && 	FechaCierre	>Date.newInstance(2024,09,30)){
                mes='septiembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,11,01) && 	FechaCierre	>Date.newInstance(2024,10,31)){
                mes='octubre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2024,12,01) && 	FechaCierre	>Date.newInstance(2024,11,30)){
                mes='noviembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,01,01) && 	FechaCierre	>Date.newInstance(2024,12,31)){
                mes='diciembre24';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,02,01) && 	FechaCierre	>Date.newInstance(2025,01,31)){
                mes='enero25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,03,01) && 	FechaCierre	>Date.newInstance(2025,02,29)){
                mes='febrero25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,04,01) && 	FechaCierre	>Date.newInstance(2025,03,31)){
                mes='marzo25';
                
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,05,01) && 	FechaCierre	>Date.newInstance(2025,04,30)){
                mes='abril25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,06,01) && 	FechaCierre	>Date.newInstance(2025,05,31)){
                mes='mayo25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,07,01) && 	FechaCierre	>Date.newInstance(2025,06,30)){
                mes='junio25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,08,01) && 	FechaCierre	>Date.newInstance(2025,07,31)){
                mes='julio25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,09,01) && 	FechaCierre	>Date.newInstance(2025,08,31)){
                mes='agosto25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,10,01) && 	FechaCierre	>Date.newInstance(2025,09,30)){
                mes='septiembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,11,01) && 	FechaCierre	>Date.newInstance(2025,10,31)){
                mes='octubre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2025,12,01)&& 	FechaCierre  >Date.newInstance(2025,11,30)){
                mes='noviembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
            if(	FechaCreacion	<Date.newInstance(2026,01,01) && 	FechaCierre	>Date.newInstance(2025,12,31)){
                mes='diciembre25';
                totalPorClave=  add_importe(mes,op,totalPorClave,OportunidadClave);
            }
            
        }
        
        
        //Actualizamos los importes, el total esta en totalPorClave
        //Claves del pipeline
        //  System.debug('Actualizamos pipeline con valores finales');
        Set <String> Keyset_map_pipeline = new Set<String>();
        Keyset_map_pipeline = map_pipeline.keySet();
        
        List <Parametrica_2__c> actualizar_pipeline = new List<Parametrica_2__c>();
        Decimal importe=0;
        String cadena_Oportunidad='';
        //  System.debug('para cada clave recuperamos el importe');
        for (String key:Keyset_map_pipeline ){
            
            Importe =  totalPorClave.get(key);
            Cadena_Oportunidad = OportunidadClave.get(key);
            Parametrica_2__c registro =  map_pipeline.get(key);
            //  System.debug('Actualizo importe '+Importe +'---> para la clave: '+ key);
            if(Importe != null){
                registro.Importe_pipeline__c = Importe.setScale(2, RoundingMode.HALF_UP);
                if(cadena_oportunidad != null ){
                    if(cadena_oportunidad.length()<131072){
                        registro.control__c =Cadena_Oportunidad;
                    }
                }
            }
            
            actualizar_pipeline.add(registro);
        }
        
        
        try{
            
            if(actualizar_pipeline.size()>0){
                System.debug('update');
                System.debug(  actualizar_pipeline.size());
                update actualizar_pipeline;
            }
        }catch (DMLException e){ 
            System.debug('Error actualizar importes pipeline: ' + e.getMessage());
            
        }
        
        
        
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        System.debug('CRM_Calculo_Pipeline terminado');
    }
    
    public static Map<String, Decimal> add_importe(String mes,Opportunity op,Map<String, Decimal> totalPorClave,Map<String, String> OportunidadClave){
        
        
        String Mercado = op.Mercado__c;
        String LineaServicio = op.Linea_de_Servicio__c;
        String Division= '';
        if(op.Mercado__c =='60029427'){
            Division='ENERGY & UTILITIES';
        }else{
            Division=op.DivisionPicklist__c;
        }
        
        
        String clave = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio;
        String clave_SinReselling = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio +'|Sin reselling';
        
        //Nueva Clave para registros Hard
        String clave_Hard = mes +'|'+Mercado + '|'+Division+'|'+LineaServicio +'|Hard';
        
        if (totalPorClave.containsKey(clave)) {
            if(op.Importe_total_sin_IVA__c != null){
                totalPorClave.put(clave, totalPorClave.get(clave) + op.Importe_total_sin_IVA__c);
            }
            
            OportunidadClave.put(clave, OportunidadClave.get(clave) +';' +op.Codigo_OC__c);
            
        }
        
        if (totalPorClave.containsKey(clave_SinReselling)) {
            if(op.Importe_total_sin_IVA__c != null){
                if(op.Tipologia__c !='5' && op.Tipologia__c !='4'){
                    totalPorClave.put(clave_SinReselling, totalPorClave.get(clave_SinReselling) + op.Importe_total_sin_IVA__c);
                }
            }

            OportunidadClave.put(clave_SinReselling, OportunidadClave.get(clave_SinReselling) +';' +op.Codigo_OC__c);
            
        }
        //Calculo importe para los registros Hard
        if (totalPorClave.containsKey(clave_Hard)) {
            if(op.Importe_total_sin_IVA__c != null){
                if(String.isNotBlank(op.Origen__c) && op.Origen__c =='Hard'){
                    totalPorClave.put(clave_Hard, totalPorClave.get(clave_Hard) + op.Importe_total_sin_IVA__c);
                }
            }

            OportunidadClave.put(clave_Hard, OportunidadClave.get(clave_Hard) +';' +op.Codigo_OC__c);
            
        }                
        
        return totalPorClave;
    }
}
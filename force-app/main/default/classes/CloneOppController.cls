public class CloneOppController {
    @AuraEnabled
    public static String getTypeOpp(Id idOportunidad){
        
        Opportunity opp =[SELECT id, name, codigo_OC__c, RecordType.Name from Opportunity where Id =: idOportunidad];
        
        return opp.RecordType.Name;
    }
    @AuraEnabled
    public static String clonarOportunidad(Id idOportunidad, String nombreOpp, Date fechaCierre, Date fechaPresentacion, Double margenEstimado, Integer plazoEjecucion, Double importeTotal){
        String idOpp;
        DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();	
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());	
        String query = ' SELECT ' + String.join( fieldNames, ',' ) +	' FROM ' +describeResult.getName() + ' WHERE id = :idOportunidad LIMIT 1 ';
        List<Opportunity> records = Database.query(query);	
        
        Opportunity oppClonada = new Opportunity();
        oppClonada = records.get(0).clone(false,true,false,false);
        
        System.debug('Oportunidad a Clonar: ' + idOportunidad);
        
        //Asignamos el Id del usuario actual como Owner de la Oportunidad Clonada
        System.debug('Usuario actual (nuevo Owner) -> '+ UserInfo.getUserId());
        oppClonada.OwnerId = UserInfo.getUserId(); 
        
        oppClonada.Crear_expediente__c = false;
        oppClonada.Fecha_creacion__c =  Date.today();
        System.debug('Record Type Oportunidad Clonada: ' + oppClonada.RecordTypeId);
        System.debug('Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(\'Innovación\').getRecordTypeId(): ' + Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Innovación').getRecordTypeId());
        if(oppClonada.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Innovación').getRecordTypeId()){
            oppClonada.StageName = 'Oferta';
            oppClonada.Subfase__c = 'Elaboración oferta';
        } else {
            oppClonada.StageName = 'Cualificación';
            oppClonada.Subfase__c = 'Alta';
        }
        oppClonada.Modificar_importes__c= TRUE;

        //Informado en el componente
        oppClonada.Name = nombreOpp;
        oppClonada.Nombre_Corto__c = nombreOpp;
        oppClonada.Fecha_estimada_de_cierre__c = fechaCierre;
        oppClonada.Margen_estimado_incluye_recargos__c = margenEstimado;
        oppClonada.RENTPPTO__c =margenEstimado;
        oppClonada.Fecha_limite_de_presentacion__c = fechaPresentacion;
        oppClonada.Plazo_de_ejecuci_n_meses__c = plazoEjecucion;
        oppClonada.Importe_Licitacion__c = importeTotal;
        //El importe total ofertado lo incluimos en la actualización para calcular el margen
        oppClonada.Contratado_a_o_oportunidad__c  = importeTotal; 

        //Importes
        oppClonada.Margen_contrato__c = null;
        oppClonada.Importe_en_divisa_local__c = null;
        oppClonada.Importe_adjudicacion__c = null;
        oppClonada.Producci_n_estimada_a_o_oportunidad__c = null;
        
        //oppClonada.Produccion_estimada_a_o_poderada__c = null;
        oppClonada.Importe_Contratacion__c = null;
        oppClonada.Margen_Previsto_Euros__c=null;
        oppClonada.Margen_Previsto_Local__c=0;
        oppClonada.importe_mtoHard__c=0;
        oppClonada.importe_mtoSoft__c=0;
        oppClonada.importe_productoHard__c=0;
        oppClonada.importe_productoSoft__c=0;
        oppClonada.importe_servicio__c=0;
        oppClonada.margen_mtoHard__c=0;
        oppClonada.margen_mtoSoft__c=0;
        oppClonada.margen_productoHard__c=0;
        oppClonada.margen_productoSoft__c=0;
        oppClonada.margen_servicio__c=0;
        oppClonada.Rentabilidad_HW__c=0;
        oppClonada.Rentabilidad_SW__c=0;
        oppClonada.Rentabilidad_Mtto_HW__c=0;
        oppClonada.Rentabilidad_Mtto_SW__c=0;
        oppClonada.Rentabilidad_Serv__c=0;
        oppClonada.Margen_estimado_incluye_recargos__c=0;
        
        oppClonada.Importe_total_ofertado_sin_IVA_local__c=null;
        oppClonada.Margen_Previsto_Local__c=null;
        oppClonada.Importe_adjudicacion__c=null;
        
        //Cierre
        oppClonada.Motivo_perdido__c ='';
        oppClonada.Estado_de_Cierre__c = null;
        oppClonada.Referencia_Comercial__c = null;
        oppClonada.Referencia_Comercial_lookup__c = null;
        oppClonada.Estado_de_Cierre__c='';
      //  oppClonada.Estado_de_Cierre_SME__c='';

        //Fechas     
        oppClonada.Adjudicada__c = false;
        oppClonada.Fecha_adjudicacion__c = null;
        oppClonada.Fecha_firma_contrato__c = null;
        oppClonada.Fecha_publicacion__c = null;
        oppClonada.Fecha_apertura__c = Date.today();  
        oppClonada.Observaciones__c = null;
        oppClonada.Objetivo_del_proyecto__c = null;
        
        //Otros
      //  oppClonada.Departamento_RO__c = null;
        oppClonada.Enviado_la_oferta_a_soporte__c = false;
        oppClonada.Oferta_SAP__c = null;
     //   oppClonada.Responsable__c = null;
        oppClonada.Oportunidad_Relacionada__c=null;
        oppClonada.Oportunidad_Padre__c=null;
        oppClonada.GUIDOPORTUNIDAD__c = '';
        
        oppClonada.Tipo_de_Oportunidad__c = 'Interés contrastado del cliente';
        oppClonada.Tipo_Participacion_Ayesa__c = 'Contratista Principal';
        oppClonada.Participacion_Ayesa__c = 100;
        oppClonada.Subcontrataciones__c='';
        oppclonada.Horizontal__c='';
        oppClonada.delivery_center__c ='';
        oppclonada.Origen__c = '';
        oppclonada.Oportunidad_Origen__c=null;
        oppClonada.URL_Carpeta__c='';
        oppClonada.DOC_Contrato__c =false;
        oppClonada.Tipologia__c='';
        oppClonada.Descontratacion__c=false;
        
        //SCM - nuevo campo Equipo Oferta no debe copiarse a la nueva oportunidad
        oppClonada.Equipo_Oferta__c = '';        
        

        oppClonada.Tipificacion_Manual__c=false;
        oppClonada.Decision_Go_Smart_BPM_Offer__c='';
        //   oppClonada.Decision_Oferta_Smart_BPM_Offer__c='';
        //   oppClonada.Estado_Smart_BPM_Offer__c='';
        //   oppClonada.Etapa_Smart_BPM_Offer__c='';
        oppClonada.URL_Expediente__c = null;
        //   oppClonada.id_registro_dataverso__c = null;
        oppClonada.Decision_QA_Economico__c ='';
        oppClonada.Decision_QA_Tecnico__c= '';
        oppClonada.Decision_Aprobacion_Oferta__c='';
        oppClonada.Tecnologia__c='';
        oppClonada.VB_linea_de_servicio__c='';
        oppClonada.Email_CEO_COO__c ='';
        oppClonada.Tipo_Extension__c='';
        oppClonada.Preventa__c=false;
        oppClonada.Oportunidad_estrategica__c=false;
        
        //¿Preventa?
        oppClonada.Finalidad__c='';
        oppClonada.Certificaciones_empresa__c='';
        oppClonada.Solvencia_empresa__c='';
        oppClonada.Certificaciones_perfiles__c='';
        oppClonada.Analisis_penalizaciones_excluyentes__c='';
        oppClonada.Informado_AJI__c='';
        oppClonada.Exige_venta_licencias__c='';
        oppClonada.Licencias__c=null;
        oppClonada.Forma_de_pago__c='';
        oppClonada.RIESGO__c='';
        oppClonada.Riesgo_Principal__c='';
        oppClonada.Informado_Compliance__c='';
        
        oppClonada.Estimacion_coste_preventa__c =null;
        oppClonada.Capacidad_preventa_redaccion_oferta__c='';
        oppClonada.Adecuacion_precio_objetivo__c='';
        oppClonada.Capacidad_ejecucion__c='';
        oppClonada.Viabilidad_ejecucion__c='';

        
        oppClonada.Actualizar_Estado__c=false; 
        oppClonada.Clonada__c = true;
        oppClonada.Bloqueada__c =false;
        
        try{
            if(!Test.isRunningTest()){
                insert oppClonada;
            }
            
            System.debug('Oportunidad Clonada: ' + oppClonada.Id); 
            
            if(!Test.isRunningTest()){
                oppClonada.Clonada__c = false;
                oppClonada.Modificar_importes__c= false;
                oppClonada.Importe_total_sin_IVA__c = importeTotal;
                try{
                    update oppClonada;
                    idOpp = oppClonada.id;
                }catch(DMLException e){ 
                    System.debug('Error al actualizar extensión: ' + e.getMessage());
                    System.debug('Elimino oportunidad');
                    delete oppClonada;
                    
                    return e.getMessage();            
                }
            }
        } catch(DMLException e){ 
            System.debug('Error Clonacion Oportunidad: ' + e.getMessage());
            return e.getMessage();            
        }	
        
        return idOpp;
    }
}
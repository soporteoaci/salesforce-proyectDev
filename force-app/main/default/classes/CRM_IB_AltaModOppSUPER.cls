/**
* @author Ayesa
* @since 21-06-2023
* @desc Creacion APEX Alta Mod Oportunidad en SUPER
* Alta SUPER Ibermatica
*/
public class CRM_IB_AltaModOppSUPER {
	@InvocableMethod 
    public static void altaModOppSUPER(List<Id> recordIds){
        System.debug('CRM_IB_AltaModOppSUPER: ' + recordIds);
        futureAltaModOppSUPER(recordIds.get(0));           
    }
    
    @future(callout=true)
    public static void futureAltaModOppSUPER(Id recordId){
        System.debug('futureAltaModOppSUPER: ' + recordId);
        
        if ('Oportunidad__c' == recordId.getSobjectType().getDescribe().getName()) {
            List<Oportunidad__c> lOpps = [SELECT Id, RecordType.DeveloperName, Codigo_OC__c, Oportunidad_Relacionada__r.Codigo_OC__c, Name, Divisa__c, Etapa__c, Fecha_estimada_de_cierre__c, Probabilidad__c, Plazo_de_ejecuci_n_meses__c, Tipo_de_Negocio__c, 
                                          Importe_total_sin_IVA__c, Importe_total_ofertado_sin_IVA_local__c, importe_servicio__c, margen_servicio__c, Margen_Previsto_Local__c, importe_productoHard__c, margen_productoHard__c, importe_productoSoft__c, margen_productoSoft__c, 
                                          importe_mtoHard__c, margen_mtoHard__c, importe_mtoSoft__c, margen_mtoSoft__c, Codigo_Org_Comercial_IB__c, Cliente__c, Tipologia__c, Fecha_limite_de_presentacion__c,
										  Estado_oportunidad__c, COMAPOYO__r.FICEPI__c, PORCCOMAPOYO__c, Computar__c, Fase__c, Fecha_Creacion__c, CreatedDate, LastModifiedDate, Referencia_Comercial__c, Referencia_Comercial_lookup__r.Name, 
                                          VALIDACIONDEF__c, RENTPPTO__c, Internacional__c, Observaciones__c, Clase_de_oferta__c, FECULTREVISIONQ0__c, VALORACIONQ0__c, RIESGO__c, Riesgo_literal__c, OBSERVACIONESQ0__c, Objetivo_del_proyecto__c, 
                                          IMPORTEOCP__c, RENTABILIDADOCP__c, CreatedBy.Name, Etapa_Fase__c, FICEPI_Business_Developer__c, Porcentaje_Business_Developer__c, Fecha_apertura__c,Cross_Selling__c, 
                                          Porcentaje_Cross_Selling__c, Motivo_Cross_Selling__c, Comentario_Cross_Selling__c, Codigo_CR_HW_Super__c, Codigo_CR_SW_Super__c, FICEPI_Owner__c, Codigo_CR_Super__c, Codigo_FICEPI_GP__c,
                                          NextGeneration__c, Rentabilidad__c, Margen_Previsto_Euros__c, Codigo_Area_Con_Tecnologica__c, Codigo_CCI__c, Cliente__r.Codigo_Sector_texto__c, Cliente__r.Codigo_Subsector_texto__c,
                                          Codigo_Estado_de_Cierre__c, Estado_de_Cierre__c, Nombre_Corto__c, Sociedad_Ayesa__c, Direccion_Operaciones__c, Mercado__c, DivisionPicklist__c, Subdivision1__c
										  FROM Oportunidad__c                                         
                                          WHERE Id = :recordId LIMIT 1];
            
            //Oportunidad/Extension
            if (!lOpps.isEmpty()) {
        		  
             	Oportunidad__c opp = lOpps.get(0);               		
            	String tipoItem = 'O';
                if (opp.Oportunidad_Relacionada__r.Codigo_OC__c != null) {
                    tipoItem = 'E';
                }
  
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();				
                gen.writeStringField('tipoItem', tipoItem);
                gen.writeStringField('idItem', opp.Id);
                gen.writeStringField('codItem', opp.Codigo_OC__c);
                gen.writeStringField('codOportunidadPadre', (opp.Oportunidad_Relacionada__r.Codigo_OC__c != null) ? (String)opp.Oportunidad_Relacionada__r.Codigo_OC__c : '');
                gen.writeStringField('denItem', (opp.Nombre_Corto__c != null) ? opp.Nombre_Corto__c : '');
                gen.writeStringField('moneda', (opp.Divisa__c != null) ? opp.Divisa__c : '');
                gen.writeStringField('codEstado', (opp.Codigo_Estado_de_Cierre__c != null) ? opp.Codigo_Estado_de_Cierre__c : '');
                if (opp.FICEPI_Owner__c != null) {
                    gen.writeNumberField('idFICEPIComercial', Integer.valueOf(opp.FICEPI_Owner__c));
                } else {
                    gen.writeNullField('idFICEPIComercial');
                }
                gen.writeStringField('etapaVentas', (opp.Etapa__c != null) ? ((opp.Etapa__c == 'Cerrada') ? opp.Estado_de_Cierre__c : opp.Etapa__c) : '');
                if (opp.Fecha_estimada_de_cierre__c != null) {
                    gen.writeDateField('fechaCierre', opp.Fecha_estimada_de_cierre__c);
                } else {
                    gen.writeNullField('fechaCierre');
                }
                if (opp.Codigo_CR_Super__c != null) {
                    gen.writeNumberField('codCR', Integer.valueOf(opp.Codigo_CR_Super__c));
                } else {
                    gen.writeNullField('codCR');
                }
                if (opp.Probabilidad__c != null) {
                    gen.writeNumberField('probabilidadExito', Decimal.valueOf(opp.Probabilidad__c));
                } else {
                    gen.writeNullField('probabilidadExito');
                }
                if (opp.Codigo_FICEPI_GP__c != null) {
                    gen.writeNumberField('idFICEPIGestorProduccion', Integer.valueOf(opp.Codigo_FICEPI_GP__c));
                } else {
                    gen.writeNullField('idFICEPIGestorProduccion');
                }
                if (opp.Rentabilidad__c != null) {
                    gen.writeNumberField('rentabilidad', opp.Rentabilidad__c);
                } else {
                    gen.writeNullField('rentabilidad');
                }
                if (opp.Plazo_de_ejecuci_n_meses__c != null) {
                    gen.writeNumberField('duracionProyectoEnMeses', opp.Plazo_de_ejecuci_n_meses__c);
                } else {
                    gen.writeNullField('duracionProyectoEnMeses');
                }
                gen.writeStringField('descObjetivo', '');
                gen.writeNullField('fechaInicioObjetivo');
                gen.writeNullField('fechaFinObjetivo');
                gen.writeStringField('ofertaObjetivo', '');
                gen.writeNullField('contratacionPrevistaObjetivo');
                gen.writeNullField('costePrevistoObjetivo');
                gen.writeStringField('tipoNegocio', (opp.Tipo_de_Negocio__c != null) ? opp.Tipo_de_Negocio__c : '');
                if (opp.RecordType.DeveloperName == 'Ibermatica_Latam') {
                    if (opp.Importe_total_ofertado_sin_IVA_local__c != null) {
                        gen.writeNumberField('importeTotal', opp.Importe_total_ofertado_sin_IVA_local__c);
                    } else {
                        gen.writeNullField('importeTotal');
                    }
                    if (opp.Margen_Previsto_Local__c != null) {
                        gen.writeNumberField('margenTotal', opp.Margen_Previsto_Local__c);
                    } else {
                        gen.writeNullField('margenTotal');
                    }                         
                } else {
                    if (opp.Importe_total_sin_IVA__c != null) {
                        gen.writeNumberField('importeTotal', opp.Importe_total_sin_IVA__c);
                    } else {
                        gen.writeNullField('importeTotal');
                    }
                    if (opp.Margen_Previsto_Euros__c != null) {
                        gen.writeNumberField('margenTotal', opp.Margen_Previsto_Euros__c);
                    } else {
                        gen.writeNullField('margenTotal');
                    }                    
                }
                if (opp.importe_servicio__c != null) {
                    gen.writeNumberField('importeServicio', opp.importe_servicio__c);
                } else {
                    gen.writeNullField('importeServicio');
                }
                if (opp.margen_servicio__c != null) {
                    gen.writeNumberField('margenServicio', opp.margen_servicio__c);
                } else {
                    gen.writeNullField('margenServicio');
                }
                if (opp.importe_productoHard__c != null) {
                    gen.writeNumberField('importeProductoHard', opp.importe_productoHard__c);
                } else {
                    gen.writeNullField('importeProductoHard');
                }
                if (opp.margen_productoHard__c != null) {
                    gen.writeNumberField('margenProductoHard', opp.margen_productoHard__c);
                } else {
                    gen.writeNullField('margenProductoHard');
                }
                if (opp.importe_productoSoft__c != null) {
                    gen.writeNumberField('importeProductoSoft', opp.importe_productoSoft__c);
                } else {
                    gen.writeNullField('importeProductoSoft');
                }
                if (opp.margen_productoSoft__c != null) {
                    gen.writeNumberField('margenProductoSoft', opp.margen_productoSoft__c);
                } else {
                    gen.writeNullField('margenProductoSoft');
                }
                if (opp.importe_mtoHard__c != null) {
                    gen.writeNumberField('importeMtoHard', opp.importe_mtoHard__c);
                } else {
                    gen.writeNullField('importeMtoHard');
                }
                if (opp.margen_mtoHard__c != null) {
                    gen.writeNumberField('margenMtoHard', opp.margen_mtoHard__c);
                } else {
                    gen.writeNullField('margenMtoHard');
                }
                if (opp.importe_mtoSoft__c != null) {
                    gen.writeNumberField('importeMtoSoft', opp.importe_mtoSoft__c);
                } else {
                    gen.writeNullField('importeMtoSoft');
                }
                if (opp.margen_mtoSoft__c != null) {
                    gen.writeNumberField('margenMtoSoft', opp.margen_mtoSoft__c);
                } else {
                    gen.writeNullField('margenMtoSoft');
                }
                if (opp.Codigo_Org_Comercial_IB__c != null) {
                    gen.writeStringField('idOrganizacionComercialCRM', opp.Codigo_Org_Comercial_IB__c); 
                } else {
                    if(!Test.isRunningTest()){
                        String division = opp.DivisionPicklist__c;
                        Parametrica_2__c param = [SELECT Id FROM Parametrica_2__c WHERE RecordType.DeveloperName ='Organizacion' and Name=:division LIMIT 1];
                        gen.writeStringField('idOrganizacionComercialCRM', (param.Id != null) ? param.Id : '');
                    } 
                }                
                gen.writeStringField('idSectorCRM', (opp.Cliente__r.Codigo_Sector_texto__c != null) ? opp.Cliente__r.Codigo_Sector_texto__c : '');
                gen.writeStringField('idSegmentoCRM', (opp.Cliente__r.Codigo_Subsector_texto__c != null) ? opp.Cliente__r.Codigo_Subsector_texto__c : '');
                gen.writeStringField('idAreaConTecnoCRM', (opp.Codigo_Area_Con_Tecnologica__c != null) ? opp.Codigo_Area_Con_Tecnologica__c : '');
                gen.writeStringField('idCCICRM', (opp.Codigo_CCI__c != null) ? opp.Codigo_CCI__c : '');
                gen.writeStringField('idCuentaCRM', (opp.Cliente__c != null) ? opp.Cliente__c : '');
                if (opp.Tipologia__c != null) {
                    gen.writeNumberField('idModalidadContratoCRM', Integer.valueOf(opp.Tipologia__c));
                } else {
                    gen.writeNullField('idModalidadContratoCRM');
                }
                if (opp.Fecha_limite_de_presentacion__c != null) {
                    gen.writeDateField('fechaLimitePresentacion', opp.Fecha_limite_de_presentacion__c);
                } else {
                    gen.writeNullField('fechaLimitePresentacion');
                }
                gen.writeStringField('clasificacionMM', (opp.Estado_oportunidad__c != null) ? opp.Estado_oportunidad__c : '');
                if (opp.COMAPOYO__r.FICEPI__c != null) {
                    gen.writeNumberField('idFICEPIComercialApoyo', Integer.valueOf(opp.COMAPOYO__r.FICEPI__c));
                } else {
                    gen.writeNullField('idFICEPIComercialApoyo');
                }
                if (opp.PORCCOMAPOYO__c != null) {
                    gen.writeNumberField('porcentajeComercialApoyo', opp.PORCCOMAPOYO__c);
                } else {
                    gen.writeNullField('porcentajeComercialApoyo');
                }
                gen.writeStringField('computar', (opp.Computar__c ? '1' : '0'));
                gen.writeStringField('fase', (opp.Fase__c != null) ? opp.Fase__c : '');
                if (opp.Fecha_Creacion__c != null) {
                    //gen.writeDateTimeField('fechaCreacionCRM', opp.Fecha_Creacion__c);
                    gen.writeStringField('fechaCreacionCRM', opp.Fecha_Creacion__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')); 
                } else {
                    gen.writeStringField('fechaCreacionCRM', opp.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss'));
                }
                if (opp.LastModifiedDate != null) {
                    //gen.writeDateTimeField('fechaUltimaModificacionCRM', opp.LastModifiedDate);
                    gen.writeStringField('fechaUltimaModificacionCRM', opp.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')); 
                } else {
                    gen.writeNullField('fechaUltimaModificacionCRM');
                }
                gen.writeStringField('esRefComercial', (opp.Referencia_Comercial__c != null) ? opp.Referencia_Comercial__c : '');
                gen.writeStringField('refComercial', (opp.Referencia_Comercial_lookup__r.Name != null) ? (String)opp.Referencia_Comercial_lookup__r.Name : '');
                if (opp.VALIDACIONDEF__c != null) {
                    gen.writeNumberField('validacionDEF', Integer.valueOf(opp.VALIDACIONDEF__c));
                } else {
                    gen.writeNullField('validacionDEF');
                }
                if (opp.RENTPPTO__c != null) {
                    gen.writeNumberField('rentPPTO', opp.RENTPPTO__c);
                } else {
                    gen.writeNullField('rentPPTO');
                }
                gen.writeStringField('esInternacional', (opp.Internacional__c ? 'Sí' : 'No'));
                gen.writeStringField('observaciones', (opp.Observaciones__c != null) ? opp.Observaciones__c : '');
                gen.writeStringField('tipoOferta', (opp.Clase_de_oferta__c != null) ? opp.Clase_de_oferta__c : '');
                if (opp.FECULTREVISIONQ0__c != null) {
                    gen.writeDateField('fecUltRevisionQ0', opp.FECULTREVISIONQ0__c);
                } else {
                    gen.writeNullField('fecUltRevisionQ0');
                }
                if (opp.VALORACIONQ0__c != null) {
                    gen.writeNumberField('valoracionQ0', opp.VALORACIONQ0__c);
                } else {
                    gen.writeNullField('valoracionQ0');
                }
                if (opp.RIESGO__c != null) {
                    gen.writeNumberField('riesgo', Integer.valueOf(opp.RIESGO__c));
                } else {
                    gen.writeNullField('riesgo');
                }
                gen.writeStringField('riesgoLiteral', (opp.Riesgo_literal__c != null) ? opp.Riesgo_literal__c : '');
                gen.writeStringField('observacionesQ0', (opp.OBSERVACIONESQ0__c != null) ? opp.OBSERVACIONESQ0__c : '');
                gen.writeStringField('objetivo', (opp.Objetivo_del_proyecto__c != null) ? opp.Objetivo_del_proyecto__c : '');
                if (opp.IMPORTEOCP__c != null) {
                 	gen.writeNumberField('importeOCP', opp.IMPORTEOCP__c);   
                } else {
                	gen.writeNullField('importeOCP');    
                }
                if (opp.RENTABILIDADOCP__c != null) {
                 	gen.writeNumberField('rentabilidadOCP', opp.RENTABILIDADOCP__c);   
                } else {
                	gen.writeNullField('rentabilidadOCP');    
                }
                gen.writeStringField('creadoPor', (opp.CreatedBy.Name != null) ? opp.CreatedBy.Name : '');
                gen.writeStringField('nextGenerationNew', (opp.NextGeneration__c != null) ? opp.NextGeneration__c : '');
                gen.writeStringField('faseIMM', (opp.Etapa_Fase__c != null) ? opp.Etapa_Fase__c : '');
                if (opp.FICEPI_Business_Developer__c != null) {
                    gen.writeNumberField('businessDeveloper', Integer.valueOf(opp.FICEPI_Business_Developer__c));
                } else {
                    gen.writeNullField('businessDeveloper');
                }
                if (opp.Porcentaje_Business_Developer__c != null) {
                    gen.writeNumberField('porcentajeBusinessDeveloper', opp.Porcentaje_Business_Developer__c);
                } else {
                    gen.writeNullField('porcentajeBusinessDeveloper');
                }
                if (opp.Fecha_apertura__c != null) {
                    gen.writeDateField('fechaInicioProyecto', opp.Fecha_apertura__c);
                } else {
                    gen.writeNullField('fechaInicioProyecto');
                }
                gen.writeStringField('origenOportunidad', (opp.Clase_de_oferta__c != null) ? opp.Clase_de_oferta__c : '');
                gen.writeStringField('sinergia', (opp.Cross_Selling__c) ? '1' : '0');
                if (opp.Porcentaje_Cross_Selling__c != null) {
                    gen.writeNumberField('percentSinergia', opp.Porcentaje_Cross_Selling__c);
                } else {
                    gen.writeNullField('percentSinergia');
                }
                gen.writeStringField('motivoSinergia', (opp.Motivo_Cross_Selling__c != null) ? opp.Motivo_Cross_Selling__c : '');
                gen.writeStringField('observaSinergia', (opp.Comentario_Cross_Selling__c != null) ? opp.Comentario_Cross_Selling__c : '');
                if (opp.Codigo_CR_HW_Super__c != null) {
                    gen.writeNumberField('crHardware', Integer.valueOf(opp.Codigo_CR_HW_Super__c));
                } else {
                    gen.writeNullField('crHardware');
                }
                if (opp.Codigo_CR_SW_Super__c != null) {
                    gen.writeNumberField('crSoftware', Integer.valueOf(opp.Codigo_CR_SW_Super__c));
                } else {
                    gen.writeNullField('crSoftware');
                }
                gen.writeStringField('sociedad', (opp.Sociedad_Ayesa__c != null) ? opp.Sociedad_Ayesa__c : '');
                gen.writeStringField('direccionOperaciones', (opp.Direccion_Operaciones__c != null) ? opp.Direccion_Operaciones__c : '');
                gen.writeStringField('mercado', (opp.Mercado__c != null) ? opp.Mercado__c : '');
                gen.writeStringField('divisionMercado', (opp.DivisionPicklist__c != null) ? opp.DivisionPicklist__c : '');
                gen.writeStringField('subdivisionMercado', (opp.Subdivision1__c != null) ? opp.Subdivision1__c : '');
                gen.writeEndObject();
               	
                String request = gen.getAsString();               
                String endpoint = 'callout:MULE_API_Oportunidades/super/oportunidades';
                
                CRM_IB_MulesoftAPI.callApiMule(endpoint, request,'PUT',recordId, 'AltaModOportunidadSUPER'); 

            } else {
               System.debug('Oportunidad no encontrada: ' + recordId); 
            }   
            
        } else if ('Objetivo__c' == recordId.getSobjectType().getDescribe().getName()) {
            
            List<Objetivo__c> lObjetivos = [SELECT Id, Codigo_Objetivo__c, name, Divisa__c, Estado__c, Desc_objetivo__c, Fecha_ini__c, Fecha_max__c, Tipo_de_Negocio__c, Cuenta__c,
                                                   FICEPI_Owner__c, Codigo_Org_Comercial_IB__c, Cuenta__r.Codigo_Sector_texto__c, Cuenta__r.Codigo_Subsector_texto__c, CreatedDate, 
                                            	   LastModifiedDate, CreatedBy.Name, Oferta__c, Coste_Previsto__c, vnprev__c
                                            FROM Objetivo__c WHERE Id = :recordId LIMIT 1];            
            if (!lObjetivos.isEmpty()) {        	
             System.debug('Objetivo CRM_IB_AltaModOppSUPER');
                Objetivo__c obj = lObjetivos.get(0);               		
            
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();				
                gen.writeStringField('tipoItem', 'P');
                gen.writeStringField('idItem', obj.Id);
                gen.writeStringField('codItem', obj.Codigo_Objetivo__c);
                gen.writeStringField('codOportunidadPadre', '');
                gen.writeStringField('denItem', (obj.Name != null) ? obj.Name : '');
                gen.writeStringField('moneda', (obj.Divisa__c != null) ? obj.Divisa__c : '');
                gen.writeStringField('codEstado', (obj.Estado__c != null) ? obj.Estado__c : '');
                if (obj.FICEPI_Owner__c != null) {
                    gen.writeNumberField('idFICEPIComercial', Integer.valueOf(obj.FICEPI_Owner__c));
                } else {
                    gen.writeNullField('idFICEPIComercial');
                }
                gen.writeStringField('etapaVentas', '');
                gen.writeNullField('fechaCierre');
                gen.writeNullField('codCR');
                gen.writeNullField('probabilidadExito');
                gen.writeNullField('idFICEPIGestorProduccion');
                gen.writeNullField('rentabilidad');
                gen.writeNullField('duracionProyectoEnMeses');
                gen.writeStringField('descObjetivo', (obj.Desc_objetivo__c != null) ? obj.Desc_objetivo__c : '');
                if (obj.Fecha_ini__c != null) {
                    gen.writeDateField('fechaInicioObjetivo', obj.Fecha_ini__c);
                } else {
                    gen.writeNullField('fechaInicioObjetivo');
                }
                if (obj.Fecha_max__c != null) {
                    gen.writeDateField('fechaFinObjetivo', obj.Fecha_max__c);
                } else {
                    gen.writeNullField('fechaFinObjetivo');
                }
                if(obj.Oferta__c!=null){
                gen.writeStringField('ofertaObjetivo', obj.Oferta__c);
                }else{
                   gen.writeStringField('ofertaObjetivo',''); 
                }
                if (obj.vnprev__c != null) {
                    gen.writeNumberField('contratacionPrevistaObjetivo', obj.vnprev__c);
                } else {
                    gen.writeNullField('contratacionPrevistaObjetivo');
                }
                if (obj.Coste_Previsto__c != null) {
                    gen.writeNumberField('costePrevistoObjetivo', obj.Coste_Previsto__c);
                } else {
                    gen.writeNullField('costePrevistoObjetivo');
                }
                gen.writeStringField('tipoNegocio', (obj.Tipo_de_Negocio__c != null) ? obj.Tipo_de_Negocio__c : '');
                gen.writeNullField('importeTotal');
                gen.writeNullField('margenTotal');
                gen.writeNullField('importeServicio');
                gen.writeNullField('margenServicio');
                gen.writeNullField('importeProductoHard');
                gen.writeNullField('margenProductoHard');
                gen.writeNullField('importeProductoSoft');
                gen.writeNullField('margenProductoSoft');
                gen.writeNullField('importeMtoHard');
                gen.writeNullField('margenMtoHard');
                gen.writeNullField('importeMtoSoft');
                gen.writeNullField('margenMtoSoft');
                gen.writeStringField('idOrganizacionComercialCRM', (obj.Codigo_Org_Comercial_IB__c != null) ? obj.Codigo_Org_Comercial_IB__c : '');
                gen.writeStringField('idSectorCRM', (obj.Cuenta__r.Codigo_Sector_texto__c != null) ? obj.Cuenta__r.Codigo_Sector_texto__c : '');
                gen.writeStringField('idSegmentoCRM', (obj.Cuenta__r.Codigo_Subsector_texto__c != null) ? obj.Cuenta__r.Codigo_Subsector_texto__c : '');
                gen.writeStringField('idAreaConTecnoCRM', '');
                gen.writeStringField('idCCICRM', '');
                gen.writeStringField('idCuentaCRM', (obj.Cuenta__c != null) ? (String)obj.Cuenta__c : '');
                gen.writeNullField('idModalidadContratoCRM');
                gen.writeNullField('fechaLimitePresentacion');
                gen.writeStringField('clasificacionMM', '');
                gen.writeNullField('idFICEPIComercialApoyo');
                gen.writeNullField('porcentajeComercialApoyo');
                gen.writeStringField('computar', '');
                gen.writeStringField('fase', '');
                gen.writeStringField('fechaCreacionCRM', obj.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')); 
                gen.writeStringField('fechaUltimaModificacionCRM', obj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')); 
                gen.writeStringField('esRefComercial', '');
                gen.writeStringField('refComercial', '');
                gen.writeNullField('validacionDEF');
                gen.writeNullField('rentPPTO');
                gen.writeStringField('esInternacional', '');
                gen.writeStringField('observaciones', '');
                gen.writeStringField('tipoOferta', '');
                gen.writeNullField('fecUltRevisionQ0');
                gen.writeNullField('valoracionQ0');
                gen.writeNullField('riesgo');
                gen.writeStringField('riesgoLiteral', '');
                gen.writeStringField('observacionesQ0', '');
                gen.writeStringField('objetivo', '');
               	gen.writeNullField('importeOCP');    
                gen.writeNullField('rentabilidadOCP');    
                gen.writeStringField('creadoPor', (obj.CreatedBy.Name != null) ? obj.CreatedBy.Name : '');
                gen.writeStringField('nextGenerationNew', '');
                gen.writeStringField('faseIMM', '');
                gen.writeNullField('businessDeveloper');
                gen.writeNullField('porcentajeBusinessDeveloper');
                gen.writeNullField('fechaInicioProyecto');
                gen.writeStringField('origenOportunidad', '');
                gen.writeStringField('sinergia', '');
                gen.writeNullField('percentSinergia');
                gen.writeStringField('motivoSinergia', '');
                gen.writeStringField('observaSinergia', '');
                gen.writeNullField('crHardware');
                gen.writeNullField('crSoftware');
                gen.writeStringField('sociedad', '');
                gen.writeStringField('direccionOperaciones', '');
                gen.writeStringField('mercado', '');
                gen.writeStringField('divisionMercado', '');
                gen.writeStringField('subdivisionMercado', '');
                gen.writeEndObject();
               	
                String request = gen.getAsString();               
                String endpoint = 'callout:MULE_API_Oportunidades/super/oportunidades';

                CRM_IB_MulesoftAPI.callApiMule(endpoint, request,'PUT',recordId, 'AltaModOportunidadSUPER'); 
            
            } else {
               System.debug('Objetivo no encontrado: ' + recordId); 
            }             
        } else {
           System.debug('Tipo objeto no tratado: ' + recordId);  
        }     
    }
}
public class CRM_ImportesSME_Utils {
    
    @AuraEnabled
    public static void recalcularImportesOportunidad(Id idOportunidad, boolean dmlaction) {
        
        System.debug('Metodo recalcularImportesOportunidad');
        
        Id recordTypeSME = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        Double descuento = 1;
        Double importe;
        Double margen;
        
        List <Oportunidad__c> oportunidades = [SELECT Id, name,Clonada__c,Desglose_importes__c,importe_mtoHard__c, importe_productoHard__c, importe_mtoSoft__c, importe_productoSoft__c, importe_servicio__c,
                                               margen_productoHard__c, margen_productoSoft__c, margen_mtoHard__c, margen_mtoSoft__c, margen_servicio__c,
                                               Rentabilidad_HW__c, Rentabilidad_Mtto_HW__c, Rentabilidad_Mtto_SW__c, Rentabilidad_SW__c, Rentabilidad_Serv__c, 
                                               Importe_total_sin_IVA__c,Importe_Licitacion__c,Margen_contrato__c,Margen_Previsto_Euros__c,recordTypeId
                                               FROM Oportunidad__c
                                               WHERE Id = :idOportunidad LIMIT 1];
    
        
        if (!oportunidades.isEmpty()) {
                            
            Oportunidad__c opp = oportunidades.get(0);
            
            //Blanqueamos campos para el recalculo
            opp.importe_productoHard__c = 0;
            opp.margen_productoHard__c = 0;
            opp.Rentabilidad_HW__c = 0;
            opp.importe_mtoHard__c = 0;             
            opp.margen_mtoHard__c  = 0;
            opp.Rentabilidad_Mtto_HW__c = 0;
            opp.importe_productoSoft__c = 0;
            opp.Margen_productoSoft__c = 0;                 
            opp.Rentabilidad_SW__c = 0;
            opp.importe_mtoSoft__c = 0;
            opp.margen_mtoSoft__c = 0;                                  
            opp.Rentabilidad_Mtto_SW__c = 0;
            opp.importe_servicio__c = 0;                
            opp.margen_servicio__c = 0;                     
            opp.Rentabilidad_Serv__c = 0;
            opp.Importe_total_sin_IVA__c = 0;
            opp.Margen_Previsto_Euros__c = 0;
            opp.Modificar_importes__c = true;
            
            List<ImporteSME__c> importes = [SELECT Id, Name, Importe_Bruto__c, Descuento_cantidad__c, Coste__c, Cantidad__c, Descuento__c, Oportunidad__c, Seccion__c, Tipo__c, 
                                            Tipo_de_Pago__c, Observaciones__c, Importe__c, Area__c, Solucion__c, Producto__c, Area_picklist__c, Modulo__c, Record_Type_Opp__c, 
                                            Coste_horas__c, Margen__c, Horas__c 
                                            FROM ImporteSME__c 
                                            WHERE Oportunidad__c = :idOportunidad];
                                            
            if (!importes.isEmpty()) {
                
                for (ImporteSME__c item : importes) {
                
                    if (item.Descuento__c != 0 || item.Descuento__c != null){
                        descuento = (100-item.Descuento__c)/100; 
                    }
                    importe = item.Importe_bruto__c*descuento;
                    margen = importe - item.Coste__c;
                    
                    System.debug('Importe ' + item.Name + ', Descuento: ' + descuento + ', Importe: ' + importe + ', Margen: ' + margen);
                    
                    switch on item.Seccion__c {     
                        when 'HARD' {
                            opp.importe_productoHard__c += importe;
                            opp.margen_productoHard__c += margen;                       
                            if(importe != 0 && importe != null){
                                opp.Rentabilidad_HW__c +=  margen*100 / importe;
                            }           
                        }
                        when 'MTTO.HARD' {              
                            opp.importe_mtoHard__c += importe;              
                            opp.margen_mtoHard__c  += margen;
                            if(importe!= 0 && importe != null){
                                opp.Rentabilidad_Mtto_HW__c +=  margen*100 / importe;
                            }
                        }
                        when 'SOFT' {
                            opp.importe_productoSoft__c += importe;
                            opp.Margen_productoSoft__c += margen;                   
                            if(importe!= 0 && importe != null) {
                                opp.Rentabilidad_SW__c += margen*100 / importe;
                            }       
                        }           
                        when 'MTTO.SOFT' {
                            opp.importe_mtoSoft__c += importe;
                            opp.margen_mtoSoft__c += margen;                                    
                            if(importe != 0 && importe != null){
                                opp.Rentabilidad_Mtto_SW__c += margen*100 / importe;
                            }       
                        }
                        when 'SRV' {
                            if(opp.RecordTypeId == recordTypeSME){
                                opp.importe_servicio__c += importe;
                                
                                Double coste_hora_calc = decimal.valueOf(item.Coste_horas__c)*item.Horas__c;
                                item.Coste__c=coste_hora_calc;
                                
                                opp.margen_servicio__c += (importe - coste_hora_calc);
                                
                                if(importe != 0 && importe != null){
                                    opp.Rentabilidad_Serv__c +=  (importe - coste_hora_calc)*100/ importe;                          
                                }
                            } else {
                                opp.importe_servicio__c += importe;             
                                opp.margen_servicio__c += margen;   
                                if(importe != 0 && importe != null){
                                    opp.Rentabilidad_Serv__c += margen*100 / importe;
                                }
                            }
                        }
                    }
                    
                    if(opp.Importe_total_sin_IVA__c == null) {
                        opp.Importe_total_sin_IVA__c = importe;
                    } else {
                        opp.Importe_total_sin_IVA__c += importe;
                    }
                    if(opp.Margen_Previsto_Euros__c == null) {
                        opp.Margen_Previsto_Euros__c = item.Margen__c;
                    } else {
                        opp.Margen_Previsto_Euros__c += item.Margen__c;
                    }               
                }
                
                if (dmlaction) {
                    update opp;                   
                    //Cambio a false el modificar importes
                    opp.Modificar_importes__c = false;
                    update opp;                     
                } else {
                    System.debug('Datos Oportunidad:');
                    System.debug('importe_productoHard__c:' + opp.importe_productoHard__c);
                    System.debug('margen_productoHard__c :' + opp.margen_productoHard__c);
                    System.debug('Rentabilidad_HW__c:' + opp.Rentabilidad_HW__c);
                    System.debug('importe_mtoHard__c:' + opp.importe_mtoHard__c);               
                    System.debug('margen_mtoHard__c:' +  opp.margen_mtoHard__c);
                    System.debug('Rentabilidad_Mtto_HW__c:' + opp.Rentabilidad_Mtto_HW__c);
                    System.debug('importe_productoSoft__c:' + opp.importe_productoSoft__c);
                    System.debug('Margen_productoSoft__c:' + opp.Margen_productoSoft__c);                   
                    System.debug('Rentabilidad_SW__c:' + opp.Rentabilidad_SW__c);
                    System.debug('importe_mtoSoft__c:' + opp.importe_mtoSoft__c);
                    System.debug('margen_mtoSoft__c:' + opp.margen_mtoSoft__c);                                 
                    System.debug('Rentabilidad_Mtto_SW__c:' + opp.Rentabilidad_Mtto_SW__c);
                    System.debug('importe_servicio__c:' + opp.importe_servicio__c);                 
                    System.debug('margen_servicio__c:' + opp.margen_servicio__c);                       
                    System.debug('Rentabilidad_Serv__c:' + opp.Rentabilidad_Serv__c);
                    System.debug('Importe_total_sin_IVA__c: ' + opp.Importe_total_sin_IVA__c);
                    System.debug('Margen_Previsto_Euros__c: ' + opp.Margen_Previsto_Euros__c);
                }  
                
            } else {        
                System.debug('No se han encontrado importes para la oportundiad ' + idOportunidad);
            }
        } else {
            System.debug('No se ha encontrado oportunidad para el id ' + idOportunidad);
        }
    }
}
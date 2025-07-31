trigger CRM_ImportesSME on ImporteSME__c (before insert,before update,after delete) {
    
    //Get User email from logged user
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    if (emailAddress != usuario_no_trigger.Correo_usuario__c) {
        
        System.debug('Ejecutamos trigger ImporteSME');

		List <Oportunidad__c> list_opps_update = new List<Oportunidad__c>();
		List <Oportunidad__c> list_opps_update_clonada_false = new List<Oportunidad__c>();
		Map<Id, Oportunidad__c> map_opps_update_clonada_false = new Map<Id, Oportunidad__c>();
        
		if(Trigger.isDelete) {
			
			System.debug('Trigger delete');
			for(ImporteSME__c item: Trigger.old ) {
				if(item.Oportunidad__c != null)  { 
					
					Id idOportunidad = item.Oportunidad__c;
					List <Oportunidad__c> oportunidades = [SELECT Id, name,Clonada__c,Desglose_importes__c,importe_mtoHard__c, importe_productoHard__c, importe_mtoSoft__c, importe_productoSoft__c, importe_servicio__c,
                                           margen_productoHard__c, margen_productoSoft__c, margen_mtoHard__c, margen_mtoSoft__c, margen_servicio__c,
                                           Rentabilidad_HW__c, Rentabilidad_Mtto_HW__c, Rentabilidad_Mtto_SW__c, Rentabilidad_SW__c, Rentabilidad_Serv__c, 
                                           Importe_total_sin_IVA__c,Importe_Licitacion__c,Margen_contrato__c,Margen_Previsto_Euros__c,recordTypeId
                                           FROM Oportunidad__c
                                           WHERE Id = :idOportunidad LIMIT 1];
					
					if (!oportunidades.isEmpty()) {
						
						Oportunidad__c op_update = oportunidades.get(0);
						op_update.Modificar_importes__c = true;
						System.debug('Oportunidad: ' + op_update.Name );
						System.debug('item: '+ item);
						
						Oportunidad__c opp_actualizada =  CRM_IB_ImportesSME.deleteImportes(item, op_update);
						list_opps_update.add(opp_actualizada);
						
					} else {
						System.debug('No se ha encontrado oportunidad para el id ' + idOportunidad);
					}
				} else {
					System.debug('No hay oportunidad relacionada');
				}
			}
		} else {
			
			for(ImporteSME__c item: Trigger.New) {
				
				if(item.Oportunidad__c != null )  { 
					
					Id idOportunidad = item.Oportunidad__c;
					List <Oportunidad__c> oportunidades = [SELECT Id, name,Clonada__c,Desglose_importes__c,importe_mtoHard__c, importe_productoHard__c, importe_mtoSoft__c, importe_productoSoft__c, importe_servicio__c,
                                           margen_productoHard__c, margen_productoSoft__c, margen_mtoHard__c, margen_mtoSoft__c, margen_servicio__c,
                                           Rentabilidad_HW__c, Rentabilidad_Mtto_HW__c, Rentabilidad_Mtto_SW__c, Rentabilidad_SW__c, Rentabilidad_Serv__c, 
                                           Importe_total_sin_IVA__c,Importe_Licitacion__c,Margen_contrato__c,Margen_Previsto_Euros__c,recordTypeId
                                           FROM Oportunidad__c
                                           WHERE Id = :idOportunidad LIMIT 1];
					
					if (!oportunidades.isEmpty()) {
						Oportunidad__c op_update = oportunidades.get(0);
						op_update.Modificar_importes__c = true;
						
						if(op_update.Desglose_importes__c == 'Sí') {
							if(Trigger.isInsert) {								
								System.debug('Trigger insert');
								Oportunidad__c opp_actualizada = CRM_IB_ImportesSME.insertImportes(item, op_update);
								list_opps_update.add(opp_actualizada);
								
							} else if (Trigger.isUpdate){
								System.debug('Trigger update');
								ImporteSME__c item_old = Trigger.oldMap.get(item.Id);								
								Oportunidad__c opp_actualizada = CRM_IB_ImportesSME.updateImportes(item, op_update, item_old);
								list_opps_update.add(opp_actualizada);
							}
						} else {
							System.debug('Desglose de importes: ' + op_update.Desglose_importes__c);
							item.addError('La oportunidad elegida no tiene desglose de importes. Actualiza el Gestor de Producción y Centro de Responsabilidad en la oportunidad');
						}						
					} else {
						System.debug('No se ha encontrado oportunidad para el id ' + idOportunidad);
					}
				} else {
					System.debug('No tiene oportunidad relacionada');
				} 
			}			
		}
        try {
        	if(!Test.isRunningTest()) {
            	update list_opps_update;
            }
            for (Oportunidad__c op: list_opps_update) {
                op.Modificar_importes__c = false;
                list_opps_update_clonada_false.add(op);    
            }
            
            for (Oportunidad__c aux : list_opps_update_clonada_false) {
                map_opps_update_clonada_false.put(aux.Id, aux);
            }
            
            update map_opps_update_clonada_false.values();
        
        } catch(DMLException e) { 
            System.debug('Error Importes: ' + e.getMessage());    
        }
        
    } else {
        System.debug('No ejecutamos trigger ImporteSME');
    }  
}
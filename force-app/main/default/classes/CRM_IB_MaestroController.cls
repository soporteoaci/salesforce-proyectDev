/**
* @author Ayesa
* @since 24-05-2023
* @desc Creacion APEX Controladora Maestros
* Controladora Maestros
*/
public class CRM_IB_MaestroController {
    @AuraEnabled
    public static String cargarOpp(Id idMaestro){
        String result;        
        List<Parametrica_2__c> lMaestros = [SELECT id,RecordType.DeveloperName,Codigo_Gestor_Produccion__c, Gestor_de_produccion__c, Centro_resp_Super__c, Organizacion__c,Codigo_CR__c, Tipo__c, Area__c,
                                            Solucion__c, Producto__c, SIC__c, Codigo_SIC__c, Sector__c, Subsector__c,  CCI__c, Sector_lookup__c, Organizacion_Comercial__c, Estado__c, 
                                            Area_Conocimiento_Tecnologica__c, Orden__c
                                          FROM Parametrica_2__c WHERE Id =:idMaestro LIMIT 1];
               
		if(!lMaestros.isEmpty()) {
			Parametrica_2__c maestro = lMaestros.get(0);
			
			System.debug('cargarOpp: ' + maestro.RecordType.developerName);
			
            String endpoint = 'callout:MULE_API_Maestros/'; 
            
			switch on maestro.RecordType.developerName {
			
				when 'Area_Conocimiento_Tecnologico' {					
					String request = '{' 
									 + '"idArea": "' + maestro.Id + '",' 
					                 + '"denominacion": "' + maestro.Area_Conocimiento_Tecnologica__c + '",' 
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'areas-con-tecnologico', request, 'POST', null, 'MaestroAreasConTecnologico');					
				}
				when 'Sector' {
					String request = '{' 
									 + '"idSector": "' + maestro.Id + '",'
					                 + '"denominacion": "' + maestro.Sector__c + '",'
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
									 
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'sectores', request, 'POST', null, 'MaestroSectores');                     
				}
				when 'Subsector' {
					String request = '{' +
									 + '"idSegmento": "' + maestro.Id + '",'
					                 + '"denominacion": "' + maestro.Subsector__c + '",'
									 + '"idSector": "' + maestro.Sector_lookup__c + '",'
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
									 
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'segmentos', request, 'POST', null, 'MaestroSegmentos');                                    
				}
				when 'Organizacion' {
					String request = '{' +
									 + '"idOrgComercial": "' + maestro.Id + '",'
					                 + '"denominacion": "' + maestro.Organizacion_Comercial__c + '",'
									 + '"estado": "' + maestro.Estado__c + '",'
									 + '"orden": ' + maestro.Orden__c
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'org-comerciales', request, 'POST', null, 'MaestroOrgComerciales');                                    
				}
				when 'CCI' {
					String request = '{' +
									 + '"idNLO": "' + maestro.Id + '",'
					                 + '"denominacion": "' + maestro.CCI__c + '",'
									 + '"estado": "' + maestro.Estado__c + '",'
									 + '"orden": ' + maestro.Orden__c
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'nlos', request, 'POST', null, 'MaestroCCIs');                                    
				}
                when else {
                    return 'El registro no es un Maestro SUPER.';
                }
			}
            
            return result;
			
		} else {
			return 'Registro de maestro no encontrado';
		}
    }
    
    @AuraEnabled
    public static String actualizarOpp(Id idMaestro){
        String result;        
        List<Parametrica_2__c> lMaestros = [SELECT id,RecordType.DeveloperName,Codigo_Gestor_Produccion__c, Gestor_de_produccion__c, Centro_resp_Super__c, Organizacion__c,Codigo_CR__c, Tipo__c, Area__c,
                                            Solucion__c, Producto__c, SIC__c, Codigo_SIC__c, Sector__c, Subsector__c,  CCI__c, Sector_lookup__c, Organizacion_Comercial__c, Estado__c, 
                                            Area_Conocimiento_Tecnologica__c, Orden__c
                                            FROM Parametrica_2__c WHERE Id =:idMaestro LIMIT 1];
        
		if(!lMaestros.isEmpty()) {
			Parametrica_2__c maestro = lMaestros.get(0);
			
			System.debug('actualizarOpp: ' + maestro.RecordType.developerName);

        	String endpoint = 'callout:MULE_API_Maestros/'; 
           
			switch on maestro.RecordType.developerName {
			
				when 'Area_Conocimiento_Tecnologico' {					
					String request = '{' 
					                 + '"denominacion": "' + maestro.Area_Conocimiento_Tecnologica__c + '",' 
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'areas-con-tecnologico', request, 'PUT', maestro.Id, 'MaestroAreasConTecnologico');					
				}
				when 'Sector' {
					String request = '{' 
					                 + '"denominacion": "' + maestro.Sector__c + '",'
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
									 
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'sectores', request, 'PUT', maestro.Id, 'MaestroSectores');                     
				}
				when 'Subsector' {
					String request = '{' +
					                 + '"denominacion": "' + maestro.Subsector__c + '",'
									 + '"idSector": "' + maestro.Sector_lookup__c + '",'
									 + '"estado": "' + maestro.Estado__c + '"'
									 + '}';
									 
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'segmentos', request, 'PUT', maestro.Id, 'MaestroSegmentos');                                    
				}
				when 'Organizacion' {
					String request = '{' +
					                 + '"denominacion": "' + maestro.Organizacion_Comercial__c + '",'
									 + '"estado": "' + maestro.Estado__c + '",'
									 + '"orden": ' + maestro.Orden__c
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'org-comerciales', request, 'PUT', maestro.Id, 'MaestroOrgComerciales');                                    
				}
				when 'CCI' {
					String request = '{' +
					                 + '"denominacion": "' + maestro.CCI__c + '",'
									 + '"estado": "' + maestro.Estado__c + '",'
									 + '"orden": ' + maestro.Orden__c
									 + '}';
					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'nlos', request, 'PUT', maestro.Id, 'MaestroCCIs');                                    
				}
                when else {
                    return 'El registro no es un Maestro SUPER.';
                }
			}
            
            return result;
			
		} else {
			return 'Registro de maestro no encontrado';
		}
    }
    
    @AuraEnabled
    public static String eliminarOpp(Id idMaestro){
        String result;        
        List<Parametrica_2__c> lMaestros = [SELECT id,RecordType.DeveloperName FROM Parametrica_2__c WHERE Id =:idMaestro LIMIT 1];
        
		if(!lMaestros.isEmpty()) {
			Parametrica_2__c maestro = lMaestros.get(0);
			
			System.debug('eliminarOpp: ' + maestro.RecordType.developerName);
			
        	String endpoint = 'callout:MULE_API_Maestros/'; 

			switch on maestro.RecordType.developerName {
			
				when 'Area_Conocimiento_Tecnologico' {					
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'areas-con-tecnologico', null, 'DELETE', maestro.Id, 'MaestroAreasConTecnologico');					
				}
				when 'Sector' {
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'sectores', null, 'DELETE', maestro.Id, 'MaestroSectores');                     
				}
				when 'Subsector' {
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'segmentos', null, 'DELETE', maestro.Id, 'MaestroSegmentos');                                    
				}
				when 'Organizacion' {
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'org-comerciales', null, 'DELETE', maestro.Id, 'MaestroOrgComerciales');                                    
				}
				when 'CCI' {
					result = CRM_IB_MulesoftAPI.callApiMule(endpoint + 'nlos', null, 'DELETE', maestro.Id, 'MaestroCCIs');                                    
				}
                when else {
                    return 'El registro no es un Maestro SUPER.';
                }
			}
            
            return result;
			
		} else {
			return 'Registro de maestro no encontrado';
		}
    }
}
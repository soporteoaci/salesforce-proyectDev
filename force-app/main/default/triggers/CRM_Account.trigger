/*26/12/2024
* Quitamos:
* flag validacion
* hayCambiosAccount
* isCamposInformados
* isAfterMethod
* 	tratamientoLogicaIbermaticaAfter:
* 	     altaClienteSUPER
*       altaClienteSAP
* 		 modifClienteSUPER

*/


trigger CRM_Account on Account (after update,before update) { 
    
    System.debug('Trigger Account'); 
    
    //Get User email from logged user 
    
    String emailAddress = UserInfo.getUserEmail(); 
    
    //Recuperamos el usuario para no ejecutar el trigger 
    
    
    
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1]; 
    
    
    
    if(emailAddress != usuario_no_trigger.Correo_usuario__c){ 
        
        System.debug('Ejecutamos trigger CRM Account'); 
        
        
        
        for(Account acc: Trigger.New){ 
            
            if (Trigger.isBefore) { 
                
                isBeforeMethod(acc, (Account)Trigger.oldMap.get(acc.Id));			 
                
            } else if (Trigger.isAfter) { 
                
               //12/2024 isAfterMethod(acc, (Account)Trigger.oldMap.get(acc.Id)); 
                
            }         
            
        } 
        
        
        
    }else{ 
        
        System.debug('No ejecutamos trigger CRM Account'); 
        
    } 

    private void isBeforeMethod(Account newAcc, Account oldAcc) { 
        
        System.debug('Metodo isBeforeMethod'); 
        
        tratamientoLogicaIbermaticaBefore(newAcc, oldAcc); 
        
    }   
    
    private void tratamientoLogicaIbermaticaBefore(Account newAcc, Account oldAcc) { 
        
        System.debug('Metodo tratamientoLogicaIbermaticaBefore'); 
        
        
        tratamientoDatosDireccion(newAcc); 
        
    } 
    
    
    
    /*Metodo para tratar los datos pais y provincia*/ 
    
    private void tratamientoDatosDireccion(Account acc) { 
        
        System.debug('Metodo tratamientoDatosDireccion'); 
        
        
        
        Id recordTypePaises = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Paises').getRecordTypeId(); 
        
        Id recordTypeProvincias = Schema.SObjectType.Parametrica_2__c.getRecordTypeInfosByName().get('Provincias').getRecordTypeId(); 
        
        
        
        List<Parametrica_2__c> lista_pais_provincia = [SELECT Id, Name, Codigo_Externo__c, Denominacion__c,Pais__r.Codigo_Externo__c, RecordType.Name  
                                                       
                                                       FROM Parametrica_2__c 
                                                       
                                                       Where RecordType.Name = 'Paises' or RecordType.Name ='Provincias']; 
        
        
        
        Map <String,String> map_paises = new Map <String,String>(); 
        
        List <Parametrica_2__c> map_provincias = new List<Parametrica_2__c>(); 
        
        
        
        for(Parametrica_2__c item : lista_pais_provincia){ 
            
            if(item.RecordType.Id ==recordTypePaises ){             
                
                map_paises.put(item.Denominacion__c,item.Codigo_Externo__c); 
                
            }else if (item.RecordType.Id ==recordTypeProvincias){            
                
                map_provincias.add(item); 
                
            } 
            
        } 
        
        
        
        String pais = acc.BillingCountry; 
        
        String provincia =acc.BillingState; 
        
        String ciudad = acc.BillingCity; 
        
        System.debug('pais: '+ pais);     
        
        System.debug('provincia: '+ provincia); 
        
        System.debug('ciudad: '+ ciudad);        
        
        System.debug('get pais del map: '+ map_paises.get(pais)); 
        
        acc.Codigo_Pais__c=map_paises.get(pais); 
        
        if(map_paises.get(pais) != null){ 
            
            for(Parametrica_2__c prov: map_provincias){ 
                
                if(prov.Denominacion__c == provincia && prov.pais__r.Codigo_externo__c == map_paises.get(pais) ){ 
                    
                    acc.Codigo_provincia__c= prov.Codigo_Externo__c; 
                    
                    System.debug('Codigo externo provincia: ' + prov.Codigo_Externo__c);                                
                    
                } 
                
            } 
            
        }   	 
        
    }         
    
}
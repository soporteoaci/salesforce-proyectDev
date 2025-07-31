trigger TaskTrigger on Task (before insert, before update) {
    
    System.debug('Trigger tarea');
    
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    if(emailAddress != usuario_no_trigger.Correo_usuario__c){
        
        
        for(Task tarea: trigger.new){
          
            //1. WhatId = null y Clic_Comercial__c != null --> WhatId=clic_Comercial__c
            //2. WhatId != null y Clic_comercial__c =null --> SI WhatID es Account --> Clic_comercial__c = WhatID
            
            if(tarea.Fecha_Creacion__c==null){
                tarea.Fecha_Creacion__c = system.today();
                
            }
          
            
        
            //CUENTAS
            System.debug('CUENTA');
            
            if(tarea.WhatId == null && tarea.Clic_Comercial__c != null){
                
               System.debug('Actualizamos whatid con clic comercial');
               tarea.WhatId=tarea.Clic_Comercial__c;
                
            }else if(tarea.WhatId != null && tarea.Clic_comercial__c ==null){
                
                String sObjName = tarea.WhatId.getSObjectType().getDescribe().getName();
                System.debug('Tipo de registro WhatId CUENTA: '+ sObjName);
                
                if (sObjName =='Account'){
                    System.debug('Actualizamos clic clomercial con  whatid');
                    tarea.Clic_comercial__c=tarea.WhatId;
                }
                
            }
            
         
            
            //3. WhoId = null y Contacto__c != null --> WhoId=Contacto__c
            //4. WhoId != null y Contacto__c = null --> Si WhoId es Contact --> Contacto__c = WhoId        
           
            
            //CONTACTOS
            System.debug('CONTACTO');
            
            if(tarea.WhoId == null && tarea.Contacto__c != null){
                
                System.debug('Actualizamos whoId con contacto y clic comercial con la cuenta del contacto');
           
                tarea.WhoId=tarea.Contacto__c;
                
                Contact contact = [Select AccountId FROM Contact WHERE Id =: tarea.Contacto__c];            
                tarea.Clic_comercial__c= contact.AccountId;
                
            }else if(tarea.WhoId != null && tarea.Contacto__c ==null){
                
                String sObjName = tarea.WhoId.getSObjectType().getDescribe().getName();
                
                System.debug('Tipo de registro WhoId CONTACTO: '+ sObjName);
                
                if (sObjName =='Contact'){
                    System.debug('Actualizamos contacto y clic clomercial con whoid y cuenta del contacto respectivamente');
                    tarea.Contacto__c=tarea.WhoId;
                    Contact contact = [Select AccountId FROM Contact WHERE Id =: tarea.Contacto__c];            
                    tarea.Clic_comercial__c= contact.AccountId;
                }
                
            }
            
            //1. WhatId = null y Oportunidad != null --> WhatId=Oportunidad__c
            //2. WhatId != null y Oportunidad__c =null --> SI WhatID es Oportunidad --> Oportunidad__c = WhatID
            
            //OPORTUNIDADES
            System.debug('OPORTUNIDAD');
            
            if(tarea.WhatId == null && tarea.Oportunidad__c != null){
                
                System.debug('Actualizamos what id con oportunidad y clic comercial con la cuenta de la oc');
                tarea.WhatId=tarea.Oportunidad__c;
                
                Oportunidad__c op = [Select Cliente__c FROM Oportunidad__c WHERE Id =: tarea.Oportunidad__c];            
                tarea.Clic_comercial__c= op.Cliente__c;
                
            }else if(tarea.WhatId != null && tarea.Oportunidad__c ==null){
                String sObjName = tarea.WhatId.getSObjectType().getDescribe().getName();
                
                System.debug('Tipo de registro WhatId OPORTUNIDAD: '+ sObjName);
                
                if (sObjName =='Oportunidad__c'){
                    System.debug('Actualizamos oportunidad con  whatid y cliente con el de la oportunidad');
                    tarea.Oportunidad__c=tarea.WhatId;
                    Oportunidad__c op = [Select Cliente__c FROM Oportunidad__c WHERE Id =: tarea.Oportunidad__c]; 
                    tarea.Clic_comercial__c = op.Cliente__c;
                }
                
            }
            
            //OBJETIVOS  
            System.debug('OBJETIVOS');
            
            if(tarea.WhatId == null && tarea.Objetivo__c != null){
                
                System.debug('Actualizamos whatid con objetivo y clic comercial con la cuenta del objetivo ');
                tarea.WhatId=tarea.Objetivo__c;
                
                Objetivo__c op = [Select Cuenta__c FROM Objetivo__c WHERE Id =: tarea.Objetivo__c];
                tarea.Clic_comercial__c= op.Cuenta__c;
                
                
               // System.debug(tarea.Objetivo__c + '/ Cuenta del objetivo: '+ tarea.Objetivo__r.Cuenta__c);
                
            }else if(tarea.WhatId != null && tarea.Objetivo__c ==null){
                
                String sObjName = tarea.WhatId.getSObjectType().getDescribe().getName();
                
                System.debug('Tipo de registro WhatId OBJETIVO: '+ sObjName);
                
                if (sObjName =='Objetivo__c'){
                    System.debug('Actualizamos objetivo con  whatid y el clic comercial con la cuenta del objetivo');
                    tarea.Objetivo__c=tarea.WhatId;
                    
                    Objetivo__c ob = [Select Cuenta__c FROM Objetivo__c WHERE Id =: tarea.Objetivo__c];
                    tarea.Clic_comercial__c = ob.Cuenta__c;
                }
                
            }
        
        }
         
    }else{
        System.debug('No ejecutamos trigger tarea');
    }
    
}
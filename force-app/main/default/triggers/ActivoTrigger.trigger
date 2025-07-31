trigger ActivoTrigger on Activo__c (after insert,after update, after delete) {
    
    //después de insert, update, delete
    //Buscamos la cuenta y añadimos el nombre/actualizamos nombre/quitamos nombre
    //Get User email from logged user
    String emailAddress = UserInfo.getUserEmail();
    //Recuperamos el usuario para no ejecutar el trigger
    No_ejecutar_triggers__c usuario_no_trigger = [SELECT Correo_usuario__c FROM No_ejecutar_triggers__c LIMIT 1];
    
    if(emailAddress != usuario_no_trigger.Correo_usuario__c){
        List<Id> accounts_Id = new List<Id>();
        Map<Id,account> map_accounts = new Map<Id,account>();
        List <Account> account_update = new List<Account>();
        
        //Obtenemos las cuentas que vamos a necesitar
        
        //cambio de cuenta en el activo
        List<Id> accounts_Id_old = new List<Id>();
        Map<Id,account> map_accounts_old = new Map<Id,account>();
        List <Account> account_update_old = new List<Account>();
        
        
        if(Trigger.isInsert){
            
            System.debug('Trigger insert. Recuperamos cuentas');
            for(Activo__c activo : Trigger.New){
                if (activo.Cuenta__c != null && !accounts_Id.contains(activo.Cuenta__c) ){
                    accounts_Id.add(activo.Cuenta__c);
                }
            }
            
            List <account> accounts = [SELECT Id,activos_cuentas__c,Name from Account where id in: accounts_id];
            System.debug('Tamaño accounts: '+ accounts.size());
            for(Account acc: accounts){
                map_accounts.put(acc.Id, acc);
            }
        }else if(Trigger.isUpdate) {
            
            System.debug('Trigger update. Recuperamos cuentas old y new');
            List <account> accounts = new List<Account>();
            List <account> accounts_old = new List<Account>();
            //Cuentas new
            for(Activo__c activo : Trigger.New){
                if (activo.Cuenta__c != null && !accounts_Id.contains(activo.Cuenta__c) ){
                    accounts_Id.add(activo.Cuenta__c);
                }
            }
            
            accounts = [SELECT Id,activos_cuentas__c,Name from Account where id in: accounts_id];
            for(Account acc: accounts){
                map_accounts.put(acc.Id, acc);
            }
            
            System.debug('Cuenta new: '+ map_accounts);
            
            //Cuentas old
            for(Activo__c activo : Trigger.Old){
                if (activo.Cuenta__c != null && !accounts_Id_old.contains(activo.Cuenta__c) ){
                    accounts_Id_old.add(activo.Cuenta__c);
                }
            }
            
            
            accounts_old = [SELECT Id,activos_cuentas__c,Name from Account where id in: accounts_id_old];
            for(Account acc: accounts_old){
                map_accounts_old.put(acc.Id, acc);
            }
            
            System.debug('Cuenta old: '+ map_accounts_old);
            
        } else if (Trigger.isDelete){
            System.debug('Trigger delete. Recuperamos cuentas');
            for(Activo__c activo : Trigger.Old){
                if (activo.Cuenta__c != null && !accounts_Id.contains(activo.Cuenta__c) ){
                    accounts_Id.add(activo.Cuenta__c);
                }
            }
            List <account> accounts = [SELECT Id,activos_cuentas__c,Name from Account where id in: accounts_id];
            System.debug('Tamaño accounts: '+ accounts.size());
            for(Account acc: accounts){
                map_accounts.put(acc.Id, acc);
            }
        }
        
        
        
        
        if(Trigger.isInsert){
            
            System.debug('Trigger insert. Actualizamos campo en cuenta');
            for(Activo__c activo: Trigger.New){
                
                Account cuenta = map_accounts.get(activo.Cuenta__c);
                system.debug('longitud: ' + String.isBlank(cuenta.Activos_cuentas__c));
                if(String.isBlank(cuenta.Activos_cuentas__c) == false){
                    
                    cuenta.Activos_cuentas__c =  cuenta.Activos_cuentas__c +' '+ activo.Name;
                    
                }else{
                    cuenta.Activos_cuentas__c = activo.Name;
                    
                }
                account_update.add(cuenta);
            }
            
            
        }else if(Trigger.isUpdate){
            System.debug('Trigger update');
            for(Activo__c activo: Trigger.New){
                Account cuenta = map_accounts.get(activo.Cuenta__c);
                
                if (activo.Name != Trigger.oldMap.get(activo.Id).Name){
                    System.debug('Trigger update. Actualizamos Name');
                    
                    if(cuenta.Activos_cuentas__c.contains(Trigger.oldMap.get(activo.Id).Name)){
                        string new_Name = cuenta.Activos_cuentas__c.replaceFirst(Trigger.oldMap.get(activo.Id).Name,activo.Name) ;
                        cuenta.Activos_cuentas__c= new_Name;
                        System.debug('Update New Name: '+new_Name);
                    }
                    account_update.add(cuenta);
                }
                
                                       /*
                Account cuenta_old = map_accounts_old.get(activo.Cuenta__c);
               System.debug('Cuenta new/Cuenta old: '+ cuenta + ' / ' + cuenta_old);
                
                if(activo.Cuenta__c != Trigger.oldMap.get(activo.Id).cuenta__c) {
                    //Todavía no funciona correctamente  ABR
                    //Cambio de cuenta en la actualización activo
                    
                    //hay que recuperar dos cuentas --> actuaizar las dos 
                   System.debug('Trigger update. Actualizamos Cuenta');
                    
                    string name_account_old = cuenta.Activos_cuentas__c.replaceFirst(Trigger.oldMap.get(activo.Id).Name,'');
                    string name_Account =  cuenta.Activos_cuentas__c +' '+ activo.Name; 
                    cuenta.Activos_cuentas__c= name_Account;
                    System.debug('Update New Name: '+name_Account);
                    account_update.add(cuenta_old);

                }  
            }*/
            }
            
        } else if (Trigger.isDelete){
            System.debug('Trigger delete. Actualizamos campo en cuenta');
            for(Activo__c activo: Trigger.Old){
                
                Account cuenta = map_accounts.get(activo.Cuenta__c);
                
                string new_Name = cuenta.Activos_cuentas__c.replaceFirst(activo.Name,'') ;
                cuenta.Activos_cuentas__c= new_Name;
                System.debug('Delete New Name: '+new_Name);
                account_update.add(cuenta);
                
            }
        }else{
            
        }
        
        try{
            update account_update;
        }catch(DMLException e){ 
            System.debug('Error Activo Trigger: ' + e.getMessage());
            
        }
    }
    
    

    
    
    
    
}
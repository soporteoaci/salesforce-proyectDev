trigger updateStatusSSC on Action__c (after insert, after update, before delete) {
    
    if (Trigger.isAfter) {
        List<Action__c> accs = [SELECT Id, Task_LK__c FROM Action__c WHERE Id IN :Trigger.new];
        if(accs.size()!= 0){
            for(Action__c a: accs){
                List<Action__c> accsByTask = [select Id, Status__c, Task_LK__c from Action__c where Task_LK__c = :a.Task_LK__c];
                String status = '';
                
                for(Action__c aByTask : accsByTask){
                    if(aByTask.Status__c == 'Abierta'){
                        status = 'Abierto';
                        break;
                    }else if(status != 'En proceso' && aByTask.Status__c == 'En proceso'){
                        status = 'En proceso';
                        
                    }else if(status != 'En proceso' && aByTask.Status__c == 'Cerrada'){
                        status = 'Cerrado';
                        
                    }else if(status != 'En proceso' && status != 'Cerrado'){
                        status = 'Validado';
                    }
                }
                
                SSC__c ssc = new SSC__c();
                ssc.Id = a.Task_LK__c;
                ssc.Status__c = status;
                update ssc;
            }
        }
    }
    if (Trigger.isBefore) {
        
        List<Action__c> accsold = [SELECT Id, Task_LK__c FROM Action__c WHERE Id IN :Trigger.old];
        if(accsold.size()!= 0){
            for(Action__c a: accsold){
                List<Action__c> accsByTask = [select Id, Status__c, Task_LK__c from Action__c where Task_LK__c = :a.Task_LK__c and Id != :a.Id];
                String status = '';
                if(accsByTask.size() != 0){
                    for(Action__c aByTask : accsByTask){
                        if(aByTask.Status__c == 'Abierta'){
                            status = 'Abierto';
                            break;
                        }else if(status != 'En proceso' && aByTask.Status__c == 'En proceso'){
                            status = 'En proceso';
                            
                        }else if(status != 'En proceso' && aByTask.Status__c == 'Cerrada'){
                            status = 'Cerrado';
                            
                        }else if(status != 'En proceso' && status != 'Cerrado'){
                            status = 'Validado';
                        }
                    }
                    
                    SSC__c ssc = new SSC__c();
                    ssc.Id = a.Task_LK__c;
                    ssc.Status__c = status;
                    System.debug(ssc);
                    update ssc;
                }
            }
        }
    }
}
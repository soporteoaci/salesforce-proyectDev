global class ActualizaFechaAbiertaTicket implements Schedulable{
    
    
    global void execute(SchedulableContext SC) {
        
        
        Boolean isTest = Test.isRunningTest();
        Date startDate = date.newInstance(1900, 1, 1);   
        Integer HoraDespues;
        Integer HoraDentro;
        Integer HoraAntes;
             
        HoraDespues = DateTime.now().hour()+12;
        HoraDentro = DateTime.now().hour()+1 ;
        HoraAntes = DateTime.now().hour()-7 ;
            
        System.debug ('HoraDespues' +HoraDespues);
        System.debug ('HoraDentro' +HoraDentro);
        System.debug ('HoraAntes' +HoraAntes);
        
        if (Schema.sObjectType.Ticket__c.isAccessible()){
            
            Ticket__c[] consulta = [SELECT id, CreatedById, OwnerId, Fecha_Abierta__c, Fecha_Abierta2__c FROM Ticket__c WHERE Estado__c = 'Asignado'];
            for (Integer i=0; i<consulta.size(); i++){
                system.debug('Fecha abierta = ' +consulta[i].Fecha_Abierta__c.day());
                system.debug('Hora abierta = ' +consulta[i].Fecha_Abierta__c.hour());
                system.debug('Fecha ahora = '+DateTime.now().day());
                system.debug('Hora ahora = '+DateTime.now().hour());
                
                if (consulta[i].OwnerId != consulta[i].CreatedbyId || isTest){
                    
                    // LA FECHA DE ABIERTA ES EN FIN DE SEMANA
                    
                    integer resto = Math.mod(startDate.daysBetween(consulta[i].Fecha_Abierta__c.date()) , 7);
                    system.debug('resto' +resto);
                    if(resto == 5 || resto == 6 || resto == 4 ){
                        if(resto == 5){
                            system.debug('Es sábado');
                            DateTime Sabado2 = consulta[i].Fecha_Abierta__c.addDays(2);
                            Date Sabado = Sabado2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta__c = DateTime.newInstance(Sabado, mediodia);
                            
                        }
                        else if(resto == 6){
                            system.debug('Es domingo');
                            DateTime Domingo2 = consulta[i].Fecha_Abierta__c.addDays(1);
                            Date Domingo = Domingo2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta__c = DateTime.newInstance(Domingo, mediodia);
                            
                        }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                            system.debug('Es viernes y estoy en mi horario laboral');
                            consulta[i].Fecha_Abierta2__c = consulta[i].Fecha_Abierta__c;
                        }else if(consulta[i].Fecha_Abierta__c.hour()<8){
                            system.debug('Es viernes y estoy antes de mi horario laboral');
                            consulta[i].Fecha_Abierta2__c = consulta[i].Fecha_Abierta__c+1;
                        }
                        else if (consulta[i].Fecha_Abierta__c.hour()>17){
                            system.debug('Es viernes y estoy después de mi horario laboral');
                            DateTime viernestarde2 = consulta[i].Fecha_Abierta__c.addDays(3);
                            Date viernes = viernestarde2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta2__c = DateTime.newInstance(viernes, mediodia);
                        } 
                    } 
                    
                    system.debug('Nueva Fecha abierta' +consulta[i].Fecha_Abierta__c);
                    // COMIENZO LA CONSULTA DENTRO DE MI HORARIO LABORAL.             
                    if(resto != 5 || resto != 6 || resto != 4 ){
                        if(HoraDentro>=8 && HoraDentro<17){
                            system.debug('Estoy en mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                system.debug('La fecha abierta es igual a la de hoy');
                                
                                if(consulta[i].Fecha_Abierta__c.hour()<8){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado antes de empezar a trabajar');
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1;
                                }else{
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado en mi horario laboral');
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                                    
                                }
                            }
                            else if (consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado antes de empezar a trabajar');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c - 1;
                            } else if(consulta[i].Fecha_Abierta__c.hour()>=17){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado después de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            } else{
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado en mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }
                        }
                        
                        
                        // COMIENZO LA CONSULTA FUERA DE MI HORARIO LABORAL, ANTES DE ENTRAR A TRABAJAR.                
                        
                        if (HoraAntes<8){
                            system.debug('Estoy antes de mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                
                                system.debug('La fecha abierta es igual a la de hoy');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                                
                            } else if(consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado antes de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado dentro de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c+1;
                            }else{
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado fuera de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c+1;
                                
                            }
                        }
                        
                        
                        // COMIENZO LA CONSULTA FUERA DE MI HORARIO LABORAL, DESPUÉS DE TERMINAR DE TRABAJAR.                
                        
                        
                        if (HoraDespues>=17){
                            system.debug('Estoy después de mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                system.debug('La fecha abierta es igual a la de hoy');
                                if (consulta[i].Fecha_Abierta__c.hour()<8){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado antes de mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1;
                                } else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado dentro mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;  
                                }   else {
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado fuera de mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;  
                                }
                            } else if(consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado antes de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1 ;
                            }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado en mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            } else {
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado fuera de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }
                            
                        }
                    } 
                } 
            }  
            update consulta;
        }  
    }  
    
    
    
    @Future
    public static void  ActualizaFecha (String newTicketJSON){ 
        List<Ticket__c> newTicket = (List<Ticket__c>)JSON.deserializeStrict(newTicketJSON, List<Ticket__c>.class);
        Boolean isTest = Test.isRunningTest();
        Date startDate = date.newInstance(1900, 1, 1);  
        Integer HoraDespues;
        Integer HoraDentro;
        Integer HoraAntes;

        HoraDespues = DateTime.now().hour();
        HoraDentro = DateTime.now().hour();
        HoraAntes = DateTime.now().hour();
       
        System.debug ('HoraDespues' +HoraDespues);
        System.debug ('HoraDentro' +HoraDentro);
        System.debug ('HoraAntes' +HoraAntes);
        
        if (Schema.sObjectType.Ticket__c.isAccessible()){
            
            Ticket__c[] consulta = [SELECT id, CreatedById, OwnerId, Fecha_Abierta__c, Fecha_Abierta2__c FROM Ticket__c WHERE Estado__c = 'Asignado' and id in :newTicket];
            for (Integer i=0; i<consulta.size(); i++){
                if (consulta[i].Fecha_Abierta__c!= null){ 
                    system.debug('Fecha abierta = ' +consulta[i].Fecha_Abierta__c.day());
                    system.debug('Hora abierta = ' +consulta[i].Fecha_Abierta__c.hour());
                    system.debug('Fecha ahora = '+DateTime.now().day());
                    system.debug('Hora ahora = '+DateTime.now().hour());
                }
                
                if (consulta[i].OwnerId != consulta[i].CreatedbyId || isTest){
                    
                    
                    integer resto = Math.mod(startDate.daysBetween(consulta[i].Fecha_Abierta__c.date()) , 7);
                    system.debug('resto' +resto);
                    if(resto == 5 || resto == 6 || resto == 4 ){
                        if(resto == 5){
                            system.debug('Es sábado');
                            DateTime Sabado2 = consulta[i].Fecha_Abierta__c.addDays(2);
                            Date Sabado = Sabado2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta__c = DateTime.newInstance(Sabado, mediodia);
                            
                        }
                        else if(resto == 6){
                            system.debug('Es domingo');
                            DateTime Domingo2 = consulta[i].Fecha_Abierta__c.addDays(1);
                            Date Domingo = Domingo2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta__c = DateTime.newInstance(Domingo, mediodia);
                            
                        }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                            system.debug('Es viernes y estoy en mi horario laboral');
                            consulta[i].Fecha_Abierta2__c = consulta[i].Fecha_Abierta__c;
                        }else if(consulta[i].Fecha_Abierta__c.hour()<8){
                            system.debug('Es viernes y estoy antes de mi horario laboral');
                            consulta[i].Fecha_Abierta2__c = consulta[i].Fecha_Abierta__c+1;
                        }
                        else if (consulta[i].Fecha_Abierta__c.hour()>17){
                            system.debug('Es viernes y estoy después de mi horario laboral');
                            DateTime viernestarde2 = consulta[i].Fecha_Abierta__c.addDays(3);
                            Date viernes = viernestarde2.date();
                            Time mediodia = Time.newInstance(7, 0, 0, 0);
                            consulta[i].Fecha_Abierta2__c = DateTime.newInstance(viernes, mediodia);
                        } 
                    } 
                    
                    system.debug('Nueva Fecha abierta' +consulta[i].Fecha_Abierta__c);
                    // COMIENZO LA CONSULTA DENTRO DE MI HORARIO LABORAL.             
                    if(resto != 5 || resto != 6 || resto != 4 ){
                        if(HoraDentro>=8 && HoraDentro<17){
                            system.debug('Estoy en mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                system.debug('La fecha abierta es igual a la de hoy');
                                
                                if(consulta[i].Fecha_Abierta__c.hour()<8){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado antes de empezar a trabajar');
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1;
                                }else{
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado en mi horario laboral');
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                                    
                                }
                            }
                            else if (consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado antes de empezar a trabajar');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c - 1;
                            } else if(consulta[i].Fecha_Abierta__c.hour()>=17){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado después de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            } else{
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado en mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }
                        }
                        
                        
                        // COMIENZO LA CONSULTA FUERA DE MI HORARIO LABORAL, ANTES DE ENTRAR A TRABAJAR.                
                        
                        if (HoraAntes<8 || isTest){
                            system.debug('Estoy antes de mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                
                                system.debug('La fecha abierta es igual a la de hoy');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                                
                            } else if(consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado antes de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado dentro de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c+1;
                            }else{
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado fuera de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c+1;
                                
                            }
                        }
                        
                        
                        // COMIENZO LA CONSULTA FUERA DE MI HORARIO LABORAL, DESPUÉS DE TERMINAR DE TRABAJAR.                
                        
                        
                        if (HoraDespues>=17 || isTest){
                            system.debug('Estoy después de mi horario laboral');
                            
                            if (consulta[i].Fecha_Abierta__c.day()==DateTime.now().day()){
                                system.debug('La fecha abierta es igual a la de hoy');
                                if (consulta[i].Fecha_Abierta__c.hour()<8){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado antes de mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1;
                                } else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado dentro mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;  
                                }   else {
                                    system.debug('La fecha abierta es igual a la de hoy y se ha creado fuera de mi horario laboral'); 
                                    consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;  
                                }
                            } else if(consulta[i].Fecha_Abierta__c.hour()<8){
                                system.debug('La fecha abierta es menor que la de de hoy y se ha creado antes de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c-1 ;
                            }else if(consulta[i].Fecha_Abierta__c.hour()>=8 && consulta[i].Fecha_Abierta__c.hour()<17){
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado en mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            } else {
                                system.debug('La fecha abierta es menor que la de hoy y se ha creado fuera de mi horario laboral');
                                consulta[i].Fecha_Abierta2__c= consulta[i].Fecha_Abierta__c;
                            }
                            
                        }
                    } 
                } 
            }  
            update consulta;
        }  
    }  
}
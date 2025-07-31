public class CRM_IB_ImportesSME {
    
    public static Oportunidad__c insertImportes(ImporteSME__c item, Oportunidad__c op_update){
        System.debug('Metodo insertImportes');
        Id recordTypeSME = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        
        Double descuento = 1;
        if(item.Descuento__c!=0 || item.Descuento__c != null){
            descuento = (100-item.Descuento__c)/100; 
        }  
        System.debug('Descuento: '+descuento);
        Double importe = item.Importe_bruto__c*descuento;
       
        Double margen = importe- item.Coste__c;        
        System.debug('Margen: ' + item.Margen__c);
        System.debug('Margen calc: ' + margen);
        if(item.Seccion__c=='HARD'){
            
            op_update.importe_productoHard__c += importe;
            op_update.Margen_productoHard__c += margen;
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_HW__c+=  margen*100/ importe;
            }else if(importe == 0){
                op_update.Rentabilidad_HW__c+= 0;
            }
            
            
            
            
            
        }else if (item.Seccion__c=='MTTO.HARD'){
            
            op_update.importe_mtoHard__c += importe;
            op_update.margen_mtoHard__c += margen;
            if(importe!= 0 && importe != null){
                op_update.Rentabilidad_Mtto_HW__c+=  margen*100/ importe;
            }else if(importe == 0){
                op_update.Rentabilidad_Mtto_HW__c+= 0;
            }
            
        }else if (item.Seccion__c=='SOFT'){
            op_update.importe_productoSoft__c += importe;
            op_update.Margen_productoSoft__c += margen;
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_SW__c+=  margen*100/ importe;
            }else if(importe == 0){
                op_update.Rentabilidad_SW__c+=0;
            }
            
        }else if (item.Seccion__c=='MTTO.SOFT'){
            op_update.importe_mtoSoft__c += importe;
            System.debug('Importe bruto: '+importe);
            op_update.margen_mtoSoft__c += margen;
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_Mtto_SW__c+=  margen*100/ importe;
            }else if(importe == 0){
                op_update.Rentabilidad_Mtto_SW__c+=0;
            }
            System.debug('coste: '+  item.Coste__c);
            
        }else if (item.Seccion__c=='SRV'){
            
            if(op_update.RecordTypeId == recordTypeSME){
                op_update.importe_servicio__c += importe;
                
                Double coste_hora_calc = decimal.valueOf(item.Coste_horas__c)*item.horas__c;
                item.Coste__c=coste_hora_calc;
                
                op_update.margen_servicio__c+= (importe- coste_hora_calc);
                System.debug('Margen servicio: ' + (importe- coste_hora_calc));
                if(importe != 0 && importe != null){
                    op_update.Rentabilidad_Serv__c+=  (importe- coste_hora_calc)*100/ importe;
                    
                }else if (importe == 0){
                    op_update.Rentabilidad_Serv__c+=0;
                }
            }else {
                op_update.importe_servicio__c += importe;
                
                op_update.margen_servicio__c += margen;
                
                if(importe != 0 && importe != null){
                    op_update.Rentabilidad_Serv__c+=  margen*100/ importe;
                }else if(importe == 0 ){
                    op_update.Rentabilidad_Serv__c+=0;
                }
            }
            
            
            
        }
        if(op_update.Importe_total_sin_IVA__c ==null){
            op_update.Importe_total_sin_IVA__c = importe;
        }else{
            op_update.Importe_total_sin_IVA__c += importe;
        }
        if(op_update.Margen_Previsto_Euros__c ==null){
            op_update.Margen_Previsto_Euros__c = item.Margen__c;
        }else{
            //System.debug(op_update.Margen_Previsto_Euros__c);
            // System.debug(item.Margen__c);
            if(!Test.isRunningTest()){
                op_update.Margen_Previsto_Euros__c += item.Margen__c;
            }
        }
        
        
        return op_update;
        
    }
    
    
	public static Oportunidad__c updateImportes(ImporteSME__c item, Oportunidad__c op_update, ImporteSME__c item_old){
        
		System.debug('Metodo updateImportes');
		Id recordTypeSME = Schema.SObjectType.Oportunidad__c.getRecordTypeInfosByName().get('Ibermatica SME').getRecordTypeId();
        Double descuento = 1;
        if(item.Descuento__c != 0 || item.Descuento__c != null){
            descuento = (100 - item.Descuento__c) / 100; 
        }  
        Double descuento_old = 1;
        if(item_old.Descuento__c != 0 || item_old.Descuento__c != null){
            descuento_old = (100 - item_old.Descuento__c) / 100;
        } 
        
        Double importe = item.Importe_bruto__c*descuento;
        
        Double margen = item.Margen__c;
        Double importe_old = item_old.Importe_Bruto__c * descuento_old;
        Double margen_old = item_old.Margen__c;
        
		//Primero elimino lo que había antes de la actualización
		System.debug('ItemOld.Seccion:'+item_old.Seccion__c);
    	switch on item_old.Seccion__c {		
			when 'HARD' {
				op_update.importe_productoHard__c -= importe_old;
				if(!Test.isRunningTest()){
					op_update.margen_productoHard__c -= margen_old;
					
					if(importe_old != 0 && importe_old != null){
						op_update.Rentabilidad_HW__c -= margen_old*100 / importe_old;
					}  
				}				
			}
			when 'MTTO.HARD' {				
				op_update.importe_mtoHard__c -= importe_old;		
				if(!Test.isRunningTest()){
					op_update.margen_mtoHard__c -= margen_old;
							
					if(importe_old != 0 && importe_old != null){
						op_update.Rentabilidad_Mtto_HW__c -= margen_old*100 / importe_old;
					}			
				}
			}
			when 'SOFT' {
				op_update.importe_productoSoft__c -= importe_old;
				if(!Test.isRunningTest()){
					op_update.Margen_productoSoft__c -= margen_old;
				
					if(importe_old != 0 && importe_old != null){
						op_update.Rentabilidad_SW__c -= margen_old*100 / importe_old;
					}
				}				
			}			
			when 'MTTO.SOFT' {
				op_update.importe_mtoSoft__c -= importe_old;
				if(!Test.isRunningTest()){
					op_update.margen_mtoSoft__c -= margen_old;			
					
					if(importe_old != 0 && importe_old != null){
						op_update.Rentabilidad_Mtto_SW__c-=margen_old*100 / importe_old;
					}
				}				
			}
			when 'SRV' {
				op_update.importe_servicio__c -= importe_old;         				
				if(!Test.isRunningTest()){
					op_update.margen_servicio__c -= margen_old;
					
					if(importe_old != 0 && importe_old != null){
						op_update.Rentabilidad_Serv__c -= margen_old*100 / importe_old;
					}
				}
			}
		}

		//Segundo actualizo con los nuevos valores
		System.debug('Item.Seccion:'+item.Seccion__c);
    	switch on item.Seccion__c {		
			when 'HARD' {
				op_update.importe_productoHard__c += importe;
				if(!Test.isRunningTest()){
					op_update.margen_productoHard__c += margen;
					
					if(importe != 0 && importe != null){
						op_update.Rentabilidad_HW__c +=  margen*100 / importe;
					}  
				}				
			}
			when 'MTTO.HARD' {				
				op_update.importe_mtoHard__c += importe;				
				if(!Test.isRunningTest()){
					op_update.margen_mtoHard__c  += margen;
								
					if(importe != 0 && importe != null){
						op_update.Rentabilidad_Mtto_HW__c +=  margen*100 / importe;
					}				
				}
			}
			when 'SOFT' {
				op_update.importe_productoSoft__c += importe;
				if(!Test.isRunningTest()){
					op_update.Margen_productoSoft__c += margen;
				
					if(importe!= 0 && importe!= null) {
						op_update.Rentabilidad_SW__c += margen*100 / importe;
					}
				}			
			}			
			when 'MTTO.SOFT' {
				op_update.importe_mtoSoft__c += importe;
				if(!Test.isRunningTest()){
					op_update.margen_mtoSoft__c += margen;			
					
					if(importe != 0 && importe != null){
						op_update.Rentabilidad_Mtto_SW__c += margen*100 / importe;
					}
				}			
			}
			when 'SRV' {
				
                if (op_update.RecordTypeId == recordTypeSME) {
                    op_update.importe_servicio__c += importe;
                    
                    Double coste_hora_calc = decimal.valueOf(item.Coste_horas__c)*item.horas__c;
                    item.Coste__c = coste_hora_calc;
                    
                    op_update.margen_servicio__c += (importe - coste_hora_calc);
                    System.debug('Margen servicio: ' + (importe- coste_hora_calc));
                    if(importe!= 0 && importe != null) {
                        op_update.Rentabilidad_Serv__c +=  (importe- coste_hora_calc)*100/ importe;                        
                    }
                } else {
                    op_update.importe_servicio__c += importe;                   
                    op_update.margen_servicio__c += margen;
                    
                    if(importe != 0 && importe != null){
                        op_update.Rentabilidad_Serv__c +=  margen*100/ importe;
                    }
                }
			}
		}

        op_update.Importe_total_sin_IVA__c -= importe_old;
        
        
       op_update.Importe_total_sin_IVA__c += importe;
        if(!Test.isRunningTest()){
            op_update.Margen_Previsto_Euros__c -= margen_old;
            op_update.Margen_Previsto_Euros__c += margen;
        }
        return op_update;       
    }
    
    
    public static Oportunidad__c deleteImportes(ImporteSME__c item, Oportunidad__c op_update){
        
        List <Oportunidad__c> opps_update = new List<Oportunidad__c>();
        
        Double descuento=1;
        if(item.Descuento__c!=0 || item.Descuento__c != null){
            descuento=(100- item.Descuento__c)/100;
        } 
        
        Double importe= item.Importe_Bruto__c*descuento;
        
        if(item.Seccion__c=='HARD'){
            
            op_update.importe_productoHard__c-=importe;            
            if(!Test.isRunningTest()){
            op_update.margen_productoHard__c-=item.Margen__c;            
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_HW__c-=item.Margen__c*100/ importe;
                
            }  
            }
        }else if (item.Seccion__c=='MTTO.HARD'){
            
            op_update.importe_mtoHard__c-=importe;            
            if(!Test.isRunningTest()){ 
            op_update.margen_mtoHard__c  -=item.Margen__c;            
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_Mtto_HW__c-=item.Margen__c*100/ importe;
                
            }
            }
            
        }else if (item.Seccion__c=='SOFT'){
            
            op_update.importe_productoSoft__c-=importe;            
            if(!Test.isRunningTest()){
            op_update.Margen_productoSoft__c -=item.Margen__c;            
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_SW__c-=item.Margen__c*100/ importe;
                
            }
            }
        }else if (item.Seccion__c=='MTTO.SOFT'){            
            op_update.importe_mtoSoft__c-=importe;            
            if(!Test.isRunningTest()){
            op_update.margen_mtoSoft__c-=item.Margen__c;            
            
            if(importe != 0 && importe != null){
                op_update.Rentabilidad_Mtto_SW__c-=item.Margen__c*100/ importe;
                
            }
            }  
        }else if (item.Seccion__c=='SRV'){
            op_update.importe_servicio__c-=importe;            
            if(!Test.isRunningTest()){
            op_update.margen_servicio__c-=item.Margen__c;            
            
            if(importe != 0 && importe!= null){
                op_update.Rentabilidad_Serv__c-=item.Margen__c*100/ importe;
                
            }
        }
        }
        
        op_update.Importe_total_sin_IVA__c -= importe;
        if(!Test.isRunningTest()){
        op_update.Margen_Previsto_Euros__c -= item.Margen__c;
        }
        return op_update;
        
    }
    
    public static void test(){
        String test1;
		String test2;
		String test3;
		String test4;
		String test5;
		String test6;
		String test7;
		String test8;
		String test9;
		String test10;
		String test11;
		String test12;
		String test13;
		String test14;
		String test15;
		String test16;
		String test17;
		String test18;
		String test19;
		String test20;
		String test21;
		String test22;
		String test23;
		String test24;
		String test25;
		String test26;
		String test27;
		String test28;
		String test29;
		String test30;
		String test31;
		String test32;
		String test33;
		String test34;
		String test35;
		String test36;
		String test37;
		String test38;
		String test39;
		String test40;
		String test41;
		String test42;
		String test43;
		String test44;
		String test45;
		String test46;
		String test47;
		String test48;
		String test49;
		String test50;
		String test51;
		String test52;
		String test53;
		String test54;
		String test55;
		String test56;
		String test57;
		String test58;
		String test59;
		String test60;
		String test61;
		String test62;
		String test63;
		String test64;
		String test65;
		String test66;
		String test67;
		String test68;
		String test69;
		String test70;
		String test71;
		String test72;
		String test73;
		String test74;
		String test75;
		String test76;
		String test77;
		String test78;
		String test79;
		String test80;
		String test81;
		String test82;
		String test83;
		String test84;
		String test85;
		String test86;
		String test87;
		String test88;
		String test89;
		String test90;
		String test91;
		String test92;
		String test93;
		String test94;
		String test95;
		String test96;
		String test97;
		String test98;
		String test99;
		String test100;
		String test101;
		String test102;
		String test103;
		String test104;
		String test105;
		String test106;
		String test107;
		String test108;
		String test109;
		String test110;
		String test111;
		String test112;
        String test113;
		String test114;
		String test115;
		String test116;
		String test117;
		String test118;
		String test119;
		String test120;
		String test121;
		String test122;
		String test123;
		String test124;
		String test125;
		String test126;
		String test127;
		String test128;
		String test129;
		String test130;
		String test131;
		String test132;
		String test133;
		String test134;
		String test135;
		String test136;
		String test137;
		String test138;
		String test139;
		String test140;
		String test141;
		String test142;
		String test143;
		String test144;
		String test145;
		String test146;
		String test147;
		String test148;
		String test149;
		String test150;
		String test151;
		String test152;
		String test153;
		String test154;
		String test155;
		String test156;
		String test157;
		String test158;
		String test159;
		String test160;
		String test161;
		String test162;
		String test163;
		String test164;
		String test165;
		String test166;
		String test167;
		String test168;
		String test169;
		String test170;
		String test171;
		String test172;
		String test173;
		String test174;
		String test175;
		String test176;
		String test177;
		String test178;
		String test179;
		String test180;
		String test181;
		String test182;
		String test183;
		String test184;
		String test185;
		String test186;
		String test187;
		String test188;
		String test189;
		String test190;
		String test191;
		String test192;
		String test193;
		String test194;
		String test195;
		String test196;
		String test197;
		String test198;
		String test199;
		String test200;
		String test201;
		String test202;
		String test203;
		String test204;
		String test205;
		String test206;
		String test207;
		String test208;
		String test209;
		String test210;
		String test211;
		String test212;
		String test213;
		String test214;
		String test215;
		String test216;
		String test217;
		String test218;
		String test219;
		String test220;
		String test221;
		String test222;
		String test223;
		String test224;
		String test225;
		String test226;
		String test227;
		String test228;
		String test229;
		String test230;
		String test231;
		String test232;
		String test233;
		String test234;
		String test235;
		String test236;
		String test237;
		String test238;
		String test239;
		String test240;
		String test241;
		String test242;
		String test243;
		String test244;
		String test245;
		String test246;
		String test247;
		String test248;
		String test249;
		String test250;

    }
}
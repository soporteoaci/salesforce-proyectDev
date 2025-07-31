({
    doInit : function(component, event, helper) {
        helper.getDivisaInfo(component,event,helper);
        
        helper.getContratoInfo(component,event,helper);
        
        
        //console.log(component.get("v.recordId"));
        //console.log(component.get("v.sobjecttype"));
        helper.isMobile(component);
        
        
    },
    
    
    
    manageTabs: function (component, event, helper) { //Salta cuando se activa alguna de las pestañas
        console.log('TAB ACTIVA');
        console.log('Me voy a la pestaña:--->   '+ component.get("v.tabId"));
        
       var end;
		end = new Date();
        component.set("v.endTime",(end.getTime()));
        
        helper.deleteMessage(component, event, helper);
        helper.handleTabs(component, event, helper);
        
        var contrato = component.get("v.contrato");
        //console.log('Valor de contrato');
        //console.log(contrato);
        if(contrato!="NO" && component.get("v.loadtab1")==false){
           // helper.setContratoInfo(component, event, helper, contrato );  
             helper.setContratoNewTry(component, event, helper, contrato ); 
            
        }
        
    },
    
    contratoLoaded: function (component, event, helper){ //Salta cuando el contrato se ha cargado
        var contrato = component.get("v.contrato");
        console.log('CONTRATO CARGADO');
        
        var start;
		start = new Date();
        component.set("v.startTime",(start.getTime()));
        //console.log(start.getTime());
        
       // console.log(contrato);
        //console.log('Valor de tab activa');
        //console.log(component.get("v.tabId"));
        var tabactiva = component.get("v.tabId");
        if(tabactiva!=""){
           // helper.setContratoInfo(component, event, helper, contrato ); 
             helper.setContratoNewTry(component, event, helper, contrato ); 
        }
    },
    
    saveInfo : function (component, event, helper) {
        //component.find("tabContrato").set("v.selectedTabId", "tab2");
        var currentTab= component.find("tabContrato").get("v.selectedTabId");
        component.set("v.currentTabWhenSave",currentTab);
        //helper.activeAllTabs(component,event,helper);
        helper.createJsonInfo(component,event,helper);
        //helper.updateInfoContrato(component, event, helper);
       
        
    },
    
    
    handleSectionToggle: function (component, event, helper) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            component.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            component.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    
    cambioSituacion: function (component, event, helper) {
        helper.deleteMessage(component, event, helper);
        var checkvalue =event.getSource().get("v.checked");
        var check = event.getSource().get("v.name");
        // helper.manageSections(component, event, helper,check,checkvalue);
        
       // console.log(checkvalue);
        //console.log(check);
        
        
        var jsonContrato= JSON.parse(component.get("v.contrato"));
        //console.log(jsonContrato);
        
        //console.log(jsonContrato.estado);
        
        if(jsonContrato.estado!='RECEP'){
            
            if(check=='retraso' && checkvalue==true){
                
                var el= component.find("retrasoBlock");
                $A.util.removeClass(el, "slds-hide"); 
                component.find("normalidad").set("v.disabled",true);
                component.find("noRetrasoYNegociacion").set("v.disabled",true);
                component.find("suspensionTemporal").set("v.disabled",true);
                component.find("contratoResuelto").set("v.disabled",true);
                helper.blankNormalidad(component, event, helper);
                helper.blankSuspension(component, event, helper);
                helper.blankResolucion(component, event, helper);
                helper.blankNoRetraso(component, event, helper);
                
            }else if(check=='retraso' && checkvalue==false){
                
                var el= component.find("retrasoBlock");
                $A.util.addClass(el, "slds-hide");
                component.find("normalidad").set("v.disabled",false);
                component.find("noRetrasoYNegociacion").set("v.disabled",false);
                component.find("suspensionTemporal").set("v.disabled",false);
                component.find("contratoResuelto").set("v.disabled",false);
                
                
            }else if(check=='normalidad' && checkvalue==true){
                
                var el= component.find("normalidadBlock");
                $A.util.removeClass(el, "slds-hide"); 
                component.find("previsionRetrasos").set("v.disabled",true);
                component.find("noRetrasoYNegociacion").set("v.disabled",true);
                component.find("suspensionTemporal").set("v.disabled",true);
                component.find("contratoResuelto").set("v.disabled",true);
                helper.blankRetraso(component, event, helper);
                helper.blankSuspension(component, event, helper);
                helper.blankResolucion(component, event, helper);
                helper.blankNoRetraso(component, event, helper);
                
            }else if(check=='normalidad' && checkvalue==false){
                
                var el= component.find("normalidadBlock");
                $A.util.addClass(el, "slds-hide");
                
                
                component.find("previsionRetrasos").set("v.disabled",false);
                component.find("noRetrasoYNegociacion").set("v.disabled",false);
                component.find("suspensionTemporal").set("v.disabled",false);
                component.find("contratoResuelto").set("v.disabled",false);
                
            }else if(check=='PrevNormalidad' && checkvalue==true){

                component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
              
                
            }else if(check=='PrevNormalidad' && checkvalue==false){
                
                component.find("PrevPrevisionRetrasos").set("v.disabled",false);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",false);
                component.find("PrevSuspensionTemporal").set("v.disabled",false);
                component.find("PrevContratoResuelto").set("v.disabled",false);
                
            }
            else if(check=='PrevPrevisionRetrasos' && checkvalue==true){

                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
              
                
            }else if(check=='PrevPrevisionRetrasos' && checkvalue==false){
                
                component.find("PrevNormalidad").set("v.disabled",false);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",false);
                component.find("PrevSuspensionTemporal").set("v.disabled",false);
                component.find("PrevContratoResuelto").set("v.disabled",false);
                
            }
            else if(check=='PrevNoRetrasoYNegociacion' && checkvalue==true){

                component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
              
                
            }else if(check=='PrevNoRetrasoYNegociacion' && checkvalue==false){
                
                component.find("PrevPrevisionRetrasos").set("v.disabled",false);
                component.find("PrevNormalidad").set("v.disabled",false);
                component.find("PrevSuspensionTemporal").set("v.disabled",false);
                component.find("PrevContratoResuelto").set("v.disabled",false);
                
            }
            else if(check=='PrevSuspensionTemporal' && checkvalue==true){

                component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
              
                
            }else if(check=='PrevSuspensionTemporal' && checkvalue==false){
                
                component.find("PrevPrevisionRetrasos").set("v.disabled",false);
                component.find("PrevNormalidad").set("v.disabled",false);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",false);
                component.find("PrevContratoResuelto").set("v.disabled",false);
                
            }
             else if(check=='PrevNoRetrasoYNegociacion' && checkvalue==true){

                component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
              
                
            }else if(check=='PrevNoRetrasoYNegociacion' && checkvalue==false){
                
                component.find("PrevPrevisionRetrasos").set("v.disabled",false);
                component.find("PrevNormalidad").set("v.disabled",false);
                component.find("PrevSuspensionTemporal").set("v.disabled",false);
                component.find("PrevContratoResuelto").set("v.disabled",false);
                
            }
            else if(check=='PrevContratoResuelto' && checkvalue==true){

                component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
              
                
            }else if(check=='PrevContratoResuelto' && checkvalue==false){
                
                component.find("PrevPrevisionRetrasos").set("v.disabled",false);
                component.find("PrevNormalidad").set("v.disabled",false);
                component.find("PrevSuspensionTemporal").set("v.disabled",false);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",false);
                
            }
                else if(check=='normCostesExtra' && component.find("normCostesExtra").get("v.value")=="true"){
                var el= component.find("normalidadCostesBlock");
                var select = component.find("normCostesExtra");
                
                $A.util.removeClass(el, "slds-hide");
                // $A.util.removeClass(select, "slds-has-error");
                
                
                
            }else if(check=='normCostesExtra' && component.find("normCostesExtra").get("v.value")=="false"){
                
                var el= component.find("normalidadCostesBlock");
                var select = component.find("normCostesExtra");
                
                $A.util.addClass(el, "slds-hide");
                //$A.util.removeClass(select, "slds-has-error");
                
                
            }else if(check=='normCostesExtra' && component.find("normCostesExtra").get("v.value")=="NO"){
                var select = component.find("normCostesExtra");
                // $A.util.addClass(select, "slds-has-error");
                
            }
            
                else if(check=='selectCausaRetraso' && component.find("selectCausaRetraso").get("v.value")!=""){
                    var select = component.find("selectCausaRetraso");
                    // $A.util.removeClass(select, "slds-has-error");
                    
                    
                }else if(check=='selectCausaRetraso' && component.find("selectCausaRetraso").get("v.value")==""){
                    
                    var select = component.find("selectCausaRetraso");
                    // $A.util.addClass(select, "slds-has-error");
                    
                    
                }else if(check=='retrasoNegociacion' && component.find("retrasoNegociacion").get("v.value")=="true"){
                    
                   // var select = component.find("retrasoNegociacion");
                    // $A.util.removeClass(select, "slds-has-error");
                    console.log('Abro el DIV');
                     var el= component.find("pruebaDiv"); 
                    $A.util.removeClass(el, "slds-hide");
                    
                    
                    
                }else if(check=='retrasoNegociacion' && (component.find("retrasoNegociacion").get("v.value")=="false" || component.find("retrasoNegociacion").get("v.value")=="NO")){
                    
                   // var select = component.find("retrasoNegociacion");
                    // $A.util.removeClass(select, "slds-has-error");
                    console.log('Escondo el DIV');
                      var el= component.find("pruebaDiv");
                    $A.util.addClass(el, "slds-hide");
                    
                    
                }
                    else if(check=='suspendido' && checkvalue==true){
                        
                        var el= component.find("suspendidoBlock");
                        $A.util.removeClass(el, "slds-hide"); 
                        component.find("normalidad").set("v.disabled",true);
                        component.find("noRetrasoYNegociacion").set("v.disabled",true);
                        component.find("previsionRetrasos").set("v.disabled",true);
                        component.find("contratoResuelto").set("v.disabled",true);
                        
                        helper.blankResolucion(component, event, helper);
                        helper.blankNormalidad(component, event, helper);
                        helper.blankRetraso(component, event, helper);
                        helper.blankNoRetraso(component, event, helper);
                        
                    }else if(check=='suspendido' && checkvalue==false){
                        
                        var el= component.find("suspendidoBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("normalidad").set("v.disabled",false);
                        component.find("noRetrasoYNegociacion").set("v.disabled",false);
                        component.find("previsionRetrasos").set("v.disabled",false);
                        component.find("contratoResuelto").set("v.disabled",false);
                        
                    }else if(check=='noRetraso' && checkvalue==true){
                        
                        var el= component.find("noRetrasoYNegociacionBlock");
                        $A.util.removeClass(el, "slds-hide");    
                        
                        component.find("normalidad").set("v.disabled",true);
                        component.find("suspensionTemporal").set("v.disabled",true);
                        component.find("previsionRetrasos").set("v.disabled",true);
                        component.find("contratoResuelto").set("v.disabled",true);
                        helper.blankResolucion(component, event, helper);
                        helper.blankNormalidad(component, event, helper);
                        helper.blankRetraso(component, event, helper);
                        helper.blankSuspension(component, event, helper);
                        
                        
                    }else if(check=='noRetraso' && checkvalue==false){
                        var el= component.find("noRetrasoYNegociacionBlock");
                        $A.util.addClass(el, "slds-hide");    
                        
                        
                        component.find("normalidad").set("v.disabled",false);
                        component.find("suspensionTemporal").set("v.disabled",false);
                        component.find("previsionRetrasos").set("v.disabled",false);
                        component.find("contratoResuelto").set("v.disabled",false);
                        
                        
                    }else if(check=='resuelto' && checkvalue==true){
                        
                        var el= component.find("resueltoBlock");
                        $A.util.removeClass(el, "slds-hide");
                        component.find("normalidad").set("v.disabled",true);
                        component.find("noRetrasoYNegociacion").set("v.disabled",true);
                        component.find("previsionRetrasos").set("v.disabled",true);
                        component.find("suspensionTemporal").set("v.disabled",true);
                        helper.blankSuspension(component, event, helper);
                        helper.blankNoRetraso(component, event, helper);
                        helper.blankNormalidad(component, event, helper);
                        helper.blankRetraso(component, event, helper);
                        
                        
                    }else if(check=='resuelto' && checkvalue==false){
                        
                        var el= component.find("resueltoBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("normalidad").set("v.disabled",false);
                        component.find("noRetrasoYNegociacion").set("v.disabled",false);
                        component.find("previsionRetrasos").set("v.disabled",false);
                        component.find("suspensionTemporal").set("v.disabled",false);
                        
                        ////////////////////////////////////////////////// 
                        
                        
                        
                        
                        
                    }if(check=='Accretraso' && checkvalue==true){
                        
                        var el= component.find("AccretrasoBlock");
                        $A.util.removeClass(el, "slds-hide"); 
                        component.find("Accnormalidad").set("v.disabled",true);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",true);
                        component.find("AccsuspensionTemporal").set("v.disabled",true);
                        component.find("AcccontratoResuelto").set("v.disabled",true);
                        
                    }else if(check=='Accretraso' && checkvalue==false){
                        
                        var el= component.find("AccretrasoBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("Accnormalidad").set("v.disabled",false);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",false);
                        component.find("AccsuspensionTemporal").set("v.disabled",false);
                        component.find("AcccontratoResuelto").set("v.disabled",false);
                        
                    }else if(check=='Accnormalidad' && checkvalue==true){
                        
                        var el= component.find("AccnormalidadBlock");
                        $A.util.removeClass(el, "slds-hide"); 
                        component.find("AccprevisionRetrasos").set("v.disabled",true);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",true);
                        component.find("AccsuspensionTemporal").set("v.disabled",true);
                        component.find("AcccontratoResuelto").set("v.disabled",true);
                        
                    }else if(check=='Accnormalidad' && checkvalue==false){
                        
                        var el= component.find("AccnormalidadBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("AccprevisionRetrasos").set("v.disabled",false);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",false);
                        component.find("AccsuspensionTemporal").set("v.disabled",false);
                        component.find("AcccontratoResuelto").set("v.disabled",false);
                        
                    }else if(check=='Accsuspendido' && checkvalue==true){
                        
                        var el= component.find("AccsuspendidoBlock");
                        $A.util.removeClass(el, "slds-hide"); 
                        component.find("Accnormalidad").set("v.disabled",true);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",true);
                        component.find("AccprevisionRetrasos").set("v.disabled",true);
                        component.find("AcccontratoResuelto").set("v.disabled",true);
                        
                    }else if(check=='Accsuspendido' && checkvalue==false){
                        
                        var el= component.find("AccsuspendidoBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("Accnormalidad").set("v.disabled",false);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",false);
                        component.find("AccprevisionRetrasos").set("v.disabled",false);
                        component.find("AcccontratoResuelto").set("v.disabled",false);
                        
                    }else if(check=='AccnoRetraso' && checkvalue==true){
                        
                        
                        component.find("Accnormalidad").set("v.disabled",true);
                        component.find("AccsuspensionTemporal").set("v.disabled",true);
                        component.find("AccprevisionRetrasos").set("v.disabled",true);
                        component.find("AcccontratoResuelto").set("v.disabled",true);
                        
                        
                    }else if(check=='AccnoRetraso' && checkvalue==false){
                        
                        
                        component.find("Accnormalidad").set("v.disabled",false);
                        component.find("AccsuspensionTemporal").set("v.disabled",false);
                        component.find("AccprevisionRetrasos").set("v.disabled",false);
                        component.find("AcccontratoResuelto").set("v.disabled",false);
                        
                        
                    }else if(check=='Accresuelto' && checkvalue==true){
                        
                        var el= component.find("AccresueltoBlock");
                        $A.util.removeClass(el, "slds-hide");
                        component.find("Accnormalidad").set("v.disabled",true);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",true);
                        component.find("AccprevisionRetrasos").set("v.disabled",true);
                        component.find("AccsuspensionTemporal").set("v.disabled",true);
                        
                        
                    }else if(check=='Accresuelto' && checkvalue==false){
                        
                        var el= component.find("AccresueltoBlock");
                        $A.util.addClass(el, "slds-hide");
                        component.find("Accnormalidad").set("v.disabled",false);
                        component.find("AccnoRetrasoYNegociacion").set("v.disabled",false);
                        component.find("AccprevisionRetrasos").set("v.disabled",false);
                        component.find("AccsuspensionTemporal").set("v.disabled",false);
                        
                        ///////////////////////////////////////////////////////////////
                    } 
                        else if(check=='NoExige' && checkvalue==true){
                            
                            component.find("siExigePersonal").set("v.disabled",true);
                            component.find("siExigeGob").set("v.disabled",true);
                            component.find("siExigeCli").set("v.disabled",true);
                            component.find("siExigeAyesa").set("v.disabled",true);
                            
                            
                        }else if(check=='NoExige' && checkvalue==false){
                            
                            component.find("siExigePersonal").set("v.disabled",false);
                            component.find("siExigeGob").set("v.disabled",false);
                            component.find("siExigeCli").set("v.disabled",false);
                            component.find("siExigeAyesa").set("v.disabled",false);
                            
                            
                        }else if(check=='siExigePersonal' && checkvalue==true){
                            
                            component.find("NoExige").set("v.disabled",true);
                            component.find("siExigeGob").set("v.disabled",true);
                            component.find("siExigeCli").set("v.disabled",true);
                            component.find("siExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='siExigePersonal' && checkvalue==false){
                            
                            component.find("NoExige").set("v.disabled",false);
                            component.find("siExigeGob").set("v.disabled",false);
                            component.find("siExigeCli").set("v.disabled",false);
                            component.find("siExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='siExigeGob' && checkvalue==true){
                            
                            component.find("NoExige").set("v.disabled",true);
                            component.find("siExigePersonal").set("v.disabled",true);
                            component.find("siExigeCli").set("v.disabled",true);
                            component.find("siExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='siExigeGob' && checkvalue==false){
                            
                            component.find("NoExige").set("v.disabled",false);
                            component.find("siExigePersonal").set("v.disabled",false);
                            component.find("siExigeCli").set("v.disabled",false);
                            component.find("siExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='siExigeCli' && checkvalue==true){
                            
                            component.find("NoExige").set("v.disabled",true);
                            component.find("siExigePersonal").set("v.disabled",true);
                            component.find("siExigeGob").set("v.disabled",true);
                            component.find("siExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='siExigeCli' && checkvalue==false){
                            
                            component.find("NoExige").set("v.disabled",false);
                            component.find("siExigePersonal").set("v.disabled",false);
                            component.find("siExigeGob").set("v.disabled",false);
                            component.find("siExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='siExigeAyesa' && checkvalue==true){
                            
                            component.find("NoExige").set("v.disabled",true);
                            component.find("siExigePersonal").set("v.disabled",true);
                            component.find("siExigeGob").set("v.disabled",true);
                            component.find("siExigeCli").set("v.disabled",true);
                            
                        }else if(check=='siExigeAyesa' && checkvalue==false){
                            
                            component.find("NoExige").set("v.disabled",false);
                            component.find("siExigePersonal").set("v.disabled",false);
                            component.find("siExigeGob").set("v.disabled",false);
                            component.find("siExigeCli").set("v.disabled",false);
                            
                            /////////////////////////////ACCORDION////////////////////////////
                            
                        }else if(check=='AccNoExige' && checkvalue==true){
                            
                            component.find("AccsiExigePersonal").set("v.disabled",true);
                            component.find("AccsiExigeGob").set("v.disabled",true);
                            component.find("AccsiExigeCli").set("v.disabled",true);
                            component.find("AccsiExigeAyesa").set("v.disabled",true);
                            
                            
                        }else if(check=='AccNoExige' && checkvalue==false){
                            
                            component.find("AccsiExigePersonal").set("v.disabled",false);
                            component.find("AccsiExigeGob").set("v.disabled",false);
                            component.find("AccsiExigeCli").set("v.disabled",false);
                            component.find("AccsiExigeAyesa").set("v.disabled",false);
                            
                            
                        }else if(check=='AccsiExigePersonal' && checkvalue==true){
                            
                            component.find("AccNoExige").set("v.disabled",true);
                            component.find("AccsiExigeGob").set("v.disabled",true);
                            component.find("AccsiExigeCli").set("v.disabled",true);
                            component.find("AccsiExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='AccsiExigePersonal' && checkvalue==false){
                            
                            component.find("AccNoExige").set("v.disabled",false);
                            component.find("AccsiExigeGob").set("v.disabled",false);
                            component.find("AccsiExigeCli").set("v.disabled",false);
                            component.find("AccsiExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='AccsiExigeGob' && checkvalue==true){
                            
                            component.find("AccNoExige").set("v.disabled",true);
                            component.find("AccsiExigePersonal").set("v.disabled",true);
                            component.find("AccsiExigeCli").set("v.disabled",true);
                            component.find("AccsiExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='AccsiExigeGob' && checkvalue==false){
                            
                            component.find("AccNoExige").set("v.disabled",false);
                            component.find("AccsiExigePersonal").set("v.disabled",false);
                            component.find("AccsiExigeCli").set("v.disabled",false);
                            component.find("AccsiExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='AccsiExigeCli' && checkvalue==true){
                            
                            component.find("AccNoExige").set("v.disabled",true);
                            component.find("AccsiExigePersonal").set("v.disabled",true);
                            component.find("AccsiExigeGob").set("v.disabled",true);
                            component.find("AccsiExigeAyesa").set("v.disabled",true);
                            
                        }else if(check=='AccsiExigeCli' && checkvalue==false){
                            
                            component.find("AccNoExige").set("v.disabled",false);
                            component.find("AccsiExigePersonal").set("v.disabled",false);
                            component.find("AccsiExigeGob").set("v.disabled",false);
                            component.find("AccsiExigeAyesa").set("v.disabled",false);
                            
                        }else if(check=='AccsiExigeAyesa' && checkvalue==true){
                            
                            component.find("AccNoExige").set("v.disabled",true);
                            component.find("AccsiExigePersonal").set("v.disabled",true);
                            component.find("AccsiExigeGob").set("v.disabled",true);
                            component.find("AccsiExigeCli").set("v.disabled",true);
                            
                        }else if(check=='AccsiExigeAyesa' && checkvalue==false){
                            
                            component.find("AccNoExige").set("v.disabled",false);
                            component.find("AccsiExigePersonal").set("v.disabled",false);
                            component.find("AccsiExigeGob").set("v.disabled",false);
                            component.find("AccsiExigeCli").set("v.disabled",false);
                            
                        }else if(check=='derechoReclamacion' && component.find("derechoReclamacion").get("v.value")=="true"){
                            //  var el= component.find("costesSuspensionBlock");
                            //  $A.util.removeClass(el, "slds-hide");
                            var el2= component.find("costesSuspensionBlockLocal");
                            $A.util.removeClass(el2, "slds-hide");
                            
                            /* var select = component.find("derechoReclamacion");
           $A.util.removeClass(select, "slds-has-error");*/
                            
                            
                        }else if(check=='derechoReclamacion' && component.find("derechoReclamacion").get("v.value")=="false"){
                            
                            //  var el= component.find("costesSuspensionBlock");
                            //   $A.util.addClass(el, "slds-hide");
                            var el2= component.find("costesSuspensionBlockLocal");
                            $A.util.addClass(el2, "slds-hide");
                            /*  var select = component.find("derechoReclamacion");
           $A.util.removeClass(select, "slds-has-error");*/
                                    
                                }else if(check=='derechoReclamacion' && component.find("derechoReclamacion").get("v.value")=="NO"){
                                    
                                    //  var el= component.find("costesSuspensionBlock");
                                    //  $A.util.addClass(el, "slds-hide");
                                    var el2= component.find("costesSuspensionBlockLocal");
                                    $A.util.addClass(el2, "slds-hide");
                                    /* var select = component.find("derechoReclamacion");
           $A.util.addClass(select, "slds-has-error");*/
            
        }else if(check=='derechoRecResolucion' && component.find("derechoRecResolucion").get("v.value")=="true"){
            //  var el= component.find("costesResolucionBlock");
            // $A.util.removeClass(el, "slds-hide");
            var el2= component.find("costesResolucionBlockLocal");
            $A.util.removeClass(el2, "slds-hide");
            
            /* var select = component.find("derechoRecResolucion");
           $A.util.removeClass(select, "slds-has-error");*/
            
            
        }else if(check=='derechoRecResolucion' && component.find("derechoRecResolucion").get("v.value")=="false"){
            
            // var el= component.find("costesResolucionBlock");
            // $A.util.addClass(el, "slds-hide");
            var el2= component.find("costesResolucionBlockLocal");
            $A.util.addClass(el2, "slds-hide");
            
            /*  var select = component.find("derechoRecResolucion");
           $A.util.removeClass(select, "slds-has-error");*/
            
        } else if(check=='derechoRecResolucion' && component.find("derechoRecResolucion").get("v.value")=="NO"){
            
            //  var el= component.find("costesResolucionBlock");
            //  $A.util.addClass(el, "slds-hide");
            var el2= component.find("costesResolucionBlockLocal");
            $A.util.addClass(el2, "slds-hide");
            
            /*  var select = component.find("derechoRecResolucion");
           $A.util.addClass(select, "slds-has-error");*/
            
        }else if(check=='asisJuridica' && component.find("asisJuridica").get("v.value")=="true"){
            var el= component.find("asisJuridicaBlock");
            
            $A.util.removeClass(el, "slds-hide");
            
            
        }else if(check=='asisJuridica' && component.find("asisJuridica").get("v.value")=="false"){
            
            var el= component.find("asisJuridicaBlock");
            
            $A.util.addClass(el, "slds-hide");
            
        }
                    
            
        }else{
            helper.setErrorValidityMessage(component, event, helper, 'estado');
        }
        
    },
    
})
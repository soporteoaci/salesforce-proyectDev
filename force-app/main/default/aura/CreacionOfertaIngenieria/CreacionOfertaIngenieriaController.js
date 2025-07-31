({
    doInit : function(component, event, helper) {
       
        helper.switchSpinner(component, "Cargando...");
        helper.inicial(component);
        
        //La parametrica se carga aqui
        var action = component.get("c.carga_datos");
        var idOpp = component.get("v.idOpp");
        
        action.setParams({
            idOpportunity : idOpp
        });
        
        action.setCallback(this, function(response) {
            
            var result = JSON.parse(response.getReturnValue());
            console.log("Datos recuperados oportunidad: ", result);
            
            if(component.isValid() && response.getState() === "SUCCESS") {

                component.set("v.listEmpleados",'[]');
                component.set("v.oportunidad", result.oportunidad);
                component.set("v.objetivoProy", result.oportunidad.Objetivo_del_proyecto__c);
                component.set("v.tituloCortoSAP", result.oportunidad.Titulo_corto_SAP__c);
                component.set("v.PAIS", result.tipos["PAIS"]);
                component.set("v.CENTRO", result.tipos["CENTRO"]); 
                component.set("v.DIVISION_INGENIERIA", result.tipos["DIVISION_INGENIERIA"]);
                component.set("v.EMPLAZAMIENTO", result.tipos["EMPLAZAMIENTO"]);
                component.set("v.TIPO_TRABAJO", result.tipos["TIPO_TRABAJO"]); 
                component.set("v.SUBTIPO_TRABAJO", result.tipos["SUBTIPO_TRABAJO"]);
                
                component.set("v.infoParametrica", result.tipos); //Almacenada toda la información paramétrica

                /* INHABILITADO PARA PRUEBAS - VOLVER A ACTIVAR PARA PASO A PRODUCCION */
                
                //Control del botón de Generar Oferta en SAP
                
                //ATENCIÓN: PARA LAS PRUEBAS EL USER PROFILE ESTÁ EN 'System Administrator' PERO EN PRODUCCIÓN HABRIA QUE CAMBIARLO A 'CRM Licitaciones'

                if(result.userProfile != 'Administrador del sistema' && (result.userProfile != 'CRM Licitaciones' || result.oportunidad.Cliente__r.SAP_Account__c == undefined || (result.oportunidad.Oferta_SAP__c != undefined  && result.oportunidad.Oferta_SAP__c != '' && result.oportunidad.Oferta_SAP__c != null)) ){
                    component.set("v.disabledGenOferButton", true);
                }else{
                    component.set("v.disabledGenOferButton", false);    
                }
                
                console.log('Etapa: ', result.oportunidad.Etapa__c);
                console.log('oferta SAP: ', result.oportunidad.Oferta_SAP__c);
                console.log('Account: ', result.oportunidad.Cliente__r.SAP_Account__c);
                console.log('Profile: ', result.userProfile);

                //Control del botón de Solicitar Oferta email
                if( result.oportunidad.Etapa__c != 'Cualificación' ){
                    component.set("v.disabledEmailOferButton", true);
                }else{
                    component.set("v.disabledEmailOferButton", false);    
                }
                
                if(component.get("v.oportunidad.Sociedad_Ayesa__c") == null){
                    component.set("v.errorMessage", "El campo Sociedad_Ayesa__c debe completarse en la Oportunidad antes de rellenar este formulario.")
                    var div = component.find("error-toast");
                    $A.util.removeClass(div,'slds-hidden');
                    $A.util.addClass(div,'slds-is-open');
                }
                   
                // Selección de valor por defecto para el combo de Tipo de trabajo
                if(component.get("v.oportunidad.Tipo_de_Trabajo__c") == null){
                	var sel = component.find('selectTipoTr');
                	sel.set("v.value", "Varios");
                }
                
                // Selección de valor por defecto para el combo de SubTipo de trabajo
                if(component.get("v.oportunidad.Subtipo_de_Trabajo__c") == null){
                	var sel = component.find('selectSubTr');
                	sel.set("v.value", "Concurso");
                }
                
                helper.switchSpinner(component, "");
            }
        });
        $A.enqueueAction(action);
    },
    
    //GUARDAMOS EL FORMULARIO
    
    guardar : function(component, event, helper) {
        
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
        helper.guardarHelper(component, event, helper) ;
    },
    
    //Para volver a la oportunidad
    
    irOportunidad : function(component, event, helper) {
        helper.goToOpp(component);  
    },
    
    generarOferta: function(component, event, helper) {
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
    	var errores = helper.formValidate(component, event, helper);
        if( errores.length == 0 )
       		helper.offerGenerator(component,event,helper);
        else {        	
            component.set("v.errorMessage", "Todos los datos obligatorios son necesarios.");
            component.set("v.errors", errores);
        }
        
        //helper.showToast(component, event, helper);
    },
    
    closeModalOfer: function(component, event, helper) {
        component.set("v.listEmpleado","[]");
        component.set("v.empleadoNombre","");
        component.set("v.empleadoApellido1","");
        component.set("v.empleadoApellido2","");
        component.set("v.empleadoCodigo","");
        
        component.set("v.listCliente","[]");
        component.set("v.clienteNombre","");
        component.set("v.clienteCodigo","");
                            
        $A.util.toggleClass(component.find("modal-ofer"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');         
    },
    
    openModal : function(component, event, helper) {
        
        component.set("v.esResponsable", true);
        component.set("v.esGP", false);
        var div1 = component.find("modalResp");
        $A.util.removeClass(div1,'slds-hidden');
        $A.util.addClass(div1,'slds-is-open');
    },
    
    openModalRUP : function(component, event, helper) {
        
        component.set("v.esResponsable", false);
        component.set("v.esGP", false);
        var div1 = component.find("modalResp");
        $A.util.removeClass(div1,'slds-hidden');
        $A.util.addClass(div1,'slds-is-open');
    },
    
    openModalGP : function(component, event, helper) {
        
        component.set("v.esGP", true);
        component.set("v.esResponsable", false);
        var div1 = component.find("modalResp");
        $A.util.removeClass(div1,'slds-hidden');
        $A.util.addClass(div1,'slds-is-open');
    },
    
    closeModal : function(component, event, helper) {
        
        var div1 = component.find("modalResp");
        $A.util.addClass(div1,'slds-hidden');
        $A.util.removeClass(div1,'slds-is-open');
        
    },
    
    openModalCeco : function(component, event, helper) {
        
        var div1 = component.find("modal-ceco");
        $A.util.removeClass(div1,'slds-hidden');
        $A.util.addClass(div1,'slds-is-open');
        
    },
    
    closeModalCeco : function(component, event, helper) {
        
        var div1 = component.find("modal-ceco");
        $A.util.addClass(div1,'slds-hidden');
        $A.util.removeClass(div1,'slds-is-open');
        
    },
    
    openModalCli : function(component, event, helper) {
        
        var div1 = component.find("modal-cli");
        $A.util.removeClass(div1,'slds-hidden');
        $A.util.addClass(div1,'slds-is-open');
    },
    
    closeModalCli : function(component, event, helper) {
        
        var div1 = component.find("modal-cli");
        $A.util.addClass(div1,'slds-hidden');
        $A.util.removeClass(div1,'slds-is-open');
        
    },
    
    closeToast : function(component, event, helper) {
        
        component.set("v.successMessage", "");
        component.set("v.warningMessage", "");
        component.set("v.errorMessage", "");
        
        var toastId = event.currentTarget.getAttribute("value");  
        $A.util.toggleClass(component.find(toastId), 'slds-hide'); 
        
    },
    
    closeToastSol : function(component, event, helper) {
        
        component.set("v.successMessage", "");
        component.set("v.warningMessage", "");
        component.set("v.errorMessage", "");
        
        var div1 = component.find("solicitud-toast");
        $A.util.addClass(div1,'slds-hidden');
        $A.util.removeClass(div1,'slds-is-open');
        
    },
    
    closeToastErr : function(component, event, helper) {
        
        component.set("v.successMessage", "");
        component.set("v.warningMessage", "");
        component.set("v.errorMessage", "");
        
        var div1 = component.find("error-toast");
        $A.util.addClass(div1,'slds-hidden');
        $A.util.removeClass(div1,'slds-is-open');
        
        var div2 = component.find("warning-toast");
        $A.util.addClass(div2,'slds-hidden');
        $A.util.removeClass(div2,'slds-is-open');
        
    },
    
    buscarCliente : function(component, event, helper) {
        
        helper.switchSpinner(component, "Cargando...");
        
        component.set("v.listCliente",'');
        var action = component.get("c.busquedaCliente");
        var buscarTexto='';
        
        
        if(component.get("v.clienteNombre")!=''){
            buscarTexto= "\"nombre\""+":" +"\""+ component.get("v.clienteNombre")+"\"";
        }     
        if(component.get("v.clienteCodigo")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"codigo\""+":" +"\""+ component.get("v.clienteCodigo")+"\"";
            }else{
                buscarTexto="\"codigo\""+":" +"\""+ component.get("v.clienteCodigo")+"\"";  
            }
        } 
        
        action.setParams({
            buscarTexto:buscarTexto
        });
        
        action.setCallback(this, function(response) {
            
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                var result = JSON.parse(response.getReturnValue());
                
                if (result.length>0){
                    $A.util.removeClass(component.find("showCliente"), "slds-hidden");
                }
                
                component.set("v.listCliente",result);
            }
             helper.switchSpinner(component, "");
        });
        $A.enqueueAction(action);       
        
    },
    
    buscarResponsable : function(component, event, helper) {
        
        helper.switchSpinner(component, "Cargando...");
        
        //BusquedaEmpl
        
        component.set("v.listEmpleados",'');
        var action = component.get("c.busquedaEmpl");
        var buscarTexto='';
        
        
        if(component.get("v.empleadoNombre")!=''){
            buscarTexto= "\"nombre\""+":" +"\""+ component.get("v.empleadoNombre")+"\"";
        }     
        if(component.get("v.empleadoApellido1")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"apellido1\""+":" +"\""+ component.get("v.empleadoApellido1")+"\"";
            }else{
                buscarTexto="\"apellido1\""+":" +"\""+ component.get("v.empleadoApellido1")+"\"";  
            }
        } 
        if(component.get("v.empleadoApellido2")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"apellido2\""+":" +"\""+ component.get("v.empleadoApellido2")+"\"";
            }else{
                buscarTexto="\"apellido2\""+":" +"\""+ component.get("v.empleadoApellido2")+"\""; 
            }
        } 
        if(component.get("v.empleadoCodigo")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"numeroPersonal\""+":" +"\""+ component.get("v.empleadoCodigo")+"\"";
            }else{
                buscarTexto="\"numeroPersonal\""+":" +"\""+ component.get("v.empleadoCodigo")+"\"";
            }
        } 
        
        action.setParams({
            buscarTexto:buscarTexto
        });
        
        
        action.setCallback(this, function(response) {
            
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                var result = JSON.parse(response.getReturnValue());
                
                if (result.length>0){
                    $A.util.removeClass(component.find("showResponsable"), "slds-hidden");
                }
                
                component.set("v.listEmpleados",result);
            }
            helper.switchSpinner(component, "");
        });
        $A.enqueueAction(action);
        
        var table = component.find("empTable");
        $A.util.removeClass(table,'slds-hidden');
        $A.util.addClass(table,'slds-is-open');
        
    },
    
    buscarCeco : function(component, event, helper) {
        
        helper.switchSpinner(component, "Cargando...");
        
        component.set("v.listCecos",'');
        var action = component.get("c.busquedaCeco");
        var buscarTexto='';
        
        if(component.get("v.cecoCodigo")!=''){
            buscarTexto = buscarTexto+ "\"codigo\""+":" +"\""+ component.get("v.cecoCodigo")+"\"";
        }
        if(component.get("v.textCeco")!=''){
            if(buscarTexto != '') buscarTexto = buscarTexto + ",";
            buscarTexto = buscarTexto + "\"descripcion\""+":" +"\""+ component.get("v.textCeco")+"\"";
        }
        if(component.get("v.oportunidad.Sociedad_Ayesa__c")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"SociedadCodigo\""+":" +"\""+ component.get("v.oportunidad.Sociedad_Ayesa__c").substring(0,4)+"\"";
            }else{
                buscarTexto="\"SociedadCodigo\""+":" +"\""+ component.get("v.oportunidad.Sociedad_Ayesa__c").substring(0,4)+"\"";  
            }
        }
        
        action.setParams({
            buscarTexto:buscarTexto
        });
        
        
        action.setCallback(this, function(response) {
            
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                var result = JSON.parse(response.getReturnValue());
                
                if (result.length>0){
                    $A.util.removeClass(component.find("showCecos"), "slds-hidden");
                }
                
                component.set("v.listCecos",result);
            }
            helper.switchSpinner(component, "");
        });
        $A.enqueueAction(action);
        
    },
    
    selectCliente : function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value");
        var listaCliente= component.get("v.listCliente");
        var sapAc = component.get("c.actualizaCodSAP");
        
        var nombreCliente = listaCliente[indice].nombre;
        var idCliente=listaCliente[indice].codigo;
        
        sapAc.setParams({
            empleadoSAP:nombreCliente,
            idCliente:idCliente
        });
        
        component.set("v.clienteCodigo", idCliente); 
        component.set("v.oportunidad.Cliente__r.SAP_Account__c", idCliente)
        
        $A.util.removeClass(component.find("showCliente"), "slds-hidden");
        $A.util.addClass(component.find("modal-cli"), "slds-hidden");
        
        $A.enqueueAction(sapAc);
        
    },
    
    selectEmpleado: function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value"); //indice
        var listaEmpleado= component.get("v.listEmpleados");
        
        var oportunidadEmpleado=listaEmpleado[indice].nombreYApellidos + " - "+listaEmpleado[indice].numeroPersonal ;
        
        component.set("v.responsable", oportunidadEmpleado);
        component.set("v.oportunidad.Responsable__c", oportunidadEmpleado)
        
        $A.util.removeClass(component.find("showCliente"), "slds-hidden");
        $A.util.addClass(component.find("modalResp"), "slds-hidden");
        
    },
    
    selectRUP : function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value"); //indice
        var listaEmpleado= component.get("v.listEmpleados");
        
        var oportunidadEmpleado=listaEmpleado[indice].nombreYApellidos + " - "+listaEmpleado[indice].numeroPersonal ;

        component.set("v.oportunidad.RUP__c", oportunidadEmpleado)
        
        $A.util.removeClass(component.find("showCliente"), "slds-hidden");
        $A.util.addClass(component.find("modalResp"), "slds-hidden");
        
    },
    
    selectGP : function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value"); //indice
        var listaEmpleado= component.get("v.listEmpleados");
        
        var oportunidadEmpleado=listaEmpleado[indice].nombreYApellidos + " - "+listaEmpleado[indice].numeroPersonal ;

        component.set("v.oportunidad.GP__c", oportunidadEmpleado)
        
        $A.util.removeClass(component.find("showCliente"), "slds-hidden");
        $A.util.addClass(component.find("modalResp"), "slds-hidden");
        
    },
    
    selectCeco: function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value");
        var listaCeco= component.get("v.listCecos");
        
        var ceco=listaCeco[indice].codigo;
        
        component.set("v.oportunidad.CECO__c", ceco)
        
        $A.util.removeClass(component.find("showCeco"), "slds-hidden");
        $A.util.addClass(component.find("modal-ceco"), "slds-hidden");
    },
    
    selectTipoTr: function(component, event, helper) {
        
        var action = component.get("c.filterParametrica");
        var valorPadre = component.get("v.oportunidad.Tipo_de_Trabajo__c");
        
        action.setParams({
            valorPadre : valorPadre
        });
        
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                component.set("v.SUBTIPO_TRABAJO", result);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    selectCentro : function(component, event, helper) {
        
        var action = component.get("c.filterParametrica");
        var valorPadre = component.get("v.oportunidad.Centro__c");
        
        action.setParams({
            valorPadre : valorPadre
        });
        
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                component.set("v.EMPLAZAMIENTO", result);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    solicitarOferta : function(component, event, helper) {
        
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
        //var errores = helper.formValidate(component, event, helper);
        //if( errores.length == 0 ) {
            
            // -- Guardamos cambios --
            var opp = JSON.stringify(component.get("v.oportunidad"));
            //component.set("v.oportunidad", opp);
            helper.guardarHelper(component, event, helper);
            
            //Cuando llama a este metodo desde aqui peta por un error de JSON pero guardo con el boton Guardar se guarda bien
            //helper.guardarHelper(component, event, helper) ;
            
            var saveError = component.get("v.errorMessage");
            if (saveError == '') {   							//No hay errores de guardado       
                //EnvioCorreo        
                var action = component.get("c.envioCorreo");
                
                action.setParams({
                    opp : opp
                });
                
                action.setCallback(this, function(response) {
                    
                    if(component.isValid() && response.getState() === "SUCCESS") {
                        
                        //helper.saveHelper(component, event, helper) ;
                        //var updateInter = response.getReturnValue();
                        console.log("SUCCESS");
                        $A.util.removeClass(component.find("solicitud-toast"), 'slds-hidden');
                        // component.set("v.IsModal", false);         
                        component.set("v.disabledEmailOferButton", true);                       
                    }else{
                        console.log("fallo envio correo"); 
                        component.set("v.warningMessage", "");
                        component.set("v.errorMessage", response.getReturnValue());                    
                    }                
                });
                
                $A.enqueueAction(action);   
            }
        /*} else {        	
            component.set("v.errorMessage", "Todos los datos obligatorios son necesarios.");
            component.set("v.errors", errores);
        }*/
        
    }
    
})
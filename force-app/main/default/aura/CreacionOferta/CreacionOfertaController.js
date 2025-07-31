({    
    
    doInit : function(component, event, helper) {
        console.log("Init");
        //helper.switchSpinner(component,"loading");
        helper.switchSpinner(component, "Cargando...");
        
        var action = component.get("c.carga_datos");
        var idOpp = component.get("v.idOpp");
        
        action.setParams({
            idOpportunity : idOpp
        });
        
        action.setCallback(this, function(response) {
            
            var result = JSON.parse(response.getReturnValue());
            console.log('Result: ', result);
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.ListEmpleado",'[]');
                component.set("v.TipoEmpleado","");
                
                component.set("v.oportunidad", result.oportunidad);
				
                component.set("v.oportunidad.nuevoCampo", 'EJEMPLO'); 
              // console.log(component.get("v.oportunidad.nuevoCampo"));
                
                component.set("v.AREA_NEGOCIO", result.tipos["AREA_NEGOCIO"]);
                console.log("Area negocio: "+result.tipos["AREA_NEGOCIO"] );
                component.set("v.PAIS", result.tipos["PAIS"]);
                component.set("v.PAIS_CLIENTE", result.tipos["PAIS"]);
                component.set("v.CENTRO", result.tipos["CENTRO"]); 
                component.set("v.GRUPO", result.tipos["GRUPO"]);
                component.set("v.AETIC", result.tipos["AETIC"]); 
                component.set("v.DIVISION_SAP", result.tipos["DIVISION"]);
                component.set("v.SECTOR_CLIENTE", result.tipos["SECTOR_CLIENTE"]); 
                component.set("v.FUNCIONAL_N1", result.tipos["FUNCIONAL_N1"]);
                component.set("v.TECNICO_N1", result.tipos["TECNICO_N1"]);
                
                component.set("v.InfoParametrica", result.tipos); //Almacenada toda la información paramétrica
                
               // console.log('Area de negocio N1: '+(component.get("v.InfoParametrica"))["AREA_NEGOCIO_N1"]);
              
                for (const key in result.tipos) {
                  // console.log(result.tipos[key]);
                  for (const key2 in result.tipos[key]) {
                        if(result.tipos[key][key2].Tipo__c=="AREA_NEGOCIO"){
                    //        console.log(result.tipos[key][key2].Valor__c);
                        }
                    
                }
                }
               //console.log(result);
               component.set("v.IsModal",false);
               component.set("v.warningMessage" ,"");
               component.set("v.errorMessage" ,"");
                
                
                //Dependientes
                
                /*
                component.set("v.AREA_NEGOCIO_N1", result.tipos["AREA_NEGOCIO_N1"]);
                component.set("v.AREA_NEGOCIO_N2", result.tipos["AREA_NEGOCIO_N2"]);
                component.set("v.DIVISION", result.tipos["DIVISION"]);
                component.set("v.TERRITORIO", result.tipos["TERRITORIO"]);
                component.set("v.SUBGRUPO", result.tipos["SUBGRUPO"]);
                component.set("v.FUNCIONAL_N2", result.tipos["FUNCIONAL_N2"]);
                component.set("v.FUNCIONAL_N3", result.tipos["FUNCIONAL_N3"]);
                component.set("v.TECNICO_N2", result.tipos["TECNICO_N2"]);
                */
                
                
                //Control de activación para el botón de selección de cliente
                if( result.oportunidad.Cliente__r.SAP_Account__c != undefined /*|| result.oportunidad.Cliente__r.SAP_Account__c !='' || result.oportunidad.Cliente__r.SAP_Account__c !=null*/){
                    component.set("v.DeshabilitarBoton", true);
                }else{
                    component.set("v.DeshabilitarBoton", false);                    
                }
                                
                /* INHABILITADO PARA PRUEBAS - VOLVER A ACTIVAR PARA PASO A PRODUCCION */
                
                //Control del botón de Generar Oferta en SAP
                if( result.userProfile != 'Administrador del sistema' && (result.userProfile != 'CRM Licitaciones' || result.oportunidad.Cliente__r.SAP_Account__c == undefined  || (result.oportunidad.Oferta_SAP__c != undefined  && result.oportunidad.Oferta_SAP__c != '' && result.oportunidad.Oferta_SAP__c != null)) ){
                    component.set("v.disabledGenOferButton", true);
                }else{
                    component.set("v.disabledGenOferButton", false);    
                }
                console.log('Etapa: ', result.oportunidad.Etapa__c);
                console.log('oferta SAP: ', result.oportunidad.Oferta_SAP__c);
                console.log('Account: ', result.oportunidad.SAP_Account__c);
                
                //Control del botón de Solicitar Oferta email
                if( result.oportunidad.Etapa__c == 'Cerrada' || (result.oportunidad.Oferta_SAP__c != undefined  && result.oportunidad.Oferta_SAP__c != '' && result.oportunidad.Oferta_SAP__c != null) ){
                    component.set("v.disabledEmailOferButton", true);
                }else{
                    component.set("v.disabledEmailOferButton", false);    
                }
                
                // Inicializaciones por defecto
                component.set("v.EsCliente",false);
                component.set("v.EsEmpleado",false); 
                // console.log(result.oportunidad);
                
              
                helper.switchSpinner(component, "");                
            }
        });
        $A.enqueueAction(action);        
    },
    
    
    SolicitarOferta : function(component, event, helper) {
      
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        //Llamada desde CRM Preventa
        var preventaAtt = component.get("v.preventa");
        var idOpp = component.get("v.idOpp");        
        console.log("Preventa Ibermatica: " + preventaAtt + " idOpp: " + idOpp); 
        
        
        var errores = helper.formValidate(component, event, helper);
        
        if( errores.length == 0 ) {
			
            // -- Guardamos cambios --
            var opp = component.get("v.oportunidad");
            component.set("v.oportunidad", opp);                    
            helper.saveHelper(component, event, helper) ;
                        
            var saveError = component.get("v.errorMessage");
            if (saveError == '') {   							//No hay errores de guardado       
                //EnvioCorreo        
                var action = component.get("c.EnvioCorreo");
                //var opp = JSON.stringify(component.get("v.oportunidad"));
                action.setParams({
                    Oport : JSON.stringify(opp)
                });
                
                component.set("v.IsModal", true);
                component.set("v.EsEmpleado",false);
                action.setCallback(this, function(response) {
                    
                    if(component.isValid() && response.getState() === "SUCCESS") {
                     
                        //helper.saveHelper(component, event, helper) ;
                        //var updateInter = response.getReturnValue();
                        $A.util.removeClass(component.find("ShowEmpleadoCliente"), 'slds-hidden'); 
                        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
                        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');
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
        } else {        	
            //component.set("v.errorMessage", "Todos los datos obligatorios son necesarios.");
            //component.set("v.errors", errores);
            //Llamada desde CRM Preventa
                if(preventaAtt == "true"){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:CRM_Preventa",
                        componentAttributes: {
                            Show_Seccion_Ibermatica : "true",
                            idOportunidad :idOpp
                        }
                    });
                    evt.fire(); 
                } 
        }
        
    },
    
    save : function(component, event, helper) {  
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
        helper.saveHelper(component, event, helper) ;
        //component.set("v.successMessage",  $A.get("$Label.c.CRM_Oferta_guardada_correctamente_CL")); 
        //component.set("v.errorMessage" ,"");
        /*DESCOMENTAR SI QUEREMOS QUE VUELVA A LA OPORTUNIDAD DE FORMA DIRECTA*/
        //helper.GoToOport(component);
        
    },
    
    IrOportunidad : function(component, event, helper) {
        
        helper.GoToOport(component);  
       
    },
    
    OpenModal: function(component, event, helper) {
        component.set("v.ListEmpleado","[]");
        component.set("v.EmpleadoNombre","");
        component.set("v.EmpleadoApellido1","");
        component.set("v.EmpleadoApellido2","");
        component.set("v.EmpleadoCodigo","");
        component.set("v.TipoEmpleado","");
        
        component.set("v.ListCliente","[]");
        component.set("v.ClienteNombre","");
        component.set("v.ClienteCodigo","");
        
        var tipoempleado = event.currentTarget.getAttribute("value"); //indice
             
            if(tipoempleado=="Cliente"){
                component.set("v.EsEmpleado",false);
                component.set("v.IsModal",false);
            }else if (tipoempleado=="Jefe_de_Proyecto__c"  || tipoempleado=="GP__c"  || tipoempleado=="RUP__c"){    
                component.set("v.EsEmpleado",true);
                component.set("v.TipoEmpleado",tipoempleado);
                component.set("v.IsModal",false);
            }
            
        $A.util.addClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden'); 
        
    },
    
    BuscarEmpleado : function(component, event, helper) {
        
        //BusquedaEmpl
        component.set("v.ListEmpleado",'');
        //helper.switchSpinner(component, "modal");
        //helper.switchSpinner(component, "Buscando...");
        var action = component.get("c.BusquedaEmpl");
        var buscarTexto='';
           
        
        if(component.get("v.EmpleadoNombre")!=''){
            buscarTexto= "\"nombre\""+":" +"\""+ component.get("v.EmpleadoNombre")+"\"";
        }     
        if(component.get("v.EmpleadoApellido1")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"apellido1\""+":" +"\""+ component.get("v.EmpleadoApellido1")+"\"";
            }else{
                buscarTexto="\"apellido1\""+":" +"\""+ component.get("v.EmpleadoApellido1")+"\"";  
            }
        } 
        if(component.get("v.EmpleadoApellido2")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"apellido2\""+":" +"\""+ component.get("v.EmpleadoApellido2")+"\"";
            }else{
                buscarTexto="\"apellido2\""+":" +"\""+ component.get("v.EmpleadoApellido2")+"\""; 
            }
        } 
        if(component.get("v.EmpleadoCodigo")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"numeroPersonal\""+":" +"\""+ component.get("v.EmpleadoCodigo")+"\"";
            }else{
                buscarTexto="\"numeroPersonal\""+":" +"\""+ component.get("v.EmpleadoCodigo")+"\"";
            }
        } 
        
        action.setParams({
            //    emp : emp ,
            buscarTexto:buscarTexto
        });
        
        
        action.setCallback(this, function(response) {
            
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                var result = JSON.parse(response.getReturnValue());
                
                if (result.length>0){
                    $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
                }
                
                component.set("v.ListEmpleado",result);
                //helper.switchSpinner(component,"modal");
                //helper.switchSpinner(component, "");
            }
        });
        $A.enqueueAction(action);       
        
    },
    
    
    BuscarCliente : function(component, event, helper) {
        
        //BusquedaEmpl
        component.set("v.ListCliente",'');
        var action = component.get("c.BusquedaCliente");
        var buscarTexto='';
        
        
        if(component.get("v.ClienteNombre")!=''){
            buscarTexto= "\"nombre\""+":" +"\""+ component.get("v.ClienteNombre")+"\"";
        }     
        if(component.get("v.ClienteCodigo")!=''){
            if(buscarTexto!=''){
                buscarTexto=buscarTexto+",\"codigo\""+":" +"\""+ component.get("v.ClienteCodigo")+"\"";
            }else{
                buscarTexto="\"codigo\""+":" +"\""+ component.get("v.ClienteCodigo")+"\"";  
            }
        } 
        
        action.setParams({
            buscarTexto:buscarTexto
        });
       
        action.setCallback(this, function(response) {
            
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                var result = JSON.parse(response.getReturnValue());
                
                if (result.length>0){
                    $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
                }
                
                component.set("v.ListCliente",result);
            }
        });
        $A.enqueueAction(action);       
        
    },
  
    SelectEmpleado: function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value"); //indice
        var listaEmpleado= component.get("v.ListEmpleado");
        
        var tipoEmpleado= component.get("v.TipoEmpleado");
        
        var OportunidadEmpleado=listaEmpleado[indice].nombreYApellidos + " - "+listaEmpleado[indice].numeroPersonal ;
        
        if(tipoEmpleado=="GP__c"){
            
            component.set("v.oportunidad.GP__c",OportunidadEmpleado); 
        }else if(tipoEmpleado=="Jefe_de_Proyecto__c"){
            
            component.set("v.oportunidad.Jefe_de_Proyecto__c",OportunidadEmpleado); 
        }else{
            component.set("v.oportunidad.RUP__c",OportunidadEmpleado); 
        }
        
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');  
        $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
        
    },
    
    SelectCliente: function(component, event, helper) {
        
        var indice = event.currentTarget.getAttribute("value"); //indice
        var listaCliente= component.get("v.ListCliente");
        
        var EmpleadoSAP=listaCliente[indice].codigo  ;
        var idCliente=component.get("v.oportunidad.Cliente__c");

        //console.log(listaCliente[indice]);
        
        var action = component.get("c.actualizaCodSAP");
        
        action.setParams({
            EmpleadoSAP:EmpleadoSAP,
            idCliente:idCliente
        });
        
        
        action.setCallback(this, function(response) {
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                
                component.set("v.DeshabilitarBoton", true);
                component.set("v.oportunidad.Cliente__r.SAP_Account__c", EmpleadoSAP);
                
                //Control del botón de Generar Oferta en SAP
                var oportunidad = component.get("v.oportunidad");
                //oportunidad.Etapa__c != 'Pedido Código Oferta'
                if( oportunidad.Etapa__c == 'Cerrada' || oportunidad.Cliente__r.SAP_Account__c == undefined  || (oportunidad.Oferta_SAP__c != undefined  && oportunidad.Oferta_SAP__c != '' && oportunidad.Oferta_SAP__c != null) ){
                    component.set("v.disabledGenOferButton", true);
                }else{
                    component.set("v.disabledGenOferButton", false);    
                }
                
            }
        });
        $A.enqueueAction(action);     
        
        
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');  
        $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
        
    },
    
    filterValues: function(component, event, helper) {
        var padre= event.getSource().getLocalId(); //Identificadores de padre e hijo en listas dependientes
        var hijo= event.getSource().get("v.name");
        
        var territorio = false; //Caso de territorio para buscar en misma lista global y filtrar a listas individuales
        if (hijo.includes("TERRITORIO")){
            var territorio=true;
        }
        
        var hijo2=''; //Buscar si hay segunda lista dependiente
        if (component.find(hijo).get("v.name")!='select'){
            hijo2=component.find(hijo).get("v.name");
        }
        
        var value = event.getSource().get("v.value"); //Se coge el nomre del valor para buscar su codigo en la lista global
        
        var varHijo= "v."+hijo; //se monta la cadena de la variable para hacer el posterior SET de la lista filtrada
        var varPadre="v."+padre;
        
        var listaPadre= component.get(varPadre);
       
        var codPadre=''; //Busqueda del codigo del padre
        for (var j=0;j< listaPadre.length; j++){
            if (listaPadre[j].Valor__c==value){
                codPadre=listaPadre[j].Name;
            }
        }   
        
        var result; //Recoger la lista HIJO para su posterior filtrado
        if(territorio){
            result= (component.get("v.InfoParametrica")["TERRITORIO"]);
        }else{
        	result= (component.get("v.InfoParametrica")[hijo]);
        }
        
        var filterList=[];
        for (var i = 0; i < result.length; i++) {  //Filtrao de la lista hijo segun el codigo del padre
            if (result[i].Codigo_Padre__c==codPadre){
                filterList.push(result[i]);
            }
        }

        if (hijo2 !=''){  //Blanqueo de listas dependientes
            hijo2=component.find(hijo).get("v.name");
            component.find(hijo2).set("v.value", "");
        }
        component.find(hijo).set("v.value", "");
        
        //Se coloca en la lista HIJO el nuevo valor filtrado
        component.set(varHijo, filterList);

    },
    
    GenOferta: function(component, event, helper) {
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
        
        
        var errores = helper.formValidate(component, event, helper);
        
        if( errores.length == 0 ){
            helper.OfferGenerator(component,event,helper);
          
        }else {        	
            component.set("v.errorMessage", "Todos los datos obligatorios son necesarios.");
            component.set("v.errors", errores);
        }
        //helper.showToast(component, event, helper);
    },

    CloseModalOfer: function(component, event, helper) {
        component.set("v.ListEmpleado","[]");
        component.set("v.EmpleadoNombre","");
        component.set("v.EmpleadoApellido1","");
        component.set("v.EmpleadoApellido2","");
        component.set("v.EmpleadoCodigo","");
        component.set("v.TipoEmpleado","");
        
        component.set("v.ListCliente","[]");
        component.set("v.ClienteNombre","");
        component.set("v.ClienteCodigo","");
                            
        $A.util.toggleClass(component.find("modal-ofer"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');         
    },
    
    CloseToast: function(component, event, helper) { 
        component.set("v.successMessage", "");
        component.set("v.warningMessage", "");
        component.set("v.errorMessage", "");
        
        var toastId = event.currentTarget.getAttribute("value");  
        $A.util.toggleClass(component.find(toastId), 'slds-hide'); 
    },
    
})
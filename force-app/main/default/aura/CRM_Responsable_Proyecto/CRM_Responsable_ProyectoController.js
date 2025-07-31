({    
    doInit: function(component, event, helper) {
        var action = component.get("c.obtenerOportunidad");
        action.setParams({
            oppId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oportunidad = response.getReturnValue();
                component.set("v.oportunidad", oportunidad);
                console.log("Oportunidad cargada -> ", oportunidad);
            } else {
                console.error("Error al cargar la oportunidad: ", response.getError());
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.esCampoResponsableRequerido");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS :' + response.getReturnValue())
                component.set("v.esResponsableRequerido", response.getReturnValue());
            } else {
                console.error("Error al obtener condición del campo Responsable");
            }
        });
        $A.enqueueAction(action);
    },
    
    OpenModal: function(component, event, helper) {
        component.set("v.ListEmpleado","[]");
        component.set("v.EmpleadoNombre","");
        component.set("v.EmpleadoApellido1","");
        component.set("v.EmpleadoApellido2","");
        component.set("v.EmpleadoCodigo","");
        component.set("v.TipoEmpleado",""); 
        component.set("v.selectedEmpleado", {});
        
        // abre modal y oscurece fondo
        $A.util.addClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden'); 
    },
    
    CloseModal: function(component, event, helper) {
        // cierra modal y fondo ok
        $A.util.addClass(component.find("modal"), "slds-hidden");
        $A.util.addClass(component.find("backGroundModal"), "slds-hidden");
    },
    
    BuscarEmpleado : function(component, event, helper) {
        
        component.set("v.EsOtroUsuario", false); 
        
        //BusquedaEmpl
        component.set("v.ListEmpleado",'');
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
                component.set("v.EsEmpleado", true);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    AbrirFormularioOtroUsuario: function(component, event, helper) {
        
        var esOtroUsuario = component.get("v.EsOtroUsuario");
        component.set("v.EsOtroUsuario", !esOtroUsuario); // para mostrar/ocultar el formulario
        
        console.log("EsOtroUsuario --> " + component.get("v.EsOtroUsuario"));
    },
    
    SelectEmpleado: function(component, event, helper) {
        console.log("SelectEmpleado");
        
        // índice del botón seleccionado
        var indice = event.currentTarget.getAttribute("data-index");
        console.log("Índice obtenido --> ", indice);
        if (indice === null || indice === undefined ) {
            console.error("Error Índice");
            return;
        }    
        
        // lista de empleados
        var listaEmpleado = component.get("v.ListEmpleado");
        if (!listaEmpleado || listaEmpleado.length === 0) {
            console.error("La lista de empleados está vacía o no se ha cargado");
            return;
        }
        
        // comprueba el índice
        indice = parseInt(indice, 10);
        if (indice < 0 || indice >= listaEmpleado.length) {
            console.error("Índice fuera de los límites");
            return;
        }
        
        // id de la Oportunidad
        var idOpp = component.get("v.recordId");
        console.log("oportunidad idOpp -->", idOpp);
        if (!idOpp) {
            console.error("Error idOpp");
            return;
        }
        
        // datos del empleado seleccionado
        var empleadoSeleccionado = listaEmpleado[indice];
        console.log("Empleado seleccionado -->", empleadoSeleccionado);
        if (!empleadoSeleccionado || !empleadoSeleccionado.nombreYApellidos || !empleadoSeleccionado.correoElectronico) {
            console.error("Error datos empleado");
            return;
        }
        
        var OportunidadEmpleado = empleadoSeleccionado.nombreYApellidos + " (" + empleadoSeleccionado.numeroPersonal + ")" + " - " + empleadoSeleccionado.correoElectronico;
        console.log("empleado OportunidadEmpleado -->", OportunidadEmpleado);
        
        // método Apex
        var action = component.get("c.actualizarOportunidad");
        action.setParams({
            oppId: idOpp,
            responsable: OportunidadEmpleado
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Se ha actualizado la oportunidad");
                component.find("ResponsableProyecto").set("v.value", OportunidadEmpleado);
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error("Error al actualizar oportunidad:", errors);
            }
        });
        
        $A.enqueueAction(action);
        
        // cierre
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');
        $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
    },
    
    GuardarEmpleado: function(component, event, helper) {
        helper.GuardarEmpleado(component);
    },
    
    toggleSection : function(component, event, helper) {
        
        var sectionAuraId = event.target.getAttribute("data-auraId");
        
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();        
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 open/close section
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    }
    
})
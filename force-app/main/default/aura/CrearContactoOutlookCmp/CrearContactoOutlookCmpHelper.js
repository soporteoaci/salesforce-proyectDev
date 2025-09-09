({
    crearContacto: function (component, event, helper) {
        var contacto = component.get("v.contacto");
        
        var action = component.get("c.guardarContacto");
        
        action.setParams({ contacto: contacto });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.mostrarToast("Éxito", "Contacto guardado correctamente.", "success");
                component.set("v.contacto", {
                    tratamiento: '',
                    nombre: '',
                    apellidos: '',
                    cuenta: '',
                    email: '',
                    cargo: '',
                    perfil: '',
                    nivel: '',
                    subnivel: '',
                    claveNegocio: false
                });
                component.set("v.busquedaCuenta", '');
                component.set("v.cuentaNombre", '');
                component.set("v.resultadosCuentas", []);
                component.set("v.mostrarResultados", false);
            } else {
                var errors = response.getError();
                var message = "Error desconocido al guardar.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                helper.mostrarToast("Error", message, "error");
            }
        });
        
        $A.enqueueAction(action);
    },
    mostrarToast: function(titulo, mensaje, tipo) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: titulo,
                message: mensaje,
                type: tipo || "info",
                mode: "dismissible"
            });
            toastEvent.fire();
        } else {
            console.warn("No se pudo mostrar el toast:", titulo, mensaje);
        }
    },

    obtenerOpcionesPicklist: function(component, objectName, fieldName, targetAttribute) {
        var action = component.get("c.obtenerValoresPicklist");
        action.setParams({
            objectName: objectName,
            fieldName: fieldName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v." + targetAttribute, response.getReturnValue());
            } else {
                console.error("Error al obtener valores de picklist:", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
 	buscarCuentas: function(component, event, helper) {
        const texto = component.get("v.busquedaCuenta");
        if (!texto || texto.trim() === '') {
            component.set("v.resultadosCuentas", []);
            component.set("v.mostrarResultados", false);
            return;
        }
    
        const action = component.get("c.buscarCuentasPorNombre");
        action.setParams({ texto });
    
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var resultados = response.getReturnValue();
                component.set("v.resultadosCuentas", resultados);
                component.set("v.mostrarResultados", true);
            } else {
                console.error("Error al buscar cuentas:", response.getError());
            }
        });
        
        $A.enqueueAction(action);
	},

                      
    seleccionarCuenta: function(component, event) {
        let target = event.target;
    
        // Recorremos hacia arriba en el DOM hasta encontrar el elemento con data-id
        while (target && !target.dataset.id) {
            target = target.parentElement;
        }
    
        if (!target) {
            console.warn("No se encontró el elemento de cuenta seleccionado.");
            return;
        }
    
        const id = target.dataset.id;
        const nombre = target.dataset.nombre;
    
        let contacto = component.get("v.contacto");
        contacto.cuenta = id;
    
        component.set("v.contacto", contacto);
        component.set("v.cuentaNombre", nombre);
        component.set("v.busquedaCuenta", nombre); // mostrar en input
        component.set("v.mostrarResultados", false);
    },

    agregarListenersCerrarDropdown: function(component) {

        const clickHandler = function(event) {
            try {
                const contenedor = component.find("contenedorLookupCuenta");
                if (contenedor && contenedor.getElement && !contenedor.getElement().contains(event.target)) {
                    component.set("v.mostrarResultados", false);
                }
            } catch (e) {
                console.warn("Error al cerrar con click fuera:", e);
            }
        };
    
        const escapeHandler = function(event) {
            try {
                if (event.key === 'Escape') {
                    component.set("v.mostrarResultados", false);
                }
            } catch (e) {
                console.warn("Error al cerrar con Escape:", e);
            }
        };
    
        if (!window._lookupCuentaListenersAdded) {
            document.addEventListener('click', clickHandler);
            document.addEventListener('keydown', escapeHandler);
            window._lookupCuentaListenersAdded = true;
        }
    }
})
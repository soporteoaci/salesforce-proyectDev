({
    
    doInit: function(component, event, helper) {
        // Cargar picklists con callback para cargar la tarea después
        helper.cargarPicklists(component, function() {
            helper.cargarTarea(component);
        });
        
        document.addEventListener('click', function(event) {
            const lookup = component.find('lookupContainer');
            if (lookup) {
                const lookupElement = lookup.getElement();
                if (!lookupElement.contains(event.target)) {
                    component.set("v.mostrarResultados", false);
                }
            }
        });
    },

    buscarContactos: function(component, event, helper) {
        var cuentaId = component.get("v.cuentaSeleccionada");
        var texto = component.get("v.nombreContacto");
        
        if (!cuentaId) {
            component.set("v.opcionesContactos", []);
            component.set("v.mostrarResultadosContactos", false);
            return;
        }
        
        if (!texto || texto.trim() === "") {
            // Si no hay texto, mostrar todos los contactos de la cuenta
            texto = "";
        }
        
        var action = component.get("c.buscarContactosPorCuenta");
        action.setParams({ cuentaId: cuentaId, texto: texto });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var resultados = response.getReturnValue();
                component.set("v.opcionesContactos", resultados);
                component.set("v.mostrarResultadosContactos", resultados.length > 0);
            } else {
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarResultadosContactos", false);
            }
        });
        $A.enqueueAction(action);
    },
    seleccionarContacto: function(component, event, helper) {
        var contactoId = event.currentTarget.dataset.id;
        var nombreContacto = event.currentTarget.dataset.nombre;
        if (contactoId && nombreContacto) {
            component.set("v.tarea.WhoId", contactoId);
            component.set("v.nombreContacto", nombreContacto);
            component.set("v.opcionesContactos", []);
            component.set("v.mostrarResultadosContactos", false);
        }
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

    seleccionarCuenta: function(component, event, helper) {
        const cuentaId = event.currentTarget.dataset.id;
        const nombreCuenta = event.currentTarget.dataset.nombre;

        if (cuentaId && nombreCuenta) {
            // Seteamos valores en atributos del componente
            component.set("v.busquedaCuenta", nombreCuenta);
            component.set("v.cuentaSeleccionada", cuentaId);
            
            // Ocultamos resultados y limpiamos lista
            component.set("v.mostrarResultados", false);
            component.set("v.resultadosCuentas", []);
            // Ya no se cargan contactos relacionados
        } else {
            console.warn("No se pudo seleccionar la cuenta: datos incompletos");
        }
    },

    // -----------------------------
    // HANDLERS DUAL CUSTOM
    // -----------------------------
    toggleDisponible: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        let marcados = new Set(component.get("v.lineasServicioDisponiblesSeleccionadas") || []);
        if (marcados.has(value)) {
            marcados.delete(value);
        } else {
            marcados.add(value);
        }
        const nuevosMarcados = Array.from(marcados);
        component.set("v.lineasServicioDisponiblesSeleccionadas", nuevosMarcados);

        // Actualizar flag 'marked' visual en la lista de disponibles
        const lista = component.get("v.lineasServicioDisponibles") || [];
        for (let i = 0; i < lista.length; i++) {
            lista[i].marked = marcados.has(lista[i].value);
        }
        component.set("v.lineasServicioDisponibles", lista);
    },

    toggleSeleccionada: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        let marcados = new Set(component.get("v.lineasServicioSeleccionadasMarcadas") || []);
        if (marcados.has(value)) {
            marcados.delete(value);
        } else {
            marcados.add(value);
        }
        const nuevosMarcados = Array.from(marcados);
        component.set("v.lineasServicioSeleccionadasMarcadas", nuevosMarcados);

        // Actualizar flag 'marked' visual en la lista de seleccionadas
        const listaSel = component.get("v.lineasServicioSeleccionadasDetalles") || [];
        for (let i = 0; i < listaSel.length; i++) {
            listaSel[i].marked = marcados.has(listaSel[i].value);
        }
        component.set("v.lineasServicioSeleccionadasDetalles", listaSel);
    },

    moverADerecha: function(component, event, helper) {
        helper.moveValues(component, 'Disponibles', 'Seleccionadas');
    },

    moverAIzquierda: function(component, event, helper) {
        helper.moveValues(component, 'Seleccionadas', 'Disponibles');
    },

    // Doble click: mover directamente un ítem al otro lado
    doubleClickDisponible: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        // Marcar temporalmente el valor y mover a la derecha
        component.set("v.lineasServicioDisponiblesSeleccionadas", [value]);
        helper.moveValues(component, 'Disponibles', 'Seleccionadas');
    },

    doubleClickSeleccionada: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        // Marcar temporalmente el valor y mover a la izquierda
        component.set("v.lineasServicioSeleccionadasMarcadas", [value]);
        helper.moveValues(component, 'Seleccionadas', 'Disponibles');
    },

    moverTodosADerecha: function(component, event, helper) {
        helper.moveAll(component, 'Disponibles', 'Seleccionadas');
    },

    moverTodosAIzquierda: function(component, event, helper) {
        helper.moveAll(component, 'Seleccionadas', 'Disponibles');
    },

    limpiarCuenta: function(component) {
        // Limpiar WhatId estándar y campos auxiliares de UI
        component.set("v.tarea.WhatId", null);
        component.set("v.cuentaSeleccionada", null);
        component.set("v.busquedaCuenta", '');
        component.set("v.mostrarResultados", false);
    },
    guardarTarea: function(component, event, helper) {
        helper.guardarTarea(component, function() {
            // ✅ Cierra el modal después de guardar con éxito
            const overlayLib = component.find("overlayLib");
            if (overlayLib) {
                overlayLib.notifyClose();
            }
            // ✅ Volver a la pantalla de tareas si existe el evento
            if ($A.get("e.force:navigateToComponent")) {
                const navEvt = $A.get("e.force:navigateToComponent");
                navEvt.setParams({
                    componentDef: "c:TareasOutlookCmp",
                    componentAttributes: {}
                });
                navEvt.fire();
            }
        });
    },

    cancelar: function(component, event, helper) {
        // Limpiar el formulario
        component.set("v.tarea", {});
        component.set("v.estadoSeleccionado", null);
        component.set("v.lineasServicioSeleccionadas", []);
        component.set("v.busquedaCuenta", '');
        component.set("v.cuentaSeleccionada", null);
        component.set("v.resultadosCuentas", []);
        component.set("v.mostrarResultados", false);

        // Cerrar modal si se abrió en overlay
        const overlayLib = component.find("overlayLib");
        if (overlayLib) {
            overlayLib.notifyClose();
        }

        // Navegar de vuelta a TareasOutlookCmp (si está disponible en este contexto)
        if ($A.get("e.force:navigateToComponent")) {
            const navEvt = $A.get("e.force:navigateToComponent");
            navEvt.setParams({
                componentDef: "c:TareasOutlookCmp",
                componentAttributes: {}
            });
            navEvt.fire();
        }
    },

	cambiarEstado: function(component, event, helper) {
        const estado = component.get("v.tarea.Status");
        console.log("➡ [Controller] cambiarEstado ejecutado. Nuevo estado:", estado);
        component.set("v.estadoSeleccionado", estado);
	},

})
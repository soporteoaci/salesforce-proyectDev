({
    init: function(component, event, helper) {
        const hoy = new Date().toISOString().slice(0, 10); // formato YYYY-MM-DD
        component.set("v.fechaInicio", hoy);
        component.set("v.fechaFin", hoy);
        
        helper.actualizarMensajeFecha(component);
        helper.obtenerTareas(component);

        // Cargar valores dinámicos de picklists
        helper.obtenerPicklists(component);

        helper.agregarListenersCerrarDropdown(component);
    },

    filtrarTareas: function(component, event, helper) {
        helper.actualizarMensajeFecha(component);
        helper.obtenerTareas(component);
    },

    crearReunion: function(component, event, helper) {
        // Validar campos obligatorios ANTES de enviar
        const subject = component.get("v.subject");
        const fecha = component.get("v.fechaReunion");
        const prioridad = component.get("v.prioridad");
        const sector = component.get("v.sectorMercado");
        const lineas = component.get("v.lineasServicio");
        const cuentaId = component.get("v.cuentaSeleccionada");
        const contactoId = component.get("v.contactoSeleccionado");

        let errores = [];

        if (!subject || subject.trim() === '') {
            errores.push("El campo Asunto es obligatorio.");
        }
        if (!fecha) {
            errores.push("Debe seleccionar una Fecha.");
        }
        if (!prioridad) {
            errores.push("Debe seleccionar una Prioridad.");
        }
        if (!sector) {
            errores.push("Debe seleccionar un Sector de Mercado.");
        }
        if (!lineas || lineas.length === 0) {
            errores.push("Debe seleccionar al menos una Línea de Servicio.");
        }
        if (!cuentaId) {
            errores.push("Debe seleccionar una Cuenta.");
        }
        if (!contactoId) {
            errores.push("Debe seleccionar un Contacto.");
        }

        if (errores.length > 0) {
            $A.get("e.force:showToast").setParams({
                title: "Campos obligatorios faltantes",
                message: errores.join(" "),
                type: "error"
            }).fire();
            return;
        }

        // Si pasa la validación, ejecutar lógica existente
        helper.crearReunión(component);
        helper.obtenerTareas(component); // Refrescar lista
    },

    guardarCambios: function(component, event, helper) {
        const borradores = event.getParam("draftValues");
        if (!borradores || borradores.length === 0) return;

        const tareasBase = component.get("v.tareas");
        let tareasParaActualizar = [];

        const regexHoraValida = /^([01]?\d|2[0-3]):(00|30)$/;

        for (let borrador of borradores) {
            // Validar formato
            if (borrador.horaInicio && !regexHoraValida.test(borrador.horaInicio)) {
                $A.get("e.force:showToast").setParams({
                    title: "Hora inválida",
                    message: "La hora debe estar en intervalos de 30 minutos (ej: 09:00, 09:30).",
                    type: "error"
                }).fire();
                return;
            }

            let tareaOriginal = tareasBase.find(t => t.Id === borrador.Id);
            if (!tareaOriginal) continue;

            // Convertir hora a Date
            if (borrador.horaInicio) {
                const [h, m] = borrador.horaInicio.split(":").map(Number);
                const fechaTarea = new Date(tareaOriginal.ActivityDate);
                const startDateTime = new Date(fechaTarea.setHours(h, m, 0, 0));
                const endDateTime = new Date(startDateTime.getTime() + 30 * 60000);

                tareaOriginal.startDateTimeRaw = startDateTime.toISOString();
                tareaOriginal.endDateTimeRaw = endDateTime.toISOString();
            }

            tareasParaActualizar.push(helper.crearTareaParaActualizar(tareaOriginal, borrador));
        }

        const action = component.get("c.actualizarTareas");
        action.setParams({ tareasActualizadas: tareasParaActualizar });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.get("e.force:showToast").setParams({
                    title: "Guardado",
                    message: "Los cambios se guardaron correctamente.",
                    type: "success"
                }).fire();

                component.set("v.borradores", []);
                helper.obtenerTareas(component);
            } else {
                console.error("Error al guardar:", response.getError());
            }
        });

        $A.enqueueAction(action);
    },
        
    verDetalleContacto: function(component, event, helper) {
        const tareaId = event.getSource().get("v.value"); 
        const actionName = event.getSource().get("v.name"); // name lo usaremos para diferenciar acción

        if (actionName === "toggleDetalle") {
            helper.toggleDetalleContacto(component, tareaId);
        }

        if (actionName === "editarTarea") {
            helper.abrirEditorDeTarea(component, tareaId, helper);
        }
    },

    buscarCuentas: function(component, event, helper) {
        helper.buscarCuentas(component);
    },

    seleccionarCuenta: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        const nombre = event.currentTarget.getAttribute("data-nombre");
        component.set("v.busquedaCuenta", nombre);
        component.set("v.cuentaSeleccionada", id);
        component.set("v.mostrarResultados", false);
        // Limpiar contacto seleccionado y búsqueda
        component.set("v.busquedaContacto", '');
        component.set("v.contactoSeleccionado", null);
        component.set("v.opcionesContactos", []);
        component.set("v.mostrarResultadosContactos", false);
        // Cargar contactos de la cuenta
        helper.cargarContactos(component, id);
        // Activar filtro de tareas después de seleccionar cuenta
        helper.actualizarMensajeFecha(component);
        helper.obtenerTareas(component);
    },

    cuentaInputCambiada: function(component, event, helper) {
        const texto = event.getSource().get("v.value");
        const cuentaActual = component.get("v.busquedaCuenta");
        
        // Si se borró el texto, limpiar la selección y refiltrar
        if (!texto || texto.trim() === '') {
            component.set("v.cuentaSeleccionada", null);
            component.set("v.opcionesContactos", []);
            component.set("v.mostrarResultados", false);
            // Refiltrar tareas sin cuenta
            helper.actualizarMensajeFecha(component);
            helper.obtenerTareas(component);
        } else {
            // Buscar cuentas si hay texto
            helper.buscarCuentas(component);
        }
        
        // Limpiar la cuenta seleccionada si el texto ha cambiado
        if (texto !== cuentaActual) {
            component.set("v.cuentaSeleccionada", null);
        }
    },

    buscarContactos: function(component, event, helper) {
        const texto = component.get("v.busquedaContacto");
        const contactos = component.get("v.opcionesContactos") || [];
        if (!texto || texto.trim() === '') {
            // Mostrar todos los contactos cargados
            component.set("v.mostrarResultadosContactos", contactos.length > 0);
            return;
        }
        // Filtrar por texto en el cliente
        const filtrados = contactos.filter(c => (c.label || '').toLowerCase().includes(texto.toLowerCase()));
        component.set("v.opcionesContactos", contactos); // mantener todos para futuras búsquedas
        component.set("v.mostrarResultadosContactos", filtrados.length > 0);
        component.set("v.opcionesContactos", filtrados);
    },

    seleccionarContacto: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        const nombre = event.currentTarget.getAttribute("data-nombre");
        component.set("v.busquedaContacto", nombre);
        component.set("v.contactoSeleccionado", id);
        component.set("v.mostrarResultadosContactos", false);
    },

    // -----------------------------
    // DUAL LISTBOX CUSTOM - Líneas de Servicio
    // -----------------------------
    toggleDisponibleLinea: function(component, event, helper) {
        helper.toggleMarcado(component, event, 'lineasServicioDisponiblesSeleccionadas', 'lineasServicioDisponibles');
    },

    toggleSeleccionadaLinea: function(component, event, helper) {
        helper.toggleMarcado(component, event, 'lineasServicioSeleccionadasMarcadas', 'lineasServicioSeleccionadasDetalles');
    },

    moverADerechaLinea: function(component, event, helper) {
        helper.moveValuesGeneric(component, 'lineas', 'Disponibles', 'Seleccionadas');
    },

    moverAIzquierdaLinea: function(component, event, helper) {
        helper.moveValuesGeneric(component, 'lineas', 'Seleccionadas', 'Disponibles');
    },

    doubleClickDisponibleLinea: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        component.set("v.lineasServicioDisponiblesSeleccionadas", [value]);
        helper.moveValuesGeneric(component, 'lineas', 'Disponibles', 'Seleccionadas');
    },

    doubleClickSeleccionadaLinea: function(component, event, helper) {
        const value = event.currentTarget.dataset.value;
        component.set("v.lineasServicioSeleccionadasMarcadas", [value]);
        helper.moveValuesGeneric(component, 'lineas', 'Seleccionadas', 'Disponibles');
    },

    abrirRegistroSalesforce: function(component, event, helper) {
        var tareaId = event.getSource().get("v.value");
        var tareas = component.get("v.tareasMostradas") || [];
        var tarea = tareas.find(t => t.Id === tareaId);
        if (tarea && tarea.UrlTarea) {
            window.open(tarea.UrlTarea, '_blank');
        } else if (tareaId) {
            // Fallback: abre por id si no hay url
            window.open('/' + tareaId, '_blank');
        }
    },
    sortColumn: function(component, event, helper) {
        var campo = event.currentTarget.getAttribute("data-campo");
        var campoOrden = component.get("v.campoOrden");
        var ordenAsc = component.get("v.ordenAsc");

        if (campo === campoOrden) {
            component.set("v.ordenAsc", !ordenAsc);
        } else {
            component.set("v.campoOrden", campo);
            component.set("v.ordenAsc", true);
        }
        helper.ordenarTareas(component);
        helper.actualizarFlechasOrden(component, component.get("v.campoOrden"), component.get("v.ordenAsc"));
    }

})
({
    
obtenerTareas: function(component) {
    const fechaInicio = component.get("v.fechaInicio");
    const fechaFin = component.get("v.fechaFin");
    const filtroEstado = component.get("v.filtroEstado"); // Nuevo filtro

    // Validación de fechas
    if (fechaInicio && fechaFin && fechaInicio > fechaFin) {
        component.set("v.mensajeErrorFecha", "La fecha de inicio no puede ser posterior a la fecha de fin.");
        setTimeout(() => component.set("v.mensajeErrorFecha", ""), 2000);
        return;
    }

    const action = component.get("c.obtenerTareasDelUsuario");
    action.setParams({ fechaInicio, fechaFin, filtroEstado }); // Pasamos el filtro al Apex

    component.set("v.cargando", true);
    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            const tareasRaw = response.getReturnValue();

            if (!tareasRaw || tareasRaw.length === 0) {
                component.set("v.tareas", []);
                component.set("v.tareasMostradas", []);
                component.set("v.mensajeErrorBusqueda", "No hay citas disponibles");
            } else {
                const tareas = tareasRaw.map(t => ({
                    Id: t.Id,
                    Subject: t.Subject,
                    Status: t.Status,
                    Priority: t.Priority,
                    ActivityDate: t.ActivityDate,
                    contactoNombre: t.Contacto,
                    cuentaNombre: t.Cuenta,
                    Tarea_Padre__c: null,
                    expandida: false,
                    iconoExpandir: 'utility:chevronright',
                    mostrarBoton: true,
                    esHija: !!t.Tarea_Padre__c,
                    rowClass: '',
                    detalleColumna: t.Subject || ''
                }));

                component.set("v.tareas", tareas);
                component.set("v.tareasMostradas", tareas);
                component.set("v.mensajeErrorBusqueda", "");
            }
        } else {
            console.error("Error al obtener tareas:", response.getError());
            component.set("v.mensajeErrorBusqueda", "Error al obtener tareas");
        }
        component.set("v.cargando", false);
    });

    $A.enqueueAction(action);
},

    actualizarMensajeFecha: function(component) {
        const inicio = component.get("v.fechaInicio");
        const fin = component.get("v.fechaFin");
        if (inicio && fin && inicio === fin) {
            const hoy = new Date().toISOString().slice(0, 10);
            component.set("v.mensajeFecha", inicio === hoy ? "Tareas para hoy" : `Tareas para el ${inicio}`);
        } else if (inicio && fin) {
            component.set("v.mensajeFecha", `Tareas entre ${inicio} y ${fin}`);
        } else {
            component.set("v.mensajeFecha", "Tareas del período seleccionado");
        }
    },

    // ===============================
    // NUEVO: Cargar valores dinámicos de picklists
    // ===============================
    obtenerPicklists: function(component) {
        const action = component.get("c.obtenerValoresPicklists");
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                const picklists = response.getReturnValue();

                // Transformar líneas de servicio para dualListbox
                const dualListOptions = picklists['Lineas_de_Servicio__c'].map(v => ({ label: v, value: v }));
                picklists['Lineas_de_Servicio__c'] = dualListOptions;

                component.set("v.picklistMap", picklists);

                // Construir listas del dual custom para líneas de servicio
                this.rebuildDualLists(component);
            } else {
                console.error("Error al cargar picklists:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    // ===============================
    // CREAR REUNIÓN (con validación y campos nuevos)
    // ===============================
    crearReunión: function(component) {
        const fecha = component.get("v.fechaReunion");
        const contactos = component.get("v.contactosSeleccionados");
        const cuentaId = component.get("v.cuentaSeleccionada");

        // NUEVO: Campos adicionales
        const subject = component.get("v.subject");
        const prioridad = component.get("v.prioridad");
        const sectorMercado = component.get("v.sectorMercado");
        const lineasServicio = component.get("v.lineasServicio");
        const resumen = component.get("v.resumenEjecutivo");
        const enviadaAgenda = component.get("v.enviadaAgenda");
        const enviadaAcuerdos = component.get("v.enviadaAcuerdos");

        const action = component.get("c.crearReunionConContactos");
        action.setParams({
            fecha: fecha,
            contactoIds: contactos,
            cuentaId: cuentaId,
            subject: subject,
            prioridad: prioridad,
            lineasServicio: (lineasServicio || []).join(';'),
            sectorMercado: sectorMercado,
            description: resumen,
            enviadaAgenda: enviadaAgenda,
            enviadaAcuerdos: enviadaAcuerdos
        });

        component.set("v.cargando", true);
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                $A.get("e.force:showToast").setParams({
                    title: "Visita creada",
                    message: "Se ha creado la visita y las tareas correctamente.",
                    type: "success"
                }).fire();

                // Limpiar campos excepto prioridad y sectorMercado
                const limpiar = [
                    "fechaReunion","horaReunion","horaFinReunion","contactosSeleccionados","cuentaSeleccionada",
                    "busquedaCuenta","subject","lineasServicio","resumenEjecutivo"
                ];
                limpiar.forEach(c => component.set("v."+c, (c==="lineasServicio"||c==="contactosSeleccionados")?[]:null));
                
                // ✅ Resetear prioridad y sector de mercado
                component.set("v.prioridad", "Normal");
                component.set("v.sectorMercado", "");
                
                // Resetear checkboxes y otros
                component.set("v.enviadaAgenda", false);
                component.set("v.enviadaAcuerdos", false);
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarDualListbox", false);

                // Reset dual custom
                component.set("v.lineasServicioDisponibles", (component.get("v.picklistMap.Lineas_de_Servicio__c")||[]).map(o=>({label:o.label,value:o.value,marked:false})));
                component.set("v.lineasServicioSeleccionadasDetalles", []);
                component.set("v.lineasServicioDisponiblesSeleccionadas", []);
                component.set("v.lineasServicioSeleccionadasMarcadas", []);

            } else {
                const error = response.getError();
                component.set("v.mensajeErrorFechaReunion", error && error[0] ? error[0].message : "Error inesperado.");
                setTimeout(() => component.set("v.mensajeErrorFechaReunion", ""), 2000);
            }
            component.set("v.cargando", false);
        });

        $A.enqueueAction(action);
    },

    // ===============================
    // Cargar contactos por cuenta
    // ===============================
    cargarContactos: function(component, cuentaId) {
        const action = component.get("c.obtenerContactosDeCuenta");
        action.setParams({ cuentaId });
    
        component.set("v.cargando", true);
    
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                const contactos = response.getReturnValue() || [];

                // Guardar opciones y mostrar sección
                component.set("v.opcionesContactos", contactos);
                component.set("v.mostrarDualListbox", contactos.length > 0);

                // Construir listas del dual custom para contactos
                const disponibles = contactos.map(c => ({ label: c.label, value: c.value, marked: false }));
                component.set("v.contactosDisponibles", disponibles);
                component.set("v.contactosSeleccionadosDetalles", []);
                component.set("v.contactosDisponiblesSeleccionados", []);
                component.set("v.contactosSeleccionadosMarcados", []);

                // Limpiar valor final
                component.set("v.contactosSeleccionados", []);
            } else {
                console.error("Error al cargar contactos:", response.getError());
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarDualListbox", false);
                component.set("v.contactosDisponibles", []);
                component.set("v.contactosSeleccionadosDetalles", []);
            }
    
            component.set("v.cargando", false);
        });
    
        $A.enqueueAction(action);
    },

    // ===============================
    // NUEVO: reconstruir listas UI para Líneas de Servicio
    // ===============================
    rebuildDualLists: function(component) {
        const opciones = component.get("v.picklistMap.Lineas_de_Servicio__c") || [];
        const seleccionadasValores = new Set(component.get("v.lineasServicio") || []);

        // Particionar opciones entre disponibles y seleccionadas
        const disponibles = [];
        const seleccionadas = [];
        opciones.forEach(op => {
            const base = { label: op.label, value: op.value, marked: false };
            if (seleccionadasValores.has(op.value)) {
                seleccionadas.push(base);
            } else {
                disponibles.push(base);
            }
        });

        component.set("v.lineasServicioDisponibles", disponibles);
        component.set("v.lineasServicioSeleccionadasDetalles", seleccionadas);
        component.set("v.lineasServicioDisponiblesSeleccionadas", []);
        component.set("v.lineasServicioSeleccionadasMarcadas", []);
    },

    // ===============================
    // UTILIDADES GENERALES DUAL CUSTOM
    // ===============================
    toggleMarcado: function(component, event, marcadoAttr, listaAttr) {
        const value = event.currentTarget.dataset.value;
        let marcados = new Set(component.get("v."+marcadoAttr) || []);
        if (marcados.has(value)) {
            marcados.delete(value);
        } else {
            marcados.add(value);
        }
        const nuevosMarcados = Array.from(marcados);
        component.set("v."+marcadoAttr, nuevosMarcados);

        const lista = (component.get("v."+listaAttr) || []).slice(0);
        for (let i = 0; i < lista.length; i++) {
            lista[i].marked = marcados.has(lista[i].value);
        }
        component.set("v."+listaAttr, lista);
    },

    moveValuesGeneric: function(component, tipo, origen, destino) {
        // tipo: 'lineas' | 'contactos'
        if (tipo === 'lineas') {
            var disponibles = (component.get("v.lineasServicioDisponibles") || []).slice(0);
            var seleccionadas = (component.get("v.lineasServicioSeleccionadasDetalles") || []).slice(0);
            const selDisponibles = new Set(component.get("v.lineasServicioDisponiblesSeleccionadas") || []);
            const selSeleccionadas = new Set(component.get("v.lineasServicioSeleccionadasMarcadas") || []);

            if (origen === 'Disponibles' && destino === 'Seleccionadas') {
                const toMove = disponibles.filter(i => selDisponibles.has(i.value)).map(i => ({ label: i.label, value: i.value, marked: false }));
                const restantes = disponibles.filter(i => !selDisponibles.has(i.value));
                const nuevasSel = seleccionadas.concat(toMove);
                component.set("v.lineasServicioDisponibles", restantes);
                component.set("v.lineasServicioSeleccionadasDetalles", nuevasSel);
                component.set("v.lineasServicioDisponiblesSeleccionadas", []);
                component.set("v.lineasServicio", nuevasSel.map(i => i.value));
            } else if (origen === 'Seleccionadas' && destino === 'Disponibles') {
                const toMove = seleccionadas.filter(i => selSeleccionadas.has(i.value)).map(i => ({ label: i.label, value: i.value, marked: false }));
                const restantes = seleccionadas.filter(i => !selSeleccionadas.has(i.value));
                const nuevasDisp = disponibles.concat(toMove);
                component.set("v.lineasServicioSeleccionadasDetalles", restantes);
                component.set("v.lineasServicioDisponibles", nuevasDisp);
                component.set("v.lineasServicioSeleccionadasMarcadas", []);
                component.set("v.lineasServicio", restantes.map(i => i.value));
            }
        } else if (tipo === 'contactos') {
            var disponiblesC = (component.get("v.contactosDisponibles") || []).slice(0);
            var seleccionadasC = (component.get("v.contactosSeleccionadosDetalles") || []).slice(0);
            const selDispC = new Set(component.get("v.contactosDisponiblesSeleccionados") || []);
            const selSelC = new Set(component.get("v.contactosSeleccionadosMarcados") || []);

            if (origen === 'Disponibles' && destino === 'Seleccionadas') {
                const toMove = disponiblesC.filter(i => selDispC.has(i.value)).map(i => ({ label: i.label, value: i.value, marked: false }));
                const restantes = disponiblesC.filter(i => !selDispC.has(i.value));
                const nuevasSel = seleccionadasC.concat(toMove);
                component.set("v.contactosDisponibles", restantes);
                component.set("v.contactosSeleccionadosDetalles", nuevasSel);
                component.set("v.contactosDisponiblesSeleccionados", []);
                component.set("v.contactosSeleccionados", nuevasSel.map(i => i.value));
            } else if (origen === 'Seleccionadas' && destino === 'Disponibles') {
                const toMove = seleccionadasC.filter(i => selSelC.has(i.value)).map(i => ({ label: i.label, value: i.value, marked: false }));
                const restantes = seleccionadasC.filter(i => !selSelC.has(i.value));
                const nuevasDisp = disponiblesC.concat(toMove);
                component.set("v.contactosSeleccionadosDetalles", restantes);
                component.set("v.contactosDisponibles", nuevasDisp);
                component.set("v.contactosSeleccionadosMarcados", []);
                component.set("v.contactosSeleccionados", restantes.map(i => i.value));
            }
        }
    },

    // ===============================
    // Función para expandir/colapsar hijas
    // ===============================
    obtenerHijasDeTarea: function(component, tareaPadreId) {
        const tareasExpandidas = component.get("v.tareasExpandidas") || [];
        const tareasBase = component.get("v.tareas") || [];
        let hijasCache = component.get("v.hijasCache") || {};
        let tareasMostradas = [];

        const yaExpandida = tareasExpandidas.includes(tareaPadreId);

        if (yaExpandida) {
            const nuevasExpandidas = tareasExpandidas.filter(id => id !== tareaPadreId);
            component.set("v.tareasExpandidas", nuevasExpandidas);

            nuevasExpandidas.forEach(id => {
                if (!hijasCache[id]) {
                    hijasCache[id] = [];
                }
            });
            component.set("v.hijasCache", hijasCache);

            tareasBase.forEach(tarea => {
                tareasMostradas.push(tarea);
                if (nuevasExpandidas.includes(tarea.Id) && hijasCache[tarea.Id]) {
                    tareasMostradas.push(...hijasCache[tarea.Id]);
                }
            });

            const tareasBaseActualizadas = tareasBase.map(t => {
                if (t.Id === tareaPadreId) {
                    t.expandida = false;
                    t.iconoExpandir = 'utility:chevronright';
                }
                return t;
            });
            component.set("v.tareas", tareasBaseActualizadas);

            component.set("v.tareasMostradas", tareasMostradas);

            return;
        }

        const action = component.get("c.obtenerTareasHijas");
        action.setParams({ tareaPadreId });
        component.set("v.cargando", true);

        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                const hijasNuevas = response.getReturnValue().map(t => ({
                    Id: t.Id,
                    Subject: t.Subject,
                    Status: t.Status,
                    Priority: t.Priority,
                    ActivityDate: t.ActivityDate,
                    contactoNombre: t.Who && t.Who.Name ? t.Who.Name : '',
                    cuentaNombre: t.What && t.What.Name ? t.What.Name : '',
                    Tarea_Padre__c: t.Tarea_Padre__c,
                    expandida: false,
                    iconoExpandir: 'utility:chevronright',
                    esHija: !!t.Tarea_Padre__c,
                    rowClass: 'tarea-hija',
                    detalleColumna: t.Who && t.Who.Name ? t.Who.Name : 'Sin contacto'
                }));
            	console.log('Primer contacto:', hijasNuevas[0].contactoNombre);
                hijasCache[tareaPadreId] = hijasNuevas;
                component.set("v.hijasCache", hijasCache);

                const nuevasExpandidas = [...tareasExpandidas, tareaPadreId];
                component.set("v.tareasExpandidas", nuevasExpandidas);

                nuevasExpandidas.forEach(id => {
                    if (!hijasCache[id]) {
                        hijasCache[id] = [];
                    }
                });

                tareasMostradas = [];
                tareasBase.forEach(tarea => {
                    tareasMostradas.push(tarea);
                    if (nuevasExpandidas.includes(tarea.Id) && hijasCache[tarea.Id]) {
                        tareasMostradas.push(...hijasCache[tarea.Id]);
                    }
                });

                const tareasBaseActualizadas = tareasBase.map(t => {
                    if (t.Id === tareaPadreId) {
                        t.expandida = true;
                        t.iconoExpandir = 'utility:chevrondown';
                    }
                    return t;
                });
                component.set("v.tareas", tareasBaseActualizadas);

                component.set("v.tareasMostradas", tareasMostradas);
            } else {
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    message: "Error al obtener tareas hijas.",
                    type: "error"
                }).fire();
            console.error("Error al obtener hijas:", response.getError());
        }
        component.set("v.cargando", false);
    });

        $A.enqueueAction(action);
    },

    crearTareaParaActualizar: function(tareaOriginal, borrador, esPadre) {
      
        return {
            Id: tareaOriginal.Id,
            Subject: borrador.Subject !== undefined ? borrador.Subject : tareaOriginal.Subject,
            Status: borrador.Status !== undefined ? borrador.Status : tareaOriginal.Status,
            ActivityDate: borrador.ActivityDate,
            esPadre: esPadre ? 'true' : 'false'
        };
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
    },

    abrirEditorDeTarea: function(component, tareaId, helper) {
        $A.createComponent(
            "c:EditarTareaOutlook",
            { tareaId: tareaId },
            function(modalContent, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.find("overlayLib").showCustomModal({
                        body: modalContent,
                        showCloseButton: true,
                        cssClass: "slds-modal_medium",
                        closeCallback: $A.getCallback(function() {
                            helper.obtenerTareas(component);
                        })
                    });
                } else {
                    console.error("Error al crear componente EditorTarea:", errorMessage);
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: "No se pudo abrir el editor de tarea.",
                        type: "error"
                    }).fire();
                }
            }
        );
    }
})
({
    
obtenerTareas: function(component) {
    const fechaInicio = component.get("v.fechaInicio");
    const fechaFin = component.get("v.fechaFin");
    const filtroEstado = component.get("v.filtroEstado"); // Nuevo filtro
    const filtroPrioridad = component.get("v.filtroPrioridad");
    const cuentaId = component.get("v.cuentaSeleccionada");

    // Validación de fechas
    if (fechaInicio && fechaFin && fechaInicio > fechaFin) {
        component.set("v.mensajeErrorFecha", "La fecha de inicio no puede ser posterior a la fecha de fin.");
        setTimeout(() => component.set("v.mensajeErrorFecha", ""), 2000);
        return;
    }

    const action = component.get("c.obtenerTareasDelUsuario");
    action.setParams({ fechaInicio, fechaFin, filtroEstado, filtroPrioridad, cuentaId }); // Pasamos los nuevos filtros al Apex

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
                    WhoId: t.WhoId, // Campo estándar para contacto/lead
                    expandida: false,
                    iconoExpandir: 'utility:chevronright',
                    mostrarBoton: true,
                    rowClass: '',
                    detalleContacto: '' // Para mostrar info del contacto al expandir
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

                // Cargar opciones de prioridad en atributo específico
                component.set("v.opcionesPrioridad", picklists.Priority || []);
                
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
        const contactoId = component.get("v.contactoSeleccionado");
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
            contactoId: contactoId, // Ahora es un solo ID, no una lista
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
                    "fechaReunion","horaReunion","horaFinReunion","contactoSeleccionado","cuentaSeleccionada",
                    "busquedaCuenta","busquedaContacto","subject","lineasServicio","resumenEjecutivo"
                ];
                limpiar.forEach(c => component.set("v."+c, (c==="lineasServicio")?[]:null));
                component.set("v.prioridad", "Normal");
                component.set("v.sectorMercado", "");
                component.set("v.enviadaAgenda", false);
                component.set("v.enviadaAcuerdos", false);
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarResultadosContactos", false);
                // Reset dual custom líneas de servicio
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
                let contactos = response.getReturnValue() || [];
                component.set("v.opcionesContactos", contactos);
                component.set("v.mostrarResultadosContactos", contactos.length > 0);
            } else {
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarResultadosContactos", false);
            }
            component.set("v.cargando", false);
        });
        $A.enqueueAction(action);
    },

    // ===============================
    // NUEVO: Buscar cuentas por nombre
    // ===============================
    buscarCuentas: function(component) {
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
                component.set("v.resultadosCuentas", []);
                component.set("v.mostrarResultados", false);
            }
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
        // Solo para líneas de servicio
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
    },

    // ===============================
    // Función para mostrar/ocultar detalle del contacto
    // ===============================
    toggleDetalleContacto: function(component, tareaId) {
        const tareasExpandidas = component.get("v.tareasExpandidas") || [];
        const tareasBase = component.get("v.tareas") || [];
        let tareasMostradas = [];

        const yaExpandida = tareasExpandidas.includes(tareaId);

        if (yaExpandida) {
            // Colapsar: quitar de expandidas
            const nuevasExpandidas = tareasExpandidas.filter(id => id !== tareaId);
            component.set("v.tareasExpandidas", nuevasExpandidas);

            // Actualizar la tarea base
            const tareasBaseActualizadas = tareasBase.map(t => {
                if (t.Id === tareaId) {
                    t.expandida = false;
                    t.iconoExpandir = 'utility:chevronright';
                    t.detalleContacto = '';
                }
                return t;
            });
            component.set("v.tareas", tareasBaseActualizadas);

            // Mostrar solo las tareas base, sin detalles
            tareasMostradas = tareasBaseActualizadas.filter(t => !nuevasExpandidas.includes(t.Id) || !t.expandida);
            
            // Agregar filas de detalle para las que siguen expandidas
            nuevasExpandidas.forEach(expandedId => {
                const tareaExpandida = tareasBaseActualizadas.find(t => t.Id === expandedId);
                if (tareaExpandida && tareaExpandida.expandida) {
                    const indexTarea = tareasMostradas.findIndex(t => t.Id === expandedId);
                    if (indexTarea !== -1) {
                        tareasMostradas.splice(indexTarea + 1, 0, {
                            Id: expandedId + '_detalle',
                            isDetalle: true,
                            detalleContacto: tareaExpandida.detalleContacto,
                            rowClass: 'fila-detalle'
                        });
                    }
                }
            });

        } else {
            // Expandir: agregar a expandidas y obtener info del contacto
            const tarea = tareasBase.find(t => t.Id === tareaId);
            if (!tarea) return;

            const action = component.get("c.obtenerDetalleContacto");
            action.setParams({ tareaId: tareaId });
            component.set("v.cargando", true);

            action.setCallback(this, response => {
                if (response.getState() === "SUCCESS") {
                    const contactoInfo = response.getReturnValue();
                    let detalleTexto = 'Sin contacto relacionado';
                    
                    if (contactoInfo && contactoInfo.Name) {
                        detalleTexto = `Contacto: ${contactoInfo.Name}`;
                        if (contactoInfo.Email) {
                            detalleTexto += ` (${contactoInfo.Email})`;
                        }
                        if (contactoInfo.Phone) {
                            detalleTexto += ` - Tel: ${contactoInfo.Phone}`;
                        }
                    }

                    const nuevasExpandidas = [...tareasExpandidas, tareaId];
                    component.set("v.tareasExpandidas", nuevasExpandidas);

                    // Actualizar la tarea base
                    const tareasBaseActualizadas = tareasBase.map(t => {
                        if (t.Id === tareaId) {
                            t.expandida = true;
                            t.iconoExpandir = 'utility:chevrondown';
                            t.detalleContacto = detalleTexto;
                        }
                        return t;
                    });
                    component.set("v.tareas", tareasBaseActualizadas);

                    // Crear lista con detalles insertados
                    tareasMostradas = [];
                    tareasBaseActualizadas.forEach(tarea => {
                        tareasMostradas.push(tarea);
                        if (nuevasExpandidas.includes(tarea.Id) && tarea.expandida) {
                            tareasMostradas.push({
                                Id: tarea.Id + '_detalle',
                                isDetalle: true,
                                detalleContacto: tarea.detalleContacto,
                                rowClass: 'fila-detalle'
                            });
                        }
                    });

                } else {
                    console.error("Error al obtener detalle del contacto:", response.getError());
                    // Mostrar detalle por defecto en caso de error
                    const nuevasExpandidas = [...tareasExpandidas, tareaId];
                    component.set("v.tareasExpandidas", nuevasExpandidas);

                    const tareasBaseActualizadas = tareasBase.map(t => {
                        if (t.Id === tareaId) {
                            t.expandida = true;
                            t.iconoExpandir = 'utility:chevrondown';
                            t.detalleContacto = 'Sin contacto relacionado';
                        }
                        return t;
                    });
                    component.set("v.tareas", tareasBaseActualizadas);

                    tareasMostradas = [];
                    tareasBaseActualizadas.forEach(tarea => {
                        tareasMostradas.push(tarea);
                        if (nuevasExpandidas.includes(tarea.Id) && tarea.expandida) {
                            tareasMostradas.push({
                                Id: tarea.Id + '_detalle',
                                isDetalle: true,
                                detalleContacto: tarea.detalleContacto,
                                rowClass: 'fila-detalle'
                            });
                        }
                    });
                }

                component.set("v.tareasMostradas", tareasMostradas);
                component.set("v.cargando", false);
            });

            $A.enqueueAction(action);
            return;
        }

        component.set("v.tareasMostradas", tareasMostradas);
    },

    crearTareaParaActualizar: function(tareaOriginal, borrador) {
      
        return {
            Id: tareaOriginal.Id,
            Subject: borrador.Subject !== undefined ? borrador.Subject : tareaOriginal.Subject,
            Status: borrador.Status !== undefined ? borrador.Status : tareaOriginal.Status,
            ActivityDate: borrador.ActivityDate
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
    },

    ordenarTareas: function(component) {
        var tareasBase = component.get("v.tareas");
        var campo = component.get("v.campoOrden");
        var ordenAsc = component.get("v.ordenAsc");
        var tareasExpandidas = component.get("v.tareasExpandidas") || [];

        if (!campo || !tareasBase) return;

        // Ordenar solo las tareas base (no las filas de detalle)
        tareasBase.sort(function(a, b) {
            var valA = a[campo] ? a[campo].toString().toLowerCase() : "";
            var valB = b[campo] ? b[campo].toString().toLowerCase() : "";

            if (valA < valB) return ordenAsc ? -1 : 1;
            if (valA > valB) return ordenAsc ? 1 : -1;
            return 0;
        });

        // Actualizar la lista base
        component.set("v.tareas", tareasBase);

        // Reconstruir la lista mostrada incluyendo detalles expandidos
        var tareasMostradas = [];
        tareasBase.forEach(function(tarea) {
            tareasMostradas.push(tarea);
            if (tareasExpandidas.includes(tarea.Id) && tarea.expandida) {
                tareasMostradas.push({
                    Id: tarea.Id + '_detalle',
                    isDetalle: true,
                    detalleContacto: tarea.detalleContacto,
                    rowClass: 'fila-detalle'
                });
            }
        });

        component.set("v.tareasMostradas", tareasMostradas);

        // Actualizar flechas
        this.actualizarFlechasOrden(component, campo, ordenAsc);
    },

    actualizarFlechasOrden: function(component, campoActivo, asc) {
        var campos = ['Subject','Status','ActivityDate','Priority','cuentaNombre'];

        campos.forEach(function(c) {
            var icon = component.find('flecha'+(c === 'cuentaNombre' ? 'Cuenta' : c));
            if(icon){
                if(c === campoActivo){
                    // Flecha de columna activa: up o down
                    icon.set('v.iconName', asc ? 'utility:arrowup' : 'utility:arrowdown');
                } else {
                    // Flechas restantes: neutras
                    icon.set('v.iconName', 'utility:arrowneutral');
                }
                icon.set('v.style','display:inline-block;'); // siempre visible
            }
        });
    },

    // Inicializar todas las flechas al cargar el componente
    inicializarFlechas: function(component) {
        var campos = ['Subject','Status','ActivityDate','Priority','cuentaNombre'];
        campos.forEach(function(c) {
            var icon = component.find('flecha'+(c === 'cuentaNombre' ? 'Cuenta' : c));
            if(icon){
                icon.set('v.iconName', 'utility:arrowneutral');
                icon.set('v.style','display:inline-block;');
            }
        });
    }

})
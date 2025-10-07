({
    cargarPicklists: function(component, callback) {
        const action = component.get("c.obtenerPicklists");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                const data = response.getReturnValue();
                console.log("📝 Picklists cargados:", data);
                
                // Ahora data contiene objetos con {label, value} en lugar de strings
                // Para líneas de servicio ya vienen en el formato correcto
                const opcionesLineas = data.Lineas_de_Servicio__c;
                console.log("🔗 Opciones de líneas de servicio:", opcionesLineas);
                
                component.set("v.estadoOpciones", data.Status);
                console.log("🔍 Valores del picklist Status (Estado):", data.Status);
                component.set("v.comoHaIdoOpciones", data.Como_ha_ido__c);
                component.set("v.siguientePasoOpciones", data.Siguiente_Paso__c);
                component.set("v.lineasServicioOpciones", opcionesLineas);
                component.set("v.priorityOpciones", data.Priority);
                component.set("v.organizacionOpciones", data.Organizaci_n__c);
                component.set("v.tipoActividadOpciones", data.Tipo_Actividad_Administrador__c);
                
                // Reconstruir dual list después de cargar las opciones
                this.rebuildDualLists(component, /*preserveMarks*/ false);
                
                // Ejecutar callback si se proporciona
                if (callback && typeof callback === 'function') {
                    callback();
                }
            }
        });
        $A.enqueueAction(action);
    },

    cargarTarea: function(component) {
        const tareaId = component.get("v.tareaId");
        
        // Cargar la tarea
        const actionTarea = component.get("c.obtenerTarea");
        actionTarea.setParams({ tareaId: tareaId });
        actionTarea.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                const tarea = response.getReturnValue();
                console.log("📋 Tarea cargada:", tarea);
                component.set("v.tarea", tarea);
                component.set("v.busquedaCuenta", tarea.What ? tarea.What.Name : '');
                component.set("v.cuentaSeleccionada", tarea.WhatId);
                component.set("v.modoBusquedaCuenta", tarea.WhatId ? false : true);
                
                // Cargar nombre del contacto desde la consulta de la tarea
                component.set("v.nombreContacto", tarea.Who ? tarea.Who.Name : '');
                component.set("v.estadoSeleccionado", tarea.Status);
                
                // Cargar las líneas de servicio con el nuevo método
                this.cargarLineasServicio(component, tareaId);
            }
        });
        $A.enqueueAction(actionTarea);
    },
    
    cargarLineasServicio: function(component, tareaId) {
        const actionLineas = component.get("c.obtenerLineasServicioPorTarea");
        actionLineas.setParams({ tareaId: tareaId });
        actionLineas.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                const resultado = response.getReturnValue();
                console.log("🔗 Líneas de servicio obtenidas del servidor:", resultado);
                
                // Establecer las listas directamente desde el servidor
                const disponibles = resultado.disponibles || [];
                const seleccionadas = resultado.seleccionadas || [];
                
                console.log("   ✅ Configurando dual listbox:");
                console.log("      Disponibles:", disponibles.length, disponibles.map(d => d.label));
                console.log("      Seleccionadas:", seleccionadas.length, seleccionadas.map(s => s.label));
                
                component.set("v.lineasServicioDisponibles", disponibles);
                component.set("v.lineasServicioSeleccionadasDetalles", seleccionadas);
                component.set("v.lineasServicioSeleccionadas", seleccionadas.map(s => s.value));
                component.set("v.lineasServicioDisponiblesSeleccionadas", []);
                component.set("v.lineasServicioSeleccionadasMarcadas", []);
            } else {
                console.error("Error al cargar líneas de servicio:", response.getError());
            }
        });
        $A.enqueueAction(actionLineas);
    },

    guardarTarea: function(component, callback) {
        const tarea = component.get("v.tarea");
        tarea.WhatId = component.get("v.cuentaSeleccionada");
    
        // Asegurar sincronización del multiselect desde UI custom
        const seleccionadas = component.get("v.lineasServicioSeleccionadas") || [];
        tarea.Lineas_de_Servicio__c = seleccionadas.length ? seleccionadas.join(';') : '';
    
        const action = component.get("c.actualizarTarea");
        action.setParams({ t: tarea });
    
        action.setCallback(this, function(response) {
            const state = response.getState();
    
            if (state === "SUCCESS") {
                $A.get("e.force:showToast").setParams({
                    title: "Guardado",
                    message: "La tarea fue actualizada correctamente.",
                    type: "success"
                }).fire();
    
                if (callback) {
                    callback();
                }
            } else {
                const errors = response.getError();
                let mensajeError = "Error inesperado.";
                if (errors && errors[0] && errors[0].message) {
                    mensajeError = errors[0].message;
                }
    
                console.error("Error al actualizar tarea:", errors);
    
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    message: mensajeError,
                    type: "error",
                    mode: "sticky"
                }).fire();
            }
        });
    
        $A.enqueueAction(action);
    },

    cargarContactos: function(component, cuentaId) {
        const action = component.get("c.obtenerContactosDeCuenta");
        action.setParams({ cuentaId });
    
        component.set("v.cargando", true);
    
        action.setCallback(this, response => {
            const state = response.getState();
            
            if (state === "SUCCESS") {
                const contactos = response.getReturnValue() || [];
    
                component.set("v.opcionesContactos", contactos);
                component.set("v.mostrarDualListbox", contactos.length > 0);
            } else {
                console.error("Error al cargar contactos:", response.getError());
                component.set("v.opcionesContactos", []);
                component.set("v.mostrarDualListbox", false);
            }
    
            component.set("v.cargando", false);
        });
    
        $A.enqueueAction(action);
    },

    // -----------------------------
    // NUEVO: reconstruir listas UI con preservación de selección
    // -----------------------------
    rebuildDualLists: function(component, preserveMarks) {
        const opciones = component.get("v.lineasServicioOpciones") || [];
        const seleccionadasValores = new Set(component.get("v.lineasServicioSeleccionadas") || []);

        console.log("🔄 Reconstruyendo dual listbox:");
        console.log("   Opciones disponibles:", opciones.length);
        console.log("   Valores seleccionados:", Array.from(seleccionadasValores));

        // Si no hay opciones aún, no hacer nada
        if (opciones.length === 0) {
            console.log("   ⚠️ No hay opciones disponibles aún");
            return;
        }

        // Si se pide preservar marcas, leer las actuales
        const prevDisp = component.get("v.lineasServicioDisponibles") || [];
        const prevSel = component.get("v.lineasServicioSeleccionadasDetalles") || [];
        const prevMarksDisp = new Set((prevDisp || []).filter(function(i){return i.marked;}).map(function(i){return i.value;}));
        const prevMarksSel = new Set((prevSel || []).filter(function(i){return i.marked;}).map(function(i){return i.value;}));

        // Particionar opciones entre disponibles y seleccionadas
        const disponibles = [];
        const seleccionadas = [];
        opciones.forEach(function(op){
            var base = { label: op.label, value: op.value, marked: false };
            if (seleccionadasValores.has(op.value)) {
                base.marked = preserveMarks && prevMarksSel.has(op.value);
                seleccionadas.push(base);
            } else {
                base.marked = preserveMarks && prevMarksDisp.has(op.value);
                disponibles.push(base);
            }
        });

        console.log("   ✅ Resultado:");
        console.log("      Disponibles:", disponibles.length, disponibles.map(d => d.label));
        console.log("      Seleccionadas:", seleccionadas.length, seleccionadas.map(s => s.label));

        component.set("v.lineasServicioDisponibles", disponibles);
        component.set("v.lineasServicioSeleccionadasDetalles", seleccionadas);
        // Mantener arrays de valores marcados, para no perder estado en UI
        component.set("v.lineasServicioDisponiblesSeleccionadas", preserveMarks ? Array.from(prevMarksDisp) : []);
        component.set("v.lineasServicioSeleccionadasMarcadas", preserveMarks ? Array.from(prevMarksSel) : []);
    },

    // Mover valores seleccionados de un lado a otro
    moveValues: function(component, origen, destino) {
        var disponibles = (component.get("v.lineasServicioDisponibles") || []).slice(0);
        var seleccionadas = (component.get("v.lineasServicioSeleccionadasDetalles") || []).slice(0);
        const selDisponibles = new Set(component.get("v.lineasServicioDisponiblesSeleccionadas") || []);
        const selSeleccionadas = new Set(component.get("v.lineasServicioSeleccionadasMarcadas") || []);

        if (origen === 'Disponibles' && destino === 'Seleccionadas') {
            const toMove = disponibles
                .filter(function(i){ return selDisponibles.has(i.value); })
                .map(function(i){ return { label: i.label, value: i.value, marked: false }; });
            const restantes = disponibles.filter(function(i){ return !selDisponibles.has(i.value); });
            const nuevasSel = seleccionadas.concat(toMove);
            component.set("v.lineasServicioDisponibles", restantes);
            component.set("v.lineasServicioSeleccionadasDetalles", nuevasSel);
            component.set("v.lineasServicioDisponiblesSeleccionadas", []);
            component.set("v.lineasServicioSeleccionadas", nuevasSel.map(function(i){ return i.value; }));
        } else if (origen === 'Seleccionadas' && destino === 'Disponibles') {
            const toMove = seleccionadas
                .filter(function(i){ return selSeleccionadas.has(i.value); })
                .map(function(i){ return { label: i.label, value: i.value, marked: false }; });
            const restantes = seleccionadas.filter(function(i){ return !selSeleccionadas.has(i.value); });
            const nuevasDisp = disponibles.concat(toMove);
            component.set("v.lineasServicioSeleccionadasDetalles", restantes);
            component.set("v.lineasServicioDisponibles", nuevasDisp);
            component.set("v.lineasServicioSeleccionadasMarcadas", []);
            component.set("v.lineasServicioSeleccionadas", restantes.map(function(i){ return i.value; }));
        }
    },

    // Mover todos los valores de un lado a otro
    moveAll: function(component, origen, destino) {
        var disponibles = (component.get("v.lineasServicioDisponibles") || []).slice(0);
        var seleccionadas = (component.get("v.lineasServicioSeleccionadasDetalles") || []).slice(0);

        if (origen === 'Disponibles' && destino === 'Seleccionadas') {
            const nuevasSel = seleccionadas.concat(disponibles.map(function(i){ return { label: i.label, value: i.value, marked: false }; }));
            component.set("v.lineasServicioDisponibles", []);
            component.set("v.lineasServicioSeleccionadasDetalles", nuevasSel);
            component.set("v.lineasServicioSeleccionadas", nuevasSel.map(function(i){ return i.value; }));
            component.set("v.lineasServicioDisponiblesSeleccionadas", []);
        } else if (origen === 'Seleccionadas' && destino === 'Disponibles') {
            const nuevasDisp = disponibles.concat(seleccionadas.map(function(i){ return { label: i.label, value: i.value, marked: false }; }));
            component.set("v.lineasServicioSeleccionadasDetalles", []);
            component.set("v.lineasServicioDisponibles", nuevasDisp);
            component.set("v.lineasServicioSeleccionadas", []);
            component.set("v.lineasServicioSeleccionadasMarcadas", []);
        }
    }
})
({
    // Inicializa el componente cargando las opciones desde Apex
    doInit: function(component, event, helper) {
        var action = component.get("c.valoresCPV");
        action.setParams({ Id_oportunidad: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                let disponibles = [], seleccionados = [];

                if (result && result.opciones) {
                    result.opciones.forEach(function(cpv) {
                        let opt = { label: cpv, value: cpv, seleccionado: false };
                        if (result.valoresSeleccionados && result.valoresSeleccionados.includes(cpv)) {
                            seleccionados.push(opt);
                        } else {
                            disponibles.push(opt);
                        }
                    });
                }

                component.set("v.allCPVOptions", disponibles.concat(seleccionados));
                component.set("v.disponibles", disponibles);
                component.set("v.seleccionados", seleccionados);
                component.set("v.selectedCPVs", seleccionados.map(function(o) { return o.value; }));
                component.set("v.originalSelectedCPVs", seleccionados.map(function(o) { return o.value; }));

                // Verificar si la oportunidad está bloqueada (debe venir en result.oportunidad)
                if (result && result.oportunidad && result.oportunidad.Bloqueo_por_aprobacion__c === true) {
                    component.set("v.bloqueado", true);
                    // dejamos el botón en el estado por defecto (disabled) según si hay cambios:
                    component.set("v.disabledSaveCPV", true);
                } else {
                    component.set("v.bloqueado", false);
                    // desactivamos el botón si no hay cambios
                    helper.checkIfModified(component);
                }
            } else {
                // fallback: mostrar error si no carga correctamente
                var errors = response.getError ? response.getError() : null;
                console.error("Error en doInit:", errors);
                helper.mostrarToast("Error", "Error al cargar CPV.", "error");
            }
        });

        $A.enqueueAction(action);
    },

    toggleSeleccionDisponible: function(component, event, helper) {
        const index = parseInt(event.currentTarget.getAttribute('data-index'), 10);
        const disponibles = component.get("v.disponibles") || [];
        const ctrl = event.ctrlKey;
        const shift = event.shiftKey;
        let ultimo = component.get("v.ultimoIndexDisponible");

        if (shift && ultimo !== -1) {
            const start = Math.min(index, ultimo);
            const end = Math.max(index, ultimo);
            for (let i = 0; i < disponibles.length; i++) {
                disponibles[i].seleccionado = (i >= start && i <= end);
            }
        } else if (ctrl) {
            disponibles[index].seleccionado = !disponibles[index].seleccionado;
            component.set("v.ultimoIndexDisponible", index);
        } else {
            for (let i = 0; i < disponibles.length; i++) {
                disponibles[i].seleccionado = (i === index);
            }
            component.set("v.ultimoIndexDisponible", index);
        }

        component.set("v.disponibles", disponibles);

        // Deseleccionar en la derecha
        helper.clearSelection(component, "seleccionados", "ultimoIndexSeleccionado");
    },

    toggleSeleccionDerecha: function(component, event, helper) {
        const index = parseInt(event.currentTarget.getAttribute('data-index'), 10);
        const seleccionados = component.get("v.seleccionados") || [];
        const ctrl = event.ctrlKey;
        const shift = event.shiftKey;
        let ultimo = component.get("v.ultimoIndexSeleccionado");

        if (shift && ultimo !== -1) {
            const start = Math.min(index, ultimo);
            const end = Math.max(index, ultimo);
            for (let i = 0; i < seleccionados.length; i++) {
                seleccionados[i].seleccionado = (i >= start && i <= end);
            }
        } else if (ctrl) {
            seleccionados[index].seleccionado = !seleccionados[index].seleccionado;
            component.set("v.ultimoIndexSeleccionado", index);
        } else {
            for (let i = 0; i < seleccionados.length; i++) {
                seleccionados[i].seleccionado = (i === index);
            }
            component.set("v.ultimoIndexSeleccionado", index);
        }

        component.set("v.seleccionados", seleccionados);

        // Deseleccionar en la izquierda
        helper.clearSelection(component, "disponibles", "ultimoIndexDisponible");
    },

    moverSeleccionadosMarcados: function(component, event, helper) {
        let disponibles = component.get("v.disponibles") || [];
        let seleccionados = component.get("v.seleccionados") || [];

        const idsMover = disponibles.filter(function(opt) { return opt.seleccionado; }).map(function(opt) { return opt.value; });
        const mover = disponibles.filter(function(opt) { return idsMover.includes(opt.value); }).map(function(opt) {
            opt.seleccionado = false;
            return opt;
        });

        const nuevosDisponibles = disponibles.filter(function(opt) { return !idsMover.includes(opt.value); });
        const nuevosSeleccionados = seleccionados.concat(mover);

        component.set("v.disponibles", nuevosDisponibles);
        component.set("v.seleccionados", nuevosSeleccionados);
        component.set("v.selectedCPVs", nuevosSeleccionados.map(function(o) { return o.value; }));

        helper.checkIfModified(component);
    },

    moverSeleccionadosIzquierda: function(component, event, helper) {
        let disponibles = component.get("v.disponibles") || [];
        let seleccionados = component.get("v.seleccionados") || [];

        const idsMover = seleccionados.filter(function(opt) { return opt.seleccionado; }).map(function(opt) { return opt.value; });
        const mover = seleccionados.filter(function(opt) { return idsMover.includes(opt.value); }).map(function(opt) {
            opt.seleccionado = false;
            return opt;
        });

        const nuevosSeleccionados = seleccionados.filter(function(opt) { return !idsMover.includes(opt.value); });
        const nuevosDisponibles = disponibles.concat(mover);

        component.set("v.disponibles", nuevosDisponibles);
        component.set("v.seleccionados", nuevosSeleccionados);
        component.set("v.selectedCPVs", nuevosSeleccionados.map(function(o) { return o.value; }));

        helper.checkIfModified(component);
    },

    moverASeleccionados: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        let disponibles = component.get("v.disponibles") || [];
        let seleccionados = component.get("v.seleccionados") || [];

        const mover = disponibles.find(function(opt) { return opt.value === id; });
        if (mover) {
            mover.seleccionado = false;
            seleccionados.push(mover);
            disponibles = disponibles.filter(function(opt) { return opt.value !== id; });
        }

        component.set("v.disponibles", disponibles);
        component.set("v.seleccionados", seleccionados);
        component.set("v.selectedCPVs", seleccionados.map(function(o) { return o.value; }));

        helper.checkIfModified(component);
    },

    moverADisponibles: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        let disponibles = component.get("v.disponibles") || [];
        let seleccionados = component.get("v.seleccionados") || [];

        const mover = seleccionados.find(function(opt) { return opt.value === id; });
        if (mover) {
            mover.seleccionado = false;
            disponibles.push(mover);
            seleccionados = seleccionados.filter(function(opt) { return opt.value !== id; });
        }

        component.set("v.disponibles", disponibles);
        component.set("v.seleccionados", seleccionados);
        component.set("v.selectedCPVs", seleccionados.map(function(o) { return o.value; }));

        helper.checkIfModified(component);
    },

    handleSearchChange: function(component) {
        const searchTerm = (component.get("v.searchTerm") || "").toLowerCase();
        const allOptions = component.get("v.allCPVOptions") || [];
        const seleccionados = component.get("v.seleccionados") || [];
        const idsSeleccionados = new Set(seleccionados.map(function(opt) { return opt.value; }));

        const normalize = function(str) { return (str || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase(); };

        const filtrados = allOptions.filter(function(opt) {
            return !idsSeleccionados.has(opt.value) && normalize(opt.label).includes(normalize(searchTerm));
        });

        component.set("v.disponibles", filtrados);
    },

    saveCPV: function(component, event, helper) {
        // Validación de primer nivel: si está bloqueada, mostrar toast y no guardar
        if (component.get("v.bloqueado")) {
            helper.mostrarToast("Acción no permitida", "La oportunidad está bloqueada por aprobación. No puedes modificar ni guardar CPV.", "error");
            return;
        }

        // Si no está bloqueada, continuamos con el guardado normal
        helper.saveCPVOportunidad(component, event, helper);
    },

    toggleSection: function(component, event) {
        const sectionAuraId = event.target.getAttribute("data-auraId");
        const sectionDiv = component.find(sectionAuraId).getElement();
        const isOpen = sectionDiv.className.includes("slds-is-open");

        sectionDiv.setAttribute("class", isOpen ? "slds-section slds-is-close" : "slds-section slds-is-open");
    }
});
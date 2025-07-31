({
    // Inicializa el componente cargando las opciones desde Apex
    doInit: function(component, event, helper) {
        var action = component.get("c.valoresCPV");
        action.setParams({ Id_oportunidad: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                let disponibles = [], seleccionados = [];

                if (result.opciones) {
                    result.opciones.forEach(cpv => {
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
                component.set("v.selectedCPVs", seleccionados.map(o => o.value));
                component.set("v.originalSelectedCPVs", seleccionados.map(o => o.value));
            }
        });

        $A.enqueueAction(action);
    },

    toggleSeleccionDisponible: function(component, event, helper) {
        const index = parseInt(event.currentTarget.getAttribute('data-index'), 10);
        const disponibles = component.get("v.disponibles");
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
        const seleccionados = component.get("v.seleccionados");
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
        let disponibles = component.get("v.disponibles");
        let seleccionados = component.get("v.seleccionados");

        const idsMover = disponibles.filter(opt => opt.seleccionado).map(opt => opt.value);
        const mover = disponibles.filter(opt => idsMover.includes(opt.value)).map(opt => {
            opt.seleccionado = false;
            return opt;
        });

        const nuevosDisponibles = disponibles.filter(opt => !idsMover.includes(opt.value));
        const nuevosSeleccionados = seleccionados.concat(mover);

        component.set("v.disponibles", nuevosDisponibles);
        component.set("v.seleccionados", nuevosSeleccionados);
        component.set("v.selectedCPVs", nuevosSeleccionados.map(o => o.value));

        helper.checkIfModified(component);
    },

    moverSeleccionadosIzquierda: function(component, event, helper) {
        let disponibles = component.get("v.disponibles");
        let seleccionados = component.get("v.seleccionados");

        const idsMover = seleccionados.filter(opt => opt.seleccionado).map(opt => opt.value);
        const mover = seleccionados.filter(opt => idsMover.includes(opt.value)).map(opt => {
            opt.seleccionado = false;
            return opt;
        });

        const nuevosSeleccionados = seleccionados.filter(opt => !idsMover.includes(opt.value));
        const nuevosDisponibles = disponibles.concat(mover);

        component.set("v.disponibles", nuevosDisponibles);
        component.set("v.seleccionados", nuevosSeleccionados);
        component.set("v.selectedCPVs", nuevosSeleccionados.map(o => o.value));

        helper.checkIfModified(component);
    },

    moverASeleccionados: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        let disponibles = component.get("v.disponibles");
        let seleccionados = component.get("v.seleccionados");

        const mover = disponibles.find(opt => opt.value === id);
        if (mover) {
            mover.seleccionado = false;
            seleccionados.push(mover);
            disponibles = disponibles.filter(opt => opt.value !== id);
        }

        component.set("v.disponibles", disponibles);
        component.set("v.seleccionados", seleccionados);
        component.set("v.selectedCPVs", seleccionados.map(o => o.value));

        helper.checkIfModified(component);
    },

    moverADisponibles: function(component, event, helper) {
        const id = event.currentTarget.getAttribute("data-id");
        let disponibles = component.get("v.disponibles");
        let seleccionados = component.get("v.seleccionados");

        const mover = seleccionados.find(opt => opt.value === id);
        if (mover) {
            mover.seleccionado = false;
            disponibles.push(mover);
            seleccionados = seleccionados.filter(opt => opt.value !== id);
        }

        component.set("v.disponibles", disponibles);
        component.set("v.seleccionados", seleccionados);
        component.set("v.selectedCPVs", seleccionados.map(o => o.value));

        helper.checkIfModified(component);
    },

    handleSearchChange: function(component) {
        const searchTerm = component.get("v.searchTerm").toLowerCase();
        const allOptions = component.get("v.allCPVOptions");
        const seleccionados = component.get("v.seleccionados");
        const idsSeleccionados = new Set(seleccionados.map(opt => opt.value));

        const normalize = str => str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

        const filtrados = allOptions.filter(opt =>
            !idsSeleccionados.has(opt.value) &&
            normalize(opt.label).includes(normalize(searchTerm))
        );

        component.set("v.disponibles", filtrados);
    },

    saveCPV: function(component, event, helper) {
        helper.saveCPVOportunidad(component, event, helper);

        // Actualiza lista original
        component.set("v.originalSelectedCPVs", component.get("v.selectedCPVs"));
        component.set("v.disabledSaveCPV", true);
    },

    toggleSection: function(component, event) {
        const sectionAuraId = event.target.getAttribute("data-auraId");
        const sectionDiv = component.find(sectionAuraId).getElement();
        const isOpen = sectionDiv.className.includes("slds-is-open");

        sectionDiv.setAttribute("class", isOpen ? "slds-section slds-is-close" : "slds-section slds-is-open");
    }
});
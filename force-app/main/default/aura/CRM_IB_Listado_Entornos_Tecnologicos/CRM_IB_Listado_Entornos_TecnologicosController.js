({
    // al inicializar
    doInit: function(component, event, helper) {
        console.log('doInit CRM_IB_Listado_Entornos_Tecnologicos: ' + component.get("v.recordId"));
        helper.getEntornosTecnologicos(component);
        component.set ("v.disabledSave", true); // deshabilita el botón de guardar al inicio       
    },

    // buscador
    handleSearch: function(component, event, helper) {
        
		var buscador = component.get("v.buscador"); // valor introducido en el buscador
        
        var action = component.get("c.getEntornosTecnologicos"); // método getEntornosTecnologicos de la clase apex CRM_IB_Listado_Entornos_Tecnologicos
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                var result = response.getReturnValue(); // el método getEntornosTecnologicos devuelve tanto las opciones disponibles como los valores ya seleccionados
                var opciones = result.opciones;
                var valoresSeleccionados = component.get("v.selectedValues"); // valores seleccionados ya previamente
                
                // filtrar las opciones disponibles según el buscador
                var opcionesFiltradas = opciones.filter(function(option) {
                    return option.toLowerCase().includes(buscador.toLowerCase()); // se aplica el filtro
                });
                
                // formatea las opciones ya filtradas para el dualListbox (label-value)
                var items = opcionesFiltradas.map(function(item) {
                    return { "label": item, "value": item };
                });

                // combinamos las opciones filtradas con los valores ya seleccionados
                var itemsConSeleccionados = items.concat(valoresSeleccionados.map(function(selectedValue) {
                    return { "label": selectedValue, "value": selectedValue };
                }));
                
                // estabelce las opciones actualizadas
                component.set("v.options", itemsConSeleccionados);
                component.set("v.selectedValues", valoresSeleccionados);

            } else {
                console.error("Se ha producido un error: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    // si hay cambios (selección)
    handleChange: function(component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedValues", selectedValues); // actualiza los valores seleccionados
        //component.set("v.buscador", ""); // se limpia el campo de búsqueda
        component.set ("v.disabledSave", false); // habilita el botón si hay cambios
    },
    
    // al guardar
    handleSave: function(component, event, helper) {
        helper.saveEntornosTecnologicos(component); // los valores seleccionados se van a guardan desde el helper
        component.set ("v.disabledSave", true); // se deshabilita el botón una vez guardados los cambios
        component.set("v.buscador", ""); // se limpia el campo de búsqueda
        helper.getEntornosTecnologicos(component);
    },
    
	// para el formato de sección
    toggleSection: function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
         
        // -1 open/close section
        if (sectionState == -1) {
            sectionDiv.setAttribute('class', 'slds-section slds-is-open');
        } else {
            sectionDiv.setAttribute('class', 'slds-section slds-is-close');
        }
    }
})
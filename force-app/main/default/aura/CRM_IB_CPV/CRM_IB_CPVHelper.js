({
    saveCPVOportunidad: function(component, event, helper) {
        const selectedCPVs = component.get("v.selectedCPVs");
        const oportunidadId = component.get("v.recordId");
        
        if (!oportunidadId) {
            helper.mostrarToast("Advertencia", "No se ha encontrado la oportunidad.", "warning");
            return;
        }
        
        const seleccionCPV = selectedCPVs.join(';'); // convertir lista a string separada por ;
        
        const action = component.get("c.saveOportunidad_CPV");
        action.setParams({
            Id_oportunidad: oportunidadId,
            seleccionCPV: seleccionCPV
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                helper.mostrarToast("Éxito", "Los valores CPV se han guardado correctamente.", "success");
                component.set("v.originalSelectedCPVs", component.get("v.selectedCPVs"));

            } else {
                const error = response.getError();
                console.error("Error al guardar CPVs:", error);
                helper.mostrarToast("Error", "Error al guardar los valores CPV.", "error");
            }
        });
        component.set("v.disabledSaveCPV", true);
        $A.enqueueAction(action);
    },
    
    
    mostrarToast: function(titulo, mensaje, tipo) {
        const toast = $A.get("e.force:showToast");
        if (toast) {
            toast.setParams({
                title: titulo,
                message: mensaje,
                type: tipo,
                mode: "dismissible"
            });
            toast.fire();
        } else {
            alert(mensaje); // fallback
        }
    },
    // Compara la lista actual con la original y activa o desactiva el botón de guardar
    checkIfModified: function(component) {
        const current = component.get("v.selectedCPVs");
        const original = component.get("v.originalSelectedCPVs");
        
        if (current.length !== original.length) {
            component.set("v.disabledSaveCPV", false);
            return;
        }
        
        const currentSorted = [...current].sort();
        const originalSorted = [...original].sort();
        
        const isSame = currentSorted.every((val, index) => val === originalSorted[index]);
        component.set("v.disabledSaveCPV", isSame);
    },
    
    // Deselecciona todos los elementos de una lista (usado al hacer selección cruzada)
    clearSelection: function(component, listName, lastIndexName) {
        let lista = component.get("v." + listName);
        lista.forEach(e => e.seleccionado = false);
        component.set("v." + listName, lista);
        component.set("v." + lastIndexName, -1);
    }
    
});
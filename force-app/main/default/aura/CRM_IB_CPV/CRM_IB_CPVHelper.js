({
    saveCPVOportunidad: function(component, event, helper) {
        // Segunda comprobación por seguridad: no llamar al servidor si está bloqueada
        if (component.get("v.bloqueado")) {
            helper.mostrarToast("Acción no permitida", "La oportunidad está bloqueada por aprobación. No puedes modificar ni guardar CPV.", "error");
            return;
        }

        const selectedCPVs = component.get("v.selectedCPVs") || [];
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
                component.set("v.originalSelectedCPVs", component.get("v.selectedCPVs") || []);
                component.set("v.disabledSaveCPV", true);
            } else {
                const error = response.getError ? response.getError() : null;
                console.error("Error al guardar CPVs:", error);

                // Si el servidor devuelve un mensaje conocido, intentamos pasarlo al usuario
                let mensaje = "Error al guardar los valores CPV.";
                if (error && error.length && error[0].message) {
                    mensaje = error[0].message;
                }

                helper.mostrarToast("Error", mensaje, "error");
                // dejar disabledSaveCPV = false para permitir reintentos
                component.set("v.disabledSaveCPV", false);
            }
        });

        // desactivar el botón momentáneamente para evitar dobles envíos hasta recibir respuesta
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
            // fallback
            alert(mensaje);
        }
    },

    // Compara la lista actual con la original y activa o desactiva el botón de guardar
    checkIfModified: function(component) {
        const current = component.get("v.selectedCPVs") || [];
        const original = component.get("v.originalSelectedCPVs") || [];

        if (!Array.isArray(current) || !Array.isArray(original)) {
            component.set("v.disabledSaveCPV", true);
            return;
        }

        if (current.length !== original.length) {
            component.set("v.disabledSaveCPV", false);
            return;
        }

        // comparar ordenado
        const currentSorted = current.slice().sort();
        const originalSorted = original.slice().sort();

        const isSame = currentSorted.every(function(val, index) { return val === originalSorted[index]; });
        component.set("v.disabledSaveCPV", isSame);
    },

    // Deselecciona todos los elementos de una lista (usado al hacer selección cruzada)
    clearSelection: function(component, listName, lastIndexName) {
        let lista = component.get("v." + listName) || [];
        lista.forEach(function(e) { e.seleccionado = false; });
        component.set("v." + listName, lista);
        component.set("v." + lastIndexName, -1);
    }
});
({
    // helper para obtener los entornos tecnológicos
	getEntornosTecnologicos: function(component) {
        var action = component.get("c.getEntornosTecnologicos"); // método getEntornosTecnologicos de la clase apex CRM_IB_Listado_Entornos_Tecnologicos
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue(); // el método getEntornosTecnologicos devuelve tanto las opciones disponibles como los valores ya seleccionados
                var opciones = result.opciones;
                var valoresSeleccionados = result.valoresSeleccionados;
                
                // formatea las opciones para el dualListbox (label-value)
                var items = [];
                for (var i = 0; i < opciones.length; i++) {
                    var item = {
                        "label": opciones[i],
                        "value": opciones[i]
                    };
                    items.push(item);
                }
                component.set("v.options", items);
                
                // configura los valores ya seleccionados
                if (valoresSeleccionados) {
                    component.set("v.selectedValues", valoresSeleccionados);
                }

            } else {
                console.error("Se ha producido un error: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
	// helper para guardar los entornos tecnológicos seleccionados
    saveEntornosTecnologicos: function(component) {
        var selectedValues = component.get("v.selectedValues");
        var recordId = component.get("v.recordId");

        var action = component.get("c.saveEntornosTecnologicos"); // método saveEntornosTecnologicos de la clase apex CRM_IB_Listado_Entornos_Tecnologicos
        action.setParams({
            recordId: recordId,
            seleccionEntornoTecnologico: selectedValues.join(';')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Entornos tecnológicos guardados correctamente."); 
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Éxito',
                    'message': 'Se ha actualizado correctamente',
                    'type': 'success',
                    'mode': 'dismissible',
                    'duration': 1000
                });
                showToast.fire();
                //setTimeout(function() { window.location.reload(); }, 2000);
                //$A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            } else {
                console.error("Error en saveEntornosTecnologicos: " + response.getError());
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Error',
                    'message': 'No se pudieron guardar los entornos tecnológicos. ' + result,
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 11000
                });
                showToast.fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})
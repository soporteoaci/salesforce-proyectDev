({
    GuardarEmpleado: function(component) {
        console.log("GuardarEmpleado");

        // valores del otro usuario
        var nombre = component.get("v.EmpleadoNombre");
        console.log("ResponsableProyecto nombre -> ", nombre);
        var email = component.get("v.EmpleadoEmail");
        console.log("ResponsableProyecto email -> ", email);
        var codigo = component.get("v.EmpleadoCodigo");
        console.log("ResponsableProyecto codigo -> ", codigo);
        
        // validación datos empleado
        if (!nombre || !email) {
            console.error("Error de datos: nombre y email son obligatorios");
            this.showError(component, "Nombre y Email son obligatorios");
            return;
        }
        if (email.indexOf('@') === -1 || email.indexOf('.') === -1) {
            console.error("Error de datos: email sin formato correcto");
            this.showError(component, "Escriba el email con un formato adecuado");
            return;
        }

        // texto concatenado
        var responsableProyecto = nombre;
        if (codigo) {
            responsableProyecto += " (" + codigo + ")";
        }
        responsableProyecto += " - " + email;
        console.log("ResponsableProyecto concat -> ", responsableProyecto);

        // Id oportunidad
        var idOpp = component.get("v.recordId");
        if (!idOpp) {
            console.error("No se encontró la oportunidad");
            return;
        }

        // método Apex
        var action = component.get("c.actualizarOportunidad");
        action.setParams({
            oppId: idOpp,
            responsable: responsableProyecto
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Se ha actualizado la oportunidad");
                component.find("ResponsableProyecto").set("v.value", responsableProyecto);
            } else {
                console.error("Error al actualizar la oportunidad", response.getError());
                this.showError(component, "Error al actualizar la oportunidad: " + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
        
        // cierre
        $A.util.toggleClass(component.find("modal"), 'slds-hidden');
        $A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');
        $A.util.removeClass(component.find("ShowEmpleadoCliente"), "slds-hidden");
    },
    
    showError: function(component, errorMessage) {
        var notification = $A.get("e.force:showToast");
        notification.setParams({
            "title": "Error",
            "message": errorMessage,
            "type": "error",
            "mode": "dismissible"
        });
        notification.fire();
    }
    
})
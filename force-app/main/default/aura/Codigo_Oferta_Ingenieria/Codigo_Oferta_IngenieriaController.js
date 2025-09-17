({
    doInit : function(component, event, helper) {
        // pdte
    },
    
    enviarCorreo : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        let action = component.get("c.enviarCorreoOferta");
        action.setParams({
            oportunidadId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (result === "OK") {
                    // éxito
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Éxito",
                        message: "El correo ha sido enviado correctamente.",
                        type: "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    // error de apex
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: result,
                        type: "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            } else {
                // error callback
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "Hubo un problema al enviar el correo.",
                    type: "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})
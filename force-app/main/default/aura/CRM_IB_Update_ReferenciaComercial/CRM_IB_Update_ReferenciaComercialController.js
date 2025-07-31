({
    doInit : function(component, event, helper) {
        var idReferencia=component.get("v.recordId"); 
        var action = component.get("c.update_referencia_comercial");
        action.setParams({ 
            'Id_ref' : idReferencia
            
        });
        action.setCallback(this, function(response) {
            component.set("v.Estado", "En proceso");
             $A.util.removeClass(component.find("spinnerModal"), "slds-hide");
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                 setTimeout(function() { window.location.reload(); }, 4000);
                   // $A.get("e.force:closeQuickAction").fire();               
            }
        });        
        $A.enqueueAction(action);
    }
})
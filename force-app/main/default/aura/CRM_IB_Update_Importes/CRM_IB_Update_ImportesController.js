({
    doInit : function(component, event, helper) {
        var idOportunidad=component.get("v.recordId"); 
        var action = component.get("c.recalcularImportesOportunidad");
        action.setParams({ 
            'idOportunidad' : idOportunidad,
            'dmlaction'		: true
        });
        action.setCallback(this, function(response) {
            component.set("v.Estado", "En proceso");
             $A.util.removeClass(component.find("spinnerModal"), "slds-hide");
             setTimeout(function() { window.location.reload(); }, 4000);
           /* var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                 setTimeout(function() { window.location.reload(); }, 4000);
                   // $A.get("e.force:closeQuickAction").fire();               
            }*/
        });        
        $A.enqueueAction(action);
    }
})
({
    doInit: function(component, event, helper) {
        console.log('ENTRO');
        
    },
    accept: function(component, event, helper) {
        
        var idObj=component.get("v.recordId"); 
        var action = component.get("c.superPreventaObjetivo");
        component.set("v.Spinner", true);
        action.setParams({ 
            'idObj' : idObj,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                window.open(response, '_blank').focus();                
            }
        });        
        $A.enqueueAction(action);
    },
    reject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
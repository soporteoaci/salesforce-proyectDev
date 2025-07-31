({
    doInit: function(component, event, helper) {
        console.log('ENTRO');
        
    },
    accept: function(component, event, helper) {
        var idMaestro=component.get("v.recordId"); 
        var action = component.get("c.actualizarOpp");
        component.set("v.Spinner", true);
        action.setParams({ 
            'idMaestro' : idMaestro,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                if(response === 'OK'){
                    component.set("v.Spinner", false);
                    console.log('SUCCESSSS');
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Maestro SUPER',
                        'message': 'Se ha realizado la actualización correctamente.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 6000
                    });
                    showToast.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    console.log('Response: ' + response);                   
                }else{
                    component.set("v.Spinner", false);
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Maestro SUPER',
                        'message': 'Error al realizar la actualización. ' + response,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 8000
                    });
                    showToast.fire();
                    $A.get("e.force:closeQuickAction").fire();                    
                    $A.get('e.force:refreshView').fire();
                }
            }else{
                component.set("v.Spinner", false);
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Maestro SUPER',
                    'message': 'Error al realizar la actualización. ' + response,
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 10000
                });
                showToast.fire();
                $A.get("e.force:closeQuickAction").fire();
                console.log('Response: ' + response); 
            }
        });        
        $A.enqueueAction(action);
        
    },
    reject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
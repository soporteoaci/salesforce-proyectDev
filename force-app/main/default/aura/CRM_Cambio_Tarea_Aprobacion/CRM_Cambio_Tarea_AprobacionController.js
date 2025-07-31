({
    doInit: function(component, event, helper) {
        console.log('ENTRO en doinit Cambio Tarea');
        
        var idOpp=component.get("v.recordId"); 
        var action = component.get("c.doinit");
        action.setParams({ 
            'idTarea' : idOpp,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            
            console.log('state: ' + state);
            console.log('response: ' + response);
            
            if (state === "SUCCESS") {
                console.log('response: '+ response);
                //mostrar_mensaje
                if (response == true){
                    console.log('No coinciden propietarios');
                    component.set("v.Mensaje_informar",true);
                    component.set("v.Seccion_Actualizar",false);
                    
                    
                }else{
                    console.log('coinciden propietarios');
                    component.set("v.Mensaje_informar",false);
                    component.set("v.Seccion_Actualizar",true);
                    
                    
                }
                
            }else{
                
            }
        });        
        $A.enqueueAction(action);
        
        
    },
    accept: function(component, event, helper) {
        
        var idTarea=component.get("v.recordId"); 
        var action = component.get("c.actualizar_decision");
        component.set("v.Spinner", true);
        action.setParams({ 
            'idTarea' : idTarea,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                console.log('Actualiza decision y recarga la página');
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Valores actualizados',
                    'message': 'Se ha guardado correctamente.',
                    'type': 'success',
                    'mode': 'dismissible',
                    'duration': 15000
                });
                showToast.fire(); 
                
                setTimeout(function() { window.location.reload(); }, 4000);
                
            }else{
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Error al guardar',
                    'message': 'No se ha podido guardar correctamente. ' + result,
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 11000
                });
                showToast.fire();
            }
        });        
        $A.enqueueAction(action);
    },
    reject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
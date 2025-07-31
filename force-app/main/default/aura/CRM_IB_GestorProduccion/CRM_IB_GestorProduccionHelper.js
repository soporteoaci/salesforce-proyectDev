({
    saveOpp : function(component,event,helper) {
        
        
        console.log('Entramos en Save helper');
        
        //  var selectOrg=  component.find('select_Org').get('v.value');
        
        var action=component.get("c.saveOpp");
        var Gestor_Produccion = component.find('select_GP').get('v.value')
        
        action.setParams({ 
            CR : component.find('select_CR').get('v.value'),
            GP : Gestor_Produccion,
            // Org: component.find('select_Org').get('v.value'),
            oppId : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('RESPONSEEE: '+ response);
            var result = response.getReturnValue();
            
            console.log('STATEEE: '+ state);
            if(result.length < 20){
                if(state == "SUCCESS"){
                    
                    //component.set("v.Organizacion_name",result);
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valores actualizados',
                        'message': 'Se ha guardado correctamente.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                    
                    setTimeout(function() { window.location.reload(); }, 2000);
                    $A.get("e.force:closeQuickAction").fire();
                    
                    
                }else  {
                    component.set("v.mensaje", "Se ha producido un error");
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
            }else{
                component.set("v.mensaje", "Se ha producido un error");
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Error al guardar',
                    'message': 'No se ha podido guardar correctamente. ' + result,
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 11000
                });
                showToast.fire();
                //window.location.reload();
                // $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
    }
    
})
({
    saveOpp : function(component,event,helper) {
        console.log('Entramos en Save helper CRM_CentroResponsabilidad');

        var action=component.get("c.saveOpp");
        var Gestor_Produccion = component.get("v.GP_elegido");
        var Centro_Responsabilidad = component.get("v.CR_elegido"); 
        var idOpp =component.get("v.idOppPreventa");        
        console.log ('valores para guardar: GP '+ Gestor_Produccion + ' CR '+Centro_Responsabilidad + ' idOpp: ' +idOpp );
        action.setParams({ 
            CR : Centro_Responsabilidad,
            GP : Gestor_Produccion,
            oppId : idOpp
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('RESPONSE: '+ response);
            var result = response.getReturnValue();
            
            console.log('STATE: '+ state);
            if(result.length < 20){
                if(state == "SUCCESS"){

                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valores actualizados',
                        'message': 'Se ha guardado correctamente.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": idOpp
                    });
                    navEvt.fire();
                    console.log('Oportunidad y componente superPreventa: ' + idOpp);
                    if(idOpp != null && idOpp != ''){
                        var action = component.get("c.superPreventa");
                        component.set("v.Spinner", true);
                        action.setParams({ 
                            'idOpp' : idOpp,
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
                    }
                    //window.location.reload();                    
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
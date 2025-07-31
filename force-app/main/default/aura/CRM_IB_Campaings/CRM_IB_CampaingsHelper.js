({
	saveOpp : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        
        var selectCNAE=  component.find('select_Campaign').get('v.value');
        
        var action=component.get("c.saveTask_Campaign");
        
        action.setParams({ 
            Id_task : component.get("v.recordId"),
            Campaign: component.find('select_Campaign').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valor Campaña actualizado',
                        'message': 'Se ha guardado correctamente el valor Campaña.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                	//setTimeout(function() { window.location.reload(); }, 2000);
                   // $A.get("e.force:closeQuickAction").fire();
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar correctamente. ' + response,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                
                    $A.get('e.force:refreshView').fire();
                    
            }
             
        });
        $A.enqueueAction(action);
	}
})
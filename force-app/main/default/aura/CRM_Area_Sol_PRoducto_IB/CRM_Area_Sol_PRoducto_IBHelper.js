({
	saveOpp : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        
        var selectOrg=  component.find('select_Producto').get('v.value');
        
        var action=component.get("c.saveActivo");
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value'),
            Solucion : component.find('select_Solucion').get('v.value'),
            Producto: component.find('select_Producto').get('v.value'),
            Id_activo : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valores actualizados',
                        'message': 'Se han guardado correctamente los valores de Area, Solución y Producto.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                
                    $A.get("e.force:closeQuickAction").fire();
                
                
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
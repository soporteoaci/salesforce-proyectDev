({
	saveOpp : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        
        
        var action=component.get("c.saveOpportunity_CCI");
        
        action.setParams({ 
            Id_opp : component.get("v.recordId"),
            CCI: component.find('select_CCI').get('v.value')
        });
        console.log('Id_opp '+ component.get("v.recordId"));
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valor CCI actualizado',
                        'message': 'Se ha guardado correctamente el valor CCI',
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
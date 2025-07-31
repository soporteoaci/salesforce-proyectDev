({
	saveCNAEAccount : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        
        var selectCNAE=  component.find('select_CNAE').get('v.value');
        
        var action=component.get("c.saveAccount_CNAE");
        
        action.setParams({ 
            Id_account : component.get("v.recordId"),
            CNAE: component.find('select_CNAE').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valor CNAE actualizados',
                        'message': 'Se ha guardado correctamente el valor CNAE.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                //	setTimeout(function() { window.location.reload(); }, 2000);
                  //  $A.get("e.force:closeQuickAction").fire();
                
                    
                
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
	},
    saveSICAccount : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        
        var selectSIC=  component.find('select_SIC').get('v.value');
        
        var action=component.get("c.saveAccount_SIC");
        
        action.setParams({ 
            Id_account : component.get("v.recordId"),
            SIC: component.find('select_SIC').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valor SIC actualizado',
                        'message': 'Se ha guardado correctamente el valor SIC.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                	//setTimeout(function() { window.location.reload(); }, 2000);
                    //$A.get("e.force:closeQuickAction").fire();
                
                    
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar correctamente el valor SIC. ' + response,
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
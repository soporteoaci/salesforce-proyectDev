({
	saveOpp : function(component,event,helper) {
      
        
        console.log('Entramos en Save helper');
        console.log('Sector: ' + component.find('select_Sector').get('v.value'));
    
        
        var action=component.get("c.saveAccount_sector");
        
         var Subsector_selected = component.find('select_Subsector').get('v.value'); 
         var sector_selected = component.get("v.Sector_elegido");
        
        //component.find('select_Sector').get('v.value'),
        if (Subsector_selected == null || Subsector_selected == ''){
            Subsector_selected='';
            
        }
        
        action.setParams({ 
            Sector : sector_selected,
            
            Subsector : Subsector_selected,
            Idaccount : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Valores actualizados',
                        'message': 'Se ha guardado correctamente.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
               	
               // setTimeout(function() { window.location.reload(); }, 2000);
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
                
            }
             
        });
        $A.enqueueAction(action);
	}
  
})
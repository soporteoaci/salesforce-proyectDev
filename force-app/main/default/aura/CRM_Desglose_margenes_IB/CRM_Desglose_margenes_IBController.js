({
	doInit : function(component, event, helper) {
        
        var action=component.get("c.desgloseMargenes");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            oppId : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS"){
                      
                component.set("v.oportunidad",response.getReturnValue());
                console.log("escribimos result " + result);
                component.set("v.mensaje","Success");
            }else{
               component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    save : function(component, event, helper){
      
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", true);
        
        var action=component.get("c.saveOpmargenes");
        
        action.setParams({ 
            oppId : component.get("v.recordId"),
             margen_servicio: component.find('margen_servicio').get('v.value'),
             margen_productoHard : component.find('margen_productoHard').get('v.value') ,
             margen_productoSoft : component.find('margen_productoSoft').get('v.value') ,
             margen_mtoHard : component.find('margen_mtoHard').get('v.value') ,
             margen_mtoSoft: component.find('margen_mtoSoft').get('v.value') 
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS"){
                      
                component.set("v.mensaje","Actualizado importes");
            }else{
               component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    }
})
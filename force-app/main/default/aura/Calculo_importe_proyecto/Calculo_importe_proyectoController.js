({
	doInit : function(component, event, helper) {
         console.log("Actualizar todos los importes");
        
        var action = component.get("c.Calculoimporte"); 
        
        action.setCallback(this, function(response) { 
            console.log(response.getState());
            if (response.getState() == "SUCCESS"){  
            	component.set("v.salida","Importes reales de proyectos actualizados correctamente");
                 console.log("success");
            } 
            else {
                	component.set("v.salida","Error al actualizar los importes reales de proyecto");
                 console.log("error");
                 }
        }); 
        $A.enqueueAction(action);
	},
     handleClick: function(component, event, helper) {

       var close_component= $A.get("e.force:closeQuickAction");
         close_component.fire();
    
    }
})
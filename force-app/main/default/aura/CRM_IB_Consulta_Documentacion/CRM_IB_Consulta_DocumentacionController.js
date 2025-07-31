({
	doInit : function(component, event, helper) {
        
		var idOpp = component.get("v.recordId"); 
        var action = component.get("c.consulta_doc_New_File");
        component.set("v.Spinner", true);
        action.setParams({ 
            idObj : idOpp
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                //window.open(response, '_blank').focus();  
                component.set("v.mensaje", "Proceso correcto, respuesta consulta: "+ response);              
            }else{
                component.set("v.mensaje", "No ha ido correctamente ");
            }
        });        
        $A.enqueueAction(action); 
	}
})
({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.processPoject");
       
        
        action.setParams({project: recordId
                         }); 
 
        action.setCallback(this, function(response) { 
            console.log(response.getState());
            if (response.getState() == "SUCCESS"){  
            	component.set("v.salida","Acción realizada correctamente");
                 console.log("success");
            } 
            else {
                	component.set("v.salida","Error en la acción");
                 console.log("error");
                 }
        }); 
        $A.enqueueAction(action);
	},
     handleClick: function(component, event, helper) {

       	history.go(); 
     
    }
})
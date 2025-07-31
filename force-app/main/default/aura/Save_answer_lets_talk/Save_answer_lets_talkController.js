({
	doInit:function(component, event, helper){
        var action = component.get("c.do_init"); 
               
        action.setParams({
            lets_talk_Id: component.get("v.recordId")
        }); 

        action.setCallback(this, function(response){
            var state=response.getState();
            if(component.isValid() && state==="SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Lets_talk_registro",result);  
                
            }else{
                console.log("Failed with state: "+ state);
            }
  
        });
        $A.enqueueAction(action);
        
        
    },
    save_email : function(component, event, helper){
        var action = component.get("c.guardar_email"); 
        
        action.setParams({
            lets_talk_Id: component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response){
            var state=response.getState();
            if(component.isValid() && state==="SUCCESS"){
                var result = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                
            }else{
                console.log("Failed with state: "+ state);
            }
            
            
        });
        $A.enqueueAction(action);
        
        var cerrarAccionRapida = $A.get("e.force:closeQuickAction");
        cerrarAccionRapida.fire();
    },
     cancel : function(component, event, helper){
        var cerrarAccionRapida = $A.get("e.force:closeQuickAction");
        cerrarAccionRapida.fire();
    },

})
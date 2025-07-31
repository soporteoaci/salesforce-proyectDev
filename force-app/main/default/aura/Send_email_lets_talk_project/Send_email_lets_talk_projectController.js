({
    doInit:function(component, event, helper){
        var action = component.get("c.do_init_proyecto"); 
               
        action.setParams({
            lets_talk_Id: component.get("v.recordId")
        }); 

        action.setCallback(this, function(response){
            var state=response.getState();
            if(component.isValid() && state==="SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Lets_talk_registro",result);  
                component.set("v.prueba",result.Destinatarios__c);
                
            }else{
                console.log("Failed with state: "+ state);
            }
  
        });
        $A.enqueueAction(action);
        
        
    },
    send_email : function(component, event, helper){
        var action = component.get("c.enviar_email_proyecto"); 
        
        action.setParams({
            lets_talk_Id: component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response){
            var state=response.getState();
            if(component.isValid() && state==="SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.prueba2",result);  
                component.set("v.prueba","prueba"); 
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
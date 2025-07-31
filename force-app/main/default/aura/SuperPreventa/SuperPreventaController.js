({
    doInit: function(component, event, helper) {
        console.log('ENTRO en SuperPreventa');
        
        var idOpp=component.get("v.recordId"); 
        var action = component.get("c.superPreventaComprobacion");
         action.setParams({ 
            'idOpp' : idOpp,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            
            console.log('state: ' + state);
            console.log('response: ' + response);
            
            if (state === "SUCCESS") {
                console.log('response: '+ response);
                if (response == 'true'){
                    component.set("v.Mensaje_informar",true);
                    component.set("v.Acceso_Preventa",false);
                    
                }else{
                    component.set("v.Mensaje_informar",false);
                    component.set("v.Acceso_Preventa",true);
                   
                }
                           
            }else{
                
            }
        });        
        $A.enqueueAction(action);
        
        
    },
    accept: function(component, event, helper) {
        console.log('Accedemos al controller apex superPreventa');
        var idOpp=component.get("v.recordId"); 
        var action = component.get("c.superPreventa");
        component.set("v.Spinner", true);
        action.setParams({ 
            'idOpp' : idOpp,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                window.open(response, '_blank').focus();                
            }
        });        
        $A.enqueueAction(action);
    },
    reject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
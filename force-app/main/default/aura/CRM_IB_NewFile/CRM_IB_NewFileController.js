({
    doInit: function(component, event, helper) {
        console.log('ENTRO');
        
        
        
    },
    accept: function(component, event, helper) {
        var idOpp = component.get("v.recordId"); 
        
        var action = component.get("c.newFile");
        component.set("v.Spinner", true);
        action.setParams({ 
            'id' : idOpp
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
        
   var action2 = component.get("c.oportunidad_documentacion");
        component.set("v.Spinner", true);
        action2.setParams({ 
            'id' : idOpp
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
               // window.open(response, '_blank').focus(); 
               var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();               
            }
        });        
        $A.enqueueAction(action2); 
        
        
      
    },
    reject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
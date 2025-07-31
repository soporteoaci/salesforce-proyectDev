({
    doInit : function(component, event, helper) {
        var action = component.get("c.getActions");
        action.setParams({ "status" : component.get("v.status") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.actionAtt", response.getReturnValue());                
            }
            else {
                console.log("Failed with state: "+ state);
            }
        });
        
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
       

        component.set('v.today', today);
        $A.enqueueAction(action);
    }
})
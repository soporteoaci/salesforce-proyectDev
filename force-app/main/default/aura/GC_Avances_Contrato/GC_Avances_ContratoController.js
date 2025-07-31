({
	doInit : function(component, event, helper) {
        helper.getInfoKPI(component,event,helper);
        //component.set("v.avanceENT",30);
        //component.set("v.avanceTDR",70);
        component.set("v.avanceENTProgress",0);
        component.set("v.avanceTDRProgress",0);
        
        
	},
    
    checkValueTDR : function(component, event, helper) {
        if (component.get('v.avanceTDRProgress') >= component.get('v.avanceTDR') ) {
            // stop
            clearInterval(component._intervalTDR);
        }
	},
    
    checkValueENT : function(component, event, helper) {
       if (component.get('v.avanceENTProgress') >= component.get('v.avanceENT') ) {
            // stop
            clearInterval(component._intervalENT);
        }
	},
    
    startUpdateTDR : function(component,event, helper) {
        helper.updateTDRStatus(component,event,helper);
    }
    
})
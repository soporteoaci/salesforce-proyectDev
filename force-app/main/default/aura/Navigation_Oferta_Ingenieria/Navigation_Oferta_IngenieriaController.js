({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        if(recordId != null && recordId != ''){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreacionOfertaIngenieria",
                componentAttributes: {
                    idOpp : component.get("v.recordId")
                }
            });
            evt.fire(); 
        }
    }
})
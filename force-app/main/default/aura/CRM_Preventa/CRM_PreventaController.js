({
    doInit: function(component, event, helper){
        console.log('Do init de CRM_Preventa');
        
        
        
       component.set("v.idOportunidad", component.get("v.recordId"));
        
        console.log("record id: "+ component.get("v.recordId")  );
    },
    
    Ayesa : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        if(recordId != null && recordId != ''){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreacionOferta",
                componentAttributes: {
                    idOpp : component.get("v.recordId"),
                    preventa : "false"
                }
            });
            evt.fire(); 
        }
    },
    
    Ibermatica : function(component, event, helper) {
          var oppId= component.get('v.oppId');
        console.log("RecordId que le pasamos: "+ oppId);
        component.set("v.Show_Seccion_Ibermatica", true);
    },
    Mixta : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        if(recordId != null && recordId != ''){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreacionOferta",
                componentAttributes: {
                    idOpp : component.get("v.recordId"),
                    preventa : "true"
                }
            });
            evt.fire(); 
        }
    }
})
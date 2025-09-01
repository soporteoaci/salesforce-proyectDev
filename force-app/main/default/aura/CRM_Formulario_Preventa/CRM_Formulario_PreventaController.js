({
    mostrarFlow : function (component) {
        // Find the component whose aura:id is "flowData"
        var oppId = component.get("v.recordId");
        var mostrar = component.set("v.Show_flow",true);
        // In that component, start your flow. Reference the flow's API Name.
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name: 'recordId',
                type : 'String',
                value: oppId
            }];
        flow.startFlow("Boton_Opportunity_Correo_Preventa",inputVariables);  
    },
    onRecordUpdated : function(component, event, helper) {
        const estado = component.get("v.registro.Orgcomercial__c");
        component.set("v.orgcomercial", estado);
        
        const recordId = component.get("v.recordId");
        const tipo = helper.getSObjectFromId(recordId);
        console.log('DEBUG - Tipo de objeto deducido:', tipo);
        
        component.set("v.sObjectName", tipo);
    },
    
    cerrarFlow : function (component) {
        var mostrar = component.set("v.Show_flow",false);
    },
    statusChange : function (component,event) {
        if (event.getParam('status') === "FINISHED") {
            var mostrar = component.set("v.Show_flow",false);
            setTimeout(function() { window.location.reload(); });   
            
        }
    }    
})
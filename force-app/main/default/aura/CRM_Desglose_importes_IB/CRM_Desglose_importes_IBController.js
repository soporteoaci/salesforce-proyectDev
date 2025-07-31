({
	doInit : function(component, event, helper) {
        
        var action=component.get("c.desgloseImportesMargenes");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            oppId : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS"){
                      
                component.set("v.oportunidad",response.getReturnValue());
                console.log("escribimos result " + result);
                component.set("v.mensaje","Success");
            }else{
               component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    saveImporte : function(component, event, helper){
      
        let buttonUpdate = component.find('botonGuardarImporte');
        buttonUpdate.set("v.disabled", true);
        
        var action=component.get("c.saveOpimportes");
        
        action.setParams({ 
            oppId : component.get("v.recordId"),
             importe_servicio: component.find('importe_servicio').get('v.value'),
             importe_productoHard : component.find('importe_productoHard').get('v.value') ,
             importe_productoSoft : component.find('importe_productoSoft').get('v.value') ,
             importe_mtoHard : component.find('importe_mtoHard').get('v.value') ,
             importe_mtoSoft: component.find('importe_mtoSoft').get('v.value') 
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS"){
                      
                component.set("v.mensaje","Actualizado importes");
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Desglose importe guardado',
                        'message': 'Se ha guardado correctamente el desglose de importes.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                 
                    $A.get("e.force:closeQuickAction").fire();
            }else{
               component.set("v.mensaje", "Se ha producido un error");
                 var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar correctamente. ' + response,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                    $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    saveMargen : function(component, event, helper){
      
        let buttonUpdate = component.find('botonGuardarMargen');
        buttonUpdate.set("v.disabled", true);
        
        var action=component.get("c.saveOpmargenes");
        
        action.setParams({ 
            oppId : component.get("v.recordId"),
             margen_servicio: component.find('margen_servicio').get('v.value'),
             margen_productoHard : component.find('margen_productoHard').get('v.value') ,
             margen_productoSoft : component.find('margen_productoSoft').get('v.value') ,
             margen_mtoHard : component.find('margen_mtoHard').get('v.value') ,
             margen_mtoSoft: component.find('margen_mtoSoft').get('v.value') 
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS"){
                      
                component.set("v.mensaje","Actualizado margenes");
                var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Desglose margenes guardado',
                        'message': 'Se ha guardado correctamente el desglose de márgenes.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
               		 
                    $A.get("e.force:closeQuickAction").fire();
            }else{
               component.set("v.mensaje", "Se ha producido un error");
                 var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar correctamente. ' + response,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                    $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
         
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
         
        // -1 open/close section
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    
 
    }
})
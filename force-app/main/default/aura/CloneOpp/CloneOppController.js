({    
        doInit: function(component,event,helper){
        var idOportunidad=component.get("v.recordId"); 
        var action = component.get("c.getTypeOpp");
          action.setParams({ 
              'idOportunidad' : idOportunidad
              
          });
             action.setCallback(this, function(response) {
              var state = response.getState();
              var response = response.getReturnValue();
              console.log('state: ' + state);
              console.log('response: ' + response);
              if (state === "SUCCESS") {
                  component.set("v.RecordTypeName", response);
              }else{
                 console.log('Error');
              }
          });        
          $A.enqueueAction(action);
    },
    cloneOpp : function(component, event, helper) {
        var recordTypeName =component.get("v.RecordTypeName");
        var idOportunidad=component.get("v.recordId"); 
        var nombreOpp = component.find("inputName").get("v.value");
        var fechaCierre = component.find("inputFechaCierre").get("v.value");
        var fechaPresentacion = component.find("inputFechaPresentacion").get("v.value");
        var plazoEjecucion = component.find("inputPlazo").get("v.value");
        
        var importeTotal;
        var margenEstimado;
        importeTotal = component.find("inputImporteTotalLicitacon").get("v.value");
        margenEstimado = component.find("inputMargenEstimado").get("v.value");
        console.log("idOportunidad: " + idOportunidad);
        console.log("nombreOportunidad: " + nombreOpp);
        var action = component.get("c.clonarOportunidad");
        action.setParams({ 
            'idOportunidad' : idOportunidad,
            'nombreOpp' : nombreOpp,
            'fechaCierre' : fechaCierre,
            'fechaPresentacion' : fechaPresentacion,
            'margenEstimado' : margenEstimado,
            'plazoEjecucion' : plazoEjecucion,
            'importeTotal' : importeTotal
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('state: ' + state);
            console.log('response: ' + response);
            if (state === "SUCCESS") {
                if(response.length < 20){
                    console.log('SUCCESSSS');
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Nueva Oportunidad',
                        'message': 'Se ha creado correctamente la Oportunidad.',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    console.log('Response: ' + response);
                    var navigateEvent = $A.get("e.force:navigateToSObject");
                    navigateEvent.setParams({ "recordId": response });
                    navigateEvent.fire();
                }else{
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al crear la Oportunidad',
                        'message': 'No se ha podido crear correctamente la Oportunidad. ' + response,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }else{
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Error al crear la Oportunidad',
                    'message': 'No se ha podido crear la Oportunidad. Debe ser el propiertario para clonar',
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 11000
                });
                showToast.fire();
                $A.get('e.force:refreshView').fire();
            }
        });        
        $A.enqueueAction(action);
        
    }
})
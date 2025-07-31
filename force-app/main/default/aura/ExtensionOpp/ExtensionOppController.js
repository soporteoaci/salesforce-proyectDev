({  
        doInit: function(component,event,helper){
        var idOportunidad=component.get("v.recordId"); 
        var action = component.get("c.getTypeOpp");
            
            
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
		 component.set('v.fecha_hoy',today);
            
          action.setParams({ 
              'idOportunidad' : idOportunidad
              
          });
             action.setCallback(this, function(response) {
              var state = response.getState();
             // var response = response.getReturnValue();
              var response = JSON.parse(response.getReturnValue());
              console.log('state: ' + state);
              console.log('response: ' + response.oportunidad.RecordType.Name);
              if (state === "SUCCESS") {
                  component.set("v.RecordTypeName", response.oportunidad.RecordType.Name);
                  component.set("v.Oportunidad", response.oportunidad);
                  component.set("v.LineasServicio", response.lineasServicio);
                  component.set("v.Subfase", response.oportunidad.Subfase__c);
                  console.log('Lineas de servicio recuperadas: '+response.lineasServicio );
                  console.log("Subfase: "+ response.oportunidad.Subfase__c);  
                 
              }else{
                 console.log('Error');
              }
          });        
          $A.enqueueAction(action);
    },
    onChangeTipoExtension:function(component, event, helper) {
        var tipoExtension = component.find("tipoExtension").get("v.value");
        
         component.set("v.TipoExtensionValue",tipoExtension);
        console.log('Lineas de servicio recuperadas 2: '+component.get("v.LineasServicio"));
    },
      extensionOpp : function(component, event, helper) {
          
          var errores = helper.formValidate(component, event, helper);
          
          if( errores.length == 0 ) {
          var recordTypeName =component.get("v.RecordTypeName");
          var idOportunidad=component.get("v.recordId");
          var Oportunidad = component.get("v.Oportunidad");
          var nombreOpp = component.find("inputName").get("v.value");
          var fechaCierre = component.find("inputFechaCierre").get("v.value");
          var fechaPresentacion = component.find("inputFechaPresentacion").get("v.value");
         var probabilidad = component.find("probabilidad").get("v.value");
          var tipoNegocio = component.find("tipo_de_negocio").get("v.value");
          var plazoEjecucion = component.find("inputPlazo").get("v.value");
          var importeTotal ;
          var margenEstimado;
          var tipoExtension;
          var lineaServicio;
          var Origen =null;
          
          if(recordTypeName == 'Ayesa' || recordTypeName== 'Ibermatica Large Account' || recordTypeName=='Ibermatica Latam'){
           importeTotal = component.find("inputImporteTotalOfertado").get("v.value");
           margenEstimado = component.find("inputMargenEstimado").get("v.value");

           console.log('Origen: '+ Origen);
           tipoExtension = component.find("tipoExtension").get("v.value");
              
              if(tipoExtension=='Extensión Desglose'){
                  lineaServicio =component.find("LineasServicioPicklist").get("v.value");
              }else{
                  lineaServicio=null;
              }
              
             // if(tipoExtension=='Extensión Rectificativa' && Oportunidad.Origen__c != null ){
                 Origen  = component.find("Origen").get("v.value");
             // }
           
          }else{
              importeTotal=null;
              margenEstimado=null;
              
          }
          
          
          
          console.log("idOportunidad: " + idOportunidad);
          console.log("nombreOportunidad: " + nombreOpp);
          console.log("probabilidad: " + probabilidad);
         component.set("v.disabledSave", true);
          var action = component.get("c.extenderOportunidad_fields");
          action.setParams({ 
              'idOportunidad' : idOportunidad,
              'nombreOpp' : nombreOpp,
              'fechaCierre' : fechaCierre,
              'fechaPresentacion' : fechaPresentacion,
              'margenEstimado' : margenEstimado,
              'plazoEjecucion' : plazoEjecucion,
              'importeTotal' : importeTotal,
              'probabilidad' : probabilidad,
              'tipoNegocio' : tipoNegocio,
              'tipoExtension': tipoExtension,
              'lineaServicio' : lineaServicio,
              'Origen': Origen
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
                          'message': 'Se ha creado correctamente la Extensión.',
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
                  }else{//ABR
                      component.set("v.disabledSave", false);
                      //
                      var showToast = $A.get("e.force:showToast");
                      showToast.setParams({
                          'title': 'Error al crear la Extensión',
                          'message': 'No se ha podido generar la Extensión correctamente. ' + response,
                          'type': 'error',
                          'mode': 'dismissible',
                          'duration': 8000
                      });
                      showToast.fire();
                      $A.get('e.force:refreshView').fire();
                  }
              }else{
                  //ABR
                  component.set("v.disabledSave", false);
//
                  var showToast = $A.get("e.force:showToast");
                  showToast.setParams({
                      'title': 'Error al crear la Oportunidad',
                      'message': 'No se ha podido crear la Oportunidad. ' + response,
                      'type': 'error',
                      'mode': 'dismissible',
                      'duration': 8000
                  });
                  showToast.fire();
                  $A.get('e.force:refreshView').fire();
              }
          });        
          $A.enqueueAction(action);
          }else{
              component.set("v.disabledSave", false);
              var showToast = $A.get("e.force:showToast");
                  showToast.setParams({
                      'title': 'Error al crear la Extensión',
                      'message': errores,
                      'type': 'error',
                      'mode': 'dismissible',
                      'duration': 8000
                  });
                  showToast.fire();
          }
      }
     })
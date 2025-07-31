({
    doInit : function(component, event, helper) {
        console.log('Dentro doinitt');
    },
    
    finalizarSubida: function(component, event, helper) {       
        component.set("v.Spinner", true);
        var file = event.getParam("files");
        var tipoArchivo = component.find("tipoArchivo").get("v.value");
        var idOportunidad = component.get("v.recordId");
        var carpeta = component.find("Carpeta").get("v.value");
        
        var file = event.getParam("files");
        var fileList = [];
        for(var i = 0; i < file.length ; i++){
            fileList.push(file[i].documentId);
        }
        console.log('FileList: ' + fileList);
        console.log('idOportunidad: ' + idOportunidad);
        
        var action = component.get("c.uploadCV");
        action.setParams({
            recordId : idOportunidad,
            contentDocumentIds : fileList,
            tipoArchivo : tipoArchivo,
            carpeta: carpeta
        });
        action.setCallback(this, function(response) {
            var state= response.getState();
            var response = response.getReturnValue();
            console.log('state2: ' + state);
            console.log('response2: ' + response);
            component.set("v.Spinner", false);
        });        
        $A.enqueueAction(action);
        
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title': 'Subida de Documentacion',
            'message': 'el Archivo se ha subido correctamente',
            'type': 'success',
            'mode': 'pester'
        });
        showToast.fire();
        $A.get('e.force:refreshView').fire();       
        
    },   
    showToast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },
    
    seleccionTipoArchivo: function(component, event, helper) {
        console.log('SELECCIÓN ARCHIVO');
        var tipoArchivo = component.find("tipoArchivo").get("v.value");
        var carpeta = component.find("Carpeta").get("v.value");
        console.log('tipo archivo : '+ tipoArchivo);
        console.log('carpeta: '+ carpeta);
        
        
        if(tipoArchivo != "Seleccione tipo" && tipoArchivo != "" && carpeta != "Seleccione carpeta" && carpeta != ""){
            component.set("v.subirArchivo", "true");
        }else{
            component.set("v.subirArchivo", "false");
        }
        
        
        if(tipoArchivo != "Seleccione tipo"){
            console.log('Buscamos la carpeta por defecto');
            //Buscamos la carpeta por defecto
            var action = component.get("c.carpeta_defecto");
            action.setParams({
                
                tipoArchivo : tipoArchivo
            });
            action.setCallback(this, function(response) {
                var state= response.getState();
                var response = response.getReturnValue();
                console.log('state: ' + state);
                console.log('carpeta default recuperada: ' + response);
                
                component.set("v.carpetaDefault", response);
                
                if(tipoArchivo != "Seleccione tipo" && tipoArchivo != "" && response != "Seleccione carpeta" && response != ""){
                    component.set("v.subirArchivo", "true");
                }else{
                    component.set("v.subirArchivo", "false");
                }
                
                
            });        
            $A.enqueueAction(action);
        }
        
    },
    
    seleccionCarpeta: function(component, event, helper) {
        console.log('seleccion carpeta');
        var tipoArchivo = component.find("tipoArchivo").get("v.value");
        var carpeta = component.find("Carpeta").get("v.value");
        console.log('tipo archivo seleccionCarpeta: '+ tipoArchivo);
        console.log('carpeta seleccionCarpeta: '+ carpeta);
        
        if(tipoArchivo != "Seleccione tipo" && tipoArchivo != "" && carpeta != "Seleccione carpeta" && carpeta != ""){
            component.set("v.subirArchivo", "true");
        }else{
            component.set("v.subirArchivo", "false");
        }
    }
})
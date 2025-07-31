({
    doInit : function(component, event, helper) {
        
        var action=component.get("c.areaImporteSME");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            Id_ImporteSME : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                
                component.set("v.ImporteSME",result.ImporteSME);
                
                component.set("v.Valores_Area",result.area);
                component.set("v.Valores_Solucion",  result.solucion);
                component.set("v.Valores_Producto", result.producto);
                console.log('Seccion Importes SME: '+ result.ImporteSME.Seccion__c);
                
                component.set("v.Area", result.ImporteSME.Area__c );
                component.set("v.Solucion",result.ImporteSME.Solucion__c);
                component.set("v.Producto", result.ImporteSME.Producto__c);
                component.set("v.Modulo", result.ImporteSME.Modulo__c);
                
                var items = [];
                var items_selected =[];
                //Todos los valores
                console.log('result lenght: '+ result.modulo.length);
                for (var i = 0; i < result.modulo.length; i++) {
                    console.log('Modulo: '+ result[i] );
                    var item = {
                        "label": result.modulo[i],
                        "value": result.modulo[i]
                    };
                    items.push(item);
                }
                component.set("v.options", items);
                //Valores elegidos al crear el importe
                console.log('result.ImporteSME.Modulo__c: '+ result.ImporteSME.Modulo__c);
                if(result.ImporteSME.Modulo__c!= '' && result.ImporteSME.Modulo__c != null && result.ImporteSME.Modulo__c != undefined){
                    items_selected =  result.ImporteSME.Modulo__c.split(',');
                }
               
              
               
				component.set("v.values", items_selected);                
                //Sí meten solo SRV solo pide Área
                //Si meten HARD o MTTO.HARD les pide Área / Solución/ Producto y cantidad.
                //Sí meten SOFT o MTTO.SOFT les pide Área / Solución/ Producto/cantidad/Tipo/tipo de Pago
                
                if(result.ImporteSME.Seccion__c=='SRV' && result.ImporteSME.Area__c == undefined){
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Informe el Área.',
                        'type': 'warning',
                        'mode': 'sticky'
                    });
                    showToast.fire();

                }else if((result.ImporteSME.Seccion__c=='HARD' || result.ImporteSME.Seccion__c=='MTTO.HARD') && (result.ImporteSME.Area__c == undefined 
                         || result.ImporteSME.Solucion__c == undefined || result.ImporteSME.Producto__c == undefined ||result.ImporteSME.Cantidad__c == undefined)){
                    
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Informe Area, Solución, Producto y Cantidad',
                        'type': 'warning',
                        'mode': 'sticky'
                    });
                    showToast.fire();
                    
                    
                }else if((result.ImporteSME.Seccion__c=='SOFT' || result.ImporteSME.Seccion__c=='MTTO.SOFT')&&(result.ImporteSME.Area__c == undefined 
                         || result.ImporteSME.Solucion__c == undefined || result.ImporteSME.Producto__c == undefined ||result.ImporteSME.Cantidad__c== undefined
                         || result.ImporteSME.Tipo__c == undefined|| result.ImporteSME.Tipo_de_Pago__c== undefined)){
                    
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Informe Area, Solución, Producto, Cantidad, Tipo y Tipo de Pago',
                        'type': 'warning',
                        'mode': 'sticky'
                    });
                    showToast.fire();
                    
                    
                }else{
                    console.log('NADA');
                }
                
                
                //console.log('Response: '+ response.getReturnValue());
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    AreaSelected: function(component, event, helper) {
        console.log('Entramos en AreaSelected');
        
        var selectArea=  component.find('select_Area').get('v.value');
        component.set("v.Area", selectArea);
        var valor_Solucion= component.find('select_Solucion').get('v.value');
        var valor_Producto= component.find('select_Producto').get('v.value');
        
        if (valor_Solucion !=null || valor_Producto !=null){
            component.set("{!v.ImporteSME.Solucion__c}","");
            component.set("v.ImporteSME.Producto__c",""); 
            component.set("v.options", null);
            component.set("v.values", null);
        }
        console.log('Area elegido: '+selectArea);
        
        var action=component.get("c.solucionImporteSME");
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Solucion",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    SolucionSelected: function(component, event, helper) {
        console.log('Entramos en SolucionSelected');
        
        var selectSolucion=  component.find('select_Solucion').get('v.value');
        component.set("v.Solucion",selectSolucion);
        console.log('Solucion elegida: '+selectSolucion);
        
        var action=component.get("c.Producto_valoresImporteSME");
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value'),
            Solucion : component.find('select_Solucion').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Producto",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    ProductoSelected: function(component, event, helper){
        // let buttonUpdate = component.find('botonGuardar');
        // buttonUpdate.set("v.disabled", false);
        console.log('Entramos en ProductoSelected');
        
        var selectProducto=  component.find('select_Producto').get('v.value');
        component.set("v.Producto", selectProducto);
        console.log('Producto elegifo: '+selectProducto);
        
        var action=component.get("c.Modulo_valoresImporteSME");
        var items_modulo =[]
        
        var Area = component.get("v.Area");
        var Solucion = component.get("v.Solucion");
        
        action.setParams({ 
            Area : Area,
            Solucion : Solucion,
            Producto: selectProducto
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();                
                var items = [];
                console.log('result lenght: '+ result.length);
                for (var i = 0; i < result.length; i++) {
                    console.log('Modulo: '+ result[i] );
                    var item = {
                        "label": result[i],
                        "value": result[i]
                    };
                    items.push(item);
                }
                component.set("v.options", items);
                // "values" must be a subset of values from "options"
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
      handleChange: function (component, event) {
        // This will contain an array of the "value" attribute of the selected options
       var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
        component.set ("v.Modulo",selectedOptionValue.toString());
    },
    
    save: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        // buttonUpdate.set("v.disabled", true);
        console.log( "entro en save");
        
        helper.saveOpp(component,event,helper);
        
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
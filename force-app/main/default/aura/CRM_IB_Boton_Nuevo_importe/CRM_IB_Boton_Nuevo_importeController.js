({
    doInit: function(component, event, helper) {
        
        console.log('Helloooo: ' +component.get("v.recordId"));
        
        var action=component.get("c.areaImporteSME");
        action.setParams({ 
            OppId: component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            if(state == "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.Valores_Area",result.area);
                component.set("v.RecordType_Op",result.RecordTypeOp);
                component.set("v.Oportunidad", result.oportunidad);
                console.log('record type: '+result.RecordTypeOp);
                
                if(result.RecordTypeOp == "Ibermatica SME"){
                    component.set("v.Show_Area_Sol_Pro", true);
                }else {
                    component.set("v.Show_Area_Sol_Pro", false);			                    
                }
                
                
                //console.log('Response: '+ response.getReturnValue());
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    handleClick: function(component, event, helper) {
        var mostrar = component.set("v.Show_create_boton",false);
        var mostrar = component.set("v.Show_create_form",true);
        
    },
    SectionSelected:function(component, event, helper){
        var seccion_text = component.find('select_Seccion').get('v.value');
        console.log('Seccion elegida: '+ seccion_text );
        var mostrar = component.set("v.Show_fields_seccion", seccion_text);
        if (seccion_text == 'SRV'){
            var obligatorio = component.set("v.Solucion_producto_obligatorio", false)
            }else{
                var obligatorio = component.set("v.Solucion_producto_obligatorio", true)
                }
        
        
    }, 
    AreaSelected: function(component, event, helper) {
        console.log('Entramos en AreaSelected');        
        
        var selectArea=  component.find('select_Area').get('v.value');
        
        var valor_Solucion= component.find('select_Solucion').get('v.value');
        var valor_Producto= component.find('select_Producto').get('v.value');
        
        if (valor_Solucion !=null || valor_Producto !=null){
            component.set("{!v.ImporteSME.Solucion__c}","");
            component.set("{!v.Valores_Producto}","");            
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
    
    ProductoSelected: function(component, event, helper) {
        console.log('Entramos en ProductoSelected');
        
        var selectProducto=  component.find('select_Producto').get('v.value');
        console.log('Producto elegifo: '+selectProducto);
        
        var action=component.get("c.Modulo_valoresImporteSME");
        
        var items_modulo =[]
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value'),
            Solucion : component.find('select_Solucion').get('v.value'),
            Producto: component.find('select_Producto').get('v.value')
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
        component.set ("v.Modulo_aux",selectedOptionValue.toString());
    },
    Guardar_importe:function(component, event, helper) {
        component.set("v.successMessage",  ''); 
        component.set("v.errorMessage",  ''); 
        component.set("v.errors", '');
        
        var RecordType_Op = component.get("v.RecordType_Op");
        console.log('RecordType : : '+ RecordType_Op);
        var errores = helper.formValidate(component, event, helper);
        
        
        if( errores.length == 0 ) {
            component.set ("v.disabledSave", true); 
            var Cantidad;
            var Coste;
            var Descuento;
            var select_Costehoras;
            var Horas;
            var select_Tipo;
            var select_Tipo_Pago;
            var Observaciones;
            
            var Name_importe = component.find('Name_importe').get('v.value');
            var select_Seccion = component.find('select_Seccion').get('v.value');
            var Importe_bruto = component.find('Importe_bruto').get('v.value');
            
            if (RecordType_Op == 'Ibermatica SME'){
                Descuento = component.find('Descuento').get('v.value');
                
                if(select_Seccion != 'SRV'){
                    Cantidad = component.find('Cantidad').get('v.value');
                    Coste = component.find('Coste').get('v.value');
                }else{
                    Cantidad = 0;
                    Coste =0;
                    select_Costehoras = component.find('select_Costehoras').get('v.value');
                    Horas = component.find('Horas').get('v.value');
                }
                
                
                if(select_Seccion== 'SOFT'){
                    select_Tipo = component.find('select_Tipo').get('v.value');
                    select_Tipo_Pago = component.find('select_Tipo_Pago').get('v.value');
                }else{
                    select_Tipo =null;
                    select_Tipo_Pago=null;
                }
                if(component.get("v.Observaciones")!="" ||  component.get("v.Observaciones")!= null){
                    Observaciones=component.get("v.Observaciones");
                }else{
                    Observaciones="";
                }
                
                
                var select_Area=  component.find('select_Area').get('v.value');
                var valor_Solucion= component.find('select_Solucion').get('v.value');
                var valor_Producto= component.find('select_Producto').get('v.value');
                
                var valor_Modulo = component.get("v.Modulo_aux");
                console.log('valor_Modulo: ' + valor_Modulo);
                
                
            }else{
                
                Coste = component.find('Coste').get('v.value');
                Descuento =0;
                Cantidad = 0;
                select_Costehoras=null;
                
                select_Tipo =null;
                select_Tipo_Pago=null;
                select_Area='';
                valor_Solucion='';
                valor_Producto='';
                if(component.get("v.Observaciones")!="" ||  component.get("v.Observaciones")!= null){
                    Observaciones=component.get("v.Observaciones");
                }else{
                    Observaciones="";
                }
                
                
            }
            var action=component.get("c.saveInfoImportes");
            
            
            action.setParams({ 
                OppId: component.get("v.recordId"),
                Name_importe :Name_importe,
                select_Seccion :select_Seccion,
                Importe_bruto :Importe_bruto,
                Descuento :Descuento,
                
                
                Cantidad :Cantidad,
                Coste :Coste,
                
                select_Costehoras :select_Costehoras,
                Horas :Horas,
                
                select_Tipo :select_Tipo,
                select_Tipo_Pago :select_Tipo_Pago,
                
                Observaciones :Observaciones,
                Area : select_Area,
                Solucion : valor_Solucion,
                Producto : valor_Producto,
                Modulo: valor_Modulo
                
            });
            action.setCallback(this,function(response){
                
                var state=response.getState();
                console.log("Response.getState: : "+ state);
                console.log('RESPONSE antes: '+response);
                
                if(state === "SUCCESS"){
                    var result = response.getReturnValue();
                    console.log('RESULT  : '+result);
                    
                    if(result.length < 20){

                    //console.log('Response: '+ response.getReturnValue());
                    component.set("v.Mostrar_errorMessage", false);
                    component.set ("v.disabledSave", true); 
                    component.set ("v.Boton_otro_importe", true);
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Importe creado',
                        'message': 'Se ha creado el importe correctamente',
                        'type': 'success',
                        'mode': 'dismissible',
                        'duration': 15000
                    });
                    showToast.fire();
                    setTimeout(function() { window.location.reload(); }, 2000);
                    $A.get("e.force:closeQuickAction").fire();
                    }else{
                     component.set("v.mensaje", "Se ha producido un error");
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar el importe. ' + result ,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                     helper.Limpiar_campos(component,event,helper);
                       console.log('BOTON ACTIVAR');
                      component.set ("v.disabledSave", false); 
                    }
                }else{
                    component.set("v.mensaje", "Se ha producido un error");
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Error al guardar',
                        'message': 'No se ha podido guardar el importe. ' + result,
                        'type': 'error',
                        'mode': 'dismissible',
                        'duration': 11000
                    });
                    showToast.fire();
                    
                }
            });
           $A.enqueueAction(action);
            
        }else {        	
            component.set("v.Mostrar_errorMessage", true);
            component.set("v.errors", errores); 
            
            
            
        }
        
        //  console.log('Name: '+ component.find('Cantidad').get('v.value'));
        
        
        
    },
    Crear_importe_2: function(component, event, helper) {
        helper.Limpiar_campos(component, event, helper);
        component.set ("v.disabledSave", false); 
        component.set ("v.Boton_otro_importe", false);
        
    },
    Cerrar: function(component, event, helper) {
        var mostrar = component.set("v.Show_create_boton",true);
        var mostrar = component.set("v.Show_create_form",false);
        helper.Limpiar_campos(component,event,helper);
    }
})
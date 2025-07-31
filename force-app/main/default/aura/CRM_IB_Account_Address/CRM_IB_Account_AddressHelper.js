({
    countryProvinceMap: {
        US: [
            {'label': 'California', 'value': 'CA'},
            {'label': 'Texas', 'value': 'TX'},
            {'label': 'Washington', 'value': 'WA'}
        ],
        CN: [
            {'label': 'GuangDong', 'value': 'GD'},
            {'label': 'GuangXi', 'value': 'GX'},
            {'label': 'Sichuan', 'value': 'SC'}
        ],
        VA: []
    },
    countryOptions: [
        {'label': 'United States', 'value': 'US'},
        {'label': 'China', 'value': 'CN'},
        {'label': 'Vatican', 'value': 'VA'}
    ],
    SaveAccountCountryState : function(component,event,helper) {
        
        console.log('Entramos en Save helper');        
        
        var action=component.get("c.saveAccountCountry");
        
        var Pais = component.get("v.pais_elegido");
        var Calle =component.get("v.calle_elegida");
        var Ciudad =component.get("v.ciudad_elegida");
        var Codigo_Postal =component.get("v.codigopost_elegido");
        var Provincia=component.get("v.provincia_elegida");
        
        console.log('Variables a pasar: '+ Pais + Calle + Ciudad+ Codigo_Postal + Provincia);
        /* Pais : component.find('select_Pais').get('v.value'),
            Provincia : component.find('select_Provincia').get('v.value'),
           
            Ciudad:component.find('Ciudad').get('v.value'),
            Calle:component.find('Calle').get('v.value'),
            Codigo_Postal: component.find('Codigo_Postal').get('v.value'),*/
        action.setParams({ 
            Pais : Pais,
            Provincia : Provincia,
            Ciudad: Ciudad,
            Calle:Calle,
            Codigo_Postal: Codigo_Postal,
            IdAccount : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Valores actualizados',
                    'message': 'Se ha guardado correctamente.',
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
                    'message': 'No se ha podido guardar correctamente. ' + response,
                    'type': 'error',
                    'mode': 'dismissible',
                    'duration': 11000
                });
                showToast.fire();
                //window.location.reload();
                // $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    formValidate: function(component, event, helper) {
        
        var fields=[];
        //fields = [ "select_Pais", "Calle", "Ciudad",  "Codigo_Postal", "select_Provincia" ];    
        fields = [ "v.pais_elegido", "v.provincia_elegida", "v.calle_elegida",  "v.ciudad_elegida", "v.codigopost_elegido" ];
        var required = [];
        
        for(var i=0; i<fields.length; i++){            
            //var value = component.find(fields[i]).get("v.value");
            var value = component.get(fields[i]);
            console.log("Campo '" + fields[i] + "': ", component.get(fields[i]));
            if(value == undefined || value == null || value == "")
                required.push("El campo '" + component.get(fields[i]) + "' es obligatorio.");
        }
        
        return required;
    },
});
({
    doInit: function(component, event, helper) {
        console.log('Direccion cuenta');
        console.log('Dirección: ' +component.get("v.recordId"));
        
        var action=component.get("c.countryProvinceMap");
        action.setParams({ 
            IdAccount : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            
            console.log('State: '+ state);
            if(state == "SUCCESS"){
                
                var result = JSON.parse(response.getReturnValue());
                component.set("v.countryOptions",result.map_paises);
                component.set("v.provinceOptions",result.map_provincias);
                component.set("v.Cuenta",result.account);
                
                //Asignamos a las variables los valores iniciales
                component.set("v.pais_elegido", result.account.BillingCountry);
                component.set("v.provincia_elegida", result.account.BillingState);
                component.set("v.calle_elegida", result.account.BillingStreet);
                component.set("v.ciudad_elegida", result.account.BillingCity);
                component.set("v.codigopost_elegido", result.account.BillingPostalCode);
                //console.log('Response: '+ response.getReturnValue());
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
        
        // component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
    },
    valoresProvincia: function(component, event, helper) {
        
        var action=component.get("c.provinceOptions");  
        
        console.log('pais que pasamos: '+component.find('select_Pais').get('v.value'));
        
        var Pais_elegido= component.find('select_Pais').get('v.value');
        component.set("v.pais_elegido", Pais_elegido);
        
        var valor_Provincia= component.find('select_Provincia').get('v.value');
        
        if (valor_Provincia !=null ){
            component.set("{!v.Cuenta.BillingState}","");
            component.set("v.provincia_elegida", "");
            // component.set("{!v.Opportunity.Organizacion_Ibermatica__c}","");
        }
        
        action.setParams({ 
            Pais : Pais_elegido
        });
        action.setCallback(this,function(response){
            
            var state=response.getState();
            if(state == "SUCCESS"){
                
                var result = response.getReturnValue();
                component.set("v.provinceOptions",result);
                console.log('RESULT: '+ result);
                
                //console.log('Response: '+ response.getReturnValue());
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    } ,
    valorProvinces: function(component, event, helper) {
        
        var valor_Provincia= component.find('select_Provincia').get('v.value');
        component.set("v.provincia_elegida",valor_Provincia );
        /*if (component.get("v.previousCountry") !== component.get("v.country")) {
            component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
        }
        component.set("v.previousCountry", component.get("v.country"));*/
        
    },
    valorCalle: function(component, event, helper) {
	
     var Calle=component.find('Calle').get('v.value');
     component.set("v.calle_elegida", Calle);
    },
    valorCiudad: function(component, event, helper) {
     var Ciudad=component.find('Ciudad').get('v.value');
        component.set("v.ciudad_elegida", Ciudad);
    },
    valorCodigoPostal: function(component, event, helper) {
     var Codigo_Postal= component.find('Codigo_Postal').get('v.value');
     component.set("v.codigopost_elegido",Codigo_Postal);
    },
    
    Guardar_direccion: function(component, event, helper) {
        console.log("Guardamos dirección");
        var errores = helper.formValidate(component, event, helper);
        
        if( errores.length == 0 ) {
            helper.SaveAccountCountryState(component,event,helper);
        }else{       	
            component.set("v.Mostrar_errorMessage", true);
            component.set("v.errors", errores); 
            
        }
    }
});
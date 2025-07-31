({
    
    //CONTROL DE SPINNER
    switchSpinner : function(component, msg){  
       
        component.set("v.spinnerMsg", msg);
        component.set("v.showSpinner", !(component.get("v.showSpinner")));
    },
    
    inicial : function(component) {
        
        //Definimos las variables necesarias a inicializar en el formulario
        var today = $A.localizationService.formatDate(new Date());
        component.set("v.fechaApOrden", today);
    },
    
    guardarHelper : function(component, event, helper){
        
        var action = component.get("c.guardarOpp");
        var idOpp = component.get("v.idOpp");
        
        var opp = JSON.stringify(component.get("v.oportunidad"));
        
        action.setParams({
            idOpportunity : idOpp,
            Oport : opp	
            
        });
        
        console.log("Oportunidad: " + opp);
        
        action.setCallback(this, function(response) {
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                if(result.status == 'OK')
                    component.set("v.successMessage",  $A.get("$Label.c.CRM_Oferta_guardada_correctamente_CL")); 
                else
                    component.set("v.errorMessage",  'Se ha producido un error al guardar la oferta. ' + result.message); 
            }
        });
        $A.enqueueAction(action);       
    },

    goToOpp : function(component){     
        var idOpp = component.get("v.idOpp");
        window.location = '/' + idOpp;
    },
    
    formValidate: function(component, event, helper) {
        var fields = ["objetivoProy", "cliente", "responsable", "fechaInicio",  "fechaFin", "importe", "selectCentro", "selectPais", "selectDivSap", "selectEmplazamiento", "selectTipoTr", "selectSubTr"];
        var required = [];
            
        for(var i=0; i<fields.length; i++){            
        	var value = component.find(fields[i]).get("v.value");
            console.log("Campo '" + fields[i] + "': ", component.find(fields[i]).get("v.value"));
        	if(value == undefined || value == null || value == "")
        		required.push("El campo '" + component.find(fields[i]).get("v.label") + "' es obligatorio.");
    	}
                
        return required;
    },
    
    offerGenerator : function(component, event, helper ) {
        
        //var results = component
        var idOpp = component.get("v.idOpp");
        var action = component.get("c.offerGeneratorApex");      
        //console.log(component.get("v.InfoParametrica"));
        
        // -- Guardamos cambios --
        var opp = component.get("v.oportunidad");
        component.set("v.oportunidad", opp);                    
        //helper.saveHelper(component, event, helper) ;
        
        
        action.setParams({
            idOpportunity : idOpp            
        });
        
        action.setCallback(this, function(response) {    
            var opp = component.get("v.oportunidad");
            
            if(component.isValid() && response.getState() === "SUCCESS") {                
                console.log('Callback response: ', response.getReturnValue());
                
                var result = JSON.parse(response.getReturnValue());
                if(result.status == 'Error'){
                    component.set("v.errorMessage", result.message);
                    component.set("v.errors", result.warnings);
                } else {           
                    var ofertaSAP = result.ofertaSAP;
                    
                    // -- Guardamos Cód. Oferta SAP y cambio de Etapa en la oportunidad --
                    //var opp = component.get("v.oportunidad");
                    opp.Oferta_SAP__c = ofertaSAP;			//Asignación de Oferta SAP
                    opp.Etapa__c = "Preparando QA";					//Asignación nuevo estado
                    //component.set("v.oportunidad", opp);                    
                    //helper.saveHelper(component, event, helper) ;
                    
                    // -- Preparamos mensajes devueltos por SAP --
                    component.set("v.warningMessage", result.message);
                    component.set("v.warnings", result.warnings);
                    component.set("v.ofertaSAP", ofertaSAP);
                    component.set("v.disabledGenOferButton", true);
                    
                    $A.util.toggleClass(component.find("modal-ofer"), 'slds-hidden');
            		$A.util.toggleClass(component.find("backGroundModal"), 'slds-hidden');
                }     
            }else{
                console.log("Fallo en la petición de oferta SAP.", response.getError());                 
                component.set("v.errorMessage", "Fallo en la petición de oferta SAP.");
            }
            
            // -- Guardamos oportunidad --
            component.set("v.oportunidad", opp);                    
            helper.guardarHelper(component, event, helper);
            
            //Spinner
            helper.switchSpinner(component, "");
        });
        
        helper.switchSpinner(component, "Generando Oferta en SAP. Espere por favor...");
        $A.enqueueAction(action);	        
    }
    
})
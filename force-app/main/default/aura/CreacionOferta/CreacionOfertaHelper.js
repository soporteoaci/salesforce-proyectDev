({
    //CONTROL DE SPINNER
    switchSpinner : function(component, msg){  
        /* //console.log(type);
        if (type=='loading'){
         component.set("v.showSpinner", !(component.get("v.showSpinner")));
        //$A.util.toggleClass(component.find("mySpinner"), "slds-hide");
        }else if(type=='modal'){
         //component.set("v.showSpinnerModal", !(component.get("v.showSpinnerModal")));
         //$A.util.toggleClass(component.find("mySpinner"), "slds-hide slds-is-relative");
        }
        */

        component.set("v.spinnerMsg", msg);
        component.set("v.showSpinner", !(component.get("v.showSpinner")));
    }, 
    
    /*  EmplHelper: function(component, event, helper){
    console.log(event.getSource().getLocalId());
	},*/
    
    GoToOport : function(component){     
        var idOpp = component.get("v.idOpp");
        window.location = '/' + idOpp;
        //window.history.back();
    },
    
    saveHelper : function(component, event, helper) {     
        var action = component.get("c.saveOpp");
        var idOpp = component.get("v.idOpp");
        
        var opp = JSON.stringify(component.get("v.oportunidad"));//component.get("v.oportunidad"); 
        console.log('Oportunidad para actualizar: ', opp);
        
        
        action.setParams({
            idOpportunity : idOpp,
            Oport : opp	
           
        });
        
        action.setCallback(this, function(response) {
            
            if(component.isValid() && response.getState() === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log('saveHelper', result);
                if(result.status == 'OK')
                	component.set("v.successMessage",  $A.get("$Label.c.CRM_Oferta_guardada_correctamente_CL")); 
                else
                    component.set("v.errorMessage",  'Se ha producido un error al guardar la oferta. ' + result.message); 
            }
        });
        $A.enqueueAction(action);       
        
    },
    
    loadValues : function(component, helper, event, padre, hijo) {
           
	//var results = component	
        
    },
    
    OfferGenerator : function(component, event, helper ) {
        
        //var results = component
        var idOpp = component.get("v.idOpp");
        var action = component.get("c.OfferGeneratorApex");
        var infoParametrica = JSON.stringify(component.get("v.InfoParametrica"));        
        //console.log(component.get("v.InfoParametrica"));
        
        // -- Guardamos cambios --
        var opp = component.get("v.oportunidad");
        component.set("v.oportunidad", opp);                    
        //helper.saveHelper(component, event, helper) ;
        
        
        action.setParams({
            infoParametrica: infoParametrica,
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
                    //opp.Etapa__c = "Preparando QA";		//Asignación nuevo estado
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
            helper.saveHelper(component, event, helper) ;
            
            helper.switchSpinner(component, "");            
        });
        
        helper.switchSpinner(component, "Generando Oferta en SAP. Espere por favor...");
        $A.enqueueAction(action);	        
    },
    
    formValidate: function(component, event, helper) {
        var fields = [ "Objetivo_del_proyecto__c", "Cliente", "JefeProyecto",  "GP",  "RUP",  "fecha_Limite_Presentacion",  "fecha_Inicio_PEP",  "Fecha_Fin_PEP", "Probabilidad", "PlazoMeses", "Importe", "AREA_NEGOCIO", "AREA_NEGOCIO_N1", "DIVISION_SAP", "AETIC", "SECTOR_CLIENTE", "PAIS", "PAIS_CLIENTE", "TERRITORIO_EJEC", "TERRITORIO", "CENTRO", /*"GRUPO", "SUBGRUPO",*/ "FUNCIONAL_N1", "FUNCIONAL_N2", "FUNCIONAL_N3", "TECNICO_N1", "TECNICO_N2" ];
        var required = [];
            
        for(var i=0; i<fields.length; i++){            
        	var value = component.find(fields[i]).get("v.value");
            console.log("Campo '" + fields[i] + "': ", component.find(fields[i]).get("v.value"));
        	if(value == undefined || value == null || value == "")
        		required.push("El campo '" + component.find(fields[i]).get("v.label") + "' es obligatorio.");
    	}
                
        return required;
    },
    
})
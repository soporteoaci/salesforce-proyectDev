({
    
    doInit : function(component, event, helper) {
        
        var action=component.get("c.valoresCNAESIC");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            Id_Account : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                component.set("v.Valores_CNAE", result.CNAE);
                 component.set("v.Valores_SIC", result.SIC);
                component.set("v.Account",result.Account);
                //  v.Account.CNAE__c
               
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },  
    CNAESelected: function(component, event, helper){
        console.log('CNAE Selected, activo boton');
        
        let buttonUpdate = component.find('botonGuardarCNAE');
        buttonUpdate.set("v.disabled", false);
    },
    SICSelected: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardarSIC');
        buttonUpdate.set("v.disabled", false);
    },
    
    
    
    saveCNAE: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardarCNAE');
        buttonUpdate.set("v.disabled", true);
        console.log( "entro en save CNAE");
      
        helper.saveCNAEAccount(component,event,helper);
        
    },
    saveSIC: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardarSIC');
        buttonUpdate.set("v.disabled", true);
        console.log( "entro en save SIC");
      
        helper.saveSICAccount(component,event,helper);
        
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
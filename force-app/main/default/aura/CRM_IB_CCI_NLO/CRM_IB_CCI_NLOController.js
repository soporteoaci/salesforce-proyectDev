({
    
    doInit : function(component, event, helper) {
        
        var action=component.get("c.valoresCCI_Opportunity");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            Id_opp : component.get("v.recordId")
        });
       
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                component.set("v.Valores_CCI", result.CCI);
                component.set("v.Oportunidad",result.Oportunidad);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },  
    CCISelected: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
    },
    
    
    
    save: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", true);
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
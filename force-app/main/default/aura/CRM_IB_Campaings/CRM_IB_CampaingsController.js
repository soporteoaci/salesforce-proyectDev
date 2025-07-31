({
    
    doInit : function(component, event, helper) {
        
        var action=component.get("c.valoresCampanya");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            Id_task : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                component.set("v.Valores_campaigns", result.Campaign);
                component.set("v.Task",result.Task);
                //  v.Account.CNAE__c
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },  
    CampaignSelected: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
    },
    
    
    
    save: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", true);
        console.log( "entro en save");
      
        helper.saveOpp(component,event,helper);
        
    }
})
({
    doInit : function(component, event, helper) {
        
        
        
        var action=component.get("c.sector");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            accountId : component.get("v.recordId")
        });
        console.log('Id account '+ component.get("v.recordId"));
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                
                component.set("v.Account",result.account);
                component.set("v.Valores_Sector",result.Sector);
                component.set("v.Valores_Subsector", result.Subsector);
                
                component.set ("v.Sector_elegido", result.account.Sector_text__c);
                component.set("v.Subsector_elegido", result.account.Subsector_texto__c);
                //console.log('Response: '+ response.getReturnValue());
                
                //Warning para informar los campos de Sector y Subsector cuando estén vacios
                if(result.account.Sector_text__c == undefined || result.account.Subsector_texto__c == undefined  ){
                    console.log('No está informado el Sector y Subsector '+ result.account.Sector_texto__c +'   '+result.account.Subsector_texto__c );
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Sector y Subsector',
                        'type': 'warning',
                        'mode': 'sticky'
                    });
                    showToast.fire();
                }else{
                    
                }
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
        
        
        
        
        
    },
    
    SectorSelected: function(component, event, helper) {
        console.log('Entramos en GPSelected');
        
        var selectSector=  component.find('select_Sector').get('v.value');
        component.set ("v.Sector_elegido", selectSector);
               
        var valor_Subsector= component.find('select_Subsector').get('v.value');
         //  var valor_Org= component.find('select_Org').get('v.value');
        //&& valor_Org !=null  || (valor_CR ==null && valor_Org !=null) || (valor_CR!=null && valor_Org ==null)
        
        if (valor_Subsector !=null ){
            component.set("{!v.Account.Subsector_texto__c}","");
           // component.set("{!v.Opportunity.Organizacion_Ibermatica__c}","");
        }
        console.log('Sector elegido: '+selectSector);
        
        var action=component.get("c.valores_subsector");
        
        action.setParams({ 
            Sector : component.find('select_Sector').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Subsector",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    SubsectorSelected: function(component, event, helper) {
        
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);

    },
  
    
    save: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
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
({
    doInit : function(component, event, helper) {
        var action1=component.get("c.readOnlyCR");        
        var idOpp = component.get("v.recordId");
        console.log('Entramos en doInit Centro Responsabilidad Detail: ' + idOpp);        
        action1.setParams({ 
            oppId : idOpp
        });
        
        action1.setCallback(this,function(response){
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                component.set ("v.readOnlyField", result);
                console.log('Result ReadOnly: ' + result); 
            }
        });
        $A.enqueueAction(action1);

        var action=component.get("c.inicio");        
        var idOpp = component.get("v.recordId");
        console.log('Entramos en doInit Centro Responsabilidad: ' + idOpp);
        component.set("v.idOppPreventa",idOpp);
        var idOppPreventa = component.get("v.idOppPreventa");
        console.log('Entramos en doInit Centro Responsabilidad: ' + idOppPreventa);
        action.setParams({ 
            oppId : idOpp
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                
                component.set("v.Opportunity",result.oportunidad);
                console.log('Valores GP,CR: '  + result.oportunidad.GP_Super__c + ' / ' +result.oportunidad.CR_Super__c + ' / ' + result.oportunidad.RecordType.Name   );
                
                component.set("v.Valores_Gestor_Produccion",result.Gestor_produccion);
                console.log("ABR Valores gestor de produccion QUERY: "+result.Gestor_produccion );
                component.set("v.Valores_Centro_Responsabilidad",result.Centro_Responsabilidad);
                component.set ("v.GP_elegido", result.oportunidad.GP_Super__c );
                component.set ("v.CR_elegido", result.oportunidad.CR_Super__c );
                console.log('DEL DO INIT CR_elegido: '+ result.oportunidad.CR_Super__c);
                
                //Warning para informar los campos de GP,CR cuando estén vacios
                //console.log('Resuuult: '+ result.oportunidad.RecordType.DeveloperName);
                if((result.oportunidad.GP_Super__c ==undefined || result.oportunidad.CR_Super__c == undefined)){
                    console.log('No está informado GP,CR');
                    /* var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Gestor de Produccion y Centro de Responsabilidad.',
                        'type': 'warning',
                        'mode': 'sticky'
                    });
                    showToast.fire();*/
                }else{
                    let buttonUpdate = component.find('botonGuardar');
                    buttonUpdate.set("v.disabled", false);
                }
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    CRSelected: function(component, event, helper) {
        console.log('Entramos en CRSelected');
        
        var selectCR=  component.find('select_CR').get('v.value');
        component.set("v.CR_elegido",selectCR);
        var valor_GP= component.find('select_GP').get('v.value');
        //  var valor_Org= component.find('select_Org').get('v.value');
        //&& valor_Org !=null  || (valor_CR ==null && valor_Org !=null) || (valor_CR!=null && valor_Org ==null)
        if (valor_GP !=null ){
            component.set("{!v.Opportunity.GP_Super__c}","");
            // component.set("{!v.Opportunity.Organizacion_Ibermatica__c}","");
        }
        console.log('Centro de responsabilidad elegido: '+selectCR);
        
        var action=component.get("c.gestor_produccion");
        
        action.setParams({ 
            CR : component.find('select_CR').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Gestor_Produccion",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    GPSelected: function(component, event, helper) {
        console.log('Entramos en GPSelected');
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
        
        var selectGP=  component.find('select_GP').get('v.value');
        component.set("v.GP_elegido",selectGP);
        
        
        //    console.log("v.CR_elegido" + selectCR + ' / ' +component.get("v.CR_elegido"));
        
        //   console.log("v.GP_elegido" + selectGP + ' / ' +component.get("v.GP_elegido"));
        
    },    
    save: function(component, event, helper){
        var idOppPreventa = component.get("v.idOppPreventa");
        console.log('idOppPreventa: ' + idOppPreventa);
        let buttonUpdate = component.find('botonGuardar');
        //  buttonUpdate.set("v.disabled", true);
        
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
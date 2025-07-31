({
    doInit : function(component, event, helper) {
        
        
        
        var action=component.get("c.gestor_produccion");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            oppId : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                
                component.set("v.Opportunity",result.oportunidad);
                console.log('GP,CR u Organizacion: '  + result.oportunidad.GP_Super__c + result.oportunidad.CR_Super__c +result.oportunidad.RecordType.Name +
                          result.oportunidad.Etapa_Fase__c  );
                
                component.set("v.Valores_Gestor_Produccion",result.Gestor_produccion);
                component.set("v.Valores_Centro_Responsabilidad",result.Centro_Responsabilidad);
                component.set ("v.GP_elegido", result.oportunidad.GP_Super__c );
                component.set ("v.CR_elegido", result.oportunidad.CR_Super__c );
                //console.log('Response: '+ response.getReturnValue());
                
                //Warning para informar los campos de GP,CR cuando estén vacios
                //console.log('Resuuult: '+ result.oportunidad.RecordType.DeveloperName);
                if((result.oportunidad.GP_Super__c ==undefined || result.oportunidad.CR_Super__c == undefined)){
                    console.log('No está informado GP,CR u Organizacion');
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': 'Revise los siguientes campos',
                        'message': 'Gestor de Produccion, Centro de Responsabilidad.',
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
    
    GPSelected: function(component, event, helper) {
        console.log('Entramos en GPSelected');
        
        var selectGP=  component.find('select_GP').get('v.value');
        component.set("v.GP_elegido",selectGP);
        var valor_CR= component.find('select_CR').get('v.value');
         //  var valor_Org= component.find('select_Org').get('v.value');
        //&& valor_Org !=null  || (valor_CR ==null && valor_Org !=null) || (valor_CR!=null && valor_Org ==null)
        if (valor_CR !=null ){
            component.set("{!v.Opportunity.CR_Super__c}","");
           // component.set("{!v.Opportunity.Organizacion_Ibermatica__c}","");
        }
        console.log('Gestor producción elegido: '+selectGP);
        
        var action=component.get("c.centro_resp");
        
        action.setParams({ 
            GP : component.find('select_GP').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Centro_Responsabilidad",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    CRSelected: function(component, event, helper) {
        
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
        
        var selectCR=  component.find('select_CR').get('v.value');
        component.set("v.CR_elegido",selectCR);
        
     /*   Para tener la Organización ligada con GP y CR
      * console.log('Entramos en CRSelected');
        
        var selectCR=  component.find('select_CR').get('v.value');
        console.log('Centro respon elegido: '+selectCR);
        
        var action=component.get("c.organizacion");
        
        action.setParams({ 
            CR : component.find('select_CR').get('v.value'),
            GP : component.find('select_GP').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Organizacion",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);*/
        
    },
  /*  OrgSelected: function(component, event, helper){
        let buttonUpdate = component.find('botonGuardar');
        buttonUpdate.set("v.disabled", false);
    },*/
    
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
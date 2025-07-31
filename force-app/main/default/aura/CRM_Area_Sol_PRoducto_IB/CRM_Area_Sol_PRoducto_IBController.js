({
    doInit : function(component, event, helper) {
        
        var action=component.get("c.area");
        
        console.log('Entramos en doInit');
        action.setParams({ 
            Id_activo : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            
            var state=response.getState();
            var result = JSON.parse(response.getReturnValue());
            
            if(state == "SUCCESS"){
                
                
                component.set("v.Activo",result.activo);
                
                component.set("v.Valores_Area",result.area);
                
                //console.log('Response: '+ response.getReturnValue());
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    AreaSelected: function(component, event, helper) {
        console.log('Entramos en AreaSelected');
        
        var selectArea=  component.find('select_Area').get('v.value');
        
        var valor_Solucion= component.find('select_Solucion').get('v.value');
        var valor_Producto= component.find('select_Producto').get('v.value');
        
        if (valor_Solucion !=null && valor_Producto !=null  || (valor_Solucion ==null && valor_Producto !=null) || (valor_Solucion!=null && valor_Producto ==null)){
            component.set("{!v.Activo.Solucion__c}","");
            component.set("{!v.Activo.Producto__c}","");
        }
        console.log('Area elegido: '+selectArea);
        
        var action=component.get("c.solucion");
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Solucion",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    
    SolucionSelected: function(component, event, helper) {
        console.log('Entramos en SolucionSelected');
        
        var selectSolucion=  component.find('select_Solucion').get('v.value');
        console.log('Solucion elegida: '+selectSolucion);
        
        var action=component.get("c.Producto_valores");
        
        action.setParams({ 
            Area : component.find('select_Area').get('v.value'),
            Solucion : component.find('select_Solucion').get('v.value')
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.Valores_Producto",result);
                
                
            }else{
                component.set("v.mensaje", "Se ha producido un error");
            }
        });
        $A.enqueueAction(action);
    },
    ProductoSelected: function(component, event, helper){
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
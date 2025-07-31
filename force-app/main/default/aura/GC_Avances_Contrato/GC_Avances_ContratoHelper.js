({
	 getInfoKPI : function(component,event,helper) {
         var action = component.get("c.getInfoAvances");
         action.setParams({
             "contractId": component.get("v.recordId")
             
         });
         action.setCallback(this, function(response) {
             var state = response.getState();
             if(component.isValid() && state === "SUCCESS") {
                 var result= response.getReturnValue();
                 var jsonInfo = JSON.parse(result); 
                 
                 
                 if(jsonInfo.result=='OK'){
                     console.log('Avances del contrato : CORRECTA');
                     console.log(jsonInfo);                    
                     component.set("v.avancesResultList",jsonInfo.avance);
                     var i;
                     for (i = 0; i < jsonInfo.avance.length; i++) {
                        if(jsonInfo.avance[i].entidad=='HITO'){
                            var avance = parseFloat(jsonInfo.avance[i].info);
                            component.set('v.avanceTecnico', avance);
                        }else if(jsonInfo.avance[i].entidad=='TDR_AVANCE'){
                            console.log('Avance TDR: '+ jsonInfo.avance[i].info);
                            component.set('v.avanceTDR', parseFloat(jsonInfo.avance[i].info));
                            
                        }else if(jsonInfo.avance[i].entidad=='ENT_AVANCE'){
                             console.log('Avance ENT: '+ jsonInfo.avance[i].info);
                            component.set('v.avanceENT', parseFloat(jsonInfo.avance[i].info));
                        }
                    }
                     helper.animationProgressBar(component,event,helper);
                     
                 }
                 else{
                     console.log('Fallo en Avances del contrato');
                 }
                 
                 
             } else {
                 console.log("KO-getInfoAvances"); 
             }   
         });
         $A.enqueueAction(action);
	},
    
    animationProgressBar: function(component, event, helper){
        
        component._intervalTDR = setInterval($A.getCallback(function () {
            var avanceTDR = component.get('v.avanceTDRProgress');
            component.set('v.avanceTDRProgress', avanceTDR + 1);
        }), 50);
        
        component._intervalENT = setInterval($A.getCallback(function () {
            var avanceENT = component.get('v.avanceENTProgress');
            component.set('v.avanceENTProgress', avanceENT + 1);
        }), 50);
        
    },
    
    updateTDRStatus : function(component, event, helper){
        var action = component.get("c.updateTdrStatusProcess");
        action.setParams({
            "contractId": component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result= response.getReturnValue();
                
                if(result=='OK'){
                    console.log('Actualización de estado de TDRs: CORRECTA');
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    console.log('Fallo en actualización de estado de TDRs');
                }
            } else {
                console.log("KO-updateTDRStatus"); 
            }   
        });
        $A.enqueueAction(action);
    },
    
    
})
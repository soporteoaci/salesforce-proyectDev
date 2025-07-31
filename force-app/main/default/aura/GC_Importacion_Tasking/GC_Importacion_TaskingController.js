({
	doInit : function(component, event, helper) {
		helper.getContractInfo(component, event, helper);
	}, 
    
    cancel : function(component, event, helper){
        var cerrarAccionRapida = $A.get("e.force:closeQuickAction");
        cerrarAccionRapida.fire();
    },
    
    startImport : function (component, event, helper){
        helper.putOnSpinner(component, event, helper);
        let buttonimport = component.find('buttonImport');
        buttonimport.set('v.disabled',true);
        helper.getIdTasking(component, event, helper);  
    },
    
    
    startUpdate : function (component, event, helper){
        helper.putOnSpinner(component, event, helper);
        let buttonUpdate = component.find('buttonUpdate');
        buttonUpdate.set('v.disabled',true);
        var idtasking = component.get("v.idTasking");
        helper.getIdTasking(component,event,helper);
      // helper.importFromTasking(component, event, helper, idtasking);  //Comentada para insertar la getsion de contratos con alto numero de TDR's
    },
    
    newCallToRelations : function(component, event, helper){
        var currentCalls= component.get("v.currentCallsToController");
        var myListTdrsIds = component.get("v.TDRListSplitedIds");
        var myTotalCalls = component.get("v.totalCallsToController");
       
        if(currentCalls<myTotalCalls){
            console.log("Llamada numero: "+ (currentCalls+1));
            console.log("Total de llamadas: "+myTotalCalls);
            console.log("Tamaño de la lista a la que voy a acceder: " + myListTdrsIds[currentCalls].length );
            helper.relationCallControllerManagement(component,event,helper,myTotalCalls,currentCalls, myListTdrsIds[currentCalls]);
        }
    },
    
    openDetailInfo : function(component, event, helper){
        var al= component.find("ResultImportInfo");
        $A.util.toggleClass(al, "slds-hide"); 
    },
    
})
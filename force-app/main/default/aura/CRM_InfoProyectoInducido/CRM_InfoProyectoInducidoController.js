({
	doInit : function(component, event, helper) {
        var idOpp=component.get("v.recordId");    
        var action = component.get("c.checkStatus");
        
        console.log('Dentro del doInit');
        console.log('idOpp=' + idOpp);
                               
        action.setParams({ 'idOpp' : idOpp });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var results = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                var opp = results['mOpp'];  
                console.log('opp', opp);
                    
                //component.set("v.canChange", !(opp!=null) ? true : false);
                component.set("v.opp", opp);
                component.set("v.programaSelected", opp.Programa_Inductor__c);
                component.set("v.proyInductor1Selected", opp.Proyecto_Inductor_1__c);
                component.set("v.proyInductor2Selected", opp.Proyecto_Inductor_2__c);
                component.set("v.proyInductor3Selected", opp.Proyecto_Inductor_3__c);
                component.set("v.proyInductor4Selected", opp.Proyecto_Inductor_4__c);
                component.set("v.tipoInduccion1Selected", opp.Tipo_Induccion_1__c);
                component.set("v.tipoInduccion2Selected", opp.Tipo_Induccion_2__c);
                component.set("v.tipoInduccion3Selected", opp.Tipo_Induccion_3__c);
                component.set("v.tipoInduccion4Selected", opp.Tipo_Induccion_4__c);
                
                // SCM - Nuevo campo Innovation_Work_Stream__c
                component.set("v.innovationWorkStreamSelected", opp.Innovation_Work_Stream__c);
                component.set("v.innovationWorkStreamOptions", [
                    { label: "Next generation of AI-powered user experiences", value: "WS1" },
                    { label: "Data-driven decision making and business operations", value: "WS2" },
                    { label: "Secured cloud infrastructures and platforms", value: "WS3" }
                ]);
                
                helper.getDatosSAP(component, helper);
                
                helper.checkChanged(component, helper);
            }
            
        });
        
        $A.enqueueAction(action);
	},
    
    save : function(component, event, helper) {
        
        var idOpp = component.get("v.recordId");    
        
        //https://developer.salesforce.com/docs/component-library/bundle/lightning:input/example#lightningcomponentdemo:exampleInputValidation
        
        //var userName = component.find('programa');
        //userName.set("v.errors",[{message:'Name is required'}]);
        
        helper.showSpinner(component);
                 
        if(!helper.checkValidations(component, event, helper)) {
            var programaSelected = component.find("programa").get("v.value");
            var proyInductor1Selected = component.find("proyInductor1").get("v.value");
            var proyInductor2Selected = component.find("proyInductor2").get("v.value");
            var proyInductor3Selected = component.find("proyInductor3").get("v.value");
            var proyInductor4Selected = component.find("proyInductor4").get("v.value");
            var tipoInduccion1Selected = component.find("tipoInduccion1").get("v.value");
            var tipoInduccion2Selected = component.find("tipoInduccion2").get("v.value");
            var tipoInduccion3Selected = component.find("tipoInduccion3").get("v.value");
            var tipoInduccion4Selected = component.find("tipoInduccion4").get("v.value");
            
            // SCM - Nuevo campo Innovation_Work_Stream__c
            var innovationWSSelected = component.find("innovationWS").get("v.value");
            
            var proyInductor1 = {
                'proyInductor': proyInductor1Selected,
                'tipoInduccion': tipoInduccion1Selected
            };
            var proyInductor2 = {
                'proyInductor': proyInductor2Selected,
                'tipoInduccion': tipoInduccion2Selected
            };
            var proyInductor3 = {
                'proyInductor': proyInductor3Selected,
                'tipoInduccion': tipoInduccion3Selected
            };
            var proyInductor4 = {
                'proyInductor': proyInductor4Selected,
                'tipoInduccion': tipoInduccion4Selected
            };
            
            console.log('idOpp', idOpp);
            console.log('programaSelected', programaSelected);
            console.log('innovationWS', innovationWSSelected);		// SCM - Nuevo campo Innovation_Work_Stream__c
            console.log('proyInductor1', proyInductor1);
            console.log('proyInductor2', proyInductor2);
            console.log('proyInductor3', proyInductor3);
            console.log('proyInductor4', proyInductor4);
            
            var action = component.get("c.updateOportunidad");
            action.setParams({ 'idOpp' : idOpp,
                              'programa' : programaSelected,
                              'innovationWS' : innovationWSSelected,				// SCM - Nuevo campo Innovation_Work_Stream__c
                              'proyInductor1Str' : JSON.stringify(proyInductor1),
                              'proyInductor2Str' : JSON.stringify(proyInductor2),
                              'proyInductor3Str' : JSON.stringify(proyInductor3),
                              'proyInductor4Str' : JSON.stringify(proyInductor4)
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var response = response.getReturnValue();
                console.log('response: ', response);
                
                helper.hideSpinner(component);
                
                var results = JSON.parse(response);
                
                if (state === "SUCCESS" && results['status'] == 'Ok') {
                    
                    component.set("v.opp", results['opportunity']);
                    helper.checkChanged(component, helper);
                    
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': $A.get("$Label.c.CRM_ProyI_D_i_ToastTitulo"),
                        'message': $A.get("$Label.c.CRM_ProyI_D_i_GuardadoMsg"),
                        'type': 'success'
                    });
                    showToast.fire();
                    
                    $A.get('e.force:refreshView').fire();
                }else{
                    
                    var warn = results['warnings'];                    
                    
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title': $A.get("$Label.c.CRM_ProyI_D_i_ToastTitulo"),
                        'message': $A.get("$Label.c.CRM_ProyI_D_i_ActualizaErrorMsg") + warn.join(),
                        'type': 'error'
                    });
                    showToast.fire();
                }
            });
            $A.enqueueAction(action);      
        }
    },
    
    checkChanged : function(component, event, helper) {
        helper.checkChanged(component, helper);
    }
    
})
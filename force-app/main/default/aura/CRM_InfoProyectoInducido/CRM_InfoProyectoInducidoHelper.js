({
	getDatosSAP: function (component, helper) {
        var action = component.get('c.getDatosSAP');

        this.showSpinner(component);
        
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var results = JSON.parse(response.getReturnValue());
                console.log('results:  ', results);
                
                if(results['status'] == 'Ok') {
                    var mProyInductores = results['mProyInductores'];                
                    mProyInductores.sort(function (a, b) {
                        var textA = helper.removeAccents(a.label.toUpperCase());
                        var textB = helper.removeAccents(b.label.toUpperCase());
                        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
                    });                    
                    component.set('v.proyInductorOptions', mProyInductores);
                    
                    var mProgramasSAP = results['mProgramas'];                
                    mProgramasSAP.sort(function (a, b) {
                        var textA = helper.removeAccents(a.label.toUpperCase());
                        var textB = helper.removeAccents(b.label.toUpperCase());
                        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
                    });
                    var mProgramas = mProgramasSAP.filter(function (element) {
                        var locale = $A.get("$Locale.language");
                        return (element.lang) ? (locale == 'es' && element.lang == 'S') ? true : (locale == 'en' && element.lang == 'E') : true;
                    });
                    component.set('v.programaOptions', mProgramas);
                    
                    var mTiposInduccionSAP = results['mTiposInduccion'];                
                    mTiposInduccionSAP.sort(function (a, b) {
                        var textA = helper.removeAccents(a.label.toUpperCase());
                        var textB = helper.removeAccents(b.label.toUpperCase());
                        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
                    });
                    var mTiposInduccion = mTiposInduccionSAP.filter(function (element, index) {
                        var locale = $A.get("$Locale.language");
                        return (element.lang) ? (locale == 'es' && element.lang == 'S') ? true : (locale == 'en' && element.lang == 'E') : true;
                    });
                    component.set('v.tipoInduccionOptions', mTiposInduccion);
                }
            } 
            
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
    },
    
    checkChanged : function(component, helper) {
        var opp = component.get("v.opp"); 
        
        var programaSelected = component.find("programa").get("v.value");
        var proyInductor1Selected = component.find("proyInductor1").get("v.value");
        var proyInductor2Selected = component.find("proyInductor2").get("v.value");
        var proyInductor3Selected = component.find("proyInductor3").get("v.value");
        var proyInductor4Selected = component.find("proyInductor4").get("v.value");
        var tipoInduccion1Selected = component.find("tipoInduccion1").get("v.value");
        var tipoInduccion2Selected = component.find("tipoInduccion2").get("v.value");
        var tipoInduccion3Selected = component.find("tipoInduccion3").get("v.value");
        var tipoInduccion4Selected = component.find("tipoInduccion4").get("v.value");
        var innovationWSSelected = component.find("innovationWS").get("v.value");	// SCM - Nuevo campo Innovation_Work_Stream__c
        
        /*return (programaSelected != opp.Programa_Inductor__c || proyInductor1Selected != opp.Proyecto_Inductor_1__c || proyInductor2Selected != opp.Proyecto_Inductor_2__c || 
                proyInductor3Selected != opp.Proyecto_Inductor_3__c || proyInductor4Selected != opp.Proyecto_Inductor_4__c || tipoInduccion1Selected != opp.Tipo_Induccion_1__c || 
                tipoInduccion2Selected != opp.Tipo_Induccion_2__c || tipoInduccion3Selected != opp.Tipo_Induccion_3__c || tipoInduccion4Selected != opp.Tipo_Induccion_4__c);*/
        
        var changed = (programaSelected != opp.Programa_Inductor__c || innovationWSSelected != opp.Innovation_Work_Stream__c || // SCM - Nuevo campo Innovation_Work_Stream__c
                       proyInductor1Selected != opp.Proyecto_Inductor_1__c || proyInductor2Selected != opp.Proyecto_Inductor_2__c || 
                proyInductor3Selected != opp.Proyecto_Inductor_3__c || proyInductor4Selected != opp.Proyecto_Inductor_4__c || tipoInduccion1Selected != opp.Tipo_Induccion_1__c || 
                tipoInduccion2Selected != opp.Tipo_Induccion_2__c || tipoInduccion3Selected != opp.Tipo_Induccion_3__c || tipoInduccion4Selected != opp.Tipo_Induccion_4__c);
        console.log("changed", changed);
        
        component.set("v.canChange", !changed);
    },
        
    removeAccents: function (str) {
        var chars = {
            "á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
            "à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u", "ñ": "n",
            "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U",
            "À": "A", "È": "E", "Ì": "I", "Ò": "O", "Ù": "U", "Ñ": "N"
        }
        var expr = /[áàéèíìóòúùñ]/ig;
        var res = str.replace(expr, function (e) { return chars[e] });
        return res;
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component) {     
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    }, 
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component){        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    checkValidations : function(component, event, helper) {
        var error = false; var msg = '';
        
        var programaValue = component.find("programa").get("v.value");
        var proyInductor1Value = component.find("proyInductor1").get("v.value");
        var proyInductor2Value = component.find("proyInductor2").get("v.value");
        var proyInductor3Value = component.find("proyInductor3").get("v.value");
        var proyInductor4Value = component.find("proyInductor4").get("v.value");
        var tipoInduccion1Value = component.find("tipoInduccion1").get("v.value");
        var tipoInduccion2Value = component.find("tipoInduccion2").get("v.value");
        var tipoInduccion3Value = component.find("tipoInduccion3").get("v.value");
        var tipoInduccion4Value = component.find("tipoInduccion4").get("v.value");
                        
       if((error = ($A.util.isEmpty(programaValue) && !($A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value))))) {
            msg = $A.get("$Label.c.CRM_ProyI_D_i_ProgProyErrorMsg");
        } /*else if((error = (!$A.util.isEmpty(programaValue) && ($A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value) || $A.util.isEmpty(proyInductor1Value))))) {
            msg = $A.get("$Label.c.CRM_ProyI_D_i_ProgErrorMsg");
            //Para que se pueda generar solo con el programa
        }*/ else if((error = ($A.util.isEmpty(proyInductor1Value) && !$A.util.isEmpty(tipoInduccion1Value) ||
                            ($A.util.isEmpty(proyInductor2Value) && !$A.util.isEmpty(tipoInduccion2Value)) ||
                            ($A.util.isEmpty(proyInductor3Value) && !$A.util.isEmpty(tipoInduccion3Value)) || 
                            ($A.util.isEmpty(proyInductor4Value) && !$A.util.isEmpty(tipoInduccion4Value))
                           ))) {
            msg = $A.get("$Label.c.CRM_ProyI_D_i_ProyErrorMsg");
        } else if((error = (!$A.util.isEmpty(proyInductor1Value) && $A.util.isEmpty(tipoInduccion1Value) ||
                            (!$A.util.isEmpty(proyInductor2Value) && $A.util.isEmpty(tipoInduccion2Value)) ||
                            (!$A.util.isEmpty(proyInductor3Value) && $A.util.isEmpty(tipoInduccion3Value)) || 
                            (!$A.util.isEmpty(proyInductor4Value) && $A.util.isEmpty(tipoInduccion4Value))
                           ))) {
            msg = $A.get("$Label.c.CRM_ProyI_D_i_TipoErrorMsg");
        }
      //  console.log('error', error);
        
      /*  if(error) {
            var showToast = $A.get("e.force:showToast");
            showToast.setParams({
                'title': $A.get("$Label.c.CRM_ProyI_D_i_ToastTitulo"),
                'message': msg,
                'type': 'error'
            });
            showToast.fire();
        }*/
        
        return error;
    }
    
})
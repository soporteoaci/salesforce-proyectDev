({
    getContratoInfo : function(component, event, helper) {
        var tipo = component.get("v.sobjecttype");
        var action = component.get("c.getInfoContrato");
       // console.log('Entro en getContratoInfo');
        //console.log('record id: ' + component.get("v.recordId"));
        //console.log('tipo de objeto: ' +component.get("v.sobjecttype"));
        action.setParams({
            "objectId": component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var contrato=response.getReturnValue();
               // helper.setContratoInfo(component, event, helper, contrato);
          		
                var jsonContrato= JSON.parse(contrato);
                component.set("v.estadoContrato",jsonContrato.estado);
                if(jsonContrato.reqsPresencia==null && jsonContrato.situacionActualContrato==null ){
                    console.log('CONTRATO VACIO');
                    component.set("v.contratoVacio",true);
                   // component.set("v.loadtab3",true);
                }
                console.log('YA TENGO EL CONTRATO');
                component.set("v.contrato",contrato);
                console.log('contrato desactualizado?  -->  '+jsonContrato.contratoDesactualizado);
                component.set("v.contratoDesactualizado",jsonContrato.contratoDesactualizado);
                component.set("v.puedeModificar", jsonContrato.puedeModificar);
            	//component.set("v.puedeModificar", true);
                
                
                
            } else {
                console.log("KO-getContratoInfo"); 
            }   
        });
        $A.enqueueAction(action);
    },
    
    getDivisaInfo: function (component, event, helper){
        
        var action = component.get("c.getMonedaOptions");
      //  console.log('Entro en getDIVISAS');
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var lista=response.getReturnValue();
                var jsonListaDivisas= JSON.parse(lista).monedas;
                
                component.set("v.listDivisa",jsonListaDivisas);
               // console.log(jsonListaDivisas);
                
            } else {
               // console.log("KO-getListaMonedas"); 
            }   
        });
        $A.enqueueAction(action);
    
    },
    
    
    setContratoInfo : function(component, event, helper, contrato ) {
        var start = component.get("v.startTime");
        console.log(start);
        var end = component.get("v.endTime");
        console.log(end);
        var timeTake = end - start;
        console.log('Tiempo transcurrido en segundos');
        console.log(timeTake/1000);
        var jsonContrato= JSON.parse(contrato);
      //  console.log(jsonContrato);
       // if(! component.get("v.contratoVacio")){
             if(true){
           // console.log('El contrato NO ESTA VACIO y seteo todo');
        helper.manageReqPresencialidad(component, event, helper, contrato);
        helper.manageSituacionActual(component, event, helper, contrato);
        helper.manageAsistenciaJuridica(component, event, helper, contrato);
        }else{
           // console.log('Como el contrato ESTA VACIO no seteo nada');
           // helper.activeAllTabs(component, event, helper);
             //helper.manageAsistenciaJuridica(component, event, helper, contrato);
        }
        
    },
    
    setContratoNewTry : function(component, event, helper, contrato ) {
        var start = component.get("v.startTime");
        console.log(start);
        var end = component.get("v.endTime");
        console.log(end);
        var timeTake = end - start;
        console.log('Tiempo transcurrido en segundos');
        console.log(timeTake/1000);
        var jsonContrato= JSON.parse(contrato);
        
        var endReq;
        var endSit;
        var endAsis;
        
        helper.promesaRequisito(component, helper, event, contrato)
        .then($A.getCallback(function(result) {
            return helper.promesaSitActual(component, helper,event, contrato);
        }),
              $A.getCallback(function(error) {
            console.log("Promise 2 was rejected: ", error);
            //return errorRecoveryPromise();
        })
              
        ).
        then($A.getCallback(function(result) {
            return helper.promesaPrevision(component, helper,event, contrato);
        }),$A.getCallback(function(error) {
            console.log("Promise 3 was rejected: ", error);
            //return errorRecoveryPromise();
        } )
             ).then($A.getCallback(function(result) {
            return helper.promesaAsistencia(component, helper,event, contrato);
        }),$A.getCallback(function(error) {
            console.log("Promise 4 was rejected: ", error);
            //return errorRecoveryPromise();
        } )
             )
 
        
    },
    
    promesaRequisito : function(component, helper, event, contrato) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var result = helper.manageReqPresencialidad(component, event, helper, contrato);
      if (result=='OK') {
          console.log('promesa 1 cumplida');
          
        resolve("Resolved");
      }
      else {
          console.log('promesa 1 fallida');
        reject("Rejected");
      }
    }));

        
    },
    
    promesaSitActual : function(component, helper, event, contrato ) {
        return new Promise($A.getCallback(function(resolve, reject) {
             var result = helper.manageSituacionActual(component, event, helper, contrato);
            if (result=='OK') {
                console.log('promesa 2 cumplida');
                
                resolve("Resolved");
            }
            else {
                console.log('promesa 2 fallida');
                reject("Rejected");
            }
        }));
    },
    
    promesaAsistencia : function( component, helper, event, contrato ) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var result = helper.manageAsistenciaJuridica(component, event, helper, contrato);
            if (result=='OK') {
                console.log('promesa 3 cumplida');
                resolve("Resolved");
            }
            else {
                console.log('promesa 3 fallida');
                reject("Rejected");
            }
        }));
    },
    
     promesaPrevision : function( component, helper, event, contrato ) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var result = helper.managePrevSituacionFutura(component, event, helper, contrato);
            if (result=='OK') {
                console.log('promesa 2 Prevision cumplida');
                resolve("Resolved");
            }
            else {
                console.log('promesa 2 Prevision fallida');
                reject("Rejected");
            }
        }));
    },
    
    activeAllTabs : function (component, event, helper){
        
       // console.log('Activo todas la pestaña 3');
      
         
         component.find("tabContrato").set("v.selectedTabId", "tab3");
        
      
    },
    
    createJsonInfo : function(component, event, helper) {
       //  console.log('Tab 1: '+ component.get("v.loadtab1"));
       // console.log('Tab 2: '+ component.get("v.loadtab2"));
       // console.log('Tab 3: '+ component.get("v.loadtab3"));
        
        var faltaRellenarCampo=false;
        var falloSeccion;
        
        var asistenciaJuridica=false;
        var docIncidencias=false;
        var codAji=null;
        var causaResolucion='';
        var causaRetraso='' ;
        var causaSuspension='' ;
        var costesReclamarResolucion= null;
        var costesReclamarSuspension=null ;
        var costesTotalesResolucion=null;
        var costesTotalesSuspension=null;
        var derechoReclamacionSuspension=false;
        var derechoReclamacionResolucion=false;
        var estimacionCosteExtraRetraso=null ;
        var estimacionCosteExtraNormalidad=null ;
        var estimacionMesesRetraso=null;
        var negociacionModificacionContrato=false;
        var negociacionModificacionFinalizada=false;
        var negociacionAceptada=false;
        var previsionCostesExtra=false;
        var reqsPresencia;
        var situacionActualContrato;
        var costesReclamarResolucionLocal=null;
        var costesReclamarSuspensionLocal=null;
        var costesTotalesResolucionLocal=null;
        var costesTotalesSuspensionLocal=null;
        var costesAceptadosSus=null;
        var costesAceptadosRes=null;
        var costesReclamarRetraso=null;
        var costesAceptadosRetraso=null;
        var estimacionCosteExtraRetrasoLocal=null;
        var estimacionCosteExtraNormalidadLocal=null;
        var moneda='';
        var previsionSituacionContrato;
        
        var loaded=false;
        
        //Recojo datos de la TAB1 de Requisitos de presencialidad
        component.find("tabContrato").set("v.selectedTabId", "tab1");
        
        if(component.find("NoExige").get("v.checked")){
            reqsPresencia = 'R10';
        }else if(component.find("siExigePersonal").get("v.checked")){
            reqsPresencia = 'R20';
        }else if(component.find("siExigeGob").get("v.checked")){
            reqsPresencia = 'R21';
        }else if(component.find("siExigeCli").get("v.checked")){
            reqsPresencia = 'R22';
        }else if(component.find("siExigeAyesa").get("v.checked")){
            reqsPresencia = 'R23';
        }else {
            faltaRellenarCampo=true;
            falloSeccion = "tab1"
            helper.setErrorValidityMessage(component, event, helper, falloSeccion);
        }
        
        if(!faltaRellenarCampo){
            

            //Recojo datos de la TAB2 de Situacion Actual de contrato
            component.find("tabContrato").set("v.selectedTabId", "tab2");
            
            //---------------------     NORMALIDAD     ---------------------------------------  // <!--
            if(component.find("normalidad").get("v.checked")){

                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'normalidad');
                //console.log('faltaRellenarCampo: '+faltaRellenarCampo);
                if(!faltaRellenarCampo){
                    situacionActualContrato = 'S10';
              /*      previsionCostesExtra = component.find("normCostesExtra").get("v.value")=='true'? true:false;//Comprobar que no es NO
                  // // estimacionCosteExtraNormalidad= previsionCostesExtra? component.find("normValorCostes").get("v.value") : null; //COEMNTADO ANTES DEL 2 de ABRIL
                    
                    estimacionCosteExtraNormalidadLocal= previsionCostesExtra? component.find("normValorCostesLocal").get("v.value") : null;
                    moneda= previsionCostesExtra? component.find("normMonedaLocal").get("v.value") : '';  */
                    
                }
                //FALTA DIVISA E IMPORTE EN MONEDA LOCAL  
                
                
            //---------------------     PREVSION RETRASOS     ---------------------------------------    
            }else if(component.find("previsionRetrasos").get("v.checked")){
                
                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'previsionRetrasos');
                
                if(!faltaRellenarCampo){
                    situacionActualContrato = 'S11';
                    
                    causaRetraso = component.find("selectCausaRetraso").get("v.value") ;
                    estimacionMesesRetraso =  component.find("mesesRetraso").get("v.value");
                    //estimacionCosteExtraRetraso = component.find("retrasoCostesExtra").get("v.value");
                    negociacionModificacionContrato = component.find("retrasoNegociacion").get("v.value");
                    if(negociacionModificacionContrato=='true'){
                    negociacionModificacionFinalizada = component.find("negFinalizada").get("v.value");
                        }
                    
                    estimacionCosteExtraRetrasoLocal= component.find("retrasoCostesExtraLocal").get("v.value");

                    costesAceptadosRetraso= component.find("retrasoCostesAceptados").get("v.value");
        		 	costesReclamarRetraso = component.find("retrasoCostesReclamar").get("v.value");
                  //  console.log(costesAceptadosRetraso);
                  //  console.log(costesReclamarRetraso);
                    moneda=component.find("retrasoMonedaLocal").get("v.value");  
                    
                 }
            //---------------------     NO RETRASOS Y NEGOCIACION     ---------------------------------------    
            }else if(component.find("noRetrasoYNegociacion").get("v.checked")){
                
                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'noRetraso');
                if(!faltaRellenarCampo){
                situacionActualContrato = 'S12';
                    negociacionAceptada = component.find("noRetrasoYNegociacionAceptada").get("v.value");
                    
                }
                
            //---------------------     SUSPENSION TEMPORAL     ---------------------------------------    
            }else if(component.find("suspensionTemporal").get("v.checked")){
                
                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'suspensionTemporal');
                
                 if(!faltaRellenarCampo){
                situacionActualContrato = 'S20';
                causaSuspension = component.find("causaSuspension").get("v.value") ;
                derechoReclamacionSuspension =  component.find("derechoReclamacion").get("v.value")=='true'? true:false;;
                     
                   //  costesReclamarSuspension= derechoReclamacionSuspension? component.find("costesReclamarSus").get("v.value") : null;
                   //  costesTotalesSuspension= derechoReclamacionSuspension? component.find("costesTotalesSus").get("v.value") : null;
                     
                     costesTotalesSuspensionLocal= derechoReclamacionSuspension? component.find("costesTotalesSusLocal").get("v.value") : null;
                     costesReclamarSuspensionLocal= derechoReclamacionSuspension? component.find("costesReclamarSusLocal").get("v.value"): null;
                     costesAceptadosSus= derechoReclamacionSuspension? component.find("costesAceptadosSusLocal").get("v.value"): null;
                     moneda= derechoReclamacionSuspension? component.find("suspensionMonedaLocal").get("v.value"): '';  
               
                 }
            //---------------------     RESOLUCION     ---------------------------------------   
            }else if(component.find("contratoResuelto").get("v.checked")){
                
                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'contratoResuelto');
                
                 if(!faltaRellenarCampo){
                     situacionActualContrato = 'S30';
                     causaResolucion = component.find("causaResolucion").get("v.value") ;
                     derechoReclamacionResolucion =  component.find("derechoRecResolucion").get("v.value")=='true'? true:false;;
                     
                     //costesReclamarResolucion= derechoReclamacionResolucion? component.find("costesReclamarRes").get("v.value") : null;
                     //costesTotalesResolucion= derechoReclamacionResolucion? component.find("costesTotalesRes").get("v.value") : null;
                     
                     costesTotalesResolucionLocal= derechoReclamacionResolucion? component.find("costesTotalesResLocal").get("v.value") : null;
                     costesReclamarResolucionLocal= derechoReclamacionResolucion? component.find("costesReclamarResLocal").get("v.value"): null;
                     costesAceptadosRes= derechoReclamacionResolucion? component.find("costesAceptadosResLocal").get("v.value"): null;
                     
                     moneda= derechoReclamacionResolucion? component.find("resolucionMonedaLocal").get("v.value"):'';  
                 }
            }else{
                faltaRellenarCampo=true;
                falloSeccion = "tab2";
                helper.setErrorValidityMessage(component, event, helper, falloSeccion);
            }
            
        }
        
        if(!faltaRellenarCampo){
            component.find("tabContrato").set("v.selectedTabId", "tabPrev2"); 
            
            if(component.find("PrevNormalidad").get("v.checked")){
            previsionSituacionContrato = 'S10';
        }else if(component.find("PrevPrevisionRetrasos").get("v.checked")){
            previsionSituacionContrato = 'S11';
        }else if(component.find("PrevNoRetrasoYNegociacion").get("v.checked")){
            previsionSituacionContrato = 'S12';
        }else if(component.find("PrevSuspensionTemporal").get("v.checked")){
            previsionSituacionContrato = 'S20';
        }else if(component.find("PrevContratoResuelto").get("v.checked")){
            previsionSituacionContrato = 'S30';
        }else {
            faltaRellenarCampo=true;
            falloSeccion = "tabPrev2"
            helper.setErrorValidityMessage(component, event, helper, falloSeccion);
        }
            
        }
        
        if(!faltaRellenarCampo){
            component.find("tabContrato").set("v.selectedTabId", "tab3"); 
            
                //Recojo datos de la TAB3 de Asistencia Juridica
               // console.log('CHECK de asistencia juridica');
                //component.find("tabContrato").set("v.selectedTabId", "tab3"); 
                faltaRellenarCampo = helper.checkValidityFields(component, event, helper, 'asistenciaJuridica');
                if(!faltaRellenarCampo){
                    docIncidencias= component.find("asisJuridica").get("v.value");
                    codAji= docIncidencias=='true'?component.find("codigoAji").get("v.value"):null;
                    asistenciaJuridica= true;
                    
                }else{
                    faltaRellenarCampo=true;
                    falloSeccion = "tab2";
                    helper.setErrorValidityMessage(component, event, helper, 'tab3');
                }
            
            
            
            
        }
        
        if(!faltaRellenarCampo){
            
            var jsonContrato = '{"docIncidencias" : ' + docIncidencias + ',';   
            jsonContrato = jsonContrato + '"asistenciaJuridica" : '  + asistenciaJuridica +',';
            jsonContrato = jsonContrato + '"codAji" : "'  + codAji +'",';
            jsonContrato = jsonContrato + '"causaResolucion" : "'  + causaResolucion +'",';
            jsonContrato = jsonContrato + '"causaRetraso" : "'  + causaRetraso + '",';
            jsonContrato = jsonContrato + '"causaSuspension" : "'  + causaSuspension + '",';
           // jsonContrato = jsonContrato + '"costesReclamarResolucion" : ' + costesReclamarResolucion + ','; //Modificada para que pueda recibir filas alfanuméricas
           // jsonContrato = jsonContrato + '"costesReclamarSuspension" : '  + costesReclamarSuspension + ',';
           // jsonContrato = jsonContrato + '"costesTotalesResolucion" : '  + costesTotalesResolucion + ',';
           // jsonContrato = jsonContrato + '"costesTotalesSuspension" : '  + costesTotalesSuspension + ',';
            jsonContrato = jsonContrato + '"derechoReclamacionSuspension" : '  + derechoReclamacionSuspension + ',';
            jsonContrato = jsonContrato + '"derechoReclamacionResolucion" : '  + derechoReclamacionResolucion + ',';
            jsonContrato = jsonContrato + '"negociacionAceptada" : '  + negociacionAceptada + ',';
            jsonContrato = jsonContrato + '"estimacionCosteExtraRetraso" : '  + estimacionCosteExtraRetraso + ',';
            jsonContrato = jsonContrato + '"estimacionCosteExtraNormalidad" : '  + estimacionCosteExtraNormalidad + ',';
            jsonContrato = jsonContrato + '"estimacionMesesRetraso" : '  + estimacionMesesRetraso + ',';
            jsonContrato = jsonContrato + '"negociacionModificacionContrato" : '  + negociacionModificacionContrato + ',';
            jsonContrato = jsonContrato + '"negociacionModificacionFinalizada" : '  + negociacionModificacionFinalizada + ',';          
            jsonContrato = jsonContrato + '"previsionCostesExtra" : '  + previsionCostesExtra + ',';         
            jsonContrato = jsonContrato + '"costesReclamarRetraso" : '  + costesReclamarRetraso + ',';
            jsonContrato = jsonContrato + '"costesAceptadosRetraso" : '  + costesAceptadosRetraso + ',';         
            jsonContrato = jsonContrato + '"costesReclamarResolucionLocal" : '  + costesReclamarResolucionLocal + ',';
            jsonContrato = jsonContrato + '"costesReclamarSuspensionLocal" : '  + costesReclamarSuspensionLocal + ',';
            jsonContrato = jsonContrato + '"costesTotalesResolucionLocal" : '  + costesTotalesResolucionLocal + ',';
            jsonContrato = jsonContrato + '"costesTotalesSuspensionLocal" : '  + costesTotalesSuspensionLocal + ',';
            jsonContrato = jsonContrato + '"costesAceptadosSus" : '  + costesAceptadosSus + ',';
            jsonContrato = jsonContrato + '"costesAceptadosRes" : '  + costesAceptadosRes + ',';
            jsonContrato = jsonContrato + '"estimacionCosteExtraRetrasoLocal" : '  + estimacionCosteExtraRetrasoLocal + ',';
            jsonContrato = jsonContrato + '"estimacionCosteExtraNormalidadLocal" : '  + estimacionCosteExtraNormalidadLocal + ',';           
            jsonContrato = jsonContrato + '"reqsPresencia" : "'  + reqsPresencia + '",';
            jsonContrato = jsonContrato + '"moneda" : "'  + moneda + '",';
            jsonContrato = jsonContrato + '"previsionSituacionContrato" : "'  + previsionSituacionContrato + '",'
            jsonContrato = jsonContrato + '"situacionActualContrato" : "'  + situacionActualContrato + '"';
            
            jsonContrato = jsonContrato + '}';
            
          //  console.log(jsonContrato);
            
            
            helper.updateInfoContrato(component, event, helper, jsonContrato);
            
            
            //component.find("tabContrato").set("v.selectedTabId", "tab2");
            var currentTab= component.get("v.currentTabWhenSave");
            component.find("tabContrato").set("v.selectedTabId", currentTab);
            
            
            
        }
    },
    
    updateInfoContrato : function(component, event, helper, jsonContrato){
        
        var action = component.get("c.updateInfoContrato");
      //  console.log('Entro en UPDATE CONTRATO');
       // console.log('record id: ' + component.get("v.recordId"));
       // console.log('tipo de objeto: ' +component.get("v.sobjecttype"));
        action.setParams({
            "objectId": component.get("v.recordId"),
            "jsonContrato": jsonContrato
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var status =response.getReturnValue();
                //helper.setContratoInfo(component, event, helper, contrato);
                //component.set("v.contrato",contrato);
                console.log('Estado de la actualización: '+status);
                if (status =='OK'){
                    component.set("v.infoStatus", true);
                    component.set("v.infoMessage", $A.get("$Label.c.GC_Info_Mensaje"));
                }
                
                
            } else {
                console.log("KO-UpdateInfo"); 
            }   
        });
        $A.enqueueAction(action);
        
        
    },
    
    blankRetraso : function(component, event, helper){
        component.find("selectCausaRetraso").set("v.value","CR0");
        component.find("mesesRetraso").set("v.value",'');
        //component.find("retrasoCostesExtra").set("v.value",'');
        component.find("retrasoNegociacion").set("v.value","NO");
        
        component.find("retrasoMonedaLocal").set("v.value","NO");
        component.find("retrasoCostesExtraLocal").set("v.value",'');
        
         component.find("retrasoCostesAceptados").set("v.value",'');
         component.find("retrasoCostesReclamar").set("v.value",'');
        
        component.find("negFinalizada").set("v.value","NO");
        var el2= component.find("pruebaDiv");
        $A.util.addClass(el2, "slds-hide");
        
    },
    
    blankNoRetraso : function(component, event, helper){
      component.find("noRetrasoYNegociacionAceptada").set("v.value","NO");  
        
    },
    
    blankNormalidad : function(component, event, helper  ){ // Comentado 2 de ABRIL
       // component.find("normCostesExtra").set("v.value","NO");
       ////// component.find("normValorCostes").set("v.value",''); Ya estaba comentado anteriormente
       // component.find("normMonedaLocal").set("v.value","NO");
      //   component.find("normValorCostesLocal").set("v.value",'');
        
      //  var el= component.find("normalidadCostesBlock");
      //  $A.util.addClass(el, "slds-hide");
        
        
    },
    
    blankSuspension : function(component, event, helper  ){
       // var el= component.find("costesSuspensionBlock");
      //  $A.util.addClass(el, "slds-hide");
        var el2= component.find("costesSuspensionBlockLocal");
        $A.util.addClass(el2, "slds-hide");
        component.find("causaSuspension").set("v.value",'');
        component.find("derechoReclamacion").set("v.value","NO");
       // component.find("costesTotalesSus").set("v.value",'');
       // component.find("costesReclamarSus").set("v.value",'');
        
         component.find("costesTotalesSusLocal").set("v.value",'');
        component.find("costesReclamarSusLocal").set("v.value",'');
        
         component.find("suspensionMonedaLocal").set("v.value","NO");
        
    },
    
    blankResolucion : function(component, event, helper  ){
        
      //  var el= component.find("costesResolucionBlock");
       // $A.util.addClass(el, "slds-hide");
         var el2= component.find("costesResolucionBlockLocal");
         $A.util.addClass(el2, "slds-hide");
        
       // component.find("costesTotalesRes").set("v.value",'');
        component.find("causaResolucion").set("v.value",'');
        // component.find("costesReclamarRes").set("v.value",'');
        component.find("derechoRecResolucion").set("v.value","NO");
        
        component.find("costesTotalesResLocal").set("v.value",'');
        component.find("costesReclamarResLocal").set("v.value",'');
         component.find("resolucionMonedaLocal").set("v.value","NO");
       
        
    },
    
    checkValidityFields : function(component,event, helper, seccion){
        var fallo = false;
        switch (seccion) {
            case 'normalidad' :  ////COMENTADO EL 2 de ABRIL
             //   console.log('Chequeo NORMALIDAD');
             /*   var checkPrevCostes = component.find("normCostesExtra").get("v.value");
                console.log(checkPrevCostes);
			  //var importeRelleno =  component.find("normValorCostes").get("v.validity").valid; //si vuelve, añadir a al "else if" para validación //COMENTADO EL 2 de ABRIL
                var importeLocalRelleno =  component.find("normValorCostesLocal").get("v.validity").valid;
                var moneda =  component.find("normMonedaLocal").get("v.value");
                if(checkPrevCostes=='NO'){
                    console.log('falta rellenar check');
                    fallo = true;
                    helper.setErrorValidityMessage(component, event, helper, 'campos');
                }else if(checkPrevCostes == 'true' && ( importeLocalRelleno==false || moneda=='NO' ) ){
                    console.log('falta rellenar importe');
                    fallo = true;    
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                }else{
                    
                }*/
              
                break;
            case 'previsionRetrasos' :
                console.log('Chequeo PREVISION');
                var causa = component.find("selectCausaRetraso").get("v.value");
                //var importeRelleno =  component.find("retrasoCostesExtra").get("v.validity").valid;
                var importeLocalRelleno =  component.find("retrasoCostesExtraLocal").get("v.validity").valid;
                
                 var importeAceptadorelleno= component.find("retrasoCostesAceptados").get("v.validity").valid;
        		 var importeReclamarRelleno = component.find("retrasoCostesReclamar").get("v.validity").valid;
                
                var moneda =  component.find("retrasoMonedaLocal").get("v.value");
                 var mesesRelleno =  component.find("mesesRetraso").get("v.validity").valid;
                var checkNegociacion = component.find("retrasoNegociacion").get("v.value");
                 var checkNegFinalizada = component.find("negFinalizada").get("v.value");
              //  console.log('Negociacion : '+checkNegFinalizada);
              //  console.log('Negociacion finalizada: '+checkNegFinalizada);
                
                
                
                if(causa=='CR0' || checkNegociacion=='NO' || (checkNegociacion=='true' && checkNegFinalizada=='NO')  || !mesesRelleno || !importeLocalRelleno || !importeAceptadorelleno || !importeReclamarRelleno || moneda=='NO' ){ //Si se incluye de nuevo el importe en euros, colocarlo en el OR
                //    console.log('faltan campos por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                }
                break;
                
            case 'noRetraso':
                console.log('Chequeo NO RETRASO PERO NEGOCIO');
                var checkNegociacion = component.find("noRetrasoYNegociacionAceptada").get("v.value");
                if(checkNegociacion=='NO' ){ 
                //    console.log('faltan campos por rellenar');
                    fallo = true;
                    helper.setErrorValidityMessage(component, event, helper, 'campos');
                }
                
                
                break;
                
            case 'suspensionTemporal' :
                console.log('Chequeo SUSPENSION');
                
                var causaSus = component.find("causaSuspension").get("v.validity").valid;
              //  var importeTotalRelleno =  component.find("costesTotalesSus").get("v.validity").valid;
              //  var importeReclamarRelleno =  component.find("costesReclamarSus").get("v.validity").valid;
                var checkDerecho = component.find("derechoReclamacion").get("v.value");
                
                var importeTotalLocalRelleno =  component.find("costesTotalesSusLocal").get("v.validity").valid;
                var importeReclamarLocalRelleno =  component.find("costesReclamarSusLocal").get("v.validity").valid;
                 var importeAceptadoLocalRelleno =  component.find("costesAceptadosSusLocal").get("v.validity").valid;
                var moneda =  component.find("suspensionMonedaLocal").get("v.value");
               
                if(!causaSus || checkDerecho=='NO' ){
                  //  console.log('faltan campos por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                }else if(causaSus && checkDerecho=='true' && ( !importeTotalLocalRelleno || !importeReclamarLocalRelleno || !importeAceptadoLocalRelleno || moneda=='NO' )){ //Incluir los valores en euros al OR si se vuelven a añadir
                  //  console.log('faltan campo importes por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                }
                
                
                break;
            case 'contratoResuelto':
                console.log('Chequeo RESOLUCION');
                
                var causaRes = component.find("causaResolucion").get("v.validity").valid;
               // var importeTotalRellenoRes =  component.find("costesTotalesRes").get("v.validity").valid;
               // var importeReclamarRellenoRes =  component.find("costesReclamarRes").get("v.validity").valid;
                var checkDerechoRes = component.find("derechoRecResolucion").get("v.value");
                
                 var importeTotalLocalRellenoRes =  component.find("costesTotalesResLocal").get("v.validity").valid;
                var importeReclamarLocalRellenoRes =  component.find("costesReclamarResLocal").get("v.validity").valid;
                var importeAceptadoLocalRellenoRes =  component.find("costesAceptadosResLocal").get("v.validity").valid;
                var moneda =  component.find("resolucionMonedaLocal").get("v.value");
                
                if(!causaRes || checkDerechoRes=='NO' ){
                 //   console.log('faltan campos por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                    
                }else if(causaRes && checkDerechoRes=='true' && (!importeTotalLocalRellenoRes ||!importeReclamarLocalRellenoRes|| !importeAceptadoLocalRellenoRes || moneda=='NO')){ //Incluir los valores en euros al OR si se vuelven a añadir
                 //   console.log('faltan campo importes por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'campos');
                }
                
                break;
                
            case 'asistenciaJuridica':
                 console.log('Chequeo ASISTENCIA');
                
                var check= component.find("asisJuridica").get("v.value");
              //  console.log('chequeo de docuementacion juridica:');
              //  console.log(check);
                var codigo = component.find("codigoAji").get("v.validity").valid;
                if(check =='NO'){ // 27 abril - Ahora solo e snecesario responder - El codigo AJI no es obligatorio
                //  console.log('faltan campos por rellenar');
                    fallo = true;
                     helper.setErrorValidityMessage(component, event, helper, 'tab3');  
                    
                }
                break;
        }
        
        return fallo;
    },
    
    handleTabs: function (component, event, helper) {
        var tab = event.getSource();
        var contrato= component.get("v.contrato");
        //console.log('Me voy a la pestaña:--->   '+ component.get("v.tabId"));
        switch (tab.get('v.id')) {
                case 'tab1' :
               // if(component.get("v.loadtab1")==false){
                  // helper.manageReqPresencialidad(component, event, helper, contrato);  
               // }
                break;
            case 'tab2' :
                if(component.get("v.loadtab2")==false){
                    helper.manageSituacionActual(component, event, helper, contrato); 
                }
                break;
                case 'tabPrev2' :
                if(component.get("v.loadtabPrev2")==false){
                    helper.managePrevSituacionFutura(component, event, helper, contrato); 
                }
                break;
            case 'tab3':
                if(component.get("v.loadtab3")==false){
                    helper.manageAsistenciaJuridica(component, event, helper, contrato);
                }
                break;
        }
    },
    
    manageAsistenciaJuridica : function(component, event, helper, contrato) {
        // console.log(contrato);
        //console.log('asistencia juridica');
        component.find("tabContrato").set("v.selectedTabId", "tab3");
        var jsonContrato= JSON.parse(contrato);
      //  console.log(jsonContrato.docIncidencias);
        //component.set("v.loadtab3",true);
       // console.log('cargada pestaña 3?: '+component.get("v.loadtab3"));
       var check= jsonContrato.asistenciaJuridica; 
       //component.find("asisJuridica").set("v.value",check);
        if(check==true){
            var checkdoc= jsonContrato.docIncidencias?'true':'false'; 
      		 component.find("asisJuridica").set("v.value",checkdoc);
            
            if(checkdoc=='true'){
             var aji = jsonContrato.codAji;
             component.find("codigoAji").set("v.value",aji);
             var select = component.find("asisJuridicaBlock"); 
			$A.util.removeClass(select, "slds-hide");
            }
            
            if (!component.get("v.loadtab3")){
            component.find("tabContrato").set("v.selectedTabId", "tab1");
                component.set("v.loadtab3",true);
            }
           
        }else if (!component.get("v.loadtab3")){
            component.set("v.loadtab3",true); //cargo la pestaña
            component.find("tabContrato").set("v.selectedTabId", "tab1");//Vuelvo a la pestaña 1
        }
            
        
     /*   if (!component.get("v.loadtab3")){
            component.find("tabContrato").set("v.selectedTabId", "tab1");
            component.set("v.loadtab3",true);
        }*/
        
        return 'OK';
    },
    
    manageSituacionActual : function(component, event, helper, contrato) {
    // console.log('situacion actual');
        component.find("tabContrato").set("v.selectedTabId", "tab2");
        var jsonContrato= JSON.parse(contrato);
     // console.log(jsonContrato);
        if(jsonContrato.situacionActualContrato !=null){
            component.set("v.loadtab2",true);
            switch (jsonContrato.situacionActualContrato){
                case 'S10':     //NORMALIDAD    ///COMENTADO EL 2 de ABRIL              
                 /*   var el= component.find("normalidadBlock");
                    $A.util.removeClass(el, "slds-hide"); */ //  COMENTADO el 2 de ABRL
                    console.log('S10 --- 0');
                    component.find("normalidad").set("v.checked",true);
                    console.log('S10 --- 1');
                    component.find("previsionRetrasos").set("v.disabled",true);
                    component.find("noRetrasoYNegociacion").set("v.disabled",true);
                    component.find("suspensionTemporal").set("v.disabled",true);
                    component.find("contratoResuelto").set("v.disabled",true);
                    
                    //Seteo de campos
                /*    var derechoReclamacion= jsonContrato.previsionCostesExtra?'true':'false'; 
                    component.find("normCostesExtra").set("v.value",derechoReclamacion); */ //  COMENTADO el 2 de ABRL
                    
                    /*var findCheck=component.find("normCostesExtra");
                    $A.util.removeClass(findCheck, "slds-has-error");*/  //COMENTADO ANTES DEL 2 de ABRIL
                    
                 /*   if(derechoReclamacion=='true'){
                        console.log("entro en  S10 y hay costes extras"); */ //  COMENTADO el 2 de ABRL
                       /* var costes = jsonContrato.estimacionCosteExtraNormalidad;
                        component.find("normValorCostes").set("v.value",costes);*/ //COMENTADO ANTES DEL 2 de ABRIL
                       
                        //moneda local
                   /*     var costesLocal = jsonContrato.estimacionCosteExtraNormalidadLocal;
                        component.find("normValorCostesLocal").set("v.value",costesLocal);
                        var moneda = jsonContrato.moneda;
                        component.find("normMonedaLocal").set("v.value",moneda);
                        
                        var el= component.find("normalidadCostesBlock");
                        var select = component.find("normCostesExtra");
                      
						$A.util.removeClass(el, "slds-hide");*/  //COMENTADO el 2 de ABRL
                        
                       // $A.util.removeClass(select, "slds-has-error");//COMENTADO ANTES DEL 2 de ABRIL
                   // }
                    break;
                case 'S11':
                    var el= component.find("retrasoBlock");
                    $A.util.removeClass(el, "slds-hide"); 
                 //   console.log(component.find("previsionRetrasos"));
                    component.find("previsionRetrasos").set("v.checked",true);
                    component.find("normalidad").set("v.disabled",true);
                    component.find("noRetrasoYNegociacion").set("v.disabled",true);
                    component.find("suspensionTemporal").set("v.disabled",true);
                    component.find("contratoResuelto").set("v.disabled",true);
                    
                    //seteo de campos
                    
                    component.find("selectCausaRetraso").set("v.value",jsonContrato.causaRetraso);
                	//component.find("retrasoCostesExtra").set("v.value",jsonContrato.estimacionCosteExtraRetraso);
                     component.find("mesesRetraso").set("v.value",jsonContrato.estimacionMesesRetraso);
                    
                   //moneda local
                    component.find("retrasoCostesExtraLocal").set("v.value",jsonContrato.estimacionCosteExtraRetrasoLocal);
                    component.find("retrasoCostesAceptados").set("v.value", jsonContrato.costesAceptadosRetraso);
        		    component.find("retrasoCostesReclamar").set("v.value", jsonContrato.costesReclamarRetraso);
                    
                    component.find("retrasoMonedaLocal").set("v.value",jsonContrato.moneda);                    
                 	
                   
                 //   console.log('CHECK DE MODIFICACION DE CONTRATO');
                    var checkNuevo= jsonContrato.negociacionModificacionContrato?'true':'false';
                	component.find("retrasoNegociacion").set("v.value",checkNuevo);
                  //   console.log(checkNuevo);
                   
                    if(checkNuevo == 'true'){
                  //      console.log("ENTRO EN EL TRUEEEEEE");
                        
                        var hola= component.find("pruebaDiv");
                        $A.util.removeClass(hola, "slds-hide");
                        var checkFin= jsonContrato.negociacionModificacionFinalizada?'true':'false';
                     component.find("negFinalizada").set("v.value",checkFin);
                        
                    }
                    
                    
                    break;
                case 'S12':
                    component.find("noRetrasoYNegociacion").set("v.checked",true);
                    component.find("previsionRetrasos").set("v.disabled",true);
                    component.find("normalidad").set("v.disabled",true);
                    component.find("suspensionTemporal").set("v.disabled",true);
                    component.find("contratoResuelto").set("v.disabled",true);
                    
                    var el= component.find("noRetrasoYNegociacionBlock"); 
                    $A.util.removeClass(el, "slds-hide");
                    
                    var check= jsonContrato.negociacionAceptada?'true':'false';
                    component.find("noRetrasoYNegociacionAceptada").set("v.value", check);
                    
                    
                    
                    break;
                case 'S20':
                    var el= component.find("suspendidoBlock");
                    $A.util.removeClass(el, "slds-hide"); 
                    component.find("suspensionTemporal").set("v.checked",true);
                    component.find("previsionRetrasos").set("v.disabled",true);
                    component.find("noRetrasoYNegociacion").set("v.disabled",true);
                    component.find("normalidad").set("v.disabled",true);
                    component.find("contratoResuelto").set("v.disabled",true);
                     //seteo de campos
                    
                    component.find("causaSuspension").set("v.value",jsonContrato.causaSuspension);
                    
                    var checkSus= jsonContrato.derechoReclamacionSuspension?'true':'false';
                	component.find("derechoReclamacion").set("v.value",checkSus);
                    
                    if(checkSus=='true'){
                        /*var costesSus = jsonContrato.costesTotalesSuspension;
                        component.find("costesTotalesSus").set("v.value",costesSus);
                        
                         var costesRecSus = jsonContrato.costesReclamarSuspension;
                        component.find("costesReclamarSus").set("v.value",costesRecSus);*/
                        
                         //moneda local
                        component.find("costesTotalesSusLocal").set("v.value",jsonContrato.costesTotalesSuspensionLocal);   
                     //   console.log('1');
                        component.find("costesReclamarSusLocal").set("v.value",jsonContrato.costesReclamarSuspensionLocal);
                      //  console.log('2');
                        component.find("suspensionMonedaLocal").set("v.value",jsonContrato.moneda);        
                      //  console.log('3');
                        component.find("costesAceptadosSusLocal").set("v.value",jsonContrato.costesAceptadosSus); 
                       // console.log('4');
                        
                       //  var el= component.find("costesSuspensionBlock");
                       // $A.util.removeClass(el, "slds-hide");
                         var el2= component.find("costesSuspensionBlockLocal");
        				$A.util.removeClass(el2, "slds-hide");
                        
                       /* var select = component.find("derechoReclamacion");
                        $A.util.removeClass(select, "slds-has-error");*/
                        
                    }

                    break;
                case 'S30':
                    var el= component.find("resueltoBlock");
                    $A.util.removeClass(el, "slds-hide"); 
                    component.find("contratoResuelto").set("v.checked",true);
                    component.find("previsionRetrasos").set("v.disabled",true);
                    component.find("noRetrasoYNegociacion").set("v.disabled",true);
                    component.find("suspensionTemporal").set("v.disabled",true);
                    component.find("normalidad").set("v.disabled",true);
                    
                    //seteo de campos
                    
                    component.find("causaResolucion").set("v.value",jsonContrato.causaResolucion);
                    
                    var checkRes= jsonContrato.derechoReclamacionResolucion?'true':'false';
                	component.find("derechoRecResolucion").set("v.value",checkRes);
                    
                    if(checkRes=='true'){
                      //  var costesRes = jsonContrato.costesTotalesResolucion;
                      //  component.find("costesTotalesRes").set("v.value",costesRes);
                         
                       //  var costesRecRes = jsonContrato.costesReclamarResolucion;
                      //  component.find("costesReclamarRes").set("v.value",costesRecRes);
                        
                        //moneda local
                        component.find("costesTotalesResLocal").set("v.value",jsonContrato.costesTotalesResolucionLocal);   
                        component.find("costesReclamarResLocal").set("v.value",jsonContrato.costesReclamarResolucionLocal);  
                        component.find("costesAceptadosResLocal").set("v.value",jsonContrato.costesAceptadosRes);
                        component.find("resolucionMonedaLocal").set("v.value",jsonContrato.moneda);  
                        
                      //  var el= component.find("costesResolucionBlock");
                       // $A.util.removeClass(el, "slds-hide");
                         var el2= component.find("costesResolucionBlockLocal");
           				 $A.util.removeClass(el2, "slds-hide");
                        
                       /* var select = component.find("derechoRecResolucion");
                        $A.util.removeClass(select, "slds-has-error");*/

                        
                    }
                    break;
                default:
                    
                    break;
                    
            }
        }else{
             component.set("v.loadtab2",true); //Cargo la pestaña de todos modos
        }
        
        return 'OK';
      //  helper.manageAsistenciaJuridica(component, event, helper, contrato);
    },
    
    manageReqPresencialidad : function(component, event, helper, contrato) {
     //   console.log('req presenc');
        //console.log(contrato);
        var jsonContrato= JSON.parse(contrato);
     //   console.log(jsonContrato.reqsPresencia);
        
        if(jsonContrato.reqsPresencia!=null){
            component.set("v.loadtab1",true);
            switch (jsonContrato.reqsPresencia){
                case 'R10':
                 //   console.log('Entro en R10');
                  //  console.log( component.find("NoExige").isRendered());
                   // console.log(component.find("NoExige").isValid());
                    component.find("NoExige").set("v.checked",true);
                    component.find("siExigePersonal").set("v.disabled",true);
                    component.find("siExigeGob").set("v.disabled",true);
                    component.find("siExigeCli").set("v.disabled",true);
                    component.find("siExigeAyesa").set("v.disabled",true);
                    break;
                case 'R20':
                    component.find("NoExige").set("v.disabled",true);
                    component.find("siExigePersonal").set("v.checked",true);
                    component.find("siExigeGob").set("v.disabled",true);
                    component.find("siExigeCli").set("v.disabled",true);
                    component.find("siExigeAyesa").set("v.disabled",true);
                    break;
                case 'R21':
                    component.find("NoExige").set("v.disabled",true);
                    component.find("siExigePersonal").set("v.disabled",true);
                    component.find("siExigeGob").set("v.checked",true);
                    component.find("siExigeCli").set("v.disabled",true);
                    component.find("siExigeAyesa").set("v.disabled",true);
                    break;
                case 'R22':
                    component.find("NoExige").set("v.disabled",true);
                    component.find("siExigePersonal").set("v.disabled",true);
                    component.find("siExigeGob").set("v.disabled",true);
                    component.find("siExigeCli").set("v.checked",true);
                    component.find("siExigeAyesa").set("v.disabled",true);
                    break;
                case 'R23':
                    component.find("NoExige").set("v.disabled",true);
                    component.find("siExigePersonal").set("v.disabled",true);
                    component.find("siExigeGob").set("v.disabled",true);
                    component.find("siExigeCli").set("v.disabled",true);
                    component.find("siExigeAyesa").set("v.checked",true);
                    break;
                default:
                    
                    break;
            }
            
        }else{
             component.set("v.loadtab1",true); //Cargo la pestaña de todos modos
        }
    // helper.manageSituacionActual(component, event, helper, contrato);
       
        return 'OK';
        
        
    },
    
     managePrevSituacionFutura : function(component, event, helper, contrato) {
        console.log('Prevision');
        //console.log(contrato);
        component.find("tabContrato").set("v.selectedTabId", "tabPrev2");
        var jsonContrato= JSON.parse(contrato);
        console.log(jsonContrato.previsionSituacionContrato);
        
        if(jsonContrato.previsionSituacionContrato!=null){
            component.set("v.loadtabPrev2",true);
            switch (jsonContrato.previsionSituacionContrato){
                case 'S10':  
                    component.find("PrevNormalidad").set("v.checked",true);
                  component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
                    break;
                case 'S11':
                    component.find("PrevPrevisionRetrasos").set("v.checked",true);
                    component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
                    break;
                case 'S12':
                    component.find("PrevNoRetrasoYNegociacion").set("v.checked",true);
                     component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);
                    break;
                case 'S20':
                    component.find("PrevSuspensionTemporal").set("v.checked",true);
                   component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                component.find("PrevContratoResuelto").set("v.disabled",true);

                    break;
                case 'S30':
                    component.find("PrevContratoResuelto").set("v.checked",true);
                   component.find("PrevPrevisionRetrasos").set("v.disabled",true);
                component.find("PrevNormalidad").set("v.disabled",true);
                component.find("PrevSuspensionTemporal").set("v.disabled",true);
                component.find("PrevNoRetrasoYNegociacion").set("v.disabled",true);
                    break;
                default:
                    
                    break;
            }
            
        }else{
             component.set("v.loadtabPrev2",true); //Cargo la pestaña de todos modos
        }
    // helper.manageSituacionActual(component, event, helper, contrato);
       
        return 'OK';
        
        
    },
    
    setErrorValidityMessage : function(component, event, helper, seccion) {
        var message=''; 
        component.set("v.infoStatus", true);
        switch (seccion) {
            case 'tab1' :
                message=$A.get("$Label.c.GC_Error_01");
                break;
            case 'tab2' :
                message=$A.get("$Label.c.GC_Error_02");
                
                break;
                case 'tab3' :
                message=$A.get("$Label.c.GC_Error_03");
                
                break;
            case 'campos' :
                message=$A.get("$Label.c.GC_Error_03");
                
                break;
                 case 'estado' :
                message=$A.get("$Label.c.GC_Error_04");
                
                break;
            case 'errorPrueba':
                message='Fallo por estar asistencia juridica a false';
                break;
                
            case 'tabPrev2':
            message=$A.get("$Label.c.GC_Error_05");
                break;


                
        }
        component.set("v.infoMessage", message);
    },
    
    deleteMessage: function(component, event, helper) {
        component.set("v.infoStatus", false); 
        component.set("v.infoMessage", '');
    },
    
    isMobile: function(component) {
        var userAgent=window.navigator.userAgent.toLowerCase();
       // return (-1!=userAgent.indexOf('mobile'));
       // component.set("v.infoStatus", true);
        component.set("v.isAppMobile", (-1!=userAgent.indexOf('mobile')));
        console.log('appMovil?: ' + (-1!=userAgent.indexOf('mobile')));
    },
        
})
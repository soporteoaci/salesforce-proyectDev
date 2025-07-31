({
    getContractInfo: function (component, event, helper) {

        var action = component.get("c.contractInfo");

        action.setParams({
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonInfo = JSON.parse(response.getReturnValue());
                component.set("v.contract", jsonInfo);

                var idTasking = jsonInfo.idTasking;

                console.log('Codigo SAP Contrato --> ' + jsonInfo.codSAP);
                console.log('Fecha ultima actualización Tasking --> ' + jsonInfo.fechaActualizacionTasking);
                console.log('Identificador de Tasking --> ' + idTasking);

                component.set("v.idTasking", idTasking);
                if(jsonInfo.Importacion_Tasking =='Si'){
                    if (idTasking != null && jsonInfo.fechaActualizacionTasking != null  ) {
                        component.set("v.isUpdate", true);
                        component.set("v.infoStartMessage", 'La última vez que se sincronizó este contrato con Tasking fue: ' + jsonInfo.fechaActualizacionTasking  );
                    } else {
                        component.set("v.isUpdate", false);
                        component.set("v.isImport", true);
                        component.set("v.infoStartMessage", 'Se va a proceder a importar todos los Hitos, Entregables y TDRs asociados a este contrato.');
                    }
                }else {
                    component.set("v.isUpdate", false);
                    component.set("v.isImport", false);
                    component.set("v.infoStartMessage", 'Este contrato no permite la importación de TdR\'s y Entregables de Tasking. Para más información, contacte con oaci@ayesa.com o aburgos@ayesa.com');
                }
                
            } else {
                console.log("KO-getContractInfo");
            }
        });
        $A.enqueueAction(action);
    },

    evaluateTDRs: function (component, event, helper) {

        console.log('Entro en EvaluateTDRS');
        console.log('elementoSAPContrato_Tasking: ' + component.get("v.elementoSAPContrato_Tasking"));
        console.log('idTasking: ' + component.get("v.idTasking"));

        var action = component.get("c.getNumberOfTDRs");

        action.setParams({
            "elementoSAPContrato": component.get("v.elementoSAPContrato_Tasking"),
            "idTasking": component.get("v.idTasking")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {
                var result = response.getReturnValue();

                console.log('Numero de TDRs por WS --> ' + result);

                if (result != null && result > 0) {
                    console.log('Se almacena el numero de TDRs');
                    component.set("v.TDRListSize", result);
                    helper.importFromTasking(component, event, helper, component.get("v.idTasking"));
                } else {
                    helper.putOffSpinner(component, event, helper);
                    component.set("v.infoFinishMessage", 'El contrato no tiene Terminos de Referencia en Tasking');
                    component.set("v.infoImportForMessage", false);
                    helper.showInfo(component);
                }
            } else {
                console.log("KO-evaluateTDRs");
            }
        });
        $A.enqueueAction(action);
    },

    getIdTasking: function (component, event, helper) {

        var action = component.get("c.get_Contract_Id_tasking");

        action.setParams({
            "codSAPProyecto": component.get("v.contract").codSAPProyecto,
            "codSAPContrato": component.get("v.contract").codSAP,
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonInfo = JSON.parse(response.getReturnValue());
                console.log(jsonInfo);

                if (jsonInfo.import_result == 'OK') {
                    var info = jsonInfo.infoElement[0].info;

                    component.set("v.idTasking", info.split('/')[0]);
                    component.set("v.elementoSAPContrato_Tasking", info.split('/')[1]);

                    //helper.importFromTasking(component, event, helper, idTasking);  //Comentada para insertar la getsion de contratos con alto numero de TDR's
                    helper.evaluateTDRs(component, event, helper); //Se evalua el numero de TDR's para gestionar ante un posible contrato con un alto numero de ellos.
                } else {
                    helper.errorManagement(component, event, helper, jsonInfo.infoElement);
                    /* component.set("v.infoStatus", true);
                     component.set("v.infoMessage", jsonInfo.message);
                     console.log(jsonInfo);
                     
                     helper.putOffSpinner(component, event, helper);
                     component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                     component.set("v.infoImportForMessage", false);
                     
                       var il= component.find("buttonSeeDetails");
                     $A.util.removeClass(il, "slds-hide"); */
                }
            } else {
                console.log("KO-getIdTasking");
                helper.putOffSpinner(component, event, helper);
                component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                component.set("v.infoImportForMessage", false);

                helper.showInfo(component);

                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    importFromTasking: function (component, event, helper, idTasking) {

        var action = component.get("c.importInfoFromTasking");

        action.setParams({
            "idTasking": idTasking,
            "contractId": component.get("v.recordId"),
            "codSAPContrato": component.get("v.contract").codSAP
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonInfo = JSON.parse(response.getReturnValue());
                console.log(jsonInfo);

                if (jsonInfo.import_result == 'OK') {
                    /* component.set("v.infoImportResult",jsonInfo.import_result);
                     component.set("v.infoImportResultList",jsonInfo.infoElement);*/
                    // var listIdsEntregables = [];
                    // for (var i = 0; i < jsonInfo.infoElement.length; i++) {
                    //     if (jsonInfo.infoElement[i].section == 'Entregables') {
                    //         console.log(jsonInfo.infoElement[i].listaIds);
                    //         listIdsEntregables.push(jsonInfo.infoElement[i].listaIds);
                    //     }
                    // }
                    // console.log('listIdsEntregables');
                    // console.log(listIdsEntregables);

                    //Dividir la siguiente llamada en funcion del numero de TDR's que se van a gestionar
                    var numberOfTDR = component.get("v.TDRListSize");
                    console.log('Tamaño de Lista de TDRs: ' + numberOfTDR);

                    if (numberOfTDR <= 85) {
                        console.log('Contrato con BAJO numero de TDRs');
                        helper.getRelations(component, event, helper, idTasking);
                    } else {
                        console.log('Contrato con ALTO numero de TDRs');
                        helper.getRelationsWithMultipleCalls(component, event, helper, idTasking);
                        //helper.getRelations(component, event, helper, idTasking);
                    }

                    /*var il= component.find("buttonSeeDetails");
                    $A.util.removeClass(il, "slds-hide"); */

                } else {
                    helper.putOffSpinner(component, event, helper, jsonInfo.infoElement);
                    component.set("v.infoImportResult", jsonInfo.import_result);
                    component.set("v.infoImportResultList", jsonInfo.infoElement);

                    component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                    component.set("v.infoImportForMessage", false);

                    helper.showInfo(component);

                    $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");
                }

            } else {
                helper.putOffSpinner(component, event, helper);
                console.log("KO-importFromTasking");
            }
        });
        $A.enqueueAction(action);
    },

    updateAllElements: function (component, event, helper) {

        var action = component.get("c.updateInfoFromTasking");

        action.setParams({
            "idTasking": component.get("v.idTasking"),
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                console.log('Resultado de la importacion');
                var jsonInfo = JSON.parse(response.getReturnValue());
                console.log(jsonInfo);

                if (jsonInfo.import_result == 'OK') {
                    component.set("v.infoImportResult", jsonInfo.import_result);
                    component.set("v.infoImportResultList", jsonInfo.infoElement);

                    helper.getRelations(component, event, helper, idTasking);

                    $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");
                } else {
                    helper.putOffSpinner(component, event, helper);
                    component.set("v.infoImportResult", jsonInfo.import_result);
                    component.set("v.infoImportResultList", jsonInfo.infoElement);

                    component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                    component.set("v.infoImportForMessage", false);

                    helper.showInfo(component);

                    $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");
                }
            } else {
                helper.putOffSpinner(component, event, helper);
                console.log("KO-updateAllElements");
            }
        });
        $A.enqueueAction(action);
    },

    getRelations: function (component, event, helper, idTasking) {

        var action = component.get("c.createRelations");

        action.setParams({
            "idTasking": idTasking,
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                console.log('Resultado de la creacion de relaciones');
                var jsonInfo = JSON.parse(response.getReturnValue());
                console.log(jsonInfo);

                // component.set("v.infoRelationsResult",jsonInfo.sectionResult);
                component.set("v.infoRelationsResultObject", jsonInfo);

                if (jsonInfo.sectionResult == 'OK') {

                    component.set("v.infoFinishMessage", 'La importación ha finalizado correctamente');
                    component.set("v.infoImportForMessage", true);
                    helper.showInfo(component);
                    // var il= component.find("buttonSeeDetails");
                    // $A.util.removeClass(il, "slds-hide"); 
                    helper.putOffSpinner(component, event, helper);
                    console.log('Todo correcto. Cargar info de resultados');

                    helper.updateTaskingContractInfo(component, event, helper, idTasking);
                    helper.deleteNotRelatedEntregables(component, event, helper);

                } else {
                    component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                    helper.putOffSpinner(component, event, helper);
                    component.set("v.infoImportForMessage", false);

                    helper.showInfo(component);

                    $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");

                    //component.set("v.infoStatus", true);
                    component.set("v.infoMessage", jsonInfo.message);
                    console.log(jsonInfo);
                }
            } else {
                component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación');
                component.set("v.infoImportForMessage", false);
                helper.putOffSpinner(component, event, helper);
                helper.showInfo(component);
                console.log("KO-getRelations");
            }
        });
        $A.enqueueAction(action);
    },

    getRelationsWithMultipleCalls: function (component, event, helper, idTasking) {

        console.log('Entro en getRelationsWithMultipleCalls');

        var action = component.get("c.getTDRList");

        action.setParams({
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonListTdr = JSON.parse(response.getReturnValue());
                console.log('Lista de TDRs para este contrato --> ');
                console.log(jsonListTdr);
                component.set("v.TDRListIds", jsonListTdr);

                // var numberOfCallsToControler = component.get("v.TDRListSize");
                var myListOfArrays = [];
                var temparray, mynumber = 0,
                    chunk = 70;
                for (var i = 0, j = jsonListTdr.length; i < j; i += chunk) {
                    mynumber = mynumber + 1;
                    temparray = jsonListTdr.slice(i, i + chunk);
                    myListOfArrays.push(temparray);
                    console.log(mynumber);
                    console.log(temparray.length);
                }
                console.log('Numero de veces que tengo que llamar al controlador: ' + mynumber);
                component.set("v.totalCallsToController", mynumber);
                component.set("v.TDRListSplitedIds", myListOfArrays);
                /*console.log(myListOfArrays[0]);
                console.log(myListOfArrays[3]);*/

                helper.relationCallControllerManagement(component, event, helper, mynumber, 0, myListOfArrays[0]);

                /*if(result != null && result > 0){
                    console.log('Se almacena el numero de TDRs');
                    component.set("v.evaluateTDRs",result);
                    helper.importFromTasking(component, event, helper, component.get("v.idTasking"));
                    
                }*/
            } else {
                console.log("KO-getRelationsWithMultipleCalls");
            }
        });
        $A.enqueueAction(action);
    },

    relationCallControllerManagement: function (component, event, helper, totalCalls, currentCalls, myListOfArrays) {

        console.log(myListOfArrays.length);
        //console.log(JSON.stringify(myListOfArrays));
        console.log(component.get("v.TDRListSplitedIds")[currentCalls]);
        console.log('Entro en relationCallControllerManagement');

        var action = component.get("c.createRelationsStepByStep");

        action.setParams({
            "contractId": component.get("v.recordId"),
            "list_of_TDR_Ids": JSON.stringify(myListOfArrays)
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonInfo = JSON.parse(response.getReturnValue());
                var currentCall = component.get("v.currentCallsToController");
                var totalcalls = component.get("v.totalCallsToController");

                console.log('Numero de llamadas: ' + currentCall);
                console.log('Total de llamadas: ' + totalcalls);
                console.log('Result: ' + jsonInfo);
                if (jsonInfo.sectionResult == 'OK' && currentCall < totalcalls) {

                    component.set("v.currentCallsToController", currentCall + 1); //linea que lanza la nueva llamada la función en la que estoy
                    var numberOfRelations = component.get("v.numberOfRelations");
                    component.set("v.numberOfRelations", numberOfRelations + jsonInfo.numberOfRecords);
                    if ((currentCall + 1) == totalcalls) { //Condición que indica que se ha llegado a la ultima llamada para las relaciones.
                        // component.set("v.infoRelationsResultObject.info", 'hola que tal');
                        component.set("v.infoFinishMessage", 'La importación ha finalizado correctamente');
                        component.set("v.infoImportForMessage", true);
                        helper.showInfo(component);
                        $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");
                        helper.putOffSpinner(component, event, helper);
                        console.log('Todo correcto. Cargar info de resultados');

                        helper.updateTaskingContractInfo(component, event, helper, component.get("v.idTasking"));
                        helper.deleteNotRelatedEntregables(component, event, helper);
                    }
                }
                console.log('result');
            } else {
                console.log("KO-relationCallControllerManagement");
            }
        });
        $A.enqueueAction(action);
    },

    deleteNotRelatedEntregables: function (component, event, helper) {

        var action = component.get("c.delete_Not_Related_Entregables");

        action.setParams({
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                if (response.getReturnValue() == 'OK') {
                    console.log("Eliminacion de Entregables no relacionados CORRECTA");
                    helper.createHitosRelations(component, event, helper);
                } else {
                    console.log("Fallo al eliminar los entregables relacionados ");
                    helper.putOffSpinner(component, event, helper);
                    component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación en el filtrado de Entregables relacionados');
                    component.set("v.infoImportForMessage", false);
                    helper.showInfo(component);
                }

            } else {
                console.log("KO-deleteNotRelatedEntregables");
                helper.putOffSpinner(component, event, helper);
                component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación en el filtrado de Entregables relacionados');
                component.set("v.infoImportForMessage", false);

                helper.showInfo(component);

                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    createHitosRelations: function (component, event, helper) {

        var action = component.get("c.createRelationsHitos");

        action.setParams({
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                if (response.getReturnValue() == 'OK') {
                    console.log("Creación de Relacions de HITOS: OK");
                    helper.finalCountOfRecords(component, event, helper);
                    // var il= component.find("buttonSeeDetails");
                    // $A.util.removeClass(il, "slds-hide"); 
                } else {
                    console.log("Fallo en la creación de Relaciones con los Hitos");
                    helper.putOffSpinner(component, event, helper);
                    component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación en la creacion de relaciones entre Hitos y Entregables');
                    component.set("v.infoImportForMessage", false);
                    helper.showInfo(component);
                }
            } else {
                console.log("KO-createRelationsHitos");
                helper.putOffSpinner(component, event, helper);
                component.set("v.infoFinishMessage", 'Hubo un fallo durante la importación en la creación de relaciones entre Hitos y Entregables');
                component.set("v.infoImportForMessage", false);

                helper.showInfo(component);

                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    finalCountOfRecords: function (component, event, helper) {

        var action = component.get("c.resumeRecords");

        action.setParams({
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {

                var jsonInfo = JSON.parse(response.getReturnValue());

                if (jsonInfo.import_result == 'OK') {
                    console.log('Conteo datos del contrato : CORRECTA');
                    console.log(jsonInfo);
                    component.set("v.infoImportResultList", jsonInfo.infoElement);
                    // component.set("v.infoImportResultList",jsonInfo.infoElement);

                    // helper.getRelations(component, event, helper, idTasking);
                    $A.util.removeClass(component.find("buttonSeeDetails"), "slds-hide");
                } else {
                    console.log('Fallo en Conteo datos del contrato');
                }
            } else {
                console.log("KO-resumeRecords");
            }
        });
        $A.enqueueAction(action);
    },

    updateTaskingContractInfo: function (component, event, helper, idTasking) {

        var action = component.get("c.updateInfoTasking");

        action.setParams({
            "idTasking": idTasking,
            "contractId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            if (component.isValid() && response.getState() === "SUCCESS") {
                if (response.getReturnValue() == 'OK') {
                    console.log('Actualización de fecha e ID de Tasking : CORRECTA');
                } else {
                    console.log('Fallo al actualizar la fecha e Id de Tasking');
                }
            } else {
                console.log("KO-updateTaskingContractInfo");
            }
        });
        $A.enqueueAction(action);
    },

    errorManagement: function (component, event, helper, jsonInfo) {

        console.log(jsonInfo);

        var codeError = jsonInfo[0].section;
        console.log('Codigo de error: ' + codeError);

        switch (codeError) {
            case 'ERR001':
                component.set("v.infoFinishMessage", jsonInfo[0].info + component.get("v.contract").codSAPProyecto);
                component.set("v.infoImportForMessage", false);

                helper.showInfo(component);

                helper.putOffSpinner(component, event, helper);
                break;
            case 'ERR002':
                component.set("v.infoFinishMessage", jsonInfo[0].info + component.get("v.contract").codSAPProyecto);
                component.set("v.infoImportForMessage", false);

                helper.showInfo(component);

                helper.putOffSpinner(component, event, helper);
                break;
            case '':
                break;
        }
    },

    putOnSpinner: function (component, event, helper) {
        $A.util.removeClass(component.find("spinnerModal"), "slds-hide");
    },

    putOffSpinner: function (component, event, helper) {
        $A.util.addClass(component.find("spinnerModal"), "slds-hide");
    },

    showInfo: function (component) {
        $A.util.addClass(component.find("startInfo"), "slds-hide");
        $A.util.removeClass(component.find("finishInfo"), "slds-hide");
    }

})
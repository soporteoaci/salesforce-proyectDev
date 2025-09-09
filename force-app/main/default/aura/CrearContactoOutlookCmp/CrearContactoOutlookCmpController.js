({
    init: function(component, event, helper) {
        component.set("v.contacto", {
            tratamiento: '',
            nombre: '',
            apellidos: '',
            cuenta: '',
            email: '',
            cargo: '',
            perfil: '',
            nivel: '',
            subnivel: '',
            claveNegocio: false
        });
        
        helper.obtenerOpcionesPicklist(component, "Contact", "Salutation", "opcionesTratamiento");
        helper.obtenerOpcionesPicklist(component, "Contact", "PERFIL__c", "opcionesPerfil");
        helper.obtenerOpcionesPicklist(component, "Contact", "NIVEL__c", "opcionesNivel");
        helper.obtenerOpcionesPicklist(component, "Contact", "SUBNIVEL__c", "opcionesSubnivel");
        helper.agregarListenersCerrarDropdown(component);
        
        
    },
    crearContacto: function (component, event, helper) {
        var contacto = component.get("v.contacto");
        
        // Validación de campos obligatorios
        let camposFaltantes = [];
        
        if (!contacto.tratamiento) camposFaltantes.push("Tratamiento");
        if (!contacto.nombre || contacto.nombre.trim() === "") camposFaltantes.push("Nombre");
        if (!contacto.apellidos || contacto.apellidos.trim() === "") camposFaltantes.push("Apellidos");
        if (!contacto.email || contacto.email.trim() === "") camposFaltantes.push("Correo electrónico");
        if (!contacto.cuenta || contacto.cuenta.trim() === "") camposFaltantes.push("Cuenta");
        
        if (camposFaltantes.length > 0) {
            helper.mostrarToast("Campos obligatorios", "Faltan: " + camposFaltantes.join(", "), "error");
            return;
        }
        
        // Si pasa la validación, continúa con la lógica de guardado
        helper.crearContacto(component, event, helper);
    },
    //Llamado trás cada cambio en cualquier parte del cmp.
    handleChange: function(component, event, helper) {
        var contacto = component.get("v.contacto");
        var fieldName = event.getSource().get("v.name");
        var value;
        
        if(event.getSource().get("v.type") === 'checkbox'){
            value = event.getSource().get("v.checked");
        } else {
            value = event.getSource().get("v.value");
        }
        
        contacto[fieldName] = value;
        
        component.set("v.contacto", contacto);
    },
    
    buscarCuentas: function(component, event, helper) {
        helper.buscarCuentas(component);
    },
    
    seleccionarCuenta: function(component, event, helper) {
        helper.seleccionarCuenta(component, event);
    }
    
})
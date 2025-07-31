({
 formValidate: function(component, event, helper) {
        
         var fechaCierre = component.find("inputFechaCierre").get("v.value");
         var fechaPresentacion = component.find("inputFechaPresentacion").get("v.value");
        var required = '';
     if(fechaPresentacion>fechaCierre){
         required= "La fecha de presentación debe de ser anterior o igual a la fecha de cierre";
     }
      return required;
	}
})
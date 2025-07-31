({
    formValidate: function(component, event, helper) {
        var Seccion = component.find('select_Seccion').get('v.value');
        var RecordType_Op = component.get("v.RecordType_Op");
        var fields=[];
        if(RecordType_Op == 'Ibermatica SME'){
            if(Seccion =='HARD' || Seccion =='MTTO.HARD'){
                fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Descuento",  "Coste",  "Cantidad", "select_Area", "select_Solucion", "select_Producto" ];
            }else if (Seccion =='SOFT'){
                fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Descuento",  "Coste",  "Cantidad", "select_Tipo", "select_Tipo_Pago","select_Area", "select_Solucion", "select_Producto"  ];
            }else if( Seccion == 'MTTO.SOFT'){
                fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Descuento",  "Coste",  "Cantidad","select_Area", "select_Solucion", "select_Producto"  ];
                
            }else if (Seccion == 'SRV'){
                fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Descuento", "select_Costehoras", "Horas", "select_Area" ];
            }else{
                fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Descuento",  "Coste",  "Cantidad", "select_Area", "select_Solucion", "select_Producto" ];
            }
            
        }else{
            fields = [ "Name_importe", "select_Seccion", "Importe_bruto",  "Coste" ];
        }
        
        var required = [];
        
        for(var i=0; i<fields.length; i++){            
            var value = component.find(fields[i]).get("v.value");
            console.log("Campo '" + fields[i] + "': ", component.find(fields[i]).get("v.value"));
            if(value == undefined || value == null || value == "")
                required.push("El campo '" + component.find(fields[i]).get("v.label") + "' es obligatorio.");
        }
        
        return required;
    },
    
    Limpiar_campos: function(component, event, helper) {
        component.set("v.Name","");
        component.set("v.Seccion","");
        component.set("v.ImporteBruto","");
        component.set("v.Descuento","0");
        component.set("v.Cantidad","");
        component.set("v.Coste","");
        component.set("v.Costehoras","");        
        component.set("v.Horas","");
        component.set("v.Tipo","");
        component.set("v.Tipo_de_Pago","");
        component.set("v.Observaciones","");
        component.set("v.Area","");
        component.set("v.Solucion","");
        component.set("v.Producto","");
        component.set("v.options",null);
        component.set("v.values",null);
       // component.set("v.Modulo",""); 
    }
})
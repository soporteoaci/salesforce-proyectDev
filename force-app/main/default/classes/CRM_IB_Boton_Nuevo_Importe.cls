public class CRM_IB_Boton_Nuevo_Importe {

    @AuraEnabled
    public static String areaImporteSME(String OppId){
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        //Recuperamos valores de gestor de produccion
        List <Parametrica_2__c> parametrica = [SELECT Id, Name,Area__c, Solucion__c, Producto__c, Tipo__c 
                                               FROM Parametrica_2__c 
                                               WHERE RecordType.DeveloperName = 'Area_Solucion_Producto' and Estado__c = '1' order by Area__c];
        List <String> valoresArea = new List<String>{''};
        
        for (Parametrica_2__c param: parametrica){
            if(!valoresArea.contains(param.Area__c)){
                valoresArea.add(param.Area__c);
            }
        }
        
        gen.writeObjectField('area', valoresArea);
        
        Oportunidad__c opp = [SELECT id,Name,RecordType.Name,Etapa__c FROM Oportunidad__c WHERE Id=:OppId];
        String RecordTypeOp = opp.RecordType.Name;
        
        gen.writeObjectField('RecordTypeOp', RecordTypeOp);
        gen.writeObjectField('oportunidad', opp);
        
        result = gen.getAsString();
        System.debug('result '+ result);
        return result;
    }
    
    @AuraEnabled
    public static List <String> solucionImporteSME(String Area){
        System.debug('Código area para filtrar: '+ Area );
        
        
        List <Parametrica_2__c> parametrica = [SELECT Id, Name, Tipo__c,Solucion__c
                                               FROM Parametrica_2__c
                                               WHERE RecordType.DeveloperName = 'Area_Solucion_Producto'  and Area__c =: Area and Estado__c = '1' order by Solucion__c];
        
        List <String> valoresSolucion = new List<String>{''};
        for (Parametrica_2__c param: parametrica){
            if(!valoresSolucion.contains(param.Solucion__c)){
                valoresSolucion.add(param.Solucion__c);
            }
        }
        
        system.debug('valores_solucion: ' + valoresSolucion);
        
        
        return valoresSolucion;
    }
    
    
 
     @AuraEnabled
    public static List <String> Producto_valoresImporteSME(String Area, String Solucion){
        System.debug('Código solucion y area para filtrar: '+ Area + ' / ' + Solucion );
        
        
        List <Parametrica_2__c> parametrica = [SELECT Id, Name, Tipo__c,Solucion__c,Producto__c
                                               FROM Parametrica_2__c
                                               WHERE RecordType.DeveloperName = 'Area_Solucion_Producto'  and Area__c =: Area and Solucion__c =: Solucion and Estado__c = '1' order by Producto__c];
        
        List <String> valoresProducto = new List<String>{''};
        for (Parametrica_2__c param: parametrica){
            if(!valoresProducto.contains(param.Producto__c)){
                valoresProducto.add(param.Producto__c);
            }
        }
        
        system.debug('valores_producto: ' + valoresProducto);
        
        
        return valoresProducto;
    }
       @AuraEnabled
    public static List <String> Modulo_valoresImporteSME(String Area, String Solucion, String Producto){
        System.debug('Código solucion y area para filtrar: '+ Area + ' / ' + Solucion );
        
        
        List <Parametrica_2__c> parametrica = [SELECT Id, Name, Tipo__c,Solucion__c,Producto__c,Modulo__c
                                               FROM Parametrica_2__c
                                               WHERE RecordType.DeveloperName = 'Area_Solucion_Producto'  and Area__c =: Area and Solucion__c =: Solucion and Producto__c =: Producto and Modulo__c != null and Estado__c = '1' order by Modulo__c];
        
        List <String> valoresModulo= new List<String>();
        for (Parametrica_2__c param: parametrica){
         
            if(!valoresModulo.contains(param.Modulo__c) && param.Modulo__c != null ){
                valoresModulo.add(param.Modulo__c);
            }
        }
        
        system.debug('valoresModulo: ' + valoresModulo);
        
        
        return valoresModulo;
    }
    @AuraEnabled
    public static String saveInfoImportes(String OppId, String Name_importe, String select_Seccion, Decimal Importe_bruto,Decimal Descuento,Integer Cantidad, Decimal Coste, String select_Costehoras,Decimal Horas, String select_Tipo, 
                                          String select_Tipo_Pago, String Observaciones, String Area,String Solucion,String Producto, String Modulo ){
        
       System.debug('Entro en saveInfoImportes');
        ImporteSME__c imp = new ImporteSME__c();
        
        imp.Oportunidad__c = OppId;
        imp.Name = Name_importe;
        imp.Seccion__c= select_Seccion;
        imp.Importe_Bruto__c=Importe_bruto;
        imp.Descuento__c  =Descuento;
        imp.Cantidad__c =Cantidad;
        imp.Coste__c= Coste;
        imp.Coste_horas__c= select_Costehoras;
        imp.Horas__c=Horas;
        imp.Tipo__c=select_Tipo;
        imp.Tipo_de_Pago__c=select_Tipo_Pago;
        imp.Observaciones__c=Observaciones;                                     
        imp.Area__c= Area;
        imp.Solucion__c= Solucion;
        imp.Producto__c= Producto;
        imp.Modulo__c = Modulo;
         System.debug('Importe a crear: ' + imp);
        try{
           
         insert imp; 
        }catch(Exception e){ 
            System.debug('Error guardar registro: ' + e.getMessage());
            return e.getMessage();            
        }
        
        system.debug('Actualizado');
        return 'SUCCESS';
        
    }
}
public class CRM_IB_Account_Address_controller {
    
    @AuraEnabled
    public static String countryProvinceMap(String IdAccount){
        
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        //Recuperamos valores de gestor de produccion
        List <Parametrica_2__c> paises = [SELECT Id,Name, Denominacion__c, Codigo_Externo__c,RecordType.Name
                                          FROM Parametrica_2__c 
                                          Where RecordType.Name ='Paises' and Estado__c ='1' order by Denominacion__c];
        
        List<String> map_paises = new  List<String>();
        
        List<String> map_provincia = new  List<String>();
        List <Parametrica_2__c> provincia = new List <Parametrica_2__c>();
        
        for (Parametrica_2__c p: paises){
            if(p.RecordType.Name == 'Paises' && !map_paises.contains(p.Denominacion__c) ){
                map_paises.add(p.Denominacion__c);
            }
        }
        
        gen.writeObjectField('map_paises', map_paises);
        
        
        //Recuperamos valores iniciales de la Cuenta
        Account acct = [SELECT Id,Name, BillingCountry, BillingState, BillingCity, BillingPostalCode, BillingStreet
                        FROM Account
                        WHERE Id =: IdAccount LIMIT 1 ];
        gen.writeObjectField('account', acct);
        
        if(acct.BillingState != null){
             provincia = [SELECT Id,Name, Denominacion__c, Codigo_Externo__c,RecordType.Name
                                             FROM Parametrica_2__c 
                                             Where RecordType.Name ='Provincias' and Estado__c ='1'   and Pais__r.Denominacion__c =:acct.BillingCountry order by Denominacion__c];
            
            
        
        for (Parametrica_2__c p: provincia){
            if(p.RecordType.Name == 'Provincias' && !map_provincia.contains(p.Denominacion__c) ){
                map_provincia.add(p.Denominacion__c);
            }
        }
        }

        
        gen.writeObjectField('map_provincias', map_provincia);
        gen.writeEndObject();
        
        result = gen.getAsString();
        // return valoresGP;
        return result;
    }
    
    @AuraEnabled
    
    public static List <String> provinceOptions(String Pais){
        
        System.debug('Pais: '+ Pais);
        
        List <Parametrica_2__c> provincia = [SELECT Id,Name, Denominacion__c, Codigo_Externo__c,RecordType.Name
                                             FROM Parametrica_2__c 
                                             Where RecordType.Name ='Provincias' and Estado__c ='1'   and Pais__r.Denominacion__c =:Pais order by Denominacion__c];
        System.debug('provincias: ' + provincia);
        List<String> map_provincia = new  List<String>();
        
        for (Parametrica_2__c p: provincia){
            if(p.RecordType.Name == 'Provincias' && !map_provincia.contains(p.Denominacion__c) ){
                map_provincia.add(p.Denominacion__c);
            }
        }
        
        System.debug('map_provincia: '+ map_provincia);
        return Map_provincia;
    }
    
    @AuraEnabled
    
    public static String saveAccountCountry(String Pais, String Provincia, String Ciudad, String Calle, String Codigo_Postal, String IdAccount){
        
        Parametrica_2__c pais_provincia = [SELECT Id,Name, Denominacion__c, Codigo_Externo__c,RecordType.Name, Pais__R.Codigo_Externo__c

                                           FROM Parametrica_2__c 
                                           Where RecordType.Name ='Provincias' and Estado__c ='1'   and Pais__r.Denominacion__c =:Pais and Denominacion__c =: Provincia order by Denominacion__c LIMIT 1];
        
        Account acct = [Select Id, Name, BillingCountry, BillingState, Codigo_Pais__c, 	Codigo_provincia__c
                        FROM Account
                        Where Id =: IdAccount];
        acct.BillingCountry = Pais;
        acct.BillingState =Provincia;
        acct.BillingCity = Ciudad;
        acct.BillingStreet = Calle;
        acct.BillingPostalCode = Codigo_Postal;
        acct.Codigo_Pais__c = pais_provincia.Pais__r.Codigo_Externo__c;
        acct.Codigo_provincia__c=pais_provincia.Codigo_Externo__c;
        try{
            
            update acct;
            
        } catch(DMLException e){ 
            System.debug('Error al actualizar dirección: ' + e.getMessage());
            return e.getMessage();            
        }	
        system.debug('Actualizado');
        return 'Actualizado';
        
       
    }
    
    
}
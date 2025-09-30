public class CRM_IB_Controller {
    
    
    @AuraEnabled
    public static String saveAccount_CNAE(String CNAE, String Id_account){
        
        System.debug('Id account: ' + Id_account);
        System.debug('Id CNAE: ' + CNAE);
        Account acc = [SELECT Id,Name FROM Account where Id =: Id_account];
        
        
        //Parametrica_2__c valores_CNAE = [SELECT Id, name, Codigo_CNAE__c, CNAE__c, Tipo__c, RecordType.name from Parametrica_2__c where tipo__c = 'CNAE' and CNAE__c =: CNAE Limit 1];
        
        
        acc.CNAE__c = CNAE;
        try{
            
            update acc;
            
        } catch(DMLException e){ 
            System.debug('Error CNAE Account: ' + e.getMessage());
            return e.getMessage();            
        }	
        system.debug('Actualizado');
        return 'Actualizado';
        
    }
    
    @AuraEnabled
    public static String saveAccount_SIC(String SIC, String Id_account){
        
        System.debug('Id account: ' + Id_account);
        System.debug('Id SIC: ' + SIC);
        Account acc = [SELECT Id,Name FROM Account where Id =: Id_account];
        
        
        //Parametrica_2__c valores_CNAE = [SELECT Id, name, Codigo_CNAE__c, CNAE__c, Tipo__c, RecordType.name from Parametrica_2__c where tipo__c = 'CNAE' and CNAE__c =: CNAE Limit 1];
        
        
        acc.SIC__c = SIC;
        try{
            
            update acc;
            
        } catch(DMLException e){ 
            System.debug('Error SIC Account: ' + e.getMessage());
            return e.getMessage();            
        }	
        system.debug('Actualizado');
        return 'Actualizado';
        
    }
    @AuraEnabled
    public static String valoresCNAESIC(String Id_Account){
        String result = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        List <Parametrica_2__c> valores_CNAE= [SELECT Id, name, Codigo_CNAE__c, Codigo_CNAE_num__c,CNAE__c, Tipo__c, RecordType.Name
                                               from Parametrica_2__c 
                                               where RecordType.Name = 'CNAE' order by Codigo_CNAE_num__c];
        List <Parametrica_2__c> valores_SIC= [SELECT Id, name, Codigo_SIC__c, SIC__c, Tipo__c, RecordType.name
                                              from Parametrica_2__c 
                                              where RecordType.Name = 'SIC' order by Codigo_SIC__c];
        List <String> valoresCNAE = new List<String>();
        List <String> valoresSIC = new List<String>();
        
        for (Parametrica_2__c param: valores_CNAE){
            if(param.RecordType.Name == 'CNAE' && !valoresCNAE.contains(param.Codigo_CNAE_num__c +' - '+param.CNAE__c)){
                valoresCNAE.add(param.Codigo_CNAE_num__c +' - '+param.CNAE__c);
            }
        }
        
        for (Parametrica_2__c param: valores_SIC){
            if(param.RecordType.Name == 'SIC' && !valoresCNAE.contains(param.Codigo_SIC__c +' - '+param.SIC__c)){
                valoresSIC.add(param.Codigo_SIC__c +' - '+param.SIC__c);
            }
        }
        
        Account acc = [SELECT Id,Name, CNAE__c, SIC__c FROM Account where Id =: Id_Account];
        System.debug('Cuenta recuperada '+ acc.Name + 'Y su valor CNAE ' + acc.CNAE__c  );
        
        gen.writeObjectField('CNAE', valoresCNAE);
        gen.writeObjectField('SIC', valoresSIC);
        gen.writeObjectField('Account', acc);
        
        gen.writeEndObject();
        
        result = gen.getAsString();
        
        return result;
    }
}
global class GC_Calculo_Imp_Proyecto implements Database.Batchable<sObject> {
    /*  
@AuraEnabled
public static void Calculoimporte (){

List<Proyecto__c>  Lista_proyectos = [SELECT ID,Name,Codigo__c,Importe_calculado_contrato__c FROM Proyecto__c];
System.debug('Lista de proyectos: '+ lista_proyectos.size());

List<Proyecto__c>  Lista_Proyectos_update = new List<Proyecto__c>();

for(Proyecto__c proj: Lista_proyectos){
Double Imp_proy_sum=0;
List<Contrato__c> Contratos_relacionados = new List<Contrato__c>();
Contratos_relacionados = [SELECT ID, Name,Codigo_SAP__C, IC_Real__c FROM Contrato__c Where Proyecto__c=: proj.Id];

if(contratos_relacionados.size()>0){
for(Contrato__c contra: Contratos_relacionados){
if(contra.IC_real__c >=0){
Imp_proy_sum+= contra.IC_real__c;
}
}
}

proj.Importe_calculado_contrato__c=Imp_proy_sum;
Lista_Proyectos_update.add(proj);
}
System.debug('Terminado el bucle de los proyectos y los contratos');

update Lista_Proyectos_update;
}
*/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT ID,Name,Codigo__c,Importe_calculado_contrato__c FROM Proyecto__c';
        
        System.debug('QUERY: '+ query);
        return Database.getQueryLocator(query);
    } 
    global void execute(Database.BatchableContext BC, List<Proyecto__c> proyectos){
        List<Proyecto__c>  Lista_proyectos = [SELECT ID,Name,Codigo__c,Importe_calculado_contrato__c FROM Proyecto__c];
        System.debug('Lista de proyectos: '+ lista_proyectos.size());
        
        List<Proyecto__c>  Lista_Proyectos_update = new List<Proyecto__c>();
        
        for(Proyecto__c proj : [SELECT ID, Name,Codigo__c,Importe_calculado_contrato__c, (SELECT ID, Name,Codigo_SAP__C, IC_Real__c from Contratos__r) FROM Proyecto__c]){
            Double Imp_proy_sum=0;
           // List<Contrato__c> Contratos_relacionados = new List<Contrato__c>();
         //   Contratos_relacionados = [SELECT ID, Name,Codigo_SAP__C, IC_Real__c FROM Contrato__c Where Proyecto__c=: proj.Id];
            
            
                for(Contrato__c contra: proj.Contratos__r){
                    if(contra.IC_real__c >=0){
                        Imp_proy_sum+= contra.IC_real__c;
                    }
                }
      
            
            proj.Importe_calculado_contrato__c=Imp_proy_sum;
            Lista_Proyectos_update.add(proj);
        }
        System.debug('Terminado el bucle de los proyectos y los contratos');
        
        update Lista_Proyectos_update;
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}
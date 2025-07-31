public class GC_Calculo_Imp_Pro_Controller {
    @AuraEnabled
    public static void Calculoimporte (){
       
        
        List<Proyecto__c>  Lista_Proyectos_update = new List<Proyecto__c>();
        
        for(Proyecto__c proj : [SELECT ID, Name,Codigo__c,Importe_calculado_contrato__c, (SELECT ID, Name,Codigo_SAP__C, IC_Real__c from Contratos__r) FROM Proyecto__c]){
            Double Imp_proy_sum=0;            
           
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
}
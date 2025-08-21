public class CRM_Notific_Op_Incoherentes_Controller {
	public Id ownerId {get;set;}
    
    public Map<String, Object> getopptys(){
        
        List<Opportunity> opptys;
        opptys = [SELECT Id, Name, Cuenta_Principal__c, OwnerId, Owner.name, Owner.email FROM Opportunity WHERE Existencia_de_Incoherencias__c = true and (StageName != 'Cerrada' or estado_de_cierre__c = 'Contratada') and OwnerId =: ownerId];
        
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            
        Map<String, Object> params = new Map<String, Object>();
        
        params.put('baseUrl', baseUrl);
        params.put('opptys', opptys);
        
        //return opptys;
        return params;
    }
}
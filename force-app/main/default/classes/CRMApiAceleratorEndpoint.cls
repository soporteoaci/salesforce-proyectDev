public class CRMApiAceleratorEndpoint implements RICM.ResponseGeneratorInterface  {
    
    public void generateResponse(Map<String,Object> param0){
        
        Id accountId = (Id) param0.get('accountid');
        String name = (String) param0.get('accountname');
        
        Account myAccount = new Account(Id = accountId, Name = name);
        update myAccount;
        
        RestContext.response.responseBody = Blob.valueOf('Account updated!');
    }
}
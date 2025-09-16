global class OCRBodyBuilder implements RICM.RequestGeneratorInterface {
    
    global String generateRequestBodyTest(Id param0, String param1){
        return null;
    }
    
    global String generateRequestBody(RICM__Integration__c param0, Map<String,Object> param1){
        
        String username = param1.get('username')?.toString();
        String password = param1.get('password')?.toString();
        String nombre = param1.get('nombre')?.toString();
        String apellido = param1.get('apellido')?.toString();
        
        DataAux myData = new DataAux();
        myData.nombre = nombre;
        myData.apellido1 = apellido;
        
        return 'username=' + username + '&password=' + password + '&data=' + JSON.serialize(myData, true);
    }
    
    global class DataAux{
        global String active = 'true';
        global String nombre;
        global String apellido1;
    }

}
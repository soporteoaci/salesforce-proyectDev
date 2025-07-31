public class CRM_IB_Consulta_Doc_Controller {
    
    //Test en la clase CRM_IB_ExisteDocNewFile_Test
    
    
    @AuraEnabled    
    public static string consulta_doc_New_File(Id idObj){
        
        System.debug('consultarDocNewFile');
        //Puede ser Oportunidad__c o Referencia_Comercial__c
        String objType = idObj.getSObjectType().getDescribe().getName();
        Oportunidad__c op;
        Referencia_Comercial__c ref;
        
        Boolean documentacion ;
        String result;
        String docs;
        //Tipo de objeto recibido
        if ('Oportunidad__c' == objType) {
            op =[SELECT ID, Name, Documentacion_IB__c FROM Oportunidad__c Where Id=: idObj];
            documentacion = op.Documentacion_IB__c;
            docs='1,2';
        } else if ('Referencia_Comercial__c' == objType) {
            
            ref =[SELECT ID, Name, Ficha__c FROM Referencia_Comercial__c Where Id=: idObj];
            documentacion = ref.Ficha__c;
            docs='6';
        }
        
        //Si el campo de documentacion ya está a true no haremos la consulta a New File
        if(documentacion == false){
            Boolean consulta_ficheros = CRM_IB_ExisteDocNewFile.existeDocNewFile(idObj,docs,'or');
            
            System.debug('consultarDocNewFile: '+ consulta_ficheros);
            if(consulta_ficheros == true){
                System.debug('Existe fichero en NewFle');
                result ='Existe fichero en NewFle';
            }else{
                //op.addError('No puede cerrar la oportunidad sin tener en NewFile la documentación requerida');
                System.debug(' No Existe fichero en NewFle');
                result ='No Existe fichero en NewFle';
            }
            
            try{
                if (objType =='Oportunidad__c' ) {
                    System.debug('Actulizamos OC');
                    op.Documentacion_IB__c = consulta_ficheros;
                    update op;
                } else if (objType == 'Referencia_Comercial__c' ) {
                    ref.Ficha__c = consulta_ficheros;
                    System.debug('Actualizamos Referencia ');
                    update ref;
                    
                }

            } catch(DMLException e){ 
                System.debug('Error update Documentación: ' + e.getMessage());
                return e.getMessage();            
            }	
        }else{
            result = 'Ya estaba actualizado anteriormente el campo a true';
        }
        
        return result;    
    }
}
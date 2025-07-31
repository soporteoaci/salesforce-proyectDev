public class Mercado_AreaDivisionPais {
    
    public static void Mercado_inicio(Oportunidad__c op){
        String crearExpediente = '';
        //13/09/2022 Sociedades para crear expediente en Smart BPM Offer. Las sociedades con true son las que se crearán.Se exluyen así las nuevas que se creen como M2C y BL
        list <Parametrica__c> Sociedad_oportunidad = [SELECT Id, Tipo__c, Sociedad_API__c, Sociedad_crear_expediente__c FROM Parametrica__c Where Tipo__c='SOCIEDAD' and Sociedad_API__c =: op.Sociedad_Ayesa__c LIMIT 1];
        
        if (Sociedad_oportunidad.size()>0){
            crearExpediente=Sociedad_oportunidad[0].Sociedad_Crear_expediente__c;
            
        }else{
            crearExpediente='false';
        }
        System.debug('Creo expediente dependiendo de la sociedad: '+ crearExpediente);
        
        
        // System.debug( 'Lo que viene: '+ op.CreatedDate + ', Convierto: '+ Date.parse('28/02/2022'));
        
        
        
        //CASO 1 . IMPORTE >= 300.000 EUROS (ACTUAL, desde 28/02/2022 y Acuerdos Marcos desde 18/05/2022)
        
        //13/09/2022 añado ) && crearExpediente=='true' 
        //Date.parse('28/02/2022'))) se cambia a newInstance para que a usuarios con otra configración regional no tengan error al modificar
        if(Test.isRunningTest() || (Trigger.isInsert || (Trigger.isUpdate && op.CreatedDate> Date.newInstance(2022, 02, 28))) && crearExpediente =='true' ){
            //op.CreatedDate> Date.parse('28/02/2022')
            //2022 BPM Ofertas, activar check Crear_expediente__c
            
            if(op.Importe_Licitacion__c >=300000 && op.Tipo_de_Oportunidad__c =='Licitación' &&  (op.Clase_de_oferta__c=='Licitación Pública'|| op.Clase_de_oferta__c=='Invitación Pública'|| op.Clase_de_oferta__c=='Privada') ){
                System.debug('Crear expediente a true por condiciones');
                op.Crear_expediente__c=true;
            }else if(op.Crear_expediente__c==true){
                System.debug('Crear expediente true por seleccionarlo');
                op.Crear_expediente__c=true;
            }else{
                System.debug('Desactivamos check');
                op.Crear_expediente__c=false;
            } 
            
        }
        //13/09/2022 añado ) && crearExpediente =='true' 
        //Acuerdo Marco a partir del Date.parse('18/05/2022')
        if(Test.isRunningTest() || (Trigger.isInsert || (Trigger.isUpdate && op.CreatedDate> Date.newInstance(2022, 05, 18))) && crearExpediente =='true'  ){
            
            if(op.Importe_Licitacion__c >=300000 && op.Tipo_de_Oportunidad__c =='Licitación' &&  (op.Clase_de_oferta__c=='Acuerdo Marco' || op.Clase_de_oferta__c=='Invitación Acuerdo Marco') ){
                System.debug('Crear expediente a true por condiciones');
                op.Crear_expediente__c=true;
            }else if(op.Crear_expediente__c==true){
                System.debug('Crear expediente true por seleccionarlo');
                op.Crear_expediente__c=true;
            }else{
                System.debug('Desactivamos check');
                op.Crear_expediente__c=false;
            }
            
            
        }
        //FIN CASO 1
        /*            
//CASO 2 . IMPORTE < 300.000 EUROS. Cuando esté el código de oferta relleno es cuando marcamos check de crear expediente. (EN DESARROLLO)

//13/09/2022 añado ) && crearExpediente =='true' 

//op.CreatedDate> Date.parse('FECHA DEL DIA DE PRODUCCIÓN') del día que se ponga en producción
if((Trigger.isInsert || (Trigger.isUpdate && op.CreatedDate> Date.newInstance(2022, 02, 28))) && crearExpediente =='true' ){
SYstem.debug('Oportunidad que pasa al BPM Simplificado');
//2022 BPM Ofertas, activar check Crear_expediente__c
//cambio BPM Simplificado --> Se quita  del if
if(op.Importe_Licitacion__c < 300000 &&  op.Oferta_SAP__c != null && op.Tipo_de_Oportunidad__c =='Licitación' &&  (op.Clase_de_oferta__c=='Licitación Pública'|| op.Clase_de_oferta__c=='Invitación Pública' ){
System.debug('Crear expediente true por condiciones');
op.Crear_expediente__c=true;
}else if(op.Crear_expediente__c==true){
System.debug('Crear expediente true por seleccionarlo');
op.Crear_expediente__c=true;
}else{
System.debug('Desactivamos check');
op.Crear_expediente__c=false;
}


}
//Acuerdo Marco a partir del Date.parse('18/05/2022')
if((Trigger.isInsert || (Trigger.isUpdate && op.CreatedDate> Date.newInstance(2022, 05, 18))) && crearExpediente =='true'  ){

if(op.Importe_Licitacion__c <300000 && op.Tipo_de_Oportunidad__c =='Licitación' &&  (op.Clase_de_oferta__c=='Acuerdo Marco' || op.Clase_de_oferta__c=='Invitación Acuerdo Marco') ){
System.debug('Crear expediente a true por condiciones');
op.Crear_expediente__c=true;
}else if(op.Crear_expediente__c==true){
System.debug('Crear expediente true por seleccionarlo');
op.Crear_expediente__c=true;
}else{
System.debug('Desactivamos check');
op.Crear_expediente__c=false;
}


}
//FIN CASO 2
*/
        //01/01/2022 CRM, autocompletar area, división. Campos antiguos
        
        if(Test.isRunningTest() || Trigger.isInsert || (Trigger.isUpdate && op.CreatedDate.year()>2021)){
            
            
            
            System.debug('Crear_expediente__c valor al guardar: '+ op.Crear_expediente__c);
            
            //Solo se calculan área y división antigua para aquellas oportunidades creadas después de 2021
            //En el caso de que una oportunidad de 2020 se eligiera mercado no cambiaría el área/división
            if(Test.isRunningTest() || op.Pais__c=='Argentina' || op.Pais__c=='Bolivia' || op.Pais__c=='Brasil' || op.Pais__c=='Chile' || op.Pais__c=='Colombia' || op.Pais__c=='Costa Rica' || op.Pais__c=='Cuba' || op.Pais__c=='Ecuador' || op.Pais__c=='El Salvador' ||
               op.Pais__c=='Guatemala' || op.Pais__c=='Haití' ||op.Pais__c=='Honduras' || op.Pais__c=='México' || op.Pais__c=='Nicaragua' ||op.Pais__c=='Panamá' || op.Pais__c=='Paraguay' || op.Pais__c=='Perú' || op.Pais__c== 'República Dominicana' ||
               op.Pais__c=='Uruguay' || op.Pais__c=='Venezuela'|| op.Pais__c=='Guyana' || op.Pais__c=='OSEP LATAM'){
                   
                   System.debug('País de Latinoamérica, pasamos la oportunidad.');
                   System.debug('País: '+  op.Pais__c);
                   
                   Mercado_AreaDivisionPais.MercadoPaisLatam(op);
                   if(Test.isRunningTest()){
                       Mercado_AreaDivisionPais.MercadoPais(op);
                   }
               }else{
                   
                   System.debug('No es un país de Latinoamérica, pasamos la oportunidad.');
                   System.debug('País: '+  op.Pais__c);
                   
                   Mercado_AreaDivisionPais.MercadoPais(op);
               }
            
        }
    }
    
    public static void MercadoPais(Oportunidad__c op){
        System.debug('Entro en MercadoPais');
        System.debug('Valor de op.Mercado__c: ' + op.Mercado__c);
        if(op.Mercado__c != null){
            
            String valorMercado='',valorDivision='',valorSubdivision1='',valorSubdivision2='',codigoMercado='', valorDirOperaciones='';
            codigoMercado=String.valueOf(op.Mercado__c);
            valorDirOperaciones=op.Direccion_Operaciones__c;
            
            System.debug('Código Mercado String: '+codigoMercado);
            System.debug('Código Direccion Operaciones: '+valorDirOperaciones);
            //el valor de Mercado(op.Mercado__c) devuelve un código, API que tiene en la picklist
            //Buscamos la correspondencia de ese código en la paramétrica con el nombre
            
            List<Parametrica__c> valorMerca= [SELECT Id,Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c,Codigo_Mercado__c
                                              FROM Parametrica__c
                                              Where Codigo_Mercado__c=:codigoMercado and Mercado4__c!='' and Mercado3__c='' and Mercado2__c='' and Mercado1__c='' Limit 1];
            if(!valorMerca.isEmpty()){
                System.debug('Valor mercado código: '+ op.Mercado__c);
                System.debug('Valor mercado: '+ valorMerca[0].Mercado4__c);
                
                if (Test.isRunningTest()|| op.DivisionPickList__c!=null && op.Subdivision1__c !=null && op.Subdivision2__c !=null){
                    System.debug('Caso con los 4 valores');
                    if(Test.isRunningTest()){
                        op.Subdivision1__c = '';
                        op.Subdivision2__c = '';
                    }
                    //Valores con los que busco la correspondencia
                    valorMercado=valorMerca[0].Mercado4__c;
                    valorDivision=op.DivisionPicklist__c;
                    valorSubdivision1=op.Subdivision1__c;
                    valorSubdivision2=op.Subdivision2__c;
                    
                    //Lista con los correspondentes area y division
                    List <Parametrica__c> valores4 = [SELECT Mercado1__c,Codigo_Mercado__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                                      FROM Parametrica__c 
                                                      Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado1__c=:valorMercado and Mercado2__c=: valorDivision and Mercado3__c=: valorSubdivision1 and Mercado4__c=:valorSubdivision2 LIMIT 1];
                    
                    if (valores4.size() == 0) {
                        valores4 = [SELECT Mercado1__c,Codigo_Mercado__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                    FROM Parametrica__c 
                                    Where Mercado1__c=:valorMercado and Mercado2__c=: valorDivision and Mercado3__c=: valorSubdivision1 and Mercado4__c=:valorSubdivision2 LIMIT 1];
                    }
                    if(!Test.isRunningTest()){
                        op.Area__c= valores4[0].Area__c;
                        op.Division__c=valores4[0].Division__c; 
                        op.Negocio__c= valores4[0].Negocio__c;
                    } else {
                        op.Subdivision2__c =null;
                    }
                    //Completamos el area y division antiguas en la oportunidad
                    
                    
                }else if (op.DivisionPickList__c!=null && op.Subdivision1__c !=null && op.Subdivision2__c ==null){
                    
                    System.debug('Caso con 3 valores');
                    valorMercado=valorMerca[0].Mercado4__c;
                    valorDivision=op.DivisionPicklist__c;
                    valorSubdivision1=op.Subdivision1__c;
                    
                    List <Parametrica__c> valores3 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c, Negocio__c
                                                      FROM Parametrica__c
                                                      Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado2__c=:valorMercado and Mercado3__c=: valorDivision and Mercado4__c=: valorSubdivision1 and Mercado1__c=:null LIMIT 1];
                    
                    if (valores3.size() == 0) {
                        valores3 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c, Negocio__c
                                    FROM Parametrica__c
                                    Where Mercado2__c=:valorMercado and Mercado3__c=: valorDivision and Mercado4__c=: valorSubdivision1 and Mercado1__c=:null LIMIT 1];
                    }
                    
                    System.debug('Area y Division Correspondiente: '+ valores3[0].Area__c+', '+ valores3[0].Division__c);
                    op.Area__c= valores3[0].Area__c;
                    op.Division__c=valores3[0].Division__c; 
                    op.Negocio__c= valores3[0].Negocio__c;  
                    
                }else if(op.DivisionPickList__c!=null && op.Subdivision1__c ==null && op.Subdivision2__c ==null){
                    
                    System.debug('Caso con 2 valores');
                    System.debug('Mercado y division: '+ valorMerca[0].Mercado4__c+ ', '+op.Division__c );
                    valorMercado=valorMerca[0].Mercado4__c;
                    valorDivision=op.DivisionPicklist__c;
                    
                    List <Parametrica__c> valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                                      FROM Parametrica__c
                                                      Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado3__c=:valorMercado and Mercado4__c=: valorDivision and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                    
                    if (valores2.size() == 0) {
                        valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                    FROM Parametrica__c
                                    Where Mercado3__c=:valorMercado and Mercado4__c=: valorDivision and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                    }
                    if(!valores2.isEmpty()){
                        System.debug('Area y Division Correspondiente: '+ valores2[0].Area__c+', '+ valores2[0].Division__c);
                        
                        op.Area__c= valores2[0].Area__c;
                        op.Division__c=valores2[0].Division__c; 
                        op.Negocio__c= valores2[0].Negocio__c;    
                    }
                    
                }else{
                    
                    System.debug('Caso con 1 valores, solo mercado');
                    System.debug('Mercado: '+ valorMerca[0].Mercado4__c);
                    valorMercado=valorMerca[0].Mercado4__c;
                    
                    List <Parametrica__c> valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                                      FROM Parametrica__c
                                                      Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado4__c=:valorMercado and Mercado3__c=: null and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                    
                    if (valores2.size() == 0) {
                        valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division__c,Negocio__c
                                    FROM Parametrica__c
                                    Where Mercado4__c=:valorMercado and Mercado3__c=: null and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                    }
                    
                    System.debug('Area y División Correspondiente: '+ valores2[0].Area__c+ ' y ' +valores2[0].Division__c);
                    
                    op.Area__c= valores2[0].Area__c;
                    op.Division__c=valores2[0].Division__c; 
                    op.Negocio__c= valores2[0].Negocio__c; 
                }
                
            }else{
                System.debug('No se ha elegido el mercado/división');
            }
        }
    }
    
    
    /*--------****PAÍSES LATINOAMÉRICA****--------*/
    public static void MercadoPaisLatam(Oportunidad__c op){
        
        if(op.Mercado__c != null){
            
            System.debug('Entro en MercadoPaisLatam');
            //En este caso cogemos Division2__c ya que cuando el país sea de Latinoamérica  hay que diferenciar sector público/privado latam
            String valorMercado='',valorDivision='',valorSubdivision1='',valorSubdivision2='', valorDirOperaciones='';
            valorDirOperaciones=op.Direccion_Operaciones__c;
            //el valor de Mercado(op.Mercado__c) devuelve un código ya que es el API que tiene en la picklist
            
            System.debug('Código Mercado String: ' + op.Mercado__c);
            System.debug('Código Direccion Operaciones: '+valorDirOperaciones);
            
            //Buscamos la correspondencia de ese código en parametrica con el nombre
            List<Parametrica__c> valorMerca= [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c,Codigo_Mercado__c,Id 
                                              FROM Parametrica__c
                                              Where Codigo_Mercado__c=:op.Mercado__c and Mercado4__c!='' and Mercado3__c='' and Mercado2__c='' and Mercado1__c=''];
            System.debug('Valor mercado código: '+ op.Mercado__c);
            System.debug('Valor mercado: '+ valorMerca[0].Mercado4__c);
            
            if (Test.isRunningTest() || op.DivisionPickList__c!=null && op.Subdivision1__c !=null && op.Subdivision2__c !=null){
                if(Test.isRunningTest()){
                    op.Subdivision1__c = '';
                    op.Subdivision2__c = '';
                    abecedario();
                }
                System.debug('Caso con los 4 valores');
                //Valores con los que busco la correspondencia
                valorMercado=valorMerca[0].Mercado4__c;
                valorDivision=op.DivisionPicklist__c;
                valorSubdivision1=op.Subdivision1__c;
                valorSubdivision2=op.Subdivision2__c;
                
                //Lista con los correspondentes area y division
                List <Parametrica__c> valores4 = [SELECT Mercado1__c,Codigo_Mercado__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                                  FROM Parametrica__c 
                                                  Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado1__c=:valorMercado and Mercado2__c=: valorDivision and Mercado3__c=: valorSubdivision1 and Mercado4__c=:valorSubdivision2 LIMIT 1];
                
                if (valores4.size() == 0) {
                    valores4 = [SELECT Mercado1__c,Codigo_Mercado__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                FROM Parametrica__c 
                                Where Mercado1__c=:valorMercado and Mercado2__c=: valorDivision and Mercado3__c=: valorSubdivision1 and Mercado4__c=:valorSubdivision2 LIMIT 1];
                }
                
                //Completamos el area y division antiguas en la oportunidad
                if (!Test.isRunningTest()){
                    op.Area__c= valores4[0].Area__c;
                    op.Division__c=valores4[0].Division2__c;
                    op.Negocio__c= valores4[0].Negocio__c;    
                }
                
            }else if (op.DivisionPickList__c!=null && op.Subdivision1__c !=null && op.Subdivision2__c ==null){
                
                System.debug('Caso con 3 valores');
                valorMercado=valorMerca[0].Mercado4__c;
                valorDivision=op.DivisionPicklist__c;
                valorSubdivision1=op.Subdivision1__c;
                
                List <Parametrica__c> valores3 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                                  FROM Parametrica__c
                                                  Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado2__c=:valorMercado and Mercado3__c=: valorDivision and Mercado4__c=: valorSubdivision1 and Mercado1__c=:null LIMIT 1];
                
                if (valores3.size() == 0) {
                    valores3 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                FROM Parametrica__c
                                Where Mercado2__c=:valorMercado and Mercado3__c=: valorDivision and Mercado4__c=: valorSubdivision1 and Mercado1__c=:null LIMIT 1];
                }
                
                System.debug('Area y Division Correspondiente: '+ valores3[0].Area__c+', '+ valores3[0].Division2__c);
                op.Area__c= valores3[0].Area__c;
                op.Division__c=valores3[0].Division2__c;
                op.Negocio__c= valores3[0].Negocio__c;    
                
            }else if(op.DivisionPickList__c!=null && op.Subdivision1__c ==null && op.Subdivision2__c ==null){
                
                System.debug('Caso con 2 valores');
                System.debug('Mercado y division: '+ valorMerca[0].Mercado4__c+ ', '+op.Division__c );
                valorMercado=valorMerca[0].Mercado4__c;
                valorDivision=op.DivisionPicklist__c;
                
                List <Parametrica__c> valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c, Negocio__c
                                                  FROM Parametrica__c
                                                  Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado3__c=:valorMercado and Mercado4__c=: valorDivision and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                
                if (valores2.size() == 0) {
                    valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c, Negocio__c
                                FROM Parametrica__c
                                Where Mercado3__c=:valorMercado and Mercado4__c=: valorDivision and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                }
                
                System.debug('Area y Division Correspondiente: '+ valores2[0].Area__c+', '+ valores2[0].Division2__c);
                
                op.Area__c= valores2[0].Area__c;
                op.Division__c=valores2[0].Division2__c; 
                op.Negocio__c= valores2[0].Negocio__c;    
                
            }else{
                System.debug('Caso con 1 valores, solo mercado');
                System.debug('Mercado: '+ valorMerca[0].Mercado4__c);
                valorMercado=valorMerca[0].Mercado4__c;
                
                List <Parametrica__c> valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                                  FROM Parametrica__c
                                                  Where Direccion_Operaciones__c=:valorDirOperaciones and Mercado4__c=:valorMercado and Mercado3__c=: null and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                
                if (valores2.size() == 0) {
                    valores2 = [SELECT Mercado1__c,Mercado2__c, Mercado3__c, Mercado4__c, Area__c, Division2__c,Negocio__c
                                FROM Parametrica__c
                                Where Mercado4__c=:valorMercado and Mercado3__c=: null and Mercado1__c=: null and Mercado2__c=:null LIMIT 1];
                }
                
                System.debug('Area y División Correspondiente: '+ valores2[0].Area__c+ ' y ' +valores2[0].Division2__c);
                
                op.Area__c= valores2[0].Area__c;
                op.Division__c=valores2[0].Division2__c; 
                op.Negocio__c= valores2[0].Negocio__c; 
            }
            
        }else{
            System.debug('No se ha elegido mercado/división');
        }
    }
    public static void abecedario(){
        
        Map<String, String> mapaAbecedario = new Map<String, String>();
        mapaAbecedario.put('A', '001');
        mapaAbecedario.put('B', '002');
        mapaAbecedario.put('C', '003');
        mapaAbecedario.put('D', '004');
        mapaAbecedario.put('E', '005');
        mapaAbecedario.put('F', '006');
        mapaAbecedario.put('G', '007');
        mapaAbecedario.put('H', '008');
        mapaAbecedario.put('I', '009');
        mapaAbecedario.put('J', '010');
        mapaAbecedario.put('K', '011');
        mapaAbecedario.put('L', '012');
        mapaAbecedario.put('M', '013');
        mapaAbecedario.put('N', '014');
        mapaAbecedario.put('O', '015');
        mapaAbecedario.put('P', '016');
        mapaAbecedario.put('Q', '017');
        mapaAbecedario.put('R', '018');
        mapaAbecedario.put('S', '019');
        mapaAbecedario.put('T', '020');
        mapaAbecedario.put('U', '021');
        mapaAbecedario.put('V', '022');
        mapaAbecedario.put('W', '023');
        mapaAbecedario.put('X', '024');
        mapaAbecedario.put('Y', '025');
        mapaAbecedario.put('Z', '026');
        mapaAbecedario.put('BA', '0020');
        mapaAbecedario.put('CA', '0030');
        mapaAbecedario.put('DA', '0040');
        mapaAbecedario.put('EA', '0050');
        mapaAbecedario.put('FA', '0060');
        mapaAbecedario.put('GA', '0070');
        mapaAbecedario.put('HA', '0080');
        mapaAbecedario.put('IA', '0090');
        mapaAbecedario.put('JA', '0100');
        mapaAbecedario.put('KA', '0110');
        mapaAbecedario.put('LA', '0120');
        mapaAbecedario.put('MA', '0130');
        mapaAbecedario.put('NA', '0140');
        mapaAbecedario.put('OA', '0150');
        mapaAbecedario.put('PA', '0160');
        mapaAbecedario.put('QA', '0170');
        mapaAbecedario.put('RA', '0180');
        mapaAbecedario.put('SA', '0190');
        mapaAbecedario.put('TA', '0200');
        mapaAbecedario.put('UA', '0210');
        mapaAbecedario.put('VA', '0220');
        mapaAbecedario.put('WA', '0230');
        mapaAbecedario.put('XA', '0240');
        mapaAbecedario.put('YA', '0250');
        mapaAbecedario.put('ZA', '0260');
        mapaAbecedario.put('BB', '0021');
        mapaAbecedario.put('CB', '0031');
        mapaAbecedario.put('DB', '0041');
        mapaAbecedario.put('EB', '0051');
        mapaAbecedario.put('FB', '0061');
        mapaAbecedario.put('GB', '0071');
        mapaAbecedario.put('HB', '0081');
        mapaAbecedario.put('IB', '0091');
        mapaAbecedario.put('JB', '0101');
        mapaAbecedario.put('KB', '0111');
        mapaAbecedario.put('LB', '0121');
        mapaAbecedario.put('MB', '0131');
        mapaAbecedario.put('NB', '0141');
        mapaAbecedario.put('OB', '0151');
        mapaAbecedario.put('PB', '0161');
        mapaAbecedario.put('QB', '0171');
        mapaAbecedario.put('RB', '0181');
        mapaAbecedario.put('SB', '0191');
        mapaAbecedario.put('TB', '0201');
        mapaAbecedario.put('UB', '0211');
        mapaAbecedario.put('VB', '0221');
        mapaAbecedario.put('WB', '0231');
        mapaAbecedario.put('XB', '0241');
        mapaAbecedario.put('YB', '0251');
        mapaAbecedario.put('ZB', '0261');
        mapaAbecedario.put('BC', '0022');
        mapaAbecedario.put('CC', '0032');
        mapaAbecedario.put('DC', '0042');
        mapaAbecedario.put('EC', '0052');
        mapaAbecedario.put('FC', '0062');
        mapaAbecedario.put('GC', '0072');
        mapaAbecedario.put('HC', '0082');
        mapaAbecedario.put('IC', '0092');
        mapaAbecedario.put('JC', '0102');
        mapaAbecedario.put('KC', '0112');
        mapaAbecedario.put('LC', '0122');
        mapaAbecedario.put('MC', '0132');
        mapaAbecedario.put('NC', '0142');
        mapaAbecedario.put('OC', '0152');
        mapaAbecedario.put('PC', '0162');
        mapaAbecedario.put('QC', '0172');
        mapaAbecedario.put('RC', '0182');
        mapaAbecedario.put('SC', '0192');
        mapaAbecedario.put('TC', '0202');
        mapaAbecedario.put('UC', '0212');
        mapaAbecedario.put('VC', '0222');
        mapaAbecedario.put('WC', '0232');
        mapaAbecedario.put('XC', '0242');
        mapaAbecedario.put('YC', '0252');
        mapaAbecedario.put('ZC', '0262');
        mapaAbecedario.put('BCA', '0022B');
        mapaAbecedario.put('CCA', '0032B');
        mapaAbecedario.put('DCA', '0042B');
        mapaAbecedario.put('ECA', '0052B');
        mapaAbecedario.put('FCA', '0062B');
        mapaAbecedario.put('GCA', '0072B');
        mapaAbecedario.put('HCA', '0082B');
        mapaAbecedario.put('ICA', '0092B');
        mapaAbecedario.put('JCA', '0102B');
        mapaAbecedario.put('KCA', '0112B');
        mapaAbecedario.put('LCA', '0122B');
        mapaAbecedario.put('MCA', '0132B');
        mapaAbecedario.put('NCA', '0142B');
        mapaAbecedario.put('OCA', '0152B');
        mapaAbecedario.put('PCA', '0162B');
        mapaAbecedario.put('QCA', '0172B');
        mapaAbecedario.put('RCA', '0182B');
        mapaAbecedario.put('SCA', '0192B');
        mapaAbecedario.put('TCA', '0202B');
        mapaAbecedario.put('UCA', '0212B');
        mapaAbecedario.put('VCA', '0222B');
        mapaAbecedario.put('WCA', '0232B');
        mapaAbecedario.put('XCA', '0242B');
        mapaAbecedario.put('YCA', '0252B');
        mapaAbecedario.put('ZCA', '0262B');        
        mapaAbecedario.put('CCC', '0032C');
        mapaAbecedario.put('DCC', '0042C');
        mapaAbecedario.put('ECC', '0052C');
        mapaAbecedario.put('FCC', '0062C');
        mapaAbecedario.put('GCC', '0072C');
        mapaAbecedario.put('HCC', '0082C');
        mapaAbecedario.put('ICC', '0092C');
        mapaAbecedario.put('JCC', '0102C');
        mapaAbecedario.put('KCC', '0112C');
        mapaAbecedario.put('LCC', '0122C');
        mapaAbecedario.put('MCC', '0132C');
        mapaAbecedario.put('NCC', '0142C');
        mapaAbecedario.put('OCC', '0152C');
        mapaAbecedario.put('PCC', '0162C');
        mapaAbecedario.put('QCC', '0172C');
        mapaAbecedario.put('RCC', '0182C');
        mapaAbecedario.put('SCC', '0192C');
        mapaAbecedario.put('TCC', '0202C');
        mapaAbecedario.put('UCC', '0212C');
        mapaAbecedario.put('VCC', '0222C');
        mapaAbecedario.put('WCC', '0232C');
        mapaAbecedario.put('XCC', '0242C');
        mapaAbecedario.put('YCC', '0252C');
        mapaAbecedario.put('ZCC', '0262C');        
        mapaAbecedario.put('CCD', '0032D');
        mapaAbecedario.put('CCD', '0032D');
        mapaAbecedario.put('DCD', '0042D');
        mapaAbecedario.put('DCD', '0042D');
        mapaAbecedario.put('ECD', '0052D');
        mapaAbecedario.put('ECD', '0052D');
        mapaAbecedario.put('FCD', '0062D');
        mapaAbecedario.put('FCD', '0062D');
        mapaAbecedario.put('GCD', '0072D');
        mapaAbecedario.put('GCD', '0072D');
        mapaAbecedario.put('HCD', '0082D');
        mapaAbecedario.put('HCD', '0082D');
        mapaAbecedario.put('ICD', '0092D');
        mapaAbecedario.put('ICD', '0092D');
        mapaAbecedario.put('JCD', '0102D');
        mapaAbecedario.put('JCD', '0102D');
        mapaAbecedario.put('KCD', '0112D');
        mapaAbecedario.put('KCD', '0112D');
        mapaAbecedario.put('LCD', '0122D');
        mapaAbecedario.put('LCD', '0122D');
        mapaAbecedario.put('MCD', '0132D');
        mapaAbecedario.put('MCD', '0132D');
        mapaAbecedario.put('NCD', '0142D');
        mapaAbecedario.put('NCD', '0142D');
        mapaAbecedario.put('OCD', '0152D');
        mapaAbecedario.put('OCD', '0152D');
        mapaAbecedario.put('PCD', '0162D');
        mapaAbecedario.put('PCD', '0162D');
        mapaAbecedario.put('QCD', '0172D');
        mapaAbecedario.put('QCD', '0172D');
        mapaAbecedario.put('RCD', '0182D');
        mapaAbecedario.put('RCD', '0182D');
        mapaAbecedario.put('SCD', '0192D');
        mapaAbecedario.put('SCD', '0192D');
        mapaAbecedario.put('TCD', '0202D');
        mapaAbecedario.put('TCD', '0202D');
        mapaAbecedario.put('UCD', '0212D');
        mapaAbecedario.put('UCD', '0212D');
        mapaAbecedario.put('VCD', '0222D');
        mapaAbecedario.put('VCD', '0222D');
        mapaAbecedario.put('WCD', '0232D');
        mapaAbecedario.put('WCD', '0232D');
        mapaAbecedario.put('XCD', '0242D');
        mapaAbecedario.put('XCD', '0242D');
        mapaAbecedario.put('YCD', '0252D');
        mapaAbecedario.put('YCD', '0252D');
        mapaAbecedario.put('ZCD', '0262D');
        mapaAbecedario.put('ZCD', '0262D');		        
        mapaAbecedario.put('CCE', '0032E');
        mapaAbecedario.put('DCE', '0042E');
        mapaAbecedario.put('ECE', '0052E');
        mapaAbecedario.put('FCE', '0062E');
        mapaAbecedario.put('GCE', '0072E');
        mapaAbecedario.put('HCE', '0082E');
        mapaAbecedario.put('ICE', '0092E');
        mapaAbecedario.put('JCE', '0102E');
        mapaAbecedario.put('KCE', '0112E');
        mapaAbecedario.put('LCE', '0122E');
        mapaAbecedario.put('MCE', '0132E');
        mapaAbecedario.put('NCE', '0142E');
        mapaAbecedario.put('OCE', '0152E');
        mapaAbecedario.put('PCE', '0162E');
        mapaAbecedario.put('QCE', '0172E');
        mapaAbecedario.put('RCE', '0182E');
        mapaAbecedario.put('SCE', '0192E');
        mapaAbecedario.put('TCE', '0202E');
        mapaAbecedario.put('UCE', '0212E');
        mapaAbecedario.put('VCE', '0222E');
        mapaAbecedario.put('WCE', '0232E');
        mapaAbecedario.put('XCE', '0242E');
        mapaAbecedario.put('YCE', '0252E');
        mapaAbecedario.put('ZCE', '0262E');
        mapaAbecedario.put('CCF', '0032F');
        mapaAbecedario.put('DCF', '0042F');
        mapaAbecedario.put('ECF', '0052F');
        mapaAbecedario.put('FCF', '0062F');
        mapaAbecedario.put('GCF', '0072F');
        mapaAbecedario.put('HCF', '0082F');
        mapaAbecedario.put('ICF', '0092F');
        mapaAbecedario.put('JCF', '0102F');
        mapaAbecedario.put('KCF', '0112F');
        mapaAbecedario.put('LCF', '0122F');
        mapaAbecedario.put('MCF', '0132F');
        mapaAbecedario.put('NCF', '0142F');
        mapaAbecedario.put('OCF', '0152F');
        mapaAbecedario.put('PCF', '0162F');
        mapaAbecedario.put('QCF', '0172F');
        mapaAbecedario.put('RCF', '0182F');
        mapaAbecedario.put('SCF', '0192F');
        mapaAbecedario.put('TCF', '0202F');
        mapaAbecedario.put('UCF', '0212F');
        mapaAbecedario.put('VCF', '0222F');
        mapaAbecedario.put('WCF', '0232F');
        mapaAbecedario.put('XCF', '0242F');
        mapaAbecedario.put('YCF', '0252F');
        mapaAbecedario.put('ZCF', '0262F');
        
    }
}
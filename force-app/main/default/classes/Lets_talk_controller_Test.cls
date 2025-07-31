@isTest
public class Lets_talk_controller_Test {
    
    @isTest 
    static void create_lets_talk(){
      List <lets_talk__c> lets_talk_insert= new List<Lets_talk__c>();
        
        Contrato__c cont = new Contrato__c();
        cont.Codigo_SAP__c='P99/9999/01';
        cont.Name ='Prueba';
        cont.Estado__c ='ENMA';
        cont.Pais__c = 'ES';
        cont.Mercado__c = '60029505';
        cont.DivisionPicklist__c ='V-AERONAUTICS';

        Lets_talk__c lets_talk = new Lets_talk__c();
        lets_talk.name = 'Prueba';
        lets_talk.Contrato__c= cont.Id;
        lets_talk.Destinatarios__c ='aburgos@ayesa.com';
        lets_talk.CC__c ='oaci@ayesa.com;oaci@ayesa.com';
        lets_talk.Asunto__c = 'Prueba';
        lets_talk.Cuerpo_Mensaje__c='esto es una prueba';
        lets_talk.Respuesta_Asunto__c='Prueba guardar mensaje';
        lets_talk.Respuesta_Cuerpo_Mensaje__c='Cuerpo mensaje';
        lets_talk_insert.add(lets_talk);
          
        Proyecto__c proj = new Proyecto__c();
        proj.Codigo__c='P99/9999';
        proj.Name ='Prueba';
        proj.Pais__c = 'ES';
        proj.Mercado__c ='60029505';

        Lets_talk__c lets_talk2 = new Lets_talk__c();
        lets_talk2.name = 'Prueba';
        lets_talk2.Proyecto__c= proj.Id;
        lets_talk2.Destinatarios__c ='aburgos@ayesa.com';
        lets_talk2.CC__c ='oaci@ayesa.com;oaci@ayesa.com';
        lets_talk2.Asunto__c = 'Prueba';
        lets_talk2.Cuerpo_Mensaje__c='esto es una prueba';
        lets_talk2.Respuesta_Asunto__c='Prueba guardar mensaje';
        lets_talk2.Respuesta_Cuerpo_Mensaje__c='Cuerpo mensaje';
        lets_talk_insert.add(lets_talk2);
       
        insert proj;
        insert cont;
        insert lets_talk_insert;

         
        Lets_talk_controller.do_init (Lets_talk.Id); 
        Lets_talk_controller.enviar_email(Lets_talk.Id);
        Lets_talk_controller.guardar_email(Lets_talk.Id);    
        
        Lets_talk_controller.do_init_proyecto (Lets_talk2.Id);
        Lets_talk_controller.enviar_email_proyecto(Lets_talk2.Id);
        Lets_talk_controller.guardar_email_proyecto(Lets_talk2.Id);
        
        
    }
}
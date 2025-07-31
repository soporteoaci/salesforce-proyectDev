@isTest (SeeAllData = false)
public class Submit_ApprovarControlador_Test {
  @testSetup 
    static void setup() { 
      //  Profile profileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
      //  UserRole uRole = [SELECT Id FROM UserRole WHERE Name ='Supervision' LIMIT 1];
       
        id userid = Userinfo.getUserId();
        //User user1 = [SELECT Id FROM User WHERE Id = userid LIMIT 1];
        //User user1 = new User(LastName = 'test1',FirstName='test1',Alias = 'uT1',Email = 'user1Test@test.com',Username = 'user1Test' + Datetime.now().getTime() + '@test.com',ProfileId = profileId.Id,UserRoleId = uRole.id,TimeZoneSidKey = 'America/Lima', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        //insert user1;
        //System.runAs ( user1 ) {
            Proyecto__c proyecto = new Proyecto__c(Name = 'Proyecto Test', Codigo__c = 'Proyecto-001', Documentalista__c = userid);
            insert proyecto;
            Hito__c hito = new Hito__c(Name = 'Hito', Proyecto__c = proyecto.Id, Fecha_Fin__c = Date.newInstance(2018, 12, 17), Peso_Facturacion__c = 20 );
            insert hito;
            Entregable__c entr = new Entregable__c(Name = 'Ent', Proyecto__c = proyecto.Id, Hito__c = hito.Id, Entregable__c = 'Ent', Tipo__c = 'Otros', Fase__c = 'Pruebas');
            insert entr;
            Entregable__c entr2 = new Entregable__c(Name = 'Ent2', Proyecto__c = proyecto.Id, Hito__c = hito.Id, Entregable__c = 'Ent2', Tipo__c = 'Otros', Fase__c = 'Pruebas');
            insert entr2;
            Subentregable__c sub= new Subentregable__c(Name= 'Sub1',Proyecto__c=proyecto.Id,CodigoSubentregable__c='Sub1',Descripciom__c='Sub1',Estado__c='Pendiente',ResponsableN1__c=userid,ResponsableN2__c=userid,AprobadorN1__c=userid,AprobadorFinal__c=userid, Fecha_Limite_de_inicio__c= date.today(), Tipo__c='Otros',Subtipo__c='Otros', Avance__c=0,	Peso__c=0);
 			insert sub;	
        	Subentregable__c sub2= new Subentregable__c(Name= 'Sub2',Proyecto__c=proyecto.Id,CodigoSubentregable__c='Sub2',Descripciom__c='Sub2',Estado__c='Pendiente',ResponsableN1__c=userid,ResponsableN2__c=userid,AprobadorN1__c=userid,AprobadorFinal__c=userid, Fecha_Limite_de_inicio__c= date.today(), Tipo__c='Otros',Subtipo__c='Otros', Avance__c=0, Peso__c=0);
			insert sub2;
			           
       // } 
    }
    
        static TestMethod void Submit_ApprovarControlador(){
            Test.startTest(); 
            Proyecto__c nameProyecto= [SELECT Id FROM Proyecto__c WHERE Name ='Proyecto Test' LIMIT 1]; 
            Submit_ApprovarControlador.processPoject(nameProyecto.Id);
   			Test.stopTest();
        }
    
       
    
}
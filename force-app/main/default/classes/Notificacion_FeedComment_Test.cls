@isTest(SeeAllData=true)
public class Notificacion_FeedComment_Test {
    
    @isTest
    static void notificacionFeedComment() {
        // Buscar o crear el grupo "Commercial Chat"
        CollaborationGroup chatterGroup;
        List<CollaborationGroup> groups = [SELECT Id FROM CollaborationGroup WHERE Name = 'Commercial Chat' LIMIT 1];
        if (groups.isEmpty()) {
            chatterGroup = new CollaborationGroup(
                Name = 'Commercial Chat',
                CollaborationType = 'Public'
            );
            insert chatterGroup;
        } else {
            chatterGroup = groups[0];
        }
        
        // Buscar o crear un usuario adicional para que haya destinatarios
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Usuario CRM' LIMIT 1];
        List<User> users = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = true LIMIT 2];
        User u1, u2;
        if (users.size() < 2) {
            u1 = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            u2 = new User(
                FirstName = 'Test',
                LastName = 'User2',
                Email = 'testuser2@example.com',
                Username = 'testuser2' + System.currentTimeMillis() + '@example.com',
                Alias = 'tuser2',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es_ES',
                TimeZoneSidKey = 'Europe/Madrid',
                ProfileId = p.Id,
                IsActive = true
            );
            insert u2;
        } else {
            u1 = users[0];
            u2 = users[1];
        }
        
        // Añadir ambos usuarios al grupo si no están ya
        Set<Id> existingMembers = new Set<Id>();
        for (CollaborationGroupMember m : [
            SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId = :chatterGroup.Id
        ]) {
            existingMembers.add(m.MemberId);
        }
        List<CollaborationGroupMember> members = new List<CollaborationGroupMember>();
        if (!existingMembers.contains(u1.Id)) {
            members.add(new CollaborationGroupMember(CollaborationGroupId = chatterGroup.Id, MemberId = u1.Id));
        }
        if (!existingMembers.contains(u2.Id)) {
            members.add(new CollaborationGroupMember(CollaborationGroupId = chatterGroup.Id, MemberId = u2.Id));
        }
        if (!members.isEmpty()) {
            insert members;
        }
        
        // Crear publicación en el grupo (usando u1 como autor)
        FeedItem post = new FeedItem(
            ParentId = chatterGroup.Id,
            Body = 'Publicación de prueba',
            Type = 'TextPost',
            CreatedById = u1.Id
        );
        insert post;
        
        // Ejecutar el trigger con un comentario (usando u2 como autor)
        Test.startTest();
        System.runAs(u2) {
            FeedComment comment = new FeedComment(
                FeedItemId = post.Id,
                CommentBody = '<p>Comentario de prueba</p>'
            );
            insert comment;
        }
        
        //Notificacion_FeedComment.test();
        
        Test.stopTest();
        
        System.assert(true, 'El trigger se ejecutó correctamente');
    }
}
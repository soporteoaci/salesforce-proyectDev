trigger Notificacion_FeedComment on FeedComment (after insert) {
    
    // Obtención de publicaciones que contengan comentarios
    Set<Id> feedItemIds = new Set<Id>();
    for (FeedComment fc : Trigger.new) {
        if (fc.FeedItemId != null) {
            feedItemIds.add(fc.FeedItemId);
        }
        System.debug('FeedItemIds:'+ feedItemIds);
    }
    
    // Búsqueda del chatter por su nombre
    ID commercialChat = [SELECT Id FROM CollaborationGroup WHERE Name = 'Commercial Chat'].Id;
    
    System.debug('CommercialChat:'+ commercialChat);
    
    // Obtener los FeedItems relacionados
    Map<Id, FeedItem> feedItems = new Map<Id, FeedItem>(
        [SELECT Id, CreatedById, ParentId, Type FROM FeedItem 
         WHERE Id IN :feedItemIds AND ParentId = :commercialChat]
    );
    
    System.debug('feedItems Map:'+ feedItems);
    
    // Obtener miembros de los grupos
    List<Id> groupMemberIds = new List<Id>();
    for (CollaborationGroupMember member : [
        SELECT MemberId
        FROM CollaborationGroupMember
        WHERE CollaborationGroupId = :commercialChat
    ]) {
        groupMemberIds.add(member.MemberId);
    }
    
    System.debug('groupMemberIds:'+ groupMemberIds);
    
    // Obtener el ID del tipo de notificación personalizada
    CustomNotificationType notificationType = 
        [SELECT Id, DeveloperName 
         FROM CustomNotificationType 
         WHERE DeveloperName='Nueva_publicacin_en_grupo'];
    
    
    // Enviar notificaciones a los miembros del grupo
    for (FeedComment fc : Trigger.new) {
        FeedItem relatedItem = feedItems.get(fc.FeedItemId);
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        List<Id> allMembers = groupMemberIds;
        Set<String> recipients = new Set<String>();
        
        // Excluir al creador del comentario y al creador de la publicación
        for (Id userId : allMembers) {
            if (userId != fc.CreatedById && (relatedItem == null || userId != relatedItem.CreatedById)) {
                recipients.add(userId);
            }
        }
        
        System.debug('recipients:'+ recipients);
        
        if (!recipients.isEmpty()) {
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTitle('Nuevo comentario en el grupo');
            notification.setBody(
                fc.CommentBody != null 
                ? fc.CommentBody.replaceAll('<[^>]+>', '') 
                : 'Hay un nuevo comentario en el grupo.'
            );
            notification.setSenderId(fc.CreatedById);
            notification.setTargetId(relatedItem.ParentId);
        }
        try{
            System.debug('notification:'+ notification);
            notification.send(recipients);
        }
        catch (Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}
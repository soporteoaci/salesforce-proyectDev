trigger ActualizaFechaAbiertaTicket on Ticket__c (after update) {
    
    if (Trigger.isUpdate){
        
        if(!System.isFuture()){
            AvoidRecursion.isFirstTime = false;
            String newTicketJSON = JSON.serialize(trigger.new);
            ActualizaFechaAbiertaTicket.ActualizaFecha(newTicketJSON);
        }  
        
    }
    
}
({
    getSObjectFromId: function(recordId) {
        if (!recordId || recordId.length < 3) {
            return null;
        }
        
        const prefix = recordId.substring(0, 3);
        const mapping = {
            'a0F': 'Opportunity',
            'a0m': 'Objetivo__c'
        };
        
        return mapping[prefix] || 'Desconocido';
    }
})
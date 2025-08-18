trigger TaskTrigger on Task (before insert, before update) {
    // Control opcional para saltar ejecución (si existe configuración)
    No_ejecutar_triggers__c cfg;
    try {
        List<No_ejecutar_triggers__c> cfgList = [
            SELECT Correo_usuario__c
            FROM No_ejecutar_triggers__c
            LIMIT 1
        ];
        if (!cfgList.isEmpty()) cfg = cfgList[0];
    } catch (Exception e) {
        // Silencioso: no bloquear trigger por error en configuración
    }
    if (cfg != null && UserInfo.getUserEmail() == cfg.Correo_usuario__c) {
        return;
    }

    // Recolectar Ids (bulk safe)
    Set<Id> acctFieldIds      = new Set<Id>();
    Set<Id> acctWhatIds       = new Set<Id>();
    Set<Id> contactFieldIds   = new Set<Id>();
    Set<Id> contactWhatIds    = new Set<Id>();
    Set<Id> oppFieldIds       = new Set<Id>(); // desde campo custom Opportunity__c
    Set<Id> oppWhatIds        = new Set<Id>(); // desde WhatId
    Set<Id> objetivoFieldIds  = new Set<Id>();
    Set<Id> objetivoWhatIds   = new Set<Id>();

    for (Task t : Trigger.new) {
        if (t.Clic_comercial__c != null) acctFieldIds.add(t.Clic_comercial__c);
        if (t.Contacto__c       != null) contactFieldIds.add(t.Contacto__c);
        if (t.Objetivo__c       != null) objetivoFieldIds.add(t.Objetivo__c);
        if (t.Opportunity__c    != null) oppFieldIds.add(t.Opportunity__c); // CAMBIO: antes Oportunidad__c

        if (t.WhatId != null) {
            String sObjName = String.valueOf(t.WhatId.getSObjectType());
            if (sObjName == 'Opportunity')  oppWhatIds.add(t.WhatId);
            else if (sObjName == 'Account') acctWhatIds.add(t.WhatId);
            else if (sObjName == 'Objetivo__c') objetivoWhatIds.add(t.WhatId);
        }
        if (t.WhoId != null) {
            String sObjName = String.valueOf(t.WhoId.getSObjectType());
            if (sObjName == 'Contact') contactWhatIds.add(t.WhoId);
        }
    }

    // Queries (solo si hay Ids)
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    if (!oppFieldIds.isEmpty() || !oppWhatIds.isEmpty()) {
        Set<Id> allOppIds = new Set<Id>();
        allOppIds.addAll(oppFieldIds);
        allOppIds.addAll(oppWhatIds);
        for (Opportunity o : [
            SELECT Id, Cliente__c
            FROM Opportunity
            WHERE Id IN :allOppIds
        ]) {
            oppMap.put(o.Id, o);
        }
    }

    Map<Id, Account> acctMap = new Map<Id, Account>();
    if (!acctFieldIds.isEmpty() || !acctWhatIds.isEmpty()) {
        Set<Id> allAcctIds = new Set<Id>();
        allAcctIds.addAll(acctFieldIds);
        allAcctIds.addAll(acctWhatIds);
        for (Account a : [
            SELECT Id
            FROM Account
            WHERE Id IN :allAcctIds
        ]) {
            acctMap.put(a.Id, a);
        }
    }

    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    if (!contactFieldIds.isEmpty() || !contactWhatIds.isEmpty()) {
        Set<Id> allContactIds = new Set<Id>();
        allContactIds.addAll(contactFieldIds);
        allContactIds.addAll(contactWhatIds);
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id IN :allContactIds
        ]) {
            contactMap.put(c.Id, c);
        }
    }

    Map<Id, Objetivo__c> objetivoMap = new Map<Id, Objetivo__c>();
    if (!objetivoFieldIds.isEmpty() || !objetivoWhatIds.isEmpty()) {
        Set<Id> allObjIds = new Set<Id>();
        allObjIds.addAll(objetivoFieldIds);
        allObjIds.addAll(objetivoWhatIds);
        for (Objetivo__c ob : [
            SELECT Id, Cuenta__c
            FROM Objetivo__c
            WHERE Id IN :allObjIds
        ]) {
            objetivoMap.put(ob.Id, ob);
        }
    }

    // Lógica principal
    for (Task t : Trigger.new) {

        // Fecha de creación custom si vacía
        if (t.Fecha_Creacion__c == null) {
            t.Fecha_Creacion__c = Date.today();
        }

        // Account: sincronía WhatId <-> Clic_comercial__c
        if (t.WhatId == null && t.Clic_comercial__c != null) {
            t.WhatId = t.Clic_comercial__c;
        } else if (t.WhatId != null && t.Clic_comercial__c == null) {
            if (String.valueOf(t.WhatId.getSObjectType()) == 'Account') {
                t.Clic_comercial__c = t.WhatId;
            }
        }

        // Contact: sincronía WhoId <-> Contacto__c + rellenar Clic_comercial__c
        if (t.WhoId == null && t.Contacto__c != null) {
            t.WhoId = t.Contacto__c;
            Contact c = contactMap.get(t.Contacto__c);
            if (c != null) t.Clic_comercial__c = c.AccountId;
        } else if (t.WhoId != null && t.Contacto__c == null) {
            if (String.valueOf(t.WhoId.getSObjectType()) == 'Contact') {
                t.Contacto__c = t.WhoId;
                Contact c2 = contactMap.get(t.Contacto__c);
                if (c2 != null) t.Clic_comercial__c = c2.AccountId;
            }
        }

        // Opportunity: sincronía WhatId <-> Opportunity__c (CAMBIO: antes Oportunidad__c)
        if (t.WhatId == null && t.Opportunity__c != null) {
            t.WhatId = t.Opportunity__c;
            Opportunity o = oppMap.get(t.Opportunity__c);
            if (o != null) t.Clic_comercial__c = o.Cliente__c;
        } else if (t.WhatId != null && t.Opportunity__c == null) {
            if (String.valueOf(t.WhatId.getSObjectType()) == 'Opportunity') {
                t.Opportunity__c = t.WhatId;
                Opportunity o2 = oppMap.get(t.Opportunity__c);
                if (o2 != null) t.Clic_comercial__c = o2.Cliente__c;
            }
        }

        // Objetivo: sincronía WhatId <-> Objetivo__c
        if (t.WhatId == null && t.Objetivo__c != null) {
            t.WhatId = t.Objetivo__c;
            Objetivo__c ob = objetivoMap.get(t.Objetivo__c);
            if (ob != null) t.Clic_comercial__c = ob.Cuenta__c;
        } else if (t.WhatId != null && t.Objetivo__c == null) {
            if (String.valueOf(t.WhatId.getSObjectType()) == 'Objetivo__c') {
                t.Objetivo__c = t.WhatId;
                Objetivo__c ob2 = objetivoMap.get(t.Objetivo__c);
                if (ob2 != null) t.Clic_comercial__c = ob2.Cuenta__c;
            }
        }
    }
}
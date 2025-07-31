@isTest (SeeAllData=false)
private class GestionDuplicados_Test {

    private static void asegurarNoEjecutarTriggers() {
        try {
            No_ejecutar_triggers__c saltar_trigger = new No_ejecutar_triggers__c();
            saltar_trigger.Correo_usuario__c = '';
            insert saltar_trigger;
        } catch (DmlException e) {
            // Si ya existe, ignoramos el error
        }
    }

    @isTest
    static void testFusionAccount() {
        System.debug('INICIO - testFusionAccount');
        asegurarNoEjecutarTriggers();

        // Caso 1: Ambos campos vacíos, deben copiarse ambos
        Account cuentaConservar = new Account(
            Name = 'ABC_Conservar_' + System.currentTimeMillis(),
            Phone = '123456789_1'
        );
        insert cuentaConservar;

        Account cuentaDuplicada = new Account(
            Name = 'ABC_Duplicada_' + System.currentTimeMillis(),
            SAP_Account__c = '5555',
            Sector__c = 'Finanzas',
            Subsector__c = 'Bancos',
            Phone = '223456789_1'
        );
        insert cuentaDuplicada;

        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'Account';
        input.idConservar = cuentaConservar.Id;
        input.idDuplicado = cuentaDuplicada.Id;

        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});
        System.assertEquals(1, resultados.size());
        System.assert(resultados[0].exito, 'true');

        Account cuentaActualizada = [SELECT Sector__c, Subsector__c FROM Account WHERE Id = :cuentaConservar.Id];
        System.assertEquals('Finanzas', cuentaActualizada.Sector__c);
        System.assertEquals('Bancos', cuentaActualizada.Subsector__c);

        // Caso 2: Subsector__c vacío y Sector__c coincide, solo se copia Subsector__c
        Account cuentaConservar2 = new Account(
            Name = 'DEF_Conservar_' + System.currentTimeMillis(),
            Phone = '987654321_2',
            Sector__c = 'Utilities'
        );
        insert cuentaConservar2;

        Account cuentaDuplicada2 = new Account(
            Name = 'DEF_Duplicada_' + System.currentTimeMillis(),
            Sector__c = 'Utilities',
            Subsector__c = 'Gas',
            Phone = '887654321_2'
        );
        insert cuentaDuplicada2;

        GestionDuplicados.InputWrapper input2 = new GestionDuplicados.InputWrapper();
        input2.objeto = 'Account';
        input2.idConservar = cuentaConservar2.Id;
        input2.idDuplicado = cuentaDuplicada2.Id;

        List<GestionDuplicados.ResultadoFusion> resultados2 = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input2});
        Account cuentaActualizada2 = [SELECT Sector__c, Subsector__c FROM Account WHERE Id = :cuentaConservar2.Id];
        System.assertEquals('Utilities', cuentaActualizada2.Sector__c);
        System.assertEquals('Gas', cuentaActualizada2.Subsector__c);

        // Caso 3: Solo Subsector__c vacío y Sector__c NO coincide, NO se copia Subsector__c
        Account cuentaConservar3 = new Account(
            Name = 'GHI_Conservar_' + System.currentTimeMillis(),
            Phone = '111222333_3',
            Sector__c = 'Finanzas'
        );
        insert cuentaConservar3;

        Account cuentaDuplicada3 = new Account(
            Name = 'GHI_Duplicada_' + System.currentTimeMillis(),
            Sector__c = 'Utilities',
            Subsector__c = 'Gas',
            Phone = '211222333_3'
        );
        insert cuentaDuplicada3;

        GestionDuplicados.InputWrapper input3 = new GestionDuplicados.InputWrapper();
        input3.objeto = 'Account';
        input3.idConservar = cuentaConservar3.Id;
        input3.idDuplicado = cuentaDuplicada3.Id;

        List<GestionDuplicados.ResultadoFusion> resultados3 = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input3});
        Account cuentaActualizada3 = [SELECT Sector__c, Subsector__c FROM Account WHERE Id = :cuentaConservar3.Id];
        System.assertEquals('Finanzas', cuentaActualizada3.Sector__c);
        System.assertEquals(null, cuentaActualizada3.Subsector__c);

        System.debug('FIN - testFusionAccount');
    }
    
    @isTest
    static void testFusionContact() {
        System.debug('INICIO - testFusionContact');
        asegurarNoEjecutarTriggers();

        Account cuentaConservar = new Account(Name='cuentaConservar',  Phone = '123456789');
        insert cuentaConservar;

        Account cuentaDuplicada = new Account(Name = 'cuentaDuplicada', SAP_Account__c='5555', SAP_Account_IB__c='cuentaDuplicada', Sector__c= 'Finanzas', Subsector__c ='Bancos');
        insert cuentaDuplicada;
        
        // Contactos a fusionar
        Contact contactoPrincipal = new Contact(
            FirstName = 'Ernesto',
            LastName = 'Principal',
            Email = 'contactoPrincipal@example.com',
            AccountId = cuentaConservar.Id
        );
        insert contactoPrincipal;

        Contact contactoDuplicado = new Contact(
            FirstName = 'Carlos',
            LastName = 'Duplicado',
            Email = 'contactoDuplicado@example.com',
            Phone = '999999999',
            AccountId = cuentaDuplicada.Id
        );
        insert contactoDuplicado;
        
        // Relacionado: Tarea (Actividad)
        Task tarea = new Task(
            Subject = 'Prueba',
            WhoId = contactoDuplicado.Id
        );
        insert tarea;

        // Input
        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'Contact';
        input.idConservar = contactoPrincipal.Id;
        input.idDuplicado = contactoDuplicado.Id;

        // LLamada al método fusionarRegistros
        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});

        System.debug('Resultado Contact: ' + resultados);
        System.assertEquals(1, resultados.size());
        System.assert(resultados[0].exito, 'true');
        Contact actualizado = [SELECT Phone FROM Contact WHERE Id = :contactoPrincipal.Id];
        System.assertEquals('999999999', actualizado.Phone);

        Task tareaActualizada = [SELECT WhoId FROM Task WHERE Id = :tarea.Id];
        System.assertEquals(contactoPrincipal.Id, tareaActualizada.WhoId);
        
        System.debug('FIN - testFusionContact');
    }
    
    // Fusionar un objeto que no existe
    @isTest
    static void testFusionObjetoInvalido() {
        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'ObjetoInexistente__c';
        input.idConservar = '001000000000000AAA';
        input.idDuplicado = '001000000000001AAA';

        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});
        System.assertEquals(false, resultados[0].exito);
        System.assert(resultados[0].mensaje.contains('Objeto no válido'));
    }

    // Fusionar registros sin datos
    @isTest
    static void testFusionEntradasVacias() {
        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>());
        System.assertEquals(0, resultados.size());
    }

    // Fusionar registros con campos vacíos
    @isTest
    static void testInformarCamposVaciosError() {
        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'Account';
        input.idConservar = '001000000000000ZZZ';
        input.idDuplicado = '001000000000001ZZZ';
        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});
        System.assertEquals(false, resultados[0].exito);
    }

    @isTest
    static void testNoCopiaSiAmbosInformados() {
        // Ambos campos ya informados en el registro a conservar
        Account cuentaConservar = new Account(Name='cuentaConservar4', Phone = '555555555', Sector__c='Finanzas', Subsector__c='Bancos');
        insert cuentaConservar;
        Account cuentaDuplicada = new Account(Name='cuentaDuplicada4', Sector__c='Industria', Subsector__c='Mayorista');
        insert cuentaDuplicada;

        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'Account';
        input.idConservar = cuentaConservar.Id;
        input.idDuplicado = cuentaDuplicada.Id;

        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});
        Account cuentaActualizada = [SELECT Sector__c, Subsector__c FROM Account WHERE Id = :cuentaConservar.Id];
        System.assertEquals('Finanzas', cuentaActualizada.Sector__c);
        System.assertEquals('Bancos', cuentaActualizada.Subsector__c);
    }

    @isTest
    static void testSoloSectorVacio() {
        // Solo Sector__c vacío, Subsector__c ya informado
        Account cuentaConservar = new Account(Name='JKL_Conservar_'+ System.currentTimeMillis(), Phone = '666666666', Subsector__c='Bancos');
        insert cuentaConservar;
        Account cuentaDuplicada = new Account(Name='JKL_Duplicada_'+ System.currentTimeMillis(), Sector__c='Finanzas', Subsector__c='Bancos');
        insert cuentaDuplicada;

        GestionDuplicados.InputWrapper input = new GestionDuplicados.InputWrapper();
        input.objeto = 'Account';
        input.idConservar = cuentaConservar.Id;
        input.idDuplicado = cuentaDuplicada.Id;

        List<GestionDuplicados.ResultadoFusion> resultados = GestionDuplicados.fusionarRegistros(new List<GestionDuplicados.InputWrapper>{input});
        Account cuentaActualizada = [SELECT Sector__c, Subsector__c FROM Account WHERE Id = :cuentaConservar.Id];
        // Según la lógica, solo se copia Sector__c si ambos están vacíos, así que aquí no debería copiarse nada
        System.assertEquals(null, cuentaActualizada.Sector__c);
        System.assertEquals('Bancos', cuentaActualizada.Subsector__c);
    }
}
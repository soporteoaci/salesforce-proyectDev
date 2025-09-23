public class TestDataFactory {
    public static Opportunity createOpportunity(String etapa, String lineaServicio,String tipoRegistro) {
        
        // ➊  Cliente + contacto reutilizables
        Account cliente = createClientes(1)[0];
        Contact contacto = new Contact(
            FirstName = 'Contacto',
            LastName  = 'Test',
            Email     = 'test' + Datetime.now().getTime() + '@example.com',
            AccountId = cliente.Id
        );
        insert contacto;
        System.debug('Línea de servicio en TestDataFactory: '+lineaServicio);
        
        RecordType rd = [SELECT Id, DeveloperName, Name
            FROM RecordType
            WHERE SObjectType = 'Opportunity' AND DeveloperName=:tipoRegistro];
        
        Opportunity opp = new Opportunity(
            RecordTypeId                   = rd.Id,
            Name                           = 'Opp-Test',
            StageName                      = 'Prospecting',
            CloseDate                      = Date.today().addDays(15),
            Nombre_Corto__c                = 'Opp-Test',
            AccountId                      = cliente.Id,
            Contacto_Principal__c          = contacto.Id,
            Pais__c                        = 'ES',
            Sociedad_Ayesa__c              = '0002',
            Probability                    = 10,
            Mercado__c                     = '60029413',
            DivisionPickList__c            = '60049219',
            Linea_de_Servicio__c           = lineaServicio,
            Clase_de_oferta__c             = 'Privada',
            Tipo_de_Oportunidad__c         = 'Licitación',
            Importe_Licitacion__c          = 200000,
            Margen_estimado_incluye_recargos__c = 10,
            Fecha_limite_de_presentacion__c     = Date.today(),
            Fecha_estimada_de_cierre__c         = Date.today(),
            Plazo_de_ejecuci_n_meses__c         = 1,
            Tipo_Participacion_Ayesa__c         = 'Contratista Principal',
            Participacion_Ayesa__c              = 100,
            Subfase__c= 'Alta'  
        );
        insert opp;
        return opp;
    }
    
    
    
    public static List<Account> createClientes(Integer numClientes) {
        List<Account> clientes = new List<Account>();
        for(Integer i=0;i<numClientes;i++) {
            Account a = new Account(
                Name = 'TestCliente' + i + '_' + Datetime.now().getTime(),
                Sector__c = 'Utilities',
                Subsector__c='Otros Servicios',
                Alias__c='Alias Prueba',
                SAP_Account__c = String.valueOf(Datetime.now().getTime())
            );
            clientes.add(a);
        }
        Database.SaveResult[] srList = Database.insert(clientes, false);
        return clientes;
    }
    
    public static Id rtId(Schema.SObjectType objType, String rtName) {
        return (rtName == null
                ? null
                : objType.getDescribe()
                .getRecordTypeInfosByName()
                .get(rtName)
                .getRecordTypeId());
    }

    public static Parametrica__c createParam(Map<String,Object> values) {
        Parametrica__c p = (Parametrica__c)Type.forName('Parametrica__c')
                                               .newInstance();
        for (String k : values.keySet()) {
            p.put(k, values.get(k));
        }
        insert p;
        return p;
    }


    public static Parametrica_2__c createParam2(String rtName,Map<String,Object> values) {

        Parametrica_2__c p2 = (Parametrica_2__c)Type.forName('Parametrica_2__c').newInstance();

        if (rtName != null)
            // DESPUÉS
            p2.RecordTypeId =
            Schema.SObjectType.Parametrica_2__c
            .getRecordTypeInfosByName()
            .get(rtName)
            .getRecordTypeId();

        for (String k : values.keySet()) {
            p2.put(k, values.get(k));
        }
        insert p2;
        return p2;
    } 

    
    
    public static Opportunity getOpportunity(String idOpportunity) {
        
        List<Opportunity> opps =  [select id, Name ,//Falta_definicion_del_objeto__c
                                      //No_existe_Limitacion__c,
                                      //Se_incluye_lucro__c,
                                      //Posibilidad_de_resoluci_n_unilateral__c,
                                      //Resoluci_n_por_conveniencia__c,
                                      //Causas_no_tasadas_y_ambiguas__c,
                                      //Codigo_OC__c,
                                      //Codigo_OC2__c,
                                      Objetivo_del_proyecto__c,
                                      Cliente__c,
                                      Division_SAP__c,
                                      Fecha_limite_de_presentacion__c,
                                      Fecha_estimada_de_cierre__c,
                                      Plazo_de_ejecuci_n_meses__c,//Fecha_Fin_PEP_cal__c,
                                      //Importe_euros__c,
                                      Importe_total_sin_IVA__c,
                                      Jefe_de_Proyecto__c,
                                      GP__c,
                                      RUP__c,
                                      //Probabilidad_CRM_SAP__c,
                                      Area_de_negocio__c,
                                      Area_de_negocio_N1__c,
                                      Area_de_negocio_N2__c,
                                      Fecha_estimada_de_cierre_calc__c,
                                      AETIC__c,
                                      Sector_cliente__c,
                                      Pais_ejecucion__c,
                                      Pais_cliente__c,
                                      Territorio_ejecucion__c,
                                      Territorio_cliente__c,
                                      Centro__c,
                                      //Grupo__c,
                                      //Subgrupo__c,
                                      Probability,
                                      Clasificacion_funcional_Nivel_1__c,
                                      Clasificacion_funcional_Nivel_2__c,
                                      Clasificacion_funcional_Nivel_3__c,
                                      Clasificacion_tecnologica_Nivel_1__c,
                                      Clasificacion_tecnologica_Nivel_2__c,
                                      Actualizar_Estado__c,
                                      Cliente__r.Name,
                                      Cliente__r.SAP_Account__c,
                                      Oferta_SAP__c,
                                      StageName
                                      from Opportunity  where id = :idOpportunity];
        
        if (opps.size() > 0) {
            return opps.get(0);
        }
        
        return null;
    }
}
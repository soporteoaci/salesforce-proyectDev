@isTest
public class TestDataFactory {
	//public static List<Oportunidad__c> createOportunidad(String etapa) {
	public static Oportunidad__c createOportunidad(String etapa, String centro) {
        
        List<Account> clientes = createClientes(1);
        Account cliente = clientes.get(0);
        
        //List<Oportunidad__c> oportunidades = new List<Oportunidad__c>();        
        //for(Integer i=0;i<numOports;i++) {
            /*Oportunidad__c oportunidad = new Oportunidad__c(
                Name = 'TestOportunidad',
                Nombre_Corto__c = 'TestOportunidad',
                //Etapa__c = 'Abierta',
                Etapa__c = etapa,
                Cliente__c = cliente.Id,
                Probabilidad__c = '100',
                Pais__c = 'Perú',
                Area__c = 'ACO',
                Fecha_limite_de_presentacion__c =  system.today(),
                Fecha_estimada_de_cierre__c = system.today() + 10,
                Plazo_de_ejecuci_n_meses__c = 12,
                Tipo_Participacion_Ayesa__c = 'UTE - Consorcio',
                
                Objetivo_del_proyecto__c = 'Test Oportunidad',
                Jefe_de_Proyecto__c = 'JUAN MANUEL MORENO VAZQUEZ - 00002971',
                GP__c = 'JOSE MARIA DEL MOLINO POLO - 00002599',
                RUP__c = 'JOSE MARIA DEL MOLINO POLO - 00002599',
                Importe_total_sin_IVA__c = 1000000,
                Contratado_a_o_oportunidad__c = 1000000,
                Area_de_negocio__c = 'Sector Público',
                Area_de_negocio_N1__c = 'Andalucía',
                Area_de_negocio_N2__c = '01.1. S. Público Andalucía',
                Division_SAP__c = 'ACO - DIVISIÓN AGUA Y RECURSOS NATURALES',
                AETIC__c = 'BPO',
                Sector_cliente__c = 'Administración Pública General',
                Pais_ejecucion__c = 'Perú',
                Pais_cliente__c = 'Perú',
                Territorio_ejecucion__c = 'Amazonas',
                Territorio_cliente__c = 'Amazonas',
                Centro__c = centro,
                Clasificacion_funcional_Nivel_1__c = 'Servicios Públicos',
                Clasificacion_funcional_Nivel_2__c = 'Servicios Sociales y Dependencia',
                Clasificacion_funcional_Nivel_3__c = 'Otros',
                Clasificacion_tecnologica_Nivel_1__c = 'Pendiente Clasificar',
                Clasificacion_tecnologica_Nivel_2__c = 'Pendiente Clasificar',
                
                Grupo__c = 'BPO',
                Subgrupo__c = 'Otros',
                
                Margen_estimado_incluye_recargos__c = 0,
                Tipo_de_Oportunidad__c = 'Oferta a realizar',
                Sociedad_Ayesa__c = '0003 - AYESA ING. Y ARQU., S.A.',
                Importe_Licitacion__c = 1000000,
                
                Actualizar_Estado__c = true,
                
                Clase_de_oferta__c = 'Acuerdo Marco',
                
                Mercado__c = 'V-AERONAUTICS',
                Direccion_Operaciones__c = 'ENGINEERING'
                
            );*/
        system.debug('etapa oportunidad --> ' + etapa);
        Oportunidad__c oportunidad = new Oportunidad__c(Nombre_Corto__c='Prueba',Name='Prueba', Cliente__c=Cliente.Id, Pais__c='ES',Sociedad_Ayesa__c='0002',Probabilidad__c='10', Mercado__c='60029413',DivisionPickList__c='60049219',
                                              Clase_de_oferta__c='Pública',Tipo_de_Oportunidad__c='Licitación', 	Importe_Licitacion__c=200000,Margen_estimado_incluye_recargos__c=10,Fecha_limite_de_presentacion__c=System.today(),
                                              Fecha_estimada_de_cierre__c=System.today(), Plazo_de_ejecuci_n_meses__c=1,Tipo_Participacion_Ayesa__c='Contratista Principal', 	Participacion_Ayesa__c=100, Direccion_Operaciones__c='ENGINEERING',
                                                       Etapa__c = etapa, Centro__c = centro, Importe_total_sin_IVA__c = 1000000, Contratado_a_o_oportunidad__c = 1000000, Actualizar_Estado__c = true, Objetivo_del_proyecto__c = 'Test Oportunidad', 
                                                        Jefe_de_Proyecto__c = 'JUAN MANUEL MORENO VAZQUEZ - 00002971', GP__c = 'JOSE MARIA DEL MOLINO POLO - 00002599', RUP__c = 'JOSE MARIA DEL MOLINO POLO - 00002599');
            //oportunidades.add(a);
        //}
        //insert oportunidades;
        system.debug('oportunidad creada --> ' + oportunidad);
        system.debug('oportunidad creada - etapa --> ' + oportunidad.Etapa__c);
        insert oportunidad;
        
        /*List<Competidor_Socio__c> socios = new List<Competidor_Socio__c>();
        for (Integer j=0;j<numOports;j++) {
            Oportunidad__c oportunidad = oportunidades[j];
            // Por cada oportunidad insertada, añadimos socios
            for (Integer k=0;k<numSociosPorOport;k++) {
                socios.add(new Competidor_Socio__c(
                    Name=acct.Name + ' Opportunity ' + k,
                    StageName='Prospecting',
                    CloseDate=System.today().addMonths(1),
                    AccountId=acct.Id
                ));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;*/
        
        //return oportunidades;
        return oportunidad;
    }
    
    
    public static List<Account> createClientes(Integer numClientes) {
        List<Account> clientes = new List<Account>();
        
        for(Integer i=0;i<numClientes;i++) {
            Account a = new Account(
                Name='TestCliente' + i,
                Sector__c = 'Utilities',
            	Subsector__c='Otros Servicios',
                Alias__c='Alias Prueba',
                SAP_Account__c = '0000003115'
            );
            clientes.add(a);
        }
        insert clientes;       
        
        return clientes;
    }
    
    
    public static void initParametricas() {
        List<Parametrica__c> parametricas = new List<Parametrica__c>();
           
        //AREA_NEGOCIO
        Parametrica__c a = new Parametrica__c(
            Name='60018397',
            Codigo_Padre__c = '',
            Tipo__c = 'AREA_NEGOCIO',
            Valor__c = 'Sector Público',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //AREA_NEGOCIO N1
        a = new Parametrica__c(
            Name='60012635',
            Codigo_Padre__c = '60018397',
            Tipo__c = 'AREA_NEGOCIO_N1',
            Valor__c = 'Andalucía',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //AREA_NEGOCIO N2
        a = new Parametrica__c(
            Name='60012636',
            Codigo_Padre__c = '60012635',
            Tipo__c = 'AREA_NEGOCIO_N2',
            Valor__c = '01.1. S. Público Andalucía',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //PAIS
        a = new Parametrica__c(
            Name='PE',
            Codigo_Padre__c = '',
            Tipo__c = 'PAIS',
            Valor__c = 'Perú',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //TERRITORIO
        a = new Parametrica__c(
            Name='11',
            Codigo_Padre__c = 'PE',
            Tipo__c = 'TERRITORIO',
            Valor__c = 'Amazonas',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //AETIC
        a = new Parametrica__c(
            Name='L05',
            Codigo_Padre__c = '',
            Tipo__c = 'AETIC',
            Valor__c = 'BPO',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //GRUPO
        a = new Parametrica__c(
            Name='3100',
            Codigo_Padre__c = '',
            Tipo__c = 'GRUPO',
            Valor__c = 'BPO',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //SUBGRUPO
        a = new Parametrica__c(
            Name='3103',
            Codigo_Padre__c = '3100',
            Tipo__c = 'SUBGRUPO',
            Valor__c = 'Otros',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //CENTRO
        a = new Parametrica__c(
            Name='4509',
            Codigo_Padre__c = '0003',
            Tipo__c = 'CENTRO',
            Valor__c = 'AAT - TORRE PELLI',
            Auxiliar__c = 'SE',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //CENTRO II
        a = new Parametrica__c(
            Name='0700',
            Codigo_Padre__c = '0045',
            Tipo__c = 'CENTRO',
            Valor__c = 'AAT - TORRE PELLI 2',
            Auxiliar__c = 'SE',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //DIVISION
        a = new Parametrica__c(
            Name='DARN',
            Codigo_Padre__c = '',
            Tipo__c = 'DIVISION',
            Valor__c = 'ACO - DIVISIÓN AGUA Y RECURSOS NATURALES',
            Auxiliar__c = 'A3D02P',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //EMPLAZAMIENTO
        a = new Parametrica__c(
            Name='P006',
            Codigo_Padre__c = '4501',
            Tipo__c = 'EMPLAZAMIENTO',
            Valor__c = 'ERP',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //SECTOR_CLIENTE
        a = new Parametrica__c(
            Name='3035',
            Codigo_Padre__c = '',
            Tipo__c = 'SECTOR_CLIENTE',
            Valor__c = 'Administración Pública General',
            Auxiliar__c = '30',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //FUNCIONAL_N1
        a = new Parametrica__c(
            Name='45220001',
            Codigo_Padre__c = '',
            Tipo__c = 'FUNCIONAL_N1',
            Valor__c = 'Servicios Públicos',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //FUNCIONAL_N2
        a = new Parametrica__c(
            Name='45220012',
            Codigo_Padre__c = '45220001',
            Tipo__c = 'FUNCIONAL_N2',
            Valor__c = 'Servicios Sociales y Dependencia',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //FUNCIONAL_N3
        a = new Parametrica__c(
            Name='45220096',
            Codigo_Padre__c = '45220012',
            Tipo__c = 'FUNCIONAL_N3',
            Valor__c = 'Otros',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //TECNICO_N1
        a = new Parametrica__c(
            Name='90',
            Codigo_Padre__c = '',
            Tipo__c = 'TECNICO_N1',
            Valor__c = 'Pendiente Clasificar',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //TECNICO_N2
        a = new Parametrica__c(
            Name='9005',
            Codigo_Padre__c = '90',
            Tipo__c = 'TECNICO_N2',
            Valor__c = 'Pendiente Clasificar',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //DIVISION INGENIERIA
        a = new Parametrica__c(
            Name='DARN',
            Codigo_Padre__c = '',
            Tipo__c = 'DIVISION_INGENIERIA',
            Valor__c = 'ACO - DIVISIÓN AGUA Y RECURSOS NATURALES',
            Auxiliar__c = 'A3D02P',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //TIPO TRABAJO
        a = new Parametrica__c(
            Name='TRAB1',
            Codigo_Padre__c = '',
            Tipo__c = 'TIPO_TRABAJO',
            Valor__c = 'TIPO TRABAJO 1',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        //SUBTIPO TRABAJO
        a = new Parametrica__c(
            Name='SUBTRAB1',
            Codigo_Padre__c = '',
            Tipo__c = 'SUBTIPO_TRABAJO',
            Valor__c = 'SUBTIPO TRABAJO 1',
            Auxiliar__c = '',
            Activo__c = true            
        );
        parametricas.add(a);
        
        
        a = new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='V-UTILITIES & ENERGY',Mercado1__c='',Mercado2__c='',Mercado3__c='',
                                                 Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Sector Público', Division2__c='Sector Público Latinoamérica' );
        parametricas.add(a);
        
        a = new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='V-DIRECTOR ENEL',Mercado3__c='V-UTILITIES & ENERGY',Mercado1__c='',Mercado2__c='',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Sector Público', Division2__c='Sector Público Latinoamérica' );
        parametricas.add(a);
        
        a = new Parametrica__c(Codigo_Mercado__c='60029427',Mercado4__c='V-MK LATAM',Mercado3__c='V-DIRECTOR ENEL',Mercado2__c='V-UTILITIES & ENERGY',Mercado1__c='',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Sector Público', Division2__c='Sector Público Latinoamérica' );
        parametricas.add(a);
        
        a = new Parametrica__c(Codigo_Mercado__c='60029427',Mercado3__c='V-MK LATAM',Mercado2__c='V-DIRECTOR ENEL',Mercado1__c='V-UTILITIES & ENERGY',Mercado4__c='V-Enel Mk Brasil L1',
                                                  Tipo__c='No', Valor__c='No',Area__c='ATC', Division__c ='Sector Público', Division2__c='Sector Público Latinoamérica' );
        parametricas.add(a);
        
        
        insert parametricas;       
    }
    
    
    public static Oportunidad__c getOportunidad(String idOpportunity) {
        
        List<Oportunidad__c> opps =  [select id, Name ,Falta_definicion_del_objeto__c,
                                     No_existe_Limitacion__c,
                                     Se_incluye_lucro__c,
                                     Posibilidad_de_resoluci_n_unilateral__c,
                                     Resoluci_n_por_conveniencia__c,
                                     Causas_no_tasadas_y_ambiguas__c,
                                     //Codigo_OC__c,
                                     Codigo_OC2__c,
                                     Objetivo_del_proyecto__c,
                                     Cliente__c,
                                     Division_SAP__c,
                                     Fecha_limite_de_presentacion__c,
                                     Fecha_estimada_de_cierre__c,
                                     Plazo_de_ejecuci_n_meses__c,Fecha_Fin_PEP_cal__c,
                                     Importe_euros__c,
                                     Importe_total_sin_IVA__c,
                                     Jefe_de_Proyecto__c,
                                     GP__c,
                                     RUP__c,
                                     Probabilidad_CRM_SAP__c,
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
                                     Grupo__c,
                                     Subgrupo__c,
                                     Probabilidad__c,
                                     Clasificacion_funcional_Nivel_1__c,
                                     Clasificacion_funcional_Nivel_2__c,
                                     Clasificacion_funcional_Nivel_3__c,
                                     Clasificacion_tecnologica_Nivel_1__c,
                                     Clasificacion_tecnologica_Nivel_2__c,
                                     Actualizar_Estado__c,
                                     Cliente__r.Name,
                                     Cliente__r.SAP_Account__c,
                                     Oferta_SAP__c,
                                     Etapa__c
                                     from Oportunidad__c  where id = :idOpportunity];
                 
        if (opps.size() > 0) {
            return opps.get(0);
        }
        
        return null;
    }
}
public class CRM_IntegrationConstants {
    
    //INTEGRACION BUSQUEDA CODIGO RESPONSABLE
    public final static String INTEGRATION_RESPONSABLE_NAME = 'OCResponsable';
    public final static String INTEGRATION_RESPONSABLE_PARAM01 = 'Data';
    public final static String INTEGRATION_RESPONSABLE_BODY_TEMPLATE = 'username=salesforce&password=CWKwfX7SbWqVjs6V&data={"activo":"true","nombre":"Jorge","apellido1":"Sabido"}';
    
    
    //INTEGRACION APROBACIONES
    public final static String INTEGRATION_APR_PRELIMINAR_NAME = 'AprPreliminar';
    public final static Map<Integer, String> LISTA_PARAM = new Map<Integer, String>();
    static {
        LISTA_PARAM.put(1, 'npersonalSolicitante');
        LISTA_PARAM.put(2, 'descripcion');
        LISTA_PARAM.put(3, 'codigoSociedad');
        LISTA_PARAM.put(4, 'codigoPais');
        LISTA_PARAM.put(5, 'codigoOportunidadComercial');
        LISTA_PARAM.put(6, 'propietarioOportunidad');
        LISTA_PARAM.put(7, 'clienteOportunidad');
        LISTA_PARAM.put(8, 'divisionSectordeMercado');
        LISTA_PARAM.put(9, 'fechadePresentacionOportunidad');
        LISTA_PARAM.put(10, 'importeTotalsinIVA');
        LISTA_PARAM.put(11, 'oportunidadUTE');
        LISTA_PARAM.put(12, 'importeOportunidad');
        LISTA_PARAM.put(13, 'importeExtensiones');
        LISTA_PARAM.put(14, 'importeTotal');
    }
    
}
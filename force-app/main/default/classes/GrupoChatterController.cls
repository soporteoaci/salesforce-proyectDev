public class GrupoChatterController {
  @AuraEnabled(cacheable=true)
    public static Id obtenerIdGrupo(String nombreGrupo) {
        System.debug('SCM - entro en GrupoChatterController - obtenerIdGrupo: ' + nombreGrupo);
        CollaborationGroup grupo = [
            SELECT Id 
            FROM CollaborationGroup 
            WHERE Name = :nombreGrupo 
            LIMIT 1
        ];
        return grupo.Id;
    }
}
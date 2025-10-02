@IsTest
private class EquipoPreventaServiceTest {
    @TestSetup
    static void setup() {
        Opportunity o = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today().addDays(30));
        insert o;
        insert new Equipo_Oferta__c(Opportunity__c=o.Id, Nombre_y_apellidos__c='Juan Pérez', Mercantil__c='A', Horas__c=10);
    }
    @IsTest
    static void testLoadAndSave() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
        EquipoPreventaService.InitData d = EquipoPreventaService.loadData(o.Id);
        System.assert(!d.existentes.isEmpty(), 'Debe haber 1');
        // Simular cambio + alta + baja
        List<EquipoPreventaService.EquipoPreventaWrapper> lista = new List<EquipoPreventaService.EquipoPreventaWrapper>();
        EquipoPreventaService.EquipoPreventaWrapper orig = d.existentes[0];
        orig.horas = 12; orig.isChanged = true; // update
        orig.isDeleted = true; // delete (prima el borrado)
        EquipoPreventaService.EquipoPreventaWrapper nuevo = new EquipoPreventaService.EquipoPreventaWrapper();
        nuevo.nombre='Nuevo'; nuevo.mercantil='A'; nuevo.horas=5; nuevo.isNew=true; nuevo.isChanged=true;
        lista.add(orig);
        lista.add(nuevo);
        EquipoPreventaService.SaveResultWrapper sr = EquipoPreventaService.save(o.Id, lista);
        System.assertEquals(1, sr.insertados, 'Insertados');
        System.assertEquals(0, sr.actualizados, 'Actualizados');
        System.assertEquals(1, sr.eliminados, 'Eliminados');
        System.assert(sr.html.contains('<table'), 'HTML generado');
    }
}
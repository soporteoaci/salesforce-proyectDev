@isTest
public class DividirPicklist_Test {

    @isTest
    static void testSepararValoresSinAntiguo() {
        // Caso con valores nuevos y sin valor antiguo
        DividirPicklist.ElementoEntrada entrada = new DividirPicklist.ElementoEntrada();
        entrada.multipicklistValue = 'Valor1;Valor2;Valor3';
        entrada.multipicklistOldValue = null;

        List<DividirPicklist.ElementoEntrada> entradas = new List<DividirPicklist.ElementoEntrada>{entrada};

        Test.startTest();
        List<DividirPicklist.ElementoSalida> resultados = DividirPicklist.separarValores(entradas);
        Test.stopTest();

        System.assertEquals(1, resultados.size(), 'Debe devolver una salida');
        System.assertNotEquals(null, resultados[0].valoresPicklist, 'Debe devolver lista de valores');
        System.assertEquals(3, resultados[0].valoresPicklist.size(), 'Debe dividir en 3 valores');
        System.assertEquals('Valor1', resultados[0].valoresPicklist[0]);
        System.assertEquals('Valor2', resultados[0].valoresPicklist[1]);
        System.assertEquals('Valor3', resultados[0].valoresPicklist[2]);
    }

    @isTest
    static void testSepararValoresConAntiguoYNuevo() {
        // Caso con valores nuevos y antiguos, debe devolver solo el nuevo
        DividirPicklist.ElementoEntrada entrada = new DividirPicklist.ElementoEntrada();
        entrada.multipicklistValue = 'A;B;C';
        entrada.multipicklistOldValue = 'A;B';

        List<DividirPicklist.ElementoEntrada> entradas = new List<DividirPicklist.ElementoEntrada>{entrada};

        List<DividirPicklist.ElementoSalida> resultados = DividirPicklist.separarValores(entradas);

        System.assertEquals(1, resultados.size(), 'Debe devolver una salida');
        System.assertNotEquals(null, resultados[0].valoresPicklist, 'Debe devolver lista de valores');
        System.assertEquals(1, resultados[0].valoresPicklist.size(), 'Debe devolver solo el valor nuevo');
        System.assertEquals('C', resultados[0].valoresPicklist[0]);
    }

    @isTest
    static void testSepararValoresSinDiferencias() {
        // Caso donde todos los valores ya estaban antes, debe devolver null
        DividirPicklist.ElementoEntrada entrada = new DividirPicklist.ElementoEntrada();
        entrada.multipicklistValue = 'A;B';
        entrada.multipicklistOldValue = 'A;B';

        List<DividirPicklist.ElementoEntrada> entradas = new List<DividirPicklist.ElementoEntrada>{entrada};

        List<DividirPicklist.ElementoSalida> resultados = DividirPicklist.separarValores(entradas);

        System.assertEquals(1, resultados.size(), 'Debe devolver una salida');
        System.assertEquals(null, resultados[0].valoresPicklist, 'Debe devolver null si no hay valores nuevos');
    }
}
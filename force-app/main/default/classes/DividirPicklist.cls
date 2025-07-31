public class DividirPicklist {
    
    public class ElementoEntrada {
        @InvocableVariable(required=true)
        public String multipicklistValue;
        @InvocableVariable
        public String multipicklistOldValue;
    }

    public class ElementoSalida {
        @InvocableVariable
        public List<String> valoresPicklist;
    }

    @InvocableMethod(label='Dividir Multipicklist' description='Divide un campo multipicklist en una lista de valores nuevos respecto al valor anterior')
    public static List<ElementoSalida> separarValores(List<ElementoEntrada> requests) {
        List<ElementoSalida> resultado = new List<ElementoSalida>();

        for (ElementoEntrada req : requests) {
            ElementoSalida res = new ElementoSalida();
            List<String> nuevosValores = new List<String>();

            if (String.isNotBlank(req.multipicklistValue)) {
                List<String> nuevos = req.multipicklistValue.split(';');
                if (String.isNotBlank(req.multipicklistOldValue)) {
                    Set<String> antiguos = new Set<String>(req.multipicklistOldValue.split(';'));
                    for (String v : nuevos) {
                        if (!antiguos.contains(v)) {
                            nuevosValores.add(v);
                        }
                    }
                } else {
                    nuevosValores.addAll(nuevos);
                }
            }
            res.valoresPicklist = nuevosValores.isEmpty() ? null : nuevosValores;
            resultado.add(res);
        }

        return resultado;
    }
}
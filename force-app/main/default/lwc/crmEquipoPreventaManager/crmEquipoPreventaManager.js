import { LightningElement, api, track } from 'lwc';
import loadData from '@salesforce/apex/EquipoPreventaService.loadData';
import searchEmpleados from '@salesforce/apex/EquipoPreventaService.searchEmpleados';
import saveSrv from '@salesforce/apex/EquipoPreventaService.save';
import canEditEquipo from '@salesforce/apex/EquipoPreventaService.canEditEquipo';
import verificarEmpleadoExiste from '@salesforce/apex/EquipoPreventaService.verificarEmpleadoExiste';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CrmEquipoPreventaManager extends LightningElement {
  @api recordId;
  @track rows = [];
  @track mercantilPicklist = [];
  @track isLoading = false;
  @track showSearch = false;
  @track resultados = [];
  @track selectedEmpleado = null;
  @track canEdit = true; // Controla si se puede editar
  mercantilSeleccion;
  horasSeleccion;
  filtro = { codigo:'', nombre:'', apellido1:'', apellido2:'' };

  get showResultadosList() { return this.resultados && this.resultados.length > 0 && !this.selectedEmpleado; }
  
  get columns() {
    const baseColumns = [
      { label:'Nombre y Apellidos', fieldName:'nombre', type:'text', wrapText: true, cellAttributes: { alignment: 'left' } },
      { label:'Código de Empleado', fieldName:'codigo', type:'text', cellAttributes: { alignment: 'left' } },
      { label:'Sociedad', fieldName:'mercantil', type:'text', wrapText: true, cellAttributes: { alignment: 'left' } },
      { 
        label:'Horas', 
        fieldName:'horas', 
        type:'number', 
        editable: this.canEdit, // Editable solo si se puede editar
        cellAttributes: { alignment: 'left' },
        typeAttributes: { 
          minimumFractionDigits: 0, 
          maximumFractionDigits: 2,
          step: 0.5
        }
      }
    ];
    
    // Agregar botón de eliminar solo si se puede editar
    if (this.canEdit) {
      baseColumns.push({
        type:'button-icon', 
        typeAttributes:{ 
          iconName:'utility:delete', 
          alternativeText:'Eliminar miembro', 
          name:'delete',
          variant:'border-filled',
          class:'slds-button_destructive'
        },
        fixedWidth: 60
      });
    }
    
    return baseColumns;
  }

  get mercantilOptions() { return this.mercantilPicklist.map(v => ({ label:v, value:v })); }
  get visibleRows() { return this.rows.filter(r => !r.isDeleted); }
  get disableSave() { return !this.rows.some(r => r.isNew || r.isDeleted || r.isChanged); }
  get disableSaveButton() { return this.disableSave || this.isLoading; }
  get disableAgregar() { 
    return !(this.selectedEmpleado && this.selectedEmpleado.mercantilMapeado && 
             this.horasSeleccion !== null && this.horasSeleccion !== undefined && 
             this.horasSeleccion >= 0); 
  }

  connectedCallback() { 
    this.refresh();
  }

  refresh() {
    this.isLoading = true;
    loadData({ opportunityId: this.recordId })
      .then(d => { 
        this.rows = d.existentes.map(r => ({ ...r, key: r.id })); 
        this.mercantilPicklist = d.mercantilPicklist;
        this.canEdit = d.canEdit;
      })
      .catch(e => this.showError(e))
      .finally(()=> this.isLoading = false);
  }

  openSearch = async () => { 
    // Verificar permisos antes de abrir el modal
    try {
      this.isLoading = true;
      const canEdit = await canEditEquipo({ opportunityId: this.recordId });
      if (!canEdit) {
        this.showToast('Error', 'No tiene permisos para realizar esta operación. El estado de la oportunidad puede haber cambiado.', 'error');
        return;
      }
      this.resetModal(); 
      this.showSearch = true; 
    } catch (error) {
      this.showError(error);
    } finally {
      this.isLoading = false;
    }
  };
  closeSearch = () => { this.showSearch = false; };

  resetModal() { this.resultados = []; this.selectedEmpleado = null; this.mercantilSeleccion = null; this.horasSeleccion = null; }

  handleFiltro(e) { this.filtro[e.target.dataset.field] = e.target.value; }

  limpiarFiltros = () => {
    this.filtro = { codigo:'', nombre:'', apellido1:'', apellido2:'' };
    this.resultados = [];
    this.selectedEmpleado = null;
  }

  buscar = () => {
    this.isLoading = true;
    searchEmpleados(this.filtro)
      .then(res => { this.resultados = res; })
      .catch(e => this.showError(e))
      .finally(()=> this.isLoading = false);
  }

  seleccionarEmpleado = (e) => {
    const { cod, nombre, correo, mercantil } = e.target.dataset;
    this.selectedEmpleado = { 
      codigo: cod, 
      nombreCompleto: nombre, 
      correo: correo,
      mercantilMapeado: mercantil 
    };
    // Establecer automáticamente el mercantil mapeado
    this.mercantilSeleccion = mercantil;
    this.scrollToForm();
  }

  deselectEmpleado = () => {
    this.selectedEmpleado = null;
    this.mercantilSeleccion = null;
    this.horasSeleccion = null;
  }

  handleMercantil(e) { this.mercantilSeleccion = e.detail.value; }
  handleHoras(e) { 
    const value = e.target.value;
    this.horasSeleccion = value ? parseFloat(value) : 0;
  }

  // Helper para verificar permisos antes de operaciones críticas
  async verificarPermisos() {
    try {
      const puedeEditar = await canEditEquipo({ opportunityId: this.recordId });
      if (!puedeEditar) {
        this.showToast('Error', 'No tiene permisos para realizar esta operación. El estado de la oportunidad puede haber cambiado. Recargue la página.', 'error');
        return false;
      }
      return true;
    } catch (error) {
      this.showToast('Error', 'Error verificando permisos: ' + (error.body?.message || error.message), 'error');
      return false;
    }
  }

  async agregarSeleccionadoConValidacion() {
    // Verificar permisos primero
    const puedeEditar = await this.verificarPermisos();
    if (!puedeEditar) return;

    // Verificar duplicado local primero (más rápido)
    const yaExisteLocal = this.rows.some(r => 
      !r.isDeleted && 
      r.codigo === this.selectedEmpleado.codigo
    );
    
    if (yaExisteLocal) {
      this.showToast('Aviso', 'Este empleado ya está en la lista actual del equipo de preventa.', 'warning');
      return;
    }

    // Verificar duplicado en la base de datos
    try {
      const yaExiste = await verificarEmpleadoExiste({ 
        opportunityId: this.recordId, 
        codigoEmpleado: this.selectedEmpleado.codigo 
      });
      
      if (yaExiste) {
        this.showToast('Aviso', 'Este empleado ya está registrado en el equipo de preventa.', 'warning');
        return;
      }
      
      // Continuar con la lógica normal de agregar
      this.ejecutarAgregarEmpleado();
      
    } catch (error) {
      this.showError(error);
    }
  }

  ejecutarAgregarEmpleado() {
    const nuevoRegistro = {
      id: null,
      key: 'tmp_' + Math.random(),
      nombre: this.selectedEmpleado.nombreCompleto,
      mercantil: this.selectedEmpleado.mercantilMapeado,
      horas: parseFloat(this.horasSeleccion),
      isNew: true,
      isChanged: true,
      isDeleted: false,
      codigo: this.selectedEmpleado.codigo,
      email: this.selectedEmpleado.correo
    };
    
    console.log('Agregando nuevo registro:', JSON.stringify(nuevoRegistro, null, 2));
    
    this.rows = [...this.rows, nuevoRegistro];
    
    // Listo para agregar otro sin cerrar
    this.selectedEmpleado = null;
    this.mercantilSeleccion = null;
    this.horasSeleccion = null;
    
    this.showToast('Éxito', 'Empleado agregado al equipo. Recuerde guardar los cambios.', 'success');
  }

  handleRowAction = async (e) => {
    const action = e.detail.action.name;
    const row = e.detail.row;
    
    if (action === 'delete') {
      // Verificar permisos antes de eliminar
      const puedeEditar = await this.verificarPermisos();
      if (!puedeEditar) return;
      
      if (row.id) {
        row.isDeleted = true;
        this.rows = [...this.rows];
        this.showToast('Info', 'Empleado marcado para eliminación. Recuerde guardar los cambios.', 'info');
      } else {
        this.rows = this.rows.filter(r => r.key !== row.key);
        this.showToast('Info', 'Empleado eliminado de la lista.', 'info');
      }
    }
  }

  handleCellChange = async (event) => {
    // Verificar permisos antes de permitir la edición
    const puedeEditar = await this.verificarPermisos();
    if (!puedeEditar) {
      // Limpiar los draft values para revertir el cambio
      this.template.querySelector('lightning-datatable').draftValues = [];
      return;
    }
    
    const draftValues = event.detail.draftValues;
    
    draftValues.forEach(draftValue => {
      // Encontrar el registro correspondiente
      const rowIndex = this.rows.findIndex(row => row.key === draftValue.key);
      if (rowIndex !== -1) {
        const updatedRow = { ...this.rows[rowIndex] };
        
        // Actualizar el valor de horas
        if (draftValue.horas !== undefined) {
          const newHoras = parseFloat(draftValue.horas) || 0;
          if (updatedRow.horas !== newHoras) {
            updatedRow.horas = newHoras;
            updatedRow.isChanged = true;
            console.log(`Horas actualizadas para ${updatedRow.nombre}: ${newHoras}`);
          }
        }
        
        // Actualizar el array de rows
        this.rows = [
          ...this.rows.slice(0, rowIndex),
          updatedRow,
          ...this.rows.slice(rowIndex + 1)
        ];
      }
    });
    
    // Limpiar los draft values
    this.template.querySelector('lightning-datatable').draftValues = [];
  }

  save = async () => {
    // Verificar permisos antes de guardar
    const puedeEditar = await this.verificarPermisos();
    if (!puedeEditar) return;
    
    // Filtrar solo los registros que tienen cambios
    const registrosConCambios = this.rows.filter(r => r.isNew || r.isDeleted || r.isChanged);
    
    const payload = registrosConCambios.map(r => ({
      id: r.id || null,
      nombre: r.nombre || '',
      mercantil: r.mercantil || '',
      horas: parseFloat(r.horas) || 0,
      codigo: r.codigo || '',
      isNew: Boolean(r.isNew),
      isDeleted: Boolean(r.isDeleted),
      isChanged: Boolean(r.isChanged)
    }));
    
    console.log('Payload to send:', JSON.stringify(payload, null, 2));
    
    if (payload.length === 0) {
      this.showToast('Aviso', 'No hay cambios que guardar', 'warning');
      return;
    }
    
    this.isLoading = true;
    // Convertir payload a JSON string para evitar problemas de deserialización
    const registrosJson = JSON.stringify(payload);
    console.log('Enviando JSON:', registrosJson);
    
    saveSrv({ opportunityId: this.recordId, registrosJson: registrosJson })
      .then(res => {
        this.rows = res.resultado.map(r => ({ ...r, key: r.id, isNew: false, isChanged: false, isDeleted: false }));
        this.showToast('Éxito', 'Registros guardados correctamente', 'success');
      })
      .catch(e => this.showError(e))
      .finally(()=> this.isLoading = false);
  }

  scrollToForm() {
    requestAnimationFrame(()=> {
      const form = this.template.querySelector('[data-id="formNuevoRegistro"]');
      if (form) {
        form.scrollIntoView({ behavior:'smooth', block:'start' });
      }
    });
  }

  showToast(title, message, variant) { this.dispatchEvent(new ShowToastEvent({ title, message, variant })); }
  showError(e) { let msg = 'Error'; if (e && e.body && e.body.message) msg = e.body.message; this.showToast('Error', msg, 'error'); }

  // Método para refrescar permisos específicamente (usado por botón refresh)
  refreshPermisos = async () => {
    try {
      this.isLoading = true;
      const previousCanEdit = this.canEdit;
      const currentCanEdit = await canEditEquipo({ opportunityId: this.recordId });
      
      this.canEdit = currentCanEdit;
      
    } catch (error) {
      this.showError(error);
    } finally {
      this.isLoading = false;
    }
  };
}
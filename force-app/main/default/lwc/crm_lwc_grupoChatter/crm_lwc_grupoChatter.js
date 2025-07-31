import { LightningElement, track, wire } from 'lwc';
import obtenerIdGrupo from '@salesforce/apex/GrupoChatterController.obtenerIdGrupo';

export default class Crm_lwc_grupoChatter extends LightningElement {
    
    @track groupId;

    @wire(obtenerIdGrupo, { nombreGrupo: 'Commercial Chat' })
    wiredGroupId({ error, data }) {
        if (data) {
            this.groupId = data;
        } else if (error) {
            console.error('Error al obtener el ID del grupo:', error);
        }
    }

    get groupLink() {
        return `${window.location.origin}/lightning/r/CollaborationGroup/${this.groupId}/view`;
    }
}
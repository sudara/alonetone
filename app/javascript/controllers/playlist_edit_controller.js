import { Controller } from 'stimulus'
import { Sortable } from '@shopify/draggable';

export default class extends Controller {
  static targets = ['sortable', 'dropzone', 'sourceTracks']

  initialize() {
    this.sortable = new Sortable(this.sortableTarget, {
      draggable: 'li',
    })
    this.sortable.on('sortable:sorted', () => console.log('sortable:sorted'))
  }
}
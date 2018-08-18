import { Controller } from 'stimulus'
import { Sortable } from '@shopify/draggable';

export default class extends Controller {
  static targets = ['sortable', 'dropzone', 'sourceTracks']

  initialize() {
    this.sortable = new Sortable(this.sortableTarget, {
      draggable: 'li',
    })

    // need this to fire only when order changed
    this.sortable.on('drag:stop', () => console.log('sorted'))
  }
}
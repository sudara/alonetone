import { Controller } from 'stimulus'
import { Sortable } from '@shopify/draggable';
import { Droppable } from '@shopify/draggable';

export default class extends Controller {
  static targes = ['playlist', 'dropzone', 'sourceTracks']

  initialize() {
    this.droppable = new Droppable(this.sourceTracksElement, {
      draggable: 'li',
      dropzone: this.dropzoneElement,
    });
  }
}
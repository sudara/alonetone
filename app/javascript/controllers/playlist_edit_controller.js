import Rails from 'rails-ujs'
import { Controller } from 'stimulus'
import { Sortable } from '@shopify/draggable';

export default class extends Controller {
  static targets = ['sortable', 'sortUrl', 'addUrl', 'dropzone', 'sourceTracks']

  initialize() {
    this.sortable = new Sortable(this.sortableTarget, {
      draggable: 'div.asset',
      mirror: {
        constrainDimensions: true,
        xAxis: false,
        yAxis: true,
      },
    })
    this.sortUrl = this.sortUrlTarget.getAttribute('href')
    this.currentParams = this.paramsFromSortables()
    // need this to fire only when order changed
    this.sortable.on('drag:stop', () => console.log(this.maybePostToSort()))
  }

  sortables() {
    return this.sortable.getDraggableElementsForContainer(this.sortableTarget)
  }

  // track[]=146023&track[]=146024&track[]=146025
  paramsFromSortables() {
    return Array.from(this.sortables(), x => `track[]=${x.id.replace('track_', '')}`).join('&')
  }

  maybePostToSort() {
    const newParams = this.paramsFromSortables()
    if (newParams !== this.currentParams) {
      this.currentParams = newParams
      this.sort()
    }
  }

  sort() {
    Rails.ajax({
      url: this.sortUrl,
      type: 'POST',
      data: this.currentParams,
      success: (data) {
        this.displaySuccess()
      }
    });
  }

  displaySuccess() {
    // have "Saved" plus a green check mark flash at top of playlist
  }
}
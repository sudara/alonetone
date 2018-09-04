import Rails from 'rails-ujs'
import { Controller } from 'stimulus'
import { Sortable } from '@shopify/draggable';

export default class extends Controller {
  static targets = ['sortable', 'sortUrl', 'addUrl', 'dropzone', 'sourceTracks', 'size', 'feedback', 'spinner']

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
    this.spinnerTarget.style.display = 'none'
    this.currentParams = this.paramsFromSortables()
    // need this to fire only when order changed
    this.sortable.on('drag:stop', () => this.maybePostToSort())

    // hack related to https://github.com/Shopify/draggable/issues/183
    // allows elements with certain classes to not behave as handles for draggable
    this.sortable.on('drag:start', (event) => { 
      const classListOfTarget = event.originalEvent.target.classList
      if (classListOfTarget.contains('.add', '.remove', '.play_link', '.play_button')) {
        event.cancel()
      }
    })
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
      success: this.displaySuccess.bind(this)
    })
  }

  displaySuccess() {
    this.feedbackTarget.innerHTML = '<div class="ajax_success">Saved!</div>'
  }
}
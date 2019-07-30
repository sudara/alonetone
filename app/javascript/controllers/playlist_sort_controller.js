import Rails from 'rails-ujs'
import Sortable from 'sortablejs'
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['sortable', 'sortUrl', 'addUrl', 'dropzone', 'sourceTracks',
    'feedback', 'spinner', 'size', 'trackCount', 'totalTime']

  initialize() {
    this.sortable = new Sortable(this.sortableTarget, {
      onEnd: () => this.maybePostToSort(),
    })
    this.sortUrl = this.sortUrlTarget.getAttribute('href')
    this.spinnerTarget.style.display = 'none'
    this.currentParams = this.paramsFromSortables()
  }

  // track[]=146023&track[]=146024&track[]=146025
  paramsFromSortables() {
    return `track[]=${this.sortable.toArray().join('&track[]=')}`
  }

  // only fire when order changed
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
      success: this.displaySuccess.bind(this),
    })
  }

  displaySuccess() {
    this.feedbackTarget.innerHTML = '<div class="ajax_success">Saved!</div>'
  }

  updatePlaylistSize() {
    const size = this.sortableTarget.childElementCount
    this.sizeTarget.innerHTML = `${size}`
    this.trackCountTarget.innerHTML = `${size} tracks`
  }

  calculateTime() {
    const time = Math.floor(this.position)
    const min = Math.floor(time / 60)
    const sec = time % 60
    this.time = min + ':' + (sec >= 10 ? sec : '0' + sec)
  }
}

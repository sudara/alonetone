import Sortable from 'sortablejs'
import Rails from '@rails/ujs'
import { Controller } from '@hotwired/stimulus'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['sortable', 'sortUrl', 'addUrl', 'dropzone', 'sourceTracks',
    'feedback', 'spinner', 'size', 'trackCount', 'totalTime']

  initialize() {
    this.sortable = new Sortable(this.sortableTarget, {
      handle: '.drag_handle',
      onEnd: () => this.maybePostToSort(),
    })
    this.sortUrl = this.sortUrlTarget.getAttribute('href')
    this.spinnerTarget.style.display = 'none'
    this.currentParams = this.paramsFromSortables()
    this.playlistForm = this.application.getControllerForElementAndIdentifier(document.querySelector('#edit_playlist_info'), 'playlist-form')
    this.playlistForm.updateCount(this.numberOfTracks)
  }

  get numberOfTracks() {
    return this.sortableTarget.childElementCount
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

  updatePlaylistMetadata() {
    const size = this.numberOfTracks
    this.sizeTarget.innerHTML = `${size}`
    this.trackCountTarget.innerHTML = `${size} tracks`
    this.totalTimeTarget.innerHTML = this.calculateTime()
    this.playlistForm.updateCount(size)
  }

  calculateTime() {
    const tracks = Array.from(this.sortableTarget.children)
    const sum = tracks.reduce((acc, el) => acc + Number(el.dataset.time), 0)
    const min = Math.floor(sum / 60)
    const sec = sum % 60
    return `${min}:${sec >= 10 ? sec : '0' + sec}`
  }

  displaySuccess() {
    flashController.alertSaved()
  }
}

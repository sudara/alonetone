import Rails from 'rails-ujs'
import { Controller } from 'stimulus'
import PlaylistSortController from './playlist_sort_controller'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['add', 'remove']

  initialize() {
    this.addUrl = document.querySelector('.add_url').getAttribute('href')
    this.removeUrl = document.querySelector('.remove_url').getAttribute('href')
  }

  setPlaylistSort() {
    this.playlistSort = this.application.getControllerForElementAndIdentifier(document.querySelector('#columns'), 'playlist-sort')
  }

  add(e) {
    e.preventDefault()
    this.setPlaylistSort()
    Rails.ajax({
      url: this.addUrl,
      type: 'POST',
      data: `asset_id=${this.element.id}`,
      before: this.spin.bind(this),
      success: (response, status, xhr) => this.added(response, status, xhr),
      error: this.errored.bind(this),
    })
  }

  remove(e) {
    e.preventDefault()
    this.setPlaylistSort()
    Rails.ajax({
      url: this.removeUrl,
      type: 'GET',
      data: `track_id=${this.element.getAttribute('data-id')}`,
      before: this.spin.bind(this),
      success: this.removed.bind(this),
      error: this.errored.bind(this),
    })
  }

  spin() {
    this.playlistSort.spinnerTarget.style.display = 'block'
  }

  stopSpin() {
    this.playlistSort.spinnerTarget.style.display = 'none'
  }

  errored() {
    setTimeout(this.stopSpin.bind(this), 500)
    flashController.alertFailed()
  }

  removed() {
    setTimeout(this.stopSpin.bind(this), 500)
    flashController.alertSaved('Removed')
    this.element.parentNode.removeChild(this.element)
    this.updatePlaylistMetadata()
  }

  added(response, status, xhr) {
    setTimeout(this.stopSpin.bind(this), 500)
    flashController.alertSaved('Added!')
    const clonedTrack = this.element.cloneNode(true)
    clonedTrack.setAttribute('data-id', `${response}`) // give it a track id before assigning it to the sortable
    this.playlistSort.sortableTarget.appendChild(clonedTrack)
    this.updatePlaylistMetadata()
  }

  updatePlaylistMetadata() {
    this.playlistSort.updatePlaylistMetadata()
  }
}
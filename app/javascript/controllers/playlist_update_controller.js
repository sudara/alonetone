import Rails from 'rails-ujs'
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['add', 'remove']

  initialize() {
    this.addUrl = document.querySelector('.add_url').getAttribute('href')
    this.removeUrl = document.querySelector('.remove_url').getAttribute('href')
  }

  setPlaylistEdit() {
    this.playlistEdit = this.application.getControllerForElementAndIdentifier(document.querySelector('#columns'), 'playlist-edit')
  }

  add(e) {
    e.preventDefault()
    this.setPlaylistEdit()
    Rails.ajax({
      url: this.addUrl,
      type: 'POST',
      data: `asset_id=${this.element.id}`,
      before: this.spin.bind(this),
      success: this.added.bind(this),
      error: this.errored.bind(this),
    })
  }

  remove(e) {
    e.preventDefault()
    this.setPlaylistEdit()
    Rails.ajax({
      url: this.removeUrl,
      type: 'GET',
      data: `track_id=${this.element.id.replace('track_', '')}`,
      before: this.spin.bind(this),
      success: this.removed.bind(this),
      error: this.errored.bind(this),
    })
  }

  spin() {
    this.playlistEdit.spinnerTarget.style.display = 'block'
  }

  stopSpin() {
    this.playlistEdit.spinnerTarget.style.display = 'none'
  }

  errored() {
    setTimeout(this.stopSpin, 300)
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_fail">Dang, something went wrong!</div>'
  }

  removed() {
    setTimeout(this.stopSpin, 3000)
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_success">Removed</div>'
    this.updatePlaylistSize()
    this.element.parentNode.removeChild(this.element)
  }

  added() {
    setTimeout(this.stopSpin, 300)
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_success">Added!</div>'
    this.playlistEdit.sortableTarget.appendChild(this.element)
    this.updatePlaylistSize()
  }

  updatePlaylistSize() {
    const size = this.playlistEdit.sortables().length
    this.playlistEdit.sizeTarget.innerHTML = `${size}`
  }
}
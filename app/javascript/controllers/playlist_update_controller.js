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
      success: (response, status, xhr) => this.added(response, status, xhr),
      error: this.errored.bind(this),
    })
  }

  remove(e) {
    e.preventDefault()
    this.setPlaylistEdit()
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
    this.playlistEdit.spinnerTarget.style.display = 'block'
  }

  stopSpin() {
    this.playlistEdit.spinnerTarget.style.display = 'none'
  }

  errored() {
    setTimeout(this.stopSpin.bind(this), 500)
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_fail">Dang, something went wrong!</div>'
  }

  removed() {
    setTimeout(this.stopSpin.bind(this), 500)
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_success">Removed</div>'
    this.updatePlaylistSize()
    this.element.parentNode.removeChild(this.element)
  }

  added(response, status, xhr) {
    setTimeout(this.stopSpin.bind(this), 500)
    this.element.setAttribute('data-id', `${response}`) // give it a track id before assigning it to the sortable
    this.addTarget.style.display = 'none'
    this.removeTarget.style.display = 'flex'
    this.playlistEdit.feedbackTarget.innerHTML = '<div class="ajax_success">Added!</div>'
    this.playlistEdit.sortableTarget.appendChild(this.element)
    this.updatePlaylistSize()
  }

  updatePlaylistSize() {
    const size = this.playlistEdit.sortable.toArray.length
    this.playlistEdit.sizeTarget.innerHTML = `${size}`
  }
}
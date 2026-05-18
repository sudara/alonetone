import { Controller } from '@hotwired/stimulus'
import PlaylistSortController from './playlist_sort_controller'
import { flashController } from './flash_controller'
import csrfFetch from '../misc/csrf_fetch'

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
    this.spin()
    csrfFetch(this.addUrl, {
      method: 'POST',
      body: new URLSearchParams({ asset_id: this.element.id }),
    })
      .then((r) => {
        if (!r.ok) throw new Error('add failed')
        return r.text()
      })
      .then((text) => this.added(text))
      .catch(() => this.errored())
  }

  remove(e) {
    e.preventDefault()
    this.setPlaylistSort()
    this.spin()
    const url = `${this.removeUrl}?track_id=${encodeURIComponent(this.element.getAttribute('data-id'))}`
    csrfFetch(url, { method: 'GET' })
      .then((r) => {
        if (!r.ok) throw new Error('remove failed')
        this.removed()
      })
      .catch(() => this.errored())
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

  added(response) {
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

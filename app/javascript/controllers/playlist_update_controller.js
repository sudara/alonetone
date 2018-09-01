import Rails from 'rails-ujs'
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['add', 'remove']

  initialize() {
    this.addUrl = document.querySelector('.add_url').getAttribute('href')
    this.removeUrl = document.querySelector('.remove_url').getAttribute('href')
  }

  add(e) {
    e.preventDefault()
    Rails.ajax({
      url: this.addUrl,
      type: 'POST',
      data: `asset_id=${this.element.id}`,
      // success (data) {
      //   this.displaySuccess()
      // }
    })
    alert('add')
  }

  remove(e) {
    e.preventDefault()
    Rails.ajax({
      url: this.removeUrl,
      type: 'GET',
      data: `track_id=${this.element.id.replace('track_','')}`,
      success (data) {
        this.element.remove()
      }
    })
    alert('removed')
  }
}
import { Controller } from "@hotwired/stimulus"
import { flashController } from './flash_controller'
import csrfFetch from '../misc/csrf_fetch'

export default class extends Controller {
  static targets = ['description', 'toggle']

  initialize() {
    this.href = this.toggleTarget.href
    this.description = this.descriptionTarget.innerText
  }

  toggle(e) {
    this.toggleTarget.classList.toggle('on')
    e.preventDefault()
    e.stopImmediatePropagation()
    csrfFetch(this.href, {
      method: 'PUT',
      body: new URLSearchParams({ setting: this.data.get('key') }),
    })
      .then((r) => {
        if (!r.ok) throw new Error('toggle_setting failed')
        flashController.alertSaved('Setting saved.')
      })
      .catch(() => {
        flashController.alertFailed("That didn't work...Try again?")
        this.toggleTarget.classList.toggle('on')
      })
  }
}

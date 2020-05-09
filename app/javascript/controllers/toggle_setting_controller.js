import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['description', 'toggle']

  initialize() {
    this.href = this.toggleTarget.href
    this.description = this.descriptionTarget.innerText
    console.log(this.toggleTarget)
  }

  toggle(e) {
    this.toggleTarget.classList.toggle('on')
    e.preventDefault()
    e.stopImmediatePropagation()
    Rails.ajax({
      url: this.href,
      data: `setting=${this.data.get('key')}`,
      type: 'PUT',
      success: () => { flashController.alertSaved(`Setting saved.`) },
      error: () => {
        flashController.alertFailed("That didn't work...Try again?")
        this.toggleTarget.classList.toggle('on')
      },
    })
  }
}

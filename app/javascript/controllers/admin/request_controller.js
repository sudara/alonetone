import { Controller } from "@hotwired/stimulus"
import { flashController } from '../flash_controller'

export default class extends Controller {
  static targets = ['approveButton', 'denyButton']

  approveSubmitted(event) {
    if (!event.detail.success) return this.error()
    this.element.classList.add('approved')
    flashController.alertSaved('Email sent!')
  }

  denySubmitted(event) {
    if (!event.detail.success) return this.error()
    this.element.classList.add('denied')
  }

  moderated() {
    this.element.classList.remove('waiting')
    this.element.classList.add('moderated')
  }

  error() {
    flashController.alertFailed('Something went wrong')
  }
}

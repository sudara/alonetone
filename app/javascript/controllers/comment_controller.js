import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['banner', 'div', 'response', 'spinner', 'personalization']

  initialize() {
    this.personalizationTarget.innerHTML = window.userPersonalization
  }

  spin() {
    this.spinnerTarget.style.display = 'block'
  }

  complete() {
    this.spinnerTarget.style.display = 'none'
  }

  success() {
    this.textareaTarget.value = ''
    this.responseTarget.innerHTML = '<div class="ajax_success">Submitted, thanks!</div>'
  }

  error() {
    this.responseTarget.innerHTML = '<div class="ajax_fail">Sorry, that didn\'t work</div>'
  }

  toggle() {
    this.bannerTarget.classList.toggle('hidden')
    this.divTarget.classList.toggle('private_banner_visible')
  }
}

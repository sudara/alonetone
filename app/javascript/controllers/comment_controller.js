import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['banner', 'div', 'response', 'spinner', 'personalization', 'textarea']

  initialize() {
    this.personalizationTarget.innerHTML = window.userPersonalization
  }

  spin() {
    this.spinnerTarget.style.display = 'block'
  }

  success() {
    this.textareaTarget.value = ''
    this.responseTarget.innerHTML = '<div class="ajax_success"><span>Submitted, thanks!</span></div>'
    this.responseTarget.classList.toggle('comment_success')

    this.spinnerTarget.style.display = 'none'

  }

  error() {
    this.responseTarget.innerHTML = '<div class="ajax_fail"><span>Sorry, that didn\'t work</span></div>'
    this.responseTarget.classList.toggle('comment_fail')
    this.spinnerTarget.style.display = 'none'
  }

  toggle() {
    this.bannerTarget.classList.toggle('hidden')
    this.divTarget.classList.toggle('private_banner_visible')
  }
}

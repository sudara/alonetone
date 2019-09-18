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
    this.responseTarget.innerHTML = '<div><span>Submitted, thanks!</span></div>'
    this.responseTarget.classList.add('ajax_success')
    this.responseTarget.classList.remove('ajax_fail')
    this.spinnerTarget.style.display = 'none'
  }

  error() {
    this.responseTarget.innerHTML = '<div><span>That didn\'t work!</span></div>'
    this.responseTarget.classList.add('ajax_fail')
    this.responseTarget.classList.remove('ajax_success')
    this.spinnerTarget.style.display = 'none'
  }

  toggle() {
   this.bannerTarget.classList.toggle('hidden')
   this.divTarget.classList.toggle('private_banner_visible')
  }
}

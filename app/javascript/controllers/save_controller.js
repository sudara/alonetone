import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['response', 'spinner']

  spin() {
    this.spinnerTarget.style.display = 'block'
  }

  success() {
    this.responseTarget.innerHTML = '<div class="ajax_success"><span>Saved!</span></div>'
    this.responseTarget.classList.toggle('save_success')
    this.spinnerTarget.style.display = 'none'
  }

  error() {
    this.responseTarget.innerHTML = '<div class="ajax_fail"><span>Sorry, that didn\'t work</span></div>'
    this.responseTarget.classList.toggle('save_fail')
    this.spinnerTarget.style.display = 'none'
  }

}

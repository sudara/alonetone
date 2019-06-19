import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['response', 'spinner']

  spin() {
    this.spinnerTarget.style.display = 'block'
  }

  success() {
    this.responseTarget.innerHTML = '<div><span>Saved!</span></div>'
    this.responseTarget.classList.toggle('ajax_success')
    this.spinnerTarget.style.display = 'none'
  }

  error() {
    this.responseTarget.innerHTML = '<div><span>Sorry, that didn\'t work</span></div>'
    this.responseTarget.classList.toggle('ajax_fail')
    this.spinnerTarget.style.display = 'none'
  }

}

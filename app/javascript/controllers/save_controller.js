import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['response', 'spinner']

  spin() {
    this.responseTarget.classList.remove('ajax_success', 'ajax_fail')
    this.responseTarget.innerHTML = ''
    this.spinnerTarget.style.display = 'block'
  }

  success() {
    this.responseTarget.innerHTML = '<div><span>Saved!</span></div>'
    this.responseTarget.classList.add('ajax_success')
    this.spinnerTarget.style.display = 'none'
  }

  error() {
    this.responseTarget.innerHTML = '<div><span>Sorry, that didn\'t work</span></div>'
    this.responseTarget.classList.add('ajax_fail')
    this.spinnerTarget.style.display = 'none'
  }

}

import { Controller } from "@hotwired/stimulus"
import { gsap } from 'gsap'

export default class extends Controller {
  static targets = ['response', 'spinner']

  spin() {
    this.responseTarget.classList.remove('ajax_success', 'ajax_fail')
    this.responseTarget.innerHTML = ''
    this.spinnerTarget.style.display = 'block'
    gsap.to(this.spinnerTarget, 0, { autoAlpha: 1 })
    gsap.to(this.responseTarget, 0, { autoAlpha: 1 })
  }

  complete() {
    gsap.to(this.spinnerTarget, .25, { autoAlpha: 0 }).delay(.25)
    gsap.to(this.responseTarget, 1, { autoAlpha: 0 }).delay(4)
  }

  success() {
    this.responseTarget.innerHTML = '<div><span>Saved!</span></div>'
    this.responseTarget.classList.add('ajax_success')
  }

  error() {
    this.responseTarget.innerHTML = '<div><span>Sorry, that didn\'t work</span></div>'
    this.responseTarget.classList.add('ajax_fail')
  }
}

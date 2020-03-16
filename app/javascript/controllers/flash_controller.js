import { Controller } from 'stimulus'
import { gsap } from 'gsap'

export let flashController

export default class extends Controller {
  static targets = ['message']

  initialize() {
    flashController = this
  }

  alert(message) {
    this.element.innerHTML = message
    gsap.timeline({})
      .to(this.element, { autoAlpha: 0, y: 50 })
      .to(this.element, { duration: 0.5, autoAlpha: 1, y: 0 })
      .to(this.element, { duration: 1.0, autoAlpha: 0, y: 0 }, 3)
  }

  alertSaved(message = 'Saved!') {
    this.element.classList.add('ajax_success')
    this.element.classList.remove('ajax_fail')
    this.alert(`<div><span>${message}</span></div>`)
  }

  alertFailed(message = "Sorry that didn't work") {
    this.element.classList.add('ajax_fail')
    this.element.classList.remove('ajax_success')
    this.alert(`<div><span>${message}</span></div>`)
  }
}

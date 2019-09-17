import { Controller } from 'stimulus'
import { TimelineMax, TweenLite, Elastic, Power4, CSSPlugin } from 'gsap/all'

export let flashController

export default class extends Controller {
  static targets = ['message']

  initialize() {
    flashController = this
  }

  alert(message) {
    this.element.innerHTML = message
    new TimelineMax({})
      .to(this.element, 0, { autoAlpha: 0, y: 50 })
      .to(this.element, 0.5, { autoAlpha: 1, y: 0 })
      .to(this.element, 1, { autoAlpha: 0, y: 0 }, 3)
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

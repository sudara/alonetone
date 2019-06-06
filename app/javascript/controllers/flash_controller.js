import { Controller } from 'stimulus'
import { TimelineMax, TweenLite, Elastic, Power4, CSSPlugin } from 'gsap/all'

export default class extends Controller {
  static targets = ['message']

  initialize() {
    // check for rails static flash
  }

  disconnect() {
  }

  alert(message) {
    this.element.innerHTML = message
    new TimelineMax({})
      .to(this.element, 0, { autoAlpha: 0, y: 50 })
      .to(this.element, .5, { autoAlpha: 1, y: 0 })
      .to(this.element, 1, { autoAlpha: 0, y: 0 }, 3)
  }

}
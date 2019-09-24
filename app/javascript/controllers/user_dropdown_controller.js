import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['menu']

  initialize() {
    this.menuTarget.style.top = '-310px'
  }

  slideOpen() {
    this.menuTarget.style.top = '0px'
  }

  slideClosed() {
    this.menuTarget.style.top = '-310px'
  }

  touch(event) {
    if (this.menuTarget.style.top !== '0px') {
      event.preventDefault()
      this.slideOpen()
    }
  }

}

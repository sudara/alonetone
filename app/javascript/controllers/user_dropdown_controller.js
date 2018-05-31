import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['menu']

  slideOpen() {
    this.menuTarget.style.top = '0px'
  }

  slideClosed() {
    this.menuTarget.style.top = '-118px'
  }

  touch(event) {
    if (this.menuTarget.style.top !== '0px') {
      event.preventDefault()
      this.slideOpen()
    }
  }
}

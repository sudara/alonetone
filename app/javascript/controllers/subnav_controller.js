import { Controller } from 'stimulus'

export default class extends Controller {

  connect() {
    this.timer = null
    this.actuallyResize()
  }

  // debounce the window.onresize events
  resize() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.actuallyResize()
    }, 50)
  }

  actuallyResize() {
    console.log(this.element)
    console.log('resizing')
  }
}
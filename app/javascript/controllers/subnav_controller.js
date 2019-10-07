import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['item']

  connect() {
    this.timer = null
    this.marginWidth = 6
    this.headerPadding = 72
    this.twoColumnCutoff = 520
    this.subNavItemsTotalWidth = this.itemTargets.reduce((total, item) => {
      console.log(item.offsetWidth)
      return total + item.offsetWidth + this.marginWidth
    }, -this.marginWidth) // we want n-1 margins
    console.log(`subNavItemsTotalWidth is ${this.subNavItemsTotalWidth}`)
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
    const availableWidth = window.innerWidth - this.headerPadding
    console.log(`resizing, padding: ${this.headerPadding} available width: ${availableWidth} subNavItemsTotalWidth: ${this.subNavItemsTotalWidth}`)

    if (availableWidth < this.twoColumnCutoff) { // 2 col
      this.element.classList.add('two-column')
      this.element.classList.remove('three-column')
    } else if (availableWidth < this.subNavItemsTotalWidth) { // 3 col
      this.element.classList.add('three-column')
      this.element.classList.remove('two-column')
    } else { // 1 col
      this.element.classList.remove('two-column')
      this.element.classList.remove('three-column')
    }
  }
}

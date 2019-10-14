import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['item']

  connect() {
    this.timer = null
    this.marginWidth = 12
    this.headerPadding = 72
    this.twoColumnCutoff = 520
    this.subNavItemsTotalWidth = this.itemTargets.reduce((total, item) => {
      return total + item.offsetWidth + this.marginWidth
    }, -this.marginWidth) // we want n-1 margins
    this.resize()
  }

  resize() {
    const availableWidth = window.innerWidth - this.headerPadding

    if (availableWidth < this.twoColumnCutoff) { // 2 col
      this.element.classList.add('two-column')
      this.element.classList.remove('three-column')
    } else if (availableWidth < this.subNavItemsTotalWidth) { // 3 col
      this.element.classList.add('three-column')
      this.element.classList.remove('two-column')
    } else { // 1 col
      this.element.classList.add('one-column')
      this.element.classList.remove('two-column')
      this.element.classList.remove('three-column')
    }
  }
}

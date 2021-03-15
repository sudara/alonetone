import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spacer', 'floater', 'container']

  initialize() {
    this.resize()
  }

  resize() {
    this.spacerTarget.style.height = 0;
    const lastContentNode = this.containerTarget.children[this.containerTarget.children.length - 3]
    let h = Math.max(0, this.containerTarget.clientHeight - this.floaterTarget.clientHeight)
    this.spacerTarget.style.height = `${h}px`
    while (h > 0 && this.floaterTarget.getBoundingClientRect().bottom > lastContentNode.getBoundingClientRect().bottom) {
      h -= 1
      this.spacerTarget.style.height = `${h}px`
    }
  }
}

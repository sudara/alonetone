import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['deleteButton', 'restoreButton', 'unspamButton']

  initialize() {
    if (this.data.get('deleted') === 'true') {
      this.showRestoreButton()
    } else {
      this.showDeleteButton()
    }
    console.log(this.data.get('spam'))
    if (this.data.get('spam') == 'false') {
      this.hideUnspamButtonTarget()
    }
  }

  showUnspamButtonTarget() {
    this.unspamButtonTarget.style.display = "block"
  }

  hideUnspamButtonTarget() {
    this.unspamButtonTarget.style.display = "none"
  }

  showDeleteButton() {
    this.data.set('deleted', 'false')
    this.element.classList.remove('deleted')
    this.restoreButtonTarget.style.display = 'none'
    this.deleteButtonTarget.style.display = 'block'
  }

  showRestoreButton() {
    this.data.set('deleted', 'true')
    this.element.classList.add('deleted')
    this.restoreButtonTarget.style.display = 'block'
    this.deleteButtonTarget.style.display = 'none'
  }
}

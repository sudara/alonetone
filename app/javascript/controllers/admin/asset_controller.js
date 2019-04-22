import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spamButton', 'unspamButton', 'deleteUserButton']

  initialize() {
    this.showDeleteUserButton()

    if (this.data.get('spam') === 'false') {
      this.showSpamButton()
    } else {
      this.showUnspamButton()
    }
  }

  showSpamButton() {
    this.data.set('spam', 'false')
    this.element.classList.remove('spam')
    this.spamButtonTarget.style.display = 'block'
    this.unspamButtonTarget.style.display = 'none'
  }

  showDeleteUserButton() {
    this.deleteUserButtonTarget.style.display = 'block'
  }

  showUnspamButton() {
    this.data.set('spam', 'true')
    this.element.classList.add('spam')
    this.unspamButtonTarget.style.display = 'block'
    this.spamButtonTarget.style.display = 'none'
  }
}

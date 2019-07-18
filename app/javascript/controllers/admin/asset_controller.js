import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spamButton', 'deleteButton']

  initialize() {
    if (this.data.get('deleted') == "true" ) {
      this.hideDeleteButtonAndSpamButton()
    } else if (this.data.get('spam') == "true") {
      this.hideSpamButton()
      this.showDeleteButton()
    } else {
      this.showSpamButton()
      this.showDeleteButton()
    }
  }

  showSpamButton() {
    this.spamButtonTarget.style.display = 'block'
  }

  hideSpamButton(){
    this.element.classList.add('spam')
    this.spamButtonTarget.style.display = 'none'
  }

  showDeleteButton() {
    this.data.set('deleted', 'false')
    this.deleteButtonTarget.style.display = 'block'
  }

  hideDeleteButtonAndSpamButton() {
    this.data.set('deleted', 'true')
    this.element.classList.remove('spam')
    this.element.classList.add('deleted')
    this.deleteButtonTarget.style.display = 'none'
    this.spamButtonTarget.style.display = 'none'
  }
}

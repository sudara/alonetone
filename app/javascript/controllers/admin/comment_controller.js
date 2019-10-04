import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spamButton', 'restoreButton']

  initialize() {
    this.hideAllButtons()

    if (this.data.get('spam') == "true") {
      this.showRestoreButton()
      this.setSpamRecord()
    } else {
      this.showSpamButton()
      this.setRestoredRecord()
    }
  }

  hideAllButtons() {
    this.hideSpamButton()
    this.hideRestoreButton()
  }

  hideSpamButton() {
    this.spamButtonTarget.style.display = 'none'
  }

  markAsSpam() {
    this.hideSpamButton()
    this.showRestoreButton()
    this.setSpamRecord()
  }

  setSpamRecord() {
    this.element.classList.add('deleted')
    this.data.set('spam', 'true')
  }

  markAsRestored() {
    this.hideRestoreButton()
    this.showSpamButton()
    this.setRestoredRecord()
  }

  setRestoredRecord() {
    this.element.classList.remove('deleted')
    this.data.set('spam', 'false')
  }
  showSpamButton() {
    this.spamButtonTarget.style.display = 'block'
  }

  hideRestoreButton() {
    this.restoreButtonTarget.style.display = 'none'
  }

  showRestoreButton() {
    this.restoreButtonTarget.style.display = 'block'
  }
}

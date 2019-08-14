import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spamButton', 'deleteButton', 'restoreButton']

  initialize() {
    if (this.data.get('deleted') == "true" ) {
      this.hideDeleteButton()
      this.showRestoreButton()
      this.hideSpamButton()
    } else if (this.data.get('spam') == "true") {
      this.markTrackAsSpam()
      this.hideRestoreButton()
      this.showDeleteButton()
    } else {
      this.showSpamButton()
      this.hideRestoreButton()
      this.showDeleteButton()
    }
  }

  // SPAM TRACK
  markTrackAsSpam() {
    this.setSpamRecord()
    this.hideSpamButton()
  }

  setSpamRecord() {
    this.data.set('spam', 'true')
    this.element.classList.add('spam')
  }

  hideSpamButton(){
    this.spamButtonTarget.style.display = 'none'
  }

  // RESTORE TRACK
  markTrackAsRestored() {
    this.hideRestoreButton()
    this.showDeleteButton()
    this.showSpamButton()
  }

  hideRestoreButton() {
    this.restoreButtonTarget.style.display = 'none'
  }

  showSpamButton() {
    setUnspamRecord()
    this.spamButtonTarget.style.display = 'block'
  }

  setUnspamRecord() {
    this.data.set('spam', 'false')
    this.element.classList.remove('spam')
  }

  showDeleteButton() {
    this.data.set('deleted', 'false')
    this.element.classList.remove('deleted')
    this.deleteButtonTarget.style.display = 'block'
  }

  // DELETE TRACK
  markTrackAsDeleted() {
    this.hideDeleteButton()
    this.hideSpamButton()
    this.showRestoreButton()
  }

  hideDeleteButton() {
    this.data.set('deleted', 'true')
    this.element.classList.add('deleted')
    this.deleteButtonTarget.style.display = 'none'
  }

  showRestoreButton() {
    this.restoreButtonTarget.style.display = 'block'
  }
}

import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spamButton', 'deleteButton', 'restoreButton']

  initialize() {
    this.hideAllButtons()

    if (this.data.get('deleted') == "true" ) {
      this.showRestoreButton()
    } else if (this.data.get('deleted') == 'false') {
      this.showSpamButton()
      this.showDeleteButton()
    }
  }

  hideAllButtons() {
    this.hideSpamButton()
    this.hideDeleteButton()
    this.hideRestoreButton()
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
    this.spamButtonTarget.style.display = 'block'
  }

  showDeleteButton() {
    this.data.set('deleted', 'false')
    this.element.classList.remove('deleted')
    this.deleteButtonTarget.style.display = 'block'
  }

  // DELETE TRACK
  markTrackAsDeleted() {
    this.setDeleteRecord()
    this.hideDeleteButton()
    this.hideSpamButton()
    this.showRestoreButton()
  }

  setDeleteRecord() {
    this.data.set('deleted', 'true')
    this.element.classList.add('deleted')
  }

  hideDeleteButton() {
    this.deleteButtonTarget.style.display = 'none'
  }

  showRestoreButton() {
    this.element.classList.add('deleted')
    this.restoreButtonTarget.style.display = 'block'
  }
}

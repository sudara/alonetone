// spam cannot restore
// Deleted user can only be restored
// Spammed user can be deleted, or unspammed
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['deleteButton', 'restoreButton', 'unspamButton', 'spamButton']

  initialize() {
    this.hideAllButtons()

    if (this.data.get('deleted') === 'true') {
      this.showRestoreButton()
    } else if (this.data.get('spam') == 'false') {
      this.showSpamButton()
      this.showDeleteButton()
    } else if (this.data.get('spam') == 'true') {
      this.showUnspamButton()
      this.showDeleteButton()
    }
  }

  //////////////////////////////////
  // GROUP button logic
  //////////////////////////////////
  hideAllButtons() {
    this.hideSpamButton()
    this.hideUnspamButton()
    this.hideDeleteButton()
    this.hideRestoreButton()
  }

  hideSpamAndShowRestoreButton() {
    this.hideSpamButton()
    this.showRestoreButton()
  }

  showDeleteAndSpamButton() {
    this.showDeleteButton()
    this.showSpamButton()
  }
  //////////////////////////////////
  // UNSPAM button
  //////////////////////////////////
  hideUnspamButton() {
    this.unspamButtonTarget.style.display = "none"
  }

  showUnspamButton() {
    this.unspamButtonTarget.style.display = "block"
  }
  //////////////////////////////////
  // SPAM button
  //////////////////////////////////
  hideSpamButton() {
    this.spamButtonTarget.style.display = "none"
  }

  showSpamButton() {
    this.data.set('spam', 'false')
    this.spamButtonTarget.style.display = "block"
  }
  //////////////////////////////////
  // DELETE button
  //////////////////////////////////
  hideDeleteButton() {
    this.deleteButtonTarget.style.display = 'none'
  }

  showDeleteButton() {
    this.data.set('deleted', 'false')
    this.element.classList.remove('deleted')
    this.restoreButtonTarget.style.display = 'none'
    this.deleteButtonTarget.style.display = 'block'
  }
  //////////////////////////////////
  // RESTORE button
  //////////////////////////////////
  hideRestoreButton() {
    this.restoreButtonTarget.style.display = 'none'
  }

  showRestoreButton() {
    this.data.set('deleted', 'true')
    this.element.classList.add('deleted')
    this.restoreButtonTarget.style.display = 'block'
    this.deleteButtonTarget.style.display = 'none'
  }
}

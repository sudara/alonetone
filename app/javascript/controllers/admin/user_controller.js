import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['deletedbutton', 'restorebutton', 'deletedvalue']

  initialize() {
    if (this.deletedvalueTarget.innerHTML == "true") {
      this.showRestoreButtonTarget()
    } else {
      this.showDeleteButtonTarget()
    }
  }

  showDeleteButtonTarget() {
    this.restorebuttonTarget.style.display = 'none'
    this.deletedbuttonTarget.style.display = 'block'
    this.deletedvalueTarget.parentNode.style.color = "black"
  }

  showRestoreButtonTarget(){
    this.restorebuttonTarget.style.display = 'block'
    this.deletedbuttonTarget.style.display = 'none'
    this.deletedvalueTarget.parentNode.style.color = "red"
  }
}

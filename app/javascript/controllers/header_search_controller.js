import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['form', 'query', 'button', 'reveal']

  submitForm(event) {
    event.preventDefault();
    if (this.queryTarget.value != "") {
      this.formTarget.submit()
    }
  }

  submitFormOnEnter(event) {
    if (event.keyCode == 13){
      this.submitForm(event)
    }
  }

  revealQuery(event) {

    event.preventDefault()
    this.queryTarget.style.display = 'block'
    this.buttonTarget.style.display = 'block'
    this.revealTarget.style.display = 'none'
  }

}
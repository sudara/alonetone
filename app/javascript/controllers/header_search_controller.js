import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'query', 'button', 'reveal']
  
  submitForm() {
    this.formTarget.submit()
  }

  revealQuery(event) {

    event.preventDefault()
    this.queryTarget.style.display = 'block'
    this.buttonTarget.style.display = 'block'
    this.revealTarget.style.display = 'none'
  }

}
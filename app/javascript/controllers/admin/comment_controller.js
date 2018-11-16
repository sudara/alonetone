import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['spam', 'unspam', 'spamvalue']

  initialize() {
    console.log(this.spamvalueTarget.innerHTML == "true")
    if (this.spamvalueTarget.innerHTML == "true") {
      this.unspamTarget.style.display = 'block'
      this.spamTarget.style.display = 'none'
    } else {
      this.unspamTarget.style.display = 'none'
      this.spamTarget.style.display = 'block'
    }
  }

  connect() {
    // console.log("Hello, Stimulus!", this.element)
  }

  spam() {
    // this.spamvalueTarget
    this.unspamTarget.style.display = 'block'
    this.spamTarget.style.display = 'none'
  }

  unspam() {
    // this.spamvalueTarget
    this.unspamTarget.style.display = 'none'
    this.spamTarget.style.display = 'block'
  }
}

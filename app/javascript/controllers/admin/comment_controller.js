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

  toggleDisplay(spam_true) {
    if (spam_true) {
      showSpamTarget()
    } else {
      showUnspamTarget()
    }
  }

  showSpamTarget() {
    this.unspamTarget.style.display = 'block'
    this.spamTarget.style.display = 'none'
  }

  showUnspamTarget(){
    this.unspamTarget.style.display = 'none'
    this.spamTarget.style.display = 'block'
  }
}

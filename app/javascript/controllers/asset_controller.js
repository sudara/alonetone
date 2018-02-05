import { Controller } from "stimulus"

export default class extends Controller {
  // data-asset-playing="0" data-asset-opened="0">
  static targets = ["play", "opened", "title"]
  
  toggle(e){
    e.preventDefault()
    this.element.classList.toggle('open')
  }
}

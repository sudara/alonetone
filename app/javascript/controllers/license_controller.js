import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  expand() {
    this.element.classList.add('expanded')
    this.element.classList.remove('collapsed')
  }
}

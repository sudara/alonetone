// admin/comments_controller.js
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['banner', 'div', 'response', 'spinner', 'personalization', 'textarea']

  initialize() {
    // this.personalizationTarget.innerHTML = window.userPersonalization
  }

}

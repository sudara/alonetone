import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['banner', 'div', 'personalization']

  initialize() {
    this.personalizationTarget.innerHTML = window.userPersonalization
  }

  spin() {
    alert("spin")
  }

  toggle() {
    this.bannerTarget.classList.toggle('hidden')
    this.divTarget.classList.toggle('private_banner_visible')
  }
}
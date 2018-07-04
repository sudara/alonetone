import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['banner', 'personalization']

  initialize() {
    this.personalizationTarget.innerHTML = window.userPersonalization
  }

  spin() {
    alert("spin")
  }

  toggle() {
    this.bannerTarget.classList.toggle('hidden')
  }
}
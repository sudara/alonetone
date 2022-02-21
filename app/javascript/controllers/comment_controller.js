import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['banner', 'div', 'response', 'spinner',
    'personalization', 'textarea', 'markAsPrivate', 'actualCheckbox']

  initialize() {
    this.personalizationTarget.innerHTML = window.userPersonalization
  }

  startSpinner() {
    this.spinnerTarget.style.display = 'block'
  }

  displayResult(e) {
    if (e.detail.formSubmission.result.success) this.success();
    else this.error();
  }

  success() {
    this.textareaTarget.value = ''
    this.responseTarget.innerHTML = '<div><span>Submitted, thanks!</span></div>'
    this.responseTarget.classList.add('ajax_success')
    this.responseTarget.classList.remove('ajax_fail')
    this.spinnerTarget.style.display = 'none'
  }

  error() {
    this.responseTarget.innerHTML = '<div><span>That didn\'t work!</span></div>'
    this.responseTarget.classList.add('ajax_fail')
    this.responseTarget.classList.remove('ajax_success')
    this.spinnerTarget.style.display = 'none'
  }

  toggle() {
    this.bannerTarget.classList.toggle('hidden')
    this.divTarget.classList.toggle('private_banner_visible')

    // The label was clicked, so we still need to check the box
    this.actualCheckboxTarget.checked = !this.actualCheckboxTarget.checked
  }
}

import { Controller } from 'stimulus'
import { TweenMax } from 'gsap/all'
import Turbolinks from 'turbolinks'
import Rails from '@rails/ujs'

export default class extends Controller {
  static targets = ['menu', 'header', 'switchToLight', 'switchToDark']

  initialize() {
    this.currentlyOpen = false
    this.lightStyles = document.querySelectorAll('link')[0]
    this.darkStyles = document.querySelectorAll('link')[1]
  }

  open(e) {
    e.preventDefault()
    this.menuTarget.style.display = 'block'
    this.currentlyOpen = true

    // https://greensock.com/ease-visualizer/
    TweenMax.from('.user_dropdown_menu_header img', 1.2,
      { width: '32px', height: '32px', ease: Elastic.easeOut })

    // a bit more manual than using click@window->user-dropdown#close
    // but this ensures the click handler only gets added when
    // the menu has been opened, which makes my performance brain happy
    e.stopImmediatePropagation()
    window.addEventListener('click', this)
    window.addEventListener('touchstart', this)
  }

  // This is a "special" method with secret implicit powers.
  // We are passing an object (this) into add/remove event listener
  // This is the  method that will be implicitly called
  // https://medium.com/@photokandy/til-you-can-pass-an-object-instead-of-a-function-to-addeventlistener-7838a3c4ec62
  handleEvent(e) {
    if (this.open && (this.escKeyPressed(e) || this.clickOutsideMenu(e))) {
      this.menuTarget.style.display = 'none'
      this.currentlyOpen = false
      window.removeEventListener('click', this)
      window.removeEventListener('touchstart', this)
    }
  }

  escKeyPressed(e) {
    return (e.type === 'keydown') && (e.keyCode === 27)
  }

  clickOutsideMenu(e) {
    return (e.type !== 'keydown')
      && (!this.menuTarget.contains(e.target) // outside whole menu
      || this.headerTarget.contains(e.target)) // inside header
  }

  switchToLight(e) {
    this.toggleTheme(e)
    this.switchToDarkTarget.style.display = 'block'
    this.switchToLightTarget.style.display = 'none'
    this.lightStyles.disabled = false

    // Buy the browser a bit of time to load the new styles
    // Ideally, while loading, we ask if the stylesheet is still 'disabled'
    // But that instantly returns false on toggling
    // So we are choosing a perceptual threshold that "just works"
    setTimeout(() => this.disableDark(), 100)
  }

  switchToDark(e) {
    this.toggleTheme(e)
    this.switchToLightTarget.style.display = 'block'
    this.switchToDarkTarget.style.display = 'none'
    this.darkStyles.disabled = false
    setTimeout(() => this.disableLight(), 100)
  }

  disableLight() {
    this.lightStyles.disabled = true
  }

  disableDark() {
    this.darkStyles.disabled = true
  }

  toggleTheme(e) {
    e.stopImmediatePropagation()
    Rails.ajax({
      url: "/toggle_theme",
      type: "PUT"
    })
    Turbolinks.clearCache()
  }
}

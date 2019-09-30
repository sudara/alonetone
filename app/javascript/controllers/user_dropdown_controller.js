import { Controller } from 'stimulus'
import { TweenMax } from 'gsap/all'

export default class extends Controller {
  static targets = ['menu', 'header']

  initialize() {
    this.currentlyOpen = false
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
  }

  // This is a "special" method with secret implicit powers.
  // We are passing an object (this) into add/remove event listener
  // This is the  method that will be implicitly called
  // https://medium.com/@photokandy/til-you-can-pass-an-object-instead-of-a-function-to-addeventlistener-7838a3c4ec62
  handleEvent(e) {
    if (this.open && ((e.keyCode === 27) || this.clickOutsideMenu(e))) {
      this.menuTarget.style.display = 'none'
      this.currentlyOpen = false
      window.removeEventListener('click', this)
    }
  }

  clickOutsideMenu(e) {
    return (e.type === 'click') &&
      (!this.menuTarget.contains(e.target) || // outside whole menu
      this.headerTarget.contains(e.target))   // inside header
  }
}

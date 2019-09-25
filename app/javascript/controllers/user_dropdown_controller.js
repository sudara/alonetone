import { Controller } from 'stimulus'
import { TweenMax } from 'gsap/all'

export default class extends Controller {
  static targets = ['menu']

  initialize() {
    this.currentlyOpen = false
  }

  open(e) {
    console.log('open is called')
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
    window.addEventListener('click', this.close.bind(this), { once: true })
  }

  close(e) {
    console.log('close is called')
    if (this.open && (e.keyCode === 27 || this.clickOutsideMenu(e))) {
      this.menuTarget.style.display = 'none'
      this.currentlyOpen = false
    }
  }

  clickOutsideMenu(e) {
    return (e.type === 'click') && !this.menuTarget.contains(e.target)
  }
}

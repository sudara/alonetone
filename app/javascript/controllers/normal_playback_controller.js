import { Controller } from '@hotwired/stimulus'
import { gsap } from 'gsap'

let currentlyOpen

// Owns the per-row "details reveal" on track lists. Playback moved to the
// persistent player (tracklist + player controllers); this only animates the
// expandable panel open/closed.
export default class extends Controller {
  static targets = ['details']
  static values = {
    unopenable: Boolean
  }

  // Pressing the row's play button queues audio via tracklist#play; reveal the
  // detail panel too so favorite/comment/private controls show, like before.
  openFromPlay() {
    if (currentlyOpen && currentlyOpen !== this) {
      currentlyOpen.closeDetails()
      currentlyOpen = undefined
    }
    if (!this.hasUnopenableValue) {
      this.openDetails()
    }
  }

  toggleDetails(e) {
    if (!e.target.classList.contains('artist')) {
      // if the link in the track top is the artist link, go to that URL,
      // otherwise open the track reveal section
      e.preventDefault()

      const isAlreadyOpen = this.element.classList.contains('open')
      // if another track details is open, close it
      if (currentlyOpen) {
        currentlyOpen.closeDetails()
      }
      if (!this.hasUnopenableValue && !isAlreadyOpen ) {
        this.openDetails()
      }
    }
  }

  closeDetails() {
    currentlyOpen = undefined
    this.element.classList.remove('open')
    // Height of the details could have changed (for example private banner showing)
    // So the margin offset for animating needs to be recalculated here
    gsap
      .to(this.detailsTarget, {
        duration: 0.25,
        marginTop: -this.detailsTarget.offsetHeight,
        ease: 'power4.inOut',
        display: 'none',
      })
  }

  openDetails() {
    if (currentlyOpen !== this) {
      this.element.classList.add('open')

      // can't animate "display" attribute as offsetHeight depends on it
      this.detailsTarget.style.display = 'block'
      gsap.set(this.detailsTarget, { marginTop: -this.detailsTarget.offsetHeight })
      gsap.to(this.detailsTarget, {
        duration: 0.25,
        marginTop: 0,
        ease: 'power4.inOut',
        display: 'block',
      })
    }
    currentlyOpen = this
  }

  disconnect() {
    if (this.element.classList.contains('open')) {
      this.element.classList.remove('open')
    }
  }
}

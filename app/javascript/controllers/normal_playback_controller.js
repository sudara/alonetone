import { Controller } from '@hotwired/stimulus'
import { gsap } from 'gsap'
import PlayAnimation from '../animation/play_animation'

let currentlyOpen

const PLAYER_EVENTS = ['player:trackchanged', 'player:loading', 'player:playing', 'player:paused', 'player:queueended']

// Owns a track row's "details reveal" plus its morphing play/pause button. The
// button animation is the same one as on main, now driven off the persistent
// player's events (filtered to this row's track) rather than a per-row engine.
export default class extends Controller {
  static targets = ['details']
  static values = {
    unopenable: Boolean
  }

  connect() {
    this.trackId = parseInt(this.element.dataset.trackId, 10)
    this.onPlayerEvent = (e) => this.syncPlayButton(e)
    PLAYER_EVENTS.forEach((type) => document.addEventListener(type, this.onPlayerEvent))
  }

  disconnect() {
    PLAYER_EVENTS.forEach((type) => document.removeEventListener(type, this.onPlayerEvent))
    this.resetAnimation()
    if (this.element.classList.contains('open')) {
      this.element.classList.remove('open')
    }
  }

  // Only react to events about this row's track; the queue ending or any event
  // for a different track returns the row to its resting play icon.
  syncPlayButton(event) {
    if (event.type === 'player:queueended') {
      this.resetAnimation()
      return
    }
    const id = event.detail && event.detail.track && event.detail.track.id
    if (id !== this.trackId) {
      this.resetAnimation()
      return
    }
    if (event.type === 'player:playing') this.toAnimState('playing')
    else if (event.type === 'player:paused') this.toAnimState('paused')
    else this.toAnimState('loading')
  }

  toAnimState(state) {
    if (this.animState === state) return
    this.ensureAnimation()
    if (!this.animation) return
    this.animState = state
    if (state === 'loading') {
      this.animation.loadingAnimation()
    } else if (state === 'playing') {
      // first play morphs play->pause; later resumes just snap to the pause icon
      if (this.animPlayed) this.animation.showPauseButton()
      else { this.animation.pausingAnimation(); this.animPlayed = true }
    } else {
      this.animation.showPlayButton()
    }
  }

  // Swap this row's static play icon for a clone of the shared animatable SVG.
  ensureAnimation() {
    if (this.animation) return
    const mount = this.element.querySelector('.playIconSymbol')
    if (mount && document.querySelector('#playAnimationSVG')) {
      this.animation = new PlayAnimation(mount)
    }
  }

  resetAnimation() {
    if (!this.animation) return
    this.animation.reset()
    this.animation = null
    this.animState = null
    this.animPlayed = false
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
}

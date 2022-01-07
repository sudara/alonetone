import { gsap } from 'gsap'
import PlaybackController from './playback_controller'
import PlayAnimation from '../animation/play_animation'

let currentlyOpen

export default class extends PlaybackController {
  // these are added to the targets defined in PlaybackController
  static targets = ['playButton', 'details', 'time', 'seekBarPlayed', 'title']

  playing() {
    this.animation.pausingAnimation()
    this.loaded = true
  }

  playCallback() {
    this.showLoadingAnimationOrPauseButton()
    if (currentlyOpen && (currentlyOpen !== this)) {
      currentlyOpen.closeDetails()
      currentlyOpen = undefined
    }
    this.openDetails()
    this.showSeekBar()
    this.registeredListen = true
    this.alreadyPlayed = true
  }

  pauseCallback() {
    this.animation.showPlayButton()
  }

  stopCallback() {
    this.animation.showPlayButton()
  }

  toggleDetails(e) {
    if (!e.target.classList.contains('artist')) {
      // if the link in the track top is the artist link, go to that URL,
      // otherwise open the track reveal section
      e.preventDefault()

      const wasOpen = this.element.classList.contains('open')
      // if another track details is open, close it
      if (currentlyOpen) {
        currentlyOpen.closeDetails()
      }
      if (!wasOpen && !this.data.get('openable')) {
        this.openDetails()
      }
    }
  }

  closeDetails() {
    currentlyOpen = undefined
    this.element.classList.remove('open')
    this.seekBarContainerTarget.classList.remove('show')
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
      if (this.alreadyPlayed) {
        this.seekBarContainerTarget.classList.add('show')
      }
    }
    currentlyOpen = this
  }

  showLoadingAnimationOrPauseButton() {
    this.setupAnimation()
    if (!this.loaded) {
      this.animation.loadingAnimation()
    } else this.animation.pausingAnimation()
  }

  // We have one single #playAnimationSVG element to move around and animate
  // Until this point, our play button has been a placeholder icon SVG
  // After this point, our play button is an animatable SVG
  // (Until play is pressed elsewhere)
  //
  // Note: Because our svg has a mask with an id, we can't have multiple copies of it in the DOM
  // Without refactoring how the svg and animation work
  setupAnimation() {
    if (!this.animation) {
      this.animation = new PlayAnimation(this.playButtonTarget)
    }
  }

  showSeekBar() {
    this.seekBarContainerTarget.classList.add('show');
  }

  seek(position) {
    const event = new CustomEvent('track:seek', { 'detail': { position } , 'bubbles': true })
    this.element.dispatchEvent(event)
  }
  
  // turbolinks caches pages, so let's make sure things are sane when we return
  disconnect() {
    super.disconnect()
    if (this.animation) {
      this.animation.reset()
    }
    if (this.element.classList.contains('open')) {
      this.element.classList.remove('open')
    }
  }
}

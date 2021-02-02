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
    // Height of the details could have changed (for example private banner showing)
    // So let's recalculate the offset for animating

    // After this animation is done in, in JS this time, hide the detailsTarget
    this.detailsTarget.style.marginTop = `-${this.detailsTarget.offsetHeight}px`
    this.element.classList.remove('open') // instead of removing the class, do the animation
    this.seekBarContainerTarget.classList.remove('show')
  }

  openDetails() {
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open') // maybe make an animation class
    }
    currentlyOpen = this
    this.detailsTarget.style.display = 'block'
    this.detailsTarget.style.marginTop = `-${this.detailsTarget.offsetHeight}px`
    // this.element.classList.add('open') // instead of adding the class, do the animation
    console.log( this.detailsTarget)
    this.timeline = gsap.timeline({ paused: true })
      .set(this.detailsTarget, { autoAlpha: 0, marginTop: 300 })
      .to(this.detailsTarget, { duration: 0.5, autoAlpha: 1, y: 0 })
      .to(this.detailsTarget, { duration: 1.0, autoAlpha: 0, y: 0 }, 3)
    this.timeline.restart()

    if (this.alreadyPlayed) {
      this.seekBarContainerTarget.classList.add('show')
    }
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

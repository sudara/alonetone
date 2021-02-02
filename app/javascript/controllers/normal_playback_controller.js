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

      if (this.openTimeline) {
        this.openTimeline.kill()
      }

      if (this.closeTimeline) {
        this.closeTimeline.kill()
      }

      this.closeTimeline = gsap.timeline({ paused: true })
      this.openTimeline = gsap.timeline({ paused: true })

      const wasOpen = this.element.classList.contains('open')
      // if another track details is open, close it
      if (currentlyOpen) {
        currentlyOpen.closeDetails()
        currentlyOpen = undefined
      }
      if (!wasOpen && !this.data.get('openable')) {
        this.openDetails()
      }
    }
  }

  closeDetails() {
    // Height of the details could have changed (for example private banner showing)
    // So let's recalculate the offset for animating
    this.element.classList.remove('open')
    this.seekBarContainerTarget.classList.remove('show')
    // this.openTimeline.pause()
    this.closeTimeline
      .to(this.detailsTarget, { duration: 0.25, marginTop: -this.detailsTarget.offsetHeight, ease: 'none' })
      .to(this.detailsTarget, { display: 'none' })
    this.closeTimeline.restart()
  }

  openDetails() {
    currentlyOpen = this
    this.element.classList.add('open')
    this.detailsTarget.style.display = 'block';
    // this.closeTimeline.pause()
    this.openTimeline
      .set(this.detailsTarget, { marginTop: -this.detailsTarget.offsetHeight, ease: 'none' })
      .to(this.detailsTarget, { duration: 0.25, marginTop: 0 })
    this.openTimeline.restart()
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

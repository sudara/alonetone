import { Controller } from 'stimulus'
import { gsap } from 'gsap'
import LargePlayAnimation from '../animation/large_play_animation'

export default class extends Controller {
  static targets = ['play', 'playButton', 'time', 'progressContainerInner', 'waveform', 'seekBar']

  initialize() {
    this.animation = new LargePlayAnimation()
    this.percentPlayed = 0.0
    this.setDelegate()
    this.setupPlayhead()
    this.setAnimationState()
  }

  setAnimationState() {
    if (this.delegate && this.delegate.isPlaying && !this.delegate.loaded) {
      // instantiated while an mp3 is still loading
      this.animation.loadingAnimation()
    } else if (this.delegate && this.delegate.isPlaying) {
      // ...while in the middle of playing
      this.animation.pausingAnimation()
      this.startPlayhead()
    } else if (this.delegate && this.delegate.positionFromStart(0.1)) {
      // ...after playing once but now paused
      this.animation.showPlayButton()
      this.showPlayhead()
      this.update(this.delegate.percentPlayed())
    } else {
      // ....loaded but not playing
      this.animation.showPlayButton()
    }
  }

  // the single/playlist controller that we are linked to
  setDelegate() {
    const itemInPlaylist = document.querySelector('.tracklist li.active')
    if (itemInPlaylist) this.delegate = this.application.getControllerForElementAndIdentifier(itemInPlaylist, 'playlist-playback')
    else {
      this.delegate = this.application.getControllerForElementAndIdentifier(this.element, 'single-playback')
    }
  }

  // called from whileLoading()
  play() {
    this.animation.showPauseButton()
    this.startPlayhead()
  }

  pause() {
    this.timeline.pause()
    this.animation.showPlayButton()
  }

  togglePlay(e) {
    this.setDelegate()
    this.delegate.togglePlay(e)
  }

  skim(e) {
    const offx = e.clientX - this.waveformTarget.getBoundingClientRect().left
    this.seekBarTarget.style.left = `${offx}px`
  }

  seek(e) {
    if (!this.delegate) this.setDelegate()
    const offset = e.clientX - this.waveformTarget.getBoundingClientRect().left
    const newPosition = offset / this.waveformTarget.offsetWidth
    this.delegate.seek(newPosition)
    this.update()
  }

  // called from the player
  update() {
    this.percentPlayed = this.delegate.percentPlayed()
    this.timeTarget.innerHTML = this.delegate.time
    if (Math.abs(this.percentPlayed - this.timeline.progress()) > 0.02) {
      // console.log(`playhead jogged from ${this.timeline.progress()} to ${this.percentPlayed}`)
      this.timeline.progress(this.percentPlayed)
    }
  }

  stop() {
    this.animation.showPlayButton()
    this.playheadAnimation.stop()
  }

  setupPlayhead() {
    this.timeline = gsap.timeline({ paused: true, duration: 1 })
    this.playheadAnimation = this.timeline.to(this.progressContainerInnerTarget, 1, {
      left: '100%',
      ease:  'none',
    }, 0)
    this.waveformAnimation = this.timeline.to('#waveform_reveal', 1, {
      attr: { x: '0' },
      ease:  'none',
    }, 0)
  }

  startPlayhead() {
    this.showPlayhead()
    this.update()
    this.timeline.play()
  }

  showPlayhead() {
    this.progressContainerInnerTarget.classList.add('visible')
    if (this.timeline.duration() === 1) {
      this.timeline.duration(this.delegate.duration)
    }
  }

  disconnect() {
    this.animation.reset()
  }
}

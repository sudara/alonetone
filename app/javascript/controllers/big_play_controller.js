import { Controller } from 'stimulus'
import LargePlayAnimation from '../animation/large_play_animation'
import Waveform from '../animation/waveform'

export default class extends Controller {
  static targets = ['play', 'playButton', 'time', 'progressContainerInner', 'waveform', 'seekBar']

  initialize() {
    this.animation = new LargePlayAnimation()
    this.waveform = this.setupWaveform()
    this.percentPlayed = 0.0
    this.setDelegate()
    this.animation.init()
    this.animation.play()
    this.playheadAnimation = new TweenMax(this.progressContainerInnerTarget, 0, {
      left: '100%',
      paused: true,
      ease: Linear.easeNone,
    })
    this.setAnimationState()
  }

  setAnimationState() {
    if (this.delegate && this.delegate.isPlaying && !this.delegate.loaded) {
      // instantiated while an mp3 is still loading
      this.animation.showLoading()
    } else if (this.delegate && this.delegate.isPlaying) {
      // ...while in the middle of playing
      this.animation.showLoading()
      this.animation.showPause()
      this.startPlayhead()
    } else if (this.delegate && this.delegate.positionFromStart(1)) {
      // ...after playing once but now paused
      this.animation.setPlay()
      this.showPlayhead()
      this.update(this.delegate.percentPlayed())
    } else {
      // ....loaded but not playing
      this.animation.setPlay()
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
    this.animation.showPause()
    this.startPlayhead()
  }

  pause() {
    this.playheadAnimation.pause()
    this.animation.setPlay()
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
    this.updatePlayhead()
  }

  // called from the player
  update(percentPlayed) {
    this.percentPlayed = percentPlayed
    this.waveform.update()
    this.timeTarget.innerHTML = this.delegate.time
    if (Math.abs(this.percentPlayed - this.playheadAnimation.progress()) > 0.02) {
      console.log(`playhead jogged from ${this.playheadAnimation.progress()} to ${this.percentPlayed}`)
      this.updatePlayhead()
    }
  }

  reset() {
    this.animation.reset()
    this.animation.setPlay()
    this.playheadAnimation.seek(0)
  }

  disconnect() {
    this.waveformTarget.querySelector('canvas').remove()
  }

  showPlayhead() {
    this.progressContainerInnerTarget.classList.add('visible')
    if (this.playheadAnimation.duration() === 0) {
      this.playheadAnimation.duration(this.delegate.duration)
    }
  }

  startPlayhead() {
    this.showPlayhead()
    this.playheadAnimation.play()
    this.updatePlayhead()
  }

  updatePlayhead() {
    this.playheadAnimation.progress(this.percentPlayed)
  }

  setupWaveform() {
    const controller = this
    const data = this.data.get('waveform')
    return new Waveform({
      container: this.waveformTarget,
      height: 54,
      percentPlayed: function () {
        return controller.percentPlayed
      },
      data,
    })
  }
}
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
    this.setAnimationState()
    this.playheadAnimation = new TweenMax(this.progressContainerInnerTarget, 100, {
      left: '100%',
      paused: true,
      ease: Linear.easeNone
    })
  }

  setAnimationState() {
    // initialized *while* an mp3 is still loading
    if (this.delegate && this.delegate.isPlaying && !this.delegate.loaded) {
      this.animation.showLoading()
    } else if (this.delegate && this.delegate.isPlaying) { // while playing
      this.animation.showLoading()
      this.animation.showPause()
      this.startPlayhead()
    } else if (this.delegate && this.delegate.positionFromStart(1)) { // after playing while paused
      this.animation.setPlay()
      this.update(this.delegate.percentPlayed())
      this.startPlayhead()
    } else { // loaded and not playing
      this.animation.setPlay()
    }
  }

  // this is the controller that the big play button / waveform is linked to
  setDelegate() {
    const itemInPlaylist = document.querySelector('.tracklist li.active')
    if (itemInPlaylist) this.delegate = this.application.getControllerForElementAndIdentifier(itemInPlaylist, 'playlist-playback')
    else {
      this.delegate = this.application.getControllerForElementAndIdentifier(this.element, 'single-playback')
    }
  }

  //  called from whileLoading()
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
  }

  update(percentPlayed) {
    this.percentPlayed = percentPlayed
    this.waveform.update()
    this.timeTarget.innerHTML = this.delegate.time
    if (Math.abs(this.percentPlayed - this.playheadAnimation.progress()) > 0.05) {
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

  startPlayhead() {
    this.progressContainerInnerTarget.classList.add('visible')
    this.playheadAnimation.duration(this.delegate.duration)
    this.playheadAnimation.play()
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
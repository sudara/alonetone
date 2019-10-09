import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
import { Howl } from 'howler'
import { bugsnagClient } from '../misc/bugsnag.js.erb'

let player
let whilePlayingCallbackFrequency = 100

// All variants of alonetone's javascript players extends this controller
export default class extends Controller {
  static targets = ['play', 'title', 'seekBarContainer', 'seekBarLoaded']

  initialize() {
    this.preInitialize()
    this.loaded = false
    this.isPlaying = false
    this.nextTrackLoading = false
    this.duration = 0
    this.time = '0:00'
    this.setupHowl()
  }

  disconnect() {
    if (this.sound.playing()) {
      this.sound.pause()
    }
  }

  setupHowl() {
    const controller = this
    this.sound = new Howl({
      src: Array(this.url),
      html5: true,
      preload: this.preload,
      // onend: controller.playNextTrack.bind(controller),
      onloaderror(id, e) {
        bugsnagClient.notify(`Failed to load mp3. Message: ${e}`)
      },
      onplay() {
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onseek() {
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onplayerror(id, e) {
        bugsnagClient.notify(e)
        controller.pause()
      },
    })
  }

  // Called once by the howler onplay/onseek callbacks
  // and recurses to give us a way to update throughout playback
  whilePlaying() {
    this.position = this.sound.seek()
    this.duration = this.sound.duration()

    if (this.sound.playing()) {
      this.whilePlayingCallback()
      if (!this.registeredListen && this.positionFromStart(5000)) {
        this.registerListen()
        this.registeredListen = true
      }
      if (!this.nextTrackLoading && this.positionFromEnd(10000)) {
        this.preloadNextTrack()
        this.nextTrackLoading = true
      }
      if (this.positionFromEnd(200)) {
        this.playNextTrack()
        this.stop()
      } else {
        // we don't need to update this 60 times a second, at most 10
        setTimeout(() => requestAnimationFrame(this.whilePlaying.bind(this)),
          whilePlayingCallbackFrequency)
      }
    }
    this.calculateTime()
  }

  // called immedately by js
  play(e) {
    this.sound.play()
    this.isPlaying = true
    if (player) {
      player.pause()
    }
    player = this
    this.element.classList.add('playing')
    this.playCallback(e)
  }

  pause() {
    this.sound.pause()
    player = null
    this.isPlaying = false
    this.pauseCallback()
  }

  stop() {
    this.sound.pause()
    this.sound.stop()
    this.stopCallback()
  }

  togglePlay(e) {
    e.preventDefault()
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  registerListen() {
    Rails.ajax({
      url: '/listens',
      type: 'POST',
      data: `id=${this.data.get('id')}`,
      success() {
      },
    })
  }

  nextTrack() {
    const next = this.element.nextElementSibling
    return this.application.getControllerForElementAndIdentifier(next, this.identifier)
  }

  playNextTrack() {
    if (this.nextTrack) this.nextTrack.play()
  }

  preloadNextTrack() {
    this.nextTrack = this.nextTrack()
    if (this.nextTrack) this.nextTrack.sound.load()
  }

  seek(newPosition) {
    if (!this.isPlaying) this.play()
    this.sound.seek(this.duration * newPosition)
  }

  positionFromEnd(ms) {
    const positionFromEnd = (this.duration - this.position) * 1000
    return ms > positionFromEnd
  }

  positionFromStart(ms) {
    return (this.position * 1000) > ms
  }

  percentPlayed() {
    return this.position / this.duration
  }

  calculateTime() {
    const time = Math.floor(this.position)
    const min = Math.floor(time / 60)
    const sec = time % 60
    this.time = min + ':' + (sec >= 10 ? sec : '0' + sec)
  }
}

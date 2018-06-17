import { Controller } from 'stimulus'
import { Howl } from 'howler'

let player

export default class extends Controller {
  static targets = ['play', 'title', 'time', 'seekBarContainer', 'seekBarLoaded']

  initialize() {
    this.preInitialize()
    this.loaded = false
    this.isPlaying = false
    this.setupHowl()
  }

  inPlaylist() {
    return this.data.has('inPlaylist') === true
  }

  disconnect() {
    if (this.sound.playing()) {
      console.log('disconnecting and stopping playback')
      this.sound.pause()
    }
  }

  setupHowl() {
    const controller = this
    this.sound = new Howl({
      src: Array(this.url),
      html5: true,
      preload: this.preload,
      onend: controller.playNextTrack.bind(controller),
      onplay() {
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onload() {

      },
    })
  }

  whilePlaying() {
    if (this.sound.playing()) {
      this.loaded = true
      this.whilePlayingCallback()
      // we don't want to update this 60 times a second, at most 10
      setTimeout(requestAnimationFrame(this.whilePlaying.bind(this)), 100)
    } else {
      console.log('not yet playing')
    }
  }

  play() {
    if (player) {
      player.pause()
    }
    player = this
    this.isPlaying = true
    this.sound.play()
    this.element.classList.add('playing')
    this.playCallback()
  }

  pause() {
    this.sound.pause()
    player = null
    this.isPlaying = false
    this.pauseCallback()
  }

  togglePlay(e) {
    e.preventDefault()
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  playNextTrack() {
    const next = this.element.nextElementSibling
    this.application.getControllerForElementAndIdentifier(next, this.identifier).play()
  }

  seek(newPosition) {
    if (!this.isPlaying) this.play()
    this.sound.seek(this.sound.duration() * newPosition)
  }

  percentPlayed() {
    return this.sound.seek() / this.sound.duration()
  }
}

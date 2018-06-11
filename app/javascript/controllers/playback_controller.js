import { Controller } from 'stimulus'
import { Howl } from 'howler'

let player

export default class extends Controller {
  static targets = ['play', 'title', 'time', 'seekBarContainer', 'seekBarLoaded']

  initialize() {
    this.preInitialize()
    this.isPlaying = false
    this.url = this.playTarget.querySelector('a').getAttribute('href')
    this.setupHowl()
    this.postInitialize()
  }

  inPlaylist() {
    return this.data.has('inPlaylist') === true
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
      onend: controller.playNextTrack.bind(controller),
      onplay() {
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onload() {

      },
    })
  }

  whilePlaying() {
    this.whilePlayingCallback()
    if (this.sound.playing()) {
      this.animation.setPause()
      setTimeout(requestAnimationFrame(this.whilePlaying.bind(this)), 100);
    }
  }

  play() {
    if (player) {
      player.pause()
    }
    player = this
    this.isPlaying = true
    this.animateLoading()
    this.playCallback()
    this.element.classList.add('playing')
    this.sound.play()
  }

  pause() {
    this.sound.pause()
    player = null
    this.isPlaying = false
    this.animation.setPlay()
  }

  togglePlay(e) {
    e.preventDefault()
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  seek(e) {
    if (!this.isPlaying) this.play()
    const offset = e.clientX - this.seekBarContainerTarget.getBoundingClientRect().left
    const newPosition = offset / this.seekBarContainerTarget.offsetWidth
    this.sound.seek(this.sound.duration() * newPosition)
  }

  animateLoading() {
    this.animation.showLoading()
  }

  playNextTrack() {
    const next = this.element.nextElementSibling
    this.application.getControllerForElementAndIdentifier(next, 'asset').play()
  }

  skim(e) {
    const offx = e.clientX - this.seekBarContainerTarget.getBoundingClientRect().left
    this.seekBarLoadedTarget.style.left = `${offx}px`
  }
}

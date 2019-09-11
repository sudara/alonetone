import PlaybackController from './playback_controller'

export default class extends PlaybackController {
  preInitialize() {
    this.url = this.playTarget.getAttribute('href')
    this.preload = true
  }

  playCallback(e) {
    if (!this.bigPlay) this.setBigPlay()
    this.bigPlay.setAnimationState()
    this.registeredListen = false
  }

  pauseCallback() {
    this.bigPlay.animation.setPlay()
  }

  whilePlayingCallback() {
    if (!this.bigPlay) this.setBigPlay()
    if (!this.loaded) {
      this.loaded = true
      this.bigPlay.play()
    }
    this.bigPlay.update(this.percentPlayed())
    console.log(this.sound.duration())
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track-content'), 'big-play')
  }
}
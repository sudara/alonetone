import PlaybackController from './playback_controller'

export default class extends PlaybackController {
  preInitialize() {
    this.url = this.playTarget.getAttribute('href')
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.preload = this.playTarget.parentElement.classList.contains('active')
  }

  playCallback(e) {
    if (!this.bigPlay) this.setBigPlay()
    if (this.loaded) this.bigPlay.animation.setPause()
    else this.bigPlay.animation.showLoading()
    this.registeredListen = false
  }

  pauseCallback() {
    this.bigPlay.animation.setPlay()
  }

  whilePlayingCallback() {
    if (!this.bigPlay) this.setBigPlay()
    if (!this.loaded) {
      this.bigPlay.animation.showPause()
      this.loaded = true
    }
    this.bigPlay.percentPlayed = this.percentPlayed()
    this.bigPlay.waveform.update()
    this.bigPlay.timeTarget.innerHTML = this.time
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track-content'), 'big-play')
  }
}
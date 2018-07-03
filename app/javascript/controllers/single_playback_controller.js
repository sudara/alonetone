import PlaybackController from './playback_controller'

export default class extends PlaybackController {
  preInitialize() {
    this.url = this.playTarget.getAttribute('href') + '.mp3'
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.preload = this.playTarget.parentElement.classList.contains('active')
  }

  playCallback(e) {
    if (!this.bigPlay) this.setBigPlay()
    this.bigPlay.animation.showLoading()
  }

  pauseCallback() {
    this.bigPlay.animation.setPlay()
  }

  whilePlayingCallback() {
    if (!this.bigPlay) this.setBigPlay()
    if (this.sound.seek() > 0.5) this.bigPlay.animation.setPause()
    this.bigPlay.percentPlayed = this.percentPlayed()
    this.bigPlay.waveform.update()
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track-content'), 'big-play')
  }
}
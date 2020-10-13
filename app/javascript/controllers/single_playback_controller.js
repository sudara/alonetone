import PlaybackController from './playback_controller'

export default class extends PlaybackController {

  initialize() {
    this.setBigPlay()
  }

  fireClick() {} // only relevant in playlist player

  playCallback() {
    this.bigPlay.setAnimationState(true)
  }

  playing(event) {
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    this.bigPlay.play()
  }

  pauseCallback() {
    this.bigPlay.pause()
  }

  stopCallback() {
    this.bigPlay.stop()
  }

  whilePlaying(event) {
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track_content'), 'big-play')
  }
}
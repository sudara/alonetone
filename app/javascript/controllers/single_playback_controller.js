import PlaybackController from './playback_controller'

export default class extends PlaybackController {

  initialize() {
    this.setBigPlay()
  }

  // this method is called by bigPlay
  // but are only relevant in playlist player
  // they are no-ops here since we can rely on stitches
  fireClick() {}

  playCallback() {
    this.bigPlay.animation.loadingAnimation()
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

  whileLoading(event) {
    this.bigPlay.load(event.detail.duration)
  }

  whilePlaying(event) {
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track_content'), 'big-play')
  }
}
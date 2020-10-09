import PlaybackController from './playback_controller'

export default class extends PlaybackController {

  initialize() {
    this.duration = 0.0
    this.currentTime = 0.0
    this.percentPlayed = 0.0
  }

  fireClick() {} // only relevant in playlist player

  playCallback(e) {}

  playing(event) {
    console.log("SINGLE PLAY YOOOOOO")

    if (!this.bigPlay) this.setBigPlay()
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    this.bigPlay.setAnimationState(this.isPlaying)
    this.bigPlay.play()
  }

  pauseCallback() {
    console.log("BIG PLAY PAUSED YO")
    this.bigPlay.pause()
  }

  stopCallback() {
    this.bigPlay.stop()
  }

  whilePlaying(event) {
    console.log("WHILE PLAYING SINGLESSS")
    this.duration = event.detail.duration
    this.currentTime = event.detail.currentTime
    this.percentPlayed = event.detail.percentPlayed
    if (this.bigPlayLoaded) {
      this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    }
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track_content'), 'big-play')
  }
}
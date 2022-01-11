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
  }

  pauseCallback() {
  }

  stopCallback() {
  }

  whileLoading(event) {
  }

  whilePlaying(event) {
  }

  setBigPlay() {
  }
}

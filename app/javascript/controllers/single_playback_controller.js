import PlaybackController from './playback_controller'

export default class extends PlaybackController {
  // this method is called by bigPlay
  // but are only relevant in playlist player
  // they are no-ops here since we can rely on stitches

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

  seek(event) {
    const stitchesEvent = new CustomEvent('track:seek', { detail: { position: event.detail.position }, bubbles: true })
    this.element.dispatchEvent(stitchesEvent)
  }
}
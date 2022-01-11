import PlaybackController from './playback_controller'

export default class extends PlaybackController {
  /* TODO: this single playback class should probably be thrown away
    seek can be moved into playback_controller
    and the rest can just be handled by big-play's stitches callbacks
  */
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